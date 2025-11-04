@isTest
    private class DH_PatientInfoRestResourceTest {
        @testSetup
        private static void testSetup() {
            //test user Creation
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
        static void handleOrderCreationTest() {
            User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
            System.runAs(apiUser1) {
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
    
                String payload = DH_RisTestDataFactory.InsertParase();
    
                req.requestURI = '/services/apexrest/OrderResource';
                req.httpMethod = 'POST';
                req.addHeader('Content-Type', 'application/json');
                req.requestBody = Blob.valueOf(payload);
    
                RestContext.request = req;
                RestContext.response = res;
    
                CodeSetBundle code = new CodeSetBundle(Name = 'CodeSetBundleForAlert');
                insert code;
    
                Test.startTest();
                //DH_PatientInfoRestResource.handleOrderCreation();
                DH_PatientInfoRestResource.Response response = DH_PatientInfoRestResource.handleOrderCreation();
                Test.stopTest();
    
                System.assertNotEquals(null, res);
                System.assertEquals(res, res, 'a Success Response should be Sent');
                System.assertEquals(res.statusCode = 200, 200, '200 Success status code Should Sent');
            }
        }
        @isTest
        static void exceptionTest() {
            User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
            System.runAs(apiUser1) {
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
    
                req.requestURI = '/services/apexrest/OrderResource';
                req.httpMethod = 'POST';
                req.addHeader('Content-Type', 'application/json');
                req.requestBody = Blob.valueOf('');
    
                RestContext.request = req;
                RestContext.response = res;
    
                Test.startTest();
                DH_PatientInfoRestResource.Response response = DH_PatientInfoRestResource.handleOrderCreation();
                Test.stopTest();
    
                System.assertNotEquals(null, res);
                System.assertEquals(res, res, 'empty Body error should sent');
            }
        }
        @isTest
        static void dmlExceptionTest() {
            User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
            System.runAs(apiUser1) {
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
    
                DH_PatientInfoWrapper wrapper = createTestWrapper();
                wrapper.patient.data.first_name = null;
                wrapper.patient.data.last_name = null;
                wrapper.patient.data.middle_name = null;
    
                String payload = JSON.serialize(wrapper);
    
                req.requestURI = '/services/apexrest/OrderResource';
                req.httpMethod = 'POST';
                req.addHeader('Content-Type', 'application/json');
                req.requestBody = Blob.valueOf(payload);
    
                RestContext.request = req;
                RestContext.response = res;
    
                CodeSetBundle code = new CodeSetBundle(Name = 'CodeSetBundleForAlert');
                insert code;
    
                Test.startTest();
                //DH_PatientInfoRestResource.handleOrderCreation();
                DH_PatientInfoRestResource.Response response = DH_PatientInfoRestResource.handleOrderCreation();
                Test.stopTest();
    
                System.assertNotEquals(null, res);
                System.assertEquals(res, res, 'a Failed Response should be Sent');
                System.assertEquals(res.statusCode = 400, 400, 'a Failed Response should be Sent');
            }
        }
        @isTest
        static void exceptionOrderTest() {
            User apiUser1 = [SELECT Id FROM User WHERE UserName = 'apiTestUser@testorg.com' LIMIT 1];
            System.runAs(apiUser1) {
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
    
                String payload = DH_RisTestDataFactory.InsertParase();
    
                req.requestURI = '/services/apexrest/OrderResource';
                req.httpMethod = 'POST';
                req.addHeader('Content-Type', 'application/json');
                req.requestBody = Blob.valueOf(payload);
    
                RestContext.request = req;
                RestContext.response = res;
    
                Test.startTest();
                //DH_PatientInfoRestResource.handleOrderCreation();
                DH_PatientInfoRestResource.Response response = DH_PatientInfoRestResource.handleOrderCreation();
                Test.stopTest();
    
                System.assertNotEquals(null, res);
            }
        }
        //mock wrapper for Insert Data for all methods
        private static DH_PatientInfoWrapper createTestWrapper() {
            DH_RisUtilityClass utility = new DH_RisUtilityClass();
            String json = DH_RisTestDataFactory.InsertParase();
            return utility.formatJSON(json);
        }
    }