public with sharing class LwcRelatedCasesAPX {
    @AuraEnabled
    public static List<Case> getRelatedRisRequestAPX(String accountId, String caseId){
        List<Case> listRelatedRisRequests = new List<Case>();
        if(accountId != null && accountId != ''){
            listRelatedRisRequests = [
                SELECT  Id, AccountId, Account.Name,Type, Status, ContactId, Contact.Name, Contact.AccountId, Reason, Subject, CreatedDate, CaseNumber
                FROM    Case
                WHERE   status NOT IN ('Complete', 'Rejected')
                AND (AccountId= :accountId  OR  Contact.AccountId =:accountId)
                AND Id != :caseId
               
            ];
        }
        return listRelatedRisRequests;
    }
    @AuraEnabled
    public static List<Case> handleCloseRisRequestAPX(List<String> caseIds){
        List<Case> listRelatedRisRequests = new List<Case>();
        if(caseIds.size() > 0){
            listRelatedRisRequests = [
                SELECT  Id, Status, ContactId, Contact.Name, Contact.AccountId, Reason, Subject, CreatedDate, CaseNumber
                FROM    Case
                WHERE   Id IN :caseIds
               
            ];
            for (Case caserecord : listRelatedRisRequests) {
                caserecord.Status ='Complete'; 
            }
            update listRelatedRisRequests;
        }
        return listRelatedRisRequests;
    }
    @AuraEnabled
    public static List<Case> handleInReviewRisRequestAPX(List<String> caseIds){
        List<Case> listRelatedRisRequests = new List<Case>();
        if(caseIds.size() > 0){
            listRelatedRisRequests = [
                SELECT  Id, Status, ContactId, Contact.Name, Contact.AccountId, Reason, Subject, CreatedDate, CaseNumber
                FROM    Case
                WHERE   Id IN :caseIds
               
            ];
            for (Case caserecord : listRelatedRisRequests) {
                caserecord.Status ='In Review'; 
            }
            update listRelatedRisRequests;
        }
        return listRelatedRisRequests;
    }
    
    
}