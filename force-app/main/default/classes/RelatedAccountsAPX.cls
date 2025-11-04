public with sharing class RelatedAccountsAPX {
	
	@AuraEnabled
	public static String mergeAcrs(List<String> accountIds, String noteMerge) {
		String stringDuplicate = String.join((Iterable<String>)accountIds, '-');
		List<Account> mergedAccounts = [SELECT Id, Name, Duplicate__c, NotesFromMerge__c, RecordType.DeveloperName FROM Account WHERE Id IN :accountIds];
		for(Account account : mergedAccounts) {
			account.Duplicate__c = stringDuplicate;
			account.NotesFromMerge__c = noteMerge;
			account.Merge_Owner__c = UserInfo.getUserId();
		}
		try {
			update mergedAccounts;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return 'success';
	}
	
	@AuraEnabled
	public static List<DuplicateRecordItem>  getDuplicateRecordsAfterMerged(List<String> recordIds) {
		List<DuplicateRecordItem> getDuplicateRecordItem = new List<DuplicateRecordItem>();
		getDuplicateRecordItem = [
			SELECT  Id, 
					DuplicateRecordSetId,
					RecordId 
			FROM	DuplicateRecordItem
			WHERE   RecordId IN :recordIds
		];
		return getDuplicateRecordItem;
	}
	
	@AuraEnabled
	public static List<Account> getAccountsForUpdate(List<String> accounIds) {
		return [SELECT Id, Name, Phone, Fax, Duplicate__c, NotesFromMerge__c, ShippingAddress, OwnerId, Owner.Name, RecordType.DeveloperName FROM Account WHERE Id IN :accounIds];
	}

	@AuraEnabled
	public static List<AccountContactRelation> removeAccountRelation(List<String> accountRelations, String recordId) {
		List<AccountContactRelation> conObjItem = new List<AccountContactRelation>();
		List<AccountContactRelation> conObjList = [SELECT Id FROM AccountContactRelation WHERE Id IN :accountRelations];
		for(AccountContactRelation con : conObjList) {
			conObjItem.add(con);
		}
		if(conObjItem.size()>0){
			try {
				delete conObjItem;
			}
			catch (Exception exp) {
				throw new AuraHandledException(exp.getMessage());
			}
		}
		return getAccounts(recordId);
	}

	@AuraEnabled
	public static List<AccountContactRelation> getAccounts(String recordId) {
		return [
			SELECT  Id, 
					AccountId, 
					Account.Name,
					Account.RecordType.DeveloperName,
					Account.BillingStreet, 
					Account.ShippingStreet,
					Account.BillingPostalCode, 
					Account.ShippingPostalCode,
					Account.Duplicate__c,
					ContactId, 
					Contact.Name, 
					Phone__c,
					FAX__c,
					Roles, 
					IsDirect, 
					IsActive, 
					Contact_Email__c, 
					Email_Reports__c,
					Fax_Reports__c,
					External_ID__c,					  
					Image_Preference_Notes__c,
					Preferred_Reader__c
			FROM	AccountContactRelation 
			WHERE   ContactId = :recordId
			AND	 IsDirect = false
		];
	}

	@AuraEnabled
	public static List<Group> getRISRequestGrpAPX(string groupName){
		List<Group> listGroups = new List<Group>();
		if(groupName!=null && groupName!=''){
			listGroups = [SELECT Id, Name, Type, DeveloperName 
			FROM Group 
			WHERE DeveloperName =:groupName
			AND Type = 'Queue'
			];
		}
		return listGroups;
	}

	@AuraEnabled
	public static List<Account> getLocationAccountsAPX(List<String> listAccLocationIds) {
		List<Account> listAccountLocations = new List<Account>();
		if(listAccLocationIds !=null && !listAccLocationIds.isEmpty()) {
			listAccountLocations = [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode
			FROM Account 
			WHERE Id IN:listAccLocationIds
			];
		}
		return listAccountLocations;
	}

	@AuraEnabled
	public static string insertLocationRISReqAPX(List<RIS_Requests__c> listLocRisRequestsToInsert) {
		if(listLocRisRequestsToInsert !=null && !listLocRisRequestsToInsert.isEmpty()) {
			List<Database.SaveResult> listSaveResRecs = Database.insert(listLocRisRequestsToInsert);
			return JSON.serialize(listSaveResRecs);
		}
		return null;
	}

	@AuraEnabled
	public static List<RIS_Requests__c> getInsertedLocationRISReqsAPX(List<String> listLocationRISReqSuccessIds) {
		List<RIS_Requests__c> listLocationRISReqs = new List<RIS_Requests__c>();
		if(listLocationRISReqSuccessIds !=null && !listLocationRISReqSuccessIds.isEmpty()) {
			listLocationRISReqs = [SELECT Id, Account_Name__c
			FROM RIS_Requests__c
			WHERE Account_Name__c !=null
			AND Id IN:listLocationRISReqSuccessIds
			];
		}
		return listLocationRISReqs;
	}

	@AuraEnabled
	public static string insertRelatedRISRequestsAPX(List<Related_Request__c> listRelatedRISReqsToInsert) {
		if(listRelatedRISReqsToInsert !=null && !listRelatedRISReqsToInsert.isEmpty()) {
			List<Database.SaveResult> listSaveResRecs = Database.insert(listRelatedRISReqsToInsert);
			return JSON.serialize(listSaveResRecs);
		}
		return null;
	}
}