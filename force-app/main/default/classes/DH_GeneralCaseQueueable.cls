/*
 * *****************************************************************************************************************************
 * Apex Helper Class Name : DH_GeneralCaseQueueable
 * Created Date : 07-Aug-2024
 * @description : Generic queueable class for updating Cases which are created while API Service Down
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Developer                Date                 Description
 * ----------------         --------------       ---------------------
 *
 * CC- 572                  07-Aug-2024          Added DH_GeneralUtility.updateServiceDownCase method
 * CC-572					12-Aug-2024			 Added updateServiceDownCase method
 * *****************************************************************************************************************************
 */
public without sharing class DH_GeneralCaseQueueable implements Queueable {
	Id accountId;
	Id voiceCallId;

	public DH_GeneralCaseQueueable(Id accountId, Id voiceCallId) {
		this.accountId = accountId;
		this.voiceCallId = voiceCallId;
	}

	public void execute(QueueableContext context) {
		if (accountId != null && voiceCallId != null) {
			DH_GeneralUtility.createContactCenterCase(accountId, voiceCallId);
		}
	}
}