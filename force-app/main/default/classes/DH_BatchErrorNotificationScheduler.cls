/*
* ***************************************************************************************************************************
* Apex Class Name - DH_BatchErrorNotificationScheduler
* Created Date - 27-May-2024
* @description       : Contact Center scheduler class of DH_BatchErrorNotification
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-520                   08-Aug-2024          Original version
* *******************************************************************************************************************************************
*/
global class DH_BatchErrorNotificationScheduler implements Schedulable{
	global void execute(SchedulableContext sc){
        DH_BatchSettings__mdt batchErrorNotification = DH_CustomMetadataDao.getBatchDetailsList('DH_BatchErrorNotification');
        Double batchSize=200;
        if(batchErrorNotification.DH_BatchSize__c!= null){
            batchSize = batchErrorNotification.DH_BatchSize__c;
        }
        Database.executeBatch(new DH_BatchErrorNotification(),Integer.valueOf(batchSize));
    }
}