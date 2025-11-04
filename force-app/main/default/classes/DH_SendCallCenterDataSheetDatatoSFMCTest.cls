@isTest(seeAllData=false)
private class DH_SendCallCenterDataSheetDatatoSFMCTest {

    @testSetup
     Public static void  createData(){
        List<Account> regionAccountsList = DH_ExclusioModalityCallcenterTestDataFac.createRegionAccounts();
       insert regionAccountsList;
       for(Account acc : regionAccountsList){
           System.debug('regionAccountsList : '+ acc.Id +' '+ acc.Name+' ' +acc.AccountRegion__c +' '+acc.Region__c +' '+acc.DH_RIS_Unique_code__c);
       }
	   List<Account> allOtherAccountsList = new List<Account>();
       for(Account acc : regionAccountsList){
           List<Account> regionBasedOtherAccountsList = DH_ExclusioModalityCallcenterTestDataFac.createOtherAccounts(acc.Id,acc.Region__c);
           allOtherAccountsList.addAll(regionBasedOtherAccountsList);
       }
       insert allOtherAccountsList;
       
       List<CareSpecialty> allRegionCareSpecialityList = new List<CareSpecialty>();
       for(Account acc:  regionAccountsList){
           List<CareSpecialty> regionBasedCareSpecialityList = DH_ExclusioModalityCallcenterTestDataFac.createCareSpeciality(acc.Id,acc.Region__c);
           allRegionCareSpecialityList.addAll(regionBasedCareSpecialityList);
       }
       insert allRegionCareSpecialityList;
     
       List<HealthcareProcedure> allRegionHealthCareProcedure= new List<HealthcareProcedure>();
       for(Account acc:  regionAccountsList){
           List<HealthCareProcedure> regionBasedHealthCareProcedure = DH_ExclusioModalityCallcenterTestDataFac.createHealthCareProcedure(acc.Id,acc.Region__c);
           allRegionHealthCareProcedure.addAll(regionBasedHealthCareProcedure);
       }
       insert allRegionHealthCareProcedure;
       
       for(HealthcareProcedure hcp : allRegionHealthCareProcedure){
           System.debug('hcp : '+ hcp.Name +' '+ hcp.Code+' ' +hcp.Region__c +' '+hcp.DH_Region_Instance__c +' '+hcp.DH_RIS_Healthcare_Procedure__c);
       }
       List<DH_Call_Center__c> callCenterList = DH_ExclusioModalityCallcenterTestDataFac.createCallCenter();
       insert callCenterList;
       
       User user1 = DH_ExclusioModalityCallcenterTestDataFac.createUser();
       user1.Email = 'unique' + System.currentTimeMillis() + '@example.com';
       insert user1;
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
        callCenterHours.Name = 'Unique callCenterHours';
        records.add(callCenterHours);
       
       Insert records;
       
         
        List<DH_Exclusions__c> Exclusionsrecords = new List<DH_Exclusions__c>();
        List<DH_Call_Center_Data_Sheet__c> denormaliserecExc = [SELECT id from DH_Call_Center_Data_Sheet__c where Name='Unique Exclusion'];
        for(integer i = 0; i<100; i++){       
            Exclusionsrecords.add(new DH_Exclusions__c(DH_Notes__c=String.valueOf('Note'+i),DH_CallCenterDataSheet__c=denormaliserecExc[0].id));
        }
        insert Exclusionsrecords;
         
        List<DH_Call_Center_Hours__c> callCenterHoursrecords = new List<DH_Call_Center_Hours__c>();
        List<DH_Call_Center_Data_Sheet__c> denormaliserecCch = [SELECT id from DH_Call_Center_Data_Sheet__c where Name='Unique callCenterHours'];
        for(integer i = 0; i<100; i++){       
            callCenterHoursrecords.add( new DH_Call_Center_Hours__c(DH_Notes1__c=String.valueOf('Note'+i),DH_CallCenterDataSheet__c=denormaliserecCch[0].id));
        }
        insert callCenterHoursrecords;
         
        List<DH_Call_Center_Mapping__c> callCenterMappingrecords = new List<DH_Call_Center_Mapping__c>();
        List<DH_Call_Center_Data_Sheet__c> denormaliserecCcm = [SELECT id from DH_Call_Center_Data_Sheet__c where Name='Unique callCenterMapping'];
        for(integer i = 0; i<100; i++){       
            callCenterMappingrecords.add(new DH_Call_Center_Mapping__c(DH_Notes__c=String.valueOf('Note'+i),DH_CallCenterDataSheet__c=denormaliserecCcm[0].id));
        }
        insert callCenterMappingrecords;
         
        List<DH_Modality_Priority__c> modalityPriorityrecords = new List<DH_Modality_Priority__c>();
        List<DH_Call_Center_Data_Sheet__c> denormaliserecMp = [SELECT id from DH_Call_Center_Data_Sheet__c where Name='Unique modalityPriority'];
        for(integer i = 0; i<100; i++){
            modalityPriorityrecords.add(new DH_Modality_Priority__c(DH_Notes__c=String.valueOf('Note'+i),DH_CallCenterDataSheet__c=denormaliserecMp[0].id));
        }
        insert modalityPriorityrecords;
       
       DH_APIAuthDetails__c DH_SFMCAuthTokenBody = new DH_APIAuthDetails__c();
       DH_SFMCAuthTokenBody.Name='DH_SFMCAuthTokenBody';
       DH_SFMCAuthTokenBody.DH_Account_ID__c='tokenbody';
       DH_SFMCAuthTokenBody.DH_Client_Secret__c='client secret';
       DH_SFMCAuthTokenBody.DH_Client_ID__c='client Id';
       DH_SFMCAuthTokenBody.DH_Grant_Type__c='Grant Type';
       insert DH_SFMCAuthTokenBody;
     }
    
