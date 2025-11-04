/*
* ***************************************************************************************************************************
* Apex Class Name : DH_BatchCCAccountDeletionScheduler
* Created Date : 14-August-2024 
* @description : Contact Center scheduler class of DH_BatchCCAccountDeletion
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1170                  14-August-2024       Original Version
* ************************************************************************************************************************************
*/
global class DH_BatchCCAccountDeletionScheduler implements Schedulable{
	global void execute(SchedulableContext sc){
        DH_BatchSettings__mdt batchErrorNotification = DH_CustomMetadataDao.getBatchDetailsList('DH_BatchCCAccountDeletion');
        Double batchSize=200;
        if(batchErrorNotification.DH_BatchSize__c!= null){
            batchSize = batchErrorNotification.DH_BatchSize__c;
        }
        Database.executeBatch(new DH_BatchCCAccountDeletion(),Integer.valueOf(batchSize));
    }
}