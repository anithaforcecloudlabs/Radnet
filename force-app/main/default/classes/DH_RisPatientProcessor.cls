/******************************************************************************************************************************************************
 *
 * @Created Date    :  7/5/2024
 * @description     : DH_RisPatientProcessor Class receives a JSON wrapper and Processes Patient and it's realted  Object Records in SFHC
 * @parm			:
 * TODO				:
 * @Jira Id         : CC-355
 * ModifiedDate 	: 02-Sep-2024
 * Modified			: added Update DML specific to Healthcloud_Id to update recordId
 *
 * ****************************************************************************************************************************************************/

public class DH_RisPatientProcessor {
	private static final String STATE_MODIFIED = 'modified';
	public Boolean isOptedOutMarketingCloud;

	public Map<String, Boolean> getPatientExtraInfo(DH_PatientInfoWrapper wrapper) {
		Map<String, Boolean> optInfo = new Map<String, Boolean>();
		optInfo.put(System.Label.DH_StopEmail, false);
		optInfo.put(System.Label.DH_StopPhone, false);
		optInfo.put(System.Label.DH_GlobalOptOut, false);
		if (wrapper.patient.data.patientExtraInfo != null) {
			for (DH_PatientInfoWrapper.PatientExtraInfo info : wrapper.patient.data.patientExtraInfo) {
				if (info.patient_extra_info_code == System.Label.DH_StopEmail) {
					optInfo.put(System.Label.DH_StopEmail, true);
				} else if (info.patient_extra_info_code == System.Label.DH_StopPhone) {
					optInfo.put(System.Label.DH_StopPhone, true);
				} else if (info.patient_extra_info_code == System.Label.DH_GlobalOptOut) {
					optInfo.put(System.Label.DH_GlobalOptOut, true);
				}
			}
		}

		return optInfo;
	}
	public Id patientProcessor(DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();
		Boolean doCallOptIn;

		if (wrapper.patient.object_state != STATE_MODIFIED) {
			String patientUniqueKey = utilityInstance.uniqueIdentifier(wrapper.patient.system_id, wrapper.patient.data.patient_Key, System.Label.DH_PersonAccountRecordTypeName);
			List<Account> existingPatient = modifiedPatient(patientUniqueKey);
            if(!existingPatient.isEmpty()){
            return existingPatient[0].Id;  
            }

		}

		Id region;
		if (wrapper.patient.system_id != null) {
			region = utilityInstance.fetchRegion(wrapper.patient.system_id);
		}

		Account patientAcc = new Account();

		patientAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.DH_PersonAccountRecordTypeName).getRecordTypeId();
		patientAcc.DH_RIS_Unique_Code__c = utilityInstance.uniqueIdentifier(wrapper.patient.system_id, wrapper.patient.data.patient_key, System.Label.DH_PersonAccountRecordTypeName);
		patientAcc.DH_System_Id__c = wrapper.patient.system_id;
        patientAcc.Region__c = wrapper.patient.system_id;
		patientAcc.AccountRegion__c = region != null ? region : null;
		patientAcc.DH_patient_key__c = wrapper.patient.data.patient_key;
		patientAcc.Firstname = wrapper.patient.data.first_name;
		patientAcc.MiddleName = wrapper.patient.data.middle_name;
		patientAcc.LastName = wrapper.patient.data.last_name;
		patientAcc.DH_Name_Prefix_Code__c = wrapper.patient.patient_prefix_code;
		patientAcc.DH_Name_Suffix_Code__c = wrapper.patient.patient_suffix_code;
		patientAcc.DH_Patient_Id__c = wrapper.patient.data.patient_id;
		patientAcc.DH_Issuer_Of_Patient_Id__c = wrapper.patient.data.Issuer_Of_Patient_Id;
		patientAcc.PersonBirthdate = wrapper.patient.data.birth_date != null ? Date.valueOf(wrapper.patient.data.birth_date) : null;
		patientAcc.DH_Gender_Code__c = wrapper.patient.data.Gender_Code;
		patientAcc.DH_Primary_Address_Line1__c = wrapper.patient.data.Primary_Address_Line1;
		patientAcc.DH_Primary_Address_Line2__c = wrapper.patient.data.Primary_Address_Line2;
		patientAcc.DH_Primary_Address_City__c = wrapper.patient.data.Primary_Address_City;
		patientAcc.DH_Primary_Address_State__c = wrapper.patient.data.Primary_Address_State;
		patientAcc.DH_Primary_Address_Zipcode__c = wrapper.patient.data.Primary_Address_Zipcode;
		patientAcc.DH_Primary_Language_Code__c = wrapper.patient.data.Primary_Language_Code;
		patientAcc.DH_Master_Patient_Key__c = wrapper.patient.data.master_patient_key;
		//process phone nodes logic
		if (wrapper.patient.data.patientPhones != null) {
			for (DH_PatientInfoWrapper.PatientPhones phone : wrapper.patient.data.patientPhones) {
				// If the display order of the phone is 1 then add that phone number as primary phone number on person account
				if (phone.display_order == String.valueOf(1)) {
					patientAcc.DH_Contact_Point_Phone__c = phone.phone_number;
				}
			}
		}
		//pocess email node logic
		if (wrapper.patient.data.patientEmailAddresses != null) {
			for (DH_PatientInfoWrapper.PatientEmailAddresses email : wrapper.patient.data.patientEmailAddresses) {
				// If the display order of the email is 1 then add that email as primary email on person account
				if (email.display_order == String.valueOf(1) && isValidEmail(email.email_address)) {
					patientAcc.DH_Contact_Point_Email__c = email.Email_Address;
				} else if (isValidEmail(email.email_address) && patientAcc.DH_Contact_Point_Email__c == null) {
					patientAcc.DH_Contact_Point_Email__c = email.email_address;
					break;
				}
			}
		}
		//process extra Info logic
		Map<String, Boolean> optoutInfo = getPatientExtraInfo(wrapper);
		patientAcc.DH_HasOptedOutEmail__c = optoutInfo.get(System.Label.DH_StopEmail) || optoutInfo.get(System.Label.DH_GlobalOptOut);
		patientAcc.DH_HasOptedOutSMS__c = optoutInfo.get(System.Label.DH_StopPhone) || optoutInfo.get(System.Label.DH_GlobalOptOut);
		patientAcc.DH_HasOptedOut__c = optoutInfo.get(System.Label.DH_GlobalOptOut) || (optoutInfo.get(System.Label.DH_StopEmail) && optoutInfo.get(System.Label.DH_StopPhone));
		if (patientAcc.DH_HasOptedOut__c == false || patientAcc.DH_HasOptedOutSMS__c == false) {
			doCallOptIn = true;
		}
		//update patient if the HealthCloud Id Received 
		if(wrapper.patient.health_cloud_id != null && wrapper.patient.health_cloud_id.startsWith('001')){
			patientAcc.Id = wrapper.patient.health_cloud_id;
			patientAcc.DH_status__C = system.label.DH_patientActive;
			update patientAcc;
		}

