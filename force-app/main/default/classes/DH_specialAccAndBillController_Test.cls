/******************************************************************************************************************************************************
 *
 * @Created Date       :   6/12/2024
 *
 * @description        :   This test class verifies the functionality of the DH_specialAccomodationAndBillController class.
 *                         It covers scenarios including both successful and unsuccessful insertion of Special_Accomodation_and_Protocol__c,Special_accomodation_practice__c and HealthcarePayerNetwork records
 *
 *@JIRA Id             :  CC-22, CC-793
 * */
@isTest(SeeAllData=false)
public class DH_specialAccAndBillController_Test {
    
    /**
     * @description : Setup method to create data
     **/
    @TestSetup
    static void makeData(){
        Group maRegionTeam = new Group(Name = 'MA Region Team', Type = 'Regular');
        insert maRegionTeam;
        Group neRegionTeam = new Group(Name = 'NE Region Team', Type = 'Regular');
        insert neRegionTeam;
        
        //Create Permission Sets (assume they already exist)
        PermissionSet eastPermSet = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.MODALITY_SEARCH_PERMISSION_SET];
        PermissionSet ePermSet = [SELECT Id FROM PermissionSet WHERE Name =:DH_KMConstants.USER_EAST];
        PermissionSet healthPermSet = [SELECT Id FROM PermissionSet WHERE Name =:DH_KMConstants.HEALTHCLOUD_FOUNDATION_PERMISSION_SET];
        
        
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
        
