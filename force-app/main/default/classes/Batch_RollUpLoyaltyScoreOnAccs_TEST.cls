@isTest
public with sharing class Batch_RollUpLoyaltyScoreOnAccs_TEST {
    public static List<Account> listTestAccs;

    private static void scenario1(){
        listTestAccs = TestDataFactory.returnAccounts(1, 'Practice_Location');
        List<Database.SaveResult> listTestSaveResultsAccs =  Database.insert(listTestAccs);

        Set<Id> testAccIdSet = new Set<Id>();
        if(listTestSaveResultsAccs!=null && !listTestSaveResultsAccs.isEmpty()){
            for(Database.SaveResult saveResRec : listTestSaveResultsAccs){
                if(saveResRec.isSuccess()){
                    testAccIdSet.add(saveResRec.getId());
                }
            }
        }

        List<Contact> listTestCons = TestDataFactory.returnContacts(3, null, testAccIdSet);
        listTestCons[0].Loyalty_Score__c = 3;
        listTestCons[0].Loyalty_Score__c = 4;
        List<Database.SaveResult> listTestSaveResultsCons =  Database.insert(listTestCons);

        Set<Id> testConIdSet = new Set<Id>();
        if(listTestSaveResultsCons!=null && !listTestSaveResultsCons.isEmpty()){
            for(Database.SaveResult saveResRec : listTestSaveResultsCons){
                if(saveResRec.isSuccess()){
                    testConIdSet.add(saveResRec.getId());
                }
            }
        }
        string conQuery = TestDataFactory.getTestSOQLQuery('Contact');
        conQuery = conQuery + ' WHERE Id IN:testConIdSet';
        listTestCons = Database.query(conQuery);

        string accConQuery = TestDataFactory.getTestSOQLQuery('AccountContactRelation');
        List<AccountContactRelation> listTestAccConRels = Database.query(accConQuery);

        List<Referral__c> listTestReferrals = TestDataFactory.returnReferrals(3,listTestAccConRels);
        List<Database.SaveResult> listTestSaveResultsRefs =  Database.insert(listTestReferrals);
    }

    @isTest
    private static void testmethod1(){
        Test.startTest();
        scenario1();
        Batch_RollUpLoyaltyScoreOnAccs_Scheduler sc = new Batch_RollUpLoyaltyScoreOnAccs_Scheduler();
        // Database.executeBatch(bc, 10);
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, sc);
        Test.stopTest();
    }
}