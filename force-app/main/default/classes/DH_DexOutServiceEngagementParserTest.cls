/*
* **********************************************************************************************************************************
* Apex Class Name : DH_DexOutServiceEngagementParserTest
* Created Date : 30-Jun-2024 
* @description : Test class for DH_DexOutServiceEngagementParser.
* Modification Log :
* ----------------------------------------------------------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-702                   30-June-2024          Added testGetEngagementList methods.
* CC-1204                  10-September-2024     Added testConstructEngagmentData, updated testGetEngagementList and setup.
* CC-527                   23-September-2024     Changes related to PMD issues.
* CC-702				   08-October-2024		 Changes related to code optimization and code coverage.
* **********************************************************************************************************************************
*/

@isTest
public class DH_DexOutServiceEngagementParserTest {
    /**
	* @Jira CC-702
    * @description - Creates reusable test data that can be used across multiple test methods within the same class.
	**/
    @testSetup
    public static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
        User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
        User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
        User radnetMarketingUser = DH_TestDataFactory.createRadNetMarketingUser();
		List<Account> accList = DH_TestDataFactory.createPatientRecord();
    }
    /**
	* @Jira CC-702
    * @description - Method to test the GetEngagementList method based on diff accounts and users.
	**/
    @isTest
    static void testGetEngagementList() {
        Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
        DH_IntegrationSetting__mdt quickMessageSettings = DH_IntegrationSetting__mdt.getInstance('DH_RisQuickMessageServiceSetting');
        Test.startTest();
            List<DH_DexOutServiceEngagementResponse> engagementList=runTestGetEngagementList(userEastMap.values());
            List<DH_DexOutServiceEngagementResponse> engagementList1=runTestGetEngagementList(userWestMap.values());
        Test.stopTest();
        System.assertEquals(3, engagementList.size(),'Count of response dosent match');
        System.assertEquals('53768', engagementList[0].uniqueID,'Unique id dosent match');
        System.assertEquals('test', engagementList[0].subject,'Subject dosent match');
        System.assertEquals('stick sent this message', engagementList[0].description,'Description dosent match');
        System.assertEquals(3, engagementList1.size(),'Count of response dosent match');
        System.assertEquals('53768', engagementList1[0].uniqueID,'Unique id dosent match');
        System.assertEquals('test', engagementList1[0].subject,'Subject dosent match');
        System.assertEquals('stick sent this message', engagementList1[0].description,'Description dosent match');
    }
    /**
	* @Jira CC-702
    * @description - Method to run testGetEngagementList the GetEngagementList method.
    * @param       - List<User>
    * @return      - DH_DexOutServiceEngagementResponse
	**/
    static List<DH_DexOutServiceEngagementResponse> runTestGetEngagementList(List<User> userList) {
        DateTime currentDateTime = DateTime.now(); 
        String formattedDateTime = currentDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String formattedDateTime1 = currentDateTime.addDays(-2).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String quickMessageResponse = '[ [{"order_key": 53768, "notes": "test", "contact_date": "'+formattedDateTime+'", "last_updated_by_user_id": "stick", "follow_up_type_code": "QuickMessageSMS"}, {"order_key": 53778, "notes": "asefasdf", "contact_date": "'+formattedDateTime1+'", "last_updated_by_user_id": "stick", "follow_up_type_code": "QuickMessageSMS"}, {"order_key": 53766, "notes": "Thank you for choosing Treesdale Radiology. Unfortunately, we are running behind today. Feel free to arrive 1/2 hour later than your scheduled appointment time.", "contact_date": "'+formattedDateTime+'", "last_updated_by_user_id": "stick", "follow_up_type_code": "QuickMessageSMS"}] ]';
        List<DH_DexOutServiceEngagementResponse> engagementList=new List<DH_DexOutServiceEngagementResponse>();
        for(User u: userList){
            System.runAs(u) {
                engagementList= DH_DexOutServicePatientEngagementParser.getEngagementList(quickMessageResponse);
                engagementList.sort();
            }
        }
        return engagementList;
    }
    /**
	* @Jira CC-702
    * @description - Method to test the GetEngagementList method.
	**/
    @isTest
    static void testConstructEngagmentData() {
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
        List<DH_DexOutServiceEngagementResponse> engagementList=runTestConstructEngagmentData(userEastMap.values(),eastAccount.Id);
        List<DH_DexOutServiceEngagementResponse> engagementList1=runTestConstructEngagmentData(userWestMap.values(),westAccount.Id);
        Test.stopTest();
        System.assertEquals(4, engagementList.size(),'List count dosent match');
        System.assertEquals(4, engagementList1.size(),'List1 count dosent match');
    }
    /**
	* @Jira CC-702
    * @description - Method to run testConstructEngagmentData method based on diff accounts and users.
    * @param       - List<User>, Id
    * @return      - DH_DexOutServiceEngagementResponse
	**/
    static  List<DH_DexOutServiceEngagementResponse> runTestConstructEngagmentData(List<User> userList,Id accId) {
        List<DH_DexOutServiceEngagementResponse> engagementList=new List<DH_DexOutServiceEngagementResponse>();
        for(User u: userList){
            System.runAs(u) {
                List<EngagementInteraction> egList = [SELECT Id, Reason, DH_Content_Body__c, StartDateTime, CommunicationChannel, DH_Account__c, DH_ResponseToMessageTrackingId__c, DH_MessageTrackingId__c, Type FROM EngagementInteraction WHERE DH_Account__c = :accId];
                engagementList=DH_DexOutServicePatientEngagementParser.constructEngagmentData(egList);
                
            }
        }
        return engagementList;
    }
}