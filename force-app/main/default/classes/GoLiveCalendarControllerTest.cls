/******************************************************************************************************************************************************
 *
 * Apex Test Class : GoLiveCalendarControllerTest
 *
 * Created Date    : 14/06/2024
 *
 * @description    : This test class verifies the functionality of the GoLiveCalendarController class
 *
 * @JIRA Id        : CC-103
 *
 * */
@isTest
public with sharing class GoLiveCalendarControllerTest {
    /*
     * @description  this method creates test data to be used in the test methods
     *
     * */
    @testsetup
    public static void setTestData(){
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
    }
    
    @isTest
    Public static void testGetRegion() {
        // Test data setup
        List<Go_Live_Calendar__c> testData = new List<Go_Live_Calendar__c>();
        testData.add(new Go_Live_Calendar__c(Name='Test1',Title__c='Test1',Category__c='TestCat1',Go_Live_Date__c=Date.today(),Region__c = 'CA'));
        testData.add(new Go_Live_Calendar__c(Name='Test2',Title__c='Test2',Category__c='TestCat2',Go_Live_Date__c=Date.today(),Region__c = 'AZ'));
        insert testData;
        
        Test.startTest();
        // Call the method to be tested
        List<String> regions = GoLiveCalendarController.getRegion();
        Test.stopTest();
        
        // Assertion
        System.assertEquals(2, regions.size(), 'Success');
    }
    
    @isTest
    Public static void testGetEventRecords() {
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
        List<Go_Live_Calendar__c> records = GoLiveCalendarController.getEventRecords('Test Title', 'Test Category', 'AZ', 'Any');
        Test.stopTest();
        
        // Assertion
        if(records!=null){
            System.assertEquals(1, records.size(), 'Success');
            System.assertEquals('Test Title', records[0].Title__c, 'title populated');
            System.assertEquals('Test Category', records[0].Category__c, 'Category populated');
            System.assertEquals('AZ', records[0].Region__c, 'Success');
        }
    }
    
    @isTest
    Public static void getTitle(){
        Go_Live_Calendar__c testRecord = new Go_Live_Calendar__c(
            Title__c = 'Test Title',
        Go_Live_Date__c = Date.today(),
        Category__c = 'Test Category',
        Region__c = 'CA'
            );
        insert testRecord;
        
        Test.startTest();
        List<String> records=GoLiveCalendarController.getTitle();
        Test.stopTest();
        
        System.assertEquals(1, records.size(), 'Success');
        System.assertEquals('Test Title', records[0], 'Success');
    }
    
    @isTest
    Public static void getProjectCategoryTest(){
        Go_Live_Calendar__c testRecord = new Go_Live_Calendar__c(
            Title__c = 'Test Title',
        Go_Live_Date__c = Date.today(),
        Category__c = 'Test Category',
        Region__c = 'AZ'
            );
        insert testRecord;
        
        Test.startTest();
        List<String> records=GoLiveCalendarController.getProjectCategory();
        Test.stopTest();
        
        System.assertEquals(1, records.size(), 'Success');
        System.assertEquals('Test Category', records[0], 'test populated');
    }
    
    
    @isTest
    Public static void getgoLiveDateTest(){
        
        Test.startTest();
        List<String> goLiveDateList = GoLiveCalendarController.getgoLiveDate();
        Test.stopTest();
        
        System.assertEquals(6, goLiveDateList.size(), 'Success');
        System.assertEquals('Any', goLiveDateList[0], 'Success');
        System.assertEquals('Past 90 Days', goLiveDateList[1], 'Success');
        System.assertEquals('Past 30 Days', goLiveDateList[2], 'Success');
        System.assertEquals('Next 30 Days', goLiveDateList[3], 'Success');
        System.assertEquals('Next 90 Days', goLiveDateList[4], 'Success');
        System.assertEquals('Archive(>90 Old)', goLiveDateList[5], 'Success');
    }
    
    @isTest
    Public static void creatEventTest(){
        
        Test.startTest();
        GoLiveCalendarController.createEvent('Test Title', Date.today(), 'Test Category', 'AZ');
        Test.stopTest();
        
        List<Go_Live_Calendar__c> records= [Select Title__c,Category__c,Region__c from Go_Live_Calendar__c];
        System.assertEquals(1, records.size(), 'Success');
        System.assertEquals('Test Title', records[0].Title__c, 'Success');
        System.assertEquals('Test Category', records[0].Category__c, 'Success');
        System.assertEquals('AZ', records[0].Region__c, 'Success');
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
        records = GoLiveCalendarController.getEventRecords(null,null,null,null);
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
        records = GoLiveCalendarController.getEventRecords(null,null,null,'Any');
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
        records = GoLiveCalendarController.getEventRecords(null,null,'CA','Any');
        
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
        records = GoLiveCalendarController.getEventRecords(null,null,'CA',null);
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
        records = GoLiveCalendarController.getEventRecords(null,null,null,'Past 90 Days');
        
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
        records = GoLiveCalendarController.getEventRecords(null,null,'CA','Past 90 Days');
        
        Test.stopTest();
        if(records!=null){
            System.assertEquals(1, records.size(), 'Success');
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
        records = GoLiveCalendarController.getEventRecords(null,null,null,'Past 30 Days');
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
        records = GoLiveCalendarController.getEventRecords(null ,null,'CA','Past 30 Days');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(1, records.size(), 'Success');
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
        records = GoLiveCalendarController.getEventRecords(null,null,null,'Next 30 Days');
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
        records = GoLiveCalendarController.getEventRecords(null,null ,'CA', 'Next 30 Days');
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
        records = GoLiveCalendarController.getEventRecords(null,null,null,'Next 90 Days');
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
        records = GoLiveCalendarController.getEventRecords(null,null,'CA', 'Next 90 Days');
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
        records = GoLiveCalendarController.getEventRecords(null,null,null,'Archive(>90 Old)');
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
        records = GoLiveCalendarController.getEventRecords(null,null,'CA', 'Archive(>90 Old)');
        Test.stopTest();
        if(records!=null){
            System.assertEquals(0, records.size(), 'Success');
        }
    }
    
    @isTest
    Public static void getRelatedFilesByRecordIdTest(){
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
        ContentVersion  contentVer = GoLiveCalendarController.getRelatedFilesByRecordId(testData[0].Id);
        Test.stopTest();
        
        System.debug(testContentVersion);
        System.assertEquals(accountCdl.ContentDocumentId, contentVer.ContentDocumentId, 'Success');
    }
    
    @isTest
    public static void hasPermissionSetTest(){
        User u = [Select Id, Name from User where lastName = 'TestingUser' limit 1];
        System.runAs(u){
            Test.startTest();
            Boolean flag = GoLiveCalendarController.hasPermissionSet('Knowledge_Search_Super_User');
            Test.stopTest();
            System.assertEquals(true, flag, 'super user');
        }
        
    }
}