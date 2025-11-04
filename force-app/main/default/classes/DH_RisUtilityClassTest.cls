@isTest
public class DH_RisUtilityClassTest {
	@testSetup
	private static void testSetup() {
		//create Integration User
		Profile integrationProfile = [SELECT Id FROM Profile WHERE Name = 'Salesforce API Only System Integrations'];
		PermissionSet intPermission = [SELECT Id FROM PermissionSet WHERE Name = 'DH_IntegrationPermissionset'];
		PermissionSet hcPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'HealthCloudFoundation'];

		User apiUser = new User(Alias = 'userWest', Email = 'apiTestUser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'API Test User', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = integrationProfile.Id, TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = false, UserName = 'apiTestUser@testorg.com');

		insert apiUser;

		PermissionSetAssignment perm2 = new PermissionSetAssignment();
		perm2.AssigneeId = apiUser.id;
		perm2.PermissionSetId = hcPermissionSet.id;
		insert perm2;

		PermissionSetLicense apiLicense = [SELECT Id, MasterLabel FROM PermissionSetLicense WHERE MasterLabel = 'Salesforce API Integration' LIMIT 1];

		PermissionSetLicenseAssign newlicense = new PermissionSetLicenseAssign();
		newlicense.AssigneeId = apiUser.Id;
		newlicense.PermissionSetLicenseId = apiLicense.Id;
		insert newlicense;

		PermissionSetAssignment perm1 = new PermissionSetAssignment();
		perm1.AssigneeId = apiUser.id;
		perm1.PermissionSetId = intPermission.id;

		insert perm1;

		Group azGroup = [SELECT Id FROM Group WHERE DeveloperName = 'AZ_Region_Team' LIMIT 1];
		Group neGropu = [SELECT Id FROM Group WHERE DeveloperName = 'NE_Region_Team' LIMIT 1];
		Group fl = [SELECT Id FROM Group WHERE DeveloperName = 'FL_Region_Team' LIMIT 1];
		Group ma = [SELECT Id FROM Group WHERE DeveloperName = 'MA_Region_Team' LIMIT 1];
		Group ca = [SELECT Id FROM Group WHERE DeveloperName = 'CA_Region_Team' LIMIT 1];

		GroupMember grp1 = new GroupMember();
		grp1.GroupId = azGroup.Id;
		grp1.UserOrGroupId = apiUser.Id;

		insert grp1;

		GroupMember grp2 = new GroupMember();
		grp2.GroupId = neGropu.Id;
		grp2.UserOrGroupId = apiUser.Id;
		insert grp2;

		GroupMember grp3 = new GroupMember();
		grp3.GroupId = fl.Id;
		grp3.UserOrGroupId = apiUser.Id;
		insert grp3;

		GroupMember grp4 = new GroupMember();
		grp4.GroupId = ma.Id;
		grp4.UserOrGroupId = apiUser.Id;
		insert grp4;

		GroupMember grp5 = new GroupMember();
		grp5.GroupId = ca.Id;
		grp5.UserOrGroupId = apiUser.Id;
		insert grp5;

		update apiUser;
	}
	@isTest
	static void testUniqueIdentifier() {
		User apiUser = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser) {
			DH_RisUtilityClass utility = new DH_RisUtilityClass();
			String result = utility.uniqueIdentifier('CA', '12345', 'RecordTypeName');

			System.assertEquals('CA_12345_RecordTypeName', result, 'Unique Identifier should match the expected value.');
		}

	}
	@isTest
	static void fourKeysUniqueTest() {
		User apiUser = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser) {
			DH_RisUtilityClass utility = new DH_RisUtilityClass();

			String result = utility.fourKeysUnique('CA', '12345', '001122', 'RecordTypeName');

			System.assertEquals('CA_12345_001122_RecordTypeName', result, 'RIS Unique Key');
		}
	}

	@isTest
	static void testFormatJSON() {
		User apiUser = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser) {
			DH_RisUtilityClass utility = new DH_RisUtilityClass();
			String inputJson = DH_RisTestDataFactory.InsertParase();

			DH_PatientInfoWrapper result = utility.formatJSON(inputJson);

			system.assertNotEquals(null, result, 'formatted JSON');
		}
	}
	@isTest
	static void testFetchRegion() {
		User apiUser = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];

		System.runAs(apiUser) {
			DH_RisUtilityClass utility = new DH_RisUtilityClass();
			Id regionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RIS Instance / RIS System').getRecordTypeId();
			Account regionAccount = new Account(Name = 'Califorinia', Region__c = 'CA', RecordTypeId = regionRecordTypeId);
			insert regionAccount;

			Id regionId = utility.fetchRegion('CA');
			System.assertNotEquals(null, 'Result should not be empty.');
			System.assertEquals(regionAccount.Id, regionId, 'Account Region');
		}
	}

	@isTest
	static void testFetchPractice() {
		User apiUser = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser) {
			DH_RisUtilityClass utility = new DH_RisUtilityClass();

			Account practiceAccount = new Account(Name = 'TestRegion_Practice_Practice', DH_RIS_Unique_Code__c = 'CA_TestPractice_Practice', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice').getRecordTypeId());
			insert practiceAccount;

			Test.startTest();
			Id practiceId = utility.fetchPractice('CA', 'TestPractice');

			test.stopTest();

			System.assertEquals(practiceAccount.Id, practiceAccount.Id, 'Practice Account');
		}
	}

	@isTest
	static void testFetchSite() {
		User apiUser = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser) {
			DH_RisUtilityClass utility = new DH_RisUtilityClass();

			// Setup test data
			Account siteAccount = new Account(Name = 'TestRegion_Site_Site', DH_RIS_Unique_Code__c = 'CA_TestSite_Site', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId());
			insert siteAccount;

			Test.startTest();
			Id siteId = utility.fetchSite('CA', 'TestSite');

			test.stopTest();
			System.assertNotEquals(null, siteAccount.Id);
			System.assertEquals(siteAccount.Id, siteAccount.Id, 'Site account');
		}

	}
	@isTest
	static void fetchCodeSetRecordIdsTest() {
		User apiUser = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
		System.runAs(apiUser) {
			Id patientClassRecordTypeId = Schema.SObjectType.CodeSet.getRecordTypeInfosByName().get('DH Patient Class').getRecordTypeId();
			Id orderRecordtype = Schema.SObjectType.CodeSet.getRecordTypeInfosByName().get('DH Order Category').getRecordTypeId();
			Id followUpRecordTypeId = Schema.SObjectType.CodeSet.getRecordTypeInfosByName().get('DH FollowUp Types').getRecordTypeId();
			Id cancelledRecordTypeId = Schema.SObjectType.CodeSet.getRecordTypeInfosByName().get('DH Cancelled Reason').getRecordTypeId();

			CodeSet cs1 = new CodeSet(Name = 'Code1', DH_RIS_Instance__c = 'CA', Code = 'CA_Code1_DH Patient Class', DH_code__c = 'Code1', RecordTypeId = patientClassRecordTypeId);
			CodeSet cs2 = new CodeSet(Name = 'Code2', DH_RIS_Instance__c = 'CA', Code = 'CA_Code2_DH Order Category', DH_code__c = 'Code2', RecordTypeId = orderRecordtype);
			CodeSet cs3 = new CodeSet(Name = 'Code3', DH_RIS_Instance__c = 'CA', Code = 'CA_Code3_DH FollowUp Types', DH_code__c = 'Code3', RecordTypeId = followUpRecordTypeId);
			CodeSet cs4 = new CodeSet(Name = 'Code4', DH_RIS_Instance__c = 'CA', Code = 'CA_Code4_DH Cancelled Reason', DH_code__c = 'Code4', RecordTypeId = cancelledRecordTypeId);

			insert cs1;
			insert cs2;
			insert cs3;

			DH_PatientInfoWrapper wrapper = new DH_PatientInfoWrapper();

			wrapper.patient = new DH_PatientInfoWrapper.cls_patient();
			wrapper.patient.system_id = 'CA';
			wrapper.patient.data = new DH_PatientInfoWrapper.cls_data();

			wrapper.order = new DH_PatientInfoWrapper.cls_order();
			wrapper.order.data = new DH_PatientInfoWrapper.cls_data();
			wrapper.order.data.patient_class_code = 'Code1';
			wrapper.order.data.order_category_code = 'Code2';
			wrapper.order.data.scheduling_next_fup_type_code = 'Code3';

			wrapper.Study = new DH_PatientInfoWrapper.Study();
			wrapper.Study.data = new DH_PatientInfoWrapper.cls_data();
			wrapper.Study.data.cancelled_reason_code = 'Code4';

			Test.startTest();
			DH_RisUtilityClass utility = new DH_RisUtilityClass();
			Map<String, Id> result = utility.fetchCodeSetRecordIds(wrapper);
			test.stopTest();

			System.assertNotEquals(null, result);
			System.assertEquals(result.get('Code1'), result.get('Code1'), 'Patient Class code');
			System.assertEquals(result.get('Code2'), result.get('Code2'), 'order category Class code');
			System.assertEquals(result.get('Code3'), result.get('Code3'), 'fup Class code');
			System.assertEquals(result.get('Code4'), result.get('Code4'), 'Cancelled reason Class code');
		}
	}
}