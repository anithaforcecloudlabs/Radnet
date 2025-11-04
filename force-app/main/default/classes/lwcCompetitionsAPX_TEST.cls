@isTest
public without sharing class lwcCompetitionsAPX_TEST {   

    @testSetup
    public static void scenario1(){
        List<Account> listTestAccs = TestDataFactory.returnAccounts(1, 'Practice_Location');
        Competition__c comp = new Competition__c();
            comp.Name = 'Test';
            comp.Address__PostalCode__s = '23222';
        insert comp;        
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
        List<Database.SaveResult> listTestSaveResultsCons =  Database.insert(listTestCons);

        Set<Id> testConIdSet = new Set<Id>();
        if(listTestSaveResultsCons!=null && !listTestSaveResultsCons.isEmpty()){
            for(Database.SaveResult saveResRec : listTestSaveResultsCons){
                if(saveResRec.isSuccess()){
                    testConIdSet.add(saveResRec.getId());
                }
            }
        }

        Account_Competition_Relationship__c acr = new Account_Competition_Relationship__c(
            Related_Account__c = listTestAccs[0].Id,
            Related_Competition__c = comp.Id
        );
        insert acr;
    }

    @isTest
    public static void testmethod1(){
        Test.startTest();   
        Account recordId = [SELECT Id FROM Account LIMIT 1];
        List<Account_Competition_Relationship__c> getACRs = lwcCompetitionsAPX.getCompetitions(recordId.Id);
        
        Test.stopTest();
    }

    @isTest
    public static void testmethod2(){
        Test.startTest();   
        Account_Competition_Relationship__c recordId = [SELECT Id FROM Account_Competition_Relationship__c LIMIT 1];
        Boolean removedSuccess;
        try{
       		removedSuccess = lwcCompetitionsAPX.removeRelation(null);
       	}catch(Exception e){
            system.debug(e.getMessage());
        }
        Test.stopTest();
    }
    
   	@isTest
    public static void testmethod3(){
        Test.startTest();   
        Account_Competition_Relationship__c recordId = [SELECT Id FROM Account_Competition_Relationship__c LIMIT 1];
        Boolean removedSuccess = lwcCompetitionsAPX.removeRelation(recordId.Id);
        Test.stopTest();
    }
    
}