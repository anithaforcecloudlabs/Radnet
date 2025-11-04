/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisPatientSearchTest
* Created Date - 27-May-2024
* @description       : Test Class for DH_DexOutServiceRisPatientSearch service class.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-430                   27-May-2024          Added testInvokeRisPatientSearchApi,testInvokeRisPatientSearchApiWithError and setup methods.
* CC-476                   02-July-2024         Updated the response for testInvokeRisPatientSearchApi,testInvokeRisPatientSearchApiWithError methods.
* CC-482-507               31-July-2024         Added updatedtestInvokeRisPatientSearchApi,testInvokeRisPatientSearchServerError methods
* CC-430                   11-September-2024    Added testInvokeRisPatientSearchApiWithNull method
* CC-1204                  12-September-2024    Updated all the test methods, Added testInvokeRisPatientSearchApiSchWest/SchEast/ManEast/ManWest,
                                                testInvokeRisPatientSearchApiWithNullSchWest/SchEast/ManEast/ManWest,testInvokeRisPatientSearchApiWithErrorSchWest/SchEast/ManEast/ManWest,testInvokeRisPatientSearchApiWithSFErrorSchWest/SchEast/ManEast/ManWest,testInvokeRisPatientSearchServerErrorSchWest/SchEast/ManEast/ManWest and testInvokeRisPatientSearchApiWithInvalidPhNoSchWest/SchEast/ManEast/ManWest methods
* CC-430				   08-October-2024		Changes related to code optimization and code coverage.
* CC-1312                  23-April-2025        Renamed and updated testInvokeRisPatientSearchApiWithInvalidPhNoSchWest to testInvokeRisPatientSearchApiWithBlankPhNoSchWest, added testInvokeRisPatientSearchApiWithBlankPhNo method
* ***************************************************************************************************************************************************
*/

