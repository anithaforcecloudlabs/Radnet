/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DeleteDenormalizedListRecordsTest
* Version - 0.1
* Created Date - 
* Function - Batch to test delete normalized records.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Prasanna Anjakar                               Intial version.
* *****************************************************************************************************************************
*/
@isTest
public class DH_DeleteDenormalizedListRecordsTest {
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
        
        DH_Call_Center_Data_Sheet__c exclusion = DH_ExclusioModalityCallcenterTestDataFac.createExclusionDenormaliseObject();
        exclusion.Name = 'Unique Exclusion';
        exclusion.OwnerId = denormalizedUser.Id;
        exclusion.Published__c=true;
        records.add(exclusion);
        
        DH_Call_Center_Data_Sheet__c modalityPriority = DH_ExclusioModalityCallcenterTestDataFac.createModalityPriorityDenormaliseObject();
        modalityPriority.Name = 'Unique modalityPriority';
        modalityPriority.OwnerId = denormalizedUser.Id;
        modalityPriority.Published__c=true;
        records.add(modalityPriority);
        
        DH_Call_Center_Data_Sheet__c callCenterMapping = DH_ExclusioModalityCallcenterTestDataFac.createCallCenterMappingDenormaliseObject();
        callCenterMapping.Name = 'Unique callCenterMapping ';
        callCenterMapping.DH_Fake_call_center_site_code__c = 'TESTC';
        callCenterMapping.DH_Site_Code_or_Call_Center_Code__c = 'TESTC';
        callCenterMapping.OwnerId = denormalizedUser.Id;
        callCenterMapping.Published__c=true;
        records.add(callCenterMapping);
        
        DH_Call_Center_Data_Sheet__c callCenterHours = DH_ExclusioModalityCallcenterTestDataFac.createCallCenterHourDenormaliseObject();
        callCenterHours.Name = 'Unique callCenterHours';
        callCenterHours.DH_Site_Code_or_Call_Center_Code__c = 'TESTAZCALLCTR';
        callCenterHours.OwnerId = denormalizedUser.Id;
        callCenterHours.Published__c=true;
        records.add(callCenterHours);
        
        
        DH_Call_Center_Data_Sheet__c callCenterHours1 = new DH_Call_Center_Data_Sheet__c();
        Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
        callCenterHours1.Name = 'CallCenterHours test 10000';
        callCenterHours1.DH_Site_Code_or_Call_Center_Code__c = 'TESTAZCALLCTR';
        callCenterHours1.DH_System__c='TESTAZ';
        callCenterHours1.DH_Day_of_Week__c='Monday';
        callCenterHours1.Published__c=true;
        callCenterHours1.OwnerId = denormalizedUser.Id;
        callCenterHours1.DH_Previous_Value__c='{ "DH_System__c" : "TESTAZ","Published__c" : true,"Name":"Unique callCenterHours", "DH_Site_Code_or_Call_Center_Code__c" : "TESTAZCALLCTR","DH_Day_of_Week__c" : "Monday", "RecordTypeId" : "'+cchId +'" }';
        callCenterHours1.RecordTypeId=cchId;
        records.add(callCenterHours1);       

        insert records;
        
