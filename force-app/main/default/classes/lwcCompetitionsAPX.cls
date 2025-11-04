public with sharing class lwcCompetitionsAPX {
    
    @AuraEnabled
    public static List<Account_Competition_Relationship__c> getCompetitions(string recordId){
        List<Account_Competition_Relationship__c> competitions = new List<Account_Competition_Relationship__c>();
            competitions = [
                SELECT Id, 
                Related_Account__c,
                Notes__c, 
                Preferred__c,
                Related_Competition__r.Address__PostalCode__s,
                Related_Competition__c, 
                Related_Competition__r.Name,
                Related_Competition__r.Address__c,
                Related_Competition__r.MR__c,
                Related_Competition__r.CT__c,
                Related_Competition__r.PETCT__c,
                Related_Competition__r.PETMR__c,
                Related_Competition__r.Status__c,
                Related_Competition__r.MR_Equipments__c,
                Related_Competition__r.CT_Equipment__c,
                Related_Competition__r.PETCT_Equipment__c,
                Related_Competition__r.PETMR_Equipment__c
                FROM Account_Competition_Relationship__c
                WHERE Related_Account__c =: recordId
            ];
        
        return competitions;
    }

    @AuraEnabled(cacheable=false)
    public static Boolean removeRelation(String recordIdToDelete){
        try{
            delete [SELECT Id FROM Account_Competition_Relationship__c WHERE Id = :recordIdToDelete];
            return true;
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            return false;
        }
    }

}