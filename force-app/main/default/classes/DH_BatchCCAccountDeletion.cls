/*
 * ***************************************************************************************************************************
 * Apex Class Name : DH_BatchCCAccountDeletion
 * Created Date : 14-August-2024
 * @description : Contact Center batch class for dormant account deletion.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-1170                  14-August-2024       This batch apex Deletes the person Account Records whose status as Draft 
 * ************************************************************************************************************************************
 */
global class DH_BatchCCAccountDeletion implements Database.Batchable<SObject> {
	global Database.QueryLocator start(Database.BatchableContext bc) {
		DH_BatchSettings__mdt batchCCAccountDeletion = DH_CustomMetadataDao.getBatchDetailsList('DH_BatchCCAccountDeletion');
		String condition = batchCCAccountDeletion.DH_WhereCondition1__c;
		String recordtypeid = DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
		String query = 'SELECT Id FROM Account WHERE ' + condition + ' AND RecordTypeId = \'' + recordtypeid + '\'';
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext bc, List<Account> scope) {
		DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
		//Logic for account deletion based on scope.
		if (!scope.isEmpty()) {
			try {
				List<DH_PayloadData__c> payloadDataList = new List<DH_PayloadData__c>();
				Database.DeleteResult[] ccDeletionAccounts = Database.delete(scope, false);
				for (Integer i = 0; i < ccDeletionAccounts.size(); i++) {
					Database.DeleteResult deleteResult = ccDeletionAccounts[i];
					if (!deleteResult.isSuccess()) {
						DH_PayloadData__c payloadData = new DH_PayloadData__c();
						payloadData.DH_RelatedTo__c = ccDeletionAccounts[i].id;
						payloadData.DH_Status__c = DH_GlobalConstants.SUCCESS;
						payloadDataList.add(payloadData);
					}
				}
				if (!payloadDataList.isEmpty()) {
					Database.insert(payloadDataList, false);
				}
			} catch (Exception e) {
				logWrapper.Exp = e;
				logWrapper.ClassName = DH_BatchCCAccountDeletion.class.getName();
				DH_DexLoggingUtility.createLogRecord(logWrapper);
			}
		}
	}

	global void finish(Database.BatchableContext bc) {
	}
}