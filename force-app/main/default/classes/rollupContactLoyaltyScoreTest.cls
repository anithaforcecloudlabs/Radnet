@isTest
public class rollupContactLoyaltyScoreTest {
    @isTest static void test1(){
        
        account a = new account();
        a.Name = 'Test1';
          a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Location').getRecordTypeId();
        
        insert a;
        
        
        Contact con = new contact();
        con.lastName = 'paul2';
        con.AccountId = a.Id;
        con.Loyalty_Score__c = 1.23;
        
        insert con;
        
        
        Test.startTest();
        rollupContactLoyaltyScoreToAccount x = new rollupContactLoyaltyScoreToAccount();
        database.executeBatch(x);
        scheduleRollupContactLoyaltyScore sh1 = new scheduleRollupContactLoyaltyScore();
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest();
        
    }
}