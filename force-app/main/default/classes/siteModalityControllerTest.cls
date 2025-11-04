/*

 *********************************************************

Apex Class         : siteModalityControllerTest
    
Created Date       : May 15, 2024
    
@description       : Test class for siteModalityController

@jiraid            : CC-104, CC-949, CC-770

 *********************************************************

 */
@isTest(SeeAllData=false)
private class siteModalityControllerTest {
    /**
     * @description : Setup method to create data
     **/
    @TestSetup
    static void makeData(){
        test.startTest();
        User eastUser = new User(
            FirstName = 'East',
        LastName = 'User',
        Email = 'eastuser@example.com',
        Username = 'eastuser@example.com' + System.currentTimeMillis(),
        Alias = 'eastuser',
        ProfileId = [SELECT Id FROM Profile WHERE Name =:DH_KMConstants.radnet_Scheduler ].Id,
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
            );
        Insert eastUser;
        
        Profile guestProfile = [SELECT Id, name FROM Profile WHERE Name =: DH_KMConstants.RADNET_COMMUNITY_PROFILE LIMIT 1];
        User guestUser = new User(
            Username = 'guestuser@test.com',
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
        List<Account> acclist = new List<Account>();
        RecordType siteRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1];
        
        Account acc = new Account(Name = 'Test Account', RecordTypeId = siteRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        acc.Site_code__c = 'ES';
        acclist.add(acc);
        
        Account acc2 = new Account(Name = 'Test Account 2', RecordTypeId = siteRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        acc2.Site_code__c = 'ES2';
        acclist.add(acc2);
        insert acclist;
        
        List<CareSpecialty> careSpec = new List<CareSpecialty>();
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_DEXA));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_MRI ));
        insert careSpec;
        
        CareProviderFacilitySpecialty specialty = new CareProviderFacilitySpecialty( // create site modality
            Name = 'Test Specialty',
        Description__c = 'Test Description',
        AccountId = acc.Id,
        specialtyId = careSpec[0].id
            );
        insert specialty;
        test.stopTest();
    }
    
    /**
     * @description : Method used to test getSiteModalities method for guest user
     **/
    @isTest
    static void testgetSiteModalitiesGuest() {
        // Create test data for accounts
        User guestUsr = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        Test.startTest();
        System.runAs(guestUsr) {
            // The following code runs as user 'guestUsr'
            RecordType siteRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1];
            Account accGuest = new Account(Name = 'Test Account Guest', RecordTypeId = siteRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
            insert accGuest;
            DH_CareSpecialty__c csGuest =new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_MRI );
            insert csGuest;
            DH_CareProviderFacilitySpecialty__c smGuest = new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_MRI, DH_AccountId__c = accGuest.Id, DH_SpecialtyId__c = csGuest.Id );
            insert smGuest;
            
            List<siteModalityController.CpfsWrapper> result = siteModalityController.getSiteModalities(accGuest.Id);
            Assert.areEqual(true, result.size()>0, 'Created CareProviderFacilitySpecialty');
        }
        Test.stopTest();
    }
    
    /**
     * @description : Method used to test getSiteModalities method for normal user
     **/
    @isTest
    static void testgetSiteModalities() {
        // Create test data for accounts
        Account acc = [SELECT Id, Name from Account WHERE Name = 'Test Account'];
        careSpecialty cs= [SELECT Id, Name from careSpecialty WHERE Name = 'MRI'];
        CareProviderFacilitySpecialty specialty = [SELECT Id, Name from CareProviderFacilitySpecialty WHERE Name = 'Test Specialty'];
        
        // Call the method to test
        try{
            test.startTest();
            List<siteModalityController.CpfsWrapper> result = siteModalityController.getSiteModalities(acc.Id);
            Assert.areEqual(true, result.size()>=0, 'Created CareProviderFacilitySpecialty');
            List<siteModalityController.CpfsWrapper> resultError = siteModalityController.getSiteModalities(acc.Name);
            Assert.areEqual(true, resultError.size() == 0, 'No result as wrong data sent through Id');
            test.stopTest();
        }
        catch(DMLException e){
            system.assertEquals(e.getMessage(), 'Unexpected error message: '+ e.getMessage(),'Exception caught');
        }
        
    }
    
    /**
     * @description : Method used to test delete access
     **/
    @isTest
    static void testDeleteSiteModalityRecord() {
        // Create test data
        Account acc = [SELECT Id, Name from Account WHERE Name = 'Test Account 2'];
        careSpecialty cs= [SELECT Id, Name from careSpecialty WHERE Name = 'DEXA'];
        User u = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        
        CareProviderFacilitySpecialty specialty2 = new CareProviderFacilitySpecialty(
            Name = 'Test Specialty2',
        Description__c = 'Test Description2',
        AccountId = acc.Id,
        specialtyId = cs.id
            );
        
        Test.startTest();
        insert specialty2;
        // Call the method to test
        siteModalityController.deleteSiteModalityRecord(specialty2.Id);
        try{
            System.runAs(u) {
                siteModalityController.deleteSiteModalityRecord(specialty2.Id);
            }
        }
        catch (Exception e){
            DH_KMUtility.getException(e,'An error occurred While deleting site modality : ');
        }
        Test.stopTest();
        
        // Verify that the record is deleted
        List<CareProviderFacilitySpecialty> deletedRecords = [SELECT Id FROM CareProviderFacilitySpecialty WHERE Id = :specialty2.Id];
        system.assertEquals(0, deletedRecords.size(),'Deleted Modality');
    }
    
    /**
     * @description : Method used to test CRUD access method for normal user
     **/
    @isTest
    static void testHasCRUDAccess() {
        // This code runs as the East user
        User u = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        Test.startTest();
        System.runAs(u) {
            // The following code runs as user 'u'
            boolean resultCreate = siteModalityController.hasCreateAccess();
            boolean resultDelete = siteModalityController.hasDeleteAccess();
            boolean resultUpdate = siteModalityController.hasUpdateAccess();
            
            Assert.areEqual(false, resultCreate, 'user has create access');
            Assert.areEqual(false, resultDelete, 'user has delete access');
            Assert.areEqual(false, resultUpdate, 'user has update access');
        }
        Test.stopTest();
    }
    
    /**
     * @description : Method used to test CRUD access method for Admin user
     **/
    @isTest
    static void testHasCRUDAccessAdmin() {
        // This code runs as the East user
        User u = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        Test.startTest();
        // The following code runs as user 'u'
        boolean resultCreate = siteModalityController.hasCreateAccess();
        boolean resultDelete = siteModalityController.hasDeleteAccess();
        boolean resultUpdate = siteModalityController.hasUpdateAccess();
        
        Assert.areEqual(true, resultCreate, 'user has create access');
        Assert.areEqual(true, resultDelete, 'user has delete access');
        Assert.areEqual(true, resultUpdate, 'user has update access');
        Test.stopTest();
    }
    
    /**
     * @description : Method used to test CRUD access method for Guest user
     **/
    @isTest
    static void testHasCRUDAccessGuest() {
        // This code runs as the Guest user
        User guestUsr = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        Test.startTest();
        System.runAs(guestUsr) {
            // The following code runs as user 'u'
            boolean resultCreate = siteModalityController.hasCreateAccess();
            boolean resultDelete = siteModalityController.hasDeleteAccess();
            boolean resultUpdate = siteModalityController.hasUpdateAccess();
            
            Assert.areEqual(false, resultCreate, 'user has create access');
            Assert.areEqual(false, resultDelete, 'user has delete access');
            Assert.areEqual(false, resultUpdate, 'user has update access');
        }
        Test.stopTest();
    }
}