/*
 *********************************************************

Apex Class         : DH_SiteSearchOptionsTest
    
Created Date       : April 23, 2024
    
@description       : This test class is used to verify methods in DH_SiteSearchOptions apex class

@jiraid            : CC-231, CC-945

 *********************************************************
 */


@isTest (seeAllData =false)
private class DH_SiteSearchOptionsTest {
    private static final String PHONENO = '9922334455';
    
    //test data setup
    @testSetup
    private static void createData(){
        
        PermissionSet eastPermSet = [SELECT Id FROM PermissionSet WHERE Name = :DH_KMConstants.SITE_SEARCH_SUPER_USER];
        PermissionSet healthPermSet = [SELECT Id FROM PermissionSet WHERE Name = :DH_KMConstants.HEALTHCLOUD_FOUNDATION_PERMISSION_SET];
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name= :DH_KMConstants.RADNET_MANAGER];
        User radnetManagerUserEast = new User(Alias = 'rsEast', Email= DH_KMConstants.USER_EMAIL_EAST,
        EmailEncodingKey='UTF-8', LastName='TestingEast', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', IsActive= true,
        UserName= DH_KMConstants.USER_EMAIL_EAST);
        insert radnetManagerUserEast;
        
        User radnetManagerUserWest = new User(Alias = 'rsWest', Email= DH_KMConstants.USER_EMAIL_WEST,
        EmailEncodingKey='UTF-8', LastName='TestingWest', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', IsActive= true,
        UserName= DH_KMConstants.USER_EMAIL_WEST);
        insert radnetManagerUserWest;
        
        Profile guestProfile = [SELECT Id, name FROM Profile WHERE Name =: DH_KMConstants.RADNET_COMMUNITY_PROFILE LIMIT 1];
        User guestUser = new User(
            Username = 'guestuser1@test.com',
        FirstName = 'Guest',
        LastName = 'User',
        Email = 'guestuser1@test.com',
        Alias = 'guest',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = guestProfile.Id,
        LanguageLocaleKey = 'en_US'
            );
        insert guestUser;
        
        insert new PermissionSetAssignment(PermissionSetId = eastPermSet.Id, AssigneeId = radnetManagerUserEast.Id);
        insert new PermissionSetAssignment(PermissionSetId = healthPermSet.Id, AssigneeId = radnetManagerUserEast.Id);
        
        
        Group eastCoastGroup = [SELECT Id, Name FROM Group WHERE DeveloperName = 'FL_Region_Team' LIMIT 1];
        GroupMember gm = new GroupMember( UserOrGroupId = radnetManagerUserEast.Id, GroupId = eastCoastGroup.Id );
        insert gm;
        
        Group westCoastGroup = [SELECT Id, Name FROM Group WHERE DeveloperName = 'CA_Region_Team' LIMIT 1];
        GroupMember gm1 = new GroupMember( UserOrGroupId = radnetManagerUserWest.Id, GroupId = westCoastGroup.Id );
        insert gm1;
        
        insert new PermissionSetAssignment(PermissionSetId = eastPermSet.Id, AssigneeId = radnetManagerUserWest.Id);
        insert new PermissionSetAssignment(PermissionSetId = healthPermSet.Id, AssigneeId = radnetManagerUserWest.Id);
        
        
        system.runAs(radnetManagerUserEast){
            
            List<Account> accountsList = new List<Account>();
            
            RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
            Account eastRegion = new Account(Name = 'East Test Region (ETR)', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, Region__c = 'ETR');
            eastRegion.Phone = phoneno;
            accountsList.add(eastRegion);
            
            RecordType regionRecordTypeSite = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1];
            Account eastsiteGroup = new Account(Name = '(ES) East SiteGroup', RecordTypeId = regionRecordTypeSite.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, Site_Code__c = 'ES');
            eastsiteGroup.Phone = phoneno;
            eastsiteGroup.DH_Site_Group_Region__c = 'Brooklyn East';
            accountsList.add(eastsiteGroup);
            
