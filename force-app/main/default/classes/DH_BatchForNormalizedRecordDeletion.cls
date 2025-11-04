/*
* ***************************************************************************************************************************
* Apex Class Name - DH_BatchForNormalizedRecordDeletion
* Version - 0.1
* Created Date - 
* Function - Batch to delete nomalized records.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Prasanna Anjakar                               Intial version.
* *****************************************************************************************************************************
*/
global class DH_BatchForNormalizedRecordDeletion implements Database.stateful,Database.Batchable<SObject>,Database.AllowsCallouts{
    //SavePoint to be implemented
    global Integer batchSize = 1;
   // global Map<DH_Call_Center_Data_Sheet__c,List<SObject>> ccdsParentVsrecordsToBeDeleted = new Map<DH_Call_Center_Data_Sheet__c,List<SObject>>();  
    
    @TestVisible global Map<DH_Call_Center_Data_Sheet__c,List<SObject>> failedCcdsParentVsrecordsToBeDeleted=new Map<DH_Call_Center_Data_Sheet__c,List<SObject>>();
    global Set<DH_Call_Center_Data_Sheet__c> processingRecords = new Set<DH_Call_Center_Data_Sheet__c>();
    global List<DH_Call_Center_Data_Sheet__c>  ccdsParentRecordsToBeDeleted = new List<DH_Call_Center_Data_Sheet__c> ();
    
    
   @TestVisible global void updatefailedCcdsParentVsrecordsToBeDeleted(Map<DH_Call_Center_Data_Sheet__c,List<SObject>> failedMap) {
        // Do something
		failedCcdsParentVsrecordsToBeDeleted = failedMap;
               System.debug('delete inside testvisible method ' + failedCcdsParentVsrecordsToBeDeleted);

    }
    /**
	* @description constructor to initialize the selected records.
	**/
    global DH_BatchForNormalizedRecordDeletion(List<DH_Call_Center_Data_Sheet__c> ccdsParentRecordsToBeDeleted){
        this.ccdsParentRecordsToBeDeleted= ccdsParentRecordsToBeDeleted;
        this.processingRecords.addAll(ccdsParentRecordsToBeDeleted) ;
    }

    /**
	* @description Start Method for batch class
	**/
    global Database.Querylocator Start(Database.BatchableContext bc){
        String query = 'SELECT Id,DH_Error_Log__c,recordTypeId FROM DH_Call_Center_Data_Sheet__c WHERE ID in :processingRecords';
        return Database.getQueryLocator(query);
    }
    
    /**
	* @param  Database.BatchableContext, (Scope) list<DH_Call_Center_Data_Sheet__c>
	* @description Start Method for batch class
	**/
    global void execute(Database.BatchableContext bc, List<DH_Call_Center_Data_Sheet__c> scope) {
        System.debug('delete inside execute ' + failedCcdsParentVsrecordsToBeDeleted);
        List<Sobject> recordsTobeDeleted = new List<Sobject>();
        List<DH_Call_Center_Data_Sheet__c> exclusionCcds = new List<DH_Call_Center_Data_Sheet__c>();
        List<DH_Call_Center_Data_Sheet__c> modalityPriorityCcds = new List<DH_Call_Center_Data_Sheet__c>();      
        List<DH_Call_Center_Data_Sheet__c> callCenterMappingCcds = new List<DH_Call_Center_Data_Sheet__c>();
        List<DH_Call_Center_Data_Sheet__c> callCenterHoursCcds = new List<DH_Call_Center_Data_Sheet__c>();
        //Map<DH_Call_Center_Data_Sheet__c,list<SObject>> ccdsVsNormalizedChildRecords= new Map<DH_Call_Center_Data_Sheet__c,list<SObject>>();
        for(DH_Call_Center_Data_Sheet__c ccds :  scope){
            if(ccds.recordTypeId==DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_Id){
                exclusionCcds.add(ccds);
            }
            else if(ccds.recordTypeId==DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_Id){
                modalityPriorityCcds.add(ccds);
            }
            else if(ccds.recordTypeId==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_Id){
                callCenterMappingCcds.add(ccds);
            }
            else if(ccds.recordTypeId==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_Id){
                callCenterHoursCcds.add(ccds);
            }
        }
        
        List<DH_Exclusions__c> exclusionToBeDeleted= [select Id,DH_CallCenterDataSheet__c FROM DH_Exclusions__c WHERE DH_CallCenterDataSheet__c IN :exclusionCcds  WITH SECURITY_ENFORCED];
        recordsTobeDeleted.addAll(exclusionToBeDeleted);
        if(exclusionToBeDeleted.size()>0 && Test.isRunningTest()!=true){
            System.enqueueJob(new DH_SendNormalizeDataQueue(0,null,exclusionToBeDeleted,null,System.label.DH_ExclusionAPIname,null));
        }  
        
        
        List<DH_Modality_Priority__c> modalityPriorityToBeDeleted= [select Id,DH_CallCenterDataSheet__c FROM DH_Modality_Priority__c WHERE DH_CallCenterDataSheet__c IN :modalityPriorityCcds  WITH SECURITY_ENFORCED];
        recordsTobeDeleted.addAll(modalityPriorityToBeDeleted);
        if(modalityPriorityToBeDeleted.size()>0 && Test.isRunningTest()!=true){
            System.enqueueJob(new DH_SendNormalizeDataQueue(0,null,modalityPriorityToBeDeleted,null,System.label.DH_ModalityPriorityAPIname,null));
            
        }    
        
        
        List<DH_Call_Center_Mapping__c> callCenterMappingToBeDeleted= [SELECT id,DH_CallCenterDataSheet__c FROM DH_Call_Center_Mapping__c where DH_CallCenterDataSheet__c IN :callCenterMappingCcds  WITH SECURITY_ENFORCED];
        recordsTobeDeleted.addAll(callCenterMappingToBeDeleted);
        if(callCenterMappingToBeDeleted.size()>0 && Test.isRunningTest()!=true){
            System.enqueueJob(new DH_SendNormalizeDataQueue(0,null,callCenterMappingToBeDeleted,null,System.label.DH_CallCenterMappingAPIname,null));
            
        } 
        
        List<DH_Call_Center_Hours__c> callCenterHoursToBeDeleted= [select Id,DH_CallCenterDataSheet__c FROM DH_Call_Center_Hours__c WHERE DH_CallCenterDataSheet__c IN :callCenterHoursCcds  WITH SECURITY_ENFORCED];
        recordsTobeDeleted.addAll(callCenterHoursToBeDeleted );
        if(callCenterHoursToBeDeleted.size()>0 && Test.isRunningTest()!=true){
            System.enqueueJob(new DH_SendNormalizeDataQueue(0,null,callCenterHoursToBeDeleted,null,System.label.DH_CallCenterHoursAPIname,null));
            
        } 

        Savepoint sp = Database.setSavepoint();
        try{
            delete recordsToBeDeleted;
            delete scope;
        }
        catch(Exception e){
            failedCcdsParentVsrecordsToBeDeleted.put(scope[0],recordsToBeDeleted);
            System.debug('exception occured ' + e);
            Database.rollback(sp);
        }       
    }
    
    /**
	* @param  Database.BatchableContext, 
	* @description finish method for batch
	**/
    global void finish(Database.BatchableContext bc) {
        List<DH_Call_Center_Data_Sheet__c> failedCcdsList = new List<DH_Call_Center_Data_Sheet__c>();
        for(DH_Call_Center_Data_Sheet__c failedCcds : failedCcdsParentVsrecordsToBeDeleted.keySet()){
            failedCcds.DH_Error_Log__c = 'Error occured while deleting the record';
            failedCcdsList.add(failedCcds);
        }
        try{
            update failedCcdsList;
        }
        catch(Exception ex){
            System.debug('Final Error while updating error in failed delete operation: ' + ex);
        }
    }
}