public with sharing class LwcRelatedPhysiciansAPX {

    @AuraEnabled
    public static List<AccountContactRelation> getContacts(String recordId ) {
        List<AccountContactRelation> acrs = new List<AccountContactRelation>();
        RIS_Requests__c risRequests = [SELECT Id, Account_Name__c FROM RIS_Requests__c WHERE Id = :recordId];
        if (risRequests.Account_Name__c != null) {
            acrs =[
                SELECT  Id,
                        AccountId,
                        Account.Name,
                        Account.RecordType.DeveloperName,
                        ContactId,
                        Contact.RecordType.DeveloperName,
                        Contact.Name,
                        Contact.Physician_NPI__c,
                        Roles,
                        IsDirect,
                        IsActive,
                        FAX__c,
                        Phone__c,
                        Contact_Email__c,
                        Contact.PAP__c,
                        Contact.Budget_Spent__c,
                        Fax_Reports__c,
                        Mail_Reports__c,
                        Reports_Email_Address__c,
                        Image_Preference_Notes__c,
                        Preferred_Reader__c
                FROM    AccountContactRelation
                WHERE   AccountId =: risRequests.Account_Name__c
                AND     Contact.RecordType.DeveloperName = 'Physicians'
                ORDER BY Contact.CreatedDate DESC
                LIMIT 50
            ];
        }
        system.debug('acrs ' + acrs);
        return acrs;
    }

    @AuraEnabled
    public static Integer getContactsCount(Id recordId ) {
        RIS_Requests__c request = [SELECT Id, Account_Name__c FROM RIS_Requests__c WHERE Id = :recordId];
        Integer contactCount = 0;

        if (request.Account_Name__c != null) {
            contactCount = [
                SELECT  COUNT()
                FROM    AccountContactRelation
                WHERE   AccountId =: request.Account_Name__c
                AND     Contact.RecordType.DeveloperName = 'Physicians'
            ];
        }

        return contactCount;
    }

}