public class DH_MessagingSessionTriggerHelper {
    public static Map<Id, MessagingSession> MessagingSessionMap;
     /**
	* @Jira 
    * @description - This method will update the previous verified patient as null 
    * @param       - None
    * @return      - List<String>
	**/
 @AuraEnabled
    public static void validatePreviousVerifiedChat(Id MessagingSessionId){
       MessagingSession Mc = [Select Id,EndUserAccountId,caseid,MessagingEndUserId from MessagingSession where id=:MessagingSessionId];
        MessagingEndUser meu = [
            SELECT Id, AccountId
            FROM MessagingEndUser
            WHERE Id = :mc.MessagingEndUserId
            LIMIT 1
        ];
        if(MEU!=null){
            MEU.AccountId=null;
            update MEU;
        }
}
    /**
	* @description - This method returns the Id previously selected record by a scheduler.
	* @param       - String
	* @return      - Account
	*/
    @AuraEnabled
    public static Account getPreviousVerifiedPatient(String recordId) {
        String idOfPreviousCall;
        String idOfVerifiedPatient;
        Set<Id> MSIdSet = new Set<Id>();
        Account verifiedPatient;
        MSIdSet.add(recordId);
        try {
            Map<Id, MessagingSession> MSMap = DH_MessagingSessionTriggerHelper.getMessMap(MSIdSet);
            MessagingSession vc = MSMap.get(recordId);
            idOfVerifiedPatient= vc.EndUserAccountId;
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
    * @description - This method will return a map of MessagingSession whose Id is in the given MessagingSessionids..
    * @param       - Set<Id>
    * @return      - Map<Id,User>
    **/
    public static Map<Id, MessagingSession> getMessMap(Set<Id> MSIds) {
		try {
			if (MessagingSessionMap == null) {
				MessagingSessionMap = new Map<Id, MessagingSession>();
			}
			if (MSIds == null || MSIds.size() == 0) {
				return MessagingSessionMap;
			}
			List<Id> MSList = new List<Id>();
			for (Id idVal : MSIds) {
				if (MessagingSessionMap.containsKey(idVal)) {
					continue;
				}
				MSList.add(idVal);
			}
			List<MessagingSession> newMSList = new List<MessagingSession>();
			if (MSList.size() > 0) {
				newMSList = DH_MessagingSessionTriggerHelper.getMSList(MSList);
			}
			if (newMSList != null && newMSList.size() > 0) {
				updateMSMap(newMSList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return MessagingSessionMap;
	}
    /**
	 * @description - This method will return a list of Messasing Session  records for passed MS  ids.
	 * @param       - Set<String>
	 * @return      - List<sObject>
	 **/
    public static List<MessagingSession> getMSList(List<Id> vcIds) {
		List<MessagingSession> vcList = new List<MessagingSession>();
		try {
			vcList = [SELECT Id,EndUserAccountId,System_Id__c,LastName__c,First_Name__c,Region__c
				FROM MessagingSession
				WHERE Id IN :vcIds
				
			];
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return vcList;
	}
    	/**
	 * @Jira CC-526
	 * @description - This method will update the MessagingSession with the new  MessagingSession data.
	 * @param       - List<Group>
	 * @return      - None
	 **/
    public static void updateMSMap(List<MessagingSession> newMSDList) {
		for (MessagingSession vcRec : newMSDList) {
			if (!MessagingSessionMap.containsKey(vcRec.Id)) {
				MessagingSessionMap.put(vcRec.Id, vcRec);
			}
		}
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
		MessagingSession MSRecord = new MessagingSession();
		if (recordId != null) {
			MSRecord = getMSRecord(recordId);
			pat =createNewPatientServicePatient(MSRecord);
		}
		return pat;
	}
    @AuraEnabled
	public static MessagingSession getMSRecord(String recordId) {
		MessagingSession callRecord = new MessagingSession();
		if (recordId != null && Schema.sObjectType.MessagingSession.isAccessible()) {
			callRecord = (DH_MessagingSessionTriggerHelper.getMessMap(new Set<id>{ id.valueOf(recordId) })).get(recordId);
		}
		return callRecord;
	}
    @AuraEnabled
	public static Account createNewPatientServicePatient(MessagingSession vc) {
		Account pat = new Account();
		try {
			pat.lastName = vc.LastName__c;
			pat.firstName = ' ' + vc.First_Name__c;
			pat.DH_Status__c = DH_GlobalConstants.PERSON_ACCOUNT_STATUS;
			pat.Region__c = vc.Region__c;
			pat.recordTypeId = DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
			if (pat != null){
				insert pat;
			}
			return pat;
		} catch (Exception e) {
			System.debug(LoggingLevel.DEBUG + e.getStackTraceString());
			return null;
		}
	}
   
}