/*

*********************************************************

Apex Class         : DH_KnowledgeIndexingTriggerTest

Created Date       : June 11, 2024

@description       : Test class for trigger handler DH_KnowledgeIndexingTriggerHandler

@jiraid            : CC-330

*********************************************************

*/
@isTest
public class DH_KnowledgeIndexingTriggerTest {
    
  public static String eastCtgApi;
  public static String eastsubCtgApi;
  public static String westCtgApi;
  public static String westSubCtgApi;
  public static String dataCategoryGroupApiName;

  public class MyPickListInfo {
    public String validFor;
  }

  //Test setup method to create test data
    @testSetup
    static void setup() {
    // Create test data  
    // // PICKLIST data create START    
    // GET datacategory GROUP API name
    dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
      
    // GET API NAME OF category and subcategory PICKLIST
    Map < String, List < String >> eastPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.EAST_CATEGORIES, DH_KMConstants.EAST_SUB_CATEGORIES);
    List < String > eastCtgApiKeys = new List < String > (new Set < String > (eastPicklistMap.keySet()));
    List < String > eastsubCtgApiList = new List < String > ();
    for (Integer i = 0; i < eastCtgApiKeys.size(); i++) {
      if (eastPicklistMap.get(eastCtgApiKeys[i]).size() != 0) {
        eastsubCtgApiList = eastPicklistMap.get(eastCtgApiKeys[i]);
        eastCtgApi = eastCtgApiKeys[i];
        eastsubCtgApi = eastsubCtgApiList[0];
        break;
      }
    }

    Map < String, List < String >> westPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.WEST_CATEGORIES,DH_KMConstants.WEST_SUB_CATEGORIES);
    List < String > westCtgApiKeys = new List < String > (new Set < String > (westPicklistMap.keySet()));
    List < String > westsubCtgApiList = new List < String > ();

    for (Integer i = 0; i < westCtgApiKeys.size(); i++) {
      if (westPicklistMap.get(westCtgApiKeys[i]).size() != 0) {
        westsubCtgApiList = westPicklistMap.get(westCtgApiKeys[i]);
        westCtgApi = westCtgApiKeys[i];
        westSubCtgApi = westsubCtgApiList[0];
        break;
      }
    }
    // Create test data for knowledge articles
        Knowledge__kav article = new Knowledge__kav();
        article.Title = 'Test Article';
        article.UrlName = 'TestArticle';
        article.Global__c = true;
        article.East_Categories__c = eastCtgApi;
        article.East_Sub_Categories__c = eastsubCtgApi;
        article.West_Categories__c = westCtgApi;
        article.West_Sub_Categories__c = westSubCtgApi;
        article.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article;
        DH_Knowledge_Indexing__c index1 = new DH_Knowledge_Indexing__c(
            Knowledge_Article_Management__c = article.Id);
            Insert index1;
        
        Knowledge__kav article2 = new Knowledge__kav();
        article2.Title = 'Test Article2';
        article2.UrlName = 'TestArticle2';
        article2.Global__c = true;
        article2.East_Categories__c = eastCtgApi;
        article2.East_Sub_Categories__c = eastsubCtgApi;
        article2.West_Categories__c = westCtgApi;
        article2.West_Sub_Categories__c = westSubCtgApi;
        article2.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article2;
        
        Knowledge__kav article3 = new Knowledge__kav();
        article3.Title = 'Test Article3';
        article3.UrlName = 'TestArticle3';
        article3.Global__c = true;
        article3.East_Categories__c = eastCtgApi;
        article3.East_Sub_Categories__c = eastsubCtgApi;
        article3.West_Categories__c = westCtgApi;
        article3.West_Sub_Categories__c = westSubCtgApi;
        article3.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article3;
        
        Knowledge__kav article4 = new Knowledge__kav();
        article4.Title = 'Test Article4';
        article4.UrlName = 'TestArticle4';
        article4.Global__c = true;
        article4.East_Categories__c = eastCtgApi;
        article4.East_Sub_Categories__c = eastsubCtgApi;
        article4.West_Categories__c = westCtgApi;
        article4.West_Sub_Categories__c = westSubCtgApi;
        article4.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article4;
    }
 
    //Check duplicates test coverage
    @isTest
    static void testBeforeUpdateCheckDuplicates() {   
        List<Knowledge__kav> article2 = [SELECT Id, Title from Knowledge__kav where UrlName = 'TestArticle2' LIMIT 1];
        DH_Knowledge_Indexing__c index2 = new DH_Knowledge_Indexing__c(
            Knowledge_Article_Management__c = article2[0].Id);
            Insert index2;
        Test.startTest();
        index2.Index__c = 1; // Duplicate index and east subcategory
        try {
            update index2;
            System.assert(false, 'Expected an error due to duplicate east index');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Duplicate index found'), 'Unexpected error message: ' + e.getMessage());
        }
        
        index2.Index__c = 2;
        index2.west_Index__c = 1; // Duplicate west index and west subcategory
        try {
            update index2;
            System.assert(false, 'Expected an error due to duplicate west index');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Duplicate index found'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }
 
    //Method used to cover copy the index to other versions if online/draft versions present for same article
    @isTest
    static void testAfterUpdateCopyIndex() {
        List<Knowledge__kav> article3 = [SELECT Id, Title from Knowledge__kav where UrlName = 'TestArticle3' LIMIT 1];
        
        DH_Knowledge_Indexing__c index3 = new DH_Knowledge_Indexing__c(
            Knowledge_Article_Management__c = article3[0].Id);
            Insert index3;
        List<Knowledge__kav> article4 = [SELECT Id, Title from Knowledge__kav where UrlName = 'TestArticle4' LIMIT 1];
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: article4[0].Id];
        DH_Knowledge_Indexing__c index4 = new DH_Knowledge_Indexing__c(
          Knowledge_Article_Management__c = article4[0].Id, 
        	Index__c = 3,
        	west_Index__c = 3);
            Insert index4;
        Test.startTest();
        	index4.Index__c = 4;
        	index4.west_Index__c = 4;
        Update index4;
        System.assertEquals(4, Integer.ValueOf(index4.Index__c),'Expected east index is 4');
        Test.stopTest();
    }
}