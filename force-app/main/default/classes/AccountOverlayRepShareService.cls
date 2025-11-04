public without sharing class AccountOverlayRepShareService implements ShareServiceInterface{
	public void share(Set<Id> accountsIdToShare) {
		List<AccountTeamMember> accountRecordsToOverlayReps = new List<AccountTeamMember>();
		List<AccountTeamMember> existingAccountShares = [
			SELECT  Id, 
					AccountId, 
					UserId, 
					AccountAccessLevel, 
					ContactAccessLevel, 
					OpportunityAccessLevel,
					TeamMemberRole 
			FROM	AccountTeamMember 
			WHERE   AccountId IN : accountsIdToShare 
			AND	 TeamMemberRole = 'Overlap Rep'
		];
		List<Account> accountToShareList = [SELECT Id, Overlay_Reps__c FROM Account WHERE Id IN :accountsIdToShare];
		for (Account account : accountToShareList) {
			if (account.Overlay_Reps__c != null) {
				accountRecordsToOverlayReps.add(
					new AccountTeamMember(
						AccountId = account.Id,
						UserId = account.Overlay_Reps__c,
						AccountAccessLevel = 'Edit',
						OpportunityAccessLevel = 'Edit',
						ContactAccessLevel = 'Edit',
						TeamMemberRole = 'Overlap Rep'
					)
				);
			}
		}
		delete existingAccountShares;
		insert accountRecordsToOverlayReps;
	}


}