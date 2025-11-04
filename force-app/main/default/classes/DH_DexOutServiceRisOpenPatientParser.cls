/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisOpenPatientParser
* Created Date - 06-August-2024 
* @description : Parser class for DH_DexOutServiceRisOpenPatient service class.
* Modification Log :
* -------------------------------------------------------------------------------------------------------
* Jira#                          Date                 Description
* --------------------        --------------       ---------------------
* CC-505                      06-August-2024        Added constructResponse method
* CC-716                      12-August-2024        Updated constructResponse and added upsertPatientAccount and isValidEmail methods
* CC-633                      17-August-2024        Added createContactPhone method
* CC-664                      21-August-2024        Added createEmailPhone method
* CC-430                      10-September-2024     Updated upsertPatientAccount method
* CC-1268                     18-September-2024     Updated upsertPatientAccount method
* CC-1557                     06-May-2025           Added upsertPatientAccount method
* *********************************************************************************************************************************************
*/
public without sharing class DH_DexOutServiceRisOpenPatientParser {
    /**
	* @Jira CC-505,716,633,664
    * @description - This method is used the parse the response returned from the DH_DexOutServiceRisOpenPatient service class.
    * @param  - String,DH_DexOutServiceRisOpenPatientRequest
	* @return - Id
	**/
    @AuraEnabled
    public static Id constructResponse(String response,DH_DexOutServiceRisOpenPatientRequest urlParametersWrapper) {
		String accId;
        if (response != null) {
			List<Object> resultList = (List<Object>) JSON.deserializeUntyped(response);
            List<Object> patientList = (List<Object>) resultList[1];
            Map<String, Object> patientMap = (Map<String, Object>) patientList[0];
            String patientDataStr = (String) patientMap.get('data'); 
			List<DH_DexOutServiceRisOpenPatientResponse.Data> patientRecords = (List<DH_DexOutServiceRisOpenPatientResponse.Data>) JSON.deserialize(patientDataStr, List<DH_DexOutServiceRisOpenPatientResponse.Data>.class);
            accId = upsertPatientAccount(patientRecords[0],urlParametersWrapper);
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
    public static Id upsertPatientAccount(DH_DexOutServiceRisOpenPatientResponse.Data patientWrapper, DH_DexOutServiceRisOpenPatientRequest urlParametersWrapper) {
		Account patient;
		Id patientId;
		if(urlParametersWrapper.systemId != null && patientWrapper.patient_key != null){
			urlParametersWrapper.systemId = (urlParametersWrapper.systemId.contains('_Training')) ? urlParametersWrapper.systemId.split('_')[0] :urlParametersWrapper.systemId;
			String uniquePatientIdentifier = urlParametersWrapper.systemId +'_'+patientWrapper.patient_key +'_' + System.Label.DH_PersonAccountRecordTypeName;
			Set<String> accUniqueIdSet = new Set<String>();
			accUniqueIdSet.add(uniquePatientIdentifier);
			List<Account> patList = DH_ContactCenterCachingUtility.getUniqueKeyVsAccountMap(accUniqueIdSet).values();
			DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
			try {
				if (patList.size() == 0) {
					patient = new Account();
					patient.RecordTypeId = DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
					patient.DH_RIS_Unique_Code__c = uniquePatientIdentifier;
				} else {
					patient = patList[0];
				}
				patient.Region__c = urlParametersWrapper.systemId;
				patient.DH_Patient_Key__c = patientWrapper.patient_key;
				patient.Firstname = patientWrapper.first_name;
				patient.MiddleName = patientWrapper.middle_name;
				patient.LastName = patientWrapper.last_name;
				patient.DH_Patient_Id__c = patientWrapper.patient_id;
				patient.DH_Issuer_Of_Patient_Id__c = patientWrapper.issuer_of_patient_id;
				patient.PersonBirthdate = patientWrapper.birth_date != null ? Date.valueOf(patientWrapper.birth_date) : null;
				patient.DH_Gender_Code__c = patientWrapper.gender_code;
				patient.DH_Primary_Address_Line1__c = patientWrapper.primary_address_line1;
				patient.DH_Primary_Address_Line2__c = patientWrapper.primary_address_line2;
				patient.DH_Primary_Address_City__c = patientWrapper.primary_address_city;
				patient.DH_Primary_Address_State__c = patientWrapper.primary_address_state;
				patient.DH_Primary_Address_Zipcode__c = patientWrapper.primary_address_zipcode;
				patient.DH_Patient_Extra_Info__c = String.valueOf(patientWrapper.patientExtraInfo);
				patient.DH_Patient_Alerts__c = String.valueOf(patientWrapper.patientAlerts);
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
							patient.DH_Contact_Point_Email__c = email.Email_Address;
						} else if (isValidEmail(email.email_address) && patient.DH_Contact_Point_Email__c == null) {
							patient.DH_Contact_Point_Email__c = email.email_address;
							break;
						}
					}
				}
				if (patient != null) {
					upsert patient DH_RIS_Unique_Code__c;
				}
				createContactPhone(patientWrapper.patientPhones,patient.Id,urlParametersWrapper.systemId);
				createContactEmail(patientWrapper.patientEmailAddresses,patient.Id,urlParametersWrapper.systemId);
				Id vcId = urlParametersWrapper.recordId;
                List<Case> caseList = [Select id from Case where DH_VoiceCall__c=:vcId];
				if(vcId != null && patient.Id != null){
					DH_VerifyCallerController.mapVoiceCallToPersonAccount(vcId,patient.Id);
                    if(caseList.isEmpty()){
                      DH_GeneralUtility.createContactCenterCase(patient.Id,vcId);  
                    }					
				}
			}catch (Exception ex) {
				logWrapper.exp =  ex;
				logWrapper.relatedTo = urlParametersWrapper.recordId;
				logWrapper.className = 'DH_DexOutServiceRisOpenPatientParser-upsertPatientAccount';
				DH_DexLoggingUtility.createLogRecord(logWrapper);
			}
		}
		else{
            DH_DexLoggingUtility.Logger logWrap = new DH_DexLoggingUtility.Logger();
            logWrap.serviceName = 'DH_DexOutServiceRisOpenPatientParser';
            String error = urlParametersWrapper.systemId == null ? ' urlParametersWrapper.systemId,':'';
            String error2  = patientWrapper.patient_key ==null ?' patientWrapper.patient_key': '';
            logWrap.errorMessage = DH_GlobalConstants.MISSING_INFO + error + error2;
            logWrap.RelatedTo = urlParametersWrapper.recordId;
            logWrap.ClassName = 'DH_DexOutServiceRisOpenPatientParser-upsertPatientAccount';
            DH_DexLoggingUtility.createLogRecord(logWrap);
        }
		if(patient != null){
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