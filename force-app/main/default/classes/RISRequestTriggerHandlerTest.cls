@IsTest
public class RISRequestTriggerHandlerTest {
   @testSetup
	static void setupTestData() {
		Account acc1 = new Account(Name = 'Test Account 1');
		Account acc2 = new Account(Name = 'Test Account 2');
		insert new List<Account>{acc1, acc2};

		acc1.Duplicate__c = acc1.Id + '-' + acc2.Id;
		update acc1;

		RIS_Requests__c req1 = new RIS_Requests__c(
			Account_Name__c = acc1.Id, 
			Type__c = 'Merge Request', 
			Status__c = 'New'
		);

		insert req1;

		List<Account> listTestPracOverviews = TestDataFactory.returnAccounts(1, 'Practice_Overview');
		List<Database.SaveResult> listSaveResRecs = new List<Database.SaveResult>();
		listSaveResRecs = Database.insert(listTestPracOverviews);
		Set<Id> practiceOverviewIdSet = new Set<Id>();
		Set<Id> practiceLocIdSet = new Set<Id>();
		Set<Id> conIdSet = new Set<Id>();
		Set<Id> risReqIdSet = new Set<Id>();
		List<AccountContactRelation> listTestAccCons = new List<AccountContactRelation>();
		if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
			for(Database.SaveResult saveResRec : listSaveResRecs){
				if(saveResRec.isSuccess()){
					practiceOverviewIdSet.add(saveResRec.getId());
				}
			}
		}
		List<Account> listTestPracLocs = TestDataFactory.returnAccounts(2, 'Practice_Location');
		if(listTestPracLocs!=null && !listTestPracLocs.isEmpty()){
			List<Id> listPracOverviewIds  = new List<Id>(practiceOverviewIdSet);
			listTestPracLocs[0].Practice_Overview__c = listPracOverviewIds[0];
		}
		listSaveResRecs = Database.insert(listTestPracLocs);
		if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
			for(Database.SaveResult saveResRec : listSaveResRecs){
				if(saveResRec.isSuccess()){
					practiceLocIdSet.add(saveResRec.getId());
				}
			}
		}
		
		List<Contact> listTestCons = TestDataFactory.returnContacts(3, 'Physicians', practiceLocIdSet);
		listSaveResRecs = Database.insert(listTestCons);
		if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
			for(Database.SaveResult saveResRec : listSaveResRecs){
				if(saveResRec.isSuccess()){
					conIdSet.add(saveResRec.getId());
				}
			}
		}
	   
		String contactIds = String.join(conIdSet,';');
		List<RIS_Requests__c> listTestRISReqs = TestDataFactory.returnRISPAPSubmissionRequests(1, listTestPracLocs[0].Id, contactIds);
		listSaveResRecs = Database.insert(listTestRISReqs);
		if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
			for(Database.SaveResult saveResRec : listSaveResRecs){
				if(saveResRec.isSuccess()){
					risReqIdSet.add(saveResRec.getId());
				}
			}
		}

		List<RIS_Requests__c> listTestRISIPReqs = TestDataFactory.returnRISImageNotesRequests(1, conIdSet.iterator().next());
		listSaveResRecs = Database.insert(listTestRISIPReqs);
		if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
			for(Database.SaveResult saveResRec : listSaveResRecs){
				if(saveResRec.isSuccess()){
					risReqIdSet.add(saveResRec.getId());
				}
			}
		}
		
	}

	@isTest
	public static void testRemoveDuplicatesAfterMergeRejection() {
		List<Account> accountsBefore = [SELECT Id, Duplicate__c FROM Account];
		
		Test.startTest();
		
		List<RIS_Requests__c> requestsToUpdate = [SELECT Id, Account_Name__c, Type__c, Status__c FROM RIS_Requests__c WHERE Type__c = 'Merge Request' AND Status__c = 'New'];
		
		for (RIS_Requests__c req : requestsToUpdate) {
			req.Status__c = 'Rejected';
		}
		try {
			update requestsToUpdate;
		} catch (Exception ex) {
			system.debug(ex.getMessage());
		}
		Test.stopTest();
		
		List<Account> accountsAfter = [SELECT Id, Duplicate__c FROM Account WHERE Id IN :accountsBefore];
		
		for (Account acc : accountsAfter) {
			System.assertEquals(null, acc.Duplicate__c, 'Duplicate field should be cleared');
		}

		Integer countDuplicateRecordSets = [SELECT COUNT() FROM DuplicateRecordSet WHERE DuplicateRule.DeveloperName = 'Custom_Account_Matching_Rule'];
		System.assertEquals(0, countDuplicateRecordSets, 'DuplicateRecordSet should be deleted');
	}

	
	@isTest
	public static void tesClosePAPSubmission() {
		Test.startTest();
		List<RIS_Requests__c> requestsToUpdate = [SELECT Id, Account_Name__c, Type__c, Status__c FROM RIS_Requests__c WHERE Type__c = 'PAP Submission' AND Status__c = 'New'];
		for (RIS_Requests__c req : requestsToUpdate) {
			req.Status__c = 'Closed';
		}
		try {
			update requestsToUpdate;
		} catch (Exception ex) {
			system.debug(ex.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	public static void tesCloseImagePreferenceNotes() {
		Test.startTest();		
		List<RIS_Requests__c> requestsToUpdate = [SELECT Id, Account_Name__c, Type__c, Status__c FROM RIS_Requests__c WHERE Type__c = 'Image preference notes' AND Status__c = 'New'];
		for (RIS_Requests__c req : requestsToUpdate) {
			req.Status__c = 'Closed';
		}
		try {
			update requestsToUpdate;
		} catch (Exception ex) {
			system.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	
	@IsTest
	public static void testClosePrivateContact() {
		List<Contact> cons = [SELECT Id FROM Contact];
		Id conId = cons[0].Id;
		RIS_Requests__c req = new RIS_Requests__c(
			ContactId__c = conId,
			Type__c = 'Private Contact',
			Private_Ris_Server__c = 'FL',
			Status__c = 'New'
		);
		insert req;

		Test.startTest();

		req.Status__c = 'Closed';
		update req;

		Test.stopTest();
	}
}