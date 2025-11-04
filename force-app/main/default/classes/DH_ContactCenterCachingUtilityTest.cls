/*
 * ***************************************************************************************************************************
 * Apex Class Name - DH_ContactCenterCachingUtilityTest
 * Created Date - 29-July-2024
 * @description : Test Class for DH_ContactCenterCachingUtility. 
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-505                   06-August-2024       Added setup,getUsersMapTest and getUsersMapTestTwo methods.
 * CC-702                   30-July-2024         Added getEngagementDetailsTest,getCallHistoryDetailsTest methods.
 * CC-940                   20-August-2024       Added getUniqueKeyVsAccountMapTest method
 * CC-691                   20-August-2024       Added getCaseMapTest method
 * CC-633                   21-August-2024       Added getContactPhoneMapTest and getContactPhoneMapTestTwo methods
 * CC-664                   21-August-2024       Added getContactEmailMapTest and getContactEmailMapTestTwo methods
 * CC-526                   29-July-2024         Added setup,getAccountsMapTest,getAccountsMapTestTwo,getVoiceListTestTwo,getVoiceListTest,getGroupListTest and getGroupTest methods.
 * CC-520				    18-August-2024		 Added getEmailTemplateMapTest,getEmailTemplateList and TestgetEmailTemplateMapNullTest methods
 * CC-572                   22-August-2024       Added getPayloadMapTest method
 * CC-1203                  12-September-2024    Updated all existing methods related to Profile changes and added getPermissionSetMapTest method
 * CC-1204			        13-September-2024	 Added getPermissionSetGroupMapTest and getProfileNameVsProfileMapTest method
 * CC-491				    18-September-2024	 Added getIerMapTest,getIerMapTestTwo,getEiMapTest and getEiMapTestTwo methods
 * 							25-September-2024 	 Added getEastUsers,getWestUsers methods.
 * CC-603                   08-Oct-2024          Added runValidateGetAccountsMap,runValidateGetEngagementDetails,runValidateCallHistoryDetailsTest,runGetGroupListTest,runValidateGetVoiceListTest,
 *                                               runGetUsersMapTest,runGetUsersMapTestTwo,runGetUniqueKeyVsAccountMapTest,runGetCaseMapTest,runGetContactPhoneMapTest,runGetContactPhoneMapTestTwo,
 *                                               runGetContactEmailMapTest,runGetContactEmailMapTestTwo,runGetEmailTemplateMapTest,runGetPayloadMapTest,runGetPermissionSetMapTest,runGetPermissionSetGroupMapTest,
 *                                               runGetProfileNameVsProfileMapTest and did changes related to code optimization and code coverage 
 * CC-1439                  30-Oct-2024			 Replaced all instances of FromPhoneNumber with F9_Call_ANI__c
 * ***********************************************************************************************************************************************
 */