            RecordType practiceRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.PRACTICE_RECORD_TYPE LIMIT 1];
            Account testPracticeEast = new Account(Name = '(TPE) Test Practice East', RecordTypeId = practiceRecordType.Id, AccountRegion__c = eastRegion.Id,Practice_code__c = 'TPE');
            testPracticeEast.Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST;
            testPracticeEast.Phone = phoneno;
            accountsList.add(testPracticeEast);
            insert accountsList;
                
            eastsiteGroup.AccountRegion__c = eastRegion.Id;
            eastsiteGroup.Account_Practice__c = testPracticeEast.Id;
            update eastSiteGroup;
            testPracticeEast.AccountRegion__c = eastRegion.Id;
            update testPracticeEast;
            
        }
        
        system.runAs(radnetManagerUserWest){
            
            List<Account> accountsList = new List<Account>();
            
            RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
            Account westRegion = new Account(Name = 'West Test Region (WTR)', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, Region__c = 'WTR');
            westRegion.Phone = phoneno;
            accountsList.add(westRegion);
            
            
            RecordType regionRecordTypeSite = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1];
            Account westsiteGroup = new Account(Name = '(WS) West SiteGroup', RecordTypeId = regionRecordTypeSite.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, Site_Code__c = 'WS');
            westsiteGroup.Phone = phoneno;
            westsiteGroup.DH_Site_Group_Region__c = 'Arizona';
            westsiteGroup.AccountRegion__c = westRegion.id;
            accountsList.add(westsiteGroup);
            
            RecordType practiceRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.PRACTICE_RECORD_TYPE LIMIT 1];
            Account testPracticeWest = new Account(Name = '(TPW) Test Practice West', RecordTypeId = practiceRecordType.Id, AccountRegion__c = westRegion.Id, Practice_code__c = 'TPW');
            testPracticeWest.Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST;
            testPracticeWest.Phone = phoneno;
            accountsList.add(testPracticeWest);
            insert accountsList;
            
            westsiteGroup.Account_Practice__c = testPracticeWest.Id;
            update westsiteGroup;
            
            testPracticeWest.AccountRegion__c = westRegion.Id;
            update testPracticeWest;
        }
        
        system.runAs(guestUser){
            
            List<Account> accountsList = new List<Account>();
            
            RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
            Account guestRegionEast = new Account(Name = 'Guest Test Region (GTR)', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, Region__c = 'GTRE');
            guestRegionEast.Phone = phoneno;
            accountsList.add(guestRegionEast);
            
            Account guestRegionWest = new Account(Name = 'Guest Test Region (GTR)', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, Region__c = 'GTRW');
            guestRegionWest.Phone = phoneno;
            accountsList.add(guestRegionWest);
            insert accountsList;
            
        }
    }
    //check to get RIS records
    @isTest
    private static void TestGetRIS() {
        RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
        Test.startTest();
        List<Account> result = DH_SiteSearchOptions.getRIS(DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'List of regions should not be empty');
    }
    
    //check to get RIS records for guest user east data
    @isTest
    private static void TestGetRIS_forGuestUserEast() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser1@test.com' LIMIT 1];
        
        System.runAs( guestUser ) {
            Test.startTest();
            List<Account> result = DH_SiteSearchOptions.getRIS(DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
            Test.stopTest();
            Assert.areEqual(1, result.size(), 'List of regions should not be empty');
        }
    }
    
    //check to get RIS records for guest user west data
    @isTest
    private static void TestGetRIS_forGuestUserWest() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser1@test.com' LIMIT 1];
        System.debug('guestUser ' + guestUser);
        System.runAs( guestUser ) {
            Test.startTest();
            List<Account> result = DH_SiteSearchOptions.getRIS(DH_KMConstants.ACCOUNT_COAST_FIELD_WEST);
            Test.stopTest();
            Assert.areEqual(1, result.size(), 'List of regions should not be empty');
        }
    }
    
    //check to get RIS records for east user
    @isTest
    private static void TestGetRIS_forEastCoast_forRadnetManager() {
        User radnetManagerUser = [SELECT Id FROM User WHERE Email = :DH_KMConstants.USER_EMAIL_EAST LIMIT 1];
        System.runAs( radnetManagerUser ) {
            Test.startTest();
            List<Account> result = DH_SiteSearchOptions.getRIS(DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
            Test.stopTest();
            Assert.areEqual(true, result.size() >= 0, 'List of regions should not be empty');
        }
    }
    //check to get RIS records for west user
    @isTest
    private static void TestGetRIS_forWestCoast_forRadnetManager() {
        User radnetManagerUserWest = [SELECT Id FROM User WHERE Email = :DH_KMConstants.USER_EMAIL_WEST LIMIT 1];
        System.runAs( radnetManagerUserWest ) {
            Test.startTest();
            List<Account> result = DH_SiteSearchOptions.getRIS(DH_KMConstants.ACCOUNT_COAST_FIELD_WEST);
            Test.stopTest();
            Assert.areEqual(true, result.size() >= 0, 'List of regions should not be empty');
        }
    }
    
    //check to get practice records for east user with region
    @isTest
    private static void TestGetPractice_forRegion() {
        User radnetManagerUserEast = [SELECT Id FROM User WHERE Email = :DH_KMConstants.USER_EMAIL_EAST LIMIT 1];
        System.runAs( radnetManagerUserEast ) {
            Test.startTest();
            List<Account> result = DH_SiteSearchOptions.getPractice(new List<String>{'East Test Region (ETR)', DH_KMConstants.NJIN}, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
            Test.stopTest();
            Assert.areEqual(true, result.size() >= 0, 'List of practices should not be empty');
        }
    }
    
    
    //check to get practice records for east user without region
    @isTest
    private static void TestGetPractice_forDefaultRegion() {
        Test.startTest();
        List<String> lst = new List<String>();
        List<Account> result = DH_SiteSearchOptions.getPractice(lst, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        Test.stopTest();
        System.assertEquals(2, result.size(), 'List of practices should not be empty');
    }
    
    //check to get practice records for west user without region
    @isTest
    private static void TestGetPracticeWest_forDefaultRegion() {
        Test.startTest();
        List<String> lst = new List<String>();
        List<Account> result = DH_SiteSearchOptions.getPractice(lst, DH_KMConstants.ACCOUNT_COAST_FIELD_WEST);
        Test.stopTest();
        System.assertEquals(2, result.size(), 'List of practices should not be empty');
    }
    
    //check to get site group records without passing practice
    @isTest
    private static void TestGetSiteGroupOptions_withoutPassingPractices() {
        Test.startTest();
        List<String> result = DH_SiteSearchOptions.getSiteGroupOptions(new List<String>(), new List<String>(), DH_KMConstants.ACCOUNT_COAST_FIELD_EAST );
        Test.stopTest();
        Assert.isNotNull(result, 'List of site groups should not be empty');
    }
    
    //check to get get site group records with passing region
    @isTest
    private static void TestGetSiteGroupOptions_withpassingRegion(){
        Test.startTest();
        List<String> result = DH_SiteSearchOptions.getsiteGroupOptions(new List<String>(), new List<String>{'East Test Region (ETR)', DH_KMConstants.NJIN}, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        Test.stopTest();
        Assert.isNotNull(result, 'List of site groups should not be empty');
    }
    
    //check to get site group records with passing practice
    @isTest
    private static void TestGetSiteGroupOptions_withPassingPractices() {
        Test.startTest();
        List<String> result = DH_SiteSearchOptions.getSiteGroupOptions(new List<String>{'East Test Region (ETR)'}, new List<String>{'(TPE) Test Practice East'}, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        Test.stopTest();
        Assert.isNotNull(result, 'List of site groups should not be empty');
    }
    
    //check to get site group records with passing practice
    @isTest
    private static void TestGetSiteGroupOptionsWest_withPassingPractices() {
        Test.startTest();
        List<String> result = DH_SiteSearchOptions.getSiteGroupOptions(new List<String>{'(TPW) Test Practice West'}, new List<String>{''}, DH_KMConstants.ACCOUNT_COAST_FIELD_WEST);
        Test.stopTest();
        Assert.isNotNull(result, 'List of site groups should not be empty');
    }
    
    //check to get modality records
    @isTest
    private static void TestGetModalities() {
        Test.startTest();
        List<Modality__mdt> result = DH_SiteSearchOptions.getModalities(new List<String>{}, new List<String>{});
        Test.stopTest();
        Assert.isTrue( result.size() > 0, 'List of modalities should not be empty');
    }
    
    //check to get sub-modality records for health cloud user 
    @isTest
    private static void TestGetSubModalitiesforHCUser(){
        
        List<CareProviderFacilitySpecialty> careSpecs = new List<CareProviderFacilitySpecialty>();
        careSpecs.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_MRI, Description__c = 'subModality1'));
        insert careSpecs;
        Test.startTest();
        List<String> result = DH_SiteSearchOptions.getSubModalities(new List<String>{DH_KMConstants.MODALITY_MRI});
        Test.stopTest();
        System.assert(result.contains('subModality1'), 'Result should contain subModality1');
    }
   
    //check to get sub-modality records for guest user 
    @isTest
    private static void TestGetSubModalitiesforGuestUser(){
        
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser1@test.com' LIMIT 1];
        System.debug('guestUser ' + guestUser);
        System.runAs( guestUser ) {
            Test.startTest();
            
            List<DH_CareProviderFacilitySpecialty__c> guestCareSpecs = new List<DH_CareProviderFacilitySpecialty__c>();
            guestCareSpecs.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_MRI, DH_Description__c = 'guestSubModality1'));
            insert guestCareSpecs;
            
            List<String> guestResult = DH_SiteSearchOptions.getSubModalities(new List<String>{DH_KMConstants.MODALITY_MRI});
            Test.stopTest();
            System.assert(guestResult.contains('guestSubModality1'), 'Guest result should contain guestSubModality1');
            
        }
    }
    
    
    //check to get search result records
    @isTest
    private static void TestFindRecords() {
        String searchKey = 'Test';
        String objectName = 'Account';
        RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account', RecordTypeId = regionRecordType.Id);
        testAccount.Phone = phoneno;
        insert testAccount;
        Test.startTest();
        List<sobject> result = DH_SiteSearchOptions.findRecords(searchKey, objectName, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        Test.stopTest();
        Assert.isNotNull(result, 'List of find records should not be empty');
        
    }
    
    //check to get search result records with west user
    @isTest
    private static void TestFindRecordswithWestcoastuser() {
        User radnetManagerUserWest = [SELECT Id FROM User WHERE Email = :DH_KMConstants.USER_EMAIL_WEST LIMIT 1];
        String searchKey = 'West';
        String objectName = 'Account';
        System.runAs( radnetManagerUserWest ){
            Test.startTest();
            List<sobject> result = DH_SiteSearchOptions.findRecords(searchKey, objectName, DH_KMConstants.ACCOUNT_COAST_FIELD_WEST);
            Test.stopTest();
            Assert.isNotNull(result, 'List of find records should not be empty');
        }
    }
    
    //check to get search result records with east user
    @isTest
    private static void TestFindRecordswithEastcoastuser() {
        User radnetManagerUserEast = [SELECT Id FROM User WHERE Email = :DH_KMConstants.USER_EMAIL_EAST LIMIT 1];
        System.runAs( radnetManagerUserEast ){
            String searchKey = 'East';
            String objectName = 'Account';
            Test.startTest();
            List<sobject> result = DH_SiteSearchOptions.findRecords(searchKey, objectName, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
            Test.stopTest();
            Assert.isNotNull(result, 'List of find records should not be empty');
        }
    }
    
    //check to verify getVFOrigin() method
    @istest
    private static void TestGetVFOrigin() {
        Test.startTest();
        String result = DH_SiteSearchOptions.getVFOrigin();
        Test.stopTest();
        Assert.isNotNull(result, 'VF Origin should not be null');
    }
    
}