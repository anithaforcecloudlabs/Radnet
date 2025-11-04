/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexLoggingUtilityTest
* Created Date - 30-May-2024
* @description       : Test class for DH_DexLoggingUtility.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* CC-426                   29-May-2024          Added getStagingRecord method and Logger class.
* CC-716                   21-August-2024       Added testCreateLogTest method.
* CC-482-507               11-September-2024    Added testGetStagingRecordMultiple method.
* CC-1203,CC-1204		   16-September-2024	Updated all existing methods related to profile update.
* CC-430                   17-September-2024    Added createLogRecord method.
* CC-482-507               09-October-2024     	Changes related to code optimization and code coverage.
* CC-1439                  30-October-2024		Replaced all instances of FromPhoneNumber with F9_Call_ANI__c.
* *****************************************************************************************************************************
*/
@isTest
public class DH_DexLoggingUtilityTest {
	/**
	 * @Jira CC-426
	 * @description Creates reusable test data that can be used across multiple test methods within the same class.
	 **/
	@testSetup
	public static void setup() {
		User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
		User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
		User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
		User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
        VoiceCall vc = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '+1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
		insert vc;
	}
	/**
	 * @Jira CC-482-507
	 * @description Test the creation of log in the generic createLogRecord.
	 **/
	@isTest
	public static void testGetStagingRecord() {
        Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisSearchPatientServiceSetting');
		String jsonStr = integrationSettingMetadata.DH_SampleResponse__c;
		Test.startTest();
		List<DH_PayloadData__c> payLoadList = runTestGetStagingRecord(userEastMap.values(),jsonStr);
		List<DH_PayloadData__c> payLoadList1 = runTestGetStagingRecord(userWestMap.values(),jsonStr);
		Test.stopTest();
		System.assertNotEquals(null, payLoadList, 'Payload record is created');
		System.assertNotEquals(null, payLoadList1, 'Payload record is created');
	}
    /**
	 * @Jira CC-482-507
	 * @description Test the creation of log in the generic createLogRecord.
	 **/
	@isTest
	public static void testGetStagingRecordTwo() {
        Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisAdvSearchPatientServiceSetting');
        String jsonStr = integrationSettingMetadata.DH_SampleResponse__c;
        while(jsonStr.length() < 400000){
            jsonStr += integrationSettingMetadata.DH_SampleResponse__c;
        }
		Test.startTest();
		List<DH_PayloadData__c> payLoadList = runTestGetStagingRecord(userEastMap.values(),jsonStr);
		List<DH_PayloadData__c> payLoadList1 = runTestGetStagingRecord(userWestMap.values(),jsonStr);
		Test.stopTest();
		System.assertNotEquals(null, payLoadList, 'Payload record is created');
		System.assertNotEquals(null, payLoadList1, 'Payload record is created');
	}
    /**
	* @Jira CC-482-507
    * @description - Test method which has common code for east and west users for testGetStagingRecord.
    * @param       - List, String
	* @return	   - List
	**/
    public static List<DH_PayloadData__c> runTestGetStagingRecord(List<User> userList,String jsonStr) {
		List<DH_PayloadData__c> payLoadList = new List<DH_PayloadData__c>();
        for (User userRec : userList) {
			System.runAs(userRec) {
                DH_PayloadData__c payload = DH_DexLoggingUtility.getStagingRecord(jsonStr);
				payLoadList.add(payload);
				System.assertNotEquals(null, payLoad.DH_Payload1__c, 'Payload 1 is created');
			}
		}
		return payLoadList;
    }  
    /**
	 * @Jira CC-716
	 * @description Test the creation of log in the createLogRecord.
	 **/
	@isTest
	public static void testCreateLogTest() {
        Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
		runTestCreateLogTest(userEastMap.values());
		runTestCreateLogTest(userWestMap.values());
		Test.stopTest();
		List<DH_PayloadData__c> payLoad = [SELECT Id, DH_ClassName__c FROM DH_PayloadData__c LIMIT 4];
		System.assertNotEquals(null, payLoad, 'Payload record is created');
		System.assertEquals(4, payLoad.size(), 'Payload record is created');
	}
    /**
	* @Jira CC-716
    * @description - Test method which has common code for east and west users for testCreateLogTest.
    * @param       - List
	**/
    public static void runTestCreateLogTest(List<User> userList) {
        VoiceCall vc = [SELECT Id FROM VoiceCall WHERE F9_Call_ANI__c = '+1649693498' LIMIT 1];
        for (User userRec : userList) {
			System.runAs(userRec) {
				DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
				logWrapper.ErrorMessage = 'Test Error Message';
				logWrapper.relatedTo = vc.Id;
				logWrapper.className = 'DH_DexLoggingUtilityTest';
				DH_DexLoggingUtility.createLogRecord(logWrapper);
			}
		}
    }
    /**
	 * @Jira CC-716
	 * @description Test the exception scenario while creating the payload record.
	 **/
	@isTest
	public static void testCreateLogTestTwo() {
        Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
		runTestCreateLogTestTwo(userEastMap.values());
		runTestCreateLogTestTwo(userWestMap.values());
		Test.stopTest();
		List<DH_PayloadData__c> payLoad = [SELECT Id, DH_ClassName__c FROM DH_PayloadData__c LIMIT 4];
		System.assertNotEquals(null, payLoad, 'Payload record is created');
	}
    /**
	* @Jira CC-716
    * @description - Test method which has common code for east and west users for testCreateLogTest.
    * @param       - List
	**/
    public static void runTestCreateLogTestTwo(List<User> userList) {
		DH_DynamicTableColumns__mdt dynamic = [SELECT Id FROM DH_DynamicTableColumns__mdt WITH SECURITY_ENFORCED LIMIT 1];
        for (User userRec : userList) {
			System.runAs(userRec) {
                Map<Integer, DH_ErrorCodeMapping__mdt> errorMapping = DH_CustomMetadataDao.getErrorCodeVsErrorMap('RIS Engagement Service');
				DH_DexOutGeneralServiceResponse res = new DH_DexOutGeneralServiceResponse();
                res.response = 'Test response';
                res.statusCode = 400;
				res.errorMessage = 'TestError';
                res.errorRecord = errorMapping.get(0);
				DH_IntegrationSetting__mdt integrationSetting = DH_IntegrationSetting__mdt.getInstance('DH_RisEngagementServiceSetting');
                DH_DexOutGeneralServiceRequest res1 = new DH_DexOutGeneralServiceRequest();
                res1.requestBody = 'Test body';
                res1.recordId = 'testrecordidtothrowthe';
                res1.requestUrlParameter = 'Test parameter';
				res1.apiSetting = integrationSetting;
				res1.preActionUrlParameter = 'action';
				res1.apiErrorSetting = errorMapping;
				res1.dynamicSetting = dynamic;
				res1.patientId = 'test';
				Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest> apiResponseVsRequestMap = new Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>();
                apiResponseVsRequestMap.put(res,res1);
				DH_DexLoggingUtility.createLogRecord(apiResponseVsRequestMap);
			}
		}
    }
    /**
	 * @Jira CC-482-507
	 * @description Test the creation of log in the generic createLogRecord.
	 **/
	@isTest
	public static void testGetStagingRecordMultiple() {
        Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
		DH_PayloadData__c payLoad = runTestGetStagingRecordMultiple(userEastMap.values());
		DH_PayloadData__c payLoad1 = runTestGetStagingRecordMultiple(userWestMap.values());
		Test.stopTest();
		System.assertNotEquals(null, payLoad, 'Payload record is created');
		System.assertNotEquals(null, payLoad1, 'Payload record is created');
	}
    /**
	* @Jira CC-482-507
    * @description - Test method which has common code for east and west users for testGetStagingRecordMultiple.
    * @param       - List
	* @return	   - DH_PayloadData__c
	**/
    public static DH_PayloadData__c runTestGetStagingRecordMultiple(List<User> userList) {
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisSearchPatientServiceSetting');
		String jsonStr = integrationSettingMetadata.DH_SampleResponse__c;
        for(integer i = 0; i < 10; i++){
            jsonStr = jsonStr + jsonStr;
        }
        DH_PayloadData__c payload = DH_DexLoggingUtility.getStagingRecord(jsonStr);
        for (User userRec : userList) {
			System.runAs(userRec) {
				System.assertNotEquals(null, payLoad.DH_Payload1__c, 'Payload 1 is created');
			}
		}
		return payLoad;
    }
}