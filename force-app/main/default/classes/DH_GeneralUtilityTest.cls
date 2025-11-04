/*
* ***************************************************************************************************************************
* Apex Class Name : DH_GeneralUtilityTest
* Created Date : 25-July-2024
* Function - Test Class for DH_GeneralUtility
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-505                   09-August-2024       Added getUserFederationIdTest method.
* CC-640                   20-August-2024       Added createContactCenterCaseTest method
* CC-572,CC-481			   21-August-2024		Added createRequestBodyTest, createNewPatientServicePatientTest,createDefaultPersonAccountTest and createDefaultPersonAccountExceptionTest methods
* CC-520				   18-August-2024       Added getLabelValueTest and getLabelValueNullTest method
* CC-1203			       11-September-2024	Updated all existing test methods
* CC-1312                  11-September-2024    Added getisValidPhNoTest method.
* CC-491                   11-September-2024    Added getUTCDateTimeTest method.
* CC-1203				   18-September-2024	Updated all existing methods related to Profile changes
* CC-603                   08-Oct-2024          Added runGetPatientSearchedDataTest,rungetUserFederationIdTest,runCreateContactCenterCaseTest,runCreateContactCenterCaseFailTest,
                                                runCreateNewPatientServicePatientTest,runCreateRequestBodyTest,runGetLabelValueTest,runGetLabelValueNullTest,
                                                runCreateDefaultPersonAccountTest,runCreateDefaultPersonAccountExceptionTest,runGetisValidPhNoTest,runGetUTCDateTimeTest,
                                                runCreateEmailWrapperTest and runCreateSmsWrapperTest and did changes related to code optimization and code coverage
* CC-1439                  30-Oct-2024			Replaced all instances of FromPhoneNumber with F9_Call_ANI__c
* ***************************************************************************************************************************
*/
@isTest
public class DH_GeneralUtilityTest {
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
		Account testAccount = new Account(Name = 'Test Account', DH_Patient_Key__c = '12345', DH_System_Id__c = 'system123');
		insert testAccount;

		List<EngagementInteraction> engagementList = new List<EngagementInteraction>();
		EngagementInteraction engagement1 = new EngagementInteraction(DH_Account__c = testAccount.Id, Reason = 'Test Reason', StartDateTime = Datetime.now(), CommunicationChannel = 'DH_Email');
		EngagementInteraction engagement2 = new EngagementInteraction(DH_Account__c = testAccount.Id, DH_Content_Body__c = 'SMS', StartDateTime = Datetime.now(), CommunicationChannel = 'DH_SMS');
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

		VoiceCall voiceCall = new voiceCall(ToPhoneNumber = '+17132508161', FromPhoneNumber = '+13128960089', F9_Call_ANI__c = '+13128960089', VendorType = 'ContactCenter', CallType = 'Inbound', F9_DH_SystemId__c = 'CA', CallDisposition = 'On Call',CallStartDateTime=System.now(),CallEndDateTime=System.now());
		insert voiceCall;

