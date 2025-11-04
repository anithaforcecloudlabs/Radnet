public with sharing class RISRequestTriggerHandler extends TriggerHandler {
	private List<RIS_Requests__c> newRISRequests;
	private List<RIS_Requests__c> oldRISRequests;
	private Map<Id, RIS_Requests__c> oldRISRequestsMap;
	private Map<Id, RIS_Requests__c> newRISRequestsMap;

	protected override void populateTriggerData(
		List<SObject> oldSObjectsList, 
		List<SObject> newSObjectsList,
		Map<Id, SObject> oldSObjectsMap, 
		Map<Id, SObject> newSObjectsMap
	) {
		this.newRISRequests = (List<RIS_Requests__c>) newSObjectsList;
		this.oldRISRequests = (List<RIS_Requests__c>) oldSObjectsList;
		this.newRISRequestsMap = (Map<Id, RIS_Requests__c >) newSObjectsMap;
		this.oldRISRequestsMap = (Map<Id, RIS_Requests__c >) oldSObjectsMap;
	}

	protected override void onAfterUpdate() {
		this.removeDuplicatesAfterMergeRejection();
		RISRequestTriggerHelper.closedPAPSubmission(this.newRISRequests, this.oldRISRequestsMap);
		RISRequestTriggerHelper.closedImagePreferenceNotes(this.newRISRequests, this.oldRISRequestsMap);
		RISRequestTriggerHelper.closedPrivateContacts(this.newRISRequests, this.oldRISRequestsMap);
	}

	private void removeDuplicatesAfterMergeRejection() {
		List<RIS_Requests__c> mergeRISRequests = new List<RIS_Requests__c>();
		List<Id> relatedAccountIds = new List<Id>();

		for (RIS_Requests__c risRequest : this.newRISRequests) {
			if (risRequest.Type__c == 'Merge Request' && (risRequest.Status__c == 'Rejected' || risRequest.Status__c == 'Closed') && risRequest.Account_Name__c != null) {
				mergeRISRequests.add(risRequest);
				relatedAccountIds.add(risRequest.Account_Name__c);
			}
		}

		if (mergeRISRequests.isEmpty()) {
			return;
		}

		List<Account> relatedAccounts = [SELECT Id, Duplicate__c FROM Account WHERE Id IN :relatedAccountIds AND Duplicate__c != NULL];

		for (Account relatedAccount : relatedAccounts) {
			relatedAccountIds.addAll(relatedAccount.Duplicate__c.split('-'));
		}

		List<Account> duplicateAccounts = [SELECT Id, Duplicate__c FROM Account WHERE Id IN :relatedAccountIds];

		for (Account duplicateAccount : duplicateAccounts) {
			duplicateAccount.Duplicate__c = null;
		}

		Set<Id> duplicateRecordSetIds = new Set<Id>();

		for (DuplicateRecordItem item : [
			SELECT  Id, DuplicateRecordSetId
			FROM	DuplicateRecordItem
			WHERE   RecordId IN :relatedAccountIds
		]) {
			duplicateRecordSetIds.add(item.DuplicateRecordSetId);
		}

		delete [SELECT Id FROM DuplicateRecordSet WHERE Id IN :duplicateRecordSetIds AND DuplicateRule.DeveloperName = 'Custom_Account_Matching_Rule'];
		update duplicateAccounts;
	}
}