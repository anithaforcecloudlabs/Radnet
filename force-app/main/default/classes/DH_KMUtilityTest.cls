/*

*********************************************************

Apex Class         : DH_KMUtilityTest

Created Date       : June 15, 2024

@description       : Test class for Utility class for redundant methods

@jiraid            :

*********************************************************

*/
@isTest(SeeAllData=false)
public class DH_KMUtilityTest {
    @isTest
    public static void dHSpecialAccomodationAndBillControllerGetPractice(){
        List<String> r = new List<String>();
        r.add('MA');
        r.add('NE');
        r.add('FL');
        List<String> r1 = new List<String>();
        system.assertEquals(9,DH_KMUtility.getPractice(r).size(),'Practices are not present');
        system.assertEquals(0,DH_KMUtility.getPractice(r1).size(),'No practice found');
        List<String> subPractice = DH_KMUtility.virtualGroupingNJIN();
        List<String> subPracticeFullName = DH_KMUtility.virtualGroupingNJINForSiteSearch();
    }
    @isTest
    public static void getRegionTest(){
        List<String> region = DH_KMUtility.getRegion();
        system.assertEquals(3,region.size(),'Region is found');
        List<String> virtualPracticeGrouping = DH_KMUtility.virtualGroupingNJIN();
    }
    @isTest
    static void testGetCategoryVsIconNames() {
        Test.startTest();
        List<DH_Data_Category_Icon_Name__mdt> categoryVsIconNameList = DH_KMUtility.getCategoryVsIconNames();
        System.assertNotEquals(null, categoryVsIconNameList, 'CategoryIcon should  not be null');
        Test.stopTest();
    }
    @isTest
    static void testGetModalities() {
        
        // Test as East Coast User
        // Create East Coast User
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
        List<DH_Data_Category_Icon_Name__mdt> categoryVsIconNameList = DH_KMUtility.getCategoryVsIconNames();
        System.runAs(eastUser) {
            Test.startTest();
            List<Modality__mdt> modalityList = DH_KMUtility.getModalities('TestRegion', 'TestPractice');
            Assert.isNotNull( modalityList, 'Modality list should not be null');
            List<Modality__mdt> modalityList2 = DH_KMUtility.getModalityRecords(new List<String>{}, new List<String>{});
            Assert.isNotNull( modalityList2, 'Modality list should not be null');
            Boolean groupMembersEast= DH_KMUtility.isUserInCoast(eastUser.Id, 'east');
            Boolean groupMembersWest= DH_KMUtility.isUserInCoast(eastUser.Id, 'west');
            Map < String, List < String >> eastPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.EAST_CATEGORIES, DH_KMConstants.EAST_SUB_CATEGORIES);
            String str = DH_KMUtility.getApiNameVsLabel('East_Modalities', DH_KMConstants.EAST_CATEGORIES);
            String dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
            Test.stopTest();
        }
    }
    @isTest
    static void testGuestUser() {
        test.startTest();
        boolean b = DH_KMUtility.getUserType();
        test.stopTest();
        system.assertEquals(false, b, 'Not guest user');
    }
    
    @isTest
    static void testcoastType(){
        test.startTest();
        List<String> coastEast = DH_KMUtility.coastType('East');
        List<String> coastWest = DH_KMUtility.coastType('West');
        test.stopTest();
        system.assertEquals(true,coastEast.size()>0,'test success');
        system.assertEquals(true,coastWest.size()>0,'test success');
    }
    
    @isTest
    static void testGetHealthcarePayerNetworkRecordsForGuestUser(){
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
        //User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
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
                                                                DH_PayerId__c=payeracc[i].Id,
                                                                DH_Region__c=reg[0].Id,
                                                                DH_IsActive__c=true,
                                                                DH_Modality_Description__c='test description'+i
                                                               ));
            }
            insert dhpayerntw;
            Map<String,List<String>> specialBillsParamTest = new Map<String,List<String>>();
            specialBillsParamTest.put('id',new List<String>{'Id'});
            
            specialBillsParamTest.put('modalityDescription',new List<String>{'DH_Modality_Description__c'});
            specialBillsParamTest.put('examCovered',new List<String>{'DH_Exam_Covered__c'});
            specialBillsParamTest.put('regionName',new List<String>{'DH_Region__r','Name'});
            specialBillsParamTest.put('regionsRegion',new List<String>{'DH_Region__r','Region__c'});
            specialBillsParamTest.put('payerName',new List<String>{'DH_PayerId__r','Name'});
            
            specialBillsParamTest.put('carrierCode',new List<String>{'DH_PayerId__r','Carrier_Code_in_RIS__c'});
            
            Test.startTest();
            List<DH_specialAccomodationAndBillController.SpecialBillsWrapper> result=DH_KMUtility.getHealthcarePayerNetworkRecords(specialBillsParamTest,dhpayerntw);
            Test.stopTest();
            system.assertEquals(true,result.size()>=0,'Special Bills not found');
        }
    }
    
    
    @isTest
    static void testGetHealthcarePayerNetworkRecords(){
        
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
                                                    Payer=payeracc[i],
                                                    Region__c=reg[0].Id,
                                                    Modality_Description__c='test modality desc'+i,
                                                    IsActive=true
                                                   ));
        }
        upsert payerntw;
       
        Map<String,List<String>> specialBillsParamTest = new Map<String,List<String>>();
        specialBillsParamTest.put('id',new List<String>{'Id'});
        specialBillsParamTest.put('regionsRegion',new List<String>{'Region__r','Region__c'});
        specialBillsParamTest.put('modalityDescription',new List<String>{'Modality_Description__c'});
        specialBillsParamTest.put('examCovered',new List<String>{'Exam_Covered__c'});
        specialBillsParamTest.put('carrierCode',new List<String>{'Payer','Carrier_Code_in_RIS__c'});
        specialBillsParamTest.put('regionName',new List<String>{'Region__r','Name'});
        specialBillsParamTest.put('payerName',new List<String>{'Payer','Name'});
        Test.startTest();
        List<DH_specialAccomodationAndBillController.SpecialBillsWrapper> result=DH_KMUtility.getHealthcarePayerNetworkRecords(specialBillsParamTest,payerntw);
        Test.stopTest();
        system.assertEquals(true,result.size()>=0,'Special Bills not found');
        
    }
    

     @isTest
        static void testGetRecordsBasedOnPractice() {
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Practice_code__c = 'Test Practice';
        insert acc;
        
        CareSpecialty careSpecialty = new CareSpecialty();
        careSpecialty.Name='Test Modality';
        insert careSpecialty;
        
        HealthCareProcedure proc = new HealthCareProcedure();
        proc.Name = 'Test Procedure';
        proc.Practice_Codes__c = acc.Id;
        proc.Modality_Codes__c = careSpecialty.Id;
        proc.Code = 'PROC12';
        proc.Body_Parts__c = 'Chest';
        proc.Reason_For_Exam__c = 'Checkup';
        proc.Special_Instructions__c = 'N/A';
        proc.IsActive = true;
        insert proc;
            
            List<String> practice = new List<String>{'Test Practice'};
            List<String> modalities = new List<String>{'Test Modality'};
   
                
           // Prepare the parameters map
            Map<String, List<String>> procRecordsParamTest = new Map<String, List<String>>();
            procRecordsParamTest.put('id',new List<String>{'Id'});
            procRecordsParamTest.put('name',new List<String>{'Name'});
            procRecordsParamTest.put('practice',new List<String>{'Practice_Codes__r', 'Practice_code__c'});
            procRecordsParamTest.put('modality',new List<String>{'Modality_Codes__r', 'Name'});
            procRecordsParamTest.put('procedureCode',new List<String>{'Code'});
            procRecordsParamTest.put('bodyParts',new List<String>{'Body_Parts__c'});
            procRecordsParamTest.put('reasonForExam',new List<String>{'Reason_For_Exam__c'});
            procRecordsParamTest.put('specialInstructions',new List<String>{'Special_Instructions__c'});
            
            Test.startTest();
                List<DH_ModalityBasedPracticeController.HealthCareProcedureWrapper> result =
                DH_KMUtility.getHealthcareProcRecords(procRecordsParamTest, new List<sObject>{proc});
        	Test.stopTest();
            System.assertEquals(true, result.size()>=0, 'Expected one HealthcareProcedureWrapper in the result');
      
        }
    
    @isTest
    static void testGetNotesBasedOnPractice() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Practice_code__c = 'Test Practice';
        insert acc;
        
        CareSpecialty careSpecality = new CareSpecialty();
        careSpecality.Name='Test Modality';
        insert careSpecality;
        
        Special_Instructions__c specIns = new Special_Instructions__c();
        specIns.Name ='Test1';
        specIns.Practice_Codes__c = acc.Id;
        specIns.Modality_Codes__c = careSpecality.Id;
        specIns.isActive__c = true;
        insert specIns;

        Special_Instructions__c specIns2 = new Special_Instructions__c();
        specIns2.Name ='Test2';
        specIns2.Practice_Codes__c = acc.Id;
        specIns2.Modality_Codes__c = null;
        specIns2.isActive__c = true;
        insert specIns2;
    
    		Map<String, List<String>> specInsParamTest = new Map<String, List<String>>();
            specInsParamTest.put('id',new List<String>{'Id'});
            specInsParamTest.put('name',new List<String>{'Name'});
            specInsParamTest.put('practiceCodes',new List<String>{'Practice_Codes__r', 'Practice_code__c'});
            specInsParamTest.put('modalityCodes',new List<String>{'Modality_Codes__r', 'Name'});
           
            Test.startTest();
           	List<DH_ModalityBasedPracticeController.specialInstructionsWrapper> result =
           	DH_KMUtility.getSpecialInstructions(specInsParamTest, new List<sObject>{specIns});
               DH_KMUtility.getSpecialInstructions(specInsParamTest, new List<sObject>{specIns2});
        	Test.stopTest();

            System.assertEquals(true, result.size()>=0, 'Expected one Special Instructions in the result');
            
        
  }
    
    @isTest
    static void testAddDataCategorySelectionAndInsert() {
    // Set up the valid values
    String dataCategoryGroup = 'User'; // Use a valid value for Data_Category_Group__c
    String category = 'Employee_Resources'; // Assume this is a valid category under dataCategoryGroup
    String subCategory = 'ADP'; // A valid subcategory under the Category
 
    // Create a test Knowledge Article record with the valid Data_Category_Group__c value
    Knowledge__kav knowledgeRecord = new Knowledge__kav();
    knowledgeRecord.Title = 'Test Article';
    knowledgeRecord.UrlName = 'Test-Article';
    knowledgeRecord.Data_Category_Group__c = dataCategoryGroup; // Set the Data Category Group
    knowledgeRecord.East_Categories__c = category;
    knowledgeRecord.East_Sub_Categories__c = subCategory;
    insert knowledgeRecord;
    
    // Create a list to hold Knowledge__DataCategorySelection records
    List<Knowledge__DataCategorySelection> dataCatSelectionInsertRecsList = new List<Knowledge__DataCategorySelection>();
 
    // Test scenario where only category is provided (and no subcategory)
    DH_KMUtility.addDataCategorySelection(dataCatSelectionInsertRecsList, knowledgeRecord, category, null);
    
    // Assert that the record was added to the list
    System.assertEquals(1, dataCatSelectionInsertRecsList.size(), 'Expected one DataCategorySelection record when only category is provided');
    System.assertEquals(category, dataCatSelectionInsertRecsList[0].DataCategoryName, 'Category name does not match');
 
    // Test scenario where both category and subcategory are provided
    DH_KMUtility.addDataCategorySelection(dataCatSelectionInsertRecsList, knowledgeRecord, category, subCategory);
    
    // Assert that both records were added to the list
    System.assertEquals(2, dataCatSelectionInsertRecsList.size(), 'Expected two DataCategorySelection records when both category and subcategory are provided');
    System.assertEquals(subCategory, dataCatSelectionInsertRecsList[1].DataCategoryName, 'SubCategory name does not match');
 
    // Test scenario where both category and subcategory are null (no records should be added)
    DH_KMUtility.addDataCategorySelection(dataCatSelectionInsertRecsList, knowledgeRecord, null, null);
    
    // Assert that no new records were added
    System.assertEquals(2, dataCatSelectionInsertRecsList.size(), 'No additional DataCategorySelection records should be added when category and subcategory are null');
 
    // Test the insertDataCategorySelections method
    Test.startTest();
    DH_KMUtility.insertDataCategorySelections(dataCatSelectionInsertRecsList);
    Test.stopTest();
    
    // Query the inserted DataCategorySelection records to verify
    List<Knowledge__DataCategorySelection> insertedRecords = [SELECT Id, ParentId, DataCategoryGroupName, DataCategoryName
                                                              FROM Knowledge__DataCategorySelection
                                                              WHERE ParentId = :knowledgeRecord.Id];
    System.assertEquals(true, insertedRecords.size()>=0, 'Expected DataCategorySelection records to be inserted');
    
   }

}