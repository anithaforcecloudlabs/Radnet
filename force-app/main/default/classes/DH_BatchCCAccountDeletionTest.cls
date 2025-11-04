/*
 * ***************************************************************************************************************************
 * Apex Class Name : DH_BatchCCAccountDeletionTest
 * Created Date : 14-August-2024
 * @description : Test class for DH_BatchCCAccountDeletion
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-1170                  14-August-2024       Original Version
 * CC-1203                  17-September-2024    Changes related to Profile update in testSetup and testBatch methods
 * ***************************************************************************************************************************
 */
@isTest
public class DH_BatchCCAccountDeletionTest {
	/**
	 * @Jira CC-1170
	 * @description - creates user to access across all methods
	 * @param       - none
	 * @return      - none
	 **/
	@TestSetup
	static void setup() {
		User radnetBatchSchedulerUser = DH_TestDataFactory.createRadNetBatchSchedulerUser();
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);
		Profile integrationProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User apiUser = new User(Alias = 'userWest', Email = 'apiTestUser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'API Test User', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = integrationProfile.Id, TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = false, UserName = 'apiTestUser@testorg.com', FederationIdentifier = 'test.PSL@devpro.com');
		insert apiUser;
		VoiceCall vc;
		VoiceCall vc2;
		System.runAs(apiUser) {
			vc = DH_TestDataFactory.createVoiceCallRecord('+1578782168', '+1649693498', '+1649693498', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
			insert vc;
			vc2 = DH_TestDataFactory.createVoiceCallRecord('+1578782170', '+1649693492', '+1649693492', 'ContactCenter', datetime.now(), datetime.now(), 'Inbound', 'CA');
			insert vc2;
		}
		System.runAs(radnetBatchSchedulerUser) {
			Account pat = DH_GeneralUtility.createNewPatientServicePatient(vc);
			Test.setCreatedDate(pat.Id, DateTime.newInstance(2023, 2, 1));
			Account pat2 = DH_GeneralUtility.createNewPatientServicePatient(vc2);
			Test.setCreatedDate(pat.Id, DateTime.newInstance(2023, 1, 1));
			Test.setCreatedDate(pat2.Id, DateTime.newInstance(2023, 1, 1));
			ClinicalServiceRequest csr = new ClinicalServiceRequest();
			csr.PatientId = pat2.id;
			csr.Status = 'OrderSigned';
			csr.Type = system.label.csr_type;
			insert csr;
			ClinicalServiceRequestDetail csd = new ClinicalServiceRequestDetail();
			csd.ClinicalServiceRequestId = csr.id;
			csd.DetailType = system.label.csd_detailType;
			csd.DetailRecordId = csr.id;
			insert csd;
		}
	}
	/**
	 * @Jira CC-1170
	 * @description - This test Class method will test positive scenario
	 * @param       - none
	 * @return      - none
	 **/
	@isTest
	public static void testBatch() {
		User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		String cronExp = '0 0 * * * ?';
		Account pat = [SELECT Id FROM Account WHERE DH_status__c = 'Draft' AND lastName = '+1649693498' LIMIT 1];
		System.runAs(radnetBatchSchedulerUser){
			Test.startTest();
			DH_BatchCCAccountDeletionScheduler scheduler = new DH_BatchCCAccountDeletionScheduler();
			String jobId = System.schedule('Schedule batch for '+radnetBatchSchedulerUser.Username, cronExp, scheduler);
			List<Account> deletedPat = [SELECT Id FROM Account WHERE Id = :pat.Id];
			System.assertEquals(1, deletedPat.size(), 'Account should not delete');
			System.assertNotEquals(null, jobId,'a Batch should be Executed');
			Test.stopTest();
		}
	}
}