        DH_Exclusions__c ex= new  DH_Exclusions__c();
        ex.DH_CallCenterDataSheet__c = exclusion.Id;
        insert ex;
        DH_Modality_Priority__c mp = new DH_Modality_Priority__c();
        mp.DH_CallCenterDataSheet__c = modalityPriority.Id;
        insert mp;
        DH_Call_Center_Mapping__C ccm = new DH_Call_Center_Mapping__C();
        ccm.DH_CallCenterDataSheet__c= callCenterMapping.Id;
        insert ccm;
        DH_Call_Center_Hours__c cch = new DH_Call_Center_Hours__c();
        cch.DH_CallCenterDataSheet__c = callCenterHours.Id;
        insert cch;
        
          
       /* List<DH_Call_Center_Hours__c>  cchlist =  new List<DH_Call_Center_Hours__c>();
        for(Integer i=0;i<5000;i++){
            DH_Call_Center_Hours__c cch0 = new DH_Call_Center_Hours__c();
            cch0.DH_CallCenterDataSheet__c=callCenterHours1.Id;
            cch0.DH_UniqueKey__c='TESTAZ,,,,,,,,,,end,#-#,,'+i;
            cchlist.add(cch0);
        }
        insert cchlist;
        System.runAs(){
            List<DH_Call_Center_Hours__c>  cchlist1 =  new List<DH_Call_Center_Hours__c>();
        for(Integer i=5000;i<10000;i++){
            DH_Call_Center_Hours__c cch0 = new DH_Call_Center_Hours__c();
            cch0.DH_CallCenterDataSheet__c=callCenterHours1.Id;
            cch0.DH_UniqueKey__c='TESTAZ,,,,,,,,,,end,#-#,,'+i;
            cchlist1.add(cch0);
        }
        insert cchlist1;*/
        DH_Call_Center_Hours__c cch2 = new DH_Call_Center_Hours__c();
        cch2.DH_CallCenterDataSheet__c=callCenterHours1.Id;
        cch2.DH_UniqueKey__c='TESTAZ,,,,,,,,,,end,#-#,,99101900101';
        insert cch2;
       
    }
    
    @isTest
    public static void testDeleteDenormalizedListRecord() {
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
            List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>(); 
            DH_Call_Center_Data_Sheet__c exclusion = [SELECT Id, Name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique Exclusion' LIMIT 1];
            records.add(exclusion);           
            
            ApexPages.StandardSetController controller1 = new ApexPages.StandardSetController(records);
            controller1.setSelected(records);
            
            DH_DeleteDenormalizedListRecords deleteDenormalizedListRecords1 = new DH_DeleteDenormalizedListRecords(controller1);
            deleteDenormalizedListRecords1.onDelete();
            Test.stopTest();
            List<DH_Call_Center_Data_Sheet__c> ex = [SELECT Id FROM DH_Call_Center_Data_Sheet__c];
            System.assertEquals(ex.size(), 4, 'Record not deleted properly');
            
        }
        
    }
    
    @isTest
    public static void testDeleteDenormalizedListRecord2() {
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
            
            List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
            
            DH_Call_Center_Data_Sheet__c callCenterHours = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique callCenterHours' LIMIT 1];
            records.add(callCenterHours);
            
            ApexPages.StandardSetController controller1 = new ApexPages.StandardSetController(records);
            controller1.setSelected(records);
            
            DH_DeleteDenormalizedListRecords deleteDenormalizedListRecords1 = new DH_DeleteDenormalizedListRecords(controller1);
            deleteDenormalizedListRecords1.onDelete();
            Test.stopTest();
            List<DH_Call_Center_Data_Sheet__c> ex = [SELECT Id FROM DH_Call_Center_Data_Sheet__c];
            System.assertEquals(ex.size(), 4, 'Record not deleted properly');
            
        }
        
    }
    
    @isTest
    public static void testDeleteDenormalizedListRecord3() {
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
            List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
            DH_Call_Center_Data_Sheet__c callCenterMapping = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique callCenterMapping' LIMIT 1];
            records.add(callCenterMapping);
            
            ApexPages.StandardSetController controller1 = new ApexPages.StandardSetController(records);
            controller1.setSelected(records);
            DH_DeleteDenormalizedListRecords deleteDenormalizedListRecords1 = new DH_DeleteDenormalizedListRecords(controller1);
            deleteDenormalizedListRecords1.onDelete();
            Test.stopTest();
            List<DH_Call_Center_Data_Sheet__c> ex = [SELECT Id FROM DH_Call_Center_Data_Sheet__c];
            System.assertEquals(ex.size(), 4, 'Record not deleted properly');
            
        }
        
    }
    
    @isTest
    public static void testDeleteDenormalizedListRecord4() {
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
            
            List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
            
            DH_Call_Center_Data_Sheet__c modalityPriority = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique modalityPriority' LIMIT 1];
            records.add(modalityPriority);
            
            ApexPages.StandardSetController controller1 = new ApexPages.StandardSetController(records);
            controller1.setSelected(records);
            
            DH_DeleteDenormalizedListRecords deleteDenormalizedListRecords1 = new DH_DeleteDenormalizedListRecords(controller1);
            deleteDenormalizedListRecords1.onDelete();
            Test.stopTest();
            List<DH_Call_Center_Data_Sheet__c> ex = [SELECT Id FROM DH_Call_Center_Data_Sheet__c];
            System.assertEquals(ex.size(), 4, 'Record not deleted properly');
            
        }
        
    }
    
    
    @isTest
    public static void testDeleteDenormalizedListRecord5() {
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
            
            List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
            
            DH_Call_Center_Data_Sheet__c modalityPriority = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique modalityPriority' LIMIT 1];
            records.add(modalityPriority);
            
            ApexPages.StandardController controller1 = new ApexPages.StandardController(modalityPriority);
            
            DH_DeleteDenormalizedListRecords deleteDenormalizedListRecords1 = new DH_DeleteDenormalizedListRecords(controller1);
            deleteDenormalizedListRecords1.publishSingleRecord();
            Test.stopTest();
            List<DH_Call_Center_Data_Sheet__c> ex = [SELECT Id FROM DH_Call_Center_Data_Sheet__c];
            System.assertEquals(ex.size(), 5, 'Standard cotroller not set properly');
            
        }
        
    }
    
    @isTest
    public static void callgetRecordsTest() {
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
            
            List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
            
            DH_Call_Center_Data_Sheet__c modalityPriority = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique modalityPriority' LIMIT 1];
            records.add(modalityPriority);
            
            ApexPages.StandardSetController controller1 = new ApexPages.StandardSetController(records);
            controller1.setSelected(records);
            DH_DeleteDenormalizedListRecords deleteDenormalizedListRecords1 = new DH_DeleteDenormalizedListRecords(controller1);
            
            List<DH_Call_Center_Data_Sheet__c> SelectedCallCenterHours=deleteDenormalizedListRecords1.getSelectedCallCenterHours();
            List<DH_Call_Center_Data_Sheet__c> SelectedCallCenterMapping=deleteDenormalizedListRecords1.getSelectedCallCenterMapping();
            List<DH_Call_Center_Data_Sheet__c> SelectedModalityPriotity=deleteDenormalizedListRecords1.getSelectedModalityPriotity();
            List<DH_Call_Center_Data_Sheet__c> SelectedExclusions=deleteDenormalizedListRecords1.getSelectedExclusions();
            Test.stopTest();
            system.assertEquals(SelectedModalityPriotity.size(), 1, 'The records are not fetched properly');
        }
    }
    
    @isTest
    public static void failedRecordsTest(){
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
            //<DH_Call_Center_Data_Sheet__c,List<SObject>
            DH_Call_Center_Data_Sheet__c callCenterHours = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'CallCenterHours test 10000' LIMIT 1];
            DH_Call_Center_Hours__c cch =[Select Id FROM DH_Call_Center_Hours__c WHERE DH_CallCenterDataSheet__c=:callCenterHours.Id];
            Map<DH_Call_Center_Data_Sheet__c,List<SObject>>failedMap = new Map<DH_Call_Center_Data_Sheet__c,List<SObject>>();
            failedMap.put(callCenterHours,new List<SObject>{cch}); 
            DH_Call_Center_Data_Sheet__c modalityPriority = [SELECT Id, name, DH_System__c, DH_Site_Code__c, DH_Carrier_Code__c, DH_Ref_Dr__c, DH_New_or_Re_Schedule__c, DH_Notes_1__c, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Name = :'Unique modalityPriority' LIMIT 1];
            List<DH_Call_Center_Data_Sheet__c> records = new List<DH_Call_Center_Data_Sheet__c>();
            records.add(modalityPriority);
            DH_BatchForNormalizedRecordDeletion batchInstance = new DH_BatchForNormalizedRecordDeletion(records);
            batchInstance.updatefailedCcdsParentVsrecordsToBeDeleted(failedMap);
            Database.executeBatch(batchInstance,1);
            Test.stopTest();
        } 
        List<DH_Call_Center_Data_Sheet__c> ex = [SELECT Id FROM DH_Call_Center_Data_Sheet__c];
        System.assertEquals(ex.size(), 4, 'Error didnt occured properly');
        
    }
}