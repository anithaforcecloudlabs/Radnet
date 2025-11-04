@isTest
public with sharing class RelatedAccountsAPX_TEST {
    public static final Id PRACTICE_LOCATION = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Location').getRecordTypeId();
    public static final Id PHYSICIANS = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physicians').getRecordTypeId();

    private static Set<Id> practiceOverviewIdSet;
    private static Set<Id> practiceLocIdSet;
    private static Set<Id> conIdSet;
    private static Set<Id> risReqIdSet;
    private static List<Related_Request__c> listTestRelatedRequests;
    private static List<AccountContactRelation> listTestAccCons;

    @testSetup
    static void setup() {
        User currentUser = new User(Id = UserInfo.getUserId(), RIS_Data_Manager__c = true);
        update currentUser;

        System.runAs(currentUser) {
            Account practice1 = new Account (
                Name = 'TestAcc',
                RecordTypeId = PRACTICE_LOCATION
            );
            Account practice2 = new Account (
                Name = 'TestAcc2',
                RecordTypeId = PRACTICE_LOCATION
            );
            Account practice3 = new Account (
                Name = 'TestAcc3',
                RecordTypeId = PRACTICE_LOCATION
            );
            insert new List<Account>{practice1, practice2, practice3};
    
            Contact contactPracticeDirect = new Contact(
                AccountId = practice1.Id,
                LastName ='TestCont',
                RecordTypeId = PHYSICIANS
            );
             Contact contactPracticeDirect2 = new Contact(
                AccountId = practice2.Id,
                LastName ='TestSecCont1',
                RecordTypeId = PHYSICIANS
            );
            Contact contactPractice2 = new Contact(
                AccountId = practice2.Id,
                LastName ='TestSecCont2',
                RecordTypeId = PHYSICIANS
            );
            Contact contactPractice3 = new Contact(
                AccountId = practice3.Id,
                LastName ='TestSecCont3',
                RecordTypeId = PHYSICIANS
            );
            Contact contactPractice4 = new Contact(
                AccountId = practice3.Id,
                LastName ='TestSecCont4',
                RecordTypeId = PHYSICIANS
            );
    
            Contact contactPractice5 = new Contact(
                AccountId = practice3.Id,
                LastName ='TestSecCont5',
                RecordTypeId = PHYSICIANS
            );
            
            insert new List<Contact>{
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
                Email_Reports__c = true
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
        }
    }

    @IsTest
    private static void getAccounts(){
        Contact pageContact = [SELECT Id FROM Contact WHERE LastName ='TestSecCont1'];
        List<AccountContactRelation> relatedAccounts = RelatedAccountsAPX.getAccounts((String)pageContact.Id);
        Assert.areEqual(0, relatedAccounts.size());
    }

    @IsTest
    private static void removedAccounts(){
        Test.startTest();
        Contact pageContact = [SELECT Id FROM Contact WHERE LastName ='TestSecCont1' LIMIT 1];
        Account pageAccount = [SELECT Id FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        AccountContactRelation acr = new AccountContactRelation(
            AccountId = pageAccount.Id,
            ContactId = pageContact.Id,
            Email_Reports__c = true
        );

        User currentUser = new User(Id = UserInfo.getUserId());

        System.runAs(currentUser) {
            insert acr;
            List<AccountContactRelation> relatedAccounts = RelatedAccountsAPX.getAccounts((String)pageContact.Id);
            List<String> listForRemove = new List<String>();
            listForRemove.add(relatedAccounts[0].Id);      
            Assert.areEqual(1, relatedAccounts.size());
           
            try {
                List<AccountContactRelation> removeAccountRelationList = RelatedAccountsAPX.removeAccountRelation(listForRemove, (String)pageContact.Id);
            } catch (Exception ex) {       
                Assert.areEqual(1, relatedAccounts.size(), 'It not possible remove direct relation');
            }
    
            Test.stopTest();        
            List<AccountContactRelation> relatedAfterRemoveAccounts = RelatedAccountsAPX.getAccounts((String)pageContact.Id);
            Assert.areEqual(0, relatedAfterRemoveAccounts.size());
        }
    }
    
    @IsTest
    private static void mergedAccounts(){
        Contact pageContact = [SELECT Id FROM Contact WHERE LastName ='TestSecCont4' LIMIT 1];
        List<AccountContactRelation> relatedAccounts = RelatedAccountsAPX.getAccounts((String)pageContact.Id);
        List<String> mergedAccounts = new List<String>();

        for (AccountContactRelation acr : relatedAccounts){
            if (!acr.IsDirect) {
                mergedAccounts.add(acr.AccountId);
            }
        }

        String noteMerge = 'Some text';
        List<Account> getAccountForUpdateList = RelatedAccountsAPX.getAccountsForUpdate(mergedAccounts);
        Assert.areEqual(2, relatedAccounts.size());
        Test.startTest();
       
        User currentUser = new User(Id = UserInfo.getUserId());

        System.runAs(currentUser) { 
            String mergedContactRelationList = RelatedAccountsAPX.mergeAcrs(mergedAccounts, noteMerge);
            List<AccountContactRelation> relatedAfterRemoveContacts = RelatedAccountsAPX.getAccounts((String)pageContact.Id);
            Assert.areEqual(2, relatedAfterRemoveContacts.size());
            try{
                List<DuplicateRecordItem> duplicateSet = RelatedAccountsAPX.getDuplicateRecordsAfterMerged(mergedAccounts);
                Assert.areNotEqual(null, duplicateSet);
            } catch (Exception exp){
                system.debug('d' + exp.getMessage());
            }
        }
        Test.stopTest();  
    }

    private static void testsetup1(){
        List<Account> listTestPracOverviews = TestDataFactory.returnAccounts(1, 'Practice_Overview');
        List<Database.SaveResult> listSaveResRecs = new List<Database.SaveResult>();
        listSaveResRecs = Database.insert(listTestPracOverviews);
        practiceOverviewIdSet = new Set<Id>();
        practiceLocIdSet = new Set<Id>();
        conIdSet = new Set<Id>();
        risReqIdSet = new Set<Id>();
        listTestAccCons = new List<AccountContactRelation>();
        if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
            for(Database.SaveResult saveResRec : listSaveResRecs){
                if(saveResRec.isSuccess()){
                    practiceOverviewIdSet.add(saveResRec.getId());
                }
            }
        }
        if(practiceOverviewIdSet!=null && !practiceOverviewIdSet.isEmpty()){
            List<Account> listTestPracLocs = TestDataFactory.returnAccounts(1, 'Practice_Location');
            if(listTestPracLocs!=null && !listTestPracLocs.isEmpty()){
                List<Id> listPracOverviewIds  = new List<Id>(practiceOverviewIdSet);
                listTestPracLocs[0].Practice_Overview__c = listPracOverviewIds[0];
            }
            listSaveResRecs = Database.insert(listTestPracLocs);
            if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
                for(Database.SaveResult saveResRec : listSaveResRecs){
                    if(saveResRec.isSuccess()){
                        practiceLocIdSet.add(saveResRec.getId());
                    }
                }
            }
            if(practiceLocIdSet!=null && !practiceLocIdSet.isEmpty()){
                List<RIS_Requests__c> listTestRISReqs = TestDataFactory.returnRISRequests(1, practiceLocIdSet);
                listSaveResRecs = Database.insert(listTestRISReqs);
                if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
                    for(Database.SaveResult saveResRec : listSaveResRecs){
                        if(saveResRec.isSuccess()){
                            risReqIdSet.add(saveResRec.getId());
                        }
                    }
                }
            }
        }
        if(practiceOverviewIdSet!=null && !practiceOverviewIdSet.isEmpty()){
            List<Contact> listTestCons = TestDataFactory.returnContacts(1, 'Physicians', practiceOverviewIdSet);
            listSaveResRecs = Database.insert(listTestCons);
            if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
                for(Database.SaveResult saveResRec : listSaveResRecs){
                    if(saveResRec.isSuccess()){
                        conIdSet.add(saveResRec.getId());
                    }
                }
            }
        }
        if(conIdSet!=null && !conIdSet.isEmpty()){
            listTestAccCons = TestDataFactory.returnAccountContactPracLocRelations(practiceLocIdSet, conIdSet);
            listSaveResRecs = Database.insert(listTestAccCons);
            if(listSaveResRecs!=null && !listSaveResRecs.isEmpty()){
                for(Database.SaveResult saveResRec : listSaveResRecs){
                    if(saveResRec.isSuccess()){
                        conIdSet.add(saveResRec.getId());
                    }
                }
            
            }
            
            string accConRelStr = TestDataFactory.getTestSOQLQuery('AccountContactRelation');
            listTestAccCons = Database.query(accConRelStr);
            string risReqsStr = TestDataFactory.getTestSOQLQuery('RIS_Requests__c');
            List<RIS_Requests__c> listTestRISReqs = Database.query(risReqsStr);
            listTestRelatedRequests = TestDataFactory.returnRelatedRequests(listTestRISReqs, listTestAccCons);
        }
        
    }

    @isTest
    private static void testmethod1(){
        testsetup1();
        Test.startTest();
        RelatedAccountsAPX.getRISRequestGrpAPX('RisRequest');
        List<String> listPracLocIds = new List<String>();
        for(Id praclocId : practiceLocIdSet){
            listPracLocIds.add(praclocId);
        }
        RelatedAccountsAPX.getLocationAccountsAPX(listPracLocIds);
        List<RIS_Requests__c> listTestRISReqs = TestDataFactory.returnRISRequests(1, practiceLocIdSet);
        RelatedAccountsAPX.insertLocationRISReqAPX(listTestRISReqs);
        Test.stopTest();
    }

    @isTest
    private static void testmethod2(){
        testsetup1();
        Test.startTest();
        List<String> listRisReqIds = new List<String>();
        for(Id risReqId : risReqIdSet){
            listRisReqIds.add(risReqId);
        }
        RelatedAccountsAPX.getInsertedLocationRISReqsAPX(listRisReqIds);
        Test.stopTest();
    }

    @isTest
    private static void testmethod3(){
        testsetup1();
        Test.startTest();
        RelatedAccountsAPX.insertLocationRISReqAPX(null);
        RelatedAccountsAPX.insertRelatedRISRequestsAPX(null);
        RelatedAccountsAPX.insertRelatedRISRequestsAPX(listTestRelatedRequests);
        Test.stopTest();
    }

}