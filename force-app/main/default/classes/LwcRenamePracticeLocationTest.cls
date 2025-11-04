@isTest
public without sharing class LwcRenamePracticeLocationTest {
	public static final Id PRACTICE_LOCATION = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Location').getRecordTypeId();
	public static final Id PHYSICIANS = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physicians').getRecordTypeId();
	public static final Id PRACTICE_OVERVIEW = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Practice_Overview').getRecordTypeId();

	@testSetup
	static void setup() {
		User currentUser = new User(Id = UserInfo.getUserId(), RIS_Data_Manager__c = true);
		update currentUser;

		System.runAs(currentUser) {
			Account practiceOverview1 = new Account(
				Name = 'TEST MEDICAL CENTER',
				ShippingCity = 'New York',
				ShippingStreet = '645 10th Avenue',
				ShippingState = 'NY',
				ShippingPostalCode = '10036',
				RecordTypeId = PRACTICE_OVERVIEW
			);
			Account practiceOverview2 = new Account(
				Name = 'TEST MEDICAL CENTER',
				ShippingCity = 'New York',
				ShippingStreet = '645 10th Avenue',
				ShippingState = 'NY',
				ShippingPostalCode = '10036',
				RecordTypeId = PRACTICE_OVERVIEW
			);
			Account practiceOverview3 = new Account(
				Name = 'TEST MEDICAL',
				RecordTypeId = PRACTICE_OVERVIEW
			);

			insert new List <Account> {
				practiceOverview1,
				practiceOverview2,
				practiceOverview3
			};

			Account practice1 = new Account(
				Name = 'TestAcc',
				Practice_Overview__c = practiceOverview1.Id,
				ShippingCity = 'New York',
				ShippingStreet = '40 PINEHURST AVENUE SUITE 1B',
				ShippingState = 'NY',
				ShippingPostalCode = '10033',
				Latitude__c = '40.84971',
				Longitude__c ='73.88',
				RIS_Server__c='NE',
				RecordTypeId = PRACTICE_LOCATION
			);
			Account practice2 = new Account(
				Name = 'TestAcc2',
				Practice_Overview__c = practiceOverview1.Id,
				ShippingCity = 'New York',
				ShippingStreet = '40 PINEHURST AVENUE SUITE 1B',
				ShippingState = 'NY',
				ShippingPostalCode = '10036',
				Latitude__c = '40.84971',
				Longitude__c ='73.88',
				RecordTypeId = PRACTICE_LOCATION
			);
			Account practice3 = new Account(
				Name = 'TestAcc3',
				Practice_Overview__c = practiceOverview1.Id,
				Latitude__c = '40.94971',
				Longitude__c ='73.98',
				RecordTypeId = PRACTICE_LOCATION
			);
	
			insert new List <Account> {
				practice1,
				practice2,
				practice3
			};
	
			Contact contactPracticeDirect = new Contact(
				AccountId = practice1.Id,
				LastName = 'TestCont',
				RecordTypeId = PHYSICIANS
			);
			Contact contactPracticeDirect2 = new Contact(
				AccountId = practice2.Id,
				LastName = 'TestSecCont1',
				RecordTypeId = PHYSICIANS
			);
			Contact contactPractice2 = new Contact(
				AccountId = practice2.Id,
				LastName = 'TestSecCont2',
				RecordTypeId = PHYSICIANS
			);
			Contact contactPractice3 = new Contact(
				AccountId = practice3.Id,
				LastName = 'TestSecCont3',
				RecordTypeId = PHYSICIANS
			);
			Contact contactPractice4 = new Contact(
				AccountId = practice3.Id,
				LastName = 'TestSecCont4',
				RecordTypeId = PHYSICIANS
			);
	
			Contact contactPractice5 = new Contact(
				AccountId = practice3.Id,
				LastName = 'TestSecCont5',
				RecordTypeId = PHYSICIANS
			);
	
			insert new List <Contact> {
				contactPracticeDirect,
				contactPracticeDirect2,
				contactPractice2,
				contactPractice3,
				contactPractice4,
				contactPractice5
			};
	
			AccountContactRelation acr1 = new AccountContactRelation(
				AccountId = practice2.Id,
				ContactId = contactPractice3.Id
			);
			insert acr1;
	
			AccountContactRelation acr2 = new AccountContactRelation(
				AccountId = practice2.Id,
				ContactId = contactPractice4.Id,
				Email_Reports__c = true,
				Mail_Reports__c = false
			);
			insert acr2;
	
			AccountContactRelation acr3 = new AccountContactRelation(
				AccountId = practice1.Id,
				ContactId = contactPractice4.Id,
				Email_Reports__c = true
			);
			insert acr3;
	
			AccountContactRelation acr4 = new AccountContactRelation(
				AccountId = practice3.Id,
				ContactId = contactPractice2.Id,
				Email_Reports__c = true
			);
			insert acr4;	

			RIS_Requests__c newRisRequestRename = new RIS_Requests__c (
				Status__c = 'New',
				Account_Name__c= practice3.Id,
				Type__c = 'Renaming an Account',
				Subject__c =' Renaming an Account'
			);
			insert newRisRequestRename;		
			
			RIS_Requests__c newRisRequestMerge = new RIS_Requests__c (
				Status__c = 'New',
				Account_Name__c= practice3.Id,
				Subject__c = 'Merge Request', 
				Type__c= 'Merge Request'
			);
			insert newRisRequestMerge;
		}
	}

	@IsTest
	private static void getRelatedPracticeOverview() {
		User currentUser = new User(Id = UserInfo.getUserId(), RIS_Data_Manager__c = false);
		update currentUser;
		test.startTest();
		System.runAs(currentUser) {
			Set<String> accountIds = new Map<String,Account>([SELECT Id FROM Account WHERE RecordTypeId = :PRACTICE_LOCATION LIMIT 3]).keySet();
			List<LwcRenamePracticeLocationController.ResultWrapper> getPracticeLocation = LwcRenamePracticeLocationController.fetchPracticeOverviewAccounts(searchWrap());
			List<Account> relatedLocations  = LwcRenamePracticeLocationController.searchPracticeLocations( searchPracticeLocations());
			List<RIS_Requests__c> relatedMergeRequests = LwcRenamePracticeLocationController.getRelatedRisRequests(new List<String>(accountIds), 'Merge Request');
			List<RIS_Requests__c> relatedRenameRequests = LwcRenamePracticeLocationController.getRelatedRisRequests(new List<String>(accountIds), 'Renaming an Account');
		}
		test.stopTest();
	}

	public static LwcRenamePracticeLocationController.SearchWrapper searchWrap() {
		Account pageAccount = [SELECT Id FROM Account WHERE Name = 'TestAcc2' LIMIT 1]; 
		LwcRenamePracticeLocationController.SearchWrapper pf = new LwcRenamePracticeLocationController.SearchWrapper();	
		pf.objectApiName =  'Account';
		pf.fieldApiName = 'Name';
		pf.searchString = 'test';
		pf.selectedRecordId = pageAccount.Id;
		return pf;
	}
	
	public static LwcRenamePracticeLocationController.SearchPracticeLocations searchPracticeLocations() {
		Account pageAccount = [SELECT Id FROM Account WHERE RecordTypeId = :PRACTICE_OVERVIEW LIMIT 1]; 
		LwcRenamePracticeLocationController.SearchPracticeLocations prLoc = new LwcRenamePracticeLocationController.SearchPracticeLocations();	
		prLoc.matchingLongitude = 'Name';
		prLoc.matchingLatitude = 'test';
		prLoc.selectedPracticeOverviewId = pageAccount.Id;
		return prLoc;
	}
	
}