@isTest
public class DH_ContactCenterCachingUtilityTest {
	/**
	 * @Jira CC-526
	 * @description - Creates reusable test data that can be used across multiple test methods within the same class.
	 * @param       - None
	 **/
	public static Integer queryCount;
	@testSetup
	public static void setup() {
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
		User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
		User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetBatchSchedulerUser = DH_TestDataFactory.createRadNetBatchSchedulerUser();
		List<Account> accList = DH_TestDataFactory.createPatientRecord();
		List<VoiceCall> voiceCallList = new List<VoiceCall>();
		VoiceCall voiceCallRecord1 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498','+1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', null);
		voiceCallRecord1.RelatedRecordId = accList[0].id;
		voiceCallList.add(voiceCallRecord1);
		VoiceCall voiceCallRecord2 = DH_TestDataFactory.createVoiceCallRecord('+1578782160', '+1649693490','+1649693490', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', null);
		voiceCallRecord2.RelatedRecordId = accList[1].id;
		voiceCallList.add(voiceCallRecord2);
		VoiceCall voiceCallRecord3 = DH_TestDataFactory.createVoiceCallRecord('+1578782161', '+1649693491','+1649693491', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', null);
		voiceCallRecord3.RelatedRecordId = accList[2].id;
		voiceCallList.add(voiceCallRecord3);
		insert voiceCallList;
		DH_TestDataFactory.createCaseRecord(accList[0].id, voiceCallRecord1.id);
		DH_TestDataFactory.createCaseRecord(accList[1].id, voiceCallRecord2.id);
		DH_TestDataFactory.createCaseRecord(accList[2].id, voiceCallRecord3.id);
		List<ContactPointPhone> cpList = new List<ContactPointPhone>();
		String phoneRisKey = 'FL' + '_' + '5678' + '_' + System.label.DH_ContactPointPhoneRecordTypeName;
		ContactPointPhone contactPhone = DH_TestDataFactory.createContactPointPhone(phoneRisKey, '444-444-4444', accList[0].id);
		cpList.add(contactPhone);
		String phoneRisKey2 = 'FL' + '_' + '5679' + '_' + System.label.DH_ContactPointPhoneRecordTypeName;
		ContactPointPhone contactPhone2 = DH_TestDataFactory.createContactPointPhone(phoneRisKey2, '545-545-5454', accList[0].id);
		cpList.add(contactPhone2);
		insert cpList;
		List<ContactPointEmail> ceList = new List<ContactPointEmail>();
		String emailRisKey = 'FL' + '_' + '5479' + '_' + System.label.DH_ContactPointEmailRecordTypeName;
		ContactPointEmail contactEmail = DH_TestDataFactory.createContactPointEmail(emailRisKey, 'testemail@gmail.com', accList[0].id);
		ceList.add(contactEmail);
		String emailRisKey2 = 'FL' + '_' + '5480' + '_' + System.label.DH_ContactPointEmailRecordTypeName;
		ContactPointEmail contactEmail2 = DH_TestDataFactory.createContactPointEmail(emailRisKey2, 'test234email@gmail.com', accList[0].id);
		ceList.add(contactEmail2);
		insert ceList;
		List<EngagementInteraction> engagementList = new List<EngagementInteraction>();
		EngagementInteraction engagement1 = new EngagementInteraction(DH_Account__c = accList[0].id, Reason = 'Test Reason', StartDateTime = Datetime.now(), CommunicationChannel = 'DH_Email', DH_EmailAddress__c = 'test367@gmail.com');
		EngagementInteraction engagement2 = new EngagementInteraction(DH_Account__c = accList[0].id, DH_Content_Body__c = 'SMS', StartDateTime = Datetime.now(), CommunicationChannel = 'DH_SMS', DH_EmailAddress__c = 'test34@gmail.com');
		engagementList.add(engagement1);
		engagementList.add(engagement2);
		insert engagementList;
        List<et4ae5__Automated_Send__c> triggerSendList = new List<et4ae5__Automated_Send__c>();
		et4ae5__Automated_Send__c triggerSend1 = DH_TestDataFactory.creatTriggerSend('2752');
		triggerSendList.add(triggerSend1);
		et4ae5__Automated_Send__c triggerSend2 = DH_TestDataFactory.creatTriggerSend('2753');
		triggerSendList.add(triggerSend2);
		insert triggerSendList;
		List<et4ae5__IndividualEmailResult__c> ierList = new List<et4ae5__IndividualEmailResult__c>();
		et4ae5__IndividualEmailResult__c ier1 = DH_TestDataFactory.creatIER('1', '2752', '167776', '3445', 5, triggerSend1.Id);
		ierList.add(ier1);
		et4ae5__IndividualEmailResult__c ier2 = DH_TestDataFactory.creatIER('2', '2753', '127772', '3344', 6, triggerSend1.Id);
		ierList.add(ier2);
		insert ierList;
        ClinicalServiceRequest csr = new ClinicalServiceRequest();
		csr.DH_Order_Key__c = '974375';
		csr.PatientId = accList[1].Id;
		csr.Type = 'Option';
		insert csr;
		List<EngagementInteraction> eIList = new List<EngagementInteraction>();
		EngagementInteraction eI1 = DH_TestDataFactory.createEiRec('1', '3445', 'DH_Email', 'test34@gmail.com', '2752', '167776', 'Test Email Sent', '', accList[1].Id, csr.Id);
		eIList.add(eI1);
		EngagementInteraction eI2 = DH_TestDataFactory.createEiRec('2', '3344', 'DH_Email', 'test367@gmail.com', '2753', '127772', 'Test Email Sent Two', '', accList[1].Id, csr.Id);
		eIList.add(eI2);
		insert eIList;
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getAccountsMap.
	 * @param       - None
	 **/
	@isTest
	public static void validateGetAccountsMap() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Account eastAccount = [SELECT Id FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account'];
		Account westAccount = [SELECT Id FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account'];

		Test.startTest();
		List<List<Integer>> querycountlist1 = runValidateGetAccountsMap(userEastMap,eastAccount);
        System.assertEquals(querycountlist1[0][0],querycountlist1[0][1], 'Query Limit Increased');
        System.assertEquals(querycountlist1[1][0],querycountlist1[1][1], 'Query Limit Increased');
		List<List<Integer>> querycountlist2 = runValidateGetAccountsMap(userWestMap,westAccount);
        System.assertEquals(querycountlist2[0][0],querycountlist2[0][1], 'Query Limit Increased');
        System.assertEquals(querycountlist2[0][0],querycountlist2[0][1], 'Query Limit Increased');
		Test.stopTest();
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getAccountsMap.
	 * @param       - None
	 **/
	public static List<List<Integer>> runValidateGetAccountsMap(Map<Id, User> userMap,Account account) {
        List<List<Integer>> querycountlist = new List<List<Integer>>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
                List<Integer> queries = new List<Integer>();
				queryCount = Limits.getQueries();
				Set<Id> blankAccIdSet = new Set<Id>();
				Map<Id, Account> result1 = DH_ContactCenterCachingUtility.getAccountsMap(blankAccIdSet);
				System.assertEquals(queryCount, Limits.getQueries(), 'Query Limit should be match');

				Set<Id> accIdSet = new Set<Id>();
				accIdSet.add(account.Id);
				Map<Id, Account> result = DH_ContactCenterCachingUtility.getAccountsMap(accIdSet);
				queryCount = Limits.getQueries();
                queries.add(queryCount);
                queries.add(Limits.getQueries());
                querycountlist.add(queries);
			}
		}
        return querycountlist;
	}
	/**
	 * @Jira CC-702
	 * @description - Tests the invocation of the getEngagmentDetails.
	 * @param       - None
	 **/
	@isTest
	public static void validateGetEngagementDetails() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Account eastAccount = [SELECT Id FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account'];
		Account westAccount = [SELECT Id FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account'];
		Test.startTest();
		List<Integer> queryList1= runValidateGetEngagementDetails(userEastMap,eastAccount);
        System.assertEquals(queryList1[0], Limits.getQueries()-1, 'Query Count should be Match');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Query Count should be Match');
		List<Integer> queryList2= runValidateGetEngagementDetails(userWestMap,westAccount);
        System.assertEquals(queryList2[0], Limits.getQueries()-1, 'Query Count should be Match');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-702
	 * @description - Tests the invocation of the getEngagmentDetails.
	 * @param       - None
	 **/
	public static List<Integer> runValidateGetEngagementDetails(Map<Id, User> userMap,Account account) {
        List<Integer> queryList= new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<Id> accIdSet = new Set<Id>();
				accIdSet.add(account.Id);
				Map<Id, List<EngagementInteraction>> result = DH_ContactCenterCachingUtility.getEngagementDetails(accIdSet);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-702
	 * @description - Tests the invocation of the getEngagmentDetails.
	 * @param       - None
	 **/
	@isTest
	public static void validateCallHistoryDetailsTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Account eastAccount = [SELECT Id FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account'];
		Account westAccount = [SELECT Id FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account'];
		Test.startTest();
			List<Integer> queryList1 = runValidateCallHistoryDetailsTest(userEastMap,eastAccount);
            queryCount = Limits.getQueries();
            System.assertEquals(queryCount, Limits.getQueries(), 'Query Count should be Match');
			List<Integer> queryList2 = runValidateCallHistoryDetailsTest(userWestMap,westAccount);
            queryCount = Limits.getQueries();
            System.assertEquals(queryCount, Limits.getQueries(), 'Query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-702
	 * @description - Tests the invocation of the getEngagmentDetails.
	 * @param       - None
	 **/
	public static List<Integer> runValidateCallHistoryDetailsTest(Map<Id, User> userMap,Account account) {
        List<Integer> queryList= new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<Id> accIdSet = new Set<Id>();
				accIdSet.add(account.Id);
                queryList.add(Limits.getQueries());
				Map<Id, List<VoiceCall>> result = DH_ContactCenterCachingUtility.getCallHistoryDetails(accIdSet);
                queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getGroupListTest.
	 * @param       - None
	 **/
	@isTest
	public static void getGroupListTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Test.startTest();
			List<Integer> queryList1 = runGetGroupListTest(userEastMap);
            System.assertEquals(queryList1[0], Limits.getQueries(), 'Group Query Count should be Match');
            System.assertEquals(queryList1[1], Limits.getQueries(), 'Group Query Count should be Match');
			List<Integer> queryList2 = runGetGroupListTest(userWestMap);
            System.assertEquals(queryList2[0], Limits.getQueries(), 'Group Query Count should be Match');
            System.assertEquals(queryList2[1], Limits.getQueries(), 'Group Query Count should be Match');
		Test.stopTest();
	}
		/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getGroupListTest.
	 * @param       - None
	 **/
	public static List<Integer> runGetGroupListTest(Map<Id, User> userMap) {
        List<Integer> queryList= new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> grpNames = new Set<String>();
				Map<String, Group> result = DH_ContactCenterCachingUtility.getGroupList(grpNames);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getVoiceList.
	 * @param       - None
	 **/
	@isTest
	public static void validateGetVoiceListTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Test.startTest();
		VoiceCall eastVcRecord = [SELECT ID, OwnerId FROM VoiceCall WHERE F9_Call_ANI__c = '+1649693498' LIMIT 1];
		VoiceCall westVcRecord = [SELECT ID, OwnerId FROM VoiceCall WHERE F9_Call_ANI__c = '+1649693491' LIMIT 1];
		List<Integer> queryList1 = runValidateGetVoiceListTest(userEastMap,eastVcRecord);
        System.assertEquals(queryList1[0], Limits.getQueries(), 'Voice Call Query Count should be Match');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Voice Call Query Count should be Match');
		List<Integer> queryList2 = runValidateGetVoiceListTest(userWestMap,westVcRecord);
        System.assertEquals(queryList2[0], Limits.getQueries(), 'Voice Call Query Count should be Match');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Voice Call Query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getVoiceList.
	 * @param       - None
	 **/
	public static List<Integer> runValidateGetVoiceListTest(Map<Id, User> userMap,VoiceCall vcRecord) {
        List<Integer> queryList = new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<Id> vcIdSet = new Set<Id>();
				vcIdSet.add(vcRecord.Id);
				Map<Id, VoiceCall> result = DH_ContactCenterCachingUtility.getVcMap(vcIdSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Voice Call Query Count should be Match');
				Set<Id> blankVcIdSet = new Set<Id>();
				Map<Id, VoiceCall> result1 = DH_ContactCenterCachingUtility.getVcMap(blankVcIdSet);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getUsersMap.
	 * @param       - None
	 **/
	@isTest
	public static void getUsersMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Test.startTest();
			List<Integer> queryList1 = runGetUsersMapTest(userEastMap);
        	System.assertEquals(queryList1[0], Limits.getQueries(), 'Account Query Count should be Match');
        	System.assertEquals(queryList1[1], Limits.getQueries(), 'Account Query Count should be Match');
			List<Integer> queryList2 = runGetUsersMapTest(userWestMap);
         	System.assertEquals(queryList2[0], Limits.getQueries(), 'Account Query Count should be Match');
        	System.assertEquals(queryList2[1], Limits.getQueries(), 'Account Query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getUsersMap.
	 * @param       - None
	 **/
	public static List<Integer> runGetUsersMapTest(Map<Id, User> userMap) {
        List<Integer> queryList= new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<Id> userIdSet = new Set<Id>();
				Map<Id, User> result = DH_ContactCenterCachingUtility.getUsersMap(userIdSet);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getUsersMap.
	 * @param       - None
	 **/
	@isTest
	public static void getUsersMapTestTwo() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Test.startTest();
			List<Integer> querList1 = runGetUsersMapTestTwo(userEastMap);
        	System.assertEquals(querList1[0], Limits.getQueries()-1, 'Account Query Count should be Match');
        	System.assertEquals(querList1[1], Limits.getQueries(), 'Account Query Count should be Match');
			List<Integer> querList2 = runGetUsersMapTestTwo(userWestMap);
        	System.assertEquals(querList2[0], Limits.getQueries()-1, 'Account Query Count should be Match');
        	System.assertEquals(querList2[1], Limits.getQueries(), 'Account Query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-526
	 * @description - Tests the invocation of the getUsersMap.
	 * @param       - None
	 **/
	public static List<Integer> runGetUsersMapTestTwo(Map<Id, User> userMap) {
        List<Integer> queryList = new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<Id> userIdSet = new Set<Id>();
				userIdSet.add(System.UserInfo.getUserId());
				Map<Id, User> result = DH_ContactCenterCachingUtility.getUsersMap(userIdSet);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-940
	 * @description - Tests the invocation of the getAccountMapOnUniqueCode.
	 * @param       - None
	 **/
	@isTest
	public static void getUniqueKeyVsAccountMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		test.startTest();
			List<Integer> queryList1 = runGetUniqueKeyVsAccountMapTest(userEastMap);
        	System.assertEquals(queryList1[0], Limits.getQueries()-3, 'Account Query Count should be Match');
        	System.assertEquals(queryList1[1], Limits.getQueries(), 'Account Query Count should be Match');
			List<Integer> queryList2 = runGetUniqueKeyVsAccountMapTest(userWestMap);
        	System.assertEquals(queryList2[0], Limits.getQueries()-3, 'Account Query Count should be Match');
        	System.assertEquals(queryList2[1], Limits.getQueries(), 'Account Query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-940
	 * @description - Tests the invocation of the getAccountMapOnUniqueCode.
	 * @param       - None
	 **/
	public static List<Integer> runGetUniqueKeyVsAccountMapTest(Map<Id, User> userMap) {
        List<Integer> queryList = new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> accountUniqueId = new Set<String>();
				accountUniqueId.add('123453_AZ_Person Account');
				Map<String, Account> result = DH_ContactCenterCachingUtility.getUniqueKeyVsAccountMap(accountUniqueId);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Account Query Count should be Match');
				accountUniqueId.add('123452_CA_Person Account');
				Map<String, Account> result2 = DH_ContactCenterCachingUtility.getUniqueKeyVsAccountMap(accountUniqueId);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Account Query Count should be Match');
				Map<String, Account> result3 = DH_ContactCenterCachingUtility.getUniqueKeyVsAccountMap(accountUniqueId);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-691
	 * @description - Tests the invocation of the getAccountMapOnUniqueCode.
	 * @param       - None
	 **/
	@isTest
	public static void getCaseMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<Case> caseList = [SELECT Id, AccountId FROM Case];

		test.startTest();
			List<Integer> queryList1= runGetCaseMapTest(userEastMap,caseList);
        	System.assertEquals(queryList1[0], Limits.getQueries(), 'Case Query Count should be Match');
        	System.assertEquals(queryList1[1], Limits.getQueries(), 'Case Query Count should be Match');
			List<Integer> queryList2= runGetCaseMapTest(userWestMap,caseList);
        	System.assertEquals(queryList2[0], Limits.getQueries(), 'Case Query Count should be Match');
        	System.assertEquals(queryList2[1], Limits.getQueries(), 'Case Query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-691
	 * @description - Tests the invocation of the getAccountMapOnUniqueCode.
	 * @param       - None
	 **/
	public static List<Integer> runGetCaseMapTest(Map<Id, User> userMap,List<Case> caseList) {
        List<Integer> queryList = new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<Id> caseIdSet = new Set<Id>();
				caseIdSet.add(caseList[0].AccountId);
				Map<Id, Case> result = DH_ContactCenterCachingUtility.getCaseMap(caseIdSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Case Query Count should be Match');
				caseIdSet.add(caseList[1].AccountId);
				Map<Id, Case> result2 = DH_ContactCenterCachingUtility.getCaseMap(caseIdSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Case Query Count should be Match');
				Map<Id, Case> result3 = DH_ContactCenterCachingUtility.getCaseMap(caseIdSet);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-633
	 * @description - Tests the invocation of the getContactPhoneMap.
	 * @param       - None
	 **/
	@isTest
	public static void getContactPhoneMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account1' AND DH_Patient_Key__c = '123451' AND Region__c = 'FL'];
		test.startTest();
		    List<Integer> queryList1 = runGetContactPhoneMapTest(userEastMap,acc);
        	System.assertEquals(queryList1[0], Limits.getQueries()-1, 'Contact Phone Query Count should be Match');
        	System.assertEquals(queryList1[1], Limits.getQueries(), 'Contact Phone Query Count should be Match');
			List<Integer> queryList2 = runGetContactPhoneMapTest(userWestMap,acc);
        	System.assertEquals(queryList2[0], Limits.getQueries()-1, 'Contact Phone Query Count should be Match');
        	System.assertEquals(queryList2[1], Limits.getQueries(), 'Contact Phone Query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-633
	 * @description - Tests the invocation of the getContactPhoneMap.
	 * @param       - None
	 **/
	public static List<Integer> runGetContactPhoneMapTest(Map<Id, User> userMap,Account account) {
        List<integer> queryList = new List<Integer>();
		String phoneRisKey = 'FL' + '_' + '5678' + '_' + System.label.DH_ContactPointPhoneRecordTypeName;
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> phoneKeySet = new Set<String>();
				phoneKeySet.add(phoneRisKey);
				Map<String, ContactPointPhone> result = DH_ContactCenterCachingUtility.getContactPhoneMap(phoneKeySet, account.Id);
				queryList.add(Limits.getQueries());				
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-633
	 * @description - Tests the invocation of the getContactPhoneMap.
	 * @param       - None
	 **/
	@isTest
	public static void getContactPhoneMapTestTwo() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account1' AND DH_Patient_Key__c = '123451' AND Region__c = 'FL'];
		test.startTest();
		List<Integer> queryList1 = runGetContactPhoneMapTestTwo(userEastMap,acc);
        System.assertEquals(queryList1[0], Limits.getQueries(), 'Contact Phone query Count should be Match');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Contact Phone query Count should be Match');
		List<Integer> queryList2 = runGetContactPhoneMapTestTwo(userWestMap,acc);
        System.assertEquals(queryList2[0], Limits.getQueries(), 'Contact Phone query Count should be Match');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Contact Phone query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-633
	 * @description - Tests the invocation of the getContactPhoneMap.
	 * @param       - None
	 **/
	public static List<Integer> runGetContactPhoneMapTestTwo(Map<Id, User> userMap,Account account) {
        List<Integer> queryList = new List<Integer>();
		for(User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> phoneKeySet = new Set<String>();
				Map<String, ContactPointPhone> result = DH_ContactCenterCachingUtility.getContactPhoneMap(phoneKeySet, account.Id);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-664
	 * @description - Tests the invocation of the getContactEmailMap.
	 * @param       - None
	 **/
	@isTest
	public static void getContactEmailMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account1' AND DH_Patient_Key__c = '123451' AND Region__c = 'FL'];
		test.startTest();
		List<Integer> queryList1 = runGetContactEmailMapTest(userEastMap,acc);
        System.assertEquals(queryList1[0], Limits.getQueries(), 'Contact Phone query Count should be Match');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Contact Phone query Count should be Match');
		List<Integer> queryList2 = runGetContactEmailMapTest(userWestMap,acc);
        System.assertEquals(queryList2[0], Limits.getQueries(), 'Contact Phone query Count should be Match');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Contact Phone query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-664
	 * @description - Tests the invocation of the getContactEmailMap.
	 * @param       - None
	 **/
	public static List<Integer> runGetContactEmailMapTest(Map<Id, User> userMap,Account account) {
        List<Integer> queryList= new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> emailKeySet = new Set<String>();
				Map<String, ContactPointEmail> result = DH_ContactCenterCachingUtility.getContactEmailMap(emailKeySet, account.Id);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-664
	 * @description - Tests the invocation of the getContactEmailMap.
	 * @param       - None
	 **/
	@isTest
	public static void getContactEmailMapTestTwo() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account1' AND DH_Patient_Key__c = '123451' AND Region__c = 'FL'];
		test.startTest();
		List<Integer> queryList1 = runGetContactEmailMapTestTwo(userEastMap,acc);
        System.assertEquals(queryList1[0], Limits.getQueries()-1, 'Contact Email query Count should be Match');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Contact Email query Count should be Match');
		List<Integer> queryList2 = runGetContactEmailMapTestTwo(userWestMap,acc);
        System.assertEquals(queryList2[0], Limits.getQueries()-1, 'Contact Email query Count should be Match');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Contact Email query Count should be Match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-664
	 * @description - Tests the invocation of the getContactEmailMap.
	 * @param       - None
	 **/
	public static List<Integer> runGetContactEmailMapTestTwo(Map<Id, User> userMap,Account account) {
        List<Integer> queryList = new List<Integer>();
		String emailRisKey = 'FL' + '_' + '5479' + '_' + System.label.DH_ContactPointEmailRecordTypeName;
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> emailKeySet = new Set<String>();
				emailKeySet.add(emailRisKey);
				Map<String, ContactPointEmail> result = DH_ContactCenterCachingUtility.getContactEmailMap(emailKeySet, account.Id);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-520
	 * @description - Tests the invocation of the getEmailTemplateList.
	 * @param       - None
	 **/
	@isTest
	public static void getEmailTemplateMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		test.startTest();
		List<Integer> queryList1 = runGetEmailTemplateMapTest(userEastMap);
        System.assertEquals(queryList1[0], Limits.getQueries()-1, 'Error occurred');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Error occurred');
		List<Integer> queryList2 = runGetEmailTemplateMapTest(userWestMap);
        System.assertEquals(queryList2[0], Limits.getQueries()-1, 'Error occurred');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Error occurred');
		Test.stopTest();
	}
	/**
	 * @Jira CC-520
	 * @description - Tests the invocation of the getEmailTemplateList.
	 * @param       - None
	 **/
	public static List<Integer> runGetEmailTemplateMapTest(Map<Id,User> userMap) {
        List<Integer> queryList = new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> eTSet = new Set<String>();
				eTSet.add('DH_APIErrorEmailNotification');
				Map<String, EmailTemplate> result1 = DH_ContactCenterCachingUtility.getEmailTemplateMap(eTSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
				Map<String, EmailTemplate> result2 = DH_ContactCenterCachingUtility.getEmailTemplateMap(eTSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
				eTSet.add('xyz');
				Map<String, EmailTemplate> result3 = DH_ContactCenterCachingUtility.getEmailTemplateMap(eTSet);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-572
	 * @description - Tests the invocation of the getPayloadMap method.
	 * @param       - None
	 **/
	@isTest
	public static void getPayloadMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
		VoiceCall voiceCallRecord = [SELECT ID, Name FROM VoiceCall WHERE F9_Call_ANI__c = '+1649693498' LIMIT 1];
		VoiceCall voiceCallRecord2 = [SELECT ID, Name FROM VoiceCall WHERE F9_Call_ANI__c = '+1649693490' LIMIT 1];
		System.runAs(radnetSchedulerEast) {
			DH_PayloadData__c pld = DH_TestDataFactory.createPayLoadRecord('Endpoint', voiceCallRecord.Id, 'payload');
			insert pld;
			DH_PayloadData__c pld2 = DH_TestDataFactory.createPayLoadRecord('Endpoint2', voiceCallRecord2.Id, 'payload2');
			insert pld2;
		}
		DH_DexOutServiceRisPatientSearchRequest wrapper = DH_TestDataFactory.createRisPatientWrapper(true, true, true, true, true, true, true, true, true);
		test.startTest();
        List<Integer> queryList1 = runGetPayloadMapTest(userEastMap,voiceCallRecord,voiceCallRecord2);
        System.assertEquals(queryList1[0], Limits.getQueries()-2, 'Payload Query should be match');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Payload Query should be match');
        List<Integer> queryList2 = runGetPayloadMapTest(userWestMap,voiceCallRecord,voiceCallRecord2);
        System.assertEquals(queryList2[0], Limits.getQueries()-2, 'Payload Query should be match');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Payload Query should be match');
		Test.stopTest();
	}
	/**
	 * @Jira CC-572
	 * @description - Tests the invocation of the getPayloadMap method.
	 * @param       - None
	 **/
	public static List<Integer> runGetPayloadMapTest(Map<Id, User> userMap,VoiceCall voiceCallRecord,VoiceCall voiceCallRecord2) {
		List<Integer> queryList = new List<Integer>();
        for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<Id> relatedIdSet = new Set<Id>();
				relatedIdSet.add(voiceCallRecord.Id);
				Map<Id, DH_PayloadData__c> payloadData = DH_ContactCenterCachingUtility.getPayloadMap(relatedIdSet);
				queryCount = Limits.getQueries();
				System.assert(true, 'returned payload Data');
				System.assertNotEquals(null, payloadData, 'Empty Payload Data not returned');
				System.assertEquals(queryCount, Limits.getQueries(), 'Payload Query should be match');
				relatedIdSet.add(voiceCallRecord2.Id);
				Map<Id, DH_PayloadData__c> payloadData2 = DH_ContactCenterCachingUtility.getPayloadMap(relatedIdSet);
				queryList.add(Limits.getQueries());
				System.assert(true, 'returned payload Data');
				System.assertNotEquals(null, payloadData2, 'Empty Payload Data not returned');
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-1203,1204
	 * @description - Tests the invocation of the getPermissionSetMap.
	 * @param       - None
	 **/
	@isTest
	static void getPermissionSetMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		test.startTest();
		List<Integer> queryList1 = runGetPermissionSetMapTest(userEastMap);
        System.assertEquals(queryList1[0], Limits.getQueries(), 'Permission Set Query Count should be match');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Permission Set Query Count should be match');
		List<Integer> queryList2 = runGetPermissionSetMapTest(userWestMap);
        System.assertEquals(queryList2[0], Limits.getQueries(), 'Permission Set Query Count should be match');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Permission Set Query Count should be match');
		test.stopTest();
	}
	/**
	 * @Jira CC-1203,1204
	 * @description - Tests the invocation of the getPermissionSetMap.
	 * @param       - None
	 **/
	static List<Integer> runGetPermissionSetMapTest(Map<Id, User> userMap) {
        List<Integer> queryList = new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> setString = new Set<String>();
				setString.add('DH_ContactCenterBatchAdmin');
				Map<String, PermissionSet> result = DH_ContactCenterCachingUtility.getPermissionSetMap(setString);
				queryList.add(Limits.getQueries());
				System.assertNotEquals(null, result, 'map should be return');
				System.assert(true, 'PermissionSet returned');
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-1203,1204
	 * @description - Tests the invocation of the getPermissionSetGroupMap.
	 * @param       - None
	 **/
	@isTest
	static void getPermissionSetGroupMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		test.startTest();
		List<Integer> queryList1 = runGetPermissionSetGroupMapTest(userEastMap);
        System.assertEquals(queryList1[0], Limits.getQueries(), 'Error occurred');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Error occurred');
		List<Integer> queryList2 = runGetPermissionSetGroupMapTest(userWestMap);
        System.assertEquals(queryList2[0], Limits.getQueries(), 'Error occurred');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Error occurred');
		test.stopTest();
	}
	/**
	 * @Jira CC-1203,1204
	 * @description - Tests the invocation of the getPermissionSetGroupMap.
	 * @param       - None
	 **/
	static List<Integer> runGetPermissionSetGroupMapTest(Map<Id, User> userMap) {
        List<Integer> queryList = new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> permissionSetGroupNameSet = new Set<String>();
				permissionSetGroupNameSet.add('DH_KnowledgeManagementEast');
				Map<String, PermissionSetGroup> result = DH_ContactCenterCachingUtility.getPermissionSetGroupMap(permissionSetGroupNameSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
				permissionSetGroupNameSet.add('DH_KnowledgeManagementWest');
				Map<String, PermissionSetGroup> result2 = DH_ContactCenterCachingUtility.getPermissionSetGroupMap(permissionSetGroupNameSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
				Map<String, PermissionSetGroup> result3 = DH_ContactCenterCachingUtility.getPermissionSetGroupMap(permissionSetGroupNameSet);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-1203,1204
	 * @description - Tests the invocation of the getPermissionSetGroupMap.
	 * @param       - None
	 **/
	@isTest
	static void getProfileNameVsProfileMapTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();

		Test.startTest();
		List<Integer> queryList1 = runGetProfileNameVsProfileMapTest(userEastMap);
        System.assertEquals(queryList1[0], Limits.getQueries(), 'Error occurred');
        System.assertEquals(queryList1[1], Limits.getQueries(), 'Error occurred');
		List<Integer> queryList2 = runGetProfileNameVsProfileMapTest(userWestMap);
        System.assertEquals(queryList2[0], Limits.getQueries(), 'Error occurred');
        System.assertEquals(queryList2[1], Limits.getQueries(), 'Error occurred');
		Test.stopTest();
	}
	/**
	 * @Jira CC-1203,1204
	 * @description - Tests the invocation of the getPermissionSetGroupMap.
	 * @param       - None
	 **/
	static List<Integer> runGetProfileNameVsProfileMapTest(Map<Id, User> userMap) {
        List<Integer> queryList = new List<Integer>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Set<String> profileNameSet = new Set<String>();
				profileNameSet.add('System Administrator');
				Map<String, Profile> result = DH_ContactCenterCachingUtility.getProfileNameVsProfileMap(profileNameSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
				profileNameSet.add('RadNet Manager West');
				Map<String, Profile> result2 = DH_ContactCenterCachingUtility.getProfileNameVsProfileMap(profileNameSet);
				queryCount = Limits.getQueries();
				System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
				Map<String, Profile> result3 = DH_ContactCenterCachingUtility.getProfileNameVsProfileMap(profileNameSet);
				queryList.add(Limits.getQueries());
			}
		}
        return queryList;
	}
	/**
	 * @Jira CC-491
	 * @description - Tests the invocation of the getIerMap.
	 * @param       - None
	 **/
	@isTest
	public static void getIerMapTest() {
        User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);
        
		Test.startTest();
		System.runAs(radnetBatchSchedulerUser) {
			DH_DexOutServiceRisEngagementRequest request = new DH_DexOutServiceRisEngagementRequest();
			Map<String, et4ae5__IndividualEmailResult__c> result = DH_ContactCenterCachingUtility.getIerMap(request);
			queryCount = Limits.getQueries();
			System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
		}
		System.runAs(radnetBatchSchedulerUser) {
			DH_DexOutServiceRisEngagementRequest request = new DH_DexOutServiceRisEngagementRequest();
			Map<String, et4ae5__IndividualEmailResult__c> result = DH_ContactCenterCachingUtility.getIerMap(request);
			queryCount = Limits.getQueries();
			System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-491
	 * @description - Tests the invocation of the getIerMap.
	 * @param       - None
	 **/
	@isTest
	public static void getIerMapTestTwo() {
		User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);

		Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account2' AND DH_Patient_Key__c = '123452' AND Region__c = 'CA'];
		List<EngagementInteraction> eIList = [SELECT Id, DH_BatchId__c, DH_EmailId__c, DH_JobId__c, ExternalIdentifier FROM EngagementInteraction WHERE DH_Account__c = :acc.Id LIMIT 2];
		test.startTest();
		System.runAs(radnetBatchSchedulerUser) {
			String key1 = eIList[0].DH_BatchId__c + eIList[0].DH_EmailId__c + eIList[0].DH_JobId__c + eIList[0].ExternalIdentifier;
			String key2 = eIList[1].DH_BatchId__c + eIList[1].DH_EmailId__c + eIList[1].DH_JobId__c + eIList[1].ExternalIdentifier;
			Map<String, EngagementInteraction> uniqueKeyVsEiMap = new Map<String, EngagementInteraction>();
			uniqueKeyVsEiMap.put(key1, eIList[0]);
			uniqueKeyVsEiMap.put(key2, eIList[1]);
			Set<String> batchIdSet = new Set<String>{ eIList[0].DH_BatchId__c, eIList[1].DH_BatchId__c };
			Set<String> emailIdSet = new Set<String>{ eIList[0].DH_EmailId__c, eIList[1].DH_EmailId__c };
			Set<String> jobIdSet = new Set<String>{ eIList[0].DH_JobId__c, eIList[1].DH_JobId__c };
			Set<String> subscriberIdSet = new Set<String>{ eIList[0].ExternalIdentifier, eIList[1].ExternalIdentifier };
			DH_DexOutServiceRisEngagementRequest request = new DH_DexOutServiceRisEngagementRequest();
			request.uniqueKeyVsEiMap = uniqueKeyVsEiMap;
			request.batchIdSet = batchIdSet;
			request.emailIdSet = emailIdSet;
			request.jobIdSet = jobIdSet;
			request.subscriberIdSet = subscriberIdSet;
			Map<String, et4ae5__IndividualEmailResult__c> result = DH_ContactCenterCachingUtility.getIerMap(request);
			queryCount = Limits.getQueries();
			System.assertNotEquals(null, result, 'Error in fetching the Individual Email Results');
			System.assertEquals(queryCount, Limits.getQueries(), 'Error in fetching the Individual Email Results');
		}
		System.runAs(radnetBatchSchedulerUser) {
			String key1 = eIList[0].DH_BatchId__c + eIList[0].DH_EmailId__c + eIList[0].DH_JobId__c + eIList[0].ExternalIdentifier;
			String key2 = eIList[1].DH_BatchId__c + eIList[1].DH_EmailId__c + eIList[1].DH_JobId__c + eIList[1].ExternalIdentifier;
			Map<String, EngagementInteraction> uniqueKeyVsEiMap = new Map<String, EngagementInteraction>();
			uniqueKeyVsEiMap.put(key1, eIList[0]);
			uniqueKeyVsEiMap.put(key2, eIList[1]);
			Set<String> batchIdSet = new Set<String>{ eIList[0].DH_BatchId__c, eIList[1].DH_BatchId__c };
			Set<String> emailIdSet = new Set<String>{ eIList[0].DH_EmailId__c, eIList[1].DH_EmailId__c };
			Set<String> jobIdSet = new Set<String>{ eIList[0].DH_JobId__c, eIList[1].DH_JobId__c };
			Set<String> subscriberIdSet = new Set<String>{ eIList[0].ExternalIdentifier, eIList[1].ExternalIdentifier };
			DH_DexOutServiceRisEngagementRequest request = new DH_DexOutServiceRisEngagementRequest();
			request.uniqueKeyVsEiMap = uniqueKeyVsEiMap;
			request.batchIdSet = batchIdSet;
			request.emailIdSet = emailIdSet;
			request.jobIdSet = jobIdSet;
			request.subscriberIdSet = subscriberIdSet;
			Map<String, et4ae5__IndividualEmailResult__c> result = DH_ContactCenterCachingUtility.getIerMap(request);
			queryCount = Limits.getQueries();
			System.assertNotEquals(null, result, 'Error in fetching the Individual Email Results');
			System.assertEquals(queryCount, Limits.getQueries(), 'Error in fetching the Individual Email Results');
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-491
	 * @description - Tests the invocation of the getEiMap.
	 * @param       - None
	 **/
	@isTest
	public static void getEiMapTest() {
		User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);

		Test.startTest();
		System.runAs(radnetBatchSchedulerUser) {
			DH_DexOutServiceRisEngagementRequest request = new DH_DexOutServiceRisEngagementRequest();
			Set<String> eiIdSet = new Set<String>();
			Map<Id, EngagementInteraction> result = DH_ContactCenterCachingUtility.getEiMap(eiIdSet);
			queryCount = Limits.getQueries();
			System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
		}
		System.runAs(radnetBatchSchedulerUser) {
			DH_DexOutServiceRisEngagementRequest request = new DH_DexOutServiceRisEngagementRequest();
			Set<String> eiIdSet = new Set<String>();
			Map<Id, EngagementInteraction> result = DH_ContactCenterCachingUtility.getEiMap(eiIdSet);
			queryCount = Limits.getQueries();
			System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
		}
		Test.stopTest();
	}

	/**
	 * @Jira CC-491
	 * @description - Tests the invocation of the getEiMap.
	 * @param       - None
	 **/
	@isTest
	public static void getEiMapTestTwo() {
		User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);

		Set<String> emailIds = new Set<String>{ 'test34@gmail.com', 'test367@gmail.com' };
		List<EngagementInteraction> eiRecords = [SELECT Id FROM EngagementInteraction WHERE DH_EmailAddress__c IN :emailIds WITH SECURITY_ENFORCED LIMIT 2];
		test.startTest();
		System.runAs(radnetBatchSchedulerUser) {
			Set<String> eiIdSet = new Set<String>();
			eiIdSet.add(eiRecords[0].Id);
			eiIdSet.add(eiRecords[1].Id);
			Map<Id, EngagementInteraction> result = DH_ContactCenterCachingUtility.getEiMap(eiIdSet);
			System.assertNotEquals(null, result, 'Error in fetching the EngagementInteraction');
			queryCount = Limits.getQueries();
			System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
		}
		System.runAs(radnetBatchSchedulerUser) {
			Set<String> eiIdSet = new Set<String>();
			eiIdSet.add(eiRecords[0].Id);
			eiIdSet.add(eiRecords[1].Id);
			Map<Id, EngagementInteraction> result = DH_ContactCenterCachingUtility.getEiMap(eiIdSet);
			System.assertNotEquals(null, result, 'Error in fetching the EngagementInteraction');
			queryCount = Limits.getQueries();
			System.assertEquals(queryCount, Limits.getQueries(), 'Error occurred');
		}
		Test.stopTest();
	}

	/**
	 * @Jira
	 * @description - Tests group listg
	 * @param       - None
	 **/
	@isTest
	public static void getGroupList() {
		User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);

		Set<String> emailIds = new Set<String>{ 'test34@gmail.com', 'test367@gmail.com' };
		List<EngagementInteraction> eiRecords = [SELECT Id FROM EngagementInteraction WHERE DH_EmailAddress__c IN :emailIds WITH SECURITY_ENFORCED LIMIT 2];
		test.startTest();
		System.runAs(radnetBatchSchedulerUser) {
            List<String> grpNames = new List<String>();
            grpNames.add('AZ_Region_Team');
            DH_ContactCenterQueryManager.getGroupList(grpNames);
            DH_ContactCenterQueryManager.getDefaultAccount('AZ');
		}
		Test.stopTest();
	}
}