/*
* ***************************************************************************************************************************
* Apex Class Name : DH_PatientEngagementController
* Created Date : 30-Jul-2024
* @description : Controller class for dH_PatientEngagement
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       ---------------------
* CC-702                   30-Jul-2024          Added getPatientEngagement and getPatientEngagementList method
* ************************************************************************************************************************************
*/
public without sharing class DH_PatientEngagementController {  

    /**
    * @Jira CC-702
    * @description - This method returns engagement list for quick message based on patient key and system id.
    * @param       - String,String
    * @return      - List<DH_DexOutServiceEngagementResponse>
    **/
    @AuraEnabled
    public static String getPatientEngagementList(String patId) {
        List<DH_DexOutServiceEngagementResponse> engagementList = new List<DH_DexOutServiceEngagementResponse>();
        Set<Id> patSet = new Set<Id>();
        Map<Id, Account> patMap = new Map<Id, Account>();
        if(patId !=null){
            patSet.add(patId);
        }
        List<Account> accountList = new List<Account>();
        if(patSet !=null){
            try{
                accountList = [SELECT Id,Region__c,DH_Patient_Key__c FROM Account WHERE id in: patSet WITH SECURITY_ENFORCED];
            }catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
        if(accountList.size()>0 && !accountList.isEmpty()){
            for(Account acc : accountList){
                if(acc.id !=null && !patMap.containsKey(acc.id)){
                    patMap.put(acc.id,acc);
                }
            }
        }
        if(patMap != null && !patMap.isEmpty() && patId !=null && patMap.containsKey(patId)){
            DH_DexoutServiceEngagementRequest engageRequest = new DH_DexoutServiceEngagementRequest();
            engageRequest.patientKey = patMap.get(patId).DH_Patient_Key__c;
            engageRequest.systemId = patMap.get(patId).Region__c;
            engageRequest.recordId = patMap.get(patId).id;
           // engagementList =  DH_DexOutServicePatientEngagement.invokePatientEngagementApi(engageRequest);
            engagementList = DH_DexOutServicePatientEngagementParser.getEngagementData(engagementList,patId);
        }
        return Json.serialize(engagementList);
    }
}