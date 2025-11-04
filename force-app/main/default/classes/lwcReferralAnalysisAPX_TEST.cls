@isTest
public with sharing class lwcReferralAnalysisAPX_TEST {
    
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

        List<Referral__c> listTestReferrals = TestDataFactory.returnReferrals(3,listTestAccConRels);
        List<Database.SaveResult> listTestSaveResultsRefs =  Database.insert(listTestReferrals);   
    }

    @isTest
    private static void testmethod1(){
        Test.startTest();   
        Contact recordId = [SELECT Id FROM Contact LIMIT 1];
        List<Contact> getPhysician = lwcReferralAnalysisAPX.getPhysicianAPX(recordId.Id);
        Test.stopTest();
    }

    @isTest
    private static void testmethod2(){
        Test.startTest();
        TestDataFactory.httpCalloutMockBody = '{"results":[{"PHYNPI": "1548876782", "PHYNAME": "KELLENE FISHER", "MASTERLOCATIONNAME": "LI_MERRICK","BRE": null,"CT": null, "DEXA": null, "DIA": 6,"FL": null, "MR": null, "NM": null,  "PET": null, "USG": null, "USV": null}],"status":"OK"}';
		Test.setMock(HttpCalloutMock.class, new TestDataFactory());
        String payloadToPOST = '{"pnpi":"1518126655","start_date":"2023-8-01","end_date":"2023-8-31"}'; 
        String results = lwcReferralAnalysisAPX.getReferralsFromIntegrationPlatformAPX('Contact', payloadToPOST);
        Test.stopTest();
    }
    
    @isTest
    private static void testmethod3(){
        Test.startTest();
        TestDataFactory.httpCalloutMockBody = '{"results":[{"PHYNPI": "1548876782", "PHYNAME": "KELLENE FISHER", "MASTERLOCATIONNAME": "LI_MERRICK","BRE": null,"CT": null, "DEXA": null, "DIA": 6,"FL": null, "MR": null, "NM": null,  "PET": null, "USG": null, "USV": null}],"status":"OK"}';
        
		Test.setMock(HttpCalloutMock.class, new TestDataFactory());
        String payloadToPOST = '{"acc_id":"001Dn00000KVv60IAD","start_date":"2023-8-01","end_date":"2023-8-31"}';
        String results = lwcReferralAnalysisAPX.getReferralsFromIntegrationPlatformAPX('Account', payloadToPOST);
        Test.stopTest();
    }

}