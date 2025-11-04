@isTest
public class DH_RisBaseProcessorTest {
	public class TestDH_RisBaseProcessor extends DH_RisBaseProcessor {
		public TestDH_RisBaseProcessor() {
			super();
		}

		public String testGetUniqueKey(String systemID, String itemKey, String risKey, String recordTypeName) {
			return getUniqueKey(systemID, itemKey, risKey, recordTypeName);
		}

		public String testGetUniqueKey(String systemID, String risKey, String recordTypeName) {
			return getUniqueKey(systemID, risKey, recordTypeName);
		}

		public String testGetUniqueKey(String systemID, String risKey) {
			return getUniqueKey(systemID, risKey);
		}
	}
	@TestSetup
	static void setupData() {
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
	static void testGetUniqueKeyWithFourParameters() {
		User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser1) {
			TestDH_RisBaseProcessor processor = new TestDH_RisBaseProcessor();
			String result = processor.testGetUniqueKey('CA', '1234', '1122', 'RecordTypeName');
			System.assertEquals('CA_1234_1122_RecordTypeName', result, 'four unique');
		}

	}
	@isTest
	static void testGetUniqueKeyWithThreeParameters() {
		User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser1) {
			TestDH_RisBaseProcessor processor = new TestDH_RisBaseProcessor();
			String result = processor.testGetUniqueKey('CA', '1234', 'RecordTypeName');
			System.assertEquals('CA_1234_RecordTypeName', result, '3 Unique Keys');
		}
	}
	@isTest
	static void testGetUniqueKeyWithTwoParameters() {
		User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser1) {
			TestDH_RisBaseProcessor processor = new TestDH_RisBaseProcessor();
			String result = processor.testGetUniqueKey('CA', '1234');
			System.assertEquals('CA_1234', result, 'TwoUniqueKeys');
		}
	}
}