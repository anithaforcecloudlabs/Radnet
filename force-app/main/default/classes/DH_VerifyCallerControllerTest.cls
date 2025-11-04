/*
 * ***********************************************************************************************************************************************
 * Apex Class Name - DH_VerifyCallerControllerTest
 * Created Date - 27-May-2024
 * @description : Test Class for DH_VerifyCallerController.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-425                   22-May-2024          Added vcColumsTest,getVoiceCallRecordSchedulerTest and getVoiceCallRecordManagerTest methods.
 * CC-426                   27-May-2024          Addded getExpiryTimeForApiTest, getUserFederationIdTest and getPatientSearchedDataTest methods.
 * CC-428                   30-May-2024          Addded mapVoiceCallToPersonAccountTest and searchPatientInSfTest methods.
 * CC-429                   30-May-2024          Addded upsertPatientInSfTest methods.
 * CC-430                   28-May-2024          Addded getDynamicTableColumnsRecordsForSearchTest method.
 * CC-428                   17-July-2024         Replaced Date_Of_Birth with standard field personBirthDate in upsertPatientInSfTest method
 * CC-482-507               25-July-2024         Added SystemId in createVoiceCallRecord method and updated getExpiryTimeForApiTest method
 * CC-481,CC-572,CC-590     22-August-2024       Added createNewPatientTest and invokeNewPatientServiceTest method
 * CC-716                   30-August-2024       Removed getPatientSearchedDataTest and getUserFederationIdTest methods	
 * CC-692                   02-September-2024    Added getPreviousVerifiedPatientTest
 * CC-1203                  17-September-2024    Updated all existing methods for profile update. 
 * CC-425					08-October-2024		 Changes related to code optimization and code coverage.  
 * CC-1439                  30-October-2024		 Replaced instances of FromPhoneNumber with F9_Call_ANI__c, and added F9_Call_ANI__c field while creating VoiceCall Record
 * CC-1518				   03-Mar-2025          PhoneNumber format change impact fix
 * ************************************************************************************************************************************************
 */
