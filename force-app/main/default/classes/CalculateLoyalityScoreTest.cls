@isTest
public class CalculateLoyalityScoreTest {
    @isTest static void test1(){
        account a = new account();
        a.Name = 'Test1';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Location').getRecordTypeId();
        
        insert a;
        
       Specialty__c sp = new Specialty__c();
        sp.Name = 'OBG/ ONCOLOGY';
        sp.Specialty_Total_Denominator__c = 1.4200;
       
        insert sp;
        
        Contact con = new contact();
        con.lastName = 'paul2';
        con.AccountId = a.Id;
        con.Specialty__c = sp.id;
        
        insert con;
        
        Referral__c rc = new Referral__c();
        rc.Practice_Name__c = a.Id;
        rc.Modality__c = 'DIA';
        rc.Encounter_Date__c = Date.today().addMonths(-1);
        rc.Physician__c = con.Id;
        insert rc;
        
        
        Test.startTest();
        CalculateLoyalityScore x = new CalculateLoyalityScore();
        database.executeBatch(x);
        scheduleCalculateLoyalityScore sh1 = new scheduleCalculateLoyalityScore();
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest();
    }
    
}