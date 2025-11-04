@isTest
public class CaseTriggerHandlerTest {
    public static List<Account> listTestAccs;
    public static List<Contact> listTestCons;

    @isTest
    static void testCreatedEmailCase(){        
        test.startTest();
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
        listTestCons = TestDataFactory.returnContacts(3, null, testAccIdSet);
        List<Database.SaveResult> listTestSaveResultsCons =  Database.insert(listTestCons);
        Case newCase = new Case (
            Status = 'New',
            AccountId = listTestAccs[0].Id,
            ContactId = listTestCons[0].Id,
            Type='Email',
            Subject='test'
        );
        insert newCase;
        test.stopTest();
    }
}