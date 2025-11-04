/*
* ***************************************************************************************************************************
* Apex Class Name : DH_BatchRisEngagementScheduler
* Created Date : 30-August-2024
* @description : Contact Center scheduler class of DH_BatchRisEngagement
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-491                  30-August-2024       Original Version
* ************************************************************************************************************************************
*/
global class DH_BatchRisEngagementScheduler implements Schedulable{
	global void execute(System.SchedulableContext sc){
        DH_BatchSettings__mdt batchRisEngagement = DH_CustomMetadataDao.getBatchDetailsList('DH_BatchRisEngagement');
        Double batchSize=200;
        if(batchRisEngagement.DH_BatchSize__c!= null){
            batchSize = batchRisEngagement.DH_BatchSize__c;
        }
        Database.executeBatch(new DH_BatchRisEngagement(),Integer.valueOf(batchSize));
    }
    /**
	* @Jira CC-491
    * @description - This method has the logic to run the batch class for every 1 hour.
    * @param       - None
    * @return      - None
    **/
    public static void scheduleMe() {
        String cronExp = System.Label.DH_BatchRisEngagementScheduleTime;
        DH_BatchRisEngagementScheduler sch = new DH_BatchRisEngagementScheduler();
        String jobID = System.schedule('Syncing data from HC to RIS', cronExp, sch);
    }
}