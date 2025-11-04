/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServicePatientEngagementTest
* Created Date : 30-Jun-2024 
* @description : Test class for DH_DexOutServicePatientEngagement.
* Modification Log :
* ---------------------------------------------------------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-702                   30-Jun-2024          Added testInvokePatientEngagementApi,testInvokePatientEngagementApiError,
                                                DH_DexOutServicePatientEngagementMock methods.
* CC-430                   30-Jun-2024          Added testInvokePatientEngagementApiWithNull method.
* CC-1204                  10-Sep-2024          Updated DH_DexOutServicePatientEngagementMock,testInvokePatientEngagementApiError,
                                                testInvokePatientEngagementApiWithNull and setup,Added testInvokePatientEngagementApiWestSch,
                                                testInvokePatientEngagementApiEastSch,,testInvokePatientEngagementApiEastManager
* CC-527                   23-Sep-2024          Changes related to PMD issues.
* CC-702				   08-October-2024		Changes related to code optimization and code coverage.
* **********************************************************************************************************************************
*/
@IsTest
public class DH_DexOutServicePatientEngagementTest {

    @testSetup
    static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
        User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
        User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
        RecordType rt=[Select Id From RecordType where Name = 'Person Account' and SobjectType = 'Account'];
        Account testAccount = DH_TestDataFactory.createAccount('EngagementControllerTest','Acc','CA',rt.Id);
        testAccount.DH_Patient_Key__c = '175472';
        testAccount.Region__c = 'CA';
        insert testAccount;
        List<Account> accList = DH_TestDataFactory.createPatientRecord();
    }
    /**
	* @Jira CC-702
    * @description - Added runTestInvokePatientEngagementApi to test api invoke for All users.
    * @param       - User
    * @return      - DH_DexOutServiceEngagementResponse
	**/
    static List<DH_DexOutServiceEngagementResponse> runTestInvokePatientEngagementApi(User userToRun) {
        List<DH_DexOutServiceEngagementResponse> engagementList;
        HttpCalloutMock mock = new DH_DexOutServicePatientEngagementMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Account testAccount = new Account();
        if(userToRun.DH_User_Region__c == 'East'){
        	testAccount = [SELECT Id,firstName,DH_Patient_Key__c,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account' LIMIT 1];
        }else{
			testAccount = [SELECT Id,firstName,DH_Patient_Key__c,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account' LIMIT 1];
        }
        System.runAs(userToRun) {
            DH_DexOutServiceEngagementRequest engageWrapper = new DH_DexOutServiceEngagementRequest();
            engageWrapper.patientKey = testAccount.DH_Patient_Key__c;
            engageWrapper.systemId = testAccount.Region__c;
            engageWrapper.recordId = testAccount.Id;
            Test.startTest();
            engagementList = DH_DexOutServicePatientEngagement.invokePatientEngagementApi(engageWrapper);
            Test.stopTest();
        }
        return engagementList;
    }
    /**
	* @Jira CC-702
    * @description - Added testInvokePatientEngagementApiWestSch to test api invoke for west scheduler.
	**/
    @IsTest
    public static void testInvokePatientEngagementApiWestSch() {
        User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        List<DH_DexOutServiceEngagementResponse> engagementList = runTestInvokePatientEngagementApi(radnetSchedulerWest);
        System.assertEquals(3, engagementList.size(),'Count of response dosent match');
        System.assertEquals('53768', engagementList[0].uniqueID,'Unique id dosent match');
        System.assertEquals('test', engagementList[0].subject,'Subject dosent match');
        System.assertEquals('stick sent this message', engagementList[0].description,'Description dosent match');
        System.assertEquals('standard:feedback', engagementList[0].iconVariant,'Icon varient dosent match');
    }
        /**
	* @Jira CC-702
    * @description - Added testInvokePatientEngagementApiEastSch to test api invoke for East Scheduler.
	**/
    @IsTest
    public static void testInvokePatientEngagementApiEastSch() {
        User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        List<DH_DexOutServiceEngagementResponse> engagementList = runTestInvokePatientEngagementApi(radnetSchedulerEast);
        System.assertEquals(3, engagementList.size(),'Count of response dosent match');
        System.assertEquals('53768', engagementList[0].uniqueID,'Unique id dosent match');
        System.assertEquals('test', engagementList[0].subject,'Subject dosent match');
        System.assertEquals('stick sent this message', engagementList[0].description,'Description dosent match');
        System.assertEquals('standard:feedback', engagementList[0].iconVariant,'Icon varient dosent match');
    }
    /**
	* @Jira CC-702
    * @description - Added testInvokePatientEngagementApiWestManager to test api invoke for west manager.
	**/
    @IsTest
    public static void testInvokePatientEngagementApiWestManager() {
        User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);
		List<DH_DexOutServiceEngagementResponse> engagementList = runTestInvokePatientEngagementApi(radnetManagerWest);
        System.assertEquals(3, engagementList.size(),'Count of response dosent match');
        System.assertEquals('53768', engagementList[0].uniqueID,'Unique id dosent match');
        System.assertEquals('test', engagementList[0].subject,'Subject dosent match');
        System.assertEquals('stick sent this message', engagementList[0].description,'Description dosent match');
        System.assertEquals('standard:feedback', engagementList[0].iconVariant,'Icon varient dosent match');
    }
        /**
	* @Jira CC-702
    * @description - Added testInvokePatientEngagementApiEastManager to test api invoke for east manager.
	**/
    @IsTest
    public static void testInvokePatientEngagementApiEastManager() {
        User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerEast);
		List<DH_DexOutServiceEngagementResponse> engagementList = runTestInvokePatientEngagementApi(radnetManagerEast);
        System.assertEquals(3, engagementList.size(),'Count of response dosent match');
        System.assertEquals('53768', engagementList[0].uniqueID,'Unique id dosent match');
        System.assertEquals('test', engagementList[0].subject,'Subject dosent match');
        System.assertEquals('stick sent this message', engagementList[0].description,'Description dosent match');
        System.assertEquals('standard:feedback', engagementList[0].iconVariant,'Icon varient dosent match');
    }
    /**
	* @Jira CC-430
    * @description - Added testInvokePatientEngagementApi to test api invoke with null values.
	**/
    @IsTest
    public static void testInvokePatientEngagementApiWithNull() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
        List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
        Account eastAccount = [SELECT Id,firstName,DH_Patient_Key__c,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account'];
		Account westAccount = [SELECT Id,firstName,DH_Patient_Key__c,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account'];
        Account testAccount = new Account();
        Test.startTest();
        for(User u: userList){
            if(u.DH_User_Region__c == 'East'){
                testAccount = eastAccount;
            }else{
                testAccount = westAccount;
            }
            System.runAs(u) {
                Test.setMock(HttpCalloutMock.class, new DH_DexOutServicePatientEngagementMock());
                DH_DexOutServiceEngagementRequest engageWrapper = new DH_DexOutServiceEngagementRequest();
                engageWrapper.patientKey = testAccount.DH_Patient_Key__c;
                engageWrapper.systemId = null;
                engageWrapper.recordId = testAccount.Id;
                List<DH_DexOutServiceEngagementResponse> engagementList = DH_DexOutServicePatientEngagement.invokePatientEngagementApi(engageWrapper);
                DH_PayloadData__c payLoad = [SELECT Id, DH_ResponseCode__c, DH_ClassName__c FROM DH_PayloadData__c LIMIT 1];
                System.assertNotEquals(null, payLoad, 'test is successfull');
            }
        }
        Test.stopTest();   
    }
    /**
	* @Jira CC-702
    * @description - Added testInvokePatientEngagementApiError to get the bad api invoke.
	**/
    @IsTest
    public static void testInvokePatientEngagementApiError() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
        List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
        Account eastAccount = [SELECT Id,firstName,DH_Patient_Key__c,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account'];
		Account westAccount = [SELECT Id,firstName,DH_Patient_Key__c,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account'];
        Account testAccount = new Account();
        Test.startTest();
        for(User u: userList){
            if(u.DH_User_Region__c == 'East'){
                testAccount = eastAccount;
            }else{
                testAccount = westAccount;
            }
            System.runAs(u) {
                HttpCalloutMock mock = new DH_DexOutServiceRisPatientSearchTest.MockHttpResponseErrorGenerator(400);
                Test.setMock(HttpCalloutMock.class, mock);
                DH_DexOutServiceEngagementRequest engageWrapper = new DH_DexOutServiceEngagementRequest();
                engageWrapper.patientKey = testAccount.DH_Patient_Key__c;
                engageWrapper.systemId = testAccount.Region__c;
                engageWrapper.recordId = testAccount.Id;
                List<DH_DexOutServiceEngagementResponse> engagementList = DH_DexOutServicePatientEngagement.invokePatientEngagementApi(engageWrapper);
                System.assertEquals(1, engagementList.size(),'error not triggred');
            }
        }
        Test.stopTest();
    }
    /**
	* @Jira CC-702
    * @description - Added DH_DexOutServicePatientEngagementMock cllas to get mook response.
	**/
    private class DH_DexOutServicePatientEngagementMock implements HttpCalloutMock {
        private HttpResponse response;
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            DateTime currentDateTime = DateTime.now(); 
            String formattedDateTime = currentDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            res.setBody('[ [{"order_key": 53768, "notes": "test", "contact_date": "'+formattedDateTime+'", "last_updated_by_user_id": "stick", "follow_up_type_code": "QuickMessageSMS"}, {"order_key": 53778, "notes": "asefasdf", "contact_date": "'+formattedDateTime+'", "last_updated_by_user_id": "stick", "follow_up_type_code": "QuickMessageSMS"}, {"order_key": 53766, "notes": "Thank you for choosing Treesdale Radiology. Unfortunately, we are running behind today. Feel free to arrive 1/2 hour later than your scheduled appointment time.", "contact_date": "'+formattedDateTime+'", "last_updated_by_user_id": "stick", "follow_up_type_code": "QuickMessageSMS"}] ]');
            return res;
        }
    }
}