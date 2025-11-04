@isTest
public with sharing class lwcPhysicianPreferenceUpdatesAPX_TEST {
    
    public static final Id PRACTICE_LOCATION = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Location').getRecordTypeId();
    public static final Id PHYSICIANS = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physicians').getRecordTypeId();

    @testSetup
    static void setup() {
        User currentUser = new User(Id = UserInfo.getUserId(), RIS_Data_Manager__c = true);
        update currentUser;

        System.runAs(currentUser) {
            Account practice1 = new Account(
                Name = 'TestAcc',
                RecordTypeId = PRACTICE_LOCATION
            );
            Account practice2 = new Account(
                Name = 'TestAcc2',
                ShippingCity = 'New York',
                ShippingStreet = '645 10th Avenue',
                ShippingState = 'NY',
                ShippingPostalCode = '10036',
                RecordTypeId = PRACTICE_LOCATION
            );
            Account practice3 = new Account(
                Name = 'TestAcc3',
                RecordTypeId = PRACTICE_LOCATION
            );
    
            insert new List <Account> {
                practice1,
                practice2,
                practice3
            };
    
            Contact contactPracticeDirect = new Contact(
                AccountId = practice1.Id,
                LastName = 'TestCont',
                RecordTypeId = PHYSICIANS
            );
            Contact contactPracticeDirect2 = new Contact(
                AccountId = practice2.Id,
                LastName = 'TestSecCont1',
                RecordTypeId = PHYSICIANS
            );
            Contact contactPractice2 = new Contact(
                AccountId = practice2.Id,
                LastName = 'TestSecCont2',
                RecordTypeId = PHYSICIANS
            );
            Contact contactPractice3 = new Contact(
                AccountId = practice3.Id,
                LastName = 'TestSecCont3',
                RecordTypeId = PHYSICIANS
            );
            Contact contactPractice4 = new Contact(
                AccountId = practice3.Id,
                LastName = 'TestSecCont4',
                RecordTypeId = PHYSICIANS
            );
    
            Contact contactPractice5 = new Contact(
                AccountId = practice3.Id,
                LastName = 'TestSecCont5',
                RecordTypeId = PHYSICIANS
            );
    
            insert new List <Contact> {
                contactPracticeDirect,
                contactPracticeDirect2,
                contactPractice2,
                contactPractice3,
                contactPractice4,
                contactPractice5
            };
    
            AccountContactRelation acr1 = new AccountContactRelation(
                AccountId = practice2.Id,
                ContactId = contactPractice3.Id
            );
            insert acr1;
    
            AccountContactRelation acr2 = new AccountContactRelation(
                AccountId = practice2.Id,
                ContactId = contactPractice4.Id,
                Email_Reports__c = true,
                Mail_Reports__c = false
            );
            insert acr2;
    
            AccountContactRelation acr3 = new AccountContactRelation(
                AccountId = practice1.Id,
                ContactId = contactPractice4.Id,
                Email_Reports__c = true
            );
            insert acr3;
    
            AccountContactRelation acr4 = new AccountContactRelation(
                AccountId = practice3.Id,
                ContactId = contactPractice2.Id,
                Email_Reports__c = true
            );
            insert acr4;
            
            RIS_Requests__c newRisRequest = new RIS_Requests__c (
                Status__c = 'New',
                Account_Name__c= practice3.Id,
                Type__c ='Change Physician Details'
            );
            insert newRisRequest;
    
            
            Related_Request__c relatedRisRequest = new Related_Request__c(
                AcrId__c = acr4.Id,
                RIS_Request__c = newRisRequest.Id,
                Contact_Phone_New__c ='7778889998',
                isDirect__c = true
            );
            
            Related_Request__c relatedRisRequest2 = new Related_Request__c(
                AcrId__c = acr3.Id,
                RIS_Request__c = newRisRequest.Id,
                Contact_Phone_New__c ='7778889998',
                isDirect__c = false
            );
            insert relatedRisRequest;        
               //move
            List<AccountContactRelation> updatesOnAcrs = getAcrsToUpdate(practice3.Id);
            RIS_Requests__c newRisRequestMove = new RIS_Requests__c (
                Status__c = 'New',
                Account_Name__c= practice3.Id,
                Type__c ='Moving Physicians',
                Subject__c ='Moving Physicians'
            );
            insert newRisRequestMove;        
            
            List<Related_Request__c> risRequestUpdates = new List<Related_Request__c>();
            for (AccountContactRelation acr : updatesOnAcrs) {
                Related_Request__c addRR = new Related_Request__c(
                AcrId__c = acr.Id,
                Physician__c = acr.ContactId,
                RIS_Request__c = newRisRequestMove.Id,
                Contact_Phone_New__c ='7778889998',
                Future_Practice_Location__c = practice1.Id, 
                isDirect__c = acr.isDirect
            );
                risRequestUpdates.add(addRR);
            }
            insert risRequestUpdates;
            
            
            RIS_Requests__c newRisRequest3 = new RIS_Requests__c (
                Status__c = 'New',
                Account_Name__c= practice3.Id,
                Type__c ='PAP Submission'
            );
            insert newRisRequest3;
            Related_Request__c relatedRisRequest31 = new Related_Request__c(
                AcrId__c = acr4.Id,
                RIS_Request__c = newRisRequest3.Id,
                Contact_Phone_New__c ='7778889998',
                PAP_New__c = true
            );
            insert relatedRisRequest31;
        }
       
    }

    @IsTest
    private static void getRelatedRecords() {
        User currentUser = new User(Id = UserInfo.getUserId(), RIS_Data_Manager__c = true);

        test.startTest();
        System.runAs(currentUser) {
            RIS_Requests__c risRequest = [SELECT Id, Name FROM RIS_Requests__c LIMIT 1];
            List<Related_Request__c> getRElated = lwcPhysicianPreferenceUpdatesAPX.getPhysicianPreferenceUpdates(risRequest.Id);
            List<Related_Request__c> approveUpdates  = lwcPhysicianPreferenceUpdatesAPX.approvedAcrUpdates( getRElated, 'Approve');
        }
        test.stopTest();
    }
    
    @isTest
    private static void moveLocationApprove() {
        User currentUser = new User(Id = UserInfo.getUserId(), RIS_Data_Manager__c = true);

        test.startTest();
        System.runAs(currentUser) {
            List<Related_Request__c> risRequestUpdates = getPhysicianPreferenceUpdates('Moving Physicians');       
            List<Related_Request__c> approveUpdates  = lwcPhysicianPreferenceUpdatesAPX.approvedAcrUpdates( risRequestUpdates, 'Approve');
            List<Related_Request__c> rejectUpdates  = lwcPhysicianPreferenceUpdatesAPX.approvedAcrUpdates( risRequestUpdates, 'Reject');
        }
        test.stopTest();
    }
    
    @isTest
    private static void submissionPAPApprove() {
        User currentUser = new User(Id = UserInfo.getUserId(), RIS_Data_Manager__c = true);

        test.startTest();
        System.runAs(currentUser) {
            List<Related_Request__c> risRequestUpdates = getPhysicianPreferenceUpdates('PAP Submission');       
            List<Related_Request__c> approveUpdates  = lwcPhysicianPreferenceUpdatesAPX.approvedAcrUpdates( risRequestUpdates, 'Approve');
            List<Related_Request__c> rejectUpdates  = lwcPhysicianPreferenceUpdatesAPX.approvedAcrUpdates( risRequestUpdates, 'Reject');
        }
        test.stopTest();
    }
    
     public static List <AccountContactRelation> getAcrsToUpdate(Id accountId) {
        return [
            SELECT 	Id,
                    AccountId,
                    ContactId,
            		Contact.AccountId,
                    Contact.Name,
                    Phone__c,
                    FAX__c,
                    PAP__c,
                    Contact_Email__c,
                    Preferred_Reader__c,
                    Image_Preference_Notes__c,
                    Email_Reports__c,
                    isDirect,
            		Account.Name
            FROM 	AccountContactRelation
            WHERE 	AccountId = :accountId /*AND Contact.AccountId =: accountId*/
        ];
    }
    
    public static List<Related_Request__c> getPhysicianPreferenceUpdates(String typeRisRequest) {
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
                    //Image_Preference_Notes__c,
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
                    Status__c,
                    Status_set__c,
                    Future_Practice_Location__c,
                    isDirect__c
            FROM    Related_Request__c 
            WHERE RIS_Request__r.Type__c = :typeRisRequest
        ];
        return relatedRisRequests;
    }
    
}