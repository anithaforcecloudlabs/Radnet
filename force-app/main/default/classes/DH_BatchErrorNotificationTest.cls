/*
* ***************************************************************************************************************************
* Apex Class Name : DH_BatchErrorNotificationTest
* Created Date : 14-August-2024 
* @description : Test class for DH_BatchErrorNotification
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-520                 14-August-2024       Original Version
* CC-1203				 17-September-2024	  Updated Test method related to profile change.
* ************************************************************************************************************************************
*/
@isTest
public class DH_BatchErrorNotificationTest {
	@TestSetup
	static void makeData(){
		User radnetBatchSchedulerUser = DH_TestDataFactory.createRadNetBatchSchedulerUser();
		List<DH_ErrorCodeMapping__mdt> errorCodes = DH_ErrorCodeMapping__mdt.getAll().values();
		List<DH_PayloadData__c> payloadRecords = new List<DH_PayloadData__c>();
		for(DH_ErrorCodeMapping__mdt err : errorCodes){
			DH_PayloadData__c pRec = DH_TestDataFactory.createPayLoad(String.valueOf(err.DH_ErrorCode__c),err.DH_ServiceName__c);
			payloadRecords.add(pRec);
		}
		insert payloadRecords;
	}
	@isTest
	public static void testBatch(){
		User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);
        String cronExp = '0 48 * * * ?';
		System.runAs(radnetBatchSchedulerUser){
			Test.startTest();
			DH_BatchErrorNotificationScheduler scheduler = new DH_BatchErrorNotificationScheduler();
			String jobId = System.schedule('Schedule batch', cronExp, scheduler);
			Test.stopTest();
			System.assertNotEquals(null,jobId, 'Batch class is executed');
		}
    }
	@isTest
	public static void testBatchTest(){
		User radnetBatchSchedulerUser = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetbatchscheduler@radnet.com' LIMIT 1]; 
		DH_TestDataFactory.assignCCAdminPermissions(radnetBatchSchedulerUser);
		System.runAs(radnetBatchSchedulerUser){
			Test.startTest();
			String jobId = Database.executeBatch(new DH_BatchErrorNotification(),200);
			Test.stopTest();
			System.assertNotEquals(null,jobId, 'Batch class is executed');
		}
    }
}