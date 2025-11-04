/******************************************************************************************************************************************************
 *
 * @Created Date    :  09-September-2024
 * @description     : DH_MarkForRetryListRecordsTest test class for DH_MarkForRetryListRecords.
 * @Jira Id         : CC-355
 * ****************************************************************************************************************************************************/
@isTest
public class DH_MarkForRetryListRecordsTest {
    @TestSetup
    static void setup(){
        Profile managerProfile = [SELECT Id FROM Profile WHERE Name = 'Radnet Manager' LIMIT 1];
		User radNetScheduler = new User(Alias = 'rsWest', Email = 'radSchWest@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'TestingWest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = managerProfile.Id, TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, FederationIdentifier = 'radSch34@torg.com', UserName = 'radSch34@torg.com');
		insert radNetScheduler;
		System.runAs(radNetScheduler){
            List<DH_PayloadData__c> pldRecordsList = new List<DH_PayloadData__c>();
            for(Integer i=0; i<5;i++){
                DH_PayloadData__c pld = new DH_PayloadData__c();
                pld.DH_PatientKey__c ='12345'+ i;
                pld.DH_OrderKey__c='12345'+ i;
                pld.DH_StudyKey__c = '12345'+ i;
                pld.DH_SystemId__c ='CA';
                pld.DH_Status__c = 'Fail';
                pld.DH_Processed__c = false;
                pld.DH_AvailableForRetry__c = false;
                pldRecordsList.add(pld);
            }
            Insert pldRecordsList;
        }
    }
    @isTest
    static void MarkForRetryTest(){
        User radNetScheduler = [SELECT ID, Username FROM USER WHERE Email LIKE 'radSchWest@testorg.com' LIMIT 1];
        List<DH_PayloadData__c> pldRecords = [SELECT Id, DH_AvailableForRetry__c FROM DH_PayloadData__c LIMIT 5];
        System.runAs(radNetScheduler){
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(pldRecords);
            setController.setSelected(pldRecords);
            DH_MarkForRetryListRecords retry = new DH_MarkForRetryListRecords(setController);

            Test.startTest();
            retry.MarkForRetry();
            Test.stopTest();
            List<DH_PayloadData__c> updatedPayloadData = [SELECT Id, DH_AvailableForRetry__c FROM DH_PayloadData__c WHERE Id IN :pldRecords];
            System.assertEquals(5, updatedPayloadData.size(), 'All records should mark as Available for Retry');
        }
    }
    @isTest
    static void startBatchNowTest(){
        User radNetScheduler = [SELECT ID, Username FROM USER WHERE Email LIKE 'radSchWest@testorg.com' LIMIT 1];
        List<DH_PayloadData__c> pldRecords = [SELECT Id, DH_AvailableForRetry__c FROM DH_PayloadData__c LIMIT 5];
        System.runAs(radNetScheduler){
            Test.startTest();
            Map<Id, String> failedRecords = new Map<Id, String>();
            DH_RetryPayloadBatchClass batchJob = new DH_RetryPayloadBatchClass(1, failedRecords, null);
            Database.executeBatch(batchJob, 200);

            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(pldRecords);
            DH_MarkForRetryListRecords retry = new DH_MarkForRetryListRecords(setController);
            retry.startBatchNow();
            Test.stopTest();
            ApexClass retryBatchClass = [SELECT Id FROM ApexClass WHERE Name = 'DH_RetryPayloadBatchClass' LIMIT 1];
            List<AsyncApexJob> activeJobs = [SELECT Id FROM AsyncApexJob WHERE ApexClassId = :retryBatchClass.Id AND Status = 'Processing' AND JobType = 'BatchApex'];
            System.assert(true, 'an active batch is job processing.');
        }
    }
}