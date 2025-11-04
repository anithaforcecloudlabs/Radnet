/*
 *********************************************************

Apex Class    : DH_ModalityBasedPracticeController
    
Created Date       : March 30, 2024
    
@description       : This class is used to fetch options of modalities and practice to show Healthcare Procedure and Special Instructions records.

@jiraid            : CC-105, CC-792

 *********************************************************
 */
public with sharing class DH_ModalityBasedPracticeController {
    
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches records for Procedure table
     *
     * @param List of String containing practice and modalities
     *
     * @return List of HealthcareProcedure Wrapper
     *
     * */
    @AuraEnabled
    public static List<HealthCareProcedureWrapper> getRecordsBasedOnPractice(List<String> practice, List<String> modalities) {
        List<HealthCareProcedureWrapper> hcpWrapperList = new List<HealthCareProcedureWrapper>();
        List<sObject> procRecords = new List<sObject>();
        Boolean isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false;
        try {
            if(practice.size()>0 && modalities.size()>0){
                procRecords = DH_KMQueryManager.getHealthcareProcedureRecords(practice, modalities, isGuestUser);
                
                if(isGuestUser){
                    Map<String,List<String>> procRecordsParam = new Map<String,List<String>>();
                    procRecordsParam.put('id',new List<String>{'Id'});
                    procRecordsParam.put('name',new List<String>{'DH_Name__c'});
                    procRecordsParam.put('practice',new List<String>{'DH_Practice_Code_s__r','Practice_code__c'});
                    procRecordsParam.put('modality',new List<String>{'DH_New_Modality_codes__r','Name'});
                    procRecordsParam.put('procedureCode',new List<String>{'DH_Procedure_Codes__c'});
                    procRecordsParam.put('bodyParts',new List<String>{'DH_Body_Parts__c'});
                    procRecordsParam.put('reasonForExam',new List<String>{'DH_Reason_for_Exam__c'});
                    procRecordsParam.put('specialInstructions',new List<String>{'DH_Special_Instructions__c'});

                    hcpWrapperList = DH_KMUtility.getHealthcareProcRecords(procRecordsParam, procRecords );

                }
                else{
                    Map<String,List<String>> procRecordsParam = new Map<String,List<String>>();
                    procRecordsParam.put('id',new List<String>{'Id'});
                    procRecordsParam.put('name',new List<String>{'Name'});
                    procRecordsParam.put('practice',new List<String>{'Practice_Codes__r','Practice_code__c'});
                    procRecordsParam.put('modality',new List<String>{'Modality_Codes__r','Name'});
                    procRecordsParam.put('procedureCode',new List<String>{'Code'});
                    procRecordsParam.put('bodyParts',new List<String>{'Body_Parts__c'});
                    procRecordsParam.put('reasonForExam',new List<String>{'Reason_for_Exam__c'});
                    procRecordsParam.put('specialInstructions',new List<String>{'Special_Instructions__c'});

                    hcpWrapperList = DH_KMUtility.getHealthcareProcRecords(procRecordsParam, procRecords );

                }
            }
        }
        catch (exception e) {
            DH_KMUtility.getException(e,'Error in getting procedure records : ');
            
        }
        return hcpWrapperList;
    }
    
    /**
     * @description Wrapper class for HealthCareProcedure object
     **/
    public class HealthCareProcedureWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String practice;
        @AuraEnabled public String modality;
        @AuraEnabled public String procedureCode;
        @AuraEnabled public String bodyParts;
        @AuraEnabled public String reasonForExam;
        @AuraEnabled public String specialInstructions;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches records for Special Instructions table
     *
     * @param List of String containing practice and modalities
     *
     * @return List of Special Instructions wrapper
     *
     * */
    
    @AuraEnabled
    public static List<specialInstructionsWrapper> getNotes(List<String> practice, List<String> modalities) {

        List<specialInstructionsWrapper> siWrapperList = new List<specialInstructionsWrapper>();
        List<sObject> instruct = new List<sObject>();
        Boolean isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false;
        try {
            instruct = DH_KMQueryManager.getSpecialInstructionsRecords(practice, modalities, isGuestUser);
           
				Map<String,List<String>> specInsParam = new Map<String, List<String>>();
                specInsParam.put('id',new List<String>{'Id'});
                specInsParam.put('name',new List<String>{'Name'});
                specInsParam.put('practiceCodes',new List<String>{'Practice_Codes__r','Practice_code__c'});
                
                if(isGuestUser) {
                    specInsParam.put('modalityCodes',new List<String>{'DH_Modality_Codes__r','Name'});
                } else{
                    specInsParam.put('modalityCodes',new List<String>{'Modality_Codes__r','Name'});
                }
                
                specInsParam.put('specialInstructions',new List<String>{'Special_Instructions__c'});
                
                siWrapperList = DH_KMUtility.getSpecialInstructions(specInsParam, instruct);
              
        } catch (exception e) {
            DH_KMUtility.getException(e,'Error in getting special instructions : ');
            
        }
        return siWrapperList;
    }
    /**
     * @description Wrapper class for Special Instruction object
     **/
    public class SpecialInstructionsWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String practiceCodes;
        @AuraEnabled public String modalityCodes;
        @AuraEnabled public String specialInstructions;
    }
    
    /**
     * @description Method used to return Guest User type
     * @return Boolean Guest user or not
     **/
    @AuraEnabled
    public static Boolean getUserType() {
        Boolean isGuestUser = false;
        try{
            isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false;
        } catch (exception e) {
            DH_KMUtility.getException(e,'Error in getting user type : ');
            
        }
        return isGuestUser;
    }
}