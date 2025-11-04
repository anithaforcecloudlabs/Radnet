@isTest
public class DH_RisStudyProcessorTest {
	@TestSetup
	static void setupMethod() {
		Profile integrationProfile = [SELECT Id FROM Profile WHERE Name = 'Salesforce API Only System Integrations'];
		PermissionSet intPermission = [SELECT Id FROM PermissionSet WHERE Name = 'DH_IntegrationPermissionset'];
		PermissionSet hcPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'HealthCloudFoundation'];

		User apiUser = new User(Alias = 'userWest', Email = 'apiTestUser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'API Test User', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = integrationProfile.Id, TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = false, UserName = 'apiTestUser@testorg.com');
		insert apiUser;

		// Assign permissions
		insert new PermissionSetAssignment(AssigneeId = apiUser.Id, PermissionSetId = hcPermissionSet.Id);

		// Add API license
		PermissionSetLicense apiLicense = [SELECT Id, MasterLabel FROM PermissionSetLicense WHERE MasterLabel = 'Salesforce API Integration' LIMIT 1];
		insert new PermissionSetLicenseAssign(AssigneeId = apiUser.Id, PermissionSetLicenseId = apiLicense.Id);

		//insert Integratin permissionset
		insert new PermissionSetAssignment(AssigneeId = apiUser.Id, PermissionSetId = intPermission.Id);

		// Query and add groups
		List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName IN ('AZ_Region_Team', 'NE_Region_Team', 'FL_Region_Team', 'MA_Region_Team', 'CA_Region_Team')];
		List<GroupMember> groupMembers = new List<GroupMember>();
		for (Group grp : groups) {
			groupMembers.add(new GroupMember(GroupId = grp.Id, UserOrGroupId = apiUser.Id));
		}
		insert groupMembers;
	}
	@isTest
	static void studyProcessor() {
		User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser1) {
			Account patientAcc = new Account(LastName = 'Test Patient', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId());
			insert patientAcc;

			//insert order
			ClinicalServiceRequest csr = new ClinicalServiceRequest(PatientId = patientAcc.Id, DH_RIS_OrderKey__c = 'CA_12345_Clinical Service Request', Type = 'Option', Status = 'Draft');
			insert csr;

			//wrapper for testData
			DH_PatientInfoWrapper wrapper = createTestWrapper();
			DH_PatientInfoWrapper wrapper2 = updateTestWrapper();
			DH_RisStudyProcessor studyProcessor = new DH_RisStudyProcessor();

			Test.startTest();
			Id studyId = studyProcessor.studyProcessor(patientAcc.Id, csr.Id, wrapper);
			Id studyId2 = studyProcessor.studyProcessor(patientAcc.Id, csr.Id, wrapper2);
			Test.stopTest();

			//assertions
			System.assertNotEquals(null, studyId);
			System.assertEquals(studyId, studyId, 'Study and related records Created');
			System.assertEquals(studyId2, studyId2, 'Study and related records Updated');
		}
	}
	//mock wrapper for Insert Data for all methods
	private static DH_PatientInfoWrapper createTestWrapper() {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		String json = DH_RisTestDataFactory.InsertParase();
		return utility.formatJSON(json);
	}
	//mock wrapper for update Data for all methods
	private static DH_PatientInfoWrapper updateTestWrapper() {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		String json = DH_RisTestDataFactory.updatedData();
		return utility.formatJSON(json);
	}
}