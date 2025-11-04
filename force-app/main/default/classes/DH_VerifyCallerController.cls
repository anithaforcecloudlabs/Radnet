/*
* ***************************************************************************************************************************
* Apex Class Name - DH_VerifyCallerController
* Version - 0.1
* Created Date - 22-May-2024
* @description       : Controller class for dH_VerifyCaller
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-425                   22-May-2024          Added getVoiceCallRecord and getDynamicTableColumnsRecords method.
* CC-426                   27-May-2024          Added getUserFederationId and getPatientSearchedData method.
* CC-428                   29-May-2024          Added mapVoiceCallToPersonAccount method.
* CC-572,CC-481,CC-590     12-Aug-2024          Added createPlaceHolderAccountWithCase,invokeNewPatientService,createNewPatient method and Updated  getVoiceCallRecord & getPatientSearchedData
* CC-692                   02-Sep-2024          Added getPreviousVerifiedPatient method.
* CC-590				   04-Sep-2024			Updated	getExpiryTimeForApi method.	
* CC-716                   30-Aug-2024         Removed getPatientSearchedData and getUserFederationId methods	  
* ************************************************************************************************************************************
*/
public class DH_VerifyCallerController {
	/**
	* @Jira CC-425
	* @description - This method returns the record created for the current call with all its data.
	* @param       - String
	* @return      - VoiceCall
	**/
	@AuraEnabled
	public static VoiceCall getVoiceCallRecord(String recordId) {
		VoiceCall callRecord = new VoiceCall();
		if (recordId != null && Schema.sObjectType.VoiceCall.isAccessible()) {
			callRecord = (DH_ContactCenterCachingUtility.getVcMap(new Set<id>{ id.valueOf(recordId) })).get(recordId);
		}
		return callRecord;
	}
	/**
	* @Jira CC-692
	* @description - This method returns the Id previously selected record by a scheduler.
	* @param       - String
	* @return      - Account
	**/
	@AuraEnabled
    public static Account getPreviousVerifiedPatient(String recordId) {
        String idOfPreviousCall;
        String idOfVerifiedPatient;
        Set<Id> voiceCallIdSet = new Set<Id>();
        Account verifiedPatient;
        voiceCallIdSet.add(recordId);
        try {
            Map<Id, Voicecall> voiceCallMap = DH_ContactCenterCachingUtility.getVcMap(voiceCallIdSet);
            VoiceCall vc = voiceCallMap.get(recordId);
            idOfVerifiedPatient= vc.RelatedRecordId;
            if(idOfVerifiedPatient!=null){
                idOfVerifiedPatient=String.valueof((Id.valueOf(idOfVerifiedPatient)).getSObjectType())==DH_GlobalConstants.ACCOUNT?idOfVerifiedPatient:null;
            }
            Map<Id,Account> accountMap = DH_ContactCenterCachingUtility.getAccountsMap(new set<Id>{idOfVerifiedPatient});
            List<Account> verifiedPersonAccounts = accountMap.values();
			if(verifiedPersonAccounts.size()!=0){
				verifiedPatient= verifiedPersonAccounts[0];
			}
        } catch (Exception e) {
            System.debug('Error' + e.getMessage() + e.getLineNumber());
        }
        return verifiedPatient;
    }
	/**
	* @Jira CC-425
	* @description - This method returns the MetaData list which contains dynamic columns.
	* @param       - None
	* @return      - List<DH_DynamicTableColumns__mdt>
	**/
	@AuraEnabled
	public static List<DH_DynamicTableColumns__mdt> getDynamicTableColumnsRecords() {
		List<DH_DynamicTableColumns__mdt> columnList = DH_CustomMetadataDao.getDynamicTableColumnList(DH_GlobalConstants.DH_VERIFY_CALLER_CLASS);
		return columnList;
	}
	/**
	* @description - mapVoiceCallToPersonAccount method is used to associate voice call record with related patient record.
	* @param       - String,String
	* @return      - void
	**/
	@AuraEnabled
	public static void mapVoiceCallToPersonAccount(String VoiceCallId, String AccountId) {
		try {
			VoiceCall vcRec = new VoiceCall();
			vcRec.id = VoiceCallId;
			vcRec.RelatedRecordId = AccountId;
			if (vcRec != null && Schema.sObjectType.VoiceCall.isUpdateable()) {
				update vcRec;
			}
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
	}
	/**
	* @Jira CC-430
	* @description - This method returns the DH_DynamicTableColumns__mdt custom metadata list which contains dynamic columns.
	* @param       - None
	* @return      - List<DH_DynamicTableColumns__mdt>
	**/
	@AuraEnabled
	public static List<DH_DynamicTableColumns__mdt> getDynamicTableColumnsRecordsForSearch() {
		List<DH_DynamicTableColumns__mdt> columnList = DH_CustomMetadataDao.getDynamicTableColumnList(DH_GlobalConstants.DH_PATIENT_SEARCH_CLASS);
		return columnList;
	}
	/**
	* @Jira CC-430
	* @description - This method returns the DH_DynamicTableColumns__mdt custom metadata list which contains dynamic columns.
	* @param       - None
	* @return      - String
	**/
	@AuraEnabled
	public static String getExpiryTimeForApi() {
		DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisNewPatientServiceSetting');
        Decimal trimValue = integrationSettingMetadata.DH_TimeOutInMilliseconds__c.setScale(0);
		return String.valueOf(trimValue);
	}
	/**
	* Jira CC-572
	* @description - This method will used for the API Callout
	* @param       - String
	* @return      - DH_DexOutGeneralServiceResponse
	**/
	@AuraEnabled
	public static DH_DexOutGeneralServiceResponse invokeNewPatientService(String recordId, Account patientId) {
		
		VoiceCall vcRecord = new VoiceCall();
		if (recordId != null) {
			vcRecord = getVoiceCallRecord(recordId);
		}
		DH_DexOutServiceRisNewPatientRequest npRequest = new DH_DexOutServiceRisNewPatientRequest();
		DH_DexOutGeneralServiceResponse npResponse = new DH_DexOutGeneralServiceResponse();
		npRequest.recordId = recordId;
		npRequest.systemID = vcRecord.F9_DH_SystemId__c;
		npRequest.sfId = patientId.Id;
		
		if (npRequest != null) {
			npResponse = DH_DexOutServiceRisNewPatient.invokeCreatePatientInRisApi(npRequest);
		}
		return npResponse;
	}
	/**
	* Jira CC-572, CC-590,CC-481
	* @description - This method will Creates the Person Account when the API Service invoked
	* @param       - String
	* @return      - Id (Account Id)
	**/
	@AuraEnabled
	public static Account createNewPatient(String recordId){
		Account pat = new Account();
		VoiceCall vcRecord = new VoiceCall();
		if (recordId != null) {
			vcRecord = getVoiceCallRecord(recordId);
			pat = DH_GeneralUtility.createNewPatientServicePatient(vcRecord);
		}
		return pat;
	}
}