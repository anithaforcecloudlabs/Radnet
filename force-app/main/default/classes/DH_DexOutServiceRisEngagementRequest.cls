/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServiceRisEngagementRequest
* Created Date : 30-August-2024 
* @description : Request wrapper for DH_DexOutServiceRisEngagement
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-491                   30-August-2024       Original Version
* ************************************************************************************************************************************
*/
public class DH_DexOutServiceRisEngagementRequest {
    public Map<String,EngagementInteraction> uniqueKeyVsEiMap{get;set;}
    public Set<String> batchIdSet{get;set;}
    public Set<String> emailIdSet{get;set;}
    public Set<String> jobIdSet{get;set;}
    public Set<String> subscriberIdSet{get;set;}
    public Map<String, List<List<EngagementInteraction>>> regionPatKeyVsEmailSmsMap {get;set;}
}