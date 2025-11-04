/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServiceRisOpenPatientTest
* Created Date : 01-August-2024
* @description : Test class for DH_DexOutServiceRisOpenPatient class.
* Modification Log : 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       -----------------------------------------------------------------------------------------
* CC-505                   01-August-2024       Added setup,testInvokeRisOpenPatientApi and testinvokeRisOpenPatientApiWithError methods.
* CC-430                   11-September-2024    Added testinvokeRisOpenPatientApiWithNull method
* CC-1204                  13-September-2024    Updated all the test methods.
* CC-505              	   09-October-2024     	Changes related to code optimization and code coverage.
* CC-1439                  30-Oct-2024			Replaced all instances of FromPhoneNumber with F9_Call_ANI__c
* ***************************************************************************************************************************************
*/
@isTest
public class DH_DexOutServiceRisOpenPatientTest{
    /**
    * @Jira CC-505
    * @description - Creates reusable test data that can be used across multiple test methods within the same class.
    **/
	@testSetup
	public static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
        User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
        User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
        List<VoiceCall> vcList = new List<VoiceCall>();
		VoiceCall voiceCallRecord1 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '+1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'FL');
		vcList.add(voiceCallRecord1);  
        VoiceCall voiceCallRecord2 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '+1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'FL');
		vcList.add(voiceCallRecord2); 
        VoiceCall voiceCallRecord3 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '+1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'FL');
		vcList.add(voiceCallRecord3);     
        VoiceCall voiceCallRecord4 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '+1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'FL');
		vcList.add(voiceCallRecord4);
        insert vcList;
        List<VoiceCall> updateVcList = new List<VoiceCall>();
        VoiceCall var1 = DH_TestDataFactory.assignVcOwner(voiceCallRecord1.ID, radnetSchedulerWest.ID);
		updateVcList.add(var1);
        VoiceCall var2 = DH_TestDataFactory.assignVcOwner(voiceCallRecord2.ID, radnetManagerWest.ID);
		updateVcList.add(var2);
        VoiceCall var3 = DH_TestDataFactory.assignVcOwner(voiceCallRecord3.ID, radnetSchedulerEast.ID);
		updateVcList.add(var3);
		VoiceCall var4 = DH_TestDataFactory.assignVcOwner(voiceCallRecord4.ID, radnetSchedulerEast.ID);
        updateVcList.add(var4);
		update updateVcList;
	}
    /**
    * @Jira CC-505
    * @description - Method which has common code for the invoeRisOpenPatientAPI.
    * @param       - User
    * @return	   - String
    **/
	public static String runTestInvokeRisOpenPatientApiTest(User userRec) {
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        String accId;
		Test.setMock(HttpCalloutMock.class, mock);
		System.runAs(userRec) {
			VoiceCall voiceCallRecord = [SELECT ID, Name FROM VoiceCall LIMIT 1];
            DH_DexOutServiceRisOpenPatientRequest wrapper =  DH_TestDataFactory.createDexOutServiceRisOpenPatientRequest(
                voiceCallRecord.Id,
                '759686',
                'FL'
            );
            String uniquePatientIdentifier = wrapper.systemId+'_'+wrapper.patientKey +'_' + System.Label.DH_PersonAccountRecordTypeName;
            Test.startTest();
            accId = DH_DexOutServiceRisOpenPatient.invokeRisOpenPatientApi(wrapper);
            Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
            System.assertNotEquals(null, payLoad, 'Payload Record is not created');
            System.assertEquals('200',payLoad.DH_ResponseCode__c,'Payload Record is not created');
            Account patient = [Select Id from Account where DH_RIS_Unique_Code__c =: uniquePatientIdentifier WITH SECURITY_ENFORCED Limit 1];
            System.assertEquals(patient.Id, accId,'Error occurred while retrieving the patientId');
		}
        return accId;
    }
    /**
    * @Jira CC-505
    * @description - Tests the invocation of the RIS Open patient API. This method verifies the successful retrieval of patient data from the API.
    **/
	@isTest
	public static void testInvokeRisOpenPatientApiSchWest() {
		User radnetScheduler = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetScheduler);
        String accId = runTestInvokeRisOpenPatientApiTest(radnetScheduler);	
        System.assertNotEquals(null,accId, 'Response is recieved');
	}
    /**
    * @Jira CC-505
    * @description - Tests the invocation of the RIS Open patient API. This method verifies the successful retrieval of patient data from the API.
    **/
	@isTest
	public static void testInvokeRisOpenPatientApiSchEast() {
		User radNetSchedulerEast = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetSchedulerEast);
        String accId = runTestInvokeRisOpenPatientApiTest(radNetSchedulerEast);
        System.assertNotEquals(null,accId, 'Response is recieved');
	}
    /**
    * @Jira CC-505
    * @description - Tests the invocation of the RIS Open patient API. This method verifies the successful retrieval of patient data from the API.
    **/
	@isTest
	public static void testInvokeRisOpenPatientApiManWest() {
		User radNetManagerWest = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radNetManagerWest);
        String accId = runTestInvokeRisOpenPatientApiTest(radNetManagerWest);
        System.assertNotEquals(null,accId, 'Response is recieved');	
	}
    /**
    * @Jira CC-505
    * @description - Tests the invocation of the RIS Open patient API. This method verifies the successful retrieval of patient data from the API.
    **/
	@isTest
	public static void testInvokeRisOpenPatientApiManEast() {
		User radNetManagerEast = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radNetManagerEast);
        String accId = runTestInvokeRisOpenPatientApiTest(radNetManagerEast);
        System.assertNotEquals(null,accId, 'Response is recieved');
	}
    /**
    * @Jira CC-505
    * @description - Method which has common code for the testinvokeRisOpenPatientApiWithError.
    * @param       - User
    * @return	   - String
    **/
	public static String runTestinvokeRisOpenPatientApiWithErrorTest(User userRec) {
        HttpCalloutMock mock = new MockHttpResponseErrorGenerator(404);
        String accId;
        Test.setMock(HttpCalloutMock.class, mock);
		System.runAs(userRec) {
			VoiceCall voiceCallRecord = [SELECT ID, Name FROM VoiceCall LIMIT 1];
            DH_DexOutServiceRisOpenPatientRequest wrapper =  DH_TestDataFactory.createDexOutServiceRisOpenPatientRequest(
                voiceCallRecord.Id,
                '759686',
                'FL'
            );
            String uniquePatientIdentifier = wrapper.systemId+'_'+wrapper.patientKey +'_' + System.Label.DH_PersonAccountRecordTypeName;
			Test.startTest();
            accId = DH_DexOutServiceRisOpenPatient.invokeRisOpenPatientApi(wrapper);
			Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
            System.assertNotEquals(null, payLoad, 'Payload is created');
            System.assertEquals('404',payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
		}
        return accId;
    }
    /**
    * @Jira CC-505
    * @description - Tests the invocation of the RIS Open patient API when an error occurs.
    **/
	@isTest
	public static void testinvokeRisOpenPatientApiWithErrorSchWest() {
		User radnetScheduler = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetScheduler);
        String accId = runTestinvokeRisOpenPatientApiWithErrorTest(radnetScheduler);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-505
    * @description - Tests the invocation of the RIS Open patient API when an error occurs.
    **/
	@isTest
	public static void testinvokeRisOpenPatientApiWithErrorSchEast() {
		User radNetSchedulerEast = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetSchedulerEast);
        String accId = runTestinvokeRisOpenPatientApiWithErrorTest(radNetSchedulerEast);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-505
    * @description - Tests the invocation of the RIS Open patient API when an error occurs.
    **/
	@isTest
	public static void testinvokeRisOpenPatientApiWithErrorManWest() {
		User radNetManagerWest = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radNetManagerWest);
        String accId = runTestinvokeRisOpenPatientApiWithErrorTest(radNetManagerWest);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-505
    * @description - Tests the invocation of the RIS Open patient API when an error occurs.
    **/
	@isTest
	public static void testinvokeRisOpenPatientApiWithErrorManEast() {
		User radNetManagerEast = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radNetManagerEast);
        String accId = runTestinvokeRisOpenPatientApiWithErrorTest(radNetManagerEast);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-430
    * @description - Method which has common code for the testinvokeRisOpenPatientApiWithNull.
    * @param       - User
    * @return	   - String
    **/
	public static Id runTestinvokeRisOpenPatientApiWithNullTest(User userRec) {
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        Id accId;
		Test.setMock(HttpCalloutMock.class, mock);
		System.runAs(userRec) {
			VoiceCall voiceCallRecord = [SELECT ID, Name FROM VoiceCall LIMIT 1];
            DH_DexOutServiceRisOpenPatientRequest wrapper =  DH_TestDataFactory.createDexOutServiceRisOpenPatientRequest(
                voiceCallRecord.Id,
                '759686',
                null
            );
            DH_DexOutServiceRisOpenPatientResponse.Data patientWrapper = new DH_DexOutServiceRisOpenPatientResponse.Data();
            patientWrapper.patient_key = '1234';
            patientWrapper.first_name = 'testFirst';
            patientWrapper.last_name = 'LastName';
			Test.startTest();
            accId = DH_DexOutServiceRisOpenPatientParser.upsertPatientAccount(patientWrapper,wrapper);
			Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_Error__c FROM DH_PayloadData__c LIMIT 1];
            System.assertNotEquals(null, payLoad, 'Payload is not created');
            System.assertEquals('Missing Info: urlParametersWrapper.systemId,', payLoad.DH_Error__c, 'Payload is not created');
		}
        return accId;
    }
    /**
	* @Jira CC-430
    * @description - Tests the invocation of the RIS Open patient API when values are null.
	**/
	@isTest
	public static void testinvokeRisOpenPatientApiWithNullAccSchWest() {
		User radnetScheduler = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetScheduler);     
        Id accId = runTestinvokeRisOpenPatientApiWithNullTest(radnetScheduler);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
	* @Jira CC-430
    * @description - Tests the invocation of the RIS Open patient API when values are null.
	**/
	@isTest
	public static void testinvokeRisOpenPatientApiWithNullAccSchEast() {
        User radNetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetSchedulerEast);
        Id accId = runTestinvokeRisOpenPatientApiWithNullTest(radNetSchedulerEast);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
	* @Jira CC-430
    * @description - Tests the invocation of the RIS Open patient API when values are null.
	**/
	@isTest
	public static void testinvokeRisOpenPatientApiWithNullAccManWest() {
        User radNetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radNetManagerWest);
        Id accId = runTestinvokeRisOpenPatientApiWithNullTest(radNetManagerWest);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
	* @Jira CC-430
    * @description - Tests the invocation of the RIS Open patient API when values are null.
	**/
	@isTest
	public static void testinvokeRisOpenPatientApiWithNullAccManEast() {
        User radNetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radNetManagerEast);
        Id accId = runTestinvokeRisOpenPatientApiWithNullTest(radNetManagerEast);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-430
    * @description - Method which has common code for the testinvokeRisOpenPatientApiNullSysId.
    * @param       - User
    * @return	   - String
    **/
	public static String runTestinvokeRisOpenPatientApiNullSysIdTest(User userRec) {
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        String accId;
		Test.setMock(HttpCalloutMock.class, mock);
		System.runAs(userRec) {
			VoiceCall voiceCallRecord = [SELECT ID, Name FROM VoiceCall LIMIT 1];
            DH_DexOutServiceRisOpenPatientRequest wrapper =  DH_TestDataFactory.createDexOutServiceRisOpenPatientRequest(
                voiceCallRecord.Id,
                '759686',
                null
            );
            String uniquePatientIdentifier = wrapper.systemId+'_'+wrapper.patientKey +'_' + System.Label.DH_PersonAccountRecordTypeName;
			Test.startTest();
            accId = DH_DexOutServiceRisOpenPatient.invokeRisOpenPatientApi(wrapper);
			Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_Error__c FROM DH_PayloadData__c LIMIT 1];
            System.assertNotEquals(null, payLoad, 'Payload is not created');
            System.assertEquals('Missing Info: urlParametersWrapper.systemId', payLoad.DH_Error__c, 'Payload is not created');
		}
        return accId;
    }
    /**
    * @Jira CC-430
    * @description - Tests the invocation of the RIS Open patient API. This method verifies the scenario when the system id is null.
    **/
	@isTest
	public static void testInvokeRisOpenPatientApiNullSysIdSchWest() {
		User radnetScheduler = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetScheduler);
        String accId = runTestinvokeRisOpenPatientApiNullSysIdTest(radnetScheduler);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-430
    * @description - Tests the invocation of the RIS Open patient API. This method verifies the scenario when the system id is null.
    **/
	@isTest
	public static void testInvokeRisOpenPatientApiNullSysIdSchEast() {
		User radNetSchedulerEast = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetSchedulerEast);
        String accId = runTestinvokeRisOpenPatientApiNullSysIdTest(radNetSchedulerEast);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-430
    * @description - Tests the invocation of the RIS Open patient API. This method verifies the scenario when the system id is null.
    **/
	@isTest
	public static void testInvokeRisOpenPatientApiNullSysIdManWest() {
		User radNetManagerWest = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radNetManagerWest);
        String accId = runTestinvokeRisOpenPatientApiNullSysIdTest(radNetManagerWest);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-430
    * @description - Tests the invocation of the RIS Open patient API. This method verifies the scenario when the system id is null.
    **/
    @isTest
	public static void testInvokeRisOpenPatientApiNullSysIdManEast() {
		User radNetManagerEast = [SELECT ID, Username,DH_User_Region__c,FederationIdentifier FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radNetManagerEast);
        String accId = runTestinvokeRisOpenPatientApiNullSysIdTest(radNetManagerEast);
        System.assertEquals(null, accId, 'Response is recieved');
	}
    /**
    * @Jira CC-505
    * @description - Test methd to cover the catch block.
    * @param       - User
    * @return	   - String
    **/
	@isTest
	public static void testInvokeRisOpenPatientApiSchWestTwo() {
		User radnetScheduler = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radNetScheduler);
        HttpCalloutMock mock = new MockHttpResponseGeneratorTwo();
		Test.setMock(HttpCalloutMock.class, mock);
		System.runAs(radNetScheduler) {
			VoiceCall voiceCallRecord = [SELECT ID, Name FROM VoiceCall LIMIT 1];
            DH_DexOutServiceRisOpenPatientRequest wrapper =  DH_TestDataFactory.createDexOutServiceRisOpenPatientRequest(
                voiceCallRecord.Id,
                '759686',
                'FL'
            );
            String uniquePatientIdentifier = wrapper.systemId+'_'+wrapper.patientKey +'_' + System.Label.DH_PersonAccountRecordTypeName;
			Test.startTest();
            String accId = DH_DexOutServiceRisOpenPatient.invokeRisOpenPatientApi(wrapper);
			Test.stopTest();
            System.assertEquals(null, accId, 'Account record should not get created');
		}
	}
    /**
    * @Jira CC-505
    * @description - This class generates mock HTTP responses for the HTTP callouts made during testing. It allows simulating different scenarios
    **/
    @TestVisible
    private class MockHttpResponseGeneratorTwo implements HttpCalloutMock {
        private HttpResponse response;
        public HTTPResponse respond(HTTPRequest req) {
                HttpResponse finalResponse = new HttpResponse();
                finalResponse.setHeader('Content-Type', 'application/json');
                finalResponse.setStatusCode(200);
                finalResponse.setBody('[[{\"result\":\"{\\\"url\\\":\\\"/api/v1/StoredProcedureAggregator/PatientKey/759686?action=z_api_CheckDeepLinkingRequestStatus&systemID=FL_Training\\\",\\\"body\\\":{\\\"data\\\":{\\\"requestID\\\":\\\"481\\\"}}}\"}],[{\"data\":\"[{\\\"patient_key\\\":759686,\\\"first_name\\\":\\\"Magnus\\\",\\\"last_name\\\":\\\"\\\",\\\"middle_name\\\":\\\"\\\",\\\"mrn\\\":\\\"61\\\",\\\"issuer_of_patient_id\\\":\\\"system\\\",\\\"birth_date\\\":\\\"1960-04-05\\\",\\\"gender_code\\\":\\\"M\\\",\\\"primary_address_line1\\\":\\\"45AlternicusLane\\\",\\\"primary_address_line2\\\":\\\"Suite33\\\",\\\"primary_address_city\\\":\\\"Reyjavik\\\",\\\"primary_address_state\\\":\\\"\\\",\\\"primary_address_zipcode\\\":\\\"23236\\\",\\\"patientPhones\\\":[{\\\"patient_phone_key\\\":11800,\\\"phone_number\\\":\\\"555-555-5555\\\",\\\"mobile_flag\\\":\\\"N\\\",\\\"primary_flag\\\":\\\"Y\\\",\\\"display_order\\\":1},{\\\"patient_phone_key\\\":16378,\\\"phone_number\\\":\\\"444-444-4444\\\",\\\"mobile_flag\\\":\\\"Y\\\",\\\"primary_flag\\\":\\\"N\\\",\\\"display_order\\\":2}],\\\"patientEmailAddresses\\\":[{\\\"patient_email_key\\\":5,\\\"email_address\\\":\\\"mmmagnus@iceland.ic\\\",\\\"primary_flag\\\":\\\"Y\\\",\\\"display_order\\\":2}],\\\"patientExtraInfo\\\":[],\\\"patientAlerts\\\":[]}]\"}]]');
                return finalResponse;
            }
    }
    /**
    * @Jira CC-505
    * @description - This class generates mock HTTP responses for the HTTP callouts made during testing. It allows simulating different scenarios
    **/
    @TestVisible
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        public HTTPResponse respond(HTTPRequest req) {
                HttpResponse finalResponse = new HttpResponse();
                finalResponse.setHeader('Content-Type', 'application/json');
                finalResponse.setStatusCode(200);
                finalResponse.setBody('[[{\"result\":\"{\\\"url\\\":\\\"/api/v1/StoredProcedureAggregator/PatientKey/759686?action=z_api_CheckDeepLinkingRequestStatus&systemID=FL_Training\\\",\\\"body\\\":{\\\"data\\\":{\\\"requestID\\\":\\\"481\\\"}}}\"}],[{\"data\":\"[{\\\"patient_key\\\":759686,\\\"first_name\\\":\\\"Magnus\\\",\\\"last_name\\\":\\\"Magnusson\\\",\\\"middle_name\\\":\\\"\\\",\\\"mrn\\\":\\\"61\\\",\\\"issuer_of_patient_id\\\":\\\"system\\\",\\\"birth_date\\\":\\\"1960-04-05\\\",\\\"gender_code\\\":\\\"M\\\",\\\"primary_address_line1\\\":\\\"45AlternicusLane\\\",\\\"primary_address_line2\\\":\\\"Suite33\\\",\\\"primary_address_city\\\":\\\"Reyjavik\\\",\\\"primary_address_state\\\":\\\"\\\",\\\"primary_address_zipcode\\\":\\\"23236\\\",\\\"patientPhones\\\":[{\\\"patient_phone_key\\\":11800,\\\"phone_number\\\":\\\"555-555-5555\\\",\\\"mobile_flag\\\":\\\"N\\\",\\\"primary_flag\\\":\\\"Y\\\",\\\"display_order\\\":1},{\\\"patient_phone_key\\\":16378,\\\"phone_number\\\":\\\"444-444-4444\\\",\\\"mobile_flag\\\":\\\"Y\\\",\\\"primary_flag\\\":\\\"N\\\",\\\"display_order\\\":2}],\\\"patientEmailAddresses\\\":[{\\\"patient_email_key\\\":5,\\\"email_address\\\":\\\"mmmagnus@iceland.ic\\\",\\\"primary_flag\\\":\\\"Y\\\",\\\"display_order\\\":1}],\\\"patientExtraInfo\\\":[],\\\"patientAlerts\\\":[]}]\"}]]');
                return finalResponse;
            }
    }
    /**
    * @Jira CC-505
    * @description - This class generates mock HTTP responses for the HTTP callouts made during testing. It allows simulating different scenarios
    * @param       - None
    * @return      - HTTPResponse
    **/
    @TestVisible
    private class MockHttpResponseErrorGenerator implements HttpCalloutMock {
        private Integer statusCode;
        public MockHttpResponseErrorGenerator(Integer statusCode) {
            this.statusCode = statusCode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse finalResponse = new HttpResponse();
            finalResponse.setHeader('Content-Type', 'application/json');
            finalResponse.setStatusCode(statusCode);
            finalResponse.setBody(System.Label.DH_DefaultErrorMessage);
            return finalResponse;
        }
    }
}