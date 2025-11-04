public class DH_SendNormalizeDataQueue implements Queueable,Database.AllowsCallouts{
    Public List<SObject> listToInsertUpdate = new List<SObject>();
    Public List<SObject> listToDelete = new List<SObject>();
    Public Integer sizeOfInsertUpdate=0;
    Public Integer sizeOfDelete=0;
    Public Integer totalSize=0;
    Public Integer counter=0;
    Public String objectName;
    Public String errorMessage=null;
    Public List<SObject> listOfFailedRecords = new List<SObject>();
    Public Integer sizeOfFailedRecords=0;
    public static Boolean doChainJob = true;

    public DH_SendNormalizeDataQueue(Integer counter,List<SObject> listToInsertUpdate,List<SObject> listToDelete,List<SObject> listOfFailedRecords,String objectName,String errorMessage){
        System.debug('constructor'+counter);
        this.counter=counter;
        this.listToInsertUpdate=(listToInsertUpdate!=null)?listToInsertUpdate:new List<SObject>{};
        this.listToDelete=(listToDelete!=null)?listToDelete:new List<SObject>{};
        this.sizeOfInsertUpdate=(listToInsertUpdate!=null)?listToInsertUpdate.size():0;
        this.sizeOfDelete=(listToDelete!=null)?listToDelete.size():0;
        this.totalSize=this.sizeOfInsertUpdate+this.sizeOfDelete;
        this.objectName=objectName;
        this.errorMessage=errorMessage;
        this.listOfFailedRecords=(listOfFailedRecords!=null)?listOfFailedRecords:new List<SObject>{};
        this.sizeOfFailedRecords=(listOfFailedRecords!=null)?listOfFailedRecords.size():0;
    }
    public void execute(QueueableContext context) {

        List<SObject> batchToProcess = new List<SObject>();
        System.debug('batch to process'+counter);
        System.debug('toatal size '+totalSize);
        
        if(counter<sizeOfInsertUpdate){
            Integer sizeLeft = sizeOfInsertUpdate-counter;
            System.debug('how much records ' + (counter+sizeLeft-1) +' '+ counter+1000 );
            for(Integer i=counter;i<=((1000>=sizeLeft)?(counter+sizeLeft)-1:(counter+1000));i++){
                batchToProcess.add(listToInsertUpdate[i]);
            }
            System.debug('processing insert update size : ' + batchToProcess.size());
            counter=counter+((1000>sizeLeft)?sizeLeft:1000);
            String successErrorMessage =DH_SendCallCenterDataSheetDatatoSFMC.sendDataToSFMC(batchToProcess, null, objectName);
            System.debug('message received '+successErrorMessage);
            if(successErrorMessage!='Success'){
                listOfFailedRecords.addAll(batchToProcess);
                System.debug('size of failed records'+listOfFailedRecords.size());
                
                if(errorMessage==null){
                    errorMessage=successErrorMessage;
                }
                System.debug('error message '+errorMessage);
            }
            if(doChainJob) {
                System.enqueueJob(new DH_SendNormalizeDataQueue(counter,listToInsertUpdate,listToDelete,listOfFailedRecords,objectName,errorMessage));
            }
            
        }
        else if(totalSize>counter){
            System.debug('processing insert delete');
            Integer tempCounter = counter-sizeOfInsertUpdate;
            Integer sizeLeft = sizeOfDelete-tempCounter;
            for(Integer i=tempCounter;i<=((1000>=sizeLeft)?(tempCounter+sizeLeft)-1:(tempCounter+1000));i++){
                batchToProcess.add(listToDelete[i]);
            }
            counter=counter+((1000>sizeLeft)?sizeLeft:1000);
            String successErrorMessage = DH_SendCallCenterDataSheetDatatoSFMC.sendDataToSFMC(null, batchToProcess, objectName);
            if(successErrorMessage!='Success'){
                listOfFailedRecords.addAll(batchToProcess);
                if(errorMessage!=null){
                    errorMessage=successErrorMessage;
                }
            }
            if(doChainJob){
                System.enqueueJob(new DH_SendNormalizeDataQueue(counter,listToInsertUpdate,listToDelete,listOfFailedRecords,objectName,errorMessage));
            }
            
        }
        else{
            System.debug('entering in the else');
            System.debug('size of failed records'+listOfFailedRecords.size());
            if(listOfFailedRecords.size()>0){
                System.debug('sending ==');
                updatePublishOnFail(listOfFailedRecords,objectName,errorMessage);
            }
        }
    }
    public static void updatePublishOnFail(List<SObject> listOfRecords,String objectName,String errorMessage){
        try{
            System.debug('entered in the update publish fail');
            System.debug('size========'+listOfRecords);
            if(listOfRecords!=null || listOfRecords.size()>0){
            List<DH_Call_Center_Data_Sheet__c> callcenterdatasheetrecords = fetchDenormalizeRecords(listOfRecords,objectName);
            for(DH_Call_Center_Data_Sheet__c callcenterdatasheet:callcenterdatasheetrecords){
                callcenterdatasheet.Published__c  = false;
                System.debug('error meesgae input '+errorMessage);
                callcenterdatasheet.DH_Error_Log__c = errorMessage;
                System.debug('published set to false');
                callcenterdatasheet.DH_isError__c = true;
            }
            if (Schema.sObjectType.DH_Call_Center_Data_Sheet__c.isUpdateable()) {
                update callcenterdatasheetrecords;
              }
            }
        }
        catch(Exception e){
            System.debug(e); 
        }
    }
    public static List<DH_Call_Center_Data_Sheet__c> fetchDenormalizeRecords(List<SObject> listOfRecords,String objectName){
        Set<id> callcenterdatasheetids = new Set<id>();
            if(objectName==System.label.DH_ExclusionAPIname){
                List<DH_Exclusions__c> exclusionlist=listOfRecords;
                for(DH_Exclusions__c exclusion:exclusionlist){
                    callcenterdatasheetids.add(exclusion.DH_CallCenterDataSheet__c);
                }
            }
            else if(objectName==System.label.DH_CallCenterHoursAPIname){
                List<DH_Call_Center_Hours__c> callcenterhourslist=listOfRecords;
                for(DH_Call_Center_Hours__c callcenterhours:callcenterhourslist){
                    callcenterdatasheetids.add(callcenterhours.DH_CallCenterDataSheet__c);
                }
            }
            else if(objectName==System.label.DH_CallCenterMappingAPIname){
                List<DH_Call_Center_Mapping__c> callcentermappinglist=listOfRecords;
                for(DH_Call_Center_Mapping__c callcentermapping:callcentermappinglist){
                    callcenterdatasheetids.add(callcentermapping.DH_CallCenterDataSheet__c);
                }
            }
            else if(objectName==System.label.DH_ModalityPriorityAPIname){
                List<DH_Modality_Priority__c> modalityprioritylist=listOfRecords;
                for(DH_Modality_Priority__c modalitypriority:modalityprioritylist){
                    callcenterdatasheetids.add(modalitypriority.DH_CallCenterDataSheet__c);
                }
            }
            return  [SELECT Id,DH_Last_Sync_Timestamp__c,Published__c,DH_Error_Log__c,DH_isError__c  from DH_Call_Center_Data_Sheet__c WHERE Id in :callcenterdatasheetids];
    }
}