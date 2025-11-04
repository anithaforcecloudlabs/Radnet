@isTest
public class LwcRelatedCasesAPX_TEST {
    public static List<Account> listTestAccs;
    public static List<Contact> listTestCons;

	@testSetup
    static void scenario1(){         
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

        List<Case> listCases = new List<Case>();
        Case newCase = new Case (
            Status = 'New',
            AccountId = listTestAccs[0].Id,
            Type='Add New Physician'
        );
        insert newCase;
        Case newCase2 = new Case (
            Status = 'New',
            ContactId = listTestCons[0].Id,
            Type='Add New Physician'
        );
        insert newCase2;
    }

    @IsTest
    private static void removedContacts() {
        Case pageCase = [SELECT Id, AccountId FROM Case LIMIT 1];
        List<Case> relatedCase = LwcRelatedCasesAPX.getRelatedRisRequestAPX(pageCase.AccountId, pageCase.Id);
        List<Case> resultUpdate = LwcRelatedCasesAPX.handleCloseRisRequestAPX(new List<String> {pageCase.Id});
        List<Case> resultInreviewUpdate = LwcRelatedCasesAPX.handleInReviewRisRequestAPX(new List<String> {pageCase.Id});
        
    }
}