/*
* ***************************************************************************************************************************
* Apex Class Name - DH_BatchforNormalizationTest
* Version - 0.1
* Created Date - 
* Function - Batch to test the  normalization test.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Prasanna Anjakar                               Intial version.
* *****************************************************************************************************************************
*/
@isTest
public class DH_BatchForNormalizationTest {
    @TestSetup
    static void setupData() {
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        
        List<Account> regionAccountsList = DH_ExclusioModalityCallcenterTestDataFac.createRegionAccounts();
        insert regionAccountsList;
        
        List<Account> allOtherAccountsList = new List<Account>();
        for (Account acc : regionAccountsList) {
            List<Account> regionBasedOtherAccountsList = DH_ExclusioModalityCallcenterTestDataFac.createOtherAccounts(acc.Id, acc.Region__c);
            allOtherAccountsList.addAll(regionBasedOtherAccountsList);
        }
        insert allOtherAccountsList;
        
        List<Account> listOfAccounts = [SELECT Id, Name, RecordType.Name, DH_RIS_Unique_Code__c, DH_Physician_Formula_Id__c, DH_Physician_Id__c FROM Account WHERE RecordType.Name = 'Physician'];
        List<CareSpecialty> allRegionCareSpecialityList = new List<CareSpecialty>();
        for (Account acc : regionAccountsList) {
            List<CareSpecialty> regionBasedCareSpecialityList = DH_ExclusioModalityCallcenterTestDataFac.createCareSpeciality(acc.Id, acc.Region__c);
            allRegionCareSpecialityList.addAll(regionBasedCareSpecialityList);
        }
        insert allRegionCareSpecialityList;
        
        List<HealthcareProcedure> allRegionHealthCareProcedure = new List<HealthcareProcedure>();
        for (Account acc : regionAccountsList) {
            List<HealthCareProcedure> regionBasedHealthCareProcedure = DH_ExclusioModalityCallcenterTestDataFac.createHealthCareProcedure(acc.Id, acc.Region__c);
            allRegionHealthCareProcedure.addAll(regionBasedHealthCareProcedure);
        }
        insert allRegionHealthCareProcedure;
        
        List<DH_Call_Center__c> callCenterList = DH_ExclusioModalityCallcenterTestDataFac.createCallCenter();
        insert callCenterList;
        
        User user1 = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        user1.Email = 'unique' + System.currentTimeMillis() + '@example.com';
        insert user1;
        List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
        
        DH_Call_Center_Data_Sheet__c exclusion = new DH_Call_Center_Data_Sheet__c();
        Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
        exclusion.DH_System__c ='TESTFL';
        exclusion.Published__c=true;
        exclusion.DH_Site_Code__c ='TJAC'; 
        exclusion.Name = 'Unique Exclusion';
        exclusion.OwnerId = denormalizedUser.Id;
        exclusion.DH_Previous_Value__c='{ "DH_System__c" : "TESTFL","Published__c" : true,"Name" : "Unique Exclusion", "RecordTypeId" : "'+exclusionId +'" }';
        exclusion.RecordTypeId  =exclusionId;
        records.add(exclusion);
        
        
        Id mpId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Modality Priority').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c modalityPriority = new DH_Call_Center_Data_Sheet__c();
        modalityPriority.Name = 'Unique modalityPriority';
        modalityPriority.OwnerId = denormalizedUser.Id;
        modalityPriority.DH_System__c='TESTCA';
        modalityPriority.DH_Relative_Priority__c='990';
        modalityPriority.Published__c=true;
        modalityPriority.DH_Previous_Value__c='{ "DH_System__c" : "TESTCA","Published__c" : true,"DH_Relative_Priority__c" : "990","Name" : "Unique modalityPriority", "RecordTypeId" : "'+mpId +'" }';
        modalityPriority.recordTypeId=mpId;
        
        records.add(modalityPriority);
        
        DH_Call_Center_Data_Sheet__c callCenterMapping = new DH_Call_Center_Data_Sheet__c();
        Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        callCenterMapping.Name = 'Unique callCenterMapping ';
        callCenterMapping.DH_Fake_call_center_site_code__c = 'TESTC';
        callCenterMapping.DH_Site_Code_or_Call_Center_Code__c = 'TESTC';
        callCenterMapping.OwnerId = denormalizedUser.Id;
        callCenterMapping.DH_System__c='TESTCA';
        callCenterMapping.Published__c=true;
        callCenterMapping.DH_Previous_Value__c= '{ "DH_System__c" : "TESTCA","Published__c" : true,"Name":"Unique callCenterMapping","DH_Fake_call_center_site_code__c" : "TESTC", "DH_Site_Code_or_Call_Center_Code__c" : "TESTC", "RecordTypeId" : "'+ccmId +'" }';
        callCenterMapping.RecordTypeId=ccmId;
        records.add(callCenterMapping);
        
        
        DH_Call_Center_Data_Sheet__c callCenterHours = new DH_Call_Center_Data_Sheet__c();
        Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
        callCenterHours.Name = 'Unique callCenterHours';
        callCenterHours.DH_Site_Code_or_Call_Center_Code__c = 'TESTAZCALLCTR';
        callCenterHours.DH_System__c='TESTAZ';
        callCenterHours.DH_Day_of_Week__c='Monday';
        callCenterHours.Published__c=true;
        callCenterHours.OwnerId = denormalizedUser.Id;
        callCenterHours.DH_Previous_Value__c='{ "DH_System__c" : "TESTAZ","Published__c" : true,"Name":"Unique callCenterHours", "DH_Site_Code_or_Call_Center_Code__c" : "TESTAZCALLCTR","DH_Day_of_Week__c" : "Monday", "RecordTypeId" : "'+cchId +'" }';
        callCenterHours.RecordTypeId=cchId;
        
        records.add(callCenterHours);        
        insert records;
        
        DH_Exclusions__c ex = new DH_Exclusions__c();
        ex.DH_CallCenterDataSheet__c=exclusion.Id;
        ex.DH_UniqueKey__c='TESTFL,,TJAC,,,,,,,end';
        insert ex;
        DH_Modality_Priority__c mp=new DH_Modality_Priority__c();
        mp.DH_CallCenterDataSheet__c=modalityPriority.Id;
        mp.DH_UniqueKey__c='TESTCA,,,,,,,,,,end,#-#,,';
        insert mp;
        
        DH_Call_Center_Mapping__c ccm = new DH_Call_Center_Mapping__c();
        ccm.DH_CallCenterDataSheet__c=callCenterMapping.Id;
        ccm.DH_UniqueKey__c='TESTCA,,,,,,,,,,end,#-#,,';
        insert ccm;
        DH_Call_Center_Hours__c cch = new DH_Call_Center_Hours__c();
        cch.DH_CallCenterDataSheet__c=callCenterHours.Id;
        cch.DH_UniqueKey__c='TESTAZ,,,,,,,,,,end,#-#,,';
        insert cch;

        
        //  DH_BatchForNormalization.updateIsTestSetup(false); 
        List<DH_Exclusions__c> exlist = [SELECT Id FROM DH_Exclusions__c];        
    }
    
