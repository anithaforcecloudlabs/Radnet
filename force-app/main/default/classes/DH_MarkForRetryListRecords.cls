public class DH_MarkForRetryListRecords {
	public ApexPages.StandardSetController controller { get; set; }
	public DH_MarkForRetryListRecords(ApexPages.StandardSetController setcontroller) {
		this.controller = setcontroller;
	}
	public void MarkForRetry() {
		List<DH_PayloadData__c> selectedRecords = new List<DH_PayloadData__c>();
		selectedRecords = controller.getSelected();
		if (selectedRecords != null && selectedRecords.size() > 0) {
			for (DH_PayloadData__c pld : selectedRecords) {
				pld.DH_AvailableForRetry__c = true;
			}
			update selectedRecords;
		}
	}
	public void startBatchNow() {
		list<ApexClass> classList = [SELECT id, Name FROM ApexClass WHERE Name = 'DH_RetryPayloadBatchClass' LIMIT 1];
		if (classList != null && !classList.isEmpty()) {
			list<AsyncApexJob> myBatchJobs = new List<AsyncApexJob>();
			myBatchJobs = [SELECT id FROM AsyncApexJob WHERE ApexClassId = :classList[0].id AND status = 'Processing' AND JobType = 'BatchApex']; //This query returns the jobs currently processing for the same class
			if (myBatchJobs == null || myBatchJobs.isEmpty()) {
				Map<Id, String> FailedRecord = new Map<Id, String>();
				DH_RetryPayloadBatchClass batchInstance = new DH_RetryPayloadBatchClass(1, FailedRecord, null);
				Database.executeBatch(batchInstance, 200);
			} else {
                String nextFireTime = String.valueOf(Datetime.now().minute() + 1)+' '+String.valueOf(Datetime.now().minute() + 1)+' '+String.valueOf(Datetime.now().hour())+' * * ?';
                DH_RetryPayloadBatchClass s = new DH_RetryPayloadBatchClass();
                System.schedule('DH_RetryPayloadBatch Job Will Start At ' + String.valueOf(Datetime.now()), nextFireTime, s);
			}
		}
	}
}