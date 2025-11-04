/*
* ***************************************************************************************************************************
* Apex Class Name - DH_VoiceCallTriggerHandler
* Created Date - 24-July-2024
* @description : Handler class for VoiceCall trigger.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ------------------------------
* CC-526                   24-July-2024         Added populateTriggerData and onAfterInsert methods.
* CC-691                   23-Aug-2024          Added function call to publishEventOnDispositionChage in onAfterUpdate.
* CC-692                   02-September         Added updatePreviousVoiceCallRecord and udpateTransferredVoiceCall function call and update onAfterUpdate and onBeforeUpdate event
* *******************************************************************************************************************************************
*/
public without sharing class DH_VoiceCallTriggerHandler extends TriggerHandler{
    private VoiceCall[] newVoiceCall;
    private VoiceCall[] oldVoiceCall;
    private Map<Id, VoiceCall> oldVoiceCallMap;
    private Map<Id, VoiceCall> newVoiceCallMap;
    /**
	* @Jira CC-526
    * @description - This method will override the populateTriggerData of the TriggerHandler class.
    * @param       - List<SObject>,List<SObject>,Map<Id, SObject>,Map<Id, SObject>
    * @return      - None
	**/
    protected override void populateTriggerData(
        List<SObject> oldSObjectsList, 
        List<SObject> newSObjectsList,
        Map<Id, SObject> oldSObjectsMap, 
        Map<Id, SObject> newSObjectsMap
    ) {
        this.newVoiceCall = (VoiceCall[]) newSObjectsList;
        this.oldVoiceCall = (VoiceCall[]) oldSObjectsList;
        this.newVoiceCallMap = (Map<Id, VoiceCall >) newSObjectsMap;
        this.oldVoiceCallMap = (Map<Id, VoiceCall >) oldSObjectsMap;
    }
    /**
	* @Jira CC-526, 691
    * @description - This method will override the onAftreInsert method of TriggerHandler class 
    * 				 (691) And will call the method to publish the platform event close the voice call record along withit subtabs.
    * @param       - List<VoiceCall>
    * @return      - None
	**/
    protected override void onBeforeUpdate() {
        DH_VoiceCallTriggerHepler.updatePhoneFormat(newVoiceCall);              
        DH_VoiceCallTriggerHepler.createVoiceCallShareRecord(newVoiceCall,oldVoiceCallMap);
        DH_VoiceCallTriggerHepler.udpateTransferredVoiceCall(this.oldVoiceCallMap,this.newVoiceCallMap);
    }
    
    protected override void onAfterUpdate() {
        DH_VoiceCallTriggerHepler.invokeCloseTabEvent(this.oldVoiceCallMap,this.newVoiceCallMap);     
        DH_VoiceCallTriggerHepler.updatePreviousVoiceCallRecord(this.oldVoiceCallMap,this.newVoiceCallMap);
    }
}