    //Test method to create denormalized record for DH_Call_Center_Data_Sheet__c for each record type and also to cover update and publish multiple records scenario
    @isTest
    public static void testPublishDenormalizedListRecordTypes1() {
        User denormalizedUser = [SELECT Id FROM User WHERE email = 'prasanna@example.com' LIMIT 1];
        PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
        DH_BatchForNormalization.updateIsTestSetup(false); 
        System.runAs(denormalizedUser) {
            Test.startTest();
            Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
            List<DH_Call_Center_Data_Sheet__c> recordsUpdate = new List<DH_Call_Center_Data_Sheet__c>();
            DH_Call_Center_Data_Sheet__c exclusions = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c,RecordTypeId FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique Exclusion' LIMIT 1];
            exclusions.DH_System__c = 'TESTFL,TESTMA,TESTCA';
            exclusions.DH_Practice_Code__c = 'TESTBRS';
            exclusions.DH_Site_Code__c = 'TJAC,TGIC';
            exclusions.DH_Carrier_Code__c = 'TEST8266';
            exclusions.DH_Ref_Dr__c = '2000050135';
            exclusions.DH_New_or_Re_Schedule__c = 'R';
            exclusions.RecordTypeId  =exclusionId;
            
            recordsUpdate.add(exclusions);
            
            update recordsUpdate;
            // Create an instance of the class and call the method
            Integer chunkSize =20;
            DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(1,recordsUpdate);
            batchInstanceNext.batchSize = chunkSize;
            Database.executeBatch(batchInstanceNext,chunkSize);
            
            Test.stopTest();
            List<DH_Exclusions__c> ex = [SELECT Id FROM DH_Exclusions__c];
            
            System.assertEquals(6, ex.size(), 'Batch job should be enqueued');
        }
        
    }
    
