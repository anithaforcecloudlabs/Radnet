/*
* *****************************************************************************************************************************
* Apex Class Name - DH_PublishDenormalizedListRecords
* Version - 1.0
* Updated Date - 18-June-2024
* Code Coverage - 0%
* Function - This is an apex class for the publish list view button,It checks for the existing batch jobs and starts a new denormaliztion batch job
* *****************************************************************************************************************************
*/
public without sharing class DH_PublishDenormalizedListRecords {
    
    public ApexPages.StandardSetController controller{get;set;}
    public ApexPages.StandardController stdController {get;set;}
    /* Standard set constructor*/
    public DH_PublishDenormalizedListRecords(ApexPages.StandardSetController setcontroller) {
            this.controller = setcontroller;
        }
    public DH_PublishDenormalizedListRecords(ApexPages.StandardController stdController) {
            this.stdController = stdController;
    }
    /*This method is called on click of the publish button to start the batch job from list button*/
    public void CallUpdateStatus(){
        List<DH_Call_Center_Data_Sheet__c>selectedRecords = new List<DH_Call_Center_Data_Sheet__c>();
            selectedRecords= controller.getSelected();   
        	checkAndExecuteBatchJob(selectedRecords);
    }
     /*This method is called on click of the publish button on detail page to start the batch job*/
    public void publishSingleRecord(){
         DH_Call_Center_Data_Sheet__c ccds = (DH_Call_Center_Data_Sheet__c)stdController.getRecord();
        checkAndExecuteBatchJob(new List<DH_Call_Center_Data_Sheet__c>{ccds});
    }
    
    public void checkAndExecuteBatchJob(List<DH_Call_Center_Data_Sheet__c>selectedRecords){
        Boolean canRun = true;
            String pageMessage='';
            if(selectedRecords!=null && selectedRecords.size()>0){
                set<String> batchJobValidStatus = new set<String>{'Processing','Preparing','Queued','Holding'};
                String normalizationBatchClassId = [ SELECT Id FROM ApexClass WHERE Name = 'DH_BatchForNormalization' WITH SECURITY_ENFORCED LIMIT 1].Id;
                
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
                                 pageMessage = 'Published batch already running.Please wait for few minutes and retry late';
                            }
                        }      
                    }
                 }
                else {
                    canRun = true;
                    pageMessage = 'Published batch started successfully';
                    
                }
            }
        if(canRun){ 
                DenormalizationSettings__c cs = DenormalizationSettings__c.getInstance('BatchChunkSize');
                Integer chunkSize =  20;
                if(cs !=null){
                    chunkSize = (Integer)cs.BatchChunkSize__c;
                }
             
             DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(1,selectedRecords);
             batchInstanceNext.batchSize = chunkSize;
             Database.executeBatch(batchInstanceNext,chunkSize);
        }
        
             pagereference p = apexpages.Currentpage();
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, pageMessage);
			 apexpages.addmessage(msg);
             p.setRedirect(true);
        
    }
}