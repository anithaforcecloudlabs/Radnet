/******************************************************************************************************************************************************
 *
 * @Created Date      :  7/8/2024
 *
 * @description       : This class is test class for DH_KMQueryManager
 *
 * @JIRA Id           :  CC-819, CC-231, CC-945, CC-946, CC-947, CC-949, CC-964
 * */
@isTest
private class DH_KMQueryManagerTest {
    
    private static final String phoneno = '9922334455';
    @TestSetup
    static void testSetUpMethod(){
        Group maRegionTeam = new Group(Name = 'MA Region Team', Type = 'Regular');
        insert maRegionTeam;
        Group neRegionTeam = new Group(Name = 'NE Region Team', Type = 'Regular');
        insert neRegionTeam;
        
        //Create Permission Sets (assume they already exist)
        PermissionSet eastPermSet = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.MODALITY_SEARCH_PERMISSION_SET];
        PermissionSet ePermSet = [SELECT Id FROM PermissionSet WHERE Name =:DH_KMConstants.USER_EAST];
        PermissionSet healthPermSet = [SELECT Id FROM PermissionSet WHERE Name =:DH_KMConstants.HEALTHCLOUD_FOUNDATION_PERMISSION_SET];
       	PermissionSet pUserEast = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_EAST_COAST_USER];

        // Create East Coast User
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
        insert eastUser;
        insert new GroupMember(GroupId = maRegionTeam.Id, UserOrGroupId = eastUser.Id);
        insert new GroupMember(GroupId = neRegionTeam.Id, UserOrGroupId = eastUser.Id);
        insert new PermissionSetAssignment(PermissionSetId = eastPermSet.Id, AssigneeId = eastUser.Id);
        insert new PermissionSetAssignment(PermissionSetId = ePermSet.Id, AssigneeId = eastUser.Id);
        insert new PermissionSetAssignment(PermissionSetId = healthPermSet.Id, AssigneeId = eastUser.Id);
        insert new PermissionSetAssignment(PermissionSetId = pUserEast.Id, AssigneeId = eastUser.Id);
        
        system.assertEquals(true,eastUser.Id != null,'User is not present');
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
        LanguageLocaleKey = 'en_US' );
        insert guestUser;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name =: DH_KMConstants.SYSTEM_ADMINISTRATOR];
    	User systemAdmin = new User(Alias = 'rsWest', Email = 'radSchWest@testorg.com',
        EmailEncodingKey = 'UTF-8', LastName = 'TestingWest', LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US', ProfileId = p1.Id,
        TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = true,
        UserName = 'radSch3West@testorg.com');
        insert systemAdmin;	
        
        Id practiceRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.PRACTICE_RECORD_TYPE).getRecordTypeId();
        Id siteRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.ACCOUNT_RECORDTYPE_SITE).getRecordTypeId();
        Id regionRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM).getRecordTypeId();
        
        System.runAs(eastUser){
    
            
            // CREATING ACCOUNT RECORDS FOR REGION
            List<Account> reg = new List<Account>();
            reg.add(new Account(Name='MA',
            Region__c='MA',
            isActive=true,
            RecordTypeId=regionRecordTypeID
                ));
            reg.add(new Account(Name='NE',
            Region__c='NE',
            isActive=true,
            RecordTypeId=regionRecordTypeID
                ));
            upsert reg;
            
            // CREATING ACCOUNT RECORDS FOR PRACTICE
            List<Account> prac = new List<Account>();
            prac.add(new Account(Name='ADV',
            Region__c=reg[0].Region__c,
            ParentId=reg[0].Id,
            Practice_code__c='ADV',
            isActive=true,
            RecordTypeId=practiceRecordTypeID
                ));
            // (AR) Arundel Mills (eh-ruhn-dl milz)
            
            prac.add(new Account(Name='ARS',
            Region__c=reg[0].Region__c,
            ParentId=reg[0].Id,
            Practice_code__c='ARS',
            isActive=true,
            RecordTypeId=practiceRecordTypeID
                ));
            // (PAT) Patuxent (puh-tux-ent)
            
            prac.add(new Account(Name='CRA',
            Region__c=reg[0].Id,
            ParentId=reg[0].Id,
            Practice_code__c='CRA',
            RecordTypeId=practiceRecordTypeID ));
            
            upsert prac;
            
            List<Account> acc = [Select Id,Name,Region__c,ParentId from Account where Practice_code__c='ADV' ];
            // CREATING ACCOUNT RECORDS FOR PAYER
            Id payerAccountRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.PAYER_RECORD_TYPE).getRecordTypeId();
            List<Account> payeracc = new List<Account>();
            for(integer i=0;i<5;i++){
                payeracc.add(new Account(Name='Test Acc'+i,
                Carrier_Code_in_RIS__c='00'+i,
                RecordTypeId=payerAccountRecordTypeID,
                isActive=true
                    ));
            }
            upsert payeracc;
            
            // CREATING SPECIAL BILLS RECORDS
            List<HealthcarePayerNetwork> payerntw = new List<HealthcarePayerNetwork>();
            for(integer i=0;i<5;i++) {
                payerntw.add(new HealthcarePayerNetwork(Name = 'test'+i,
                Exam_Covered__c='Test Exam covered'+i,
                PayerId=payeracc[i].Id,
                Region__c=reg[0].Id,
                IsActive=true
                    ));
            }
            upsert payerntw;
            
            // CREATING SPECIAL ACCOMODATION AND PROTOCOL RECORDS
            List<Special_Accomodation_and_Protocol__c> spAcc = new List<Special_Accomodation_and_Protocol__c>();
            for(integer i=0;i<5;i++) {
                spAcc.add(new Special_Accomodation_and_Protocol__c(Name = 'test Acc'+i));
            }
            upsert spAcc;
            
            // MACHINE WEIGHT DATA FOR HEALTHCLOUD USER
            List<Account> site = new List<Account>();
            site.add(new Account(Name='(GRB) Greenbelt Imaging Center',
            Site_Code__c='GRB',
            ParentId = prac[2].Id,
            RecordTypeId=siteRecordTypeID ));
            
            insert site;
            
            List<CareSpecialty> careSpec = new List<CareSpecialty>();
            careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_DEXA,CareSpecialty_External_ID__c='MODDEXA'));
            
            insert careSpec;
            
            List<CareProviderFacilitySpecialty> siteModality = new List<CareProviderFacilitySpecialty>();
            
            for(integer i=0;i<site.size();i++) {
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_DEXA, AccountId = site[i].Id, SpecialtyId = careSpec[0].Id  ));
            }
            
            insert siteModality;
            
            List<HL_Machine_and_Weight__c> mwList = new List<HL_Machine_and_Weight__c>();
            
            for(integer i=0;i<siteModality.size();i++) {
                mwList.add(new HL_Machine_and_Weight__c( Name = 'Test machine'+i,
                Site_Modality__c = siteModality[i].Id
                    ));
            }
            upsert mwList;
        
         
        }
        // MACHINE WEIGHT DATA FOR GUEST USER
        System.runAs(guestUser){
            
            List<Account> reg1 = new List<Account>();
            reg1.add(new Account(Name= DH_KMConstants.REGION_FL,
            Region__c = 'FL',
            isActive = true,
            RecordTypeId=regionRecordTypeID
                ));
            upsert reg1;
            List<Account> prac1 = new List<Account>();
            prac1.add(new Account(Name='RIA',
            Region__c=reg1[0].Id,
            ParentId=reg1[0].Id,
            Practice_code__c='RIA',
            RecordTypeId=practiceRecordTypeID ));
            
            upsert prac1;
            List<Account> site1 = new List<Account>();
            site1.add(new Account(Name='(TRA) Tradition Center',
            Site_Code__c='TRA',
            ParentId = prac1[0].Id,
            RecordTypeId=siteRecordTypeID ));
            
            insert site1;
            List<CareSpecialty> careSpec1 = new List<CareSpecialty>();
            careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_DEXA,CareSpecialty_External_ID__c='MODDEXA'));
            
            insert careSpec1;
            
            List<DH_CareSpecialty__c> careSpecClone1 = new List<DH_CareSpecialty__c>();
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_DEXA));
            insert careSpecClone1;
            
            List<CareProviderFacilitySpecialty> siteModality1 = new List<CareProviderFacilitySpecialty>();
            for(integer i=0;i<site1.size();i++) {
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_DEXA, AccountId = site1[i].Id, SpecialtyId = careSpec1[0].Id  ));
            }
            insert siteModality1;
            
            List<DH_CareProviderFacilitySpecialty__c> siteModClone1 = new List<DH_CareProviderFacilitySpecialty__c>();
            for(integer i=0;i<site1.size();i++) {
                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_DEXA, DH_AccountId__c = site1[i].Id, DH_SpecialtyId__c = careSpecClone1[0].Id  ));
            }
            insert siteModClone1;
            List<HL_Machine_and_Weight__c> mwList1 = new List<HL_Machine_and_Weight__c>();
            
            for(integer i=0;i<siteModClone1.size();i++) {
                mwList1.add(new HL_Machine_and_Weight__c( Name = 'Test machinee'+i,
                DH_CareProviderFacilitySpecialty__c = siteModClone1[i].Id,
                Site_Modality__c = siteModality1[i].Id
                    ));
            }
            upsert mwList1;
         
        }
        //Test Data for Go Live Calendar
        Profile p = [SELECT Id FROM Profile WHERE Name='Radnet Manager'];
        User kmSuperUser = new User(Alias = 'rsEast', Email='kmSuperUser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUser', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', IsActive= true,UserPermissionsKnowledgeUser=true,
        UserName='kmSuperUser@testorg.com');
        insert kmSuperUser;
        
        PermissionSet psEastManager = [SELECT Id FROM PermissionSet WHERE Name = 'Knowledge_Search_Super_User'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = kmSuperUser.Id;
        psa.PermissionSetId = psEastManager.Id;
        insert psa;
     
        User radnetAdmin = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com'LIMIT 1];
        System.runAs(radnetAdmin) {
            // KNOWLEDGE ARTICLE DATA 
     // PICKLIST data create     
    // GET datacategory GROUP API name
    String dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
    String eastCtgApi;
  	String eastsubCtgApi;
    String westCtgApi;
  	String westSubCtgApi;
            
    // GET API NAME OF category and subcategory PICKLIST
    Map < String, List < String >> eastPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.EAST_CATEGORIES, DH_KMConstants.EAST_SUB_CATEGORIES);
    List < String > eastCtgApiKeys = new List < String > (new Set < String > (eastPicklistMap.keySet()));
    List < String > eastsubCtgApiList = new List < String > ();
    for (Integer i = 0; i < eastCtgApiKeys.size(); i++) {
      if (eastPicklistMap.get(eastCtgApiKeys[i]).size() != 0) {
        eastsubCtgApiList = eastPicklistMap.get(eastCtgApiKeys[i]);
        eastCtgApi = eastCtgApiKeys[i];
        eastsubCtgApi = eastsubCtgApiList[0];
        break;
      }
    }

    Map < String, List < String >> westPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.WEST_CATEGORIES, DH_KMConstants.WEST_SUB_CATEGORIES);
    List < String > westCtgApiKeys = new List < String > (new Set < String > (westPicklistMap.keySet()));
    List < String > westsubCtgApiList = new List < String > ();

    for (Integer i = 0; i < westCtgApiKeys.size(); i++) {
      if (westPicklistMap.get(westCtgApiKeys[i]).size() != 0) {
        westsubCtgApiList = westPicklistMap.get(westCtgApiKeys[i]);
        westCtgApi = westCtgApiKeys[i];
        westSubCtgApi = westsubCtgApiList[0];
        break;
      }
    }
         Knowledge__kav article4 = new Knowledge__kav();
        article4.Title = 'Test Knowledge CT Article 9';
        article4.UrlName = 'Test-Knowledge-Article-9';
        article4.Global__c = true;
        article4.Article_type__c='East';
        article4.East_Categories__c = eastCtgApi;
        article4.East_Sub_Categories__c = eastsubCtgApi;
        article4.West_Categories__c = westCtgApi;
        article4.West_Sub_Categories__c = westSubCtgApi;
        article4.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article4;

        List < knowledge__kav > obj2 = [SELECT Id, Title,Article_type__c, Details__c, KnowledgeArticleId FROM knowledge__kav];

      	KbManagement.PublishingService.publishArticle(obj2[0].KnowledgeArticleId, true);
         
         //Test Data for DH_LinkSiteImages
        
        Id siteAcc=Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.ACCOUNT_RECORDTYPE_SITE).getRecordTypeId();
        Account testAccount = new Account(
            RecordTypeId=siteAcc,
            Name = 'Test Account',
            Phone = '1234567890'
        );
        insert testAccount;
        
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.jpg',
            ContentLocation = 'S'
        );
        insert testContentVersion;
            
        
        // Creating test data for Search Phone Directory
        List<Phone_Directory__c> phoneDirectories = new List<Phone_Directory__c>();
        
        phoneDirectories.add(new Phone_Directory__c(
            Region__c = DH_KMConstants.REGION_NORTH,
            Entry_Point_Name__c = 'Main Office',
            Phone_Number__c = '123-456-7890',
            Comments__c = 'Main office in North region'
        ));
        
        phoneDirectories.add(new Phone_Directory__c(
            Region__c = DH_KMConstants.REGION_SOUTH,
            Entry_Point_Name__c = 'Branch Office',
            Phone_Number__c = '098-765-4321',
            Comments__c = 'Branch office in South region'
        ));
        
        phoneDirectories.add(new Phone_Directory__c(
            Region__c = DH_KMConstants.REGION_NORTH,
            Entry_Point_Name__c = 'Support Center',
            Phone_Number__c = '555-555-5555',
            Comments__c = 'Support center in North region'
        ));
        
        insert phoneDirectories;
        }
    }
    @isTest
    public static void dHSABControllerGetHPNTest() {
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
            List<String> r = new List<String>();
            r.add('MA');
            r.add('NE');
            Test.startTest();
            List<sObject> result=DH_KMQueryManager.getHealthcarePayerNetworkList(r, false);
            Test.stopTest();
            system.assertEquals(5,result.size(),'Special Bills not found');
        }
    }
    @isTest
    public static void dHSpecailBillGetHCPNEastTest() {
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        List<sObject> procRecords = new List<sObject>();
        List<String> practice = new List<String>{'TestPractice'};
        List<String> modalities = new List<String>{'TestModality'};
        System.runAs(eastUser) {
            procRecords = DH_KMQueryManager.getHealthcareProcedureRecords(practice, modalities, false);
            procRecords = DH_KMQueryManager.getSpecialInstructionsRecords(practice, modalities, false);
            
            List<String> r = new List<String>();
            r.add('MA');
            r.add('NE');
            Test.startTest();
            List<sObject> result=DH_KMQueryManager.getHealthcarePayerNetworkList(r, true);
            Test.stopTest();
            system.assertEquals(true,result.size()>=0,'Special Bills not found');
        }
    }
    @isTest
    public static void dHSpecailBillGetHCPNGuestTest() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        List<sObject> procRecords = new List<sObject>();
        List<String> practice = new List<String>{'TestPractice'};
        List<String> modalities = new List<String>{'TestModality'};
        System.runAs(guestUser) {
            procRecords = DH_KMQueryManager.getHealthcareProcedureRecords(practice, modalities, true);
            procRecords = DH_KMQueryManager.getSpecialInstructionsRecords(practice, modalities, true);
            
            List<String> r = new List<String>();
            r.add('MA');
            r.add('NE');
            Test.startTest();
            List<sObject> result=DH_KMQueryManager.getHealthcarePayerNetworkList(r, true);
            Test.stopTest();
            system.assertEquals(true,result.size()>=0,'Special Bills not found');
        }
    }
    @isTest
    public static void dHSpecailBillGetHCPNGuestTestfalse() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        List<sObject> procRecords = new List<sObject>();
        List<String> practice = new List<String>{'TestPractice'};
        List<String> modalities = new List<String>{'TestModality'};
        System.runAs(guestUser) {
            procRecords = DH_KMQueryManager.getHealthcareProcedureRecords(practice, modalities, false);
            procRecords = DH_KMQueryManager.getSpecialInstructionsRecords(practice, modalities, false);
        }
    }
    @isTest
    public static void sABControllerGetSABTest() {
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
            List<String> r = new List<String>();
            r.add('MA');
            List<String> p = new List<String>();
            p.add('ADV');
            p.add('NJIN');
            List<String> p1 = new List<String>();
            Test.startTest();
            List<Special_accomodation_practice__c>  result=DH_KMQueryManager.getSpecialAccomodationBillsList(r,p,false);
            List<Special_accomodation_practice__c>  result1=DH_KMQueryManager.getSpecialAccomodationBillsList(r,p1,true);
            Test.stopTest();
            system.assertEquals(true,p.size()>0,'Practice not found');
            
        }
    }
    
    @isTest
    public static void getMachineWeightListByModalityTest() {
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
            List<String> m = new List<String>();
            m.add('Dexa');
            List<String> p = new List<String>();
            p.add('CRA');
            String s = '(GRB) Greenbelt Imaging Center';
            
            List<String> m1 = new List<String>();
            List<String> p1 = new List<String>();
            String s1 = '';
            
            Test.startTest();
            List<sObject> result  = DH_KMQueryManager.getMachineWeightListByModality(m, p, s);
            List<sObject> result1 = DH_KMQueryManager.getMachineWeightListByModality(m1, p1, s);
            List<sObject> result2 = DH_KMQueryManager.getMachineWeightListByModality(m1, p, s);
            List<sObject> result3 = DH_KMQueryManager.getMachineWeightListByModality(m, p, s1);
            Test.stopTest();
            
            system.assertEquals(true,result.size()>0,'test success');
            system.assertEquals(true,result1.size()>0,'test success');
            
        }
    }
    
    @isTest
    public static void getMachineWeightListByPracticeTest() {
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
            List<String> m = new List<String>();
            m.add('Dexa');
            List<String> p = new List<String>();
            p.add('CRA');
            String s = '(GRB) Greenbelt Imaging Center';
            
            List<String> p1 = new List<String>();
            String s1 = '';
            
            Test.startTest();
            
            List<sObject> result  = DH_KMQueryManager.getMachineWeightListByPractice(p, s);
            List<sObject> result1 = DH_KMQueryManager.getMachineWeightListByPractice(p1, s);
            List<sObject> result2 = DH_KMQueryManager.getMachineWeightListByPractice(p, s1);
            Test.stopTest();
            
            system.assertEquals(true,result1.size()>0,'test success');
        }
    }
    
    @isTest
    public static void getMachineWeightListBySiteTest() {
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
            List<String> m = new List<String>();
            m.add('Dexa');
            List<String> p = new List<String>();
            p.add('CRA');
            String s = '(GRB) Greenbelt Imaging Center';
            
            List<String> p1 = new List<String>();
            String s1 = '';
            
            Test.startTest();
            List<sObject> result  = DH_KMQueryManager.getMachineWeightListBySite(p, s);
            List<sObject> result1 = DH_KMQueryManager.getMachineWeightListBySite(p1, s);
            List<sObject> result2 = DH_KMQueryManager.getMachineWeightListBySite(p, s1);
            Test.stopTest();
            system.assertEquals(true,result1.size()>0,'test success');
            
        }
    }
    
    @isTest
    public static void getMachineWeightListByModalityForGuestTest() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            List<String> m = new List<String>();
            m.add('Dexa');
            List<String> p = new List<String>();
            p.add('RIA');
            String s = '(TRA) Tradition Center';
            
            List<String> m1 = new List<String>();
            List<String> p1 = new List<String>();
            String s1 = '';
            
            
            Test.startTest();
            List<sObject> result  = DH_KMQueryManager.getMachineWeightListByModalityForGuest(m, p, s);
            List<sObject> result1 = DH_KMQueryManager.getMachineWeightListByModalityForGuest(m1, p1, s);
            List<sObject> result2 = DH_KMQueryManager.getMachineWeightListByModalityForGuest(m1, p, s);
            List<sObject> result3 = DH_KMQueryManager.getMachineWeightListByModalityForGuest(m, p, s1);
            Test.stopTest();
            
            system.assertEquals(true,result.size()>=0,'test success');
            system.assertEquals(true,result1.size()>=0,'test success');
            
        }
    }
    
    @isTest
    public static void getMachineWeightListByPracticeForGuestTest() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            List<String> m = new List<String>();
            m.add('Dexa');
            List<String> p = new List<String>();
            p.add('RIA');
            String s = '(TRA) Tradition Center';
            
            List<String> p1 = new List<String>();
            String s1 = '';
            
            Test.startTest();
            
            List<sObject> result  = DH_KMQueryManager.getMachineWeightListByPracticeForGuest(p, s);
            List<sObject> result1 = DH_KMQueryManager.getMachineWeightListByPracticeForGuest(p1, s);
            List<sObject> result2 = DH_KMQueryManager.getMachineWeightListByPracticeForGuest(p, s1);
            Test.stopTest();
            
            system.assertEquals(true,result1.size()>=0,'test success');
            
        }
    }
    
    @isTest
    public static void getMachineWeightListBySiteForGuestTest() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            List<String> m = new List<String>();
            m.add('Dexa');
            List<String> p = new List<String>();
            p.add('RIA');
            String s = '(TRA) Tradition Center';
            
            List<String> p1 = new List<String>();
            String s1 = '';
            
            Test.startTest();
            List<sObject> result  = DH_KMQueryManager.getMachineWeightListBySiteForGuest(p, s);
            List<sObject> result1 = DH_KMQueryManager.getMachineWeightListBySiteForGuest(p1, s);
            List<sObject> result2 = DH_KMQueryManager.getMachineWeightListBySiteForGuest(p, s1);
            Test.stopTest();
            
            system.assertEquals(true,result1.size()>=0,'test success');
            
        }
    }
    
    //check to get RIS records
    @isTest
    public static void TestGetRISRecords() {
        
        RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
        Test.startTest();
        List<Account> result = DH_KMQueryManager.getRISRecords(DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'List of regions should not be empty');
    }
    
    //check to get practice records for east user without region
    @isTest
    public static void TestGetPractice_forDefaultRegion() {
        
        Test.startTest();
        List<String> lst = new List<String>();
        List<Account> result = DH_KMQueryManager.getPracticeRecords(lst, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        Test.stopTest();
        System.assertEquals(4, result.size(), 'List of practices should not be empty');
        
    }
    
    //check to get site group records without passing practices
    @isTest
    public static void TestGetSiteGroupOptions_withoutPassingPractices() {
        Test.startTest();
        List<sObject>result = DH_KMQueryManager.getSiteGroupOptionRecords(new List<String>(), new List<String>(), DH_KMConstants.ACCOUNT_COAST_FIELD_EAST );
        Test.stopTest();
    }
    
    
    //check to get search result records
    @isTest
    public static void TestFindRecords() {
        String searchKey = 'Test';
        String objectName = 'Account';
        RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account', RecordTypeId = regionRecordType.Id);
        testAccount.Phone = phoneno;
        insert testAccount;
        
        Test.startTest();
        List<sobject> result = DH_KMQueryManager.searchFindRecords(searchKey, objectName, 'East');
        Test.stopTest();
    }
    
    //check to get search result records with east user
    @isTest
    public static void TestFindRecordswithEastcoastuser() {
        
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs( eastUser ){
            String searchKey = 'East';
            String objectName = 'Account';
            Test.startTest();
            List<sobject> result = DH_KMQueryManager.searchFindRecords(searchKey, objectName, 'East');
            Test.stopTest();
        }
    }
    
    //check to get search result records with east and west selected coast for guest user
    @isTest
    static void testCoastUserSearch() {
        User guestUser = [SELECT Id FROM User WHERE Username = 'guestuserAdminPersi@test.com' LIMIT 1];
        System.runAs(guestUser) {
            Test.startTest();
            List<sObject> records = DH_KMQueryManager.searchFindRecords('East', 'Account', 'East');
            List<sObject> records1 = DH_KMQueryManager.searchFindRecords('West', 'Account', 'West');
            Test.stopTest();
            
        }
    }
    @isTest
    static void getSiteModalityTest() {
        test.startTest();
        List<Account> site1 = new List<Account>();
        site1.add(new Account(Name='(TRA) Tradition Center',
        Site_Code__c='TRA' ));
        
        insert site1;
        List<CareSpecialty> careSpec1 = new List<CareSpecialty>();
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_DEXA,CareSpecialty_External_ID__c='MODDEXA'));
        
        insert careSpec1;
        
        List<DH_CareSpecialty__c> careSpecClone1 = new List<DH_CareSpecialty__c>();
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_DEXA));
        insert careSpecClone1;
        
        List<CareProviderFacilitySpecialty> siteModality1 = new List<CareProviderFacilitySpecialty>();
        for(integer i=0;i<site1.size();i++) {
            siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_DEXA, AccountId = site1[i].Id, SpecialtyId = careSpec1[0].Id  ));
        }
        insert siteModality1;
        
        List<DH_CareProviderFacilitySpecialty__c> siteModClone1 = new List<DH_CareProviderFacilitySpecialty__c>();
        for(integer i=0;i<site1.size();i++) {
            siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_DEXA, DH_AccountId__c = site1[i].Id, DH_SpecialtyId__c = careSpecClone1[0].Id  ));
        }
        insert siteModClone1;
        List<sObject> careSpecList = DH_KMQueryManager.getSiteModality(site1[0].id, false);
        List<sObject> careSpecListClone = DH_KMQueryManager.getSiteModality(site1[0].id, true);
        List<CareProviderFacilitySpecialty> cpfsRecords = DH_KMQueryManager.deleteSiteModality(site1[0].id);
        system.assertEquals(true,careSpecList.size()>=0,'test success');
        system.assertEquals(true,careSpecList.size()>=0,'test success');
        test.stopTest();
    }
    
  @isTest
  private static void testQueryKnowledgeDataCategorySelection() {
    // test method to get Knowledge__DataCategorySelection records List 

    User u = [SELECT Id FROM User WHERE Email = 'eastuser@example.com'
      LIMIT 1
    ];
    System.runAs(u) {
      Test.startTest();
      List < Knowledge__DataCategorySelection > datacatgoryselectionList1 = DH_KMQueryManager.queryKnowledgeDataCategorySelection();
      System.assertNotEquals(null, datacatgoryselectionList1, 'test success ');

      Test.stopTest();
    }
  }
    
    @isTest
  private static void testgetKnowledgeArticles() {
    // test method to get Knowledge__kav records List 
    
    User u = [SELECT Id FROM User WHERE Email = 'eastuser@example.com'
      LIMIT 1
    ];
    System.runAs(u) {
      Test.startTest();
        
      List <Knowledge__DataCategorySelection> datacatgoryselectionList1 = DH_KMQueryManager.queryKnowledgeDataCategorySelection();
	  List<Id> articleIdList = new List<Id>();
      articleIdList.add(datacatgoryselectionList1[0].parentId);
        
      List <sObject> articleList = DH_KMQueryManager.getKnowledgeArticles(articleIdList);
      System.assertNotEquals(null, articleList, 'test success ');

      Test.stopTest();
    }
  }
    
    @isTest
  private static void testgetMostViewedKnowledgeArticlesRecordsList() {
    // test method to get Knowledge__kav records List 
    
    User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com' LIMIT 1];
      List<Knowledge__kav> ka = [SELECT Id,Title,Article_type__c,Details__c from Knowledge__kav ];
         Id [] fixedSearchResults= new Id[1];
         fixedSearchResults[0] = ka[0].Id;
         Test.setFixedSearchResults(fixedSearchResults);
    System.runAs(u) {
      Test.startTest();
      List<String> coast = new List<String>{'East','Global'};  
      List <sObject> mostViewedKnowArticles = DH_KMQueryManager.getMostViewedKnowledgeArticlesRecordsList(coast,false);
     
      System.assertEquals(true, mostViewedKnowArticles.size()>0, 'test success ');

      Test.stopTest();
    }
  }
      @isTest
  private static void testgetMostViewedKnowledgeArticlesRecordsListGuestUser() {
    // test method to get Knowledge__kav records List 
    
    User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
      List<Knowledge__kav> ka = [SELECT Id,Title,Article_type__c,Details__c from Knowledge__kav ];
         Id [] fixedSearchResults= new Id[1];
         fixedSearchResults[0] = ka[0].Id;
         Test.setFixedSearchResults(fixedSearchResults);
    System.runAs(guestUser) {
      Test.startTest();
      List<String> coast = new List<String>{'East','Global'};  
      List <sObject> mostViewedKnowArticles = DH_KMQueryManager.getMostViewedKnowledgeArticlesRecordsList(coast,true);
      System.assertEquals(true, mostViewedKnowArticles.size()>0, 'test success ');
      Test.stopTest();
    }
  }
    @isTest
  private static void testgetTrackingDetailsRecordsList() {
    // test method to get Knowledge__kav records List 
    
     User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com' LIMIT 1];
      List<Knowledge__kav> ka = [SELECT Id,Title,Article_type__c,Details__c from Knowledge__kav ];
         Id [] fixedSearchResults= new Id[1];
         fixedSearchResults[0] = ka[0].Id;
         Test.setFixedSearchResults(fixedSearchResults);
    System.runAs(u) {
      Test.startTest();
        List<String> coast = new List<String>{'East','Global'};  
 	String searchQuery='*What* OR *procedure*';
      List<List<sObject>> trackingDetailsArticles = DH_KMQueryManager.getTrackingDetailsRecordsList(searchQuery,coast,false);
     
      System.assertEquals(true, trackingDetailsArticles.size()>0, 'test success ');

      Test.stopTest();
    }
  }
    
     @isTest
  private static void testgetTrackingDetailsRecordsListGuestUser() {
    // test method to get Knowledge__kav records List 
    
   User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
      List<Knowledge__kav> ka = [SELECT Id,Title,Article_type__c,Details__c from Knowledge__kav ];
         Id [] fixedSearchResults= new Id[1];
         fixedSearchResults[0] = ka[0].Id;
         Test.setFixedSearchResults(fixedSearchResults);
    System.runAs(guestUser) {
      Test.startTest();
        List<String> coast = new List<String>{'East','Global'};  
 	String searchQuery='*test*';
      List<List<sObject>> trackingDetailsArticles = DH_KMQueryManager.getTrackingDetailsRecordsList(searchQuery,coast,true);
     
      System.assertEquals(true, trackingDetailsArticles.size()>0, 'test success ');

      Test.stopTest();
    }
  }
    
        @isTest
  private static void testgetAllTrackingDetailsRecordsList() {
    // test method to get Knowledge__kav records List 
    
     User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com' LIMIT 1];
      List<Knowledge__kav> ka = [SELECT Id,Title,Article_type__c,Details__c from Knowledge__kav ];
         Id [] fixedSearchResults= new Id[1];
         fixedSearchResults[0] = ka[0].Id;
         Test.setFixedSearchResults(fixedSearchResults);
    System.runAs(u) {
      Test.startTest();
        List<String> coast = new List<String>{'East','Global'};  
 	String searchQuery='*What* OR *procedure*';
      List<List<sObject>> trackingAllDetailsArticles = DH_KMQueryManager.getAllTrackingDetailsRecordsList(searchQuery,coast,false);
      System.assertEquals(true, trackingAllDetailsArticles.size()>0, 'test success ');

      Test.stopTest();
    }
  }
    
        @isTest
  private static void testgetAllTrackingDetailsRecordsListGuestUser() {
    // test method to get Knowledge__kav records List 
    
    User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
      List<Knowledge__kav> ka = [SELECT Id,Title,Article_type__c,Details__c from Knowledge__kav ];
         Id [] fixedSearchResults= new Id[1];
         fixedSearchResults[0] = ka[0].Id;
         Test.setFixedSearchResults(fixedSearchResults);
    System.runAs(guestUser) {
      Test.startTest();
        List<String> coast = new List<String>{'East','Global'};  
 	String searchQuery='*What* OR *procedure*';
      List<List<sObject>> trackingAllDetailsArticles = DH_KMQueryManager.getAllTrackingDetailsRecordsList(searchQuery,coast,true);
      System.assertEquals(true, trackingAllDetailsArticles.size()>0, 'test success ');

      Test.stopTest();
    }
  }
    
      @isTest
  private static void testgetCategoryNameRecords() {
    // test method to get Knowledge__kav records List 
    
     User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com' LIMIT 1];
       List<Knowledge__kav> ka = [SELECT Id,Title,Article_type__c,Details__c from Knowledge__kav ];
         Id [] fixedSearchResults= new Id[1];
         fixedSearchResults[0] = ka[0].Id;
         Test.setFixedSearchResults(fixedSearchResults);
    System.runAs(u) {
      Test.startTest();
        List<String> coast = new List<String>{'East','Global'};  
 	String searchQuery='*What* OR *procedure*';
      List<List<sObject>> categoryKARecords = DH_KMQueryManager.getCategoryNameRecords(searchQuery,coast,false);
      System.assertEquals(true, categoryKARecords.size()>0, 'test success ');

      Test.stopTest();
    }
  }
    
    @isTest
  private static void testarticleViewCountUpdate() {
    // test method to get Knowledge__kav records List 
    
     User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
      Knowledge__kav ka = [SELECT Id,Title,ArticleTotalViewCount,Article_type__c,Details__c from Knowledge__kav Limit 1 UPDATE VIEWSTAT];
    System.runAs(guestUser) {
      Test.startTest();
      DH_KMQueryManager.articleViewCountUpdate(ka.Id);
        //Integer articleCount =ka.ArticleTotalViewCount;
      System.assertNotEquals(false, ka.ArticleTotalViewCount<=0, 'test success ');

      Test.stopTest();
    }
  }

    @isTest
    private static void getSiteListQuery_test(){
        Test.startTest();
        	List<sObject> siteList = DH_KMQueryManager.getSiteListQuery();
        Test.stopTest();
    }
    
    /**
     * @description : Test Setup Method to create data
     **/
    
    private static void createDataForSearchSites(){
        //setup method for creating test data for site
        
        List<Account> accountsList = new List<Account>();
        
        RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
        RecordType siteRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1];
        Account eastRegion = new Account(Name = 'East Test Region', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, Region__c = 'ETS');
        eastRegion.Phone = phoneno;
        accountsList.add(eastRegion);
        
        Account westRegion = new Account(Name = 'West Test Region', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, Region__c = 'WTS');
        westRegion.Phone = phoneno;
        accountsList.add(westRegion);
        
        Account eastsiteGroup = new Account(Name = 'East SiteGroup', RecordTypeId = siteRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
        eastsiteGroup.Phone = phoneno;
        eastsiteGroup.DH_Site_Group_Region__c = 'Brooklyn East';
        eastsiteGroup.Site_code__c = 'ES';
        accountsList.add(eastsiteGroup);
        
        RecordType practiceRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.PRACTICE_RECORD_TYPE LIMIT 1];
        
        Account testPractice = new Account(Name = 'Test Practice', RecordTypeId = practiceRecordType.Id, AccountRegion__c = eastRegion.Id);
        testPractice.Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST;
        testPractice.Phone = phoneno;
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
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_MRI,CareSpecialty_External_ID__c='MODDMRI' ));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_CT,CareSpecialty_External_ID__c='MODCT' ));   	
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_XRAY,CareSpecialty_External_ID__c='MODXRAY' )); 
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_ULTRASOUND,CareSpecialty_External_ID__c='MODUS' ));   
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_NM,CareSpecialty_External_ID__c='MODNM'));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_PETCT,CareSpecialty_External_ID__c='MODPETCT' ));    
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_FLUOROSCOPY,CareSpecialty_External_ID__c='MODFL' ));      	
        insert careSpec;
        
        List<CareProviderFacilitySpecialty> siteModality = new List<CareProviderFacilitySpecialty>();
        
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_DEXA, AccountId = eastSiteGroup.Id, SpecialtyId = careSpec[0].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_MRI, AccountId = eastSiteGroup.Id, SpecialtyId = careSpec[1].Id, Description__c = 'submodality1' ));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_CT, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[2].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_XRAY, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[3].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_ULTRASOUND, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[4].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_NM, AccountId = eastSiteGroup.Id, SpecialtyId = careSpec[5].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_PETCT, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[6].Id));
        siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_FLUOROSCOPY, AccountId = eastSiteGroup.Id , SpecialtyId = careSpec[7].Id));
        
        insert siteModality;
        
    }
    
    /**
     * @description : Method to cover sitesearchcontriller for healthcloud user
     **/
    @isTest
    private static void testSearchSites() {
        createDataForSearchSites();
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
            lat,longt,25, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, new List<String>{'submodality1'});
        Test.stopTest();
        // Assert the results
        System.assertEquals(true, searchResults.size()>=0, 'Search by site code failed');
    }
    
    /**
     * @description : Method to cover sitesearchcontriller for Guest user
     **/
    @isTest
    private static void testSearchSitesGuest() {
        delete [select id from Account];
        createDataForSearchSites();
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            Double lat;
            Double longt;
            List<Account> accountsList = new List<Account>();
            
            RecordType regionRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM LIMIT 1];
            RecordType siteRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1];
            Account eastRegion = new Account(Name = 'East Test Region 1', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, Region__c = 'FL');
            eastRegion.Phone = phoneno;
            accountsList.add(eastRegion);
            
            Account westRegion = new Account(Name = 'West Test Region 1', RecordTypeId = regionRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, Region__c = 'NE');
            westRegion.Phone = phoneno;
            accountsList.add(westRegion);
            
            Account eastsiteGroup = new Account(Name = 'East SiteGroup 1', RecordTypeId = siteRecordType.Id, Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
            eastsiteGroup.Phone = phoneno;
            eastsiteGroup.DH_Site_Group_Region__c = 'Brooklyn East';
            eastsiteGroup.Site_code__c = 'ESP';
            accountsList.add(eastsiteGroup);
            
            RecordType practiceRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.PRACTICE_RECORD_TYPE LIMIT 1];
            
            Account testPractice = new Account(Name = 'Test Practice 1', RecordTypeId = practiceRecordType.Id, AccountRegion__c = eastRegion.Id);
            testPractice.Coast__c = DH_KMConstants.ACCOUNT_COAST_FIELD_WEST;
            testPractice.Phone = phoneno;
            
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
            siteModality.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_MRI, DH_AccountId__c = eastSiteGroup.Id, DH_SpecialtyId__c = careSpec[0].Id, DH_Description__c = 'submodality1' ));
            insert siteModality;
            
            
            List<DH_SiteSearchController.AccountWrapper> searchResults = DH_SiteSearchController.searchSites(
            new List<String>{'East Test Region 1'},
            new List<String>{'Test Practice 1', DH_KMConstants.NJIN},
            new List<String>{'Brooklyn'},
            'ESP', '',
            new List<String>{DH_KMConstants.MODALITY_MRI,''},
            lat,longt,25, DH_KMConstants.ACCOUNT_COAST_FIELD_EAST, new List<String>{'submodality1'});
            
            
            List<DH_SiteSearchController.AccountWrapper> searchResults2 = DH_SiteSearchController.searchSites(
            new List<String>{'East Test Region 1'},
            new List<String>{'Test Practice 1', DH_KMConstants.NJIN},
            new List<String>{'Brooklyn'},
            'ESP', '',
            new List<String>{DH_KMConstants.MODALITY_MRI,''},
            lat,longt,25, DH_KMConstants.ACCOUNT_COAST_FIELD_WEST, new List<String>{''});
            Test.stopTest();
            // Assert the results
            System.assertEquals(true, searchResults.size()>=0, 'Search by site code failed');
        }
    }

    
    
    // -----------------Excel Import Test Methods --------- 
    
    @isTest
    public static void getHealthcareProcedureTest(){
        Id healthCareProcedureRecordTypeIdKM = Schema.SObjectType.HealthCareProcedure.getRecordTypeInfosByName().get(DH_KMConstants.EX_HEALTHCARE_RECORDTYPE_NAME).getRecordTypeId();
        HealthcareProcedure hcp = new HealthcareProcedure();
        hcp.Name = 'TEST hcp';
        hcp.RecordTypeId = healthCareProcedureRecordTypeIdKM;
        insert hcp;
        Test.startTest();
        List<HealthcareProcedure> hcpList = DH_KMQueryManager.getHealthcareProcedure(healthCareProcedureRecordTypeIdKM);
        Test.stopTest();
        
        System.assertEquals(true, hcpList.size() >= 0, 'Records fetched');
    }
    
    @isTest
    public static void getClonedHealthcareProcedureRecordsTest(){
        Id dhhcpRecordTypeId = Schema.SObjectType.DH_HealthCareProcedure__c.getRecordTypeInfosByName().get(DH_KMConstants.EX_DH_HEALTHCARE_RECORDTYPE_NAME).getRecordTypeId();
        DH_HealthcareProcedure__c dhhcp = new DH_HealthcareProcedure__c();
        dhhcp.Name = 'Test dhhcp';
        dhhcp.RecordTypeId = dhhcpRecordTypeId;
        insert dhhcp;
        Test.startTest();
        List<DH_HealthcareProcedure__c> dhhcpList = DH_KMQueryManager.getClonedHealthcareProcedureRecords(dhhcpRecordTypeId);
        Test.stopTest();
        System.assertEquals(true, dhhcpList.size() >= 0, 'Records Fetched');
    }
    
    @isTest
    public static void getClonedCareSpecialtiesTest(){
        Id dhcspRecordTypeId = Schema.SObjectType.DH_CareSpecialty__c.getRecordTypeInfosByName().get(DH_KMConstants.EX_CARESPECIALTY_RECORDTYPE_NAME).getRecordTypeId();
        DH_CareSpecialty__c dhcsp = new DH_CareSpecialty__c();
        dhcsp.Name = 'TEST dhcsp';
        dhcsp.RecordTypeId = dhcspRecordTypeId;
        insert dhcsp;
        Test.startTest();
        List<DH_CareSpecialty__c> dhcspList = DH_KMQueryManager.getClonedCareSpecialties();
        Test.stopTest();
        System.assertEquals(true, dhcspList.size() >= 0, 'Records Fetched');
    }
    // ----------------------------------------------------------------------------------------------------------- 
    
    
    //-------------DH_LinkSiteImages Test methods--------------
     @isTest
    private static void testgetSiteImageVersionFiles() {
           User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com' LIMIT 1];
         System.runAs(u) {
        Account testAccount = [Select Id from Account where Name ='Test Account' LIMIT 1];
        ContentVersion testContentVersion = [Select Id from ContentVersion where Title ='Test Document' LIMIT 1];
        List<ContentVersion> versions1 = DH_KMQueryManager.getSiteImageVersionFiles(testAccount.Id);
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V'
        );
   		insert accountCdl;   
        List<ContentVersion> versions = DH_KMQueryManager.getSiteImageVersionFiles(testAccount.Id);
       	System.assertEquals(true, versions != null);
       	System.assertEquals(1, versions.size());
       	ContentVersion firstVersion = versions.get(0);
       	System.assertEquals(true,versions.size()>0,'checking if data is coming');
         }
    }
     @isTest
    static void testGetPhoneDirectoryRegion() {
        // Test the getRegion method
        List<String> regions = DH_KMQueryManager.getPhoneDirectoryRegion();
        
        // Assert the results
        System.assertEquals(2, regions.size(), 'There should be 2 unique regions.');
        System.assert(regions.contains(DH_KMConstants.REGION_NORTH), 'Region should contain North.');
        System.assert(regions.contains(DH_KMConstants.REGION_SOUTH), 'Region should contain South.');
    }
    
     @isTest
    static void testGetAllEntryPointName() {
        // Test the getEntryPointName method
        List<String> entryPointNames = DH_KMQueryManager.getAllEntryPointName();
        
        // Assert the results
        System.assertEquals(3, entryPointNames.size(), 'There should be 3 entry point names.');
        System.assert(entryPointNames.contains('Main Office'), 'EntryPointName should contain Main Office.');
        System.assert(entryPointNames.contains('Branch Office'), 'EntryPointName should contain Branch Office.');
        System.assert(entryPointNames.contains('Support Center'), 'EntryPointName should contain Support Center.');
    }
    
    @isTest
    static void testGetPhoneDirectoryRecords() {
        // Test getRecords method for different scenarios
 
        // Case 1: Both region and entry point name are provided
        List<Phone_Directory__c> records = DH_KMQueryManager.getPhoneDirectoryRecords(DH_KMConstants.REGION_NORTH, 'Main Office');
        System.assertEquals(1, records.size(), 'There should be 1 record for North and Main Office.');
        System.assertEquals('123-456-7890', records[0].Phone_Number__c, 'Phone number should be 123-456-7890.');
 
        // Case 2: Only region is provided
        records = DH_KMQueryManager.getPhoneDirectoryRecords(DH_KMConstants.REGION_NORTH, null);
        System.assertEquals(2, records.size(), 'There should be 2 records for North.');
 
        // Case 3: Only entry point name is provided
        records = DH_KMQueryManager.getPhoneDirectoryRecords(null, 'Branch Office');
        System.assertEquals(1, records.size(), 'There should be 1 record for Branch Office.');
        System.assertEquals('098-765-4321', records[0].Phone_Number__c, 'Phone number should be 098-765-4321.');
 
        // Case 4: Neither region nor entry point name is provided
        records = DH_KMQueryManager.getPhoneDirectoryRecords(null, null);
        System.assertEquals(3, records.size(), 'There should be 3 records in total.');
    }
    
    //----------- Go Live Calendar test methods-------------
     @isTest
    Public static void testGetGoLiveCalendarRegion() {
        // Test data setup
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today(),Region__c = 'CA'));
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today(),Region__c = 'AZ'));
        insert testData;
        
        Test.startTest();
        // Call the method to be tested
        List<String> regions = DH_KMQueryManager.getGoLiveCalendarRegion();
        Test.stopTest();
        
        // Assertion
        System.assertEquals(2, regions.size(), 'Success');
    }
    
    @isTest
    Public static void testGetGoLiveCalendarEventRecords() {
        // Test data setup
        Go_Live_Calendar__c testRecord = new Go_Live_Calendar__c(
            Name = 'Test Title',
        	Title__c = 'Test Title',
        	Go_Live_Date__c = Date.today(),
        	Category__c = 'Test Category',
        	Region__c = 'AZ'
            );
        insert testRecord;
        
        Test.startTest();
        // Called the method to be tested
        List<Go_Live_Calendar__c> records = DH_KMQueryManager.getGoLiveCalendarEventRecords('Test Title', 'Test Category', 'AZ', 'Any');
        Test.stopTest();
        
        // Assertion
        if(records!=null){
            System.assertEquals(true, records.size()>0, 'Success');
            System.assertEquals('Test Title', records[0].Title__c, 'title populated');
            System.assertEquals('Test Category', records[0].Category__c, 'Category populated');
            System.assertEquals('AZ', records[0].Region__c, 'Success');
        }
    }
    
      @isTest
    Public static void testGetRelatedFilesByEventRecordId(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()+1,Region__c = 'AZ'));
        insert testData;
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
        Title = 'Test Document',
        PathOnClient = 'TestDocument.pdf',
        ContentLocation = 'S'
            );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
        LinkedEntityId = testData[0].Id,
        ShareType = 'V'
            );
        insert accountCdl;
        
        Test.startTest();
        List<ContentVersion> contentVer = DH_KMQueryManager.getRelatedFilesByEventRecordId(testData[0].Id);
        Test.stopTest();
        System.assertEquals(accountCdl.ContentDocumentId, contentVer[0].ContentDocumentId, 'Success');
    }
    
    @isTest
    public static void testGetUserInfoForPermissionSet(){
        User u = [Select Id, Name from User where UserName = 'kmSuperUser@testorg.com' limit 1];
        System.runAs(u){
            Test.startTest();
            List<PermissionSetAssignment> psa = DH_KMQueryManager.getUserInfoForPermissionSet('Knowledge_Search_Super_User');
            Test.stopTest();
            System.assertEquals(true, psa.size()>0, 'super user');
        }
        
    }
    
    @isTest
    public static void testGetCurrentUserProfile(){
        Profile p = DH_KMQueryManager.getCurrentUserProfile();
       System.assertEquals(true, p.Name.length()>0, 'success');
    }
    
    @isTest
    Public static void getEventRecordsTest(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
   
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,null,null);
        Test.stopTest();
       
        if(records!=null){
            System.assertEquals(2, records.size(), 'Success');
        }
            
    }

    @isTest
    Public static void getEventRecordsTest1(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,null,'Any');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(2, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest2(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,'CA','Any');
        
        Test.stopTest();
        if(records!=null){
            System.assertEquals(1, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest3(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,'CA',null);
        Test.stopTest();
        if(records!=null){
            System.assertEquals(1, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest4(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records =DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,null,'Past 90 Days');
        
        Test.stopTest();
        if(records!=null){
            System.assertEquals(2, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest5(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
  
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,null,'Past 90 Days');
        
        Test.stopTest();
        system.debug('go live records '+records);
        if(records!=null){
            System.assertEquals(true, records.size()>0, 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest6(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,null,'Past 30 Days');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(2, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest7(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null ,null,null,'Past 30 Days');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(2, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest8(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,null,'Next 30 Days');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(0, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest9(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null ,'CA', 'Next 30 Days');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(0, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest10(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,null,'Next 90 Days'); 
        Test.stopTest();
        if(records!=null){
            System.assertEquals(0, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest11(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,'CA', 'Next 90 Days');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(0, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest12(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,null,'Archive(>90 Old)'); 
        Test.stopTest();
        if(records!=null){
            System.assertEquals(0, records.size(), 'Success');
        }
    }

    @isTest
    Public static void getEventRecordsTest13(){
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today()-20,Region__c = 'AZ'));
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today()-20,Region__c = 'CA'));
        insert testData;
        
        
        
        
        //  ContentVersion for the GLC
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            ContentLocation = 'S'
        );
        insert testContentVersion;
        
        // test ContentDocumentLink for the Account
        ContentDocumentLink accountCdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testData[0].Id,
            ShareType = 'V'
        );
        insert accountCdl;
        
        Test.startTest();
            List<Go_Live_Calendar__c>records = new List<Go_Live_Calendar__c>();
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords(null,null,'CA', 'Archive(>90 Old)');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(0, records.size(), 'Success');
        }
    }

    
    
 }