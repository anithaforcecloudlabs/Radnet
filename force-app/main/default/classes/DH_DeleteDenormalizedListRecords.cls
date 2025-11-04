/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DeleteDenormalizedListRecords
* Version - 0.1
* Created Date - 
* Function - Batch to delete normalized records.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Prasanna Anjakar                               Intial version.
* *****************************************************************************************************************************
*/
public class DH_DeleteDenormalizedListRecords {
    
    public ApexPages.StandardSetController controller{get;set;}
    public ApexPages.StandardController stdController {get;set;}
    public static List<DH_Call_Center_Data_Sheet__c> selectedRecordsToBeDeleted = new List<DH_Call_Center_Data_Sheet__c>();
    public static List<DH_Call_Center_Data_Sheet__c> selectedRecords = new List<DH_Call_Center_Data_Sheet__c>();
    public static List<DH_Call_Center_Data_Sheet__c> selectedExclusions  = new List<DH_Call_Center_Data_Sheet__c>();
    public static List<DH_Call_Center_Data_Sheet__c> selectedModalityPriotity = new List<DH_Call_Center_Data_Sheet__c>();
    public static List<DH_Call_Center_Data_Sheet__c> selectedCallCenterMapping  = new List<DH_Call_Center_Data_Sheet__c>();
    public static List<DH_Call_Center_Data_Sheet__c> selectedCallCenterHours = new List<DH_Call_Center_Data_Sheet__c>();
       public String reportsURL{get; set; } 
           public String reportsURL2{get; set; } 

    /*public static boolean showEXTable {get;set;}
    public static boolean showMPTable {get;set;}
    public static boolean showCCMTable {get;set;}
    public static boolean showCCHTable {get;set;}
    public static boolean showNoSelectionMessage{get;set;}
    public static boolean showTable=true;*/

    /* Standard set constructor*/
    public DH_DeleteDenormalizedListRecords(ApexPages.StandardSetController setcontroller) {
            reportsURL = URL.getOrgDomainUrl()+ '/lightning/o/DH_Call_Center_Data_Sheet__c/list'; 
        this.controller = setcontroller;
        selectedRecordsToBeDeleted = getSelectedRecordsToBeDeleted();
    }
    public DH_DeleteDenormalizedListRecords(ApexPages.StandardController stdController) {
         //   reportsURL = URL.getSalesforceBaseUrl().toExternalForm()+ '/lightning/o/DH_Call_Center_Data_Sheet__c/list'; 
        reportsURL=URL.getOrgDomainUrl()+ '/lightning/o/DH_Call_Center_Data_Sheet__c/list';
        system.debug('urlll' + reportsURL);
        this.stdController = stdController;
    }
    public void publishSingleRecord(){
        
        DH_Call_Center_Data_Sheet__c ccds = (DH_Call_Center_Data_Sheet__c)stdController.getRecord();
        selectedRecordsToBeDeleted = new List<DH_Call_Center_Data_Sheet__c>{ccds};
        selectedRecordsToBeDeleted = getSelectedRecordsToBeDeleted();
    }
    public List<DH_Call_Center_Data_Sheet__c> getSelectedRecordsToBeDeleted(){
        if(controller!=null){
            selectedRecords= controller.getSelected();
        }
        if(stdController!=null){
            DH_Call_Center_Data_Sheet__c ccds = (DH_Call_Center_Data_Sheet__c)stdController.getRecord();
            selectedRecords= new List<DH_Call_Center_Data_Sheet__c>{ccds};
        }
        Set<Id> selectedRecordIdSet = new Set<Id>();
        for(DH_Call_Center_Data_Sheet__c ccds : selectedRecords){
            selectedRecordIdSet.add(ccds.Id);
        }
        selectedRecordsToBeDeleted = [Select RecordType.Name, Id,RecordTypeId ,DH_New_or_Re_Schedule__c, DH_Ref_Dr__c,DH_Ref_Group_Code__c,Published__c, DH_System__c, DH_Practice_Code__c, DH_Modality_Code_aka_Proc_Group_Code__c,DH_Site_Code_or_Call_Center_Code__c, DH_Fake_call_center_site_code__c,DH_Site_Code__c, DH_Procedure_Code__c, DH_Portal_Procedure_Group_Modality_Code__c,DH_iCode__c, DH_Carrier_Code__c,DH_Relative_Priority__c, DH_Description__c,DH_Notes_1__c, DH_Notes_2__c, DH_Specific_Date__c, DH_Day_of_Week__c, DH_Earliest_Time_for_RADAR_Outreach__c, DH_timezone__c, DH_Latest_Time_for_RADAR_Outreach__c, DH_URL1_to_give_RADAR__c,DH_URL2_to_give_RADAR__c, DH_URL3_to_give_RADAR__c, DH_URL4_to_give_RADAR__c,DH_URL5_to_give_RADAR__c, DH_Phone_Number_1__c, DH_Phone_Number_2__c, DH_Phone_Number_3__c,DH_Phone_Number_4__c, DH_Phone_Number_5__c, DH_Contact_Method__c, DH_ZIP__c from DH_Call_Center_Data_Sheet__c where Id in :selectedRecordIdSet order by RecordType.Name];
        if(selectedExclusions.isEmpty() && selectedModalityPriotity.isEmpty() && selectedCallCenterMapping.isEmpty() && selectedCallCenterHours.isEmpty()){
        for(DH_Call_Center_Data_Sheet__c ccds : selectedRecordsToBeDeleted){
            if(ccds.recordTypeId==DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_Id){
                selectedExclusions.add(ccds);
            }
            else if(ccds.recordTypeId==DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_Id){
                selectedModalityPriotity.add(ccds);
            }
            else if(ccds.recordTypeId==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_Id){
                selectedCallCenterMapping.add(ccds);
            }
            else if(ccds.recordTypeId==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_Id){
                selectedCallCenterHours.add(ccds);
            }
            
        }
    }
        return selectedRecordsToBeDeleted;
    }

