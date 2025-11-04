public with sharing class lwcPhysicianPreferenceUpdatesAPX {
    @AuraEnabled
    public static List<Related_Request__c> getPhysicianPreferenceUpdates(String risRequestId) {
        List<Related_Request__c> relatedRisRequests = [
            SELECT  Id,
                    Name,
                    AcrId__c, 
                    Contact_Fax__c,
                    Contact_Phone__c,
                    Contact_Phone_New__c,
                    Contact_Fax_New__c,
                    Description__c,
                    Email_Reports__c,
                    Email_Reports_New__c,
                    Image_Preference_Notes__c,
                    //Image_Preference_Notes_New__c,
                    PAP__c,
                    PAP_New__c,
                    Physician__c,
                    Physician__r.Name,
                    Physician__r.Physician_NPI__c,
                    PhysicianNPI__c,
                    Preferred_Reader__c,
                    Preferred_Reader_New__c,
                    RIS_Request__c,
                    RIS_Request__r.Type__c,
                    RIS_Request__r.ContactId__c,
                    RIS_Request__r.Account_Name__c,
                    Status__c,
                    Status_set__c,
                    Future_Practice_Location__c,
                    isDirect__c,
                    Contact_Email__c,
                    Contact_Email_New__c
            FROM    Related_Request__c 
            WHERE RIS_Request__c = :risRequestId
        ];
        return relatedRisRequests;
    }

    @AuraEnabled
    public static List<Related_Request__c> approvedAcrUpdates(List<Related_Request__c> relatedRisRequests, String status) {       
        List<AccountContactRelation> acrToUpdate = new   List<AccountContactRelation>();
        List<AccountContactRelation> acrToRemove = new   List<AccountContactRelation>();
        List<AccountContactRelation> acrToInsert = new   List<AccountContactRelation>();

        List<Related_Request__c> relatedToMoveList = new List<Related_Request__c>();
        for (Related_Request__c relatedRisRequest : relatedRisRequests) {
            if (status == 'Approve') {                 
                if (relatedRisRequest.RIS_Request__r.Type__c == 'Physician removed') {
                    AccountContactRelation acrRemove = new AccountContactRelation(  Id = relatedRisRequest.AcrId__c);
                    acrToRemove.add(acrRemove);
                }
                if (relatedRisRequest.RIS_Request__r.Type__c == 'Moving Physicians') {
                    relatedToMoveList.add(relatedRisRequest);
                }
                if (relatedRisRequest.RIS_Request__r.Type__c == 'Change Physician Details') {
                    AccountContactRelation acr = new AccountContactRelation(
                        Id = relatedRisRequest.AcrId__c,
                        Phone__c = relatedRisRequest.Contact_Phone_New__c,
                        FAX__c = relatedRisRequest.Contact_Fax_New__c,
                        //PAP__c = relatedRisRequest.PAP_New__c,
                        Preferred_Reader__c = relatedRisRequest.Preferred_Reader_New__c,
                        //Image_Preference_Notes__c = relatedRisRequest.Image_Preference_Notes_New__c,
                        Email_Reports__c = relatedRisRequest.Email_Reports_New__c,
                        Contact_Email__c = relatedRisRequest.Contact_Email_New__c
                    );

                    acrToUpdate.add(acr);
                }
               	/*if (relatedRisRequest.RIS_Request__r.Type__c == 'PAP Submission') {
                    AccountContactRelation acrPAP = new AccountContactRelation(
                        Id = relatedRisRequest.AcrId__c,
                        PAP__c = relatedRisRequest.PAP_New__c
                    );
                    acrToUpdate.add(acrPAP);
               	}*/

                if (relatedRisRequest.RIS_Request__r.Type__c == 'Add New Physician') {
                    acrToInsert.add(populateACRtoCreate(relatedRisRequest));
                }

                relatedRisRequest.Status__c = 'Approve';
            } else {
                relatedRisRequest.Status__c = 'Reject';
            }
        }
        if (!relatedToMoveList.isEmpty() && relatedToMoveList != null) {
            movePhysiciansToNewLocation(relatedToMoveList);
        }
        
        insert acrToInsert;
        update acrToUpdate;
        update relatedRisRequests;
        delete acrToRemove;
        return relatedRisRequests;
    }

    @AuraEnabled
    public static void movePhysiciansToNewLocation(List<Related_Request__c> relatedToMoveList) {
        List<AccountContactRelation> acrToRemove = new List<AccountContactRelation>();
        List<AccountContactRelation> acrToCreate = new List<AccountContactRelation>();
        List<Related_Request__c> directRelationToUpdate = new List<Related_Request__c>();
        Map<Id, Id> contactIdToAccountUpdate = new Map<Id, Id>();
        for (Related_Request__c relatedRisRequest : relatedToMoveList) {            
            if (relatedRisRequest.isDirect__c) {
                contactIdToAccountUpdate.put(relatedRisRequest.Physician__c, relatedRisRequest.Future_Practice_Location__c);
            } else {
                acrToRemove.add(new AccountContactRelation(Id = relatedRisRequest.AcrId__c));                
                acrToCreate.add(populateMoveACRtoCreate(relatedRisRequest));
            }
       }
       if (!contactIdToAccountUpdate.isEmpty() && contactIdToAccountUpdate != null) {
            updateContacts(contactIdToAccountUpdate);
       }
       
       insert acrToCreate;      
       delete acrToRemove;
    }

    private static AccountContactRelation populateACRtoCreate(Related_Request__c relatedRequest) {        
        AccountContactRelation acr = new AccountContactRelation (
            ContactId = Id.valueOf(relatedRequest.RIS_Request__r.ContactId__c),
            AccountId = Id.valueOf(relatedRequest.RIS_Request__r.Account_Name__c),
            Phone__c = relatedRequest.Contact_Phone_New__c,
            FAX__c = relatedRequest.Contact_Fax_New__c,
            //PAP__c = relatedRequest.PAP_New__c,
            Preferred_Reader__c = relatedRequest.Preferred_Reader_New__c,
            //Image_Preference_Notes__c = relatedRequest.Image_Preference_Notes_New__c,
            Email_Reports__c = relatedRequest.Email_Reports_New__c,
            Contact_Email__c = relatedRequest.Contact_Email__c
        );

        return acr;
    } 

    public static AccountContactRelation populateMoveACRtoCreate(Related_Request__c relatedRequest) {        
        AccountContactRelation acr = new AccountContactRelation (
            ContactId = Id.valueOf(relatedRequest.Physician__c),
            AccountId = Id.valueOf(relatedRequest.Future_Practice_Location__c),
            Phone__c = (relatedRequest.Contact_Phone_New__c != null ) ? relatedRequest.Contact_Phone_New__c : relatedRequest.Contact_Phone__c,
            FAX__c = (relatedRequest.Contact_Fax_New__c != null ) ?relatedRequest.Contact_Fax_New__c : relatedRequest.Contact_Fax__c,
            //PAP__c = relatedRequest.PAP_New__c,
            Preferred_Reader__c = (relatedRequest.Preferred_Reader_New__c != null ) ? relatedRequest.Preferred_Reader_New__c : relatedRequest.Preferred_Reader__c,
            //Image_Preference_Notes__c = (relatedRequest.Image_Preference_Notes_New__c != null ) ? relatedRequest.Image_Preference_Notes_New__c : relatedRequest.Image_Preference_Notes__c,
            Email_Reports__c = relatedRequest.Email_Reports_New__c                
        );
        return acr;
    } 

    public static void updateContacts(Map<Id, Id> contactIdToAccountUpdate) {
        List<Contact> getDirectContacts = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIdToAccountUpdate.keySet()];
        List<Contact> contactsToUpdate = new  List<Contact>();
        
        for (Id contactId : contactIdToAccountUpdate.keySet()) {
            contactsToUpdate.add(new Contact (Id =contactId, AccountId = contactIdToAccountUpdate.get(contactId)));
        }
        
        update contactsToUpdate;
    }   
    
}