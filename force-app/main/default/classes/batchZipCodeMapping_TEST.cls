@isTest
public class batchZipCodeMapping_TEST {
    @isTest
    public static void testBatch() {
        Test.startTest();
        List<Account> listTestAccs = TestDataFactory.returnAccounts(3, 'Practice_Location');
        for(Integer count = 0; count < 3; count++){
                Account testAccRec = new Account();
                testAccRec.ShippingPostalCode = '10091';
                testAccRec.Name = 'Test Acc '+ String.valueOf(count);                
                testAccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Practice_Location').getRecordTypeId();                
                listTestAccs.add(testAccRec);
            }
        
        insert listTestAccs;
        
        Competition__c comp1 = new Competition__c();
        comp1.Name = 'Test 1';
        comp1.Address__PostalCode__s = '10091';
        TriggerFactory.disable(Competition__c.SObjectType);
        insert comp1;
        Competition__c comp2 = new Competition__c();
        comp2.Name = 'Test 2';
        comp2.MR__c = true;
        comp2.Address__PostalCode__s = '10091';
        TriggerFactory.disable(Competition__c.SObjectType);
        insert comp2;
       
        Database.executeBatch(new batchZipCodeMapping());
        Test.stopTest();
    }
    
    @isTest
    public static void testBatch2() {
         Test.startTest();
        List<Account> listTestAccs = TestDataFactory.returnAccounts(3, 'Practice_Location');
        for(Integer count = 0; count < 3; count++){
                Account testAccRec = new Account();
                testAccRec.ShippingPostalCode = '10091';
                testAccRec.Name = 'Test Acc '+ String.valueOf(count);                
                testAccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Practice_Location').getRecordTypeId();                
                listTestAccs.add(testAccRec);
            }
        
        insert listTestAccs;
        
        Competition__c comp1 = new Competition__c();
        comp1.Name = 'Test 1';
        comp1.Address__PostalCode__s = '10091';
        TriggerFactory.disable(Competition__c.SObjectType);
        insert comp1;
        Competition__c comp2 = new Competition__c();
        comp2.Name = 'Test 2';
        comp2.MR__c = true;
        comp2.Address__PostalCode__s = '10091';
        insert comp2;
       
        Database.executeBatch(new batchZipCodeMapping());
        Test.stopTest();
    }
    
    @isTest
    public static void testBatch3() {
         Test.startTest();
        List<Account> listTestAccs = TestDataFactory.returnAccounts(3, 'Practice_Location');
        for(Integer count = 0; count < 3; count++){
                Account testAccRec = new Account();
                testAccRec.ShippingPostalCode = '10091';
                testAccRec.Name = 'Test Acc '+ String.valueOf(count);                
                testAccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Practice_Location').getRecordTypeId();                
                listTestAccs.add(testAccRec);
            }
        
        insert listTestAccs;
        
        Competition__c comp1 = new Competition__c();
        comp1.Name = 'Test 1';
        comp1.Address__PostalCode__s = '10091';
     
        insert comp1;
        Competition__c comp2 = new Competition__c();
        comp2.Name = 'Test 2';
        comp2.MR__c = true;
        comp2.Address__PostalCode__s = '10091';
        insert comp2;
       
        Database.executeBatch(new batchZipCodeMapping());
        Test.stopTest();
    }
    
    @isTest
    public static void testBatch4() {
         Test.startTest();
        List<Account> listTestAccs = TestDataFactory.returnAccounts(3, 'Practice_Location');
        for(Integer count = 0; count < 3; count++){
                Account testAccRec = new Account();
                testAccRec.ShippingPostalCode = '10091';
                testAccRec.Name = 'Test Acc '+ String.valueOf(count);                
                testAccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Practice_Location').getRecordTypeId();                
                listTestAccs.add(testAccRec);
            }
        
        insert listTestAccs;
        
        Competition__c comp1 = new Competition__c();
        comp1.Name = 'Test 1';
        comp1.Address__PostalCode__s = '10891';
     
        insert comp1;
        Competition__c comp2 = new Competition__c();
        comp2.Name = 'Test 2';
        comp2.MR__c = true;
        comp2.Address__PostalCode__s = '10091';
        insert comp2;
       
        Database.executeBatch(new batchZipCodeMapping());
        Test.stopTest();
    }
}