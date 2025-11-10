/*
* ***************************************************************************************************************************
* Apex Class Name - DH_CaseTriggerHeplerTest
* Created Date - 24-July-2024
* @description : Test Class for DH_CaseTriggerHandler and DH_CaseTriggerHepler.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       --------------------------------------------
* CC-526                   24-July-2024         Added setup and updateCaseSystemIdTest methods.
* CC-1204                  12-September-2024    Updated updateCaseSystemIdTest method.
* CC-526                   24-September-2024    Updated scope of Test.startTest in updateCaseSystemIdTest method
* CC-526                   07-October-2024     	Changes related to code optimization and code coverage.
* *****************************************************************************************************************************
*/
@isTest
public class DH_CaseTriggerHeplerTest {
    /**
	* @Jira CC-526
    * @description - Creates reusable test data that can be used across multiple test methods within the same class.
    * @param       - None
	**/
    @testSetup
    public static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
        User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
        User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();   
        Account acc = DH_TestDataFactory.createAccount('Test','AccountTwo','CA',DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        Case caseRec = DH_TestDataFactory.createCase('Test Case Created One',acc.Id);
        insert caseRec;
    } 
    /**
	* @Jira CC-526
    * @description - Tests the invocation of the updateCaseSystemIdTest which will update the Sytem Id of the Case record.
    * @param       - None
	**/
    @isTest
    private static void updateCaseSystemIdTest() {
        Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
        Case caseRec = runUpdateCaseSystemIdTest(userEastMap.values());
        Case caseRec1 = runUpdateCaseSystemIdTest(userWestMap.values());
		Test.stopTest();
        System.assertNotEquals(null, caseRec,'Error occurred while creating Case record');
        System.assertNotEquals(null, caseRec1,'Error occurred while creating Case record');
    }
    /**
	* @Jira CC-526
    * @description - Method which covers the common code for both east and west users.
    * @param       - List
    * @return      - Case
	**/
    public static Case runUpdateCaseSystemIdTest(List<User> userList) {
        Account accRec= [SELECT ID FROM Account WHERE LastName = 'AccountTwo' LIMIT 1];
        Case caseRecord= [SELECT ID,DH_SystemId__c,Description,AccountId FROM Case WHERE AccountId =: accRec.Id LIMIT 1];
        for (User userRec : userList) {
			System.runAs(userRec) {
                System.assertEquals('CA', caseRecord.DH_SystemId__c,'Error occurred while creating Case Record');
			}
		}
        return caseRecord;
    }

        /**
	* @Jira CC-29
    * @description - Method which covers the Entitlement code.
    * @param       - None
    * @return      - void
	**/
    @isTest
    public static void caseEntitlemtMatchingAccountTest(){
       
        Account acc = [Select Id from Account Limit 1];
        acc.DH_Contact_Point_Email__c = 'example@gmail.com';
        acc.DH_Contact_Point_Phone__c = '8964549354';
        update acc;

        Entitlement entl = new Entitlement(Name='TestEntitlement', AccountId=acc.Id);
        insert entl;

        Case caseRec = DH_TestDataFactory.createCase('Test Case Created One',acc.Id);
        caseRec.Origin = 'Chat';
        caseRec.Inquiry_Type__c = 'BillingInquiry';
        caseRec.Phone__C = '8964549354';
        caseRec.Email__C = 'example@gmail.com';
        caseRec.Status = 'In Progress';
        caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Chat Support Case').getRecordTypeId();
        caseRec.EntitlementId = entl.Id;
        Insert caseRec;

        Test.startTest();
        caseRec.Status = 'Closed';
        update caseRec;
        Test.stopTest();
    }

    /**
	* @Jira CC-29
    * @description - Method which covers the Entitlement code.
    * @param       - None
    * @return      - void
	**/
    @isTest
     public static void caseEntitlemtNotMatchingAccountTest(){

        Test.startTest();
        Case caseRec = DH_TestDataFactory.createCase('Test Case Created One', null);
        caseRec.Origin = 'Chat';
        caseRec.Inquiry_Type__c = 'BillingInquiry';
        caseRec.Phone__C = '8964549354';
        caseRec.Status = 'In Progress';
        caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Chat Support Case').getRecordTypeId();
        Insert caseRec;
        Test.stopTest();
    }
}