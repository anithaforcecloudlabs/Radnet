/*
* *******************************************************************************************************************************************
* Apex Class Name : DH_DexOutGeneralServiceTest
* Created Date : 25-July-2024
* Function : Test Class for DH_DexOutGeneralService class. 
* Modification Log :
* -------------------------------------------------------------------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-482-507               25-Jul-2024          Original Version.
* CC-1247                  04-Sep-2024          Added testWebCalloutUtilityDefaultError,testWebCalloutUtilityTimeOutError and HttpCalloutExceptionMock methods
* CC-520                   23-Sept-2024         Changes related to profile changes
* CC-482-507 			   10-Oct-2024			Added runTestWebCalloutUtility, runTestWebCalloutUtilityError,runTestWebCalloutUtilityErrorUrl,runTestWebCalloutUtilityDefaultError and runTestWebCalloutUtilityTimeOutError 
												methods and did changes related to code optimization and code coverage.
* *******************************************************************************************************************************************
*/
@isTest
public class DH_DexOutGeneralServiceTest {
    /**
	* @Jira CC-482-507 
    * @description - Creates reusable test data that can be used across multiple test methods within the same class.
	**/
    @testSetup
    public static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
		User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
		User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
		User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
    }
    /**
	* @Jira CC-482-507 
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API
    * @param - User
    * @return - DH_DexOutGeneralServiceResponse
	**/
    public static DH_DexOutGeneralServiceResponse runTestWebCalloutUtility(User userRec) { 
        DH_DexOutGeneralServiceResponse results;
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,true);
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisSearchPatientServiceSetting');
        DH_DexOutGeneralServiceRequest req = DH_TestDataFactory.createDexOutGeneralServiceRequest(wrapper, integrationSettingMetadata);
        HttpCalloutMock mock = new DH_DexOutServiceRisPatientSearchTest.MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);      
        System.runAs(userRec) {
            Test.startTest();
            results = DH_DexOutGeneralService.invokeWebCallout(req);
            Test.stopTest();
        } 
        return results;
    }
    /**
	* @Jira CC-482-507 
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API for Radnet Scheduler West.
	**/
    @isTest
    public static void testWebCalloutUtilitySchedulerWest() {   
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtility(radnetSchedulerWest);
        Assert.areEqual(true, results.statusCode==200,'Successful API call');
    }
    /**
	* @Jira CC-482-507 
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API for Radnet Scheduler East.
	**/
    @isTest
    public static void testWebCalloutUtilitySchedulerEast() {   
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtility(radnetSchedulerEast);
        Assert.areEqual(true, results.statusCode==200,'Successful API call');
    }
    /**
	* @Jira CC-482-507 
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API for Radnet Manager West.
	**/
    @isTest
    public static void testWebCalloutUtilityManagerWest() {   
        User radnetManagerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtility(radnetManagerWest);
        Assert.areEqual(true, results.statusCode==200,'Successful API call');
    }
    /**
	* @Jira CC-482-507 
    * @description - Tests the invocation of the RIS patient search API. This method verifies the successful retrieval of patient data from the API for Radnet Manager East.
	**/
    @isTest
    public static void testWebCalloutUtilityManagerEast() {   
        User radnetManagerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtility(radnetManagerEast);
        Assert.areEqual(true, results.statusCode==200,'Successful API call');
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout.
    * @param - User
    * @return - DH_DexOutGeneralServiceResponse
	**/
    public static DH_DexOutGeneralServiceResponse runTestWebCalloutUtilityError(User userRec) {   
        DH_DexOutGeneralServiceResponse results;
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,true);
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisSearchPatientServiceSetting');
        DH_DexOutGeneralServiceRequest req = DH_TestDataFactory.createDexOutGeneralServiceRequest(wrapper, integrationSettingMetadata);
        Test.setMock(HttpCalloutMock.class, new DH_DexOutServiceRisPatientSearchTest.MockHttpResponseGenerator());    
        System.runAs(userRec) {
            Test.startTest();
            results = DH_DexOutGeneralService.invokeWebCallout(req);
            Test.stopTest();
            Assert.areNotEqual(null, results,'Error occured in the invokeWebCallout');
        } 
        return results;
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout for Radnet Scheduler West
	**/
    @isTest
    public static void testWebCalloutUtilityErrorSchedulerWest() {   
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityError(radnetSchedulerWest);
        Assert.areNotEqual(null, results,'Error occured in the invokeWebCallout');
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout for Radnet Scheduler East.
	**/
    @isTest
    public static void testWebCalloutUtilityErrorSchedulerEast() {   
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityError(radnetSchedulerEast);
        Assert.areNotEqual(null, results,'Error occured in the invokeWebCallout');
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout for Radnet Manager West.
	**/
    @isTest
    public static void testWebCalloutUtilityErrorManagerWest() {   
        User radnetManagerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityError(radnetManagerWest);
        Assert.areNotEqual(null, results,'Error occured in the invokeWebCallout');    
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout for Radnet Manager East.
	**/
    @isTest
    public static void testWebCalloutUtilityErrorManagerEast() {   
        User radnetManagerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityError(radnetManagerEast);
        Assert.areNotEqual(null, results,'Error occured in the invokeWebCallout');  
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout
    * @param - User
    * @return - DH_DexOutGeneralServiceResponse
	**/
    public static DH_DexOutGeneralServiceResponse runTestWebCalloutUtilityErrorUrl(User userRec) { 
        DH_DexOutGeneralServiceResponse results;
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,true);
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisSearchPatientServiceSetting');
        DH_DexOutGeneralServiceRequest req = DH_TestDataFactory.createDexOutGeneralServiceRequest(wrapper, integrationSettingMetadata);
        HttpCalloutMock mock = new DH_DexOutServiceRisPatientSearchTest.MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);      
        System.runAs(userRec) {
            Test.startTest();
            results = DH_DexOutGeneralService.invokeWebCallout(req);
            Test.stopTest();
            Assert.areNotEqual(null, results,'Error occured in the invokeRisPatientSearchApi');
        } 
        return results;
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout for Radnet Scheduler West
	**/
    @isTest
    public static void testWebCalloutUtilityErrorUrlSchedulerWest() {   
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];  
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityErrorUrl(radnetSchedulerWest);
        Assert.areNotEqual(null, results,'Error occured in the invokeRisPatientSearchApi');
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout for Radnet Scheduler East
	**/
    @isTest
    public static void testWebCalloutUtilityErrorUrlSchedulerEast() {   
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityErrorUrl(radnetSchedulerEast);
        Assert.areNotEqual(null, results,'Error occured in the invokeRisPatientSearchApi');
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout for Radnet Manager West
	**/
    @isTest
    public static void testWebCalloutUtilityErrorUrlManagerWest() {   
        User radnetManagerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityErrorUrl(radnetManagerWest);
        Assert.areNotEqual(null, results,'Error occured in the invokeRisPatientSearchApi');
    }
    /**
	* @Jira CC-482-507
    * @description - Tests the failure senario for invokeWebCallout for Radnet Manager East
	**/
    @isTest
    public static void testWebCalloutUtilityErrorUrlManagerEast() {   
        User radnetManagerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastmanager@radnet.com' LIMIT 1];
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityErrorUrl(radnetManagerEast);
        Assert.areNotEqual(null, results,'Error occured in the invokeRisPatientSearchApi');
    }
    /**
	* @Jira CC-1247
    * @description - Tests the default exception senario for invokeWebCallout.
    * @param - User
    * @return - DH_DexOutGeneralServiceResponse
	**/
    public static DH_DexOutGeneralServiceResponse runTestWebCalloutUtilityDefaultError(User userRec) { 
        DH_DexOutGeneralServiceResponse results;
		DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,true);
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisSearchPatientServiceSetting');
        DH_DexOutGeneralServiceRequest req = DH_TestDataFactory.createDexOutGeneralServiceRequest(wrapper, integrationSettingMetadata);
        HttpCalloutMock mock = new DH_DexOutServiceRisPatientSearchTest.MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);      
        System.runAs(userRec) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutExceptionMock('undefined exception'));
            results = DH_DexOutGeneralService.invokeWebCallout(req);
            Test.stopTest();    
        } 
        return results;        
    }
    /**
	* @Jira CC-1247
    * @description - Tests the default exception senario for invokeWebCallout for Radnet Scheduler West
	**/
    @isTest
    public static void testWebCalloutUtilityDefaultErrorSchedulerWest() {   
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1]; 
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityDefaultError(radnetSchedulerWest);
        Assert.areEqual(true, results.statusCode==-100,'Response code is not -100');
    }
    /**
	* @Jira CC-1247
    * @description - Tests the default exception senario for invokeWebCallout for Radnet Scheduler East
	**/
    @isTest
    public static void testWebCalloutUtilityDefaultErrorSchedulerEast() {   
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityDefaultError(radnetSchedulerEast);
        Assert.areEqual(true, results.statusCode==-100,'Response code is not -100');
    }
    /**
	* @Jira CC-1247
    * @description - Tests the default exception senario for invokeWebCallout for Radnet Manager West
	**/
    @isTest
    public static void testWebCalloutUtilityDefaultErrorManagerWest() {   
        User radnetManagerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityDefaultError(radnetManagerWest);
        Assert.areEqual(true, results.statusCode==-100,'Response code is not -100');
    }
    /**
	* @Jira CC-1247
    * @description - Tests the default exception senario for invokeWebCallout for Radnet Manager East
	**/
    @isTest
    public static void testWebCalloutUtilityDefaultErrorManagerEast() {   
        User radnetManagerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityDefaultError(radnetManagerEast);
        Assert.areEqual(true, results.statusCode==-100,'Response code is not -100');
    }
    /**
	* @Jira CC-1247
    * @description - Tests the callout exception senario for invokeWebCallout.
    * @param - User
    * @return - DH_DexOutGeneralServiceResponse
	**/
    public static DH_DexOutGeneralServiceResponse runTestWebCalloutUtilityTimeOutError(User userRec) { 
        DH_DexOutGeneralServiceResponse results;
        DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true,true, true, true, true, true, true, true,true);
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisSearchPatientServiceSetting');
        DH_DexOutGeneralServiceRequest req = DH_TestDataFactory.createDexOutGeneralServiceRequest(wrapper, integrationSettingMetadata);
        HttpCalloutMock mock = new DH_DexOutServiceRisPatientSearchTest.MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);      
        System.runAs(userRec) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new HttpCalloutExceptionMock(DH_GlobalConstants.TIMEOUT_ERROR));
                results = DH_DexOutGeneralService.invokeWebCallout(req);
            Test.stopTest();    
        } 
        return results;
    }
    /**
	* @Jira CC-1247
    * @description - Tests the callout exception senario for invokeWebCallout for Radnet Scheduler West
	**/
    @isTest
    public static void testWebCalloutUtilityTimeOutErrorSchedulerWest() {   
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityTimeOutError(radnetSchedulerWest);
        Assert.areEqual(true, results.statusCode==-1,'Response code is not -1');
    }
    /**
	* @Jira CC-1247
    * @description - Tests the callout exception senario for invokeWebCallout for Radnet Scheduler East
	**/
    @isTest
    public static void testWebCalloutUtilityTimeOutErrorSchedulerEast() {   
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityTimeOutError(radnetSchedulerEast);
        Assert.areEqual(true, results.statusCode==-1,'Response code is not -1');
    }
    /**
	* @Jira CC-1247
    * @description - Tests the callout exception senario for invokeWebCallout for Radnet Manager West
	**/
    @isTest
    public static void testWebCalloutUtilityTimeOutErrorManagerWest() {   
        User radnetManagerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityTimeOutError(radnetManagerWest);
        Assert.areEqual(true, results.statusCode==-1,'Response code is not -1');
    }
    /**
	* @Jira CC-1247
    * @description - Tests the callout exception senario for invokeWebCallout for Radnet Manager East
	**/
    @isTest
    public static void testWebCalloutUtilityTimeOutErrorManagerEast() {   
        User radnetManagerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastmanager@radnet.com' LIMIT 1];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerEast);
        DH_DexOutGeneralServiceResponse results = runTestWebCalloutUtilityTimeOutError(radnetManagerEast);
        Assert.areEqual(true, results.statusCode==-1,'Response code is not -1');
    }
    /**
	* @Jira CC-1247
    * @description - generates the calloutException
	**/
    private class HttpCalloutExceptionMock implements HttpCalloutMock {
        private String errorMsg;
        public HttpCalloutExceptionMock(String errorMsg) {
            this.errorMsg = errorMsg;
        }
        public HttpResponse respond(HttpRequest req) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage(errorMsg);
        throw e;
        }   
    }
}