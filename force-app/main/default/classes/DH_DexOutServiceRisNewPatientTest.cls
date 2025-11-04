/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisNewPatientTest
* Created Date - 28-May-2024
* @description       : Test Class for DH_DexOutServiceRisNewPatient service class.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-426                   27-May-2024          Added testInvokeCreatePatientInRisApi,testInvokeCreatePatientInRisApiWithError & setup methods.
* CC-520                   09-August-2024       Updated testInvokeCreatePatientInRisApi,testInvokeCreatePatientInRisApiWithError, added MockHttpResponseGenerator
* CC-CC-572,CC-481,CC-590  27-August-2024		Updated MockHttpResponseGenerator method
* CC-1204                  13-September-2024    Added & updated testInvokeCreatePatientInRisApiSchWest/SchEast/ManEast/ManWest,testInvokeCreatePatientInRisApiWithErrorSchWest/SchEast/ManEast/ManWest,
												testInvokeCreatePatientInRisApiServiceDownSchWest/SchEast/ManEast/ManWest,testInvokeCreatePatientInRisApiWithNullSchWest/SchEast/ManEast/ManWest,Updates setup method.
* CC-426                   24-September-2024    Changes related to system.run as scope.
* CC-603                   08-Oct-2024          Added runtestInvokeCreatePatientInRisApiWithNull, runtestInvokeCreatePatientInRisApiServiceDown,runtestInvokeCreatePatientInRisApiWithError and runTestInvokeCreatePatientInRisApi and did changes related to code optimization and code coverage
* CC-1439                  30-Oct-2024			Replaced all instances of FromPhoneNumber with F9_Call_ANI__c
* CC-1518				   03-Mar-2025          PhoneNumber format change impact fix
* *****************************************************************************************************************************************
*/
@isTest
public class DH_DexOutServiceRisNewPatientTest {
	/**
	* @Jira CC-426
	* @description - Creates reusable test data that can be used across multiple test methods within the same class.
	* @param       - None
	**/
	@testSetup
	public static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
        User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
        User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
		VoiceCall voiceCallRecord1 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
		insert voiceCallRecord1;
		VoiceCall var1 = DH_TestDataFactory.assignVcOwner(voiceCallRecord1.ID, radnetSchedulerWest.ID);
		update var1;
        VoiceCall voiceCallRecord2 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
		insert voiceCallRecord2;
		VoiceCall var2 = DH_TestDataFactory.assignVcOwner(voiceCallRecord2.ID, radnetManagerWest.ID);
		update var2;
        VoiceCall voiceCallRecord3 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
		insert voiceCallRecord3;
		VoiceCall var3 = DH_TestDataFactory.assignVcOwner(voiceCallRecord3.ID, radnetSchedulerEast.ID);
		update var3;
        VoiceCall voiceCallRecord4 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
		insert voiceCallRecord4;
		VoiceCall var4 = DH_TestDataFactory.assignVcOwner(voiceCallRecord4.ID, radnetSchedulerEast.ID);
		update var4;
	}
	/**
	* @Jira CC-426
	* @description - Tests the invocation of the RIS create patient API. This method verifies the successful creation of a patient via the API.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiSchWest() {
		User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
		runTestInvokeCreatePatientInRisApi(radnetSchedulerWest);
	}
	/**
    * @Jira CC-426
    * @description - Tests the invocation of the RIS create patient API. This method verifies the successful creation of a patient via the API.
    * @param       - None
    **/
	@isTest
	public static void testInvokeCreatePatientInRisApiSchEast() {
		User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
		runTestInvokeCreatePatientInRisApi(radnetSchedulerEast);
	}
	/**
	* @Jira CC-426
	* @description - Tests the invocation of the RIS create patient API. This method verifies the successful creation of a patient via the API.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiManWest() {
		User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetManagerWest);
		runTestInvokeCreatePatientInRisApi(radnetManagerWest);
	}
	/**
	* @Jira CC-426
	* @description - Tests the invocation of the RIS create patient API. This method verifies the successful creation of a patient via the API.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiManEast() {
		User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetManagerEast);
		runTestInvokeCreatePatientInRisApi(radnetManagerEast);
	}
			/**
    * @Jira CC-426
    * @description - Tests the invocation of the RIS create patient API. This method verifies the successful creation of a patient via the API.
    * @param       - None
    **/
	public static void runTestInvokeCreatePatientInRisApi(User user) {
		HttpResponse mockResponse = DH_TestDataFactory.createMockResponse(200, '');
		HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse, 0,200);
		Test.setMock(HttpCalloutMock.class, mock);
		System.runAs(user) {
			Account testAccount = DH_TestDataFactory.createAccount('CA', 'Default', 'CA', DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
			insert testAccount;
			VoiceCall voiceCallRecord = [SELECT ID, Name, OwnerId FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3498' LIMIT 1];
			DH_DexOutServiceRisNewPatientRequest wrapper = DH_TestDataFactory.createDexOutServiceRisNewPatientRequest(voiceCallRecord.ID, 'TestUser', '3600', 'John', 'Doe', '1234567890', 'john.doe@example.com');
			DH_PayloadData__c plRecord = DH_TestDataFactory.createPayLoadRecord('DH_RisNewPatientServiceSetting', voiceCallRecord.Id, String.valueOf(wrapper));
			DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisNewPatientServiceSetting');
			DH_DexOutGeneralServiceRequest apiRequest = new DH_DexOutGeneralServiceRequest();
			apiRequest.patientId = testAccount.Id;
			apiRequest.recordId = voiceCallRecord.Id;
			apiRequest.apiSetting = integrationSettingMetadata;
			wrapper.recordId = voiceCallRecord.Id;
			wrapper.sfId = testAccount.Id;
			wrapper.systemID = 'CA';
			List<DH_DynamicTableColumns__mdt> toBeReplaced = DH_CustomMetadataDao.getDynamicTableColumnList('DH_DexOutServiceRisNewPatient');
			Test.startTest();
			DH_DexOutGeneralServiceResponse result = DH_DexOutServiceRisNewPatient.invokeCreatePatientInRisApi(wrapper);
			Test.stopTest();
			DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c, DH_ClassName__c FROM DH_PayloadData__c LIMIT 1];
			System.assertNotEquals(null, payLoad, 'test is successful');
			System.assertNotEquals(null, result.response, 'Error in creating the invokeCreatePatientInRisApi');
		}
	}
	/**
	* @Jira CC-426
	* @description - Tests the invocation of the RIS create patient API when an error occurs and retries are exhausted.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiWithErrorSchWest() {
		User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
		runtestInvokeCreatePatientInRisApiWithError(radnetSchedulerWest);
	}
	/**
	* @Jira CC-426
	* @description - Tests the invocation of the RIS create patient API when an error occurs and retries are exhausted.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiWithErrorSchEast() {
		User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
		runtestInvokeCreatePatientInRisApiWithError(radnetSchedulerEast);
	}
	/**
	* @Jira CC-426
	* @description - Tests the invocation of the RIS create patient API when an error occurs and retries are exhausted.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiWithErrorManWest() {
		User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetManagerWest);
		runtestInvokeCreatePatientInRisApiWithError(radnetManagerWest);
	}
	/**
	* @Jira CC-426
	* @description - Tests the invocation of the RIS create patient API when an error occurs and retries are exhausted.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiWithErrorManEast() {
		User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetManagerEast);
		runtestInvokeCreatePatientInRisApiWithError(radnetManagerEast);
	}
	/**
	* @Jira CC-426
	* @description - Tests the invocation of the RIS create patient API when an error occurs and retries are exhausted.
	* @param       - None
	**/
	public static void runtestInvokeCreatePatientInRisApiWithError(User user) {
		DH_DexOutServiceRisNewPatientRequest testwrapper;
		System.runAs(user) {
			VoiceCall voiceCallRecord = [SELECT ID, Name,OwnerId FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3498' LIMIT 1];
			Account testAccount = DH_TestDataFactory.createAccount('CA', 'Default', 'CA', DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
			insert testAccount;
			testwrapper = DH_TestDataFactory.createDexOutServiceRisNewPatientRequest(
				voiceCallRecord.ID, 
				'TestUserTwo', 
				'3600', 
				'John', 
				'Doe', 
				'1234567890', 
				'john.doe@example.com' 
			);
			DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisNewPatientServiceSetting');
			DH_DexOutGeneralServiceRequest apiRequest = new DH_DexOutGeneralServiceRequest();
			apiRequest.patientId = testAccount.Id;
			apiRequest.recordId = voiceCallRecord.Id;
			apiRequest.apiSetting = integrationSettingMetadata;
			testWrapper.recordId = apiRequest.recordId;
			testWrapper.sfId = apiRequest.patientId;
			testWrapper.systemID = 'CA';

			HttpResponse mockResponse = DH_TestDataFactory.createMockResponse(404, '');
			HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse, 2,404);
			Test.setMock(HttpCalloutMock.class, mock);
			{
				Test.startTest();
				DH_DexOutGeneralServiceResponse result = DH_DexOutServiceRisNewPatient.invokeCreatePatientInRisApi(testwrapper);
				Test.stopTest(); 
				DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c, DH_ClassName__c FROM DH_PayloadData__c LIMIT 1];
				System.assertNotEquals(null, payLoad, 'test is successfull');
				System.assertEquals('404', payLoad.DH_ResponseCode__c, 'Error occured in the payload data creation');
			}
        }
	}
	/**
	* @Jira CC-481,572
	* @description - Tests the invocation of the RIS create patient API. This method Test Service Down scenario
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiServiceDownSchWest() {
		User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
		runtestInvokeCreatePatientInRisApiServiceDown(radnetSchedulerWest);
	}
	/**
	* @Jira CC-481,572
	* @description - Tests the invocation of the RIS create patient API. This method Test Service Down scenario
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiServiceDownSchEast() {
		User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
		runtestInvokeCreatePatientInRisApiServiceDown(radnetSchedulerEast);
	}
	/**
	* @Jira CC-481,572
	* @description - Tests the invocation of the RIS create patient API. This method Test Service Down scenario
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiServiceDownManWest() {
		User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetManagerWest);
		runtestInvokeCreatePatientInRisApiServiceDown(radnetManagerWest);
	}
	/**
	* @Jira CC-481,572
	* @description - Tests the invocation of the RIS create patient API. This method Test Service Down scenario
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiServiceDownManEast() {
		User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetManagerEast);
		runtestInvokeCreatePatientInRisApiServiceDown(radnetManagerEast);
	}
	/**
	* @Jira CC-481,572
	* @description - Tests the invocation of the RIS create patient API. This method Test Service Down scenario
	* @param       - None
	**/
	public static void runtestInvokeCreatePatientInRisApiServiceDown(User user) {
		HttpResponse mockResponse = DH_TestDataFactory.createMockResponse(500, '');
		HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse, 0,500);
		Test.setMock(HttpCalloutMock.class, mock);
		System.runAs(user) {
			Account testAccount = DH_TestDataFactory.createAccount('CA', 'Default', 'CA', DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
			insert testAccount;
			VoiceCall voiceCallRecord = [SELECT ID, Name,OwnerId FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3498' LIMIT 1];
            DH_DexOutServiceRisNewPatientRequest wrapper = DH_TestDataFactory.createDexOutServiceRisNewPatientRequest(voiceCallRecord.ID, 'TestUser', '3600', 'John', 'Doe', '1234567890', 'john.doe@example.com');
			DH_PayloadData__c plRecord = DH_TestDataFactory.createPayLoadRecord('DH_RisNewPatientServiceSetting', voiceCallRecord.Id, String.valueOf(wrapper));
			DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisNewPatientServiceSetting');
			DH_DexOutGeneralServiceRequest apiRequest = new DH_DexOutGeneralServiceRequest();
			apiRequest.patientId = testAccount.Id;
			apiRequest.recordId = voiceCallRecord.Id;
			apiRequest.apiSetting = integrationSettingMetadata;
			wrapper.recordId = voiceCallRecord.Id;
			wrapper.sfId = testAccount.Id;
			wrapper.systemID = 'CA';
			List<DH_DynamicTableColumns__mdt> toBeReplaced = DH_CustomMetadataDao.getDynamicTableColumnList('DH_DexOutServiceRisNewPatient');
			Test.startTest();
			DH_DexOutGeneralServiceResponse result = DH_DexOutServiceRisNewPatient.invokeCreatePatientInRisApi(wrapper);
			Test.stopTest();
			DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c, DH_ClassName__c FROM DH_PayloadData__c LIMIT 1];
			System.assertNotEquals(null, payLoad, 'test is successful');
			System.assertNotEquals(null, result.response, 'Error in creating the invokeCreatePatientInRisApi');
		}
	}
    /**
	* @Jira CC-430
	* @description - Tests the invocation of the RIS create patient API. This method verifies the null value scenarios.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiWithNullSchWest() {
		User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
		runtestInvokeCreatePatientInRisApiWithNull(radnetSchedulerWest);
	}
    /**
	* @Jira CC-430
	* @description - Tests the invocation of the RIS create patient API. This method verifies the null value scenarios.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiWithNullSchEast() {
		User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
		runtestInvokeCreatePatientInRisApiWithNull(radnetSchedulerEast);
	}
    /**
	* @Jira CC-430
	* @description - Tests the invocation of the RIS create patient API. This method verifies the null value scenarios.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiWithNullManWest() {
		User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetManagerWest);
		runtestInvokeCreatePatientInRisApiWithNull(radnetManagerWest);
	}
    /**
	* @Jira CC-430
	* @description - Tests the invocation of the RIS create patient API. This method verifies the null value scenarios.
	* @param       - None
	**/
	@isTest
	public static void testInvokeCreatePatientInRisApiWithNullManEast() {
		User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetManagerEast);
		runtestInvokeCreatePatientInRisApiWithNull(radnetManagerEast);
	}
	/**
	* @Jira CC-430
	* @description - Tests the invocation of the RIS create patient API. This method verifies the null value scenarios.
	* @param       - None
	**/
	public static void runtestInvokeCreatePatientInRisApiWithNull(User user) {
		HttpResponse mockResponse = DH_TestDataFactory.createMockResponse(200, '');
		HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse, 0,200);
		Test.setMock(HttpCalloutMock.class, mock);
		System.runAs(user) {
			Account testAccount = DH_TestDataFactory.createAccount('CA', 'Default', 'CA', DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
			insert testAccount;
			VoiceCall voiceCallRecord = [SELECT ID, Name,OwnerId FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3498' LIMIT 1];
            DH_DexOutServiceRisNewPatientRequest wrapper = DH_TestDataFactory.createDexOutServiceRisNewPatientRequest(voiceCallRecord.ID, 'TestUser', '3600', 'John', 'Doe', '1234567890', 'john.doe@example.com');
			DH_PayloadData__c plRecord = DH_TestDataFactory.createPayLoadRecord('DH_RisNewPatientServiceSetting', voiceCallRecord.Id, String.valueOf(wrapper));
			DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisNewPatientServiceSetting');
			DH_DexOutGeneralServiceRequest apiRequest = new DH_DexOutGeneralServiceRequest();
			apiRequest.patientId = testAccount.Id;
			apiRequest.recordId = voiceCallRecord.Id;
			apiRequest.apiSetting = integrationSettingMetadata;
			wrapper.recordId = voiceCallRecord.Id;
			wrapper.sfId = testAccount.Id;
			wrapper.systemID = null;
			List<DH_DynamicTableColumns__mdt> toBeReplaced = DH_CustomMetadataDao.getDynamicTableColumnList('DH_DexOutServiceRisNewPatient');
			Test.startTest();
			DH_DexOutGeneralServiceResponse result = DH_DexOutServiceRisNewPatient.invokeCreatePatientInRisApi(wrapper);
			Test.stopTest();
			DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c, DH_ClassName__c FROM DH_PayloadData__c LIMIT 1];
			System.assertNotEquals(null, payLoad, 'test is successful');
		}
	}
	/**
	* @Jira CC-426
	* @description - This class generates mock HTTP responses for the HTTP callouts made during testing.
	*                It allows simulating different scenarios, including handling retries when an initial callout fails.
	**/
	private class MockHttpResponseGenerator implements HttpCalloutMock {
		private HttpResponse response;
		private Integer retryLimit;
        private Integer statusCode;
		public MockHttpResponseGenerator(HttpResponse response, Integer retryLimit,Integer statusCode) {
			this.response = response;
			this.retryLimit = retryLimit;
            this.statusCode = statusCode;
		}
		public HttpResponse respond(HttpRequest req) {
			if (retryLimit > 0) {
				retryLimit--;
				return response;
			} else {
				HttpResponse finalResponse = new HttpResponse();
				finalResponse.setHeader('Content-Type', 'application/json');
				finalResponse.setStatusCode(statusCode);
				finalResponse.setBody('[{"patientId": "123", "firstName": "Test", "lastName": "Patient"}]');
				return finalResponse;
			}
		}
	}
}