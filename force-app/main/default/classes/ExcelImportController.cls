/******************************************************************************************************************************************************
 * 
 * Apex Controller : ExcelImportController
 * 
 * Created Date    : 11/06/2024
 * 
 * @description    : This class serves to create Healthcare Procedure and Special Instruction records inserted from excel.
 * 
 * @JIRA Id        : CC-105
 * 
 * */
global with sharing class ExcelImportController {
    
    public string successMessage {get{  
		return DH_KMConstants.EX_SUCCESS_MESSAGE;
	} set;}
    
    public string chooseFileMessage {get{  
		return DH_KMConstants.EX_CHOOSE_FILE_MESSAGE;
	} set;}
    
    public string errorsFound {get{  
		return DH_KMConstants.EX_ERRORS_FOUND;
	} set;}
    
    public string wrongFileTypeMessage {get{  
		return DH_KMConstants.EX_WRONG_FILE_TYPE_MESSAGE;
	} set;}
    
    public string wrongExcelFileMessage {get{  
		return DH_KMConstants.EX_WRONG_EXCEL_FILE_MESSAGE;
	} set;}
    
    public string practiceCodeHeader {get{  
		return DH_KMConstants.EX_PRACTICE_CODE_HEADER;
	} set;}
    
    public string modalityCodeHeader {get{  
		return DH_KMConstants.EX_MODALITY_CODE_HEADER;
	} set;}
    
    public string procedureDescriptionHeader {get{  
		return DH_KMConstants.EX_PROCEDURE_DESCRIPTION_HEADER;
	} set;}
    
    public string procedureCodeHeader {get{  
		return DH_KMConstants.EX_PROCEDURE_CODE_HEADER;
	} set;}
    
    public string bodyPartHeader {get{  
		return DH_KMConstants.EX_BODY_PART_HEADER;
	} set;}
    
    public string clinicalIndicationHeader {get{  
		return DH_KMConstants.EX_CLINICAL_INDICATION_HEADER;
	} set;}
    
    public string specialInstructionHeader {get{  
		return DH_KMConstants.EX_SPECIAL_INSTRUCTION_HEADER;
	} set;}
    
    public string noRecordsMessage {get{
        return DH_KMConstants.EX_NO_RECORDS_MESSAGE;
    } set;}
    
    public string syncButtonLabel {get{
        return DH_KMConstants.EX_SYNC_BUTTON_LABEL;
    }}
    
    public string syncSuccessMessage {get{
        return DH_KMConstants.EX_SYNC_SUCCESS_MSG;
    }}
    
    public string alreadySyncedMessage {get{
        return DH_KMConstants.EX_ALREADY_SYNCED_MSG;
    }}
    
    public string successLabel {get{
        return DH_KMConstants.EX_SUCCESS;
    }}
    
    public string syncedLabel {get{
        return DH_KMConstants.EX_SYNCED;
    }}
    
    public string syncFailedError{get{
        return System.Label.DH_Sync_Fail_Error;
    }}
    
    /**************************************************************************************************************************************************
     * 
     * @description this method is used to create and delete healthcare procedure and special_instructions__c records
     * 
     * @param records List of map of healthcare procedure records
     * 
     * @param specialInstructionsRecords List of map of special_instructions__c records
     * 
     * @return List of string of errors (if any) found during insertion of records
     * 
     * */
    @RemoteAction
    global static List<String> createRecords(List<Map<String, String>> records, List<Map<String, String>> specialInstructionsRecords){
        try{
            // forming practiceCode to AccountId Map
            Map<String, Id> practiceCodeAccountIdMap = new Map<String, Id>();
            List<Account> accounts = [Select Id, Practice_code__c from Account where (RecordType.Name =: DH_KMConstants.EX_ACCOUNT_RECORDTYPE_NAME OR RecordType.Name =: DH_KMConstants.EX_ACCOUNT_RECORDTYPE_NAME_VP ) and Practice_code__c != null WITH SECURITY_ENFORCED];
            for(Account acc : accounts){
                practiceCodeAccountIdMap.put(acc.Practice_code__c, acc.Id);
            }
            
            // forming modalityCode to CareSpecialtyId Map
            Map<String, Id> modalityCodeCareSpecialtyIdMap = new Map<String, Id>();
            //List<CareSpecialty> careSpecialties = [Select Id, RecordType.Name, SpecialtyCode from CareSpecialty where SpecialtyCode != null and RecordType.Name =: DH_KMConstants.EX_CARESPECIALTY_RECORDTYPE_NAME WITH SECURITY_ENFORCED];
            List<CareSpecialty> careSpecialties = [Select Id, SpecialtyCode from CareSpecialty where SpecialtyCode != null and RecordType.Name =: DH_KMConstants.EX_CARESPECIALTY_RECORDTYPE_NAME WITH SECURITY_ENFORCED];
            for(CareSpecialty cs : careSpecialties){
                modalityCodeCareSpecialtyIdMap.put(cs.SpecialtyCode, cs.Id);
            }
            
            
            List<HealthCareProcedure> healthCareProceduresList = new List<HealthCareProcedure>();
            List<Special_Instructions__c> specialInstructionsList = new List<Special_Instructions__c>();
            Map<String, Integer> recordVSrowno = new Map<String, Integer>();
            List<String> errorsFound = new List<String>();
            
            // fetching recordId of 'KM Healthcare Procedure' record type
            Id healthCareProcedureRecordTypeIdKM = Schema.SObjectType.HealthCareProcedure.getRecordTypeInfosByName().get(DH_KMConstants.EX_HEALTHCARE_RECORDTYPE_NAME).getRecordTypeId();
            
            // creating healthCareProcedure list to be inserted
            for(Map<String, String> mp : records){
                String practiceCode = mp.get(DH_KMConstants.EX_PRACTICE_CODE);
                String modalityCode = mp.get(DH_KMConstants.EX_MODALITY_CODE);
                Integer rowNo = Integer.valueOf(mp.get(DH_KMConstants.EX_ROWNO));
                
                // checking for any kind of validation errors
                if(String.isBlank(practiceCode)){
                    errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_PRACTICE_CODE_EMPTY_ERROR);
                    if(String.isBlank(modalityCode)){
                        errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_MODALITY_CODE_EMPTY_ERROR);
                    }
                    else if(!modalityCodeCareSpecialtyIdMap.containsKey(modalityCode)){
                        errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_MODALITY_CODE_NOT_FOUND + modalityCode + DH_KMConstants.EX_FOUND_IN_DB);
                    }
                }
                // checking for any kind of validation errors
                else if(!practiceCodeAccountIdMap.containsKey(practiceCode)){
                    errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo +DH_KMConstants.EX_PRACTICE_CODE_NOT_FOUND + practiceCode + DH_KMConstants.EX_FOUND_IN_DB);
                    if(String.isBlank(modalityCode)){
                        errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_MODALITY_CODE_EMPTY_ERROR);
                    }
                    else if(!modalityCodeCareSpecialtyIdMap.containsKey(modalityCode)){
                        errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_MODALITY_CODE_NOT_FOUND + modalityCode + DH_KMConstants.EX_FOUND_IN_DB);
                    }
                }
                
                // checking for any kind of validation errors
                if(String.isBlank(modalityCode)){
                    errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_MODALITY_CODE_EMPTY_ERROR);
                }
                else if(!modalityCodeCareSpecialtyIdMap.containsKey(modalityCode)){
                    errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_MODALITY_CODE_NOT_FOUND + modalityCode + DH_KMConstants.EX_FOUND_IN_DB);
                }
                
                
                HealthCareProcedure hcp = new HealthCareProcedure();
                hcp.Practice_Codes__c = practiceCodeAccountIdMap.get(practiceCode);
                hcp.Modality_Codes__c = modalityCodeCareSpecialtyIdMap.get(modalityCode);
                hcp.Name = mp.get(DH_KMConstants.EX_PROCEDURE_DESCRIPTION);
                hcp.Code = mp.get(DH_KMConstants.EX_PROCEDURE_CODE);
                hcp.Body_Parts__c = mp.get(DH_KMConstants.EX_BODY_PART);
                hcp.Reason_for_Exam__c = mp.get(DH_KMConstants.EX_CLINICAL_INDICATION);
                hcp.Special_Instructions__c = mp.get(DH_KMConstants.EX_SPECIAL_INSTRUCTIONS);
                hcp.IsActive = true;
                hcp.RecordTypeId = healthCareProcedureRecordTypeIdKM;
                healthCareProceduresList.add(hcp);
                recordVSrowno.put(JSON.serialize(hcp), rowNo);
            }
            
            List<String> errorsFoundSpecialInstructions = new List<String>();
            
            // creating specialInstructionList to be inserted
            for(Map<String, String> mp : specialInstructionsRecords){
                String practiceCode = mp.get(DH_KMConstants.EX_PRACTICE_CODE);
                String modalityCode = mp.get(DH_KMConstants.EX_MODALITY_CODE);
                Integer rowNo = Integer.valueOf(mp.get(DH_KMConstants.EX_ROWNO));
                
                // checking for any kind of validation errors
                if(String.isBlank(practiceCode)){
                    errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_PRACTICE_CODE_EMPTY_ERROR);
                    errorsFoundSpecialInstructions.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_PRACTICE_CODE_EMPTY_ERROR);				
                    continue;                
                }
                else if(!practiceCodeAccountIdMap.containsKey(practiceCode)){
                    errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_PRACTICE_CODE_NOT_FOUND + practiceCode + DH_KMConstants.EX_FOUND_IN_DB);
                    errorsFoundSpecialInstructions.add(DH_KMConstants.EX_ROW_NUMBER + rowNo + DH_KMConstants.EX_PRACTICE_CODE_NOT_FOUND + practiceCode + DH_KMConstants.EX_FOUND_IN_DB);
                    continue;
                }
                Special_Instructions__c spIns = new Special_Instructions__c();
                spIns.Practice_Codes__c = practiceCodeAccountIdMap.get(practiceCode);
                spIns.Modality_Codes__c = modalityCodeCareSpecialtyIdMap.get(modalityCode);
                spIns.Special_Instructions__c = mp.get(DH_KMConstants.EX_SPECIAL_INSTRUCTIONS);
                spIns.isActive__c=true;
                specialInstructionsList.add(spIns);
                recordVSrowno.put(JSON.serialize(spIns), rowNo);
            }
       
            
            List<HealthCareProcedure> successHealthCareProceduresList = new List<HealthCareProcedure>();
            List<HealthCareProcedure> failedHealthCareProceduresList = new List<HealthCareProcedure>();
            List<Special_Instructions__c> successSpecialInstructionsList = new List<Special_Instructions__c>();
            List<Special_Instructions__c> failedSpecialInstructionsList = new List<Special_Instructions__c>();
            try{
                List<HealthCareProcedure> allHealthcareProcedure;
                if(healthCareProceduresList.size() == records.size() && errorsFound.size() == 0){
                    //allHealthcareProcedure = [Select Id, RecordType.Name from HealthCareProcedure where RecordType.Name =: DH_KMConstants.EX_HEALTHCARE_RECORDTYPE_NAME WITH SECURITY_ENFORCED];
                    allHealthcareProcedure = [Select Id from HealthCareProcedure where RecordType.Name =: DH_KMConstants.EX_HEALTHCARE_RECORDTYPE_NAME WITH SECURITY_ENFORCED];
                    if(!healthCareProceduresList.isEmpty()){
                        // partially inserting healthcare procedure records
                        Database.SaveResult[] result = Database.insert(healthCareProceduresList,false);
                        for (Integer i = 0; i < result.size(); i++) {
                            Database.SaveResult upsertResult = result[i];
                            if (!upsertResult.isSuccess()) {                        			
                                failedHealthCareProceduresList.add(healthCareProceduresList[i]);
                                // adding errors to errorsFound list
                                errorsFound.add(DH_KMConstants.EX_ROW_NUMBER+recordVSrowno.get(JSON.serialize(healthCareProceduresList[i])) + DH_KMConstants.EX_CAUSING_ERROR_MSG + upsertResult.getErrors());
                                continue;                       			
                            }
                            if (upsertResult.isSuccess()){
                                successHealthCareProceduresList.add(healthCareProceduresList[i]);
                            }
                        }
                    }
                }
                List<Special_Instructions__c> allSpecialInstructionsList;
                if(specialInstructionsList.size() == specialInstructionsRecords.size() && errorsFoundSpecialInstructions.size() == 0){
                    //allSpecialInstructionsList = new List<Special_Instructions__c>([SELECT id, name from Special_Instructions__c WITH SECURITY_ENFORCED]);
                    allSpecialInstructionsList = new List<Special_Instructions__c>([SELECT Id from Special_Instructions__c WITH SECURITY_ENFORCED]);
                    if(!specialInstructionsList.isEmpty()){
                        // partially inserting special_instructions__c records
                        Database.SaveResult[] siResults = Database.insert(specialInstructionsList,false);
                        for (Integer i = 0; i < siResults.size(); i++) {
                            Database.SaveResult upsertResult = siResults[i];
                            if (!upsertResult.isSuccess()) {                        			
                                failedSpecialInstructionsList.add(specialInstructionsList[i]);
                                // adding errors to errorsFound list
                                errorsFound.add(DH_KMConstants.EX_ROW_NUMBER + recordVSrowno.get(JSON.serialize(specialInstructionsList[i])) + DH_KMConstants.EX_CAUSING_ERROR_MSG + upsertResult.getErrors());
                                continue;		
                            }
                            if (upsertResult.isSuccess()){
                                successSpecialInstructionsList.add(specialInstructionsList[i]);
                            }
                        }
                    }
                }
                if(!errorsFound.isempty() || !failedHealthCareProceduresList.isempty() || !failedSpecialInstructionsList.isempty()){
                    if(!successSpecialInstructionsList.isEmpty() && Special_Instructions__c.SObjectType.getDescribe().isDeletable()){
                        delete successSpecialInstructionsList;
                    }
                    if(!successHealthCareProceduresList.isEmpty() && HealthCareProcedure.SObjectType.getDescribe().isDeletable()){
                        delete successHealthCareProceduresList;
                    } 
                }
                
                if(!successHealthCareProceduresList.isEmpty() && errorsFound.isempty() && HealthCareProcedure.SObjectType.getDescribe().isDeletable()){
                    delete allHealthcareProcedure;
                }
                
                if(!successSpecialInstructionsList.isEmpty() && errorsFound.isempty() && Special_Instructions__c.SObjectType.getDescribe().isDeletable()){
                    delete allSpecialInstructionsList;
                }
            }
            catch(Exception e){
                System.debug(LoggingLevel.ERROR, ' Error in database operations: ' + e.getMessage() + ' at line no: ' + e.getLineNumber());
            }     
            return errorsFound;
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, ' Error in createRecords method: ' + e.getMessage() + ' at line no: ' + e.getLineNumber());
        }
        return new List<String>{};
    }
    
    
    /**************************************************************************************************************************************************
     * 
     * @description this method is used to create cloned healthcare procedure records
     * 
     * */
    public static void createDhHcpRecords(){
        try{
            // fetching the recordType id for DH_HealthcareProcedure__c object
            Id dhhcpRecordTypeId = Schema.SObjectType.DH_HealthCareProcedure__c.getRecordTypeInfosByName().get(DH_KMConstants.EX_DH_HEALTHCARE_RECORDTYPE_NAME).getRecordTypeId();
            
            // fetching the recordType id for HealthcareProcedure object
            Id healthCareProcedureRecordTypeIdKM = Schema.SObjectType.HealthCareProcedure.getRecordTypeInfosByName().get(DH_KMConstants.EX_HEALTHCARE_RECORDTYPE_NAME).getRecordTypeId();
            
            // Deleting all DH_HCP records
            List<DH_HealthCareProcedure__c> dhHcpDeleteList = DH_KMQueryManager.getClonedHealthcareProcedureRecords(dhhcpRecordTypeId);
            if(dhHcpDeleteList != null && dhHcpDeleteList.size() > 0 && DH_HealthCareProcedure__c.SObjectType.getDescribe().isDeletable()){
                delete dhHcpDeleteList;
            }
            
            List<DH_CareSpecialty__c> dhcarespecialties = DH_KMQueryManager.getClonedCareSpecialties();
            
            // forming a map of DH_CareSpecialty__c external id vs its record id
            Map<String, Id> dhcsExternalIdVSId = new Map<String, Id>();
            for(DH_CareSpecialty__c dhcs : dhcarespecialties){
                dhcsExternalIdVSId.put(dhcs.DH_CareSpecialty_External_ID__c, dhcs.Id);
            }
            List<DH_HealthCareProcedure__c> dhhcpList = new List<DH_HealthCareProcedure__c>();
            for(HealthcareProcedure hcp : DH_KMQueryManager.getHealthcareProcedure(healthCareProcedureRecordTypeIdKM)){
                DH_HealthCareProcedure__c dhhcp = new DH_HealthCareProcedure__c();
                dhhcp.DH_Active__c = hcp.IsActive;
                dhhcp.DH_Name__c = hcp.Name;
                dhhcp.DH_Healthcare_Procedure_External_Id__c = hcp.Id;
                dhhcp.DH_Practice_Code_s__c = hcp.Practice_Codes__c;
                dhhcp.DH_New_Modality_codes__c = dhcsExternalIdVSId.get(hcp.Modality_Codes__r.CareSpecialty_External_ID__c);
                dhhcp.DH_Procedure_Codes__c = hcp.Code;
                dhhcp.DH_Body_Parts__c = hcp.Body_Parts__c;
                dhhcp.DH_Reason_for_Exam__c = hcp.Reason_for_Exam__c;
                dhhcp.DH_Special_Instructions__c = hcp.Special_Instructions__c;
                dhhcp.RecordTypeId = dhhcpRecordTypeId;
                dhhcpList.add(dhhcp);
            }
            
            if(dhhcpList != null && dhhcpList.size() > 0 && DH_HealthCareProcedure__c.SObjectType.getDescribe().isCreateable()){
                insert dhhcpList;
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, ' Error in creation of cloned records : ' + e.getMessage() + ' at line no: ' + e.getLineNumber());
        }
        
    }
    
    /**************************************************************************************************************************************************
     * 
     * @description this method syncs healthcare records to ucc
     * 
     * @return String returns success/synced depending on whether the records are done syncing or are already synced.
     * */
    @RemoteAction
    global static String syncRecords(){
        try{
            Id dhhcpRecordTypeId = Schema.SObjectType.DH_HealthCareProcedure__c.getRecordTypeInfosByName().get(DH_KMConstants.EX_DH_HEALTHCARE_RECORDTYPE_NAME).getRecordTypeId();
            // List<DH_HealthCareProcedure__c> dhhcpList = [Select Id, Name, DH_Healthcare_Procedure_External_Id__c from DH_HealthCareProcedure__c where RecordtypeId =: dhhcpRecordTypeId WITH SECURITY_ENFORCED LIMIT 1 ];
            List<DH_HealthCareProcedure__c> dhhcpList = [Select Id, DH_Healthcare_Procedure_External_Id__c from DH_HealthCareProcedure__c where RecordtypeId =: dhhcpRecordTypeId WITH SECURITY_ENFORCED LIMIT 1 ];
            
            // If there are no DH_HealthCareProcedure__c records present
            if(dhhcpList.size() == 0){
                createDhHcpRecords();
                return DH_KMConstants.EX_SUCCESS;
            }
            String hcpId = dhhcpList[0].DH_Healthcare_Procedure_External_Id__c;
            List<HealthcareProcedure> hcpList = [Select Id from HealthcareProcedure where Id =: hcpId WITH SECURITY_ENFORCED];
            
            // If there is no corresponding healthcareProcedure record for DH_HealthCareProcedure__c record
            if(hcpList.size() == 0){
                createDhHcpRecords();
                return DH_KMConstants.EX_SUCCESS;
            }
            return DH_KMConstants.EX_SYNCED;
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, ' Error in syncing records: ' + e.getMessage() + ' at line no: ' + e.getLineNumber());
        }
        
        return '';
    }
}