     @isTest 
     public static void testSendingExclusions() {
        List<DH_Exclusions__c> exclusionsrecords=[select Name, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_Site_Code_Formula__c,
    DH_Carrier_Code_Formula__c, DH_Referring_ID_Formula__c, DH_Procedure_Code_Formula__c,DH_Procedure_Group_Code_Formula__c, DH_Practice_Code_Formula__c, DH_FileExclUniqueKey__c,
    DH_Referring_Group_Code_Formula__c,DH_Procedure_Code__c,  DH_Carrier_Code__c, DH_Referring_Group_Code__c, DH_referring_id__c, DH_Order_Nrf__c,
    DH_CallCenterDataSheet__c,CreatedById,DH_iCode__c,LastModifiedById,DH_New_or_Re_Schedule__c,DH_Notes__c,
    OwnerId,DH_Procedure_Group_Code__c,CreatedDate,
    RecordTypeId,DH_System_Formula__c,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,
    LastViewedDate,LastReferencedDate, DH_CallCenterDataSheet__r.Name from DH_Exclusions__c limit 100];
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(0,exclusionsrecords,exclusionsrecords,null,'DH_Exclusions__c',null));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :exclusionsrecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.Published__c,'Check if the records are published');
        System.assertEquals(true,parentrec.DH_Last_Sync_Timestamp__c!=null,'check if the time stamp is updated');
        }
     }
    
     @isTest 
     public static void testSendingExclusionsfailed() {
        List<DH_Exclusions__c> exclusionsrecords=[select Id, Name, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_Site_Code_Formula__c,
    DH_Carrier_Code_Formula__c, DH_Referring_ID_Formula__c, DH_Procedure_Code_Formula__c,DH_Procedure_Group_Code_Formula__c, DH_Practice_Code_Formula__c, DH_FileExclUniqueKey__c,
    DH_Referring_Group_Code_Formula__c,DH_Procedure_Code__c,  DH_Carrier_Code__c, DH_Referring_Group_Code__c, DH_referring_id__c, DH_Order_Nrf__c,
    DH_CallCenterDataSheet__c,CreatedById,DH_iCode__c,LastModifiedById,DH_New_or_Re_Schedule__c,DH_Notes__c,
    OwnerId,DH_Procedure_Group_Code__c,CreatedDate,
    RecordTypeId,DH_System_Formula__c,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,
    LastViewedDate,LastReferencedDate, DH_CallCenterDataSheet__r.Name from DH_Exclusions__c limit 100];
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(400,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(200,exclusionsrecords,exclusionsrecords,exclusionsrecords,'DH_Exclusions__c','Error'));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :exclusionsrecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.DH_Error_Log__c.length()>0,'check if the error message is getting updated');
        System.assertEquals(false,parentrec.Published__c,'Check if the records are published');
        }
     }
     @isTest 
     public static void testSendingBulkExclusions() {
        List<DH_Exclusions__c> exclusionsrecords=[select Id, Name, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_Site_Code_Formula__c,
    DH_Carrier_Code_Formula__c, DH_Referring_ID_Formula__c, DH_Procedure_Code_Formula__c,DH_Procedure_Group_Code_Formula__c, DH_Practice_Code_Formula__c, DH_FileExclUniqueKey__c,
    DH_Referring_Group_Code_Formula__c,DH_Procedure_Code__c,  DH_Carrier_Code__c, DH_Referring_Group_Code__c, DH_referring_id__c, DH_Order_Nrf__c,
    DH_CallCenterDataSheet__c,CreatedById,DH_iCode__c,LastModifiedById,DH_New_or_Re_Schedule__c,DH_Notes__c,
    OwnerId,DH_Procedure_Group_Code__c,CreatedDate,
    RecordTypeId,DH_System_Formula__c,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,
    LastViewedDate,LastReferencedDate, DH_CallCenterDataSheet__r.Name from DH_Exclusions__c limit 100];
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(150,exclusionsrecords,exclusionsrecords,null,'DH_Exclusions__c',null));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :exclusionsrecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.Published__c,'Check if the records are published');
        }
     }
     @isTest 
     public static void testSendingCallCenterHours() {
        List<DH_Call_Center_Hours__c> callCenterHoursRecords=[select Id, Name, DH_System__c,DH_Practice_Code__c, DH_Call_Center_Code_Lookup__c, DH_Site_Code__c, DH_Day_of_Week__c, 
    DH_FileCCHoursUniqueKey__c, DH_Call_Center_Code__c, DH_timezone__c, DH_CSTStartTime__c, DH_CSTEndTime__c, DH_System_Formula__c, DH_SIte_Code_Formula__c, 
    DH_Practice_Code_Formula__c, DH_Specific_Date__c, DH_Notes1__c, DH_Contact_Method__c, DH_iCode__c,DH_CallCenterDataSheet__c, 
    CreatedById ,DH_Earliest_Time_for_RADAR_Outreach__c  ,DH_isHoliday__c ,RecordTypeId,CreatedDate,
LastModifiedById, DH_Latest_Time_for_RADAR_Outreach__c , DH_Notes2__c,DH_Outreach_Timezone__c,OwnerId,IsDeleted,LastModifiedDate,
SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate,DH_CallCenterDataSheet__r.Name from DH_Call_Center_Hours__c limit 50];
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(0,callCenterHoursRecords,callCenterHoursRecords,null,'DH_Call_Center_Hours__c',null));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :callCenterHoursRecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.Published__c,'Check if the records are published');
        System.assertEquals(true,parentrec.DH_Last_Sync_Timestamp__c!=null,'check if the time stamp is updated');
        }
     }
     @isTest 
     public static void testSendingCallCenterHoursfailed() {
        List<DH_Call_Center_Hours__c> callCenterHoursRecords=[select Id, Name, DH_System__c,DH_Practice_Code__c, DH_Call_Center_Code_Lookup__c, DH_Site_Code__c, DH_Day_of_Week__c, 
    DH_FileCCHoursUniqueKey__c, DH_Call_Center_Code__c, DH_timezone__c, DH_CSTStartTime__c, DH_CSTEndTime__c, DH_System_Formula__c, DH_SIte_Code_Formula__c, 
    DH_Practice_Code_Formula__c, DH_Specific_Date__c, DH_Notes1__c, DH_Contact_Method__c, DH_iCode__c,DH_CallCenterDataSheet__c, 
    CreatedById ,DH_Earliest_Time_for_RADAR_Outreach__c  ,DH_isHoliday__c ,RecordTypeId,CreatedDate,
LastModifiedById, DH_Latest_Time_for_RADAR_Outreach__c , DH_Notes2__c,DH_Outreach_Timezone__c,OwnerId,IsDeleted,LastModifiedDate,
SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate,DH_CallCenterDataSheet__r.Name from DH_Call_Center_Hours__c limit 100];
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(400,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(400,callCenterHoursRecords,callCenterHoursRecords,callCenterHoursRecords,'DH_Call_Center_Hours__c','Error'));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :callCenterHoursRecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.DH_Error_Log__c.length()>0,'check if the error message is getting updated');
        System.assertEquals(false,parentrec.Published__c,'Check if the records are published');
        }
     }
     @isTest 
     public static void testSendingBulkCallCenterHours() {
        List<DH_Call_Center_Hours__c> callCenterHoursRecords=[select Id, Name, DH_System__c,DH_Practice_Code__c, DH_Call_Center_Code_Lookup__c, DH_Site_Code__c, DH_Day_of_Week__c, 
    DH_FileCCHoursUniqueKey__c, DH_Call_Center_Code__c, DH_timezone__c, DH_CSTStartTime__c, DH_CSTEndTime__c, DH_System_Formula__c, DH_SIte_Code_Formula__c, 
    DH_Practice_Code_Formula__c, DH_Specific_Date__c, DH_Notes1__c, DH_Contact_Method__c, DH_iCode__c,DH_CallCenterDataSheet__c, 
    CreatedById ,DH_Earliest_Time_for_RADAR_Outreach__c  ,DH_isHoliday__c ,RecordTypeId,CreatedDate,
LastModifiedById, DH_Latest_Time_for_RADAR_Outreach__c , DH_Notes2__c,DH_Outreach_Timezone__c,OwnerId,IsDeleted,LastModifiedDate,
SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate,DH_CallCenterDataSheet__r.Name from DH_Call_Center_Hours__c limit 100];
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(150,callCenterHoursRecords,callCenterHoursRecords,null,'DH_Call_Center_Hours__c',null));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :callCenterHoursRecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.Published__c,'Check if the records are published');
        }
     }

     @isTest 
     public static void testSendingCallCenterMapping() {
        List<DH_Call_Center_Mapping__c> callCenterMappingrecords=[select Id, Name, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_ZIP__c, 
    DH_Modality_Code__c, DH_Procedure_Code__c, DH_Fake_call_center_site_code_Lookup__c,	DH_Referring_Group_Code__c,DH_Notes__c,
    DH_Fake_call_center_site_code__c,DH_URL1_to_give_RADAR__c,DH_URL2_to_give_RADAR__c,DH_URL3_to_give_RADAR__c,
    DH_URL4_to_give_RADAR__c,DH_URL5_to_give_RADAR__c,DH_Phone_Number_1__c,DH_Phone_Number_2__c,DH_Phone_Number_3__c,
    DH_Phone_Number_4__c,DH_Phone_Number_5__c,DH_System_Formula__c,DH_Practice_Code_Formula__c,DH_Site_Code_Formula__c,
    DH_Referring_Group_Code_Formula__c,DH_Modality_Code_Formula__c,DH_Procedure_Code_Formula__c,
    OwnerId,IsDeleted,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastViewedDate,
    LastReferencedDate,DH_Site_Code_or_Call_Center_Code__c,RecordTypeId,
    DH_CallCenterDataSheet__c, DH_CallCenterDataSheet__r.Name from DH_Call_Center_Mapping__c limit 100];
         User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(0,callCenterMappingrecords,callCenterMappingrecords,null,'DH_Call_Center_Mapping__c',null));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :callCenterMappingrecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.Published__c,'Check if the records are published');
        System.assertEquals(true,parentrec.DH_Last_Sync_Timestamp__c!=null,'check if the time stamp is updated');
        }
     }
     @isTest 
     public static void testSendingCallCenterMappingfailed() {
        List<DH_Call_Center_Mapping__c> callCenterMappingrecords=[select Id, Name, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_ZIP__c, 
    DH_Modality_Code__c, DH_Procedure_Code__c, DH_Fake_call_center_site_code_Lookup__c,	DH_Referring_Group_Code__c,DH_Notes__c,
    DH_Fake_call_center_site_code__c,DH_URL1_to_give_RADAR__c,DH_URL2_to_give_RADAR__c,DH_URL3_to_give_RADAR__c,
    DH_URL4_to_give_RADAR__c,DH_URL5_to_give_RADAR__c,DH_Phone_Number_1__c,DH_Phone_Number_2__c,DH_Phone_Number_3__c,
    DH_Phone_Number_4__c,DH_Phone_Number_5__c,DH_System_Formula__c,DH_Practice_Code_Formula__c,DH_Site_Code_Formula__c,
    DH_Referring_Group_Code_Formula__c,DH_Modality_Code_Formula__c,DH_Procedure_Code_Formula__c,
    OwnerId,IsDeleted,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastViewedDate,
    LastReferencedDate,DH_Site_Code_or_Call_Center_Code__c,RecordTypeId,
    DH_CallCenterDataSheet__c, DH_CallCenterDataSheet__r.Name from DH_Call_Center_Mapping__c limit 100];
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(400,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(400,callCenterMappingrecords,callCenterMappingrecords,callCenterMappingrecords,'DH_Call_Center_Mapping__c','Error'));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :callCenterMappingrecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.DH_Error_Log__c.length()>0,'check if the error message is getting updated');
        System.assertEquals(false,parentrec.Published__c,'Check if the records are published');
        }
     }
     @isTest  
     public static void testSendingBulkCallCenterMapping() {
        List<DH_Call_Center_Mapping__c> callCenterMappingrecords=[select Id, Name, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_ZIP__c, 
    DH_Modality_Code__c, DH_Procedure_Code__c, DH_Fake_call_center_site_code_Lookup__c,	DH_Referring_Group_Code__c,DH_Notes__c,
    DH_Fake_call_center_site_code__c,DH_URL1_to_give_RADAR__c,DH_URL2_to_give_RADAR__c,DH_URL3_to_give_RADAR__c,
    DH_URL4_to_give_RADAR__c,DH_URL5_to_give_RADAR__c,DH_Phone_Number_1__c,DH_Phone_Number_2__c,DH_Phone_Number_3__c,
    DH_Phone_Number_4__c,DH_Phone_Number_5__c,DH_System_Formula__c,DH_Practice_Code_Formula__c,DH_Site_Code_Formula__c,
    DH_Referring_Group_Code_Formula__c,DH_Modality_Code_Formula__c,DH_Procedure_Code_Formula__c,
    OwnerId,IsDeleted,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastViewedDate,
    LastReferencedDate,DH_Site_Code_or_Call_Center_Code__c,RecordTypeId,
    DH_CallCenterDataSheet__c, DH_CallCenterDataSheet__r.Name from DH_Call_Center_Mapping__c limit 100];
         User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(1000,callCenterMappingrecords,callCenterMappingrecords,null,'DH_Call_Center_Mapping__c',null));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :callCenterMappingrecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.Published__c,'Check if the records are published');
        }
     }
     @isTest 
     public static void testSendingModalityPriority() {
        List<DH_Modality_Priority__c> modalityPriorityecords=[select Id, Name, DH_System__c, DH_procedure_group_code__c,DH_CallCenterDataSheet__c, DH_Relative_Priority__c, 
    DH_Procedure_Group_Code_Formula__c, DH_System_Formula__c, DH_FilePriorityUniqueKey__c, DH_CallCenterDataSheet__r.Name,
    CreatedById,DH_Description__c,LastModifiedById,OwnerId,DH_Portal_Procedure_Group_Modality_Code__c,CreatedDate,DH_Notes__c,
RecordTypeId,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDatE from 
    DH_Modality_Priority__c limit 100];
         User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(0,modalityPriorityecords,modalityPriorityecords,null,'DH_Modality_Priority__c',null));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :modalityPriorityecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.Published__c,'Check if the records are published');
        System.assertEquals(true,parentrec.DH_Last_Sync_Timestamp__c!=null,'check if the time stamp is updated');
        }
     }
     @isTest 
     public static void testSendingModalityPriorityfailed() {
        List<DH_Modality_Priority__c> modalityPriorityecords=[select Id, Name, DH_System__c, DH_procedure_group_code__c,DH_CallCenterDataSheet__c, DH_Relative_Priority__c, 
    DH_Procedure_Group_Code_Formula__c, DH_System_Formula__c, DH_FilePriorityUniqueKey__c, DH_CallCenterDataSheet__r.Name,
    CreatedById,DH_Description__c,LastModifiedById,OwnerId,DH_Portal_Procedure_Group_Modality_Code__c,CreatedDate,DH_Notes__c,
RecordTypeId,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDatE from 
    DH_Modality_Priority__c limit 100];
         User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(400,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(300,modalityPriorityecords,modalityPriorityecords,modalityPriorityecords,'DH_Modality_Priority__c','Error'));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :modalityPriorityecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.DH_Error_Log__c.length()>0,'check if the error message is getting updated');
        System.assertEquals(false,parentrec.Published__c,'Check if the records are published');
        }
     }
     @isTest 
     public static void testSendingBulkModalityPriority() {
        List<DH_Modality_Priority__c> modalityPriorityecords=[select Id, Name, DH_System__c, DH_procedure_group_code__c,DH_CallCenterDataSheet__c, DH_Relative_Priority__c, 
    DH_Procedure_Group_Code_Formula__c, DH_System_Formula__c, DH_FilePriorityUniqueKey__c, DH_CallCenterDataSheet__r.Name,
    CreatedById,DH_Description__c,LastModifiedById,OwnerId,DH_Portal_Procedure_Group_Modality_Code__c,CreatedDate,DH_Notes__c,
RecordTypeId,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDatE from 
    DH_Modality_Priority__c limit 100]; 
        User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(200,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(400,modalityPriorityecords,modalityPriorityecords,null,'DH_Modality_Priority__c',null));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :modalityPriorityecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(true,parentrec.Published__c,'Check if the records are published');
        }
     }
     
     @isTest 
     public static void testSendingFailedRecords() {
        List<DH_Modality_Priority__c> modalityPriorityecords=[select Id, Name, DH_System__c, DH_procedure_group_code__c,DH_CallCenterDataSheet__c, DH_Relative_Priority__c, 
    DH_Procedure_Group_Code_Formula__c, DH_System_Formula__c, DH_FilePriorityUniqueKey__c, DH_CallCenterDataSheet__r.Name,
    CreatedById,DH_Description__c,LastModifiedById,OwnerId,DH_Portal_Procedure_Group_Modality_Code__c,CreatedDate,DH_Notes__c,
RecordTypeId,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDatE from 
    DH_Modality_Priority__c];
         User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(300,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(400,modalityPriorityecords,modalityPriorityecords,modalityPriorityecords,'DH_Modality_Priority__c','Error'));
        Test.stopTest();
        DH_Call_Center_Data_Sheet__c parentrec =[SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c  from DH_Call_Center_Data_Sheet__c WHERE Id = :modalityPriorityecords[0].DH_CallCenterDataSheet__c];
        System.assertEquals(false,parentrec.Published__c,'Check if the records are published');
        System.assertEquals(true,parentrec.DH_Error_Log__c.length()>0,'Check if the error message is updated ');
        }
     }    
    
    @isTest 
     public static void testFailedError() {
        List<DH_Modality_Priority__c> modalityPriorityecords=[select Id, Name, DH_System__c, DH_procedure_group_code__c,DH_CallCenterDataSheet__c, DH_Relative_Priority__c, 
    DH_Procedure_Group_Code_Formula__c, DH_System_Formula__c, DH_FilePriorityUniqueKey__c, DH_CallCenterDataSheet__r.Name,
    CreatedById,DH_Description__c,LastModifiedById,OwnerId,DH_Portal_Procedure_Group_Modality_Code__c,CreatedDate,DH_Notes__c,
RecordTypeId,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDatE from 
    DH_Modality_Priority__c];
         User denormalizedUser = DH_ExclusioModalityCallcenterTestDataFac.createUser();
        insert denormalizedUser;
        PermissionSet ps = [SELECT Id,name  FROM PermissionSet where Name ='DH_SFMCDenormalizedObjectPermissionSet'];
        PermissionSet ps2 = [SELECT Id,name  FROM PermissionSet where Name like 'HealthCloudFoundation'];
	    PermissionSetAssignment psa= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa2= new PermissionSetAssignment(AssigneeId = denormalizedUser.Id, PermissionSetId = ps2.Id);
        List<PermissionSetAssignment> psaList = new 	List<PermissionSetAssignment>();
        psaList.add(psa);
        psaList.add(psa2);
        insert psaList;
         
        System.runAs(denormalizedUser){
        DH_SendNormalizeDataQueue.doChainJob=false;
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(400,'{"access_token":"token"}'));
        Test.startTest();
        System.enqueueJob(new DH_SendNormalizeDataQueue(300,modalityPriorityecords,modalityPriorityecords,null,'DH_Modality_Priority__c','Error'));
        Test.stopTest();
        }
     }
      
    
    @isTest
    Public Static void OrderOptIntest(){
        Profile integrationProfile = [SELECT Id FROM Profile WHERE Name = 'Salesforce API Only System Integrations'];
        PermissionSet intPermission = [SELECT Id FROM PermissionSet WHERE Name = 'DH_IntegrationPermissionset'];
        PermissionSet hcPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'HealthCloudFoundation'];

        User apiUser = new User(
            Alias = 'userWest', 
            Email = 'apiTestUser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'API Test User', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = integrationProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            IsActive = true, 
            UserPermissionsKnowledgeUser = false,
            UserName = 'apiTestUser@testorg.com'
        );
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
        
        System.runAs(apiUser){
        Account ac = new Account(Name='testing account');
        insert ac;
        ContactPointPhone  ccp = new ContactPointPhone(TelephoneNumber='1010101010',ParentId=ac.id);
        insert ccp;
        System.debug('this is contact point phone'+[SELECT id,(SELECT TelephoneNumber FROM ContactPointPhones) FROM Account WHERE id = :ac.id]);
        Test.setMock(HttpCalloutMock.class, new HttpSFMCmock(400,'{"access_token":"token"}'));
        Test.startTest();
        DH_SendCallCenterDataSheetDatatoSFMC.sendOptInData(new List<Id>{ac.id});
        Test.stopTest();
        }
    }
    
    private class HttpSFMCmock implements HttpCalloutMock {
        String Response;
        Integer ResponseCode;
        HttpSFMCmock(Integer Code, String ResponseBody)
        {
            ResponseCode = Code;
            Response = ResponseBody;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(ResponseCode);
            res.setbody(Response);
            return res;
        }
    }

}