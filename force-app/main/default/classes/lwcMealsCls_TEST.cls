@isTest
public class lwcMealsCls_TEST {

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
    }

    @isTest
    public static void testmethod1(){
        Test.startTest();   
        Account recordId = [SELECT Id FROM Account LIMIT 1];
        List<AccountContactRelation> getACRs = lwcMealsCls.getContacts(recordId.Id);
        List<Contact> cont = new List<Contact>();
        List<String> contIds= new List<String>();

        for (AccountContactRelation acr : getACRs) {
            cont.add(new Contact(Id = acr.ContactId, Budget_Spent__c = acr.Contact.Budget_Spent__c));
            contIds.add( acr.ContactId);
        }
        List<Map<String, String>> objectsMap = lwcMealsCls.getPicklistValues();
        Task tsk1 = new Task(
            WhatId = recordId.Id,        
            Call_Type__c = 'Sales Call',
            Objective__c = 'MRI',       
            Cost__c =78,
            Description = 'task comment',        
            Subject = 'Meals',          
            ActivityDate = date.today(), 
            Status = 'Open');
        Task newTask = lwcMealsCls.saveTask(tsk1,contIds, true);
        
        List<Contact> updateBudgets = lwcMealsCls.updateBudgetContacts(cont);
        Test.stopTest();
    }

}