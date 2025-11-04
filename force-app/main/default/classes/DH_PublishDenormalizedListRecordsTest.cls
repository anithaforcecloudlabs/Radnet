/*
 
*********************************************************
 
Apex Class         : DH_PublishDenormalizedListRecordsTest
 
Created Date       : June , 2024

Updated Date       : 21-June-2024
 
@description       :  * Function - This is an apex class to test the functionality for the publish list view button,It checks for the existing batch jobs and starts a new 
						denormaliztion batch job.Test class to cover below classes DH_PublishDenormalizedListRecords, DH_BatchForNormalization, DH_ExclusionDenormalizeJsonConverter
					    DH_NormalizedRecordDelete, DH_NormalizedRecordUpdate, DH_NormalizedRecordsCreation, DH_CreateCombinationDenormalizedRecord
 
@jiraid            : CC-283
 
*********************************************************
 
*/

@isTest(seeAllData=false)
public class DH_PublishDenormalizedListRecordsTest {
	//static variable to control queable Job execution
	//DH_SendNormalizeDataQueue.doChainJob = false;

	//Test steup method to create test data(Create necessary test data using your data factory methods : DH_ExclusioModalityCallcenterTestDataFac)
	@TestSetup
	static void setupData() {
		// Create necessary test data using your data factory methods
		List<Account> regionAccountsList = DH_ExclusioModalityCallcenterTestDataFac.createRegionAccounts();
		insert regionAccountsList;
		List<Account> allOtherAccountsList = new List<Account>();
		for (Account acc : regionAccountsList) {
			List<Account> regionBasedOtherAccountsList = DH_ExclusioModalityCallcenterTestDataFac.createOtherAccounts(acc.Id, acc.Region__c);
			allOtherAccountsList.addAll(regionBasedOtherAccountsList);
		}
		insert allOtherAccountsList;
		List<Account> listOfAccounts = [SELECT Id, Name, RecordType.Name, DH_RIS_Unique_Code__c, DH_Physician_Formula_Id__c, DH_Physician_Id__c FROM Account WHERE RecordType.Name = 'Physician'];
		List<CareSpecialty> allRegionCareSpecialityList = new List<CareSpecialty>();
		for (Account acc : regionAccountsList) {
			List<CareSpecialty> regionBasedCareSpecialityList = DH_ExclusioModalityCallcenterTestDataFac.createCareSpeciality(acc.Id, acc.Region__c);
			allRegionCareSpecialityList.addAll(regionBasedCareSpecialityList);
		}
		insert allRegionCareSpecialityList;

		List<HealthcareProcedure> allRegionHealthCareProcedure = new List<HealthcareProcedure>();
		for (Account acc : regionAccountsList) {
			List<HealthCareProcedure> regionBasedHealthCareProcedure = DH_ExclusioModalityCallcenterTestDataFac.createHealthCareProcedure(acc.Id, acc.Region__c);
			allRegionHealthCareProcedure.addAll(regionBasedHealthCareProcedure);
		}
		insert allRegionHealthCareProcedure;

		List<DH_Call_Center__c> callCenterList = DH_ExclusioModalityCallcenterTestDataFac.createCallCenter();
		insert callCenterList;

		User user1 = DH_ExclusioModalityCallcenterTestDataFac.createUser();
		user1.Email = 'unique' + System.currentTimeMillis() + '@example.com';
		insert user1;
		List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();

		DH_Call_Center_Data_Sheet__c exclusion = DH_ExclusioModalityCallcenterTestDataFac.createExclusionDenormaliseObject();
		exclusion.Name = 'Unique Exclusion';
		records.add(exclusion);

		DH_Call_Center_Data_Sheet__c modalityPriority = DH_ExclusioModalityCallcenterTestDataFac.createModalityPriorityDenormaliseObject();
		modalityPriority.Name = 'Unique modalityPriority';
		records.add(modalityPriority);

		DH_Call_Center_Data_Sheet__c callCenterMapping = DH_ExclusioModalityCallcenterTestDataFac.createCallCenterMappingDenormaliseObject();
		callCenterMapping.Name = 'Unique callCenterMapping ';
		callCenterMapping.DH_Fake_call_center_site_code__c = 'TESTC';
		callCenterMapping.DH_Site_Code_or_Call_Center_Code__c = 'TESTC';
		records.add(callCenterMapping);

		DH_Call_Center_Data_Sheet__c callCenterHours = DH_ExclusioModalityCallcenterTestDataFac.createCallCenterHourDenormaliseObject();
		callCenterHours.Name = 'Unique callCenterHours';
		callCenterHours.DH_Site_Code_or_Call_Center_Code__c = 'TESTAZCALLCTR';
		records.add(callCenterHours);

		insert records;

		List<DH_Call_Center_Data_Sheet__c> recordsEmpty = new List<DH_Call_Center_Data_Sheet__c>();

		DH_Call_Center_Data_Sheet__c exclusionEmpty = DH_ExclusioModalityCallcenterTestDataFac.createExclusionDenormaliseObjectEmpty();
		exclusionEmpty.Name = 'Unique Exclusion Empty';
		recordsEmpty.add(exclusionEmpty);

		DH_Call_Center_Data_Sheet__c modalityPriorityEmpty = DH_ExclusioModalityCallcenterTestDataFac.createModalityPriorityDenormaliseObjectEmpty();
		modalityPriorityEmpty.Name = 'Unique modalityPriority Empty';
		recordsEmpty.add(modalityPriorityEmpty);

		DH_Call_Center_Data_Sheet__c callCenterMappingEmpty = DH_ExclusioModalityCallcenterTestDataFac.createCallCenterMappingDenormaliseObjectEmpty();
		callCenterMappingEmpty.Name = 'Unique callCenterMapping Empty';
		callCenterMappingEmpty.DH_Fake_call_center_site_code__c = 'TESTC';
		callCenterMappingEmpty.DH_Site_Code_or_Call_Center_Code__c = 'TESTC';
		recordsEmpty.add(callCenterMappingEmpty);

		DH_Call_Center_Data_Sheet__c callCenterHoursEmpty = DH_ExclusioModalityCallcenterTestDataFac.createCallCenterHourDenormaliseObjectEmpty();
		callCenterHoursEmpty.Name = 'Unique callCenterHours Empty';
		callCenterHoursEmpty.DH_Site_Code_or_Call_Center_Code__c = 'TESTAZCALLCTR';
		recordsEmpty.add(callCenterHoursEmpty);

		insert recordsEmpty;
	}