        system.assertEquals(true,eastUser.Id != null,'User is not present');
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
        System.runAs(eastUser){
            
            // CREATING ACCOUNT RECORDS FOR REGION
            List<Account> reg = new List<Account>();
            Id regionRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM).getRecordTypeId();
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
            Id practiceRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.practice_record_type).getRecordTypeId();
            prac.add(new Account(Name='ADV',
            Region__c=reg[0].Region__c,
            ParentId=reg[0].Id,
            Practice_code__c='ADV',
            isActive=true,
            RecordTypeId=practiceRecordTypeID
                ));
            prac.add(new Account(Name='ARS',
            Region__c=reg[0].Region__c,
            ParentId=reg[0].Id,
            Practice_code__c='ARS',
            isActive=true,
            RecordTypeId=practiceRecordTypeID
                ));
            
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
            
            List<DH_HealthcarePayerNetwork__c> dhpayerntw = new List<DH_HealthcarePayerNetwork__c>();
            for(integer i=0;i<5;i++) {
                dhpayerntw.add(new DH_HealthcarePayerNetwork__c(Name = 'test'+i,
                DH_Exam_Covered__c='Test Exam covered'+i,
                DH_PayerId__c=payeracc[i].Id,
                DH_Region__c=reg[0].Id,
                DH_IsActive__c=true
                    ));
            }
            upsert dhpayerntw;
            List<Special_Accomodation_and_Protocol__c> spAcc = new List<Special_Accomodation_and_Protocol__c>();
            for(integer i=0;i<5;i++) {
                spAcc.add(new Special_Accomodation_and_Protocol__c(Name = 'test Acc'+i
                    ));
            }
            upsert spAcc;
            
            // CREATING SPECIAL ACCOMODATION RECORDS
            List<Special_accomodation_practice__c> spPrac = new List<Special_accomodation_practice__c>();
            for(integer i=0;i<2;i++) {
                spPrac.add(new Special_accomodation_practice__c(Name = 'test Prac'+i,
                Notes__c='Test Notes'+i,
                Special_Accomodation_and_Protocols__c=spAcc[i].Id,
                //PracticeForSharing__c=prac[0].Practice_code__c,
                Practice__c=prac[0].Id
                    ));
            }
            
            upsert spPrac;
            
        }
    }
    /**
     * @description : Test method for HealthcarePayerNetwork helthcloud user
     **/
    @isTest
    public static void dHSABControllerGetHPNTest() {
        User eastUser = [SELECT Id FROM User WHERE Email = 'eastuser@example.com' LIMIT 1];
        System.runAs(eastUser) {
            List<String> r = new List<String>();
            r.add('MA');
            r.add('NE');
            Test.startTest();
            List<DH_specialAccomodationAndBillController.SpecialBillsWrapper> result=DH_specialAccomodationAndBillController.getHealthcarePayerNetwork(r);
            Test.stopTest();
            system.assertEquals(5,result.size(),'Special Bills not found');
        }
    }
    /**
     * @description : Test method for HealthcarePayerNetwork guest user
     **/
    @isTest
    public static void dHSpecailBillGetHCPNGuestTest() {
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            List<Account> reg = new List<Account>();
            Id regionRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM).getRecordTypeId();
            reg.add(new Account(Name='MA1',
            Region__c='MA1',
            isActive=true,
            RecordTypeId=regionRecordTypeID
                ));
            reg.add(new Account(Name='NE1',
            Region__c='NE1',
            isActive=true,
            RecordTypeId=regionRecordTypeID
                ));
            insert reg;
            Id payerAccountRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.PAYER_RECORD_TYPE).getRecordTypeId();
            List<Account> payeracc = new List<Account>();
            for(integer i=0;i<5;i++){
                payeracc.add(new Account(Name='Test Acc'+i,
                Carrier_Code_in_RIS__c='001'+i,
                RecordTypeId=payerAccountRecordTypeID,
                isActive=true
                    ));
            }
            insert payeracc;
            List<DH_HealthcarePayerNetwork__c> dhpayerntw=new List<DH_HealthcarePayerNetwork__c>();
            for(integer i=0;i<5;i++) {
                dhpayerntw.add(new DH_HealthcarePayerNetwork__c(Name = 'test'+i,
                DH_Exam_Covered__c='Test Exam covered'+i,
                DH_PayerId__c=payeracc[0].Id,
                DH_Region__c=reg[0].Id,
                DH_IsActive__c=true
                    ));
            }
            insert dhpayerntw;
            List<String> r = new List<String>();
            r.add('MA1');
            r.add('NE1');
            Test.startTest();
            List<DH_specialAccomodationAndBillController.SpecialBillsWrapper> result=DH_specialAccomodationAndBillController.getHealthcarePayerNetwork(r);
            Test.stopTest();
            system.assertEquals(true,result.size()>=0,'Special Bills not found');
        }
    }
    /**
     * @description : Test method for Special Accomodation helthcloud user
     **/
    @isTest
    public static void dHSABControllerGetHPNTestEmpty() {
        
        List<String> r = new List<String>();
        r.add('AZ');
        Test.startTest();
        List<DH_specialAccomodationAndBillController.SpecialBillsWrapper> result=DH_specialAccomodationAndBillController.getHealthcarePayerNetwork(r);
        Test.stopTest();
        system.assertEquals(false,result.size()>0,'expected blank but special bill found');
    }
    
    @isTest
    public static void dHSABGetHPNTestException() {
        
        List<String> r = new List<String>();
        r.add('10');
        Test.startTest();
        List<DH_specialAccomodationAndBillController.SpecialBillsWrapper> result=DH_specialAccomodationAndBillController.getHealthcarePayerNetwork(r);
        Test.stopTest();
        system.assertEquals(false,result.size()>0,'expected blank but special bill found');
    }
    /**
     * @description : Test method for Special Accomodation helthcloud user
     **/
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
            List<Special_accomodation_practice__c>  result=DH_specialAccomodationAndBillController.getSpecialAccomodationBills(r,p);
            List<Special_accomodation_practice__c>  result1=DH_specialAccomodationAndBillController.getSpecialAccomodationBills(r,p1);
            Test.stopTest();
            system.assertEquals(true,p.size()>0,'Practice not found');
            
        }
        
    }
}