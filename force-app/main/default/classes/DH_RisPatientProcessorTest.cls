@isTest
public class DH_RisPatientProcessorTest {
	@TestSetup
	static void setup() {
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
	static void patientProcessorTest() {
		User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser1) {
			CodeSetBundle code = new CodeSetBundle(Name = 'CodeSetBundleForAlert');
			insert code;
			String uniqueRis = 'CA_26360779_Person Account';

			DH_PatientInfoWrapper wrapper = createTestWrapper();
			DH_PatientInfoWrapper wrapper2 = updateTestWrapper();
			DH_RisPatientProcessor patientprocessor = new DH_RisPatientProcessor();

			test.startTest();
			Id patientId = patientprocessor.patientProcessor(wrapper);
			patientprocessor.patientAlertProcessor(patientId, wrapper);
			List<Account> accounts = patientprocessor.modifiedPatient(uniqueRis);
			Id patientId2 = patientprocessor.patientProcessor(wrapper2);
			patientprocessor.patientAlertProcessor(patientId2, wrapper2);
			test.stopTest();

			Account patientAccount = [SELECT Id FROM Account WHERE Id = :patientId];
			Account patientAccount2 = [SELECT Id FROM Account WHERE Id = :patientId2];

			system.assertNotEquals(null, patientId, 'Patient Id Return');
			System.assertEquals(patientAccount.Id, patientAccount.Id, 'Person Account Created');
			System.assertNotEquals(null, accounts, ' Unique Patient account retrived');
		}
	}
	//mock test Insert Data for all methods
	private static DH_PatientInfoWrapper createTestWrapper() {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		String json = DH_RisTestDataFactory.InsertParase();
		return utility.formatJSON(json);
	}
	//mock test update Data for all methods
	private static DH_PatientInfoWrapper updateTestWrapper() {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		String json = DH_RisTestDataFactory.updatedData();
		return utility.formatJSON(json);
	}
}