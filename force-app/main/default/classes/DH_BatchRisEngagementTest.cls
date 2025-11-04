/*
* ***************************************************************************************************************************
* Apex Class Name : DH_BatchRisEngagementTest
* Created Date : 30-August-2024 
* @description : Test Class for DH_BatchRisEngagementTest
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-491                   30-August-2024       Added setup,testInvokeOfBatchClass,testInvokeOfSchedularClass,testInvokeOfBatchClassApi,testInvokeOfBatchClassApiError methods.
* *****************************************************************************************************************************************************************************
*/
@isTest
public class DH_BatchRisEngagementTest {
    public Static String res;
    /**
	* @Jira CC-491
    * @description - Creates reusable test data that can be used across multiple test methods within the same class.
	**/
    @testSetup
    public static void setup() {
        Account acc = DH_TestDataFactory.createAccount('Test','AccountTwo','CA',DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        Account acc2 = DH_TestDataFactory.createAccount('Test','AccountTwo','FL',DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc2;
        Account acc3 = DH_TestDataFactory.createAccount('Test','AccountThree','AZ',DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc3;
        Account acc4 = DH_TestDataFactory.createAccount('Test','AccountThree','AZ',DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc4;
        ClinicalServiceRequest csr = new ClinicalServiceRequest();
        csr.DH_Order_Key__c = '974375';
        csr.PatientId = acc.Id;
        csr.Type = 'Option';
        csr.DH_RIS_OrderKey__c = '123';
        insert csr;
        List<EngagementInteraction> eIList = new List<EngagementInteraction>();
        EngagementInteraction eI1 = DH_TestDataFactory.createEiRec('1','3445','DH_Email','test34@gmail.com','2752','167776','Test Email Sent','',acc.Id,csr.Id);
        eIList.add(eI1);
        EngagementInteraction eI2 = DH_TestDataFactory.createEiRec('2','3344','DH_Email','test367@gmail.com','2753','127772','Test Email Sent Two','',acc.Id,csr.Id);
        eIList.add(eI2);
        EngagementInteraction eI3 = DH_TestDataFactory.createEiRec('1','3445','DH_SMS','','167776','','','Test SMS Sent',acc3.Id,csr.Id);
        eIList.add(eI3);
        EngagementInteraction eI4 = DH_TestDataFactory.createEiRec('2','3344','DH_SMS','','127772','','','Test SMS Sent Two',acc4.Id,csr.Id);
        eIList.add(eI4);
        insert eIList;
        List<et4ae5__Automated_Send__c> triggerSendList = new List<et4ae5__Automated_Send__c>();
        et4ae5__Automated_Send__c triggerSend1 = DH_TestDataFactory.creatTriggerSend('2752');
        triggerSendList.add(triggerSend1);
        et4ae5__Automated_Send__c triggerSend2 = DH_TestDataFactory.creatTriggerSend('2753');
        triggerSendList.add(triggerSend2);
        insert triggerSendList;
        List<et4ae5__IndividualEmailResult__c> ierList = new List<et4ae5__IndividualEmailResult__c>();
        et4ae5__IndividualEmailResult__c ier1 = DH_TestDataFactory.creatIER('1','2752','167776','3445',5,triggerSend1.Id);
        ierList.add(ier1);
        et4ae5__IndividualEmailResult__c ier2 = DH_TestDataFactory.creatIER('2','2752','167776','3445',5,triggerSend1.Id);
        ierList.add(ier2);
        et4ae5__IndividualEmailResult__c ier3 = DH_TestDataFactory.creatIER('1','2753','127772','3344',6,triggerSend1.Id);
        ierList.add(ier3);
        et4ae5__IndividualEmailResult__c ier4 = DH_TestDataFactory.creatIER('2','2753','127772','3344',6,triggerSend1.Id);
        ierList.add(ier4);
        insert ierList;
        User radnetBatchSchedulerUser = DH_TestDataFactory.createRadNetBatchSchedulerUser();
    }
    /**
	* @Jira CC-491
    * @description - Tests the invocation of the batch class DH_BatchRisEngagement.
	**/
    @isTest
    public static void testInvokeOfBatchClass(){   
        User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);
        ID batchprocessid;
        Test.StartTest();
        System.runAs(radnetBatchSchedulerUser) {
        		DH_BatchRisEngagement risEng = new DH_BatchRisEngagement();
       	 		batchprocessid = Database.executeBatch(risEng,4);
        }
        Test.StopTest();
        System.assertNotEquals(null, batchprocessid, 'Batch class has not been properly called');
    }
    /**
	* @Jira CC-491
    * @description - Tests the invocation of the schedular class DH_BatchRisEngagementScheduler.
	**/
    @isTest
    public static void testInvokeOfSchedularClass(){  
        User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);
        Test.StartTest();
            System.runAs(radnetBatchSchedulerUser) {
                DH_BatchRisEngagementScheduler.scheduleMe();
                List<CronTrigger> cronTriggers = [SELECT Id, CronJobDetailId FROM CronTrigger];
                System.assertNotEquals(null,cronTriggers[0].CronJobDetailId, 'Batch class is executed');
            }        
        Test.StopTest();
    }
    /**
	* @Jira CC-491
    * @description - Tests the invocation of the batch class HC to RIS api callout.
	**/
    @isTest
    public static void testInvokeOfBatchClassApi(){  
        User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);
        
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);
        ID batchprocessid;
        Test.StartTest();
        System.runAs(radnetBatchSchedulerUser) {
            DH_BatchRisEngagement risEng = new DH_BatchRisEngagement();
        	batchprocessid = Database.executeBatch(risEng,4);
        }
        Test.StopTest();
        System.assertNotEquals(null, batchprocessid, 'Batch class has not been properly called');
        List<DH_PayloadData__c> payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c];
        System.assertNotEquals(null, payLoad, 'Payload record is created');
    }
    /**
	* @Jira CC-491
    * @description - Tests the invocation of the batch class HC to RIS api callout.
	**/
    @isTest
    public static void testInvokeOfBatchClassApiError(){   
        User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);
        
        HttpCalloutMock mock = new MockHttpResponseErrorGenerator(500);
        Test.setMock(HttpCalloutMock.class, mock);  
        
        ID batchprocessid;
        Test.StartTest();
        System.runAs(radnetBatchSchedulerUser) {
        	DH_BatchRisEngagement risEng = new DH_BatchRisEngagement();
    		batchprocessid = Database.executeBatch(risEng,4);
        }
        Test.StopTest();
        System.assertNotEquals(null, batchprocessid, 'Batch class has not been properly called');
        List<DH_PayloadData__c> payLoad = [SELECT Id, DH_ResponseCode__c FROM DH_PayloadData__c];
        System.assertNotEquals(null, payLoad, 'Payload record is created');
    }
    /**
	* @Jira CC-491
    * @description - This class generates mock HTTP responses for the HTTP callouts made during testing. It allows simulating different scenarios
	**/
    @TestVisible
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        public HTTPResponse respond(HTTPRequest req) {
                HttpResponse finalResponse = new HttpResponse();
                finalResponse.setHeader('Content-Type', 'application/json');
                finalResponse.setStatusCode(200);
                finalResponse.setBody('[[{"SfId": "0u3Va00000007pVIAQ","ProcessedFlag": true},{"SfId": "0u3Va00000007pWIAQ","ProcessedFlag": true},{"SfId": "0u3Va00000007pXIAQ","ProcessedFlag": true},{"SfId": "0u3Va00000007pYIAQ","ProcessedFlag": true}]]');  
                return finalResponse;
            }
    }
    /**
	* @Jira CC-491
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