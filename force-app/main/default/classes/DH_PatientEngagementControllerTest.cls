/*
* ***************************************************************************************************************************
* Apex Class Name : DH_PatientEngagementControllerTest
* Created Date : 30-Jun-2024 
* @description : Test class for DH_PatientEngagementController.
* Modification Log :
* ---------------------------------------------------------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-702                   30-June-2024         Added testGetPatientEngagement methods.
* CC-1154                  23-August-2024       Created the test data required for upfates
* CC-1204                  13-Sepeptember-2024  Updated all test methods.
* CC-702                   24-Sepeptember-2024  Changes related to engagement interaction record creation.
* CC-702				   08-October-2024		Changes related to code optimization and code coverage.
* **********************************************************************************************************************************
*/
@isTest
public class DH_PatientEngagementControllerTest {
    /**
	* @Jira CC-702
    * @description - Creates reusable test data that can be used across multiple test methods within the same class.
	**/
    @testSetup
    static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
        User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
        User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
        User radnetMarketingUser = DH_TestDataFactory.createRadNetMarketingUser(); 
		List<Account> accList = DH_TestDataFactory.createPatientRecord();
        VoiceCall voiceCall1 = DH_TestDataFactory.createVoiceCallRecord('+1578782168','+1649693498', '+1649693498', 'ContactCenter',datetime.now(),datetime.now(),'Inbound','CA');
        voiceCall1.CallDisposition = DH_GlobalConstants.COMPLETED;
        insert voiceCall1;
        VoiceCall vc =DH_TestDataFactory.updateVoiceCallRecord(voiceCall1.Id,accList[0].ID);
        Update vc;
        VoiceCall voiceCall2 = DH_TestDataFactory.createVoiceCallRecord('+1578782168','+1649693498', '+1649693498', 'ContactCenter',datetime.now(),datetime.now(),'Inbound','CA');
        voiceCall2.CallDisposition = DH_GlobalConstants.COMPLETED;
        insert voiceCall2;
        VoiceCall vc2 =DH_TestDataFactory.updateVoiceCallRecord(voiceCall2.Id,accList[2].ID);
        Update vc2;
    }
    /**
	* @Jira CC-702
    * @description - Created testGetPatientEngagement methods to covere coverage of GetPatientEngagement.
	**/
    @isTest
    static void testGetPatientEngagement() {
        Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
        User radnetMarketingUser = [SELECT ID, Username FROM USER WHERE Email='marketingUser@PatientEngagementControllerTest.com' limit 01];
        DH_TestDataFactory.assignMarketingPermissionSet(radnetMarketingUser.Id);
        Account eastAccount = [SELECT Id,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account'];
		Account westAccount = [SELECT Id,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account'];
        System.runAs(radnetMarketingUser) {
            DH_TestDataFactory.createFixedEngagementInteractionRecords(eastAccount.Id,eastAccount.Region__c);
            DH_TestDataFactory.createFixedEngagementInteractionRecords(westAccount.Id,westAccount.Region__c);
        }
        Test.startTest();
            List<DH_DexOutServiceEngagementResponse> engagementList= new List<DH_DexOutServiceEngagementResponse>();
            List<EngagementInteraction> eastEgList = [SELECT Id, Reason, DH_Content_Body__c, StartDateTime, CommunicationChannel, DH_Account__c, DH_ResponseToMessageTrackingId__c, DH_MessageTrackingId__c, Type FROM EngagementInteraction WHERE DH_Account__c = :eastAccount.Id];
            List<EngagementInteraction> westEgList = [SELECT Id, Reason, DH_Content_Body__c, StartDateTime, CommunicationChannel, DH_Account__c, DH_ResponseToMessageTrackingId__c, DH_MessageTrackingId__c, Type FROM EngagementInteraction WHERE DH_Account__c = :westAccount.Id];
            for(User u: userEastMap.values()){
                System.runAs(u) { 
                    String result = DH_PatientEngagementController.getPatientEngagementList(eastAccount.Id);
                    engagementList =(List<DH_DexOutServiceEngagementResponse>) JSON.deserialize(result, List<DH_DexOutServiceEngagementResponse>.class);
                }
                engagementList.addAll(DH_DexOutServicePatientEngagementParser.constructEngagmentData(eastEgList));
                System.assertNotEquals(null, engagementList);
                System.assert(engagementList.size() > 0, 'Engagement list should not be empty');
            }
            for(User u: userWestMap.values()){
                System.runAs(u) {
                    String result = DH_PatientEngagementController.getPatientEngagementList(westAccount.Id);
                    engagementList =(List<DH_DexOutServiceEngagementResponse>) JSON.deserialize(result, List<DH_DexOutServiceEngagementResponse>.class);
                }
                engagementList.addAll(DH_DexOutServicePatientEngagementParser.constructEngagmentData(westEgList));
                System.assertNotEquals(null, engagementList);
                System.assert(engagementList.size() > 0, 'Engagement list should not be empty');
            }
        Test.stopTest();
    }
}