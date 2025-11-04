public with sharing class ShareServiceFactory {
	public static ShareServiceInterface getInstance(String shareServiceType) {
		return (ShareServiceInterface) Type.forName(ApexSharingSettings.sharingTypeToHandler.get(shareServiceType)).newInstance();
	}
}