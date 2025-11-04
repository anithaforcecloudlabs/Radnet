public with sharing class AccountShareService {
	public static void shareOverlayReps(Set<Id> accountIds) {
		ShareServiceInterface shareService = ShareServiceFactory.getInstance(ApexSharingSettings.ACCOUNT_OVERLAY_REP_SHARING_TYPE);
		shareService.share(accountIds);
	}
}