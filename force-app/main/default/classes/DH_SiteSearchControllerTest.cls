/*

 *********************************************************

Apex Class         : DH_SiteSearchControllerTest
    
Created Date       : May 15, 2024
    
@description       : Test class for controller class for site search component(dH_siteSearch) to fetch site data

@jiraid            : CC-232

 *********************************************************

 */

@isTest
private class DH_SiteSearchControllerTest {
    
    private static final String phoneno = '9922334455';
    /**
     * @description : Test Setup Method to create data
     **/
    @testSetup
    private static void createData(){
        //setup method for creating test data for site
        
        List<Account> accountsList = new List<Account>();
        
        RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
        
        Account eastRegion = new Account(Name = 'East Test Region', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, Region__c = 'ETS');
        eastRegion.Phone = phoneno;
        accountsList.add(eastRegion);
        
        Account westRegion = new Account(Name = 'West Test Region', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, Region__c = 'WTS');
        westRegion.Phone = phoneno;
        accountsList.add(westRegion);
                
        RecordType practiceRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.PRACTICE_RECORD_TYPE LIMIT 1];
        
        Account testPractice = new Account(Name = 'Test Practice', RecordTypeId = practiceRecordType.Id, AccountRegion__c = eastRegion.Id);
        testPractice.Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST;
        testPractice.Phone = phoneno;
        