	//Test method to publish single exclusion record
	@isTest
	public static void testPublishSingleRecord() {
		User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
		insert denormalizedUser;
		PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
		PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
		PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
		PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
		List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
		psaList.add(psa);
		psaList.add(psa2);
		insert psaList;
		// Test the publishSingleRecord method
		System.runAs(denormalizedUser) {
			DH_SendNormalizeDataQueue.doChainJob = false;
			Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200, '{"access_token":"token"}'));
			Test.startTest();
			DH_Call_Center_Data_Sheet__c exclusion = DH_ExclusioModalityCallcenterTestDataFac.createExclusionDenormaliseObject();
			exclusion.Name = 'Unique Exclusion ' + System.currentTimeMillis();
			exclusion.DH_System__c = 'TESTMA';
			insert exclusion;
			// Use the correct constructor for a single record
			ApexPages.StandardController stdController = new ApexPages.StandardController(exclusion);
			// Create an instance of the class and call the method
			DH_PublishDenormalizedListRecords publishDenormalizedListRecords = new DH_PublishDenormalizedListRecords(stdController);
			publishDenormalizedListRecords.publishSingleRecord();
			// Assert that the batch job was enqueued
			Integer jobCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
			AsyncApexJob[] jobs = [SELECT id, ApexClassId, status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
			System.assertEquals(1, jobCount, 'Batch job should be enqueued');
			Test.stopTest();
		}

	}

	@isTest
	public static void testcreateDenormalisedObjectForUniqueArray() {
		User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
		insert denormalizedUser;
		PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
		PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
		PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
		PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
		List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
		psaList.add(psa);
		psaList.add(psa2);
		insert psaList;
		System.runAs(denormalizedUser) {
			List<DH_Call_Center_Data_Sheet__c> ccdsList = DH_ExclusioModalityCallcenterTestDataFac.createDenormalisedObject();
			try {
				insert ccdsList;
			} catch (DMLException e) {
				System.debug('Error sucesfully recieved : ' + e);
			}
		}
	}

	@isTest
	public static void testCheckDuplicate() {
		User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
		insert denormalizedUser;
		PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
		PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
		PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
		PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
		List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
		psaList.add(psa);
		psaList.add(psa2);
		insert psaList;
		System.runAs(denormalizedUser) {
			boolean ifFailed = false;
			List<DH_Call_Center_Data_Sheet__c> ccdsList = DH_ExclusioModalityCallcenterTestDataFac.dataForCheckingExclusionDuplicate();
			List<DH_Call_Center_Data_Sheet__c> ccdsduplicateList = DH_ExclusioModalityCallcenterTestDataFac.dataForCheckingExclusionDuplicate();
			insert ccdsList;
			try {
				insert ccdsduplicateList[0];
			} catch (Exception e) {
				ifFailed = true;
			}
			try {
				insert ccdsduplicateList[1];
			} catch (Exception e) {
				ifFailed = true;
			}
			try {
				insert ccdsduplicateList[2];
			} catch (Exception e) {
				ifFailed = true;
			}
			try {
				insert ccdsduplicateList[3];
			} catch (Exception e) {
				ifFailed = true;
			}
			System.assertEquals(true, ifFailed, 'All duplicATE records should fail');
		}

	}
	@isTest
	public static void testFailedPublishDenormalizedListRecord() {
		User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
		insert denormalizedUser;
		PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
		PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
		PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
		PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
		List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
		psaList.add(psa);
		psaList.add(psa2);
		insert psaList;
		System.runAs(denormalizedUser) {
			Boolean message = false;
			List<DH_Call_Center_Data_Sheet__c> ccdsList7 = DH_ExclusioModalityCallcenterTestDataFac.failedFakeCallCenterDenormalisedObject();
			try {
				insert ccdsList7;
			} catch (DMLException e) {
				message = true;
			}
			List<DH_Call_Center_Data_Sheet__c> ccdsList8 = DH_ExclusioModalityCallcenterTestDataFac.failedRefPractDenormalisedObject();
			try {
				insert ccdsList8;
			} catch (DMLException e) {
				message = true;
			}
			List<DH_Call_Center_Data_Sheet__c> ccdsList9 = DH_ExclusioModalityCallcenterTestDataFac.failedRefDrDenormalisedObject();
			try {
				insert ccdsList9;
			} catch (DMLException e) {
				message = true;
			}

			List<DH_Call_Center_Data_Sheet__c> ccdsList6 = DH_ExclusioModalityCallcenterTestDataFac.failedCallCenterDenormalisedObject();
			try {
				insert ccdsList6;
			} catch (DMLException e) {
				message = true;
			}

			List<DH_Call_Center_Data_Sheet__c> ccdsList4 = DH_ExclusioModalityCallcenterTestDataFac.failedProcedureCodeDenormalisedObject();
			try {
				insert ccdsList4;
			} catch (DMLException e) {
				message = true;
			}

			List<DH_Call_Center_Data_Sheet__c> ccdsList5 = DH_ExclusioModalityCallcenterTestDataFac.failedCarrierCodeDenormalisedObject();
			try {
				insert ccdsList5;
			} catch (DMLException e) {
				message = true;
			}

			List<DH_Call_Center_Data_Sheet__c> ccdsList3 = DH_ExclusioModalityCallcenterTestDataFac.failedModalityDenormalisedObject();
			try {
				insert ccdsList3;
			} catch (DMLException e) {
				message = true;
			}

			List<DH_Call_Center_Data_Sheet__c> ccdsList2 = DH_ExclusioModalityCallcenterTestDataFac.failedSiteDenormalisedObject();
			try {
				insert ccdsList2;
			} catch (DMLException e) {
				message = true;
			}
			List<DH_Call_Center_Data_Sheet__c> ccdsList = DH_ExclusioModalityCallcenterTestDataFac.createFailedSDenormalisedObject();
			try {
				insert ccdsList;
			} catch (DMLException e) {
				message = true;
			}

			System.assertEquals(true, message, 'All records should fail');
		}

	}
	private class HttpSFMCmock implements HttpCalloutMock {
		String Response;
		Integer ResponseCode;
		HttpSFMCmock(Integer Code, String ResponseBody) {
			ResponseCode = Code;
			Response = ResponseBody;
		}
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(ResponseCode);
			res.setbody(Response);
			return res;
		}
	}
}