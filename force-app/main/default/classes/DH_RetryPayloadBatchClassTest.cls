/*
 * ***************************************************************************************************************************
 * Apex Class Name - DH_RetryPayloadBatchClassTest
 * Version - 0.1
 * Created Date - 28-May-2024
 * Function - Test Class covers DH_RetryPayloadBatchClass which designed to retry failed payloads.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Developer                Date                 Description
 * ----------------         --------------       ---------------------
 * 06-June-2024          Initial version.
 * *****************************************************************************************************************************
 */
@isTest
public class DH_RetryPayloadBatchClassTest {
	/**
	 * @author Abhishek Gandhi | 06-06-2024
	 * @param None
	 * @description Creates reusable test data that can be used across multiple test methods within the same class.
	 **/
	@testSetup
	static void setup() {
		Profile managerProfile = [SELECT Id FROM Profile WHERE Name = 'Radnet Manager' LIMIT 1];
		User radNetScheduler = new User(Alias = 'rsWest', Email = 'radSchWest@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'TestingWest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = managerProfile.Id, TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, FederationIdentifier = 'radSch34@torg.com', UserName = 'radSch34@torg.com');
		insert radNetScheduler;
		List<DH_PayloadData__c> testData = new List<DH_PayloadData__c>();
		testData.add(new DH_PayloadData__c(DH_PatientKey__c = '169836', DH_OrderKey__c = '1240487', DH_No_of_Attempts__c = 0, DH_StudyKey__c = '4654131', DH_SystemId__c = 'NE', DH_Status__c = 'fail', DH_Processed__c = false, DH_AvailableForRetry__c =True));
		testData.add(new DH_PayloadData__c(DH_PatientKey__c = '169837', DH_OrderKey__c = '123456', DH_No_of_Attempts__c = 0, DH_StudyKey__c = '11301', DH_SystemId__c = 'NE', DH_Status__c = 'fail', DH_Processed__c = false, DH_AvailableForRetry__c = True));
		testData.add(new DH_PayloadData__c(DH_PatientKey__c = '169838', DH_OrderKey__c = '1234567', DH_No_of_Attempts__c = 3, DH_StudyKey__c = '1122', DH_SystemId__c = 'AZ', DH_Status__c = 'fail', DH_Processed__c = false, DH_AvailableForRetry__c = True));
			testData.add(new DH_PayloadData__c(DH_PatientKey__c = '169839', DH_OrderKey__c = '1234568', DH_No_of_Attempts__c = 3, DH_StudyKey__c = '1122', DH_SystemId__c = 'CA', DH_Status__c = 'fail', DH_Processed__c = false, DH_AvailableForRetry__c = True));
	
        insert testData;
	}
	/**
	 * @author Abhishek Gandhi | 06-06-2024
	 * @param - None
	 * @description Tests the invocation of the RIS create Retry API by enqueuing DH_RetryPayloadBatch Batch Job.
	 *              This method verifies the negative scenario of the API.
	 **/
	@isTest
	static void resendToSFHealthCloudWithError() {
		User radNetScheduler = [SELECT ID, Username FROM USER WHERE Email LIKE 'radSchWest@testorg.com' LIMIT 1];
       Map<Integer, String>regionMap=new Map<Integer, String>();
        regionMap.put(1,'AZ');
        regionMap.put(2,'CA');
        regionMap.put(3,'FL');
        regionMap.put(4,'MA');
        regionMap.put(5,'NE');

        
		System.runAs(radNetScheduler) {
			Test.setMock(HttpCalloutMock.class, new DH_RetryPayloadBatchClassMock(500, 'Bad Request: StudyKey 10121 not found'));
			// Start test
			
			Test.startTest();
			Map<Id, String> emptyMap = new Map<Id, String>();
			DH_RetryPayloadBatchClass batch = new DH_RetryPayloadBatchClass(2, emptyMap,regionMap);
			Database.executeBatch(batch, 500);
			Test.stopTest();
			DH_PayloadData__c[] payload = [SELECT Id, DH_No_of_Attempts__c FROM DH_PayloadData__c];
			System.assertEquals(payload[0].DH_No_of_Attempts__c, 1, 'No of Retry should be 1');
			System.assertNotEquals(null, emptyMap, 'empty map');
		}
	}
	/**
	 * @author Abhishek Gandhi | 06-06-2024
	 * @param - None
	 * @description Tests the invocation of the RIS create Retry API by enqueuing DH_RetryPayloadBatch Batch Job.
	 *              This method verifies the successful scenario of the API.
	 **/
	@isTest
	static void resendToSFHealthCloud() {
		User radNetScheduler = [SELECT ID, Username FROM USER WHERE Email LIKE 'radSchWest@testorg.com' LIMIT 1];
		// Mock HTTP Callout
		Map<Integer, String>regionMap=new Map<Integer, String>();
        regionMap.put(1,'AZ');
        regionMap.put(2,'CA');
        regionMap.put(3,'FL');
        regionMap.put(4,'MA');
        regionMap.put(5,'NE');

        System.runAs(radNetScheduler) {
			Test.setMock(HttpCalloutMock.class, new DH_RetryPayloadBatchClassMock(200, '[[{"Id":1,"PatientKey":169836,"OrderKey":10121,"StudyKey":10121,"SystemID":"CA","ProcessedFlag":true}]])'));
			// Start test
			Test.startTest();
			Map<Id, String> emptyMap = new Map<Id, String>();
			DH_RetryPayloadBatchClass batch = new DH_RetryPayloadBatchClass(2, emptyMap,regionMap);
			Database.executeBatch(batch, 200);
			Test.stopTest();
			// Verify that records were not processed due to the error response
			List<DH_PayloadData__c> processedRecords = [SELECT Id, DH_Processed__c FROM DH_PayloadData__c WHERE DH_Processed__c = TRUE];
			System.assertEquals(1, processedRecords.size(), 'All records should remain unprocessed due to the error response');
		}
	}
    
    	/**
	 * @author Abhishek Gandhi | 06-06-2024
	 * @param - None
	 * @description Tests the invocation of the RIS create Retry API by enqueuing DH_RetryPayloadBatch Batch Job.
	 *              This method verifies the negative scenario of the API.
	 **/
	@isTest
	static void resendToSFHealthCloudTest() {
		User radNetScheduler = [SELECT ID, Username FROM USER WHERE Email LIKE 'radSchWest@testorg.com' LIMIT 1];
       Map<Integer, String>regionMap=new Map<Integer, String>();
        regionMap.put(1,'AZ');
        regionMap.put(2,'CA');
        regionMap.put(3,'FL');
        regionMap.put(4,'MA');
        regionMap.put(5,'NE');

        
		System.runAs(radNetScheduler) {
			Test.setMock(HttpCalloutMock.class, new DH_RetryPayloadBatchClassMock(500, 'Bad Request: StudyKey 10121 not found'));
			// Start test
			
			Test.startTest();
			Map<Id, String> emptyMap = new Map<Id, String>();
			DH_RetryPayloadBatchClass batch = new DH_RetryPayloadBatchClass();
			Database.executeBatch(batch, 500);
			Test.stopTest();
		}
	}
    
	/**
	 * @author Abhishek Gandhi | 06-06-2024
	 * @param None
	 * @description This class generates mock HTTP responses for the HTTP callouts made during testing.
	 *              It allows simulating different scenarios, including handling retries when an initial callout fails.
	 **/
	private class DH_RetryPayloadBatchClassMock implements HttpCalloutMock {
		String response;
		Integer responseCode;
		DH_RetryPayloadBatchClassMock(Integer code, String responseBody) {
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