@isTest
private class DH_VerifyCallerControllerTest {
	/**
	 * @Jira CC-425,426
	 * @description - Creates reusable test data that can be used across multiple test methods within the same class.
	 * @param       - None
	 **/
	@testSetup
	public static void setup() {
		User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
		User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
		User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
		User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
		List<Account> accList = DH_TestDataFactory.createPatientRecord();
		Account pat = DH_TestDataFactory.createAccount('Test', 'Test', 'CA', DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
		insert pat;
        List<VoiceCall> voiceCallList = new List<VoiceCall>();
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        VoiceCall voiceCallRecord1 = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
        VoiceCall voiceCallRecord2 = DH_TestDataFactory.createVoiceCallRecord('+1578782169', '+1649693499', '1649693499', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
        VoiceCall voiceCallRecord3 = DH_TestDataFactory.createVoiceCallRecord('+1578782170', '+1649693492', '1649693492', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
        VoiceCall vc1 = new VoiceCall(FromPhoneNumber = '+1999999999', F9_Call_ANI__c = '+1999999999', RelatedRecordId = accList[0].personcontactId, callCenterId = callCenterId.Id, VendorType = 'ContactCenter', CallStartDateTime = datetime.now(), CallEndDateTime = datetime.now(), ToPhoneNumber = '+1578782168', CallType = 'Inbound');
		VoiceCall vc = new VoiceCall(FromPhoneNumber = '+1999999999', F9_Call_ANI__c = '+1999999999', RelatedRecordId = accList[0].personcontactId, callCenterId = callCenterId.Id, VendorType = 'ContactCenter', CallStartDateTime = datetime.now(), CallEndDateTime = datetime.now(), ToPhoneNumber = '+1578782168', CallType = 'Inbound', PreviousCallId = vc1.Id, CallDisposition = 'In-progress');
		voiceCallList.add(vc1);
        voiceCallList.add(vc);
        voiceCallList.add(voiceCallRecord1);
        voiceCallList.add(voiceCallRecord2);
        voiceCallList.add(voiceCallRecord3);
        insert voiceCallList;
        List<VoiceCall> updatedList = new List<VoiceCall>();
        VoiceCall var = DH_TestDataFactory.assignVcOwner(voiceCallRecord2.id, radnetSchedulerEast.id);
        updatedList.add(var);
        VoiceCall var1 = DH_TestDataFactory.assignVcOwner(voiceCallRecord3.id, radnetManagerEast.id);
        updatedList.add(var1);
        update updatedList;
        DH_PayloadData__c payLoadRecord = DH_TestDataFactory.createPayLoadRecord('https://patientsearchaggregator-api-ris.riosplatform.com/api/v1/patientsearchaggregator/patients', voiceCallRecord1.Id, '{"systemId":null,"recordId":null,"phoneNumber":null,"patientMRN":null,"lastName":null,"firstName":"RadNetUserTest","email":"radnet3245@gmail.com","dateOfBirth":null,"accessionNumber":null}');
        insert payLoadRecord;		
	}
	/**
	 * @Jira CC-425
	 * @description - Checks if the vcColumsTest returns the correct number of columns from the metadata.
	 * @param       - None
	 **/
	@isTest
	public static void vcColumsTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
		Test.startTest();
		List<DH_DynamicTableColumns__mdt> mc;
		for (User userRec : userList) {
			System.runAs(userRec) {
				mc = DH_VerifyCallerController.getDynamicTableColumnsRecords();
				System.assertEquals(7, mc.size(), 'Error occurred while retrieving the metadata record');
			}
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-425
	 * @description - Checks if the getVoiceCallRecordSchedulerTest returns the correct data and voice call record for scheduler user from Ris System.
	 * @param       - None
	 **/
	@isTest
	public static void getVoiceCallRecordSchedulerTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());

		VoiceCall voiceCallRecord3 = [SELECT ID, OwnerId FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3499' LIMIT 1];
		Test.startTest();
		for (User userRec : userList) {
			System.runAs(userRec) {
				VoiceCall result = DH_VerifyCallerController.getVoiceCallRecord(voiceCallRecord3.id);
				System.assertEquals(result.F9_Call_ANI__c, '(164) 969-3499', 'Incorrect number of voice calls returned');
			}
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-425
	 * @description - Checks if the getVoiceCallRecordManagerTest returns the correct data and voice call record for Manager user from Ris System.
	 * @param       - None
	 **/
	@isTest
	public static void getVoiceCallRecordManagerTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
		VoiceCall vc = [SELECT ID, OwnerId FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3499' LIMIT 1];
		VoiceCall result = new VoiceCall();
		Test.startTest();
		for (User userRec : userList) {
			System.runAs(userRec) {
				result = DH_VerifyCallerController.getVoiceCallRecord(vc.id);
				System.assertEquals(result.F9_Call_ANI__c, '(164) 969-3499', 'Incorrect number of voice calls returned');
			}
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-428
	 * @description - mapVoiceCallToPersonAccountTest validates functionality of mapVoiceCallToPersonAccount method.
	 * @param       - None
	 **/
	@isTest
	public static void mapVoiceCallToPersonAccountTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
		VoiceCall vc = [SELECT ID, OwnerId,F9_Call_ANI__c FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3499' LIMIT 1];
        Account eastAccount = [SELECT Id,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account'];
		Account westAccount = [SELECT Id,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account'];
        Account pat = new Account();
		Test.startTest();
		for (User userRec : userList) {
			System.runAs(userRec) {
                if(userRec.DH_User_Region__c == 'East'){
					pat = eastAccount;
                }else{
                    pat = westAccount;
                }
				DH_VerifyCallerController.mapVoiceCallToPersonAccount(vc.id, pat.id);
				System.assertEquals(true, pat.id != null, 'Record dosent Match');
			}
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-430
	 * @description - Test method to check the functionality of getDynamicTableColumnsRecordsForSearch method.
	 * @param       - None
	 **/
	@isTest
	public static void getDynamicTableColumnsRecordsForSearchTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
		Test.startTest();
		for (User userRec : userList) {
			System.runAs(userRec) {
				List<DH_DynamicTableColumns__mdt> columnList = DH_VerifyCallerController.getDynamicTableColumnsRecordsForSearch();
				System.assertEquals(5, columnList.size(), 'Error occurred while retrieving the metadata record');
			}
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-430
	 * @description - Test method to check the functionality of getExpiryTimeForApi method.
	 * @param       - None
	 **/
	@isTest
	public static void getExpiryTimeForApiTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
		Test.startTest();
		for (User userRec : userList) {
			System.runAs(userRec) {
				String expiryInSec = DH_VerifyCallerController.getExpiryTimeForApi();
				System.assertEquals(Integer.valueOf(30000), Integer.valueOf(expiryInSec), 'Time out in Patient Search setting metadata is not 15000');
			}
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-572,CC-481
	 * @description - Tests the invocation of the invokeNewPatientService
	 * @param       - None
	 **/
	@isTest
	static void invokeNewPatientServiceTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());

		VoiceCall voiceCallRecord = [SELECT ID, Name,F9_Call_ANI__c FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3499' LIMIT 1];
		Account eastAccount = [SELECT Id,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'FL_123451_Person Account'];
		Account westAccount = [SELECT Id,Region__c FROM Account WHERE DH_RIS_Unique_Code__c = 'AZ_123453_Person Account'];
        Account pat = new Account();
		Test.startTest();
		for (User userRec : userList) {
			System.runAs(userRec) {
                if(userRec.DH_User_Region__c == 'East'){
					pat = eastAccount;
                }else{
                    pat = westAccount;
                }
				DH_DexOutGeneralServiceResponse response = DH_VerifyCallerController.invokeNewPatientService(voiceCallRecord.Id, pat);
				System.assertNotEquals(null, response, 'Response Received');
			}
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-572,CC-481,CC-590
	 * @description - Tests the invocation of the createNewPatient
	 * @param       - None
	 **/
	@isTest
	static void createNewPatientTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
		VoiceCall voiceCallRecord = [SELECT ID, Name, F9_Call_ANI__c FROM VoiceCall WHERE F9_Call_ANI__c = '(164) 969-3499' LIMIT 1];
		Test.startTest();
		for (User userRec : userList) {
			System.runAs(userRec) {
				Account acc = DH_VerifyCallerController.createNewPatient(voiceCallRecord.Id);
				system.assertNotEquals(null, acc, 'Person account Created');
			}
		}
		Test.stopTest();
	}
	/**
	 * @Jira CC-692
	 * @description - Tests the invocation of the getPreviousVerifiedPatient
	 * @param       - None
	 **/
	@isTest
	public static void getPreviousVerifiedPatientTest() {
		Map<Id,User> userEastMap = DH_TestDataFactory.getEastUsers();
        Map<Id,User> userWestMap = DH_TestDataFactory.getWestUsers();
		List<User> userList = userEastMap.values();
        userList.addAll(userWestMap.values());
		List<VoiceCall> vcList =[SELECT ID, Name,PreviousCallId FROM VoiceCall WHERE F9_Call_ANI__c = '+1999999999'];
		Test.startTest();
		for (User userRec : userList) {
			System.runAs(userRec) {
				Account patient = DH_VerifyCallerController.getPreviousVerifiedPatient(vcList[0].id);
				System.assertEquals(patient, null, 'verified patient not Correct');
			}
		}
		Test.stopTest();
	}
}