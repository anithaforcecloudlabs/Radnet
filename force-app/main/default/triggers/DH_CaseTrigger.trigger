/*
* ***************************************************************************************************************************
* Apex Trigger Name - DH_CaseTrigger
* Created Date - 24-July-2024
* @description : Trigger for Case object.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ------------------------------
* CC-526                   24-July-2024         Added logic to call execute method of TriggerFactory.
* *******************************************************************************************************************************************
*/
trigger DH_CaseTrigger on Case (before insert, before update, after insert, after update) {
    TriggerFactory.execute(Case.getSObjectType());
}