		if (patientAcc != null) {
			upsert patientAcc DH_RIS_Unique_Code__c;
		}

		if (!String.isBlank(wrapper.patient.data.primary_language_code)) {
			patientLanguageProcessor(patientAcc.Id, wrapper);
		}
		if (wrapper.patient.data.patientPhones != null) {
			patientPhoneProcessor(patientAcc.Id, wrapper);
		}
		if (wrapper.patient.data.patientEmailAddresses != null) {
			patientEmailProcessor(patientAcc.Id, wrapper);
		}
		if (wrapper.patient.data.patientExtraInfo != null) {
			patientExtraInfoProcessor(patientAcc.Id, wrapper);
		}
		if (wrapper.patient.data.patientAlerts != null) {
			patientAlertProcessor(patientAcc.Id, wrapper);
		}
		if (doCallOptIn == true) {
			List<Account> patientRec = [SELECT Id, DH_isOptedOutFromMarketingCloud__c FROM Account WHERE Id = :patientAcc.Id AND DH_isOptedOutFromMarketingCloud__c = TRUE AND RecordType.Name = :system.label.DH_PersonAccountRecordTypeName];

			if (patientRec.size() > 0) {
				isOptedOutMarketingCloud = true;
				List<Id> patientIdsList = new List<Id>();
				patientIdsList.add(patientAcc.Id);
			//	DH_SendCallCenterDataSheetDatatoSFMC.sendOptInData(patientIdsList);
			}
		}
		return patientAcc.Id;
	}
	public void patientLanguageProcessor(Id patientId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();
		String languageCode = wrapper.patient.data.primary_language_code;

		PersonLanguage pl = new PersonLanguage();
		List<String> personLanguageKeys = new List<String>();
		String personLanguageKey;

		personLanguageKey = utilityInstance.fourKeysUnique(wrapper.patient.system_id, wrapper.patient.data.patient_Key, wrapper.patient.data.primary_language_code, System.label.DH_PersonLanguageRecordTypeName);
		personLanguageKeys.add(personLanguageKey);
		pl.IndividualId = patientId;
		pl.Language = languageCode;
		pl.Rank = 1;
		pl.WritingProficiencyLevel = System.Label.DH_WritingProficiencyLevel;
		pl.SpeakingProficiencyLevel = System.Label.DH_SpeakingProficiencyLevel;
		pl.DH_RIS_Instance__c = wrapper.patient.system_id;
		pl.RIS_LanguageCode__c = personLanguageKey;

		if (pl != null) {
			upsert pl RIS_LanguageCode__c;
		}

		List<PersonLanguage> deletePatientLanguage = [SELECT Id, Language FROM PersonLanguage WHERE IndividualId = :patientId AND Language != :languageCode AND RIS_LanguageCode__c NOT IN :personLanguageKeys];

		if (deletePatientLanguage.size() > 0) {
			delete deletePatientLanguage;
		}
	}
	public void patientPhoneProcessor(Id patientId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();

		List<String> phoneKeys = new List<String>();
		List<ContactPointPhone> phoneListToUpsert = new List<ContactPointPhone>();

		for (DH_PatientInfoWrapper.PatientPhones phone : wrapper.patient.data.patientPhones) {
			String phoneRisKey = utilityInstance.uniqueIdentifier(wrapper.patient.system_id, phone.patient_phone_key, System.label.DH_ContactPointPhoneRecordTypeName);
			phoneKeys.add(phoneRisKey);

			ContactPointPhone cp = new ContactPointPhone();
			cp.ParentId = patientId;
			cp.DH_Patient_Phone_Key__c = Phone.patient_phone_key;
			cp.TelephoneNumber = Phone.Phone_Number;
			cp.DH_Mobile_Flag__c = Phone.mobile_flag != null && Phone.mobile_flag == 'Y' ? true : false;
			cp.DH_RIS_PhoneKey__c = phoneRisKey;
			cp.IsPrimary = Phone.primary_flag != null && Phone.primary_flag == 'Y' ? true : false;
			cp.PreferenceRank = Integer.valueOf(Phone.display_order);
			cp.DH_Description__c = Phone.Description != null ? Phone.Description : null;
			cp.IsPersonalPhone = phone.master_mobile_flag != null && phone.master_mobile_flag == 'Y' ? true : false;
			phoneListToUpsert.add(cp);
		}
		if (phoneListToUpsert.size() > 0) {
			upsert phoneListToUpsert DH_RIS_PhoneKey__c;
		}
		List<ContactPointPhone> recordToDelete = [SELECT Id FROM ContactPointPhone WHERE ParentId = :patientId AND DH_RIS_PhoneKey__c NOT IN :phoneKeys];
		if (recordToDelete.size() > 0) {
			delete recordToDelete;
		}
	}
	public void patientEmailProcessor(Id patientId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();

		List<String> emailsKeys = new List<String>();
		List<ContactPointEmail> emailsListToUpsert = new List<ContactPointEmail>();

		for (DH_PatientInfoWrapper.PatientEmailAddresses email : wrapper.patient.data.patientEmailAddresses) {
			//Process only if the Email Address is Valid
			if (isValidEmail(email.email_address)) {
				String risEmailkey = utilityInstance.uniqueIdentifier(wrapper.patient.system_id, email.patient_email_key, System.label.DH_ContactPointEmailRecordTypeName);
				emailsKeys.add(risEmailkey);

				ContactPointEmail cpe = new ContactPointEmail();
				cpe.ParentId = patientId;
				cpe.DH_RIS_EmailKey__c = risEmailkey;
				cpe.DH_Email_Key__c = email.Patient_Email_Key;
				cpe.EmailAddress = email.Email_Address;
				cpe.IsPrimary = email.Primary_Flag != null && email.Primary_Flag == 'Y' ? true : false;
				cpe.PreferenceRank = Integer.valueOf(email.display_order);
				emailsListToUpsert.add(cpe);
			} else {
				System.debug('invalid Emails Skipped--' + email.email_address);
			}
		}
		// upsert the Email Records
		if (emailsListToUpsert.size() > 0) {
			upsert emailsListToUpsert DH_RIS_EmailKey__c;
		}
		List<ContactPointEmail> emailrecordToDelete = [SELECT Id FROM ContactPointEmail WHERE ParentId = :patientId AND DH_RIS_EmailKey__c NOT IN :emailsKeys];

		if (emailrecordToDelete.size() > 0) {
			delete emailrecordToDelete;
		}
	}
	public void patientExtraInfoProcessor(Id patientId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();

		List<String> extraInfokeys = new List<String>();
		List<DH_Patient_Extra_Info__c> recordsToUpsert = new List<DH_Patient_Extra_Info__c>();

		for (DH_PatientInfoWrapper.PatientExtraInfo info : wrapper.patient.data.patientExtraInfo) {
			String extraInfoRisKey = utilityInstance.uniqueIdentifier(wrapper.patient.system_id, info.patient_extra_info_key, system.label.DH_PatientExtraInfoRecordTypeName);
			extraInfokeys.add(extraInfoRisKey);

			DH_Patient_Extra_Info__c ex = new DH_Patient_Extra_Info__c();
			ex.Name = wrapper.patient.System_id + '_' + Info.patient_extra_info_key + '_' + Info.patient_extra_info_code;
			ex.DH_Patient__c = patientId;
			ex.DH_Patient_Extra_Info_Key__c = Info.patient_extra_info_key;
			ex.DH_PE_Code__c = Info.patient_extra_info_code;
			ex.DH_RIS_PE_Patient_Info__c = extraInfoRisKey;
			ex.DH_Value__c = info.value;
			recordsToUpsert.add(ex);
		}

		if (recordsToUpsert.size() > 0) {
			upsert recordsToUpsert DH_RIS_PE_Patient_Info__c;
		}
		List<DH_Patient_Extra_Info__c> extraInfoListToDelete = [SELECT Id FROM DH_Patient_Extra_Info__c WHERE DH_Patient__c = :patientId AND DH_RIS_PE_Patient_Info__c NOT IN :extraInfoKeys];
		if (extraInfoListToDelete.size() > 0) {
			delete extraInfoListToDelete;
		}
	}
	public void patientAlertProcessor(Id patientId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();
		//query codeset record
		CodeSetBundle code = [SELECT Id FROM CodeSetBundle WHERE Name = :System.label.DH_CodeSetBundleRecordName LIMIT 1];
		List<String> patientAlertKeys = new List<String>();
		List<ClinicalAlert> clinicalAlertListToInsert = new List<ClinicalAlert>();

		for (DH_PatientInfoWrapper.PatientAlerts alert : wrapper.patient.data.patientAlerts) {
			String patientAlertKey = utilityInstance.fourKeysUnique(wrapper.patient.system_id, wrapper.patient.data.patient_Key, alert.patient_flag_code, System.label.DH_PatientAlertRecordTypeName);
			patientAlertKeys.add(patientAlertKey);

			ClinicalAlert cli = new ClinicalAlert();
			cli.SubjectId = patientId;
			cli.Status = System.label.cli_status;
			cli.CodeId = code != null ? code.Id : null;
			cli.DH_Patient_Flag_Code__c = alert.patient_flag_code;
			cli.DH_RIS_PFlag_RecType_PKey__c = patientAlertKey;
			cli.RecordTypeId = Schema.SObjectType.ClinicalAlert.getRecordTypeInfosByName().get(System.label.DH_PatientAlertRecordTypeName).getRecordTypeId();
			clinicalAlertListToInsert.add(cli);
		}
		if (clinicalAlertListToInsert.size() > 0) {
			upsert clinicalAlertListToInsert DH_RIS_PFlag_RecType_PKey__c;
		}
		List<ClinicalAlert> clinicalAlertRecordsToDelete = [SELECT Id FROM ClinicalAlert WHERE RecordType.Name = :System.label.DH_PatientAlertRecordTypeName AND SubjectId = :patientId AND DH_RIS_PFlag_RecType_PKey__c NOT IN :patientAlertKeys];
		if (clinicalAlertRecordsToDelete.size() > 0) {
			delete clinicalAlertRecordsToDelete;
		}
	}
	private Boolean isValidEmail(String emailAddress) {
		if (emailAddress == null) {
			return false;
		}
		String emailRegex = '^[A-Za-z0-9._%+-]+@[A-Za-z-]+\\.[A-Za-z]{2,6}$';
		Pattern emailPattern = Pattern.compile(emailRegex);
		Matcher emailMatcher = emailPattern.matcher(emailAddress);
		return emailMatcher.matches();
	}
	public List<Account> modifiedPatient(String uniqueRIS) {
		List<Account> existingPatient;
		if (uniqueRIS != null) {
			Id patientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.DH_PersonAccountRecordTypeName).getRecordTypeId();
			return existingPatient = [SELECT Id, PersonHasOptedOutOfEmail, DH_HasOptedOutEmail__c, DH_HasOptedOutSMS__c, DH_HasOptedOut__c FROM Account WHERE DH_RIS_Unique_Code__c = :uniqueRIS AND RecordTypeId = :patientRecordTypeId LIMIT 1];
		}
		if (!existingPatient.isEmpty()) {
			return existingPatient;
		} else {
			return null;
		}
	}
}