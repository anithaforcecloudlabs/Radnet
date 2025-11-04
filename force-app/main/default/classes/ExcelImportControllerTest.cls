/******************************************************************************************************************************************************
 * 
 * Apex Test Class : ExcelImportControllerTest
 * 
 * Created Date    : 11/06/2024
 * 
 * @description    : This test class verifies the functionality of the ExcelImportController class. It covers scenarios including both successful and unsuccessful insertion of HealthcareProcedure and Special_Instructions__c records
 * 
 * @JIRA Id        : CC-105
 * 
 * */ 
@isTest
public with sharing class ExcelImportControllerTest {
    /*
     * @description  this method creates test data to be used in the test methods
     * 
     * */
    @TestSetup 
    public static void createData(){
        List<Account> accList = new List<Account>();
        List<HealthCareProcedure> hcpList = new List<HealthCareProcedure>();
        List<CareSpecialty> cspList = new List<CareSpecialty>();
        List<Special_Instructions__c> spiList = new List<Special_Instructions__c>();
        Id healthCareProcedureRecordTypeIdKM = Schema.SObjectType.HealthCareProcedure.getRecordTypeInfosByName().get(DH_KMConstants.EX_HEALTHCARE_RECORDTYPE_NAME).getRecordTypeId();
        Id practiceRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.EX_ACCOUNT_RECORDTYPE_NAME).getRecordTypeId();
        Id virtualPracticeRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.EX_ACCOUNT_RECORDTYPE_NAME_VP).getRecordTypeId();
		Id kmCareSpecialtyRecordTypeId = Schema.SObjectType.CareSpecialty.getRecordTypeInfosByName().get(DH_KMConstants.EX_CARESPECIALTY_RECORDTYPE_NAME).getRecordTypeId();
        
        // CREATING ACCOUNT RECORDS
        for(Integer i=0; i<2; i++){
            Account acc = new Account();
            acc.Name = 'TestAccount' + i;
            acc.RecordTypeId = i == 0 ? practiceRecordTypeId :virtualPracticeRecordTypeId ;
            acc.Practice_code__c = i == 0 ? 'ARS' : 'CRA';
            accList.add(acc);
        }
        insert accList; 
        
        
        // CREATING CARE SPECIALTY RECORDS
        for(Integer i=0; i<2; i++){
            CareSpecialty cs = new CareSpecialty();
            cs.Name = 'TestCareSpecialty'+i;
            cs.SpecialtyCode = i == 0 ? 'MA' : 'US';
            cs.RecordTypeId = kmCareSpecialtyRecordTypeId;
            cspList.add(cs);
        }
		insert cspList;
        
        // CREATING HEALTHCAREPROCEDURE RECORDS
        for(Integer i=0; i<2; i++){
            HealthCareProcedure hcp = new HealthCareProcedure();
            hcp.Practice_Codes__c = accList[i].Id;
            hcp.Modality_Codes__c = cspList[i].Id;
            hcp.Name = i == 0 ? 'Ultrasound Stomach' : 'Dental Scan';
            hcp.Code = i == 0 ? '1234US' : '1234DS';
            hcp.Body_Parts__c = i == 0 ? 'Stomach' : 'Teeth';
            hcp.Reason_for_Exam__c = '<span style="color:red;">Reason For Exam' + i + '</span>';
            hcp.Special_Instructions__c = '<span style="font-weight:bold;">Special Instructions' + i + '</span>';
            hcp.IsActive = true;
            hcp.RecordTypeId =healthCareProcedureRecordTypeIdKM;
            hcpList.add(hcp);
        }
        
        insert hcpList;
        
        // CREATING SPECIAL INSTRUCTION RECORDS
        for(Integer i=0; i<2; i++){
            Special_Instructions__c spi = new Special_Instructions__c();
            spi.Practice_Codes__c = accList[i].Id;
            spi.Modality_Codes__c = cspList[i].Id;
            spi.Special_Instructions__c = '<span>Special Instructions' + i + '</span>';
            spi.isActive__c = true;
            spiList.add(spi);
        }
        
        insert spiList;
        
    }
	

    /*
     * @description  this method tests creation of records in happy flow
     * 
     * */
    
	@isTest
    public static void createRecordTestSuccess(){
        List<Map<String, String>> records = new List<Map<String, String>>();
        List<Map<String, String>> specialInstructionsRecords = new List<Map<String, String>>();
        Map<String, String> hcpMap1= new Map<String, String>();
        hcpMap1.put('practiceCode','ARS');
        hcpMap1.put('modalityCode','MA');
        hcpMap1.put('procedureDescription','Map1Data');
        hcpMap1.put('procedureCode','G0301T');
        hcpMap1.put('bodyPart','Breast');
        hcpMap1.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        hcpMap1.put('specialInstructions','<b>hello</b>');
        hcpMap1.put('rowNo', '400');
        Map<String, String> hcpMap2= new Map<String, String>();
        hcpMap2.put('practiceCode','CRA');
        hcpMap2.put('modalityCode','US');
        hcpMap2.put('procedureDescription','Map1Data');
        hcpMap2.put('procedureCode','G0302T');
        hcpMap2.put('bodyPart','Breast');
        hcpMap2.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        hcpMap2.put('specialInstructions','<b>hello</b>');
        hcpMap2.put('rowNo', '1040');
       	records.add(hcpMap1);
        records.add(hcpMap2);
        
        Map<String, String> spiMap1= new Map<String, String>();
        spiMap1.put('practiceCode','ARS');
        spiMap1.put('modalityCode','MA');
        spiMap1.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        spiMap1.put('rowNo', '2000');
        Map<String, String> spiMap2= new Map<String, String>();
        spiMap2.put('practiceCode','CRA');
        spiMap2.put('modalityCode','US');
        spiMap2.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        spiMap2.put('rowNo', '3057');
        specialInstructionsRecords.add(spiMap1);
        specialInstructionsRecords.add(spiMap2);
        
        Test.startTest();
        	List<String>jobIdCustomErrors = ExcelImportController.createRecords(records, specialInstructionsRecords);
        Test.stopTest();
        
        System.assertEquals(jobIdCustomErrors.size(), 0, 'Records created successfully');
        
    }   

    /*
     * @description  this method tries creation of records when practice and modality codes are empty and null
     * 
     * */
    @isTest
    public static void createRecordsTestPracticeCodeAndModalityCodeEmptyAndNull(){
        List<Map<String, String>> records = new List<Map<String, String>>();
        List<Map<String, String>> specialInstructionsRecords = new List<Map<String, String>>();
        
        Map<String, String> hcpMap1= new Map<String, String>();
        hcpMap1.put('practiceCode','');
        hcpMap1.put('modalityCode','');
        hcpMap1.put('procedureDescription','Map1Data');
        hcpMap1.put('procedureCode','G0301T');
        hcpMap1.put('bodyPart','Breast');
        hcpMap1.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        hcpMap1.put('specialInstructions','<b>hello</b>');
        hcpMap1.put('rowNo', '400');
        
       Map<String, String> hcpMap2= new Map<String, String>();
        hcpMap2.put('practiceCode',null);
        hcpMap2.put('modalityCode','');
        hcpMap2.put('procedureDescription','Map1Data');
        hcpMap2.put('procedureCode','G0302T');
        hcpMap2.put('bodyPart','Breast');
        hcpMap2.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        hcpMap2.put('specialInstructions','<b>hello</b>');
        hcpMap2.put('rowNo', '1040');
        Map<String, String> hcpMap3= new Map<String, String>();
        hcpMap3.put('practiceCode','');
        hcpMap3.put('modalityCode',null);
        hcpMap3.put('procedureDescription','Map1Data');
        hcpMap3.put('procedureCode','G0301T');
        hcpMap3.put('bodyPart','Breast');
        hcpMap3.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        hcpMap3.put('specialInstructions','<b>hello</b>');
        hcpMap3.put('rowNo', '400');
        Map<String, String> hcpMap4= new Map<String, String>();
        hcpMap4.put('practiceCode',null);
        hcpMap4.put('modalityCode',null);
        hcpMap4.put('procedureDescription','Map1Data');
        hcpMap4.put('procedureCode','G0302T');
        hcpMap4.put('bodyPart','Breast');
        hcpMap4.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        hcpMap4.put('specialInstructions','<b>hello</b>');
        hcpMap4.put('rowNo', '1040');
       	records.add(hcpMap1);
        records.add(hcpMap2);
        records.add(hcpMap3);
        records.add(hcpMap4);
        
        Map<String, String> spiMap1= new Map<String, String>();
        spiMap1.put('practiceCode','');
        spiMap1.put('modalityCode','');
        spiMap1.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        spiMap1.put('rowNo', '2000');
        
        Map<String, String> spiMap2= new Map<String, String>();
        spiMap2.put('practiceCode',null);
        spiMap2.put('modalityCode','');
        spiMap2.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        spiMap2.put('rowNo', '3057');
        
        Map<String, String> spiMap3= new Map<String, String>();
        spiMap3.put('practiceCode','');
        spiMap3.put('modalityCode',null);
        spiMap3.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        spiMap3.put('rowNo', '2000');
        
        Map<String, String> spiMap4= new Map<String, String>();
        spiMap4.put('practiceCode',null);
        spiMap4.put('modalityCode',null);
        spiMap4.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        spiMap4.put('rowNo', '3057');
       
        specialInstructionsRecords.add(spiMap1);
        specialInstructionsRecords.add(spiMap2);
        specialInstructionsRecords.add(spiMap3);
        specialInstructionsRecords.add(spiMap4);
        
        Test.startTest();
        	List<String> jobIdCustomErrors = ExcelImportController.createRecords(records, specialInstructionsRecords);
        Test.stopTest();
        
        System.assertEquals(jobIdCustomErrors.size(), 16, 'Errors Found');
        
    }
    
    /*
     * @description  this method tries creation of records when practice and modality code is invalid
     * 
     * */
    @isTest
    public static void createRecordsTestInvalidPracticeCodeAndSpecialtyCode(){
        List<Map<String, String>> records = new List<Map<String, String>>();
        List<Map<String, String>> specialInstructionsRecords = new List<Map<String, String>>();
        
        Map<String, String> hcpMap1= new Map<String, String>();
        hcpMap1.put('practiceCode','INVALID');
        hcpMap1.put('modalityCode','INVALID');
        hcpMap1.put('procedureDescription','Map1Data');
        hcpMap1.put('procedureCode','G0301T');
        hcpMap1.put('bodyPart','Breast');
        hcpMap1.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        hcpMap1.put('specialInstructions','<b>hello</b>');
        hcpMap1.put('rowNo', '400');
        
        Map<String, String> hcpMap2= new Map<String, String>();
        hcpMap2.put('practiceCode',null);
        hcpMap2.put('modalityCode','INVALID');
        hcpMap2.put('procedureDescription','Map1Data');
        hcpMap2.put('procedureCode','G0302T');
        hcpMap2.put('bodyPart','Breast');
        hcpMap2.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        hcpMap2.put('specialInstructions','<b>hello</b>');
        hcpMap2.put('rowNo', '1040');
        
        Map<String, String> hcpMap3= new Map<String, String>();
        hcpMap3.put('practiceCode','INVALID');
        hcpMap3.put('modalityCode',null);
        hcpMap3.put('procedureDescription','Map1Data');
        hcpMap3.put('procedureCode','G0303T');
        hcpMap3.put('bodyPart','Breast');
        hcpMap3.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        hcpMap3.put('specialInstructions','<b>hello</b>');
        hcpMap3.put('rowNo', '400');
        
        Map<String, String> hcpMap4= new Map<String, String>();
        hcpMap4.put('practiceCode','INVALID');
        hcpMap4.put('modalityCode','');
        hcpMap4.put('procedureDescription','Map1Data');
        hcpMap4.put('procedureCode','G0304T');
        hcpMap4.put('bodyPart','Breast');
        hcpMap4.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        hcpMap4.put('specialInstructions','<b>hello</b>');
        hcpMap4.put('rowNo', '1040');
        
        Map<String, String> hcpMap5= new Map<String, String>();
        hcpMap5.put('practiceCode','');
        hcpMap5.put('modalityCode','INVALID');
        hcpMap5.put('procedureDescription','Map1Data');
        hcpMap5.put('procedureCode','G0305T');
        hcpMap5.put('bodyPart','Breast');
        hcpMap5.put('clinicalIndication','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        hcpMap5.put('specialInstructions','<b>hello</b>');
        hcpMap5.put('rowNo', '1044');
        
        records.add(hcpMap1);
        records.add(hcpMap2);
        records.add(hcpMap3);
        records.add(hcpMap4);
        records.add(hcpMap5);
        
        Map<String, String> spiMap1= new Map<String, String>();
        spiMap1.put('practiceCode','INVALID');
        spiMap1.put('modalityCode','INVALID');
        spiMap1.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        spiMap1.put('rowNo', '2000');
        
        Map<String, String> spiMap2= new Map<String, String>();
        spiMap2.put('practiceCode',null);
        spiMap2.put('modalityCode','INVALID');
        spiMap2.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        spiMap2.put('rowNo', '3057');
        
        Map<String, String> spiMap3= new Map<String, String>();
        spiMap3.put('practiceCode','INVALID');
        spiMap3.put('modalityCode',null);
        spiMap3.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text1</span></span>');
        spiMap3.put('rowNo', '2001');
        
        Map<String, String> spiMap4= new Map<String, String>();
        spiMap4.put('practiceCode','INVALID');
        spiMap4.put('modalityCode','');
        spiMap4.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        spiMap4.put('rowNo', '3051');
        
        Map<String, String> spiMap5= new Map<String, String>();
        spiMap5.put('practiceCode','');
        spiMap5.put('modalityCode','INVALID');
        spiMap5.put('specialInstructions','<span style="font-family: Calibri; font-size: 12;"><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: bold; font-style: normal; text-decoration: none;">NJIN: </span><span style="font-family: Calibri; font-size: 12px; color: black; font-weight: normal; font-style: normal; text-decoration: none;">Rich Text2</span></span>');
        spiMap5.put('rowNo', '3052');
       
        specialInstructionsRecords.add(spiMap1);
        specialInstructionsRecords.add(spiMap2);
        specialInstructionsRecords.add(spiMap3);
        specialInstructionsRecords.add(spiMap4);
        specialInstructionsRecords.add(spiMap5);
        
        Test.startTest();
        List<String> jobIdCustomErrors = ExcelImportController.createRecords(records, specialInstructionsRecords);
        Test.stopTest();
        
        System.assertEquals(jobIdCustomErrors.size() > 0, true, 'Errors Found');
    }
    
    
    /*
     * @description  this method tries syncing with no cloned records present
     * 
     * */
    
    @isTest
    public static void syncRecordsTestWithNoClonedRecords(){
        Test.startTest();
        String result = ExcelImportController.syncRecords();
        Test.stopTest();
        System.assertEquals(DH_KMConstants.EX_SUCCESS, result, 'cloned records created');
    }
    
    
    /*
     * @description  this method tries syncing with cloned records present and linked to corresponding healthcare procedure record
     * 
     * */
    @isTest
    public static void syncRecordsTestWithExistingClonedRecordsLinked(){
        DH_HealthCareProcedure__c dhhcp = new DH_HealthCareProcedure__c(DH_Name__c = 'Test Dh Hcp', DH_Active__c = true,
            															DH_Body_Parts__c = 'Stomach', DH_Reason_for_Exam__c = '<span style="color:red;">Reason For Exam</span>',
            															DH_Special_Instructions__c = '<span style="font-weight:bold;">Special Instructions</span>');
        insert dhhcp;
        Test.startTest();
        String result = ExcelImportController.syncRecords();
        Test.stopTest();
        System.assertEquals(DH_KMConstants.EX_SUCCESS, result, 'cloned records created');
    }
    
    
    /*
     * @description  this method tries syncing with cloned records present but not linked to healthcare procedure record
     * 
     * */
    @isTest
    public static void syncRecordsTestWithExistingClonedRecordsNotLinked(){
        HealthcareProcedure hcp = [Select Id from HealthcareProcedure LIMIT 1];
        DH_HealthCareProcedure__c dhhcp = new DH_HealthCareProcedure__c(DH_Name__c = 'Test Dh Hcp', DH_Active__c = true, DH_Healthcare_Procedure_External_Id__c = String.valueOf(hcp.Id),
            															DH_Body_Parts__c = 'Stomach', DH_Reason_for_Exam__c = '<span style="color:red;">Reason For Exam</span>',
            															DH_Special_Instructions__c = '<span style="font-weight:bold;">Special Instructions</span>');
        insert dhhcp;
        Test.startTest();
        String result = ExcelImportController.syncRecords();
        Test.stopTest();
        System.assertEquals(DH_KMConstants.EX_SYNCED, result, 'cloned records synced');
    }
    
    
    /*
     * @description  this method tests all the instance variables present in the ExcelImportController class
     * 
     * */    
    @isTest
    public static void testAllInstanceVariables(){
        Test.startTest();
        ExcelImportController exObj = new ExcelImportController();
        Test.stopTest();
        
        System.assertEquals(DH_KMConstants.EX_SUCCESS_MESSAGE, exObj.successMessage, 'successMessage checked');
        System.assertEquals(DH_KMConstants.EX_CHOOSE_FILE_MESSAGE, exObj.chooseFileMessage, 'chooseFileMessage checked');
        System.assertEquals(DH_KMConstants.EX_ERRORS_FOUND, exObj.errorsFound, 'errorsFound checked');
        System.assertEquals(DH_KMConstants.EX_WRONG_FILE_TYPE_MESSAGE, exObj.wrongFileTypeMessage, 'wrongFileTypeMessage checked');
        System.assertEquals(DH_KMConstants.EX_WRONG_EXCEL_FILE_MESSAGE, exObj.wrongExcelFileMessage, 'wrongExcelFileMessage checked');
        System.assertEquals(DH_KMConstants.EX_PRACTICE_CODE_HEADER, exObj.practiceCodeHeader, 'practiceCodeHeader checked');
        System.assertEquals(DH_KMConstants.EX_MODALITY_CODE_HEADER, exObj.modalityCodeHeader, 'modalityCodeHeader checked');
        System.assertEquals(DH_KMConstants.EX_PROCEDURE_DESCRIPTION_HEADER, exObj.procedureDescriptionHeader, 'procedureDescriptionHeader checked');
        System.assertEquals(DH_KMConstants.EX_PROCEDURE_CODE_HEADER, exObj.procedureCodeHeader, 'procedureCodeHeader checked');
        System.assertEquals(DH_KMConstants.EX_BODY_PART_HEADER, exObj.bodyPartHeader, 'bodyPartHeader checked');
        System.assertEquals(DH_KMConstants.EX_CLINICAL_INDICATION_HEADER, exObj.clinicalIndicationHeader, 'clinicalIndicationHeader checked');
        System.assertEquals(DH_KMConstants.EX_SPECIAL_INSTRUCTION_HEADER, exObj.specialInstructionHeader, 'specialInstructionHeader checked');
        System.assertEquals(DH_KMConstants.EX_NO_RECORDS_MESSAGE, exObj.noRecordsMessage, 'noRecordsMessage checked');
        System.assertEquals(DH_KMConstants.EX_SYNC_BUTTON_LABEL, exObj.syncButtonLabel, 'syncButtonLabel checked');
        System.assertEquals(DH_KMConstants.EX_SYNC_SUCCESS_MSG, exObj.syncSuccessMessage, 'syncSuccessMessage checked');
        System.assertEquals(DH_KMConstants.EX_ALREADY_SYNCED_MSG, exObj.alreadySyncedMessage, 'alreadySyncedMessage checked');
        System.assertEquals(DH_KMConstants.EX_SUCCESS, exObj.successLabel, 'successLabel checked');
        System.assertEquals(DH_KMConstants.EX_SYNCED, exObj.syncedLabel, 'syncedLabel checked');
        System.assertEquals(System.Label.DH_Sync_Fail_Error, exObj.syncFailedError, 'syncFailedError checked');
    }
}