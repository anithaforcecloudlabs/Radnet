/*
* ***************************************************************************************************************************
* Apex Class Name - DH_CaseTriggerHepler
* Created Date - 24-July-2024
* @description : Helper class for DH_CaseTriggerHandler.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ------------------------------
* CC-526                   24-July-2024         Added updateCaseSystemId method.
* *******************************************************************************************************************************************
*/
public class DH_CaseTriggerHepler {
    /**
	* @Jira CC-526
    * @description - This method will populate the System Id on the Case record based on the RIS Instance / RIS System of the related Account record.
    * @param       - List<Case>
    * @return      - None
	**/
	public static void updateCaseSystemId(List<Case> newCaseList){
		Map<Id,Id> accIdVsCaseIdMap = new Map<Id,Id>();
		List<Case> caseList = new List<Case>();
        Map<Id,String> caseIdVsAccRegionMap = new Map<Id,String>();
        if(newCaseList != null){
            for(Case caseRec : newCaseList){
                accIdVsCaseIdMap.put(caseRec.AccountId,caseRec.Id);
            }
        }
        if(accIdVsCaseIdMap != null && !accIdVsCaseIdMap.isEmpty()){
            for(Account acc : DH_ContactCenterCachingUtility.getAccountsMap(accIdVsCaseIdMap.keySet()).values()){
                caseIdVsAccRegionMap.put(accIdVsCaseIdMap.get(acc.Id),acc.Region__c);
            }
        }
        if(caseIdVsAccRegionMap != null && newCaseList != null && !caseIdVsAccRegionMap.isEmpty()){
            for(Case caseRec : newCaseList){
                caseRec.DH_SystemId__c = caseIdVsAccRegionMap.get(caseRec.Id);
            }
        }
	}
}