@isTest
public class DH_DexOutServiceRisPatientSearchTest {
    private class WraperPayloadVsresult{
        public Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> results {get;set;}
        public DH_PayloadData__c payLoad {get;set;}
    }
    /**
	* @Jira CC-430
    * @description - Creates reusable test data that can be used across multiple test methods within the same class.
	**/
    @testSetup
    public static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
        User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
        User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerEast);
    }
    /**
	* @Jira CC-482
    * @description - Created reusable methods runTestInvokeRisPatientSearchApi which invoke api for all users.
    * @param       - User
    * @return      - wraperPayloadVsresult
	**/
    static wraperPayloadVsresult runTestInvokeRisPatientSearchApi(User userToRun) {
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,true);
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock); 
        wraperPayloadVsresult wr = new wraperPayloadVsresult();     
        System.runAs(userToRun) {
            Test.startTest();
            Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> results = DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi(wrapper);
            Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
            wr.results = results;
            wr.payLoad = payLoad;
        }
        return wr; 
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiSchWest(){   
        User radNetSchedulerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = runTestInvokeRisPatientSearchApi(radNetSchedulerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload Record is created');
        System.assertEquals('200',wr.payLoad.DH_ResponseCode__c,'Payload Record is created');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        System.assertEquals(3,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(2,wr.results.get(1).size(),'Error occured in the invokeRisPatientSearchApi');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiSchEast(){   
        User radNetSchedulerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = runTestInvokeRisPatientSearchApi(radNetSchedulerEast);
        System.assertNotEquals(null, wr.payLoad, 'Payload Record is created');
        System.assertEquals('200',wr.payLoad.DH_ResponseCode__c,'Payload Record is created');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        System.assertEquals(3,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(2,wr.results.get(1).size(),'Error occured in the invokeRisPatientSearchApi');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiManWest(){   
        User radNetManagerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = runTestInvokeRisPatientSearchApi(radNetManagerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload Record is created');
        System.assertEquals('200',wr.payLoad.DH_ResponseCode__c,'Payload Record is created');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        System.assertEquals(3,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(2,wr.results.get(1).size(),'Error occured in the invokeRisPatientSearchApi');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiManEast(){   
        User radNetManagerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = runTestInvokeRisPatientSearchApi(radNetManagerEast);
        System.assertNotEquals(null, wr.payLoad, 'Payload Record is created');
        System.assertEquals('200',wr.payLoad.DH_ResponseCode__c,'Payload Record is created');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        System.assertEquals(3,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(2,wr.results.get(1).size(),'Error occured in the invokeRisPatientSearchApi');
    }
    /**
	* @Jira CC-430
    * @description - Created reusable methods runTestInvokeRisPatientSearchApiWithNull  which will run null check for all users.
    * @param       - User
    * @return      - DH_PayloadData__c
	**/
    static DH_PayloadData__c runTestInvokeRisPatientSearchApiWithNull(User userToRun) {
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,false);
        DH_PayloadData__c payLoad = new DH_PayloadData__c();
        System.runAs(userToRun) {
            Test.startTest();
            Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> results = DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi(wrapper);
            Test.stopTest();
            payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
        }
        return payLoad;
    }
    /**
	* @Jira CC-430
    * @description - Tests the invocation of the RIS patient search API. This method checks the null value scenarios.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithNullSchWest(){   
        User radNetSchedulerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        DH_PayloadData__c payLoad = runTestInvokeRisPatientSearchApiWithNull(radNetSchedulerWest);
        System.assertNotEquals(null, payLoad, 'Payload Record is created');
    } 
    /**
	* @Jira CC-430
    * @description - Tests the invocation of the RIS patient search API. This method checks the null value scenarios.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithNullSchEast(){   
        User radNetSchedulerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        DH_PayloadData__c payLoad = runTestInvokeRisPatientSearchApiWithNull(radNetSchedulerEast);
        System.assertNotEquals(null, payLoad, 'Payload Record is created');
    } 
    /**
	* @Jira CC-430
    * @description - Tests the invocation of the RIS patient search API. This method checks the null value scenarios.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithNullManWest(){   
        User radNetManagerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        DH_PayloadData__c payLoad = runTestInvokeRisPatientSearchApiWithNull(radNetManagerWest);
        System.assertNotEquals(null, payLoad, 'Payload Record is created');
    } 
    /**
	* @Jira CC-430
    * @description - Tests the invocation of the RIS patient search API. This method checks the null value scenarios.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithNullManEast(){   
        User radNetManagerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        DH_PayloadData__c payLoad = runTestInvokeRisPatientSearchApiWithNull(radNetManagerEast);
        System.assertNotEquals(null, payLoad, 'Payload Record is created');
    } 
    /**
	* @Jira CC-482
    * @description - Created reusable methods runTestInvokeRisPatientSearchApiWithError  which will run 404Error check for all users.
    * @param       - User.
    * @return      - wraperPayloadVsresult.
	**/
    static wraperPayloadVsresult runTestInvokeRisPatientSearchApiWithError(User userToRun) {
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true, true, true, true, true, true, true,true,true);  
        HttpCalloutMock mock = new MockHttpResponseErrorGenerator(404);
        Test.setMock(HttpCalloutMock.class, mock);   
        wraperPayloadVsresult wr = new wraperPayloadVsresult();    
        System.runAs(userToRun){   
            Test.startTest();
            Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> results = DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi(wrapper);
            Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
            wr.results = results;
            wr.payLoad = payLoad;
        }
        return wr;
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API when an error occurs.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithErrorSchWest() {       
        User radNetSchedulerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = runTestInvokeRisPatientSearchApiWithError(radNetSchedulerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload is created');
        System.assertEquals('404',wr.payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        System.assertEquals(1,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(System.Label.DH_404DefaultErrorMessage, wr.results.get(-1).get(0).errorMessage, 'Error Message Recieved');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API when an error occurs.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithErrorSchEast() {       
        User radNetSchedulerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = runTestInvokeRisPatientSearchApiWithError(radNetSchedulerEast);
        System.assertNotEquals(null, wr.payLoad, 'Payload is created');
        System.assertEquals('404',wr.payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        System.assertEquals(1,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(System.Label.DH_404DefaultErrorMessage, wr.results.get(-1).get(0).errorMessage, 'Error Message Recieved');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API when an error occurs.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithErrorManWest() {       
        User radNetManagerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = runTestInvokeRisPatientSearchApiWithError(radNetManagerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload is created');
        System.assertEquals('404',wr.payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        System.assertEquals(1,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(System.Label.DH_404DefaultErrorMessage, wr.results.get(-1).get(0).errorMessage, 'Error Message Recieved');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API when an error occurs.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithErrorManEast() {       
        User radNetManagerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = runTestInvokeRisPatientSearchApiWithError(radNetManagerEast);
        System.assertNotEquals(null, wr.payLoad, 'Payload is created');
        System.assertEquals('404',wr.payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        System.assertEquals(1,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(System.Label.DH_404DefaultErrorMessage, wr.results.get(-1).get(0).errorMessage, 'Error Message Recieved');
    }
    /**
	* @Jira CC-482
    * @description - Created reusable methods testInvokeRisPatientSearchApiWithSFError  which will run 400Error check for all users.
    * @param       - User.
    * @return      - wraperPayloadVsresult.
	**/
    static wraperPayloadVsresult testInvokeRisPatientSearchApiWithSFError(User userToRun) {
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true, true, true, true, true, true, true,true,true);  
        HttpCalloutMock mock = new MockHttpResponseErrorGenerator(400);
        wraperPayloadVsresult wr = new wraperPayloadVsresult();
        Test.setMock(HttpCalloutMock.class, mock);       
        System.runAs(userToRun){   
            Test.startTest();
            Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> results = DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi(wrapper);
            Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
            wr.results = results;
            wr.payLoad = payLoad;
        }
        return wr;
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API when an server error occur.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithSFErrorSchWest() {       
        User radNetSchedulerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchApiWithSFError(radNetSchedulerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload record is created');
        System.assertEquals('400',wr.payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
        System.assertNotEquals(null, wr.results, 'Error Response is received');
        System.assertEquals(1,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(System.Label.DH_400DefaultErrorMessage, wr.results.get(-1).get(0).errorMessage, 'Error Message Recieved');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API when an server error occur.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithSFErrorSchEast() {       
        User radNetSchedulerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchApiWithSFError(radNetSchedulerEast);
        System.assertNotEquals(null, wr.payLoad, 'Payload record is created');
        System.assertEquals('400',wr.payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
        System.assertNotEquals(null, wr.results, 'Error Response is received');
        System.assertEquals(1,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(System.Label.DH_400DefaultErrorMessage, wr.results.get(-1).get(0).errorMessage, 'Error Message Recieved');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API when an server error occur.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithSFErrorManWest() {       
        User radNetManagerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchApiWithSFError(radNetManagerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload record is created');
        System.assertEquals('400',wr.payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
        System.assertNotEquals(null, wr.results, 'Error Response is received');
        System.assertEquals(1,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(System.Label.DH_400DefaultErrorMessage, wr.results.get(-1).get(0).errorMessage, 'Error Message Recieved');
    }
    /**
	* @Jira CC-482
    * @description - Tests the invocation of the RIS patient search API when an server error occur.
	**/
    @isTest
    public static void testInvokeRisPatientSearchApiWithSFErrorManEast() {       
        User radNetManagerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchApiWithSFError(radNetManagerEast);
        System.assertNotEquals(null, wr.payLoad, 'Payload record is created');
        System.assertEquals('400',wr.payLoad.DH_ResponseCode__c,'Error occured in the payload data creation');
        System.assertNotEquals(null, wr.results, 'Error Response is received');
        System.assertEquals(1,wr.results.size(),'Error occured in the invokeRisPatientSearchApi');
        System.assertEquals(System.Label.DH_400DefaultErrorMessage, wr.results.get(-1).get(0).errorMessage, 'Error Message Recieved');
    }
    /**
	* @Jira CC-507
    * @description - Created reusable methods testInvokeRisPatientSearchServerError  which will run 500 Error check for all users.
    * @param       - User.
    * @return      - wraperPayloadVsresult.
	**/
    static wraperPayloadVsresult testInvokeRisPatientSearchServerError(User userToRun) {
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true, true, true, true, true, true, true,true,true);  
        HttpCalloutMock mock = new MockHttpResponseErrorGenerator(500);
        wraperPayloadVsresult wr = new wraperPayloadVsresult();
        Test.setMock(HttpCalloutMock.class, mock);       
        System.runAs(userToRun){   
            Test.startTest();
            Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> results = DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi(wrapper);
            Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
            wr.results = results;
            wr.payLoad = payLoad;
        }
        return wr;
    }
    /**
	* @Jira CC-507
    * @description - Tests the invocation of the RIS patient search API when an server error occur.
	**/
    @isTest
    public static void testInvokeRisPatientSearchServerErrorSchWest() {       
        User radNetSchedulerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchServerError(radNetSchedulerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload record is created');
        System.assertEquals('500',wr.payLoad.DH_ResponseCode__c,'Server error occured during Patient Search');
        System.assertNotEquals(null, wr.results, 'Success response after retry');
    }
    /**
	* @Jira CC-507
    * @description - Tests the invocation of the RIS patient search API when an server error occur.
	**/
    @isTest
    public static void testInvokeRisPatientSearchServerErrorSchEast() {       
        User radNetSchedulerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchServerError(radNetSchedulerEast);
        System.assertNotEquals(null, wr.payLoad, 'Payload record is created');
        System.assertEquals('500',wr.payLoad.DH_ResponseCode__c,'Server error occured during Patient Search');
        System.assertNotEquals(null, wr.results, 'Success response after retry');
    }
    /**
	* @Jira CC-507
    * @description - Tests the invocation of the RIS patient search API when an server error occur.
	**/
    @isTest
    public static void testInvokeRisPatientSearchServerErrorManWest() {       
        User radNetManagerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr =testInvokeRisPatientSearchServerError(radNetManagerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload record is created');
        System.assertEquals('500',wr.payLoad.DH_ResponseCode__c,'Server error occured during Patient Search');
        System.assertNotEquals(null, wr.results, 'Success response after retry');
    }
    /**
	* @Jira CC-507
    * @description - Tests the invocation of the RIS patient search API when an server error occur.
	**/
    @isTest
    public static void testInvokeRisPatientSearchServerErrorManEast() {       
        User radNetManagerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchServerError(radNetManagerEast);
        System.assertNotEquals(null, wr.payLoad, 'Payload record is created');
        System.assertEquals('500',wr.payLoad.DH_ResponseCode__c,'Server error occured during Patient Search');
        System.assertNotEquals(null, wr.results, 'Success response after retry');
    }
    /**
	* @Jira CC-1312
    * @description - Created reusable methods testInvokeRisPatientSearchApiWithInvalidPhNo which will run to check invalid phone number error for all users.
    * @param       - User.
    * @return      - wraperPayloadVsresult.
	**/
    static wraperPayloadVsresult testInvokeRisPatientSearchApiWithInvalidPhNo(User userToRun) {
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,true);
        wrapper.callType = 'Inbound';
        wrapper.phoneNumber = 'test@gmail.com';
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        wraperPayloadVsresult wr = new wraperPayloadVsresult();
        Test.setMock(HttpCalloutMock.class, mock);      
        System.runAs(userToRun) {
            Test.startTest();
            Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> results = DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi(wrapper);
            Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
            wr.results = results;
            wr.payLoad = payLoad;
        }
        return wr;
    }
    /**
	* @Jira CC-1312
    * @description - Created reusable methods testInvokeRisPatientSearchApiWithBlankPhNo which will run to check null or blank phone number error.
    * @param       - User.
    * @return      - wraperPayloadVsresult.
	**/
    static wraperPayloadVsresult testInvokeRisPatientSearchApiWithBlankPhNo(User userToRun) {
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,true);
        wrapper.callType = 'Inbound';
        wrapper.phoneNumber = '';
        wrapper.isAdvanceSearch = false;
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        wraperPayloadVsresult wr = new wraperPayloadVsresult();
        Test.setMock(HttpCalloutMock.class, mock);      
        System.runAs(userToRun) {
            Test.startTest();
            Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> results = DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi(wrapper);
            Test.stopTest();
            DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c LIMIT 1];
            wr.results = results;
            wr.payLoad = payLoad;
        }
        return wr;
    }
    /**
	* @Jira CC-1312
    * @description - Tests the invocation of the RIS patient search API. This method verifies the scenario when the phone number is not valid.
	**/
    @isTest
    private static void testInvokeRisPatientSearchApiWithBlankPhNoSchWest(){   
        User radNetSchedulerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchApiWithBlankPhNo(radNetSchedulerWest);
        System.assertNotEquals(null, wr.payLoad, 'Payload Record is created');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        DH_DexOutServiceRisPatientSearchResponse response = wr.results.get(-2)[0];
        System.assertEquals('The caller number field should be populated',response.errorMessage,'Error in phone validation');
    }
    /**
	* @Jira CC-1312
    * @description - Tests the invocation of the RIS patient search API. This method verifies the scenario when the phone number is not valid.
	**/
    @isTest
    private static void testInvokeRisPatientSearchApiWithInvalidPhNoSchEast(){   
        User radNetSchedulerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchApiWithInvalidPhNo(radNetSchedulerEast); 
        System.assertNotEquals(null, wr.payLoad, 'Payload Record is created');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        DH_DexOutServiceRisPatientSearchResponse response = wr.results.get(-1)[0];
        System.assertEquals('Patient information cannot be fetched because caller number is invalid',response.errorMessage,'Error in phone validation');
    }
    /**
	* @Jira CC-1312
    * @description - Tests the invocation of the RIS patient search API. This method verifies the scenario when the phone number is not valid.
	**/
    @isTest
    private static void testInvokeRisPatientSearchApiWithInvalidPhNoManWest(){   
        User radNetManagerWest = [SELECT ID, Username FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchApiWithInvalidPhNo(radNetManagerWest); 
        System.assertNotEquals(null, wr.payLoad, 'Payload Record is created');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        DH_DexOutServiceRisPatientSearchResponse response = wr.results.get(-1)[0];
        System.assertEquals('Patient information cannot be fetched because caller number is invalid',response.errorMessage,'Error in phone validation');
    }
    /**
	* @Jira CC-1312
    * @description - Tests the invocation of the RIS patient search API. This method verifies the scenario when the phone number is not valid.
	**/
    @isTest
    private static void testInvokeRisPatientSearchApiWithInvalidPhNoManEast(){   
        User radNetManagerEast = [SELECT ID, Username FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        wraperPayloadVsresult wr = testInvokeRisPatientSearchApiWithInvalidPhNo(radNetManagerEast); 
        System.assertNotEquals(null, wr.payLoad, 'Payload Record is created');
        System.assertNotEquals(null, wr.results, 'Response is recieved');
        DH_DexOutServiceRisPatientSearchResponse response = wr.results.get(-1)[0];
        System.assertEquals('Patient information cannot be fetched because caller number is invalid',response.errorMessage,'Error in phone validation');
    }
    /**
	* @Jira CC-430
    * @description - This class generates mock HTTP responses for the HTTP callouts made during testing. It allows simulating different scenarios
	**/
    @TestVisible
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        public HTTPResponse respond(HTTPRequest req) {
                HttpResponse finalResponse = new HttpResponse();
                finalResponse.setHeader('Content-Type', 'application/json');
                finalResponse.setStatusCode(200);
                finalResponse.setBody('[{"patientKey":"1964","firstName":"Amanda","lastName":"Ali","middleInitial":"","birthDate":"1984-02-09","mrn":"1964","address":"399WestWhiteClarendonFreewayLincoln,Nevada32527","phoneNumber":"(444)444-4444(primary)","emailAddress":"","systemID":"CA","openEMROrder":null,"openNonEMROrder":null,"lastPerformedExam":null,"nextScheduledExam":{"scheduledDate":"2016-03-09T13:00:00Z","examDescription":"MRBrainW[70552]-Head","requestedBy":"Jackson,Bob","modalityType":"MR","siteDescription":"Cedarville"},"groupingKey":"0","previousFirstName":"","previousLastName":"","lastContact":null},{"patientKey":"152339","firstName":"Magnus","lastName":"Magnusson","middleInitial":"","birthDate":"1986-02-09","groupingKey":"1"},{"patientKey":"1345639","firstName":"Magnus","lastName":"Magnusson","middleInitial":"","nextScheduledExam":{"scheduledDate":"2016-03-09T13:00:00Z","examDescription":"MRBrainW[70552]-Head","requestedBy":"Jackson,Bob","modalityType":"MR","siteDescription":"Cedarville"},"birthDate":"1994-03-09","groupingKey":"1"},{"patientKey":175393,"firstName":"Jayne","lastName":"ODell","middleInitial":"D","birthDate":"","mrn":"z40000009","address":"9HamptonDriveBerkeley,CA60163","phoneNumber":"(902)888-7610(primary)(mobile)(222)222-2222(333)333-3333(mobile)(444)444-4444(mobile)","emailAddress":"eradjayne@gmail.com","systemID":"CA","openEMROrder":{"requestedDate":"2021-01-18T13:46:38.4577503Z","orderedProcedures":"MRChestWo[71550]","requestedBy":"Adams,John"},"openNonEMROrder":{"requestedDate":"2023-09-07T19:59:36.1470967Z","emrCode":null,"requestedBy":"Chang,Henry","orderedProcedures":"BreastImagingtobeDetermined[BID]"},"lastPerformedExam":{"scheduledDate":"2023-09-07T17:36:00Z","examDescription":"MADigitalMammoScreenBilat[G0202]-Breast-Bilateral","requestedBy":"Chang,Henry","modalityType":"MA","siteDescription":"PineGrove"},"nextScheduledExam":{"scheduledDate":"2020-02-25T18:50:00Z","examDescription":"MRAbdomenW/Wo[74183]-Abdomen","requestedBy":"Adams,John","modalityType":"MR","siteDescription":"PineGrove"},"groupingKey":2,"previousFirstName":"","previousLastName":"ODell","lastContact":{"lastContactDate":"2023-07-12T16:18:04.670413Z","lastFollowUpTypeCode":"QuickMessageSMS","lastContactNotes":"test","orderedProcedures":"MRCervicalSpineW[72142]-Cervicalspine","requestedBy":"Adams,John"}}]');  
                return finalResponse;
            }
    }
    /**
	* @Jira CC-482
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