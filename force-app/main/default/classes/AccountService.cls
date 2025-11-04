public without sharing class AccountService {
	public static void syncManualSharingAccount(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
	Set<Id> manualShareAccountIds = new Set<Id>();
		for(Account newAccount : newAccounts) {
			Account oldAccount;
			if (oldAccountMap != null) {
				oldAccount = oldAccountMap.get(newAccount.Id);
			}
			if (newAccount.Overlay_Reps__c != null || newAccount.Overlay_Reps__c != oldAccount.Overlay_Reps__c) {
				manualShareAccountIds.add(newAccount.Id);
			}
			if (!manualShareAccountIds.isEmpty()) {
				AccountShareService.shareOverlayReps(manualShareAccountIds);
			}
		}
	}
}