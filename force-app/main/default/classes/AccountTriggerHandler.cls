public with sharing class AccountTriggerHandler extends TriggerHandler{
	private Account[] newAccounts;
	private Account[] oldAccounts;
	private Map<Id, Account> oldAccountsMap;
	private Map<Id, Account> newAccountsMap;

	protected override void populateTriggerData(
		List<SObject> oldSObjectsList,
		List<SObject> newSObjectsList,
		Map<Id, SObject> oldSObjectsMap,
		Map<Id, SObject> newSObjectsMap
	) {
		this.newAccounts = (Account[]) newSObjectsList;
		this.oldAccounts = (Account[]) oldSObjectsList;
		this.newAccountsMap = (Map<Id, Account >) newSObjectsMap;
		this.oldAccountsMap = (Map<Id, Account >) oldSObjectsMap;
	}

	protected override void onAfterInsert() {
		//AccountService.syncManualSharingAccount(newAccounts, null);
	}

	protected override void onAfterUpdate() {
		AccountService.syncManualSharingAccount(newAccounts, oldAccountsMap);
	}
}