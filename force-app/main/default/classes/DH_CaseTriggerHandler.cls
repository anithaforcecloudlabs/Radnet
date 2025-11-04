/*
* ***************************************************************************************************************************
* Apex Class Name - DH_CaseTriggerHandler
* Created Date - 24-July-2024
* @description : Handler class for Case trigger.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ------------------------------
* CC-526                   24-July-2024         Added populateTriggerData and onBeforeInsert methods.
* *******************************************************************************************************************************************
*/
public class DH_CaseTriggerHandler extends TriggerHandler{
	private Case[] newCases;
	private Case[] oldCases;
	private Map<Id, Case> oldCaseMap;
	private Map<Id, Case> newCaseMap;
	/**
	* @Jira CC-526
    * @description - This method will override the populateTriggerData method of TriggerHandler class.
    * @param       - List<SObject>,List<SObject>,Map<Id, SObject>,Map<Id, SObject>
    * @return      - None
	**/
	protected override void populateTriggerData(
		List<SObject> oldSObjectsList, 
		List<SObject> newSObjectsList,
		Map<Id, SObject> oldSObjectsMap, 
		Map<Id, SObject> newSObjectsMap
	) {
		this.newCases = (Case[]) newSObjectsList;
		this.oldCases = (Case[]) oldSObjectsList;
		this.newCaseMap = (Map<Id, Case >) newSObjectsMap;
		this.oldCaseMap = (Map<Id, Case >) oldSObjectsMap;
	}
	/**
	* @Jira CC-526
    * @description - This method will override the onBeforeInsert method of TriggerHandler class.
    * @param       - None
    * @return      - None
	**/
	protected override void onBeforeInsert() {
		DH_CaseTriggerHepler.updateCaseSystemId(newCases);
	}
}