        RecordType siteRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1];        
        
        Account eastsiteGroup = new Account(Name = 'East SiteGroup', RecordTypeId = siteRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        eastsiteGroup.Phone = phoneno;
        eastsiteGroup.DH_Site_Group_Region__c = 'Brooklyn East';
        eastsiteGroup.Site_code__c = 'ES';
        accountsList.add(eastsiteGroup);

        
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
        
        //inserting accountList
        Test.startTest();
        insert guestUser;
        
        accountsList.add(testPractice);
        insert accountsList;
        
        //updating site account with its practice accounts
        eastSiteGroup.Account_Practice__c = testPractice.Id;
        eastSiteGroup.AccountRegion__c = eastRegion.Id;
        update eastSiteGroup;
        
        //updating site account with region account
        
        testPractice.AccountRegion__c = eastRegion.Id;
        update testPractice;
        
        
        
        List<CareSpecialty> careSpec = new List<CareSpecialty>();
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_DEXA,CareSpecialty_External_ID__c='MODDEXA'));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_MRI,CareSpecialty_External_ID__c='MODMRI' ));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_CT,CareSpecialty_External_ID__c='MODCT' ));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_XRAY,CareSpecialty_External_ID__c='MODXRAY' ));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_ULTRASOUND,CareSpecialty_External_ID__c='MODUS' ));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_NM,CareSpecialty_External_ID__c='MODNM'));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_PETCT,CareSpecialty_External_ID__c='MODPETCT' ));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_FLUOROSCOPY,CareSpecialty_External_ID__c='MODFL' ));
        insert careSpec;
        
        List<CareProviderFacilitySpecialty> siteModality = new List<CareProviderFacilitySpecialty>();
        
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_DEXA, AccountId = eastSiteGroup.Id, SpecialtyId = careSpec[0].Id  ));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_MRI, AccountId = eastSiteGroup.Id, SpecialtyId = careSpec[1].Id, Description__c = 'subModality1'));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_CT, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[2].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_XRAY, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[3].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_ULTRASOUND, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[4].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_NM, AccountId = eastSiteGroup.Id, SpecialtyId = careSpec[5].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_PETCT, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[6].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_FLUOROSCOPY, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[7].Id));
        
        
        insert siteModality;
        
        Test.stopTest();
        
    }
    
    /**
     * @description : Method to cover sitesearchcontriller for healthcloud user
     **/
    @isTest
    static void testSearchSites() {
        Account eastsiteGroup = [SELECT Id, Name, AccountRegion__r.Name, Account_Practice__r.Name, DH_Site_Group_Region__c,  Site_Code__c   from Account WHERE Name='East SiteGroup'];
        Double lat;
        Double longt;
        Test.startTest();
        List<DH_SiteSearchController.AccountWrapper> searchResults = DH_SiteSearchController.searchSites(
        new List<String>{'East Test Region'},
        new List<String>{'Test Practice', DH_KMConstants.NJIN},
        new List<String>{'Brooklyn East'},
        'ES', '',
        new List<String>{DH_KMConstants.MODALITY_MRI,''},
            lat,longt,25, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, new List<String>{'subModality1'});
        Test.stopTest();
        // Assert the results
        System.assertEquals(true, searchResults.size()>=0, 'Search by site code failed');
        
        for(DH_SiteSearchController.AccountWrapper wrapper : searchResults){
            System.assertNotEquals(null, wrapper.Id, 'AccountWrapper Id should not be null');
            System.assertNotEquals(null,wrapper.careProviderFacilitySpecialties, 'careProviderFacilitySpecialties should not be null');
            
        }
    }
    
   
    
    /**
     * @description : Method to cover sitesearchcontriller for Guest user
     **/
    @isTest
    static void testSearchSitesGuest() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            Double lat;
            Double longt;
            List<Account> accountsList = new List<Account>();
            
            RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
           
            Account eastRegion = new Account(Name = 'East Test Region 1', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, Region__c = 'FL');
            eastRegion.Phone = phoneno;
            accountsList.add(eastRegion);
            
            Account westRegion = new Account(Name = 'West Test Region 1', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, Region__c = 'NE');
            westRegion.Phone = phoneno;
            accountsList.add(westRegion);
            
            RecordType practiceRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.PRACTICE_RECORD_TYPE LIMIT 1];
            
            Account testPractice = new Account(Name = 'Test Practice 1', RecordTypeId = practiceRecordType.Id, AccountRegion__c = eastRegion.Id);
            testPractice.Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST;
            testPractice.Phone = phoneno;
            
            RecordType siteRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1]; 
            
            Account eastsiteGroup = new Account(Name = 'East SiteGroup 1', RecordTypeId = siteRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
            eastsiteGroup.Phone = phoneno;
            eastsiteGroup.DH_Site_Group_Region__c = 'Brooklyn East';
            eastsiteGroup.Site_code__c = 'ESP';
            accountsList.add(eastsiteGroup);
            
            
            
            Test.startTest();
            accountsList.add(testPractice);
            insert accountsList;
            
            //updating site account with its practice accounts
            eastSiteGroup.Account_Practice__c = testPractice.Id;
            eastSiteGroup.AccountRegion__c = eastRegion.Id;
            update eastSiteGroup;
            
            //updating site account with region account
            
            testPractice.AccountRegion__c = eastRegion.Id;
            update testPractice;
            
            List<DH_CareSpecialty__c> careSpec = new List<DH_CareSpecialty__c>();
            careSpec.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_MRI ));
            insert careSpec;
            
            List<DH_CareProviderFacilitySpecialty__c> siteModality = new List<DH_CareProviderFacilitySpecialty__c>();
            siteModality.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_MRI, DH_AccountId__c = eastSiteGroup.Id, DH_SpecialtyId__c = careSpec[0].Id, DH_Description__c = 'guestSubModality1' ));
            insert siteModality;
            
            
            List<DH_SiteSearchController.AccountWrapper> searchResults = DH_SiteSearchController.searchSites(
            new List<String>{'East Test Region 1'},
            new List<String>{'Test Practice 1', DH_KMConstants.NJIN},
            new List<String>{'Brooklyn East'},
            'ESP', '',
            new List<String>{DH_KMConstants.MODALITY_MRI,''},
            lat,longt,25, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, new List<String>{'guestSubModality1'});
            
            
            List<DH_SiteSearchController.AccountWrapper> searchResults2 = DH_SiteSearchController.searchSites(
            new List<String>{'East Test Region 1'},
            new List<String>{'Test Practice 1', DH_KMConstants.NJIN},
            new List<String>{'Brooklyn East'},
            'ESP', '',
            new List<String>{DH_KMConstants.MODALITY_MRI,''},
            lat,longt,25, DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, new List<String>{'guestSubModality1'});
            Test.stopTest();
            // Assert the results
            System.assertEquals(true, searchResults.size()>=0, 'Search by site code failed');
            
        }
    }
}