		Account patAccount = DH_GeneralUtility.createNewPatientServicePatient(voiceCall);
	}
	/**
	 * @Jira CC-426
	 * @description - Tests method for getPatientSearchedData method
	 * @param       - None
	 **/
	@isTest
	static void getPatientSearchedDataTest(){
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<Map<String,Object>> result1= runGetPatientSearchedDataTest(userEastMap);
			System.assertNotEquals(null, result1[0],'Map should not null');
			System.assertNotEquals(null, result1[1],'Map should not null');
			List<Map<String,Object>> result2= runGetPatientSearchedDataTest(userWestMap);
			System.assertNotEquals(null, result2[0],'Map should not null');
			System.assertNotEquals(null, result2[1],'Map should not null');
		Test.stopTest();
	}
		/**
	 * @Jira CC-426
	 * @description - Tests method for getPatientSearchedData method
	 * @param       - userMap
	 * @return      - List<Map<string,string>>
	 **/
	static List<Map<String,String>> runGetPatientSearchedDataTest(Map<Id, User> userMap){
		VoiceCall voiceCall = [SELECT id FROM VoiceCall LIMIT 1];
		List<Map<String,String>> res = new List<Map<String,String>>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				Map<String, String> result = DH_GeneralUtility.getPatientSearchedData(voiceCall.Id);
				res.add(result);
			}
		}
		return res;
	}	
	/**
	 * @Jira CC-505
	 * @description - Tests the invocation of the getUserFederationIdTest which will return the user federation id.
	 * @param       - None
	 **/
	@isTest
	public static void getUserFederationIdTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<String> result1 = rungetUserFederationIdTest(userEastMap);
            System.assertNotEquals(null, result1[0], 'Successfully retrieving the user Federation Id');
            System.assertNotEquals(null, result1[1], 'Successfully retrieving the user Federation Id');
			List<String> result2 = rungetUserFederationIdTest(userWestMap);
            System.assertNotEquals(null, result2[0], 'Successfully retrieving the user Federation Id');
            System.assertNotEquals(null, result2[1], 'Successfully retrieving the user Federation Id');
		Test.stopTest();
	}
	/**
	 * @Jira CC-505
	 * @description - Tests the invocation of the getUserFederationIdTest which will return the user federation id.
	 * @param       - None
	 **/
	public static List<String> rungetUserFederationIdTest(Map<Id, User> userMap) {
        List<String> listOfString = new List<string>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				String userFederationID = DH_GeneralUtility.getUserFederationId();
                listOfString.add(userFederationID);
			}
		}
        return listOfString;
	}
	/**
	 * @Jira CC-572,640
	 * @description - Tests the invocation of the createContactCenterCase which will creates the Case
	 * @param       - None
	 **/
	@isTest
	public static void createContactCenterCaseTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<Case> case1 = runCreateContactCenterCaseTest(userEastMap);
            System.assertNotEquals(null, case1[0], 'Case should be created');
			System.assertNotEquals(null, case1[1], 'Case should be created');
			List<Case> case2 = runCreateContactCenterCaseTest(userWestMap);
            System.assertNotEquals(null, case2[0], 'Case should be created');
            System.assertNotEquals(null, case2[1], 'Case should be created');
		Test.stopTest();
	}
	/**
	 * @Jira CC-572,640
	 * @description - Tests the invocation of the createContactCenterCase which will creates the Case
	 * @param       - None
	 **/
	public static List<Case> runCreateContactCenterCaseTest(Map<Id, User> userMap) {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		VoiceCall voiceCall = [SELECT Id FROM VoiceCall LIMIT 1];
        List<Case> caseList = new List<Case>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				DH_GeneralUtility.createContactCenterCase(testAccount.Id, voiceCall.Id);
				Case contactCase = [SELECT Id, AccountId FROM Case WHERE AccountId = :testAccount.Id LIMIT 1];
				caseList.add(contactCase);
			}
		}
        return caseList;
	}
    /**
	 * @Jira CC-572,640
	 * @description - Tests the invocation of the createContactCenterCase which will not creates the Case
	 * @param       - None
	 **/
    @isTest
	public static void createContactCenterCaseFailTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<Case> caseList1 = runCreateContactCenterCaseFailTest(userEastMap);
            System.assertNotEquals(null, caseList1[0], 'Case should be created');
            System.assertNotEquals(null, caseList1[1], 'Case should be created');
			List<Case> caseList2 = runCreateContactCenterCaseFailTest(userWestMap);
            System.assertNotEquals(null, caseList2[0], 'Case should be created');
            System.assertNotEquals(null, caseList2[1], 'Case should be created');
		Test.stopTest();
	}
	/**
	 * @Jira CC-572,640
	 * @description - Tests the invocation of the createContactCenterCase which will not creates the Case
	 * @param       - None
	 **/
	public static List<Case> runCreateContactCenterCaseFailTest(Map<Id, User> userMap) {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		VoiceCall voiceCall = [SELECT Id FROM VoiceCall LIMIT 1];
        List<Case> caseList = new List<Case>();
        for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				DH_GeneralUtility.createContactCenterCase(testAccount.Id, voiceCall.Id);
				Case contactCase = [SELECT Id, AccountId FROM Case WHERE AccountId = :testAccount.Id LIMIT 1];
                caseList.add(contactCase);
			}
		}
        return caseList;
	}
	/**
	 * @Jira CC-572,CC-481
	 * @description - Tests the invocation of the createNewPatientServicePatient which will creates the Case
	 * @param       - None
	 **/
	@isTest
	static void createNewPatientServicePatientTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();       
		Test.startTest();
			List<Account> accountList1 = runCreateNewPatientServicePatientTest(userEastMap);
            system.assertNotEquals(null, accountList1, 'a Person account should be created');
            system.assertNotEquals(null, accountList1, 'a Person account should be created');
			List<Account> accountList2 = runCreateNewPatientServicePatientTest(userWestMap);
            system.assertNotEquals(null, accountList2, 'a Person account should be created');
            system.assertNotEquals(null, accountList2, 'a Person account should be created');
		Test.stopTest();	
	}
	/**
	 * @Jira CC-572,CC-481
	 * @description - Tests the invocation of the createNewPatientServicePatient which will creates the Case
	 * @param       - None
	 **/
	public static List<Account> runCreateNewPatientServicePatientTest(Map<Id, User> userMap) {
        List<Account> aclist = new List<Account>();
        VoiceCall voiceCall = [SELECT id,F9_DH_SystemId__c,F9_Call_ANI__c FROM VoiceCall WHERE F9_Call_ANI__c = '+13128960089'];
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
                DH_GeneralUtility.createNewPatientServicePatient(voiceCall);
                Account patAccount = [SELECT id FROM Account WHERE lastname='+13128960089' LIMIT 1];
                aclist.add(patAccount);
			}
		}
        return aclist;
	}
	/**
	 * @Jira ,CC-481
	 * @description - Tests the invocation of the createNewPatientServicePatient which will creates the Case
	 * @param       - None
	 **/
	@isTest
	static void createRequestBodyTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<String> requestBodylist1 = runCreateRequestBodyTest(userEastMap);
            System.assertNotEquals(null, requestBodylist1[0], 'Request Body should not be null');
            System.assertNotEquals(null, requestBodylist1[1], 'Request Body should not be null');
			List<String> requestBodylist2 = runCreateRequestBodyTest(userWestMap);
            System.assertNotEquals(null, requestBodylist2[0], 'Request Body should not be null');
            System.assertNotEquals(null, requestBodylist2[1], 'Request Body should not be null');
		Test.stopTest();	
	}
		/**
	 * @Jira ,CC-481
	 * @description - Tests the invocation of the createNewPatientServicePatient which will creates the Case
	 * @param       - None
	 **/
	static List<String> runCreateRequestBodyTest(Map<Id, User> userMap) {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		VoiceCall voiceCall = [SELECT Id FROM VoiceCall LIMIT 1];
		DH_DexOutGeneralServiceRequest apiRequest = new DH_DexOutGeneralServiceRequest();
		apiRequest.patientId = testAccount.Id;
		apiRequest.recordId = voiceCall.Id;
        List<String> requestbodylist = new List<String>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				String requestBody = DH_GeneralUtility.createRequestBody(apiRequest);
                requestbodylist.add(requestBody);
				System.assert(requestBody.contains(apiRequest.patientId), 'the Request body should have Patient Id');
			}
		}	
        return requestbodylist;
	}
	/**
	 * @Jira - 520
	 * @description - Tests the invocation of the getLabelValue which will return the error message
	 * @param       - None
	 **/
	@isTest
	static void getLabelValueTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<String> resultList1 = runGetLabelValueTest(userEastMap);
            System.assertNotEquals(null, resultList1[0], 'errorMessage should not be null');
			System.assertEquals(true, resultList1[0].length() > 0, 'the DH_ErrorCodeMapping__mdt custom metadata should have DH_ErrorMessageLabel__c');
            System.assertNotEquals(null, resultList1[0], 'errorMessage should not be null');
			System.assertEquals(true, resultList1[0].length() > 0, 'the DH_ErrorCodeMapping__mdt custom metadata should have DH_ErrorMessageLabel__c');
			List<String> resultList2 = runGetLabelValueTest(userWestMap);
            System.assertNotEquals(null, resultList2[0], 'errorMessage should not be null');
			System.assertEquals(true,  resultList2[0].length() > 0, 'the DH_ErrorCodeMapping__mdt custom metadata should have DH_ErrorMessageLabel__c');
            System.assertNotEquals(null,  resultList2[0], 'errorMessage should not be null');
			System.assertEquals(true,  resultList2[0].length() > 0, 'the DH_ErrorCodeMapping__mdt custom metadata should have DH_ErrorMessageLabel__c');
		Test.stopTest();
	}
		/**
	 * @Jira - 520
	 * @description - Tests the invocation of the getLabelValue which will return the error message
	 * @param       - None
	 **/
	static List<String> runGetLabelValueTest(Map<Id, User> userMap) {
		DH_ErrorCodeMapping__mdt errorMessage = DH_ErrorCodeMapping__mdt.getInstance('DH_401NewPatientErrorMessage');
        List<String> resultList = new List<String>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				resultList.add(DH_GeneralUtility.getLabelValue(errorMessage));
			}
		}
        return resultList;
	}
	/**
	 * @Jira - 520
	 * @description - Tests the invocation of the getLabelValue which will return the error message
	 * @param       - None
	 **/
	@isTest
	static void getLabelValueNullTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<String> resultList1 = runGetLabelValueNullTest(userEastMap);
            System.assertNotEquals(null, resultList1[0], 'errorMessage should not be null');
			System.assertEquals(true, resultList1[0].length() > 0, 'the DH_ErrorCodeMapping__mdt custom metadata should have DH_ErrorMessageLabel__c');
            System.assertNotEquals(null, resultList1[1], 'errorMessage should not be null');
			System.assertEquals(true, resultList1[1].length() > 0, 'the DH_ErrorCodeMapping__mdt custom metadata should have DH_ErrorMessageLabel__c');
			List<String> resultList2 = runGetLabelValueNullTest(userWestMap);
            System.assertNotEquals(null, resultList2[0], 'errorMessage should not be null');
			System.assertEquals(true, resultList2[0].length() > 0, 'the DH_ErrorCodeMapping__mdt custom metadata should have DH_ErrorMessageLabel__c');
			System.assertNotEquals(null, resultList2[1], 'errorMessage should not be null');
			System.assertEquals(true, resultList2[1].length() > 0, 'the DH_ErrorCodeMapping__mdt custom metadata should have DH_ErrorMessageLabel__c');
		Test.stopTest();
	}
		/**
	 * @Jira - 520
	 * @description - Tests the invocation of the getLabelValue which will return the error message
	 * @param       - None
	 **/
	static List<String> runGetLabelValueNullTest(Map<Id, User> userMap) {
		DH_ErrorCodeMapping__mdt errorMessage = DH_ErrorCodeMapping__mdt.getInstance('xyz');
        List<String> resultList = new List<String>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
                resultList.add(DH_GeneralUtility.getLabelValue(errorMessage));
			}
		}
        return resultList;
	}
	/**
	 * Jira CC-572
	 * @description - this method Creates the Region specific Account
	 * @param       - none
	 * @return      - none
	 **/
	@isTest
	static void createDefaultPersonAccountTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<Account> patientList1 = runCreateDefaultPersonAccountTest(userEastMap);
			System.assertNotEquals(null, patientList1[0], 'Person Account should be created');
			System.assertNotEquals(null, patientList1[1], 'Person Account should be created');
			List<Account> patientList2 = runCreateDefaultPersonAccountTest(userWestMap);
            System.assertNotEquals(null, patientList2[0], 'Person Account should be created');
            System.assertNotEquals(null, patientList2[1], 'Person Account should be created');
		Test.stopTest();
	}
	/**
	 * Jira CC-572
	 * @description - this method Creates the Region specific Account
	 * @param       - none
	 * @return      - none
	 **/
	static List<Account> runCreateDefaultPersonAccountTest(Map<Id, User> userMap) {
		String systemId = 'CA';
        List<Account> accountList = new List<Account>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				accountList.add(DH_GeneralUtility.createDefaultPersonAccount(systemId));
			}
		}
        return accountList;
	}
	/**
	 * Jira CC-572
	 * @description - this method Creates the Region specific Account
	 * @param       - none
	 * @return      - none
	 **/
	@isTest
	static void createDefaultPersonAccountExceptionTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<Account> patientList1 = runCreateDefaultPersonAccountExceptionTest(userEastMap);
            System.assertEquals(null, patientList1[0], 'Account not Created');
			System.assertEquals(patientList1[0], patientList1[0], 'Exception');
            System.assertEquals(null, patientList1[1], 'Account not Created');
			System.assertEquals(patientList1[1], patientList1[1], 'Exception');
			List<Account> patientList2 = runCreateDefaultPersonAccountExceptionTest(userWestMap);
            System.assertEquals(null, patientList2[0], 'Account not Created');
			System.assertEquals(patientList2[0], patientList2[0], 'Exception');
            System.assertEquals(null, patientList2[1], 'Account not Created');
			System.assertEquals(patientList2[1], patientList2[1], 'Exception');
		Test.stopTest();
	} 
	/**
	 * Jira CC-572
	 * @description - this method Creates the Region specific Account
	 * @param       - none
	 * @return      - none
	 **/
	static List<Account> runCreateDefaultPersonAccountExceptionTest(Map<Id, User> userMap) {
		String systemId = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
        List<Account> accountList = new List<Account>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				accountList.add(DH_GeneralUtility.createDefaultPersonAccount(systemId));
			}
		}
        return accountList;
	}
	/**
	 * @Jira CC-1312
	 * @description - Tests the invocation of the isValidPhNo which will return true or false.
	 * @param       - None
	 **/
	@isTest
	public static void getisValidPhNoTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<Boolean> validList1 = runGetisValidPhNoTest(userEastMap);
            System.assertEquals(true, validList1[0], 'Error in validating the phone number');
            System.assertEquals(true, validList1[1], 'Error in validating the phone number');
			List<Boolean> validList2 = runGetisValidPhNoTest(userWestMap);
            System.assertEquals(true, validList2[0], 'Error in validating the phone number');
            System.assertEquals(true, validList2[1], 'Error in validating the phone number');
		Test.stopTest();
	}
		/**
	 * @Jira CC-1312
	 * @description - Tests the invocation of the isValidPhNo which will return true or false.
	 * @param       - None
	 **/
	public static List<Boolean> runGetisValidPhNoTest(Map<Id, User> userMap) {
        List<Boolean> validList = new List<Boolean>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
                String phno = '3456789045';
				validList.add(DH_GeneralUtility.isValidPhNo(phno));
			}
		}
        return validList;
	}
    /**
	 * @Jira CC-491
	 * @description - Tests the invocation of the getUTCDateTime which will return date UTC dateTime format.
	 * @param       - None
	 **/
	@isTest
	public static void getUTCDateTimeTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
            DateTime dt = System.now();
			List<String> dateRecList1 = runGetUTCDateTimeTest(userEastMap,dt);
            String dateVal1 = DH_GeneralUtility.getUTCDateTime(dt);
            System.assertEquals(dateRecList1[0], dateVal1, 'Error in getting UTC format');
            System.assertEquals(dateRecList1[1], dateVal1, 'Error in getting UTC format');
			List<String> dateRecList2 = runGetUTCDateTimeTest(userWestMap,dt);
            String dateVal2 = DH_GeneralUtility.getUTCDateTime(dt);
            System.assertEquals(dateRecList2[0], dateVal2, 'Error in getting UTC format');
            System.assertEquals(dateRecList2[1], dateVal2, 'Error in getting UTC format');
		Test.stopTest();
	}
	/**
	 * @Jira CC-491
	 * @description - Tests the invocation of the getUTCDateTime which will return date UTC dateTime format.
	 * @param       - None
	 **/
	public static List<String> runGetUTCDateTimeTest(Map<Id, User> userMap, DateTime dt) {
        List<String> dateRecList = new List<String>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				String dateVal = DH_GeneralUtility.getUTCDateTime(dt);
                dateRecList.add(dateVal);
			}
		}
        return dateRecList;
	}
	/**
	 * @Jira CC-491
	 * @description - Tests the invocation of the createEmailWrapper which will return email wrapper
	 * @param       - None
	 **/
	@isTest
	public static void createEmailWrapperTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<List<DH_DexOutServiceRisEIEmailRequest>> emailwrapper1 = runCreateEmailWrapperTest(userEastMap);
            System.assertNotEquals(null,emailwrapper1[0], 'Email Wrapper created');
            System.assertNotEquals(null,emailwrapper1[1], 'Email Wrapper created');
			List<List<DH_DexOutServiceRisEIEmailRequest>> emailwrapper2 = runCreateEmailWrapperTest(userWestMap);
            System.assertNotEquals(null,emailwrapper2[0], 'Email Wrapper created');
            System.assertNotEquals(null,emailwrapper2[1], 'Email Wrapper created');
		Test.stopTest();
	}
	/**
	 * @Jira CC-491
	 * @description - Tests the invocation of the createEmailWrapper which will return email wrapper
	 * @param       - None
	 **/
	public static List<List<DH_DexOutServiceRisEIEmailRequest>> runCreateEmailWrapperTest(Map<Id, User> userMap) {
		Map<String, String> dynamicTableColumnMapEmail = DH_CustomMetadataDao.getAttributeLabelVsAttributeName('DH_DexOutServiceRisEIEmailRequest');

		Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' AND DH_Patient_Key__c = '12345' AND DH_System_Id__c = 'system123' LIMIT 1];
		List<EngagementInteraction> eIList = [SELECT Id,Reason,StartDateTime,DH_ClinicalServiceRequest__r.DH_Order_Key__c,DH_JobId__c,DH_BatchId__c,DH_EmailId__c,ExternalIdentifier,CommunicationChannel,DH_JourneyName__c, DH_JourneyTouchPoint__c,Status,DH_Account__r.Region__c, DH_Account__r.DH_Patient_Key__c,DH_Content_Body__c,PhoneNumber FROM EngagementInteraction WHERE DH_Account__c = :acc.Id LIMIT 2];
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
		
		Map<String, et4ae5__IndividualEmailResult__c> ierMap = DH_ContactCenterCachingUtility.getIerMap(request);
        List<List<DH_DexOutServiceRisEIEmailRequest>> emailWrapperList = new List<List<DH_DexOutServiceRisEIEmailRequest>>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				emailWrapperList.add(DH_GeneralUtility.createEmailWrapper(eIList,ierMap,dynamicTableColumnMapEmail));
            }
		}
        return emailWrapperList;
	}
    /**
	 * @Jira CC-491
	 * @description - Tests the invocation of the createSmsWrapper which will return Sms wrapper
	 * @param       - None
	 **/
	@isTest
	public static void createSmsWrapperTest() {
		Map<Id, User> userEastMap = DH_TestDataFactory.getEastUsers();
		Map<Id, User> userWestMap = DH_TestDataFactory.getWestUsers();
		Test.startTest();
			List<List<DH_DexOutServiceRisEISmsRequest>> smswrapperList1 = runCreateSmsWrapperTest(userEastMap);
            System.assertNotEquals(null,smswrapperList1[0],'SMS Wrapper created');
            System.assertNotEquals(null,smswrapperList1[1],'SMS Wrapper created');
            List<List<DH_DexOutServiceRisEISmsRequest>> smswrapperList2 = runCreateSmsWrapperTest(userWestMap);
            System.assertNotEquals(null,smswrapperList2[0],'SMS Wrapper created');
            System.assertNotEquals(null,smswrapperList2[1],'SMS Wrapper created');
		Test.stopTest();
	}
	/**
	 * @Jira CC-491
	 * @description - Tests the invocation of the createSmsWrapper which will return Sms wrapper
	 * @param       - None
	 **/
	public static List<List<DH_DexOutServiceRisEISmsRequest>> runCreateSmsWrapperTest(Map<Id, User> userMap) {
		Map<String, String> dynamicTableColumnMapSms = DH_CustomMetadataDao.getAttributeLabelVsAttributeName('DH_DexOutServiceRisEISmsRequest');

		Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' AND DH_Patient_Key__c = '12345' AND DH_System_Id__c = 'system123' LIMIT 1];
		List<EngagementInteraction> eIList = [SELECT Id,Reason,StartDateTime,DH_ClinicalServiceRequest__r.DH_Order_Key__c,DH_JobId__c,DH_BatchId__c,DH_EmailId__c,ExternalIdentifier,CommunicationChannel,DH_JourneyName__c, DH_JourneyTouchPoint__c,Status,DH_Account__r.Region__c, DH_Account__r.DH_Patient_Key__c,DH_Content_Body__c,PhoneNumber FROM EngagementInteraction WHERE DH_Account__c = :acc.Id LIMIT 2];
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
        List<List<DH_DexOutServiceRisEISmsRequest>> smsWrappeList = new List<List<DH_DexOutServiceRisEISmsRequest>>();
		for (User userRec : userMap.values()) {
			System.runAs(userRec) {
				smsWrappeList.add(DH_GeneralUtility.createSmsWrapper(eIList,dynamicTableColumnMapSms));
            }
		}
        return smsWrappeList;
	}
}