public with sharing class LwcRelatedRisRequestApx {
    @AuraEnabled
    public static List<RIS_Requests__c> getRelatedRisRequestAPX(String accountId, String caseId){
        List<RIS_Requests__c> listRelatedRisRequests = new List<RIS_Requests__c>();
        if(accountId != null && accountId != ''){
            listRelatedRisRequests = [
                SELECT  Id, 
                        Account_Name__c,
                        Account_Name__r.Name,
                        Type__c, Status__c,
                        Reason_for_rejection__c,
                        ContactId__c,
                        ContactId__r.Name,
                        ContactId__r.AccountId,
                        Subject__c,
                        CreatedDate,
                        Name
                FROM    RIS_Requests__c
                WHERE   Status__c NOT IN ('Closed', 'Rejected')
                AND (Account_Name__c = :accountId  OR  ContactId__r.AccountId =:accountId)
                AND Id != :caseId
               
            ];
        }
        return listRelatedRisRequests;
    }
    @AuraEnabled
    public static List<RIS_Requests__c> handleCloseRisRequestAPX(List<String> caseIds){
        List<RIS_Requests__c> listRelatedRisRequests = new List<RIS_Requests__c>();
        if(caseIds.size() > 0){
            listRelatedRisRequests = [
                SELECT  Id, Status__c, ContactId__c, ContactId__r.Name, Reason_for_rejection__c, ContactId__r.AccountId, Subject__c, CreatedDate, Name
                FROM    RIS_Requests__c
                WHERE   Id IN :caseIds
               
            ];
            for (RIS_Requests__c caserecord : listRelatedRisRequests) {
                caserecord.Status__c ='Closed'; 
            }
            update listRelatedRisRequests;
        }
        return listRelatedRisRequests;
    }
    @AuraEnabled
    public static List<RIS_Requests__c> handleInReviewRisRequestAPX(List<String> caseIds){
        List<RIS_Requests__c> listRelatedRisRequests = new List<RIS_Requests__c>();
        if(caseIds.size() > 0){
            listRelatedRisRequests = [
                SELECT  Id, Status__c, ContactId__c, ContactId__r.Name, ContactId__r.AccountId, Reason_for_rejection__c, Subject__c, CreatedDate, Name
                FROM    RIS_Requests__c
                WHERE   Id IN :caseIds
               
            ];
            for (RIS_Requests__c caserecord : listRelatedRisRequests) {
                caserecord.Status__c ='In Review'; 
            }
            update listRelatedRisRequests;
        }
        return listRelatedRisRequests;
    }
    
}