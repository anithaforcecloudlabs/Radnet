@isTest
public with sharing class AccountHandlerTest {
	public static List<Account> listTestAccs;
	public static List<Contact> listTestCons;
	public static User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

	@testSetup
	static void scenario1() {
		User testUser = new User(
			FirstName = 'user',
			LastName = 'test',
			Email = 'user@test.com',
			isActive = true,
			Username = 'user@test.com' + System.currentTimeMillis(),
			Alias = 'testuser',
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep'].Id,
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US'
		);
		insert testUser;
		System.runAs(currentUser) {
			listTestAccs = TestDataFactory.returnAccounts(1, 'Practice_Location');
			List<Database.SaveResult> listTestSaveResultsAccs =  Database.insert(listTestAccs);
			Set<Id> testAccIdSet = new Set<Id>();
			if(listTestSaveResultsAccs!=null && !listTestSaveResultsAccs.isEmpty()) {
				for(Database.SaveResult saveResRec : listTestSaveResultsAccs) {
					if(saveResRec.isSuccess()){
						testAccIdSet.add(saveResRec.getId());
					}
				}
			}
		}
	}

	@isTest
	static void testOverlayAccount(){
		scenario1();
		Account getAccount = [SELECT Id, Overlay_Reps__c FROM Account LIMIT 1];
		User getTestUser = [SELECT Id FROM User WHERE Email = 'user@test.com' LIMIT 1];
		System.runAs(currentUser) {
			getAccount.Overlay_Reps__c = getTestUser.Id;
			update getAccount;
		}
	}
}