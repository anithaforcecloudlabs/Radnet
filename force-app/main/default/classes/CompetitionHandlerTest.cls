@isTest
public with sharing class CompetitionHandlerTest {
    @TestSetup
    static void makeData(){
        List<Account> listTestAccs = TestDataFactory.returnAccounts(3, 'Practice_Location');
        for(Account account: listTestAccs) {
            account.ShippingPostalCode = '10091';
        }
        
        List<Database.SaveResult> listTestSaveResultsAccs =  Database.insert(listTestAccs); 
    }

    @isTest
    public static void testCreateRelationCompetition() {
        Competition__c comp = new Competition__c();
        comp.Name = 'Test';
        comp.Address__PostalCode__s = '10091';
        insert comp;

        List<Account_Competition_Relationship__c> acrsCreated =[SELECT Id, Related_Account__c, Related_Competition__c FROM Account_Competition_Relationship__c];
        //assert.areEqual(3, acrsCreated.size(), 'Expexted 3 account competitive relations');
    }

    @isTest
    public static void testCreateCompetition() {
        Competition__c comp = new Competition__c();
        comp.Name = 'Test 11291';
        comp.Address__PostalCode__s = '11291';
        insert comp;
        List<Account_Competition_Relationship__c> acrsCreated =[SELECT Id, Related_Account__c, Related_Competition__c FROM Account_Competition_Relationship__c];
        assert.areEqual(0, acrsCreated.size(), 'Expexted 0 account competitive relations due to different postal codes');
    }
    
     @isTest
    public static void testCreateCompetitionError() {
        Competition__c comp = new Competition__c();
        comp.Name = 'Test 11291';
        try{
       		insert comp;
       	}catch(Exception e){
            system.debug(e.getMessage());
        }
    }
}