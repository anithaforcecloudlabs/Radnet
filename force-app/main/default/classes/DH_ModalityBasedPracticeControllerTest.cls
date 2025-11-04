/*
    *********************************************************

    Apex Class/ LWC Component Name    : DH_ModalityBasedPracticeControllerTest

    Created Date       : April 2, 2024 

    @description       : This test class is used to verify methods in DH_ModalityBasedPracticeController apex class

    @jiraid            : CC-105, CC-792

    *********************************************************
    */

    @isTest
    private class DH_ModalityBasedPracticeControllerTest {
        
        @TestSetup
        public static void setupTestData() {
        Group maRegionTeam = new Group(Name = 'MA Region Team', Type = 'Regular');
        insert maRegionTeam;
        Group neRegionTeam = new Group(Name = 'NE Region Team', Type = 'Regular');
        insert neRegionTeam;
            
        //Create Permission Sets (assume they already exist)
        PermissionSet eastPermSet = [SELECT Id FROM PermissionSet WHERE Name = :DH_KMConstants.MODALITY_SEARCH_PERMISSION_SET];
        PermissionSet ePermSet = [SELECT Id FROM PermissionSet WHERE Name = :DH_KMConstants.USER_EAST];
        PermissionSet healthPermSet = [SELECT Id FROM PermissionSet WHERE Name = :DH_KMConstants.HEALTHCLOUD_FOUNDATION_PERMISSION_SET];
            
            
            // Create East Coast User
            User eastUser = new User(
            FirstName = 'East',
            LastName = 'User',
            Email = 'eastuser@example.com',
            Username = 'eastuser@example.com' + System.currentTimeMillis(),
            Alias = 'eastuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = :DH_KMConstants.RADNET_SCHEDULER].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert eastUser;
        insert new GroupMember(GroupId = maRegionTeam.Id, UserOrGroupId = eastUser.Id);
        insert new GroupMember(GroupId = neRegionTeam.Id, UserOrGroupId = eastUser.Id);
        insert new PermissionSetAssignment(PermissionSetId = eastPermSet.Id, AssigneeId = eastUser.Id);
        insert new PermissionSetAssignment(PermissionSetId = ePermSet.Id, AssigneeId = eastUser.Id);
        insert new PermissionSetAssignment(PermissionSetId = healthPermSet.Id, AssigneeId = eastUser.Id);
        
        }
        
        @isTest
        static void testGetPractice() {
        setupTestData();
        // Test as East Coast User
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
        Test.startTest();
        List<Practice__mdt> practiceList = DH_KMUtility.getPracticeforModalitySearch();
        Test.stopTest();
    
        Assert.isNotNull( practiceList, 'Practice list should not be null');
            
        }
      }
    
        @isTest
        static void testGetModalities() {
        setupTestData();
        // Test as East Coast User
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
        Test.startTest();
        List<Modality__mdt> modalityList = DH_KMUtility.getModalities('TestRegion', 'TestPractice');
        Test.stopTest();
    
        Assert.isNotNull( modalityList, 'Modality list should not be null');
            
        }
    }
    
        @isTest
        static void testGetRecordsBasedOnPractice() {
        setupTestData();
        
        // Test as East Coast User
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Practice_code__c = 'TestPractice';
        insert acc;
        CareSpecialty obj2 = new CareSpecialty();
        obj2.Name='TestModality';
        obj2.CareSpecialty_External_ID__c='TestModalityExt';
        insert obj2;
        HealthCareProcedure obj = new HealthCareProcedure();
    //    obj.RecordTypeId = stExam;
        obj.Name = 'Test';
        obj.Modality_Codes__c = obj2.Id;
        obj.Practice_Codes__c = acc.Id;
        obj.isActive = true;
        insert obj;
        Special_Instructions__c obj1 = new Special_Instructions__c();
        obj1.Name ='Test1';
        obj1.Practice_Codes__c = acc.Id;
        obj1.isActive__c = true;
        insert obj1;
    
            List<String> practice = new List<String>{'TestPractice'};
            List<String> modalities = new List<String>{'TestModality'};
            Test.startTest();
            List<DH_ModalityBasedPracticeController.HealthCareProcedureWrapper> procRecords = DH_ModalityBasedPracticeController.getRecordsBasedOnPractice(practice, modalities);
            Test.stopTest();
    
            Assert.isNotNull( procRecords, 'Procedure records should not be null');
        }
     }
    
        @isTest
        static void testGetNotes() {
            setupTestData();
        // Test as East Coast User
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
            Account acc = new Account();
            acc.Name = 'Test';
            acc.Practice_code__c = 'TestPractice';
            insert acc;
            
        Special_Instructions__c obj1 = new Special_Instructions__c();
            obj1.Name ='Test1';
            obj1.Practice_Codes__c = acc.Id;
            obj1.isActive__c = true;
            insert obj1;
    
            List<String> practice = new List<String>{'TestPractice'};
            List<String> modalities = new List<String>{'TestModality'};
            Test.startTest();
            List<DH_ModalityBasedPracticeController.SpecialInstructionsWrapper> instruct = DH_ModalityBasedPracticeController.getNotes(practice, modalities);
            Test.stopTest();
    
            Assert.isNotNull( instruct, 'Special instructions should not be null');
            
        }   
    }
        
        @isTest
        static void testGetUserType() {
            Test.startTest();
            Boolean result = DH_ModalityBasedPracticeController.getUserType();
            Test.stopTest();
            System.assertEquals(false,result,'Expected user type to be non-guest');
        }
            
                  
        static testMethod void guestUserTest(){
        setupTestData();
        Profile guestProfile = [SELECT Id, name FROM Profile WHERE Name =: DH_KMConstants.RADNET_COMMUNITY_PROFILE LIMIT 1];
            User guestUser = new User(
            Username = 'guestuserAdminPersi@test.com',
            FirstName = 'Guest',
            LastName = 'User',
            Email = 'guestuser@test.com',
            Alias = 'guest',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = guestProfile.Id,
            LanguageLocaleKey = 'en_US'
          );
            
        insert guestUser;
        System.runAs ( guestUser ) {
            
            
    Account acc = new Account();
            acc.Name = 'Test';
            acc.Practice_code__c = 'TestPractice';
            insert acc;
            DH_CareSpecialty__c obj2 = new DH_CareSpecialty__c();
            obj2.Name='TestModality';
            insert obj2;
            DH_HealthCareProcedure__c obj = new DH_HealthCareProcedure__c();
    //    obj.RecordTypeId = stExam;
            obj.Name = 'Test';
            obj.DH_New_Modality_codes__c = obj2.Id;
            obj.DH_Practice_Code_s__c	 = acc.Id;
            obj.DH_Active__c = true;
            insert obj;
        Special_Instructions__c obj1 = new Special_Instructions__c();
            obj1.Name ='Test1';
            obj1.Practice_Codes__c = acc.Id;
            obj1.isActive__c = true;
            insert obj1;
    
            List<String> practice = new List<String>{'TestPractice'};
            List<String> modalities = new List<String>{'TestModality'};
            
            Test.startTest();
            List<DH_ModalityBasedPracticeController.HealthCareProcedureWrapper> procRecords = DH_ModalityBasedPracticeController.getRecordsBasedOnPractice(practice, modalities);
        
    
            List<DH_ModalityBasedPracticeController.SpecialInstructionsWrapper> instruct = DH_ModalityBasedPracticeController.getNotes(practice, modalities);
            Test.stopTest();
            Assert.isNotNull( procRecords, 'Procedure records should not be null');
        }
     }
  }