/*
* ***************************************************************************************************************************
* Apex Class Name - DH_VoiceCallTrigger
* Created Date - 24-July-2024
* @description       : Trigger for VoiceCall record.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ------------------------------
* CC-526                   24-July-2024         Added logic to call execute method of TriggerFactory class.
* *******************************************************************************************************************************************
*/
trigger DH_VoiceCallTrigger on VoiceCall (before insert, after insert, before update, after update) {
    TriggerFactory.execute(VoiceCall.getSObjectType()); 
}