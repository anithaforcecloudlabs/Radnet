public class DH_DexOutServiceRisOpenPatientParserMS {
     @AuraEnabled
    public static Id constructResponse(String response,DH_DexOutServiceRisOpenPatientRequest urlParametersWrapper) {
        String accId;
	 if (response != null) {
			List<Object> resultList = (List<Object>) JSON.deserializeUntyped(response);
         System.debug('resultList'+resultList);
            List<Object> patientList = (List<Object>) resultList[1];
         System.debug('patientList'+patientList);
            Map<String, Object> patientMap = (Map<String, Object>) patientList[0];
            String patientDataStr = (String) patientMap.get('data'); 
          System.debug('patientDataStr'+patientDataStr);
			List<DH_DexOutServiceRisOpenPatientResponse.Data> patientRecords = (List<DH_DexOutServiceRisOpenPatientResponse.Data>) JSON.deserialize(patientDataStr, List<DH_DexOutServiceRisOpenPatientResponse.Data>.class);
            accId = upsertPatientAccountForMessaging(patientRecords[0],urlParametersWrapper);
        }
        return accId;
	}
    /**
	* @Jira CC-716,633,664
    * @description - This method is used to upsert the person accounts based on the patient data returned from the RIS.
    * @param  - DH_DexOutServiceRisOpenPatientResponse.Data,DH_DexOutServiceRisOpenPatientRequest
	* @return - Id
	**/
   @AuraEnabled
public static Id upsertPatientAccountForMessaging(
    DH_DexOutServiceRisOpenPatientResponse.Data patientWrapper,
    DH_DexOutServiceRisOpenPatientRequest urlParametersWrapper
) {
    Account patient;
    Id patientId;

    if (urlParametersWrapper.systemId != null && patientWrapper.patient_key != null) {
        // normalize systemId (remove "_Training" suffix if present)
        urlParametersWrapper.systemId = (urlParametersWrapper.systemId.contains('_Training')) 
            ? urlParametersWrapper.systemId.split('_')[0] 
            : urlParametersWrapper.systemId;

        // Create unique identifier for this Patient Account
        String uniquePatientIdentifier = urlParametersWrapper.systemId 
            + '_' + patientWrapper.patient_key 
            + '_' + System.Label.DH_PersonAccountRecordTypeName;

        Set<String> accUniqueIdSet = new Set<String>{ uniquePatientIdentifier };

        // Fetch existing patient if already stored
        List<Account> patList = DH_ContactCenterCachingUtility.getUniqueKeyVsAccountMap(accUniqueIdSet).values();

        DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
        try {
            if (patList.isEmpty()) {
                patient = new Account();
                patient.RecordTypeId = DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
                patient.DH_RIS_Unique_Code__c = uniquePatientIdentifier;
            } else {
                patient = patList[0];
            }

            // Fill patient details
            patient.Region__c = urlParametersWrapper.systemId;
            patient.DH_Patient_Key__c = patientWrapper.patient_key;
            patient.FirstName = patientWrapper.first_name;
            patient.MiddleName = patientWrapper.middle_name;
            patient.LastName = patientWrapper.last_name;
            patient.DH_Patient_Id__c = patientWrapper.patient_id;
            patient.DH_Issuer_Of_Patient_Id__c = patientWrapper.issuer_of_patient_id;
            patient.PersonBirthdate = (patientWrapper.birth_date != null) 
                ? Date.valueOf(patientWrapper.birth_date) : null;
            patient.DH_Gender_Code__c = patientWrapper.gender_code;
            patient.DH_Primary_Address_Line1__c = patientWrapper.primary_address_line1;
            patient.DH_Primary_Address_Line2__c = patientWrapper.primary_address_line2;
            patient.DH_Primary_Address_City__c = patientWrapper.primary_address_city;
            patient.DH_Primary_Address_State__c = patientWrapper.primary_address_state;
            patient.DH_Primary_Address_Zipcode__c = patientWrapper.primary_address_zipcode;
            patient.DH_Patient_Extra_Info__c = String.valueOf(patientWrapper.patientExtraInfo);
            patient.DH_Patient_Alerts__c = String.valueOf(patientWrapper.patientAlerts);
            patient.Source_Type__c=System.Label.Chat;

            if (patientWrapper.patientPhones != null) {
                for (DH_DexOutServiceRisOpenPatientResponse.PatientPhones phone : patientWrapper.patientPhones) {
                    if (phone.display_order == 1) {
                        patient.DH_Contact_Point_Phone__c = phone.phone_number;
                    }
                }
            }

            if (patientWrapper.patientEmailAddresses != null) {
                for (DH_DexOutServiceRisOpenPatientResponse.PatientEmailAddresses email : patientWrapper.patientEmailAddresses) {
                    if (email.display_order == 1 && isValidEmail(email.email_address)) {
                        patient.DH_Contact_Point_Email__c = email.email_address;
                    } else if (isValidEmail(email.email_address) && patient.DH_Contact_Point_Email__c == null) {
                        patient.DH_Contact_Point_Email__c = email.email_address;
                        break;
                    }
                }
            }

            // Insert or update patient
            if (patient != null) {
                upsert patient DH_RIS_Unique_Code__c;
            }

            // Create related contact point records
            createContactPhone(patientWrapper.patientPhones, patient.Id, urlParametersWrapper.systemId);
            createContactEmail(patientWrapper.patientEmailAddresses, patient.Id, urlParametersWrapper.systemId);

            // Now map patient to MessagingSession → via MessagingEndUser
            Id msId = urlParametersWrapper.recordId; // this should be the MessagingSession Id
            if (msId != null && patient.Id != null) {
                MessagingSession ms = [
                    SELECT Id, MessagingEndUserId ,caseid
                    FROM MessagingSession 
                    WHERE Id = :msId
                    LIMIT 1
                ];

                if (ms != null && ms.MessagingEndUserId != null) {
                    MessagingEndUser meu = [
                        SELECT Id, AccountId 
                        FROM MessagingEndUser 
                        WHERE Id = :ms.MessagingEndUserId
                        LIMIT 1
                    ];

                    meu.AccountId = patient.Id;
                    update meu; // link MessagingSession’s end user to this patient
                }
                if (ms.CaseId != null) {
            Case c = [
                SELECT Id, AccountId
                FROM Case
                WHERE Id = :ms.CaseId
                LIMIT 1
            ];
                    system.debug('Case'+c);
            c.AccountId = patient.Id;
                    system.debug('Caseacco'+c.AccountId);
            update c;
        }
            }
        } catch (Exception ex) {
            logWrapper.exp = ex;
            logWrapper.relatedTo = urlParametersWrapper.recordId;
            logWrapper.className = 'DH_DexOutServiceRisOpenPatientParser-upsertPatientAccountForMessaging';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
    } else {
        DH_DexLoggingUtility.Logger logWrap = new DH_DexLoggingUtility.Logger();
        logWrap.serviceName = 'DH_DexOutServiceRisOpenPatientParser';
        String error = urlParametersWrapper.systemId == null ? ' urlParametersWrapper.systemId,' : '';
        String error2 = patientWrapper.patient_key == null ? ' patientWrapper.patient_key' : '';
        logWrap.errorMessage = DH_GlobalConstants.MISSING_INFO + error + error2;
        logWrap.RelatedTo = urlParametersWrapper.recordId;
        logWrap.ClassName = 'DH_DexOutServiceRisOpenPatientParser-upsertPatientAccountForMessaging';
        DH_DexLoggingUtility.createLogRecord(logWrap);
    }

    if (patient != null) {
        patientId = patient.Id;
    }
    return patientId;
}

	/**
	* @Jira CC-716,633,664
    * @description - This method is used to validate the format of the email address.
    * @param  - String
	* @return - Boolean
	**/
	public static Boolean isValidEmail(String emailAddress) {
		if (emailAddress == null) {
			return false;
		}
		String emailRegex = System.Label.DH_ValidEmailFormat;
		Pattern emailPattern = Pattern.compile(emailRegex);
		Matcher emailMatcher = emailPattern.matcher(emailAddress);
		return emailMatcher.matches();
	}
	/**
	* @Jira CC-716,633,664
    * @description - This method is used the parse the response returned from the DH_DexOutServiceRisOpenPatient service class.
    * @param  - List<DH_DexOutServiceRisOpenPatientResponse.PatientPhones>,Id,String
	**/
    @AuraEnabled
    public static void createContactPhone(List<DH_DexOutServiceRisOpenPatientResponse.PatientPhones> phoneList,Id patientId,String systemId) {
		List<ContactPointPhone> phoneListToUpsert = new List<ContactPointPhone>();
		DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
		Set<String> phoneKeySet = new Set<String>();
		try{
			if(phoneList != null && patientId!= null && systemId!= null){
				for(DH_DexOutServiceRisOpenPatientResponse.PatientPhones phoneRec: phoneList){
					String phoneRisKey = systemId + '_' + phoneRec.patient_phone_key + '_' + System.label.DH_ContactPointPhoneRecordTypeName;
					phoneKeySet.add(phoneRisKey);
					ContactPointPhone phone = new ContactPointPhone();
					phone.DH_Patient_Phone_Key__c = String.valueOf(phoneRec.patient_phone_key);
					phone.DH_RIS_PhoneKey__c = phoneRisKey;
					phone.TelephoneNumber = phoneRec.phone_number;
					phone.DH_Mobile_Flag__c = phoneRec.mobile_flag != null && phoneRec.mobile_flag == 'Y' ? true : false;
					phone.IsPrimary = phoneRec.primary_flag != null && phoneRec.primary_flag == 'Y' ? true : false;
					phone.PreferenceRank = phoneRec.display_order;
					phone.ParentId = patientId;
					phoneListToUpsert.add(phone);
				}
			}
			if(phoneListToUpsert != null && (Schema.sObjectType.ContactPointPhone.isUpdateable() && Schema.sObjectType.ContactPointPhone.isCreateable())) {
				upsert phoneListToUpsert DH_RIS_PhoneKey__c;
			}
			List<ContactPointPhone> recordToDelete = DH_ContactCenterCachingUtility.getContactPhoneMap(phoneKeySet,patientId).values();
			if(recordToDelete != null && Schema.sObjectType.ContactPointPhone.isDeletable()) {
				delete recordToDelete;
			}
		}catch (Exception ex) {
            logWrapper.exp =  ex;
            logWrapper.relatedTo = patientId;
            logWrapper.className = 'DH_DexOutServiceRisOpenPatientParser-createContactPhone';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
	}
	/**
	* @Jira CC-716,633,664
    * @description - This method is used the parse the response returned from the DH_DexOutServiceRisOpenPatient service class.
    * @param - List<DH_DexOutServiceRisOpenPatientResponse.PatientEmailAddresses>,Id,String
	**/
    @AuraEnabled
    public static void createContactEmail(List<DH_DexOutServiceRisOpenPatientResponse.PatientEmailAddresses> emailAddressList,Id patientId, String systemId){
		Set<String> emailsKeys = new Set<String>();
		DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
		List<ContactPointEmail> emailsListToUpsert = new List<ContactPointEmail>();
		try{
			if(emailAddressList != null && patientId!= null && systemId!= null){
				for(DH_DexOutServiceRisOpenPatientResponse.PatientEmailAddresses email : emailAddressList) {
					if(isValidEmail(email.email_address)) {
						String risEmailkey = systemId + '_' + email.patient_email_key + '_' + System.label.DH_ContactPointEmailRecordTypeName;
						emailsKeys.add(risEmailkey);
						ContactPointEmail emailRec = new ContactPointEmail();
						emailRec.ParentId = patientId;
						emailRec.DH_RIS_EmailKey__c = risEmailkey;
						emailRec.DH_Email_Key__c = String.valueOf(email.patient_email_key);
						emailRec.EmailAddress = email.email_address;
						emailRec.IsPrimary = email.primary_flag != null && email.primary_flag == 'Y' ? true : false;
						emailRec.PreferenceRank = email.display_order;
						emailsListToUpsert.add(emailRec);
					}
				}
			}
			if(emailsListToUpsert != null && emailsListToUpsert.size() > 0 && Schema.sObjectType.ContactPointEmail.isUpdateable() && Schema.sObjectType.ContactPointEmail.isCreateable()) {
				upsert emailsListToUpsert DH_RIS_EmailKey__c;
			}
			List<ContactPointEmail> emailrecordToDelete = DH_ContactCenterCachingUtility.getContactEmailMap(emailsKeys,patientId).values();
			if(emailrecordToDelete != null && emailrecordToDelete.size() > 0 && Schema.sObjectType.ContactPointEmail.isDeletable()) {
				delete emailrecordToDelete;
			}
		}catch (Exception ex) {
            logWrapper.exp =  ex;
            logWrapper.relatedTo = patientId;
            logWrapper.className = 'DH_DexOutServiceRisOpenPatientParser-createContactEmail';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
	}

}