  /*  public List<DH_Call_Center_Data_Sheet__c> getSelectedRecordsToBeDeleted(){
        return selectedRecordsToBeDeleted;
    }*/
    public List<DH_Call_Center_Data_Sheet__c> getSelectedExclusions(){
        return selectedExclusions;
    }
    public List<DH_Call_Center_Data_Sheet__c> getSelectedModalityPriotity(){
        return selectedModalityPriotity;
    }
    public List<DH_Call_Center_Data_Sheet__c> getSelectedCallCenterMapping(){
        return selectedCallCenterMapping;
    }
    public List<DH_Call_Center_Data_Sheet__c> getSelectedCallCenterHours(){
        return selectedCallCenterHours;
    }


    public PageReference  onDelete(){
        checkAndExecuteBatchJob(selectedRecordsToBeDeleted);
        return Page.DH_PublishMessageVFPage;
        
    }

    public void checkAndExecuteBatchJob(List<DH_Call_Center_Data_Sheet__c> selectedRecords){
        String pageMessage='';
        Boolean canRun = true;
        if(selectedRecords!=null && selectedRecords.size()>0){
            set<String> batchJobValidStatus = new set<String>{'Processing','Preparing','Queued','Holding'};
                String normalizationBatchClassId = [ SELECT Id FROM ApexClass WHERE Name = 'DH_BatchForNormalizedRecordDeletion' WITH SECURITY_ENFORCED LIMIT 1].Id;
            //Check for the current batch jobs being processed or queued
            AsyncApexJob[] jobs = [select id,ApexClassId from AsyncApexJob where status in:batchJobValidStatus AND JobType='BatchApex'];
            //If there are atleast one job running check its details
            if (jobs!=null && jobs.size()>0) {
                if(jobs.size() >= 5){
                    canRun = false;
                    pageMessage = 'Number of batch jobs enqueued are more than 5.Please wait for few minutes and retry later';
                }else{
                    for(AsyncApexJob aaj:jobs){
                        if(aaj.ApexClassId == normalizationBatchClassId){
                            canRun = false;
                            pageMessage = 'Delete batch already running.Please wait for few minutes and retry late';
                        }
                    }      
                }
            }
            else {
                canRun = true;
                pageMessage = 'Delete batch started successfully';
            }
        }
        if(canRun){ 
            DH_BatchForNormalizedRecordDeletion batchInstance = new DH_BatchForNormalizedRecordDeletion(selectedRecords);
            Database.executeBatch(batchInstance,1);
         
        }
        
    }
}