    @isTest
    public static void testPublishDenormalizedListRecordTypes2() {
        User denormalizedUser = [SELECT Id FROM User WHERE email = 'prasanna@example.com' LIMIT 1];
        PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
        System.runAs(denormalizedUser) {
            Test.startTest();
            Id mpId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Modality Priority').getRecordTypeId();
            
            List<DH_Call_Center_Data_Sheet__c> recordsUpdate = new List<DH_Call_Center_Data_Sheet__c>();
            DH_Call_Center_Data_Sheet__c modalityPrioritys = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c,RecordTypeId FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique modalityPriority' LIMIT 1];
            modalityPrioritys.DH_System__c = 'TESTFL,TESTCA';
            modalityPrioritys.DH_Modality_Code_aka_Proc_Group_Code__c = 'TESTPanther';
            modalityPrioritys.DH_Description__c = 'Radiation Therapy 1';
            modalityPrioritys.recordTypeId=mpId;
            
            recordsUpdate.add(modalityPrioritys);
            
            update recordsUpdate;
            
            // Create an instance of the class and call the method
            Integer chunkSize =20;
            DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(2,recordsUpdate);
            batchInstanceNext.batchSize = chunkSize;
            Database.executeBatch(batchInstanceNext,chunkSize);
            
            Test.stopTest();
            List<DH_Modality_Priority__c> mp = [SELECT Id FROM DH_Modality_Priority__c];
            System.assertEquals(2, mp.size(), 'Batch job should be enqueued');
        }
        
    }
    
    @isTest
    public static void testPublishDenormalizedListRecordTypes3() {
        User denormalizedUser = [SELECT Id FROM User WHERE email = 'prasanna@example.com' LIMIT 1];
        PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
        System.runAs(denormalizedUser) {
            Test.startTest();
    
            Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
            
            List<DH_Call_Center_Data_Sheet__c> recordsUpdate = new List<DH_Call_Center_Data_Sheet__c>();            
            DH_Call_Center_Data_Sheet__c callCenterMappings = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c,RecordTypeId FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique callCenterMapping' LIMIT 1];
            callCenterMappings.DH_System__c = 'TESTCA,TESTFL';
            callCenterMappings.DH_Site_Code__c = 'TPSL,TKEW';
            callCenterMappings.DH_Fake_call_center_site_code__c = 'TESTC';
            callCenterMappings.DH_Site_Code_or_Call_Center_Code__c = 'TESTC';
            callCenterMappings.DH_Practice_Code__c = 'TESTRIA';
            callCenterMappings.DH_ZIP__c = '1234';
            callCenterMappings.DH_Modality_Code_aka_Proc_Group_Code__c = 'TESTNM,TESTANGIO';
            callCenterMappings.RecordTypeId=ccmId;
            
            recordsUpdate.add(callCenterMappings);
            
            update recordsUpdate;
            Integer chunkSize =20;
            DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(3,recordsUpdate);
            batchInstanceNext.batchSize = chunkSize;
            Database.executeBatch(batchInstanceNext,chunkSize);
            
            Test.stopTest();
            List<DH_Call_Center_Mapping__c> ccm = [SELECT Id FROM DH_Call_Center_Mapping__c];
            System.assertEquals(8, ccm.size(), 'Batch job should be enqueued');
        }
        
    }
    
    @isTest
    public static void testPublishDenormalizedListRecordTypes4() {
        User denormalizedUser = [SELECT Id FROM User WHERE email = 'prasanna@example.com' LIMIT 1];
        PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
        System.runAs(denormalizedUser) {
            Test.startTest();                  
            Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
            List<DH_Call_Center_Data_Sheet__c> recordsUpdate = new List<DH_Call_Center_Data_Sheet__c>();            
            DH_Call_Center_Data_Sheet__c callCenterHour = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c,RecordTypeId FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique callCenterHours' LIMIT 1];
            callCenterHour.DH_System__c = 'TESTCA,TESTFL';
            callCenterHour.DH_Practice_Code__c = 'TESTBRS,TESTRIA';
            callCenterHour.DH_Day_of_Week__c = 'Monday;Tuesday;Wednesday;Thursday';
            callCenterHour.DH_Contact_Method__c = 'AM,PM';
            callCenterHour.DH_Earliest_Time_for_RADAR_Outreach__c=stringToTime('09:00:12');
            callCenterHour.DH_Latest_Time_for_RADAR_Outreach__c=stringToTime('09:00:12');
            callCenterHour.RecordTypeId=cchId;
           
            recordsUpdate.add(callCenterHour);            
            update recordsUpdate;
            Integer chunkSize =20;
            DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(4,recordsUpdate);
            batchInstanceNext.batchSize = chunkSize;
            Database.executeBatch(batchInstanceNext,chunkSize);
            
            Test.stopTest();
            List<DH_Call_Center_Hours__c> cch = [SELECT Id FROM DH_Call_Center_Hours__c];
            
            System.assertEquals(32, cch.size(), 'Batch job should be enqueued');
        }
        
    }
    
    
       @isTest
    public static void testPublishDenormalizedListRecordTypes5() {
        User denormalizedUser = [SELECT Id FROM User WHERE email = 'prasanna@example.com' LIMIT 1];
        PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
        		
        List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();

		DH_Call_Center_Data_Sheet__c exclusion = DH_ExclusioModalityCallcenterTestDataFac.createExclusionDenormaliseObject();
		exclusion.Name = 'Unique Exclusion';
		records.add(exclusion);

		DH_Call_Center_Data_Sheet__c modalityPriority = DH_ExclusioModalityCallcenterTestDataFac.createModalityPriorityDenormaliseObject();
		modalityPriority.Name = 'Unique modalityPriority';
		records.add(modalityPriority);

		DH_Call_Center_Data_Sheet__c callCenterMapping = DH_ExclusioModalityCallcenterTestDataFac.createCallCenterMappingDenormaliseObject();
		callCenterMapping.Name = 'Unique callCenterMapping ';
        records.add(callCenterMapping);
        
        DH_Call_Center_Data_Sheet__c callCenterHours = DH_ExclusioModalityCallcenterTestDataFac.createCallCenterHourDenormaliseObject();
        callCenterHours.DH_Earliest_Time_for_RADAR_Outreach__c=stringToTime('09:00:12');
        callCenterHours.DH_Latest_Time_for_RADAR_Outreach__c=stringToTime('09:00:12');
        callCenterHours.Name = 'Unique callCenterHours';
        records.add(callCenterHours);
       
        Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c callCenterHours2 = new DH_Call_Center_Data_Sheet__c();
        callCenterHours2.DH_Specific_Date__c='01/12/2024,01/12/2024';
        callCenterHours2.Name = 'Unique callCenterHours';
    	callCenterHours2.DH_System__c='TESTAZ';       
        callCenterHours2.DH_Site_Code_or_Call_Center_Code__c='TESTAZCALLCTR';
        callCenterHours2.RecordTypeId=cchId;
        records.add(callCenterHours2);
        System.runAs(denormalizedUser) {
            Test.startTest();
            insert records;
            DH_BatchForNormalization.updateIsTestSetup(true);
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(records);
            setController.setSelected(records);
            DH_PublishDenormalizedListRecords publishDenormalizedListRecords = new DH_PublishDenormalizedListRecords(setController);
            publishDenormalizedListRecords.CallUpdateStatus();
            Test.stopTest();
        }
        
    }
    
    
    
       
       @isTest
    public static void testPublishDenormalizedListSendEmails() {
        User denormalizedUser = [SELECT Id FROM User WHERE email = 'prasanna@example.com' LIMIT 1];
        PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
        		
        List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
       
        Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c callCenterHours = new DH_Call_Center_Data_Sheet__c();
        callCenterHours.DH_Specific_Date__c='01/12/2024,02/12/2024,03/12/2024,04/12/2024,05/12/2024,06/12/2024,07/12/2024,08/12/2024,09/12/2024,10/12/2024,11/12/2024,12/12/2024,01/01/2024,01/02/2024,01/03/2024,01/04/2024,01/05/2024,01/06/2024,01/07/2024,01/08/2024,01/09/2024,01/10/2024';
        callCenterHours.Name = 'Unique callCenterHours';
        callCenterHours.DH_Practice_Code__c= 'TESTRIA,TESTBRS,TESTAZDRG';
        callCenterHours.DH_Site_Code__c='TGIC,TKEW,TJAC,TPSL,TLPN';
    	callCenterHours.DH_System__c='TESTAZ';       
        callCenterHours.DH_Contact_Method__c='Boom,AM,PM,JM,KM,PP,SS,DD,FF,FWLS,ML';
        callCenterHours.DH_Site_Code_or_Call_Center_Code__c='TESTAZCALLCTR,TESTADVNMPETCALLCTR,TESTC';
        callCenterHours.RecordTypeId=cchId;
        records.add(callCenterHours);

        System.runAs(denormalizedUser) {
            Test.startTest();
            insert records;
            DH_BatchForNormalization.updateIsTestSetup(true);
            Integer chunkSize =1;
            DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(4,records);
            batchInstanceNext.batchSize = chunkSize;
            Database.executeBatch(batchInstanceNext,chunkSize);
            Test.stopTest();
        }
        List<DH_Call_Center_Hours__c> cch = [SELECT Id FROM DH_Call_Center_Hours__c where DH_CallCenterDataSheet__c = :callCenterHours.Id];
        System.assertEquals(0, cch.size(), 'Batch job should be enqueued');
        
    }
    
    
     @isTest
    public static void testPublishDenormalizedListDuplicateRecords() {
        User denormalizedUser = [SELECT Id FROM User WHERE email = 'prasanna@example.com' LIMIT 1];
        PermissionSet ps = [SELECT Id, name FROM PermissionSet WHERE Name = 'DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id, name FROM PermissionSet WHERE Name LIKE 'HealthCloudFoundation'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
        List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
        DH_Call_Center_Data_Sheet__c exclusion = new DH_Call_Center_Data_Sheet__c();
        Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
        exclusion.DH_System__c ='TESTFL';
        exclusion.Published__c=true;
        exclusion.DH_Site_Code__c ='TJAC,TKEW'; 
        exclusion.Name = 'Unique Exclusion';
        exclusion.OwnerId = denormalizedUser.Id;
        exclusion.DH_Previous_Value__c='{ "DH_System__c" : "TESTFL","Published__c" : true,"Name" : "Unique Exclusion", "RecordTypeId" : "'+exclusionId +'" }';
        exclusion.RecordTypeId  =exclusionId;
        records.add(exclusion);
        System.runAs(denormalizedUser) {            
            Test.startTest();
            insert exclusion;
            Integer chunkSize =1;
            DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(1,records);
            batchInstanceNext.batchSize = chunkSize;
            Database.executeBatch(batchInstanceNext,chunkSize);          
            Test.stopTest();
            List<DH_Exclusions__c> ex = [SELECT Id FROM DH_Exclusions__c  where DH_CallCenterDataSheet__c = :exclusion.Id];
            
            System.assertEquals(0, ex.size(), 'Batch job should be enqueued');
        }
        
        
    }
    
    public static Time stringToTime(String timeString){
    List<String> timeParts = timeString.split(':');
    Integer hours= Integer.valueOf(timeParts[0]);
    Integer minutes= Integer.valueOf(timeParts[1]);
    Integer seconds= Integer.valueOf(timeParts[2]);
    return Time.newInstance(hours, minutes, seconds, 0);
}
}