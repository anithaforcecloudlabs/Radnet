@isTest
public class CountPhysiciansBatch_Test {  
    @isTest
    public static void testCountPhysicians(){
        Account acc = new Account(Name = 'test');
        insert acc;
        List<Contact> listofcon = new List<Contact>();
        for(Integer i = 0; i < 10; i++) {
            Contact con = new Contact();
            con.LastName='test';
             con.AccountId = acc.Id;
            listofcon.add(con);
        }
        insert listofcon;
        Test.startTest();
        CountPhysiciansBatch obj = new CountPhysiciansBatch();
        Database.executeBatch( obj );
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, obj  );
        Test.stopTest();
        
        Account accUpdated = [SELECT Id,Name,Physicians__c FROM Account WHERE Name = 'test'];
        System.assertEquals(10,accUpdated.Physicians__c);
    }
}