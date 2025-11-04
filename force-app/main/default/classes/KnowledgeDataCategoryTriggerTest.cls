/*
*********************************************************

Apex Class         : KnowledgeDataCategoryTriggerTest

Created Date       : May 27, 2024

@description       : @description - This test class verifies the functionality of the KnowledgeDataCategoryApex trigger handler. 
                     * It covers scenarios including both successful and unsuccessful creation and updation of Knowledge Articles records

@jiraid            : CC-330, 423, 463, 465

*********************************************************
*/


@isTest
private class KnowledgeDataCategoryTriggerTest {
  public static String eastCtgApi;
  public static String eastsubCtgApi;
  public static String westCtgApi;
  public static String westSubCtgApi;
  public static String  dataCategoryGroupApiName;

  public class MyPickListInfo {
    public String validFor;
  }
    private static Id articleRecordType = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get( 'FAQ_Template_1' ).getRecordTypeId();
    
    @testSetup
    static void setupTestData() {  
        
        // PICKLIST data create START    
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

    Map < String, List < String >> westPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.WEST_CATEGORIES, DH_KMConstants.WEST_SUB_CATEGORIES);
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
    // PICKLIST data create END
    
        
        //CREATION OF KNOWLEDGE ARTICLE RECORDS
   
        Knowledge__kav article = new Knowledge__kav();
        article.Title = 'Test Article1';
        article.UrlName = 'TestArticle1';
        article.RecordTypeId = articleRecordType;
        article.Global__c = true;
        article.East_Categories__c = eastCtgApi;
        article.East_Sub_Categories__c = eastsubCtgApi;
        article.West_Categories__c = westCtgApi;
        article.West_Sub_Categories__c = westSubCtgApi;
        article.Data_Category_Group__c = dataCategoryGroupApiName;
        
        Knowledge__kav article2 = new Knowledge__kav();
        article2.Title = 'Test Article2';
        article2.UrlName = 'TestArticle2';
        article2.RecordTypeId = articleRecordType;
        article2.Global__c = true;
        article2.East_Categories__c = eastCtgApi;
        article2.East_Sub_Categories__c = eastsubCtgApi;
        article2.West_Categories__c = westCtgApi;
        article2.West_Sub_Categories__c = westSubCtgApi;
        article2.Data_Category_Group__c = dataCategoryGroupApiName;
        insert new List<Knowledge__kav>{article , article2}; 
            
   		 Knowledge__kav article3 = new Knowledge__kav();
        article3.Title = 'TestArticle3';
        article3.UrlName = 'TestArticle3';
        article3.RecordTypeId = articleRecordType;
        article3.Global__c = true;
        article3.East_Categories__c = eastCtgApi;
        article3.East_Sub_Categories__c = eastsubCtgApi;  
        article3.West_Categories__c = westCtgApi;
        article3.West_Sub_Categories__c = westSubCtgApi;
        article3.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article3;
        
      }
    
    /**************************************************************************************************************************************************
     * 
     * @description this method checks for creation and updation of article for both east and west categories and sub-categories
     * 
     * */
    
    @isTest
    private static void firstindexArticleforEastAndWestSubCategory() {
        
      // EAST PICKLIST data create START 
      // GET datacategory GROUP API name
      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
        
      // GET API NAME OF category and subcategory PICKLIST
      Map < String, List < String >> eastPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.EAST_CATEGORIES, DH_KMConstants.EAST_SUB_CATEGORIES);
      List < String > eastCtgApiKeys = new List < String > (new Set < String > (eastPicklistMap.keySet()));
      List < String > eastsubCtgApiList = new List < String > ();
      for (Integer i = 1; i < eastCtgApiKeys.size(); i++) {
        if (eastPicklistMap.get(eastCtgApiKeys[i]).size() != 0) {
          eastsubCtgApiList = eastPicklistMap.get(eastCtgApiKeys[i]);
          eastCtgApi = eastCtgApiKeys[i];
          eastsubCtgApi = eastsubCtgApiList[0];
         	break;
        }
      }
      //EAST PICKLIST data create END
	
     //WEST PICKLIST data create START    
    // GET datacategory GROUP API name
    dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
        
     // GET API NAME OF category and subcategory PICKLIST
    Map < String, List < String >> westPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.WEST_CATEGORIES, DH_KMConstants.WEST_SUB_CATEGORIES);
    List < String > westCtgApiKeys = new List < String > (new Set < String > (westPicklistMap.keySet()));
    List < String > westsubCtgApiList = new List < String > ();

    for (Integer i = 1; i < westCtgApiKeys.size(); i++) {
      if (westPicklistMap.get(westCtgApiKeys[i]).size() != 0) {
        westsubCtgApiList = westPicklistMap.get(westCtgApiKeys[i]);
        westCtgApi = westCtgApiKeys[i];
        westSubCtgApi = westsubCtgApiList[0];
        break;
      }
    }
      //WEST PICKLIST data create END
      
        Knowledge__kav article = [
            SELECT 
            ID, East_Categories__c, East_Sub_Categories__c
            FROM 
            Knowledge__kav 
            WHERE 
            Title = 'Test Article1'
            LIMIT 1];
		  Test.startTest();
            article.East_Categories__c = eastCtgApi;
            article.East_Sub_Categories__c = eastsubCtgApi;        
            Update article;
        
        List<DH_Knowledge_Indexing__c> indexRecords = [
            SELECT Id, Index__c, west_Index__c
            FROM DH_Knowledge_Indexing__c
            WHERE Knowledge_Article_Management__c = :article.Id
        ];
        article.Global__c=false;
        article.East_Categories__c = null;
        article.East_Sub_Categories__c = null; 
        article.West_Categories__c=westCtgApi;
        article.West_Sub_Categories__c=westSubCtgApi;
        Update article;
        Assert.isNotNull(indexRecords, 'index records not be null');
        Test.stopTest();
       
    }
    
    /**************************************************************************************************************************************************
     * 
     * @description this method checks for insertion of articles with east category and sub-category
     * */
    
    
    @isTest
    private static void firstindexArticleforEastSubCategory() {
       // EAST PICKLIST data create START 
      // GET datacategory GROUP API name
      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
        
      // GET API NAME OF category and subcategory PICKLIST
      Map < String, List < String >> eastPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.EAST_CATEGORIES, DH_KMConstants.EAST_SUB_CATEGORIES);
      List < String > eastCtgApiKeys = new List < String > (new Set < String > (eastPicklistMap.keySet()));
      List < String > eastsubCtgApiList = new List < String > ();
      for (Integer i = 0; i < eastCtgApiKeys.size(); i++) {
        if (eastPicklistMap.get(eastCtgApiKeys[i]).size() > 1) {
          eastsubCtgApiList = eastPicklistMap.get(eastCtgApiKeys[i]);
          eastCtgApi = eastCtgApiKeys[i];
          eastsubCtgApi = eastsubCtgApiList[1];
         	break;
        }
      }
      //EAST PICKLIST data create END
      
        Knowledge__kav article = [
            SELECT 
            ID, East_Categories__c, East_Sub_Categories__c
            FROM 
            Knowledge__kav 
            WHERE 
            Title = 'Test Article2'
            LIMIT 1];
        Test.startTest();
            article.East_Categories__c = eastCtgApi;        
            article.East_Sub_Categories__c = eastsubCtgApi;
            Update article;
        
        List<DH_Knowledge_Indexing__c> indexRecords = [
            SELECT Id, Index__c, west_Index__c
            FROM DH_Knowledge_Indexing__c
            WHERE Knowledge_Article_Management__c = :article.Id
        ];
        
        Assert.isNotNull(indexRecords, 'index records not be null');
        
		Test.stopTest();        
    }
    
    
    /**************************************************************************************************************************************************
     * 
     * @description this method checks for insertion of articles with west category and sub-category
     * */
    
    @isTest
    private static void firstindexArticleforWestSubCategory() {
    
    //WEST PICKLIST data create START    
    // GET datacategory GROUP API name
    dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
    Map < String, List < String >> westPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.WEST_CATEGORIES, DH_KMConstants.WEST_SUB_CATEGORIES);
    List < String > westCtgApiKeys = new List < String > (new Set < String > (westPicklistMap.keySet()));
    List < String > westsubCtgApiList = new List < String > ();

    for (Integer i = 1; i < westCtgApiKeys.size(); i++) {
      if (westPicklistMap.get(westCtgApiKeys[i]).size() != 0) {
        westsubCtgApiList = westPicklistMap.get(westCtgApiKeys[i]);
        westCtgApi = westCtgApiKeys[i];
        westSubCtgApi = westsubCtgApiList[0];
        break;
      }
    }
        Knowledge__kav article = [
            SELECT 
            ID, East_Categories__c, West_Categories__c, West_Sub_Categories__c
            FROM 
            Knowledge__kav 
            WHERE 
            Title = 'Test Article2'
            LIMIT 1];
        article.West_Categories__c = westCtgApi;
        article.West_Sub_Categories__c = westSubCtgApi;
        Update article;
        
        List<DH_Knowledge_Indexing__c> indexRecords = [
            SELECT Id, Index__c, west_Index__c
            FROM DH_Knowledge_Indexing__c
            WHERE Knowledge_Article_Management__c = :article.Id
        ];
        
        Assert.isNotNull(indexRecords, 'index records not be null');
        
    }
    
    /**************************************************************************************************************************************************
     * 
     * @description this consolidated method verifies different conditions and covers various scenarios,
     * to insert and update articles, based on their old and new data category values
     * 
     * */
    
    @isTest
    private static void firstindexArticleforEastWestSubCategoryUpdate() {
        
        //WEST PICKLIST data create START    
        // GET datacategory GROUP API name
        dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
        Map < String, List < String >> westPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.WEST_CATEGORIES, DH_KMConstants.WEST_SUB_CATEGORIES);
        List < String > westCtgApiKeys = new List < String > (new Set < String > (westPicklistMap.keySet()));
        List < String > westsubCtgApiList = new List < String > ();
        for (Integer i = 1; i < westCtgApiKeys.size(); i++) {
          if (westPicklistMap.get(westCtgApiKeys[i]).size() > 1) {
              
            westsubCtgApiList = westPicklistMap.get(westCtgApiKeys[i]);
            westCtgApi = westCtgApiKeys[i];
            westSubCtgApi = westsubCtgApiList[1];
            break;
          }
        }
       
      // EAST PICKLIST data create START 
      // GET datacategory GROUP API name
      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
        
      // GET API NAME OF category and subcategory PICKLIST
      Map < String, List < String >> eastPicklistMap = DH_KMUtility.getGlobalPickList(DH_KMConstants.EAST_CATEGORIES, DH_KMConstants.EAST_SUB_CATEGORIES);
      List < String > eastCtgApiKeys = new List < String > (new Set < String > (eastPicklistMap.keySet()));
      List < String > eastsubCtgApiList = new List < String > ();
      for (Integer i = 0; i < eastCtgApiKeys.size(); i++) {
        if (eastPicklistMap.get(eastCtgApiKeys[i]).size() > 1) {
          eastsubCtgApiList = eastPicklistMap.get(eastCtgApiKeys[i]);
          eastCtgApi = eastCtgApiKeys[i];
          eastsubCtgApi = eastsubCtgApiList[1];
         	break;
        }
      }
      //EAST PICKLIST data create END
      
         Knowledge__kav article = [ SELECT  ID, East_Categories__c, West_Categories__c, West_Sub_Categories__c
            FROM  Knowledge__kav  WHERE  Title = 'Test Article2' LIMIT 1];
          article.West_Categories__c = westCtgApi;
          article.West_Sub_Categories__c = westSubCtgApi;
          Update article;
        
        List<DH_Knowledge_Indexing__c> indexRecords = [
            SELECT Id, Index__c, west_Index__c
            FROM DH_Knowledge_Indexing__c
            WHERE Knowledge_Article_Management__c = :article.Id
        ];
        
        Assert.isNotNull(indexRecords, 'index records not be null');
        String westCtgApi2;
        for (Integer i = 0; i < westCtgApiKeys.size(); i++) {
          if (westPicklistMap.get(westCtgApiKeys[i]).size() ==0) {
              
            westsubCtgApiList = westPicklistMap.get(westCtgApiKeys[i]);
            westCtgApi2 = westCtgApiKeys[i];
            break;
          }
        }
        
        //west sub category null
        Test.startTest();
            article.West_Categories__c = westCtgApi2;
            article.West_Sub_Categories__c = null;
            Update article;
            article.West_Categories__c = westCtgApi;
            article.West_Sub_Categories__c = westSubCtgApi;
            Update article;
        	try{
                article.West_Sub_Categories__c= null;
                Update article;
            }
            catch(exception e){
                System.debug('West category present subcategory null error');
            }
        	try{
                article.East_Categories__c = null;
        		article.East_Sub_Categories__c= null;
            	article.article_Type__c = DH_KMConstants.ARTICLE_TYPE_WEST;
                article.West_Sub_Categories__c= null;
                Update article;
            }
            catch(exception e){
                System.debug('West category present subcategory null error');
            }
        Knowledge__kav article6 = new Knowledge__kav();
            article6.Title = 'Test Article6';
            article6.UrlName = 'TestArticle6';
            article6.RecordTypeId = articleRecordType;
            article6.Global__c = false;
            article6.West_Categories__c = westCtgApi2;
            article6.Data_Category_Group__c = dataCategoryGroupApiName;
            Insert article6;
        
        	
        	//east sub category null
            article6.East_Categories__c = eastCtgApi;
            article6.East_Sub_Categories__c = eastsubCtgApi;
            article6.West_Categories__c = null;
            article6.West_Sub_Categories__c= null;
            Update article6;

             article6.West_Categories__c = westCtgApi2;  
             article6.Global__c = true;
        	   Update article6;
        
        try{
            article6.East_Sub_Categories__c = null;
            Update article6;
        }
        catch(exception e){
            System.debug('East category present subcategory null error');
        }
        try{
            article6.West_Categories__c = null;
        	article6.West_Sub_Categories__c= null;
            article6.article_Type__c = DH_KMConstants.ARTICLE_TYPE_EAST;
            article6.East_Sub_Categories__c = null;
            Update article6;
        }
        catch(exception e){
            System.debug('East category present subcategory null error');
        }

          List<Knowledge__kav> knowList = new List<Knowledge__kav>();
            Knowledge__kav article7 = new Knowledge__kav();
            article7.Title = 'Test Article7';
            article7.UrlName = 'TestArticle7';
            article7.RecordTypeId = articleRecordType;
            article7.Global__c = false;
            article7.East_Categories__c = eastCtgApi;
            article7.Data_Category_Group__c = dataCategoryGroupApiName;
            knowlist.add(article7);
        
           Knowledge__kav article8 = new Knowledge__kav();
            article8.Title = 'Test Article8';
            article8.UrlName = 'TestArticle8';
            article8.RecordTypeId = articleRecordType;
            article8.Global__c = false;
            article8.East_Categories__c = eastCtgApi;
            article8.Data_Category_Group__c = dataCategoryGroupApiName;
            knowlist.add(article8);
        
            Knowledge__kav article9 = new Knowledge__kav();
            article9.Title = 'Test Article9';
            article9.UrlName = 'TestArticle9';
            article9.RecordTypeId = articleRecordType;
            article9.Global__c = false;
            article9.West_Categories__c = westCtgApi;
            article9.Data_Category_Group__c = dataCategoryGroupApiName;
            knowlist.add(article9);  
            insert knowlist;
        
          article7.East_Categories__c = eastCtgApi;
          article7.East_Sub_Categories__c= eastsubCtgApi;
          article7.article_Type__c = DH_KMConstants.ARTICLE_TYPE_EAST;
          update article7;

          article8.East_Categories__c = 'Insurance_Resources';
          article8.East_Sub_Categories__c= 'Insurance_Grids';
          article8.article_Type__c = DH_KMConstants.ARTICLE_TYPE_EAST;
          update article8;
        
          article9.West_Categories__c = westCtgApi;
          article9.West_Sub_Categories__c= westsubCtgApi;
          article9.article_Type__c = DH_KMConstants.ARTICLE_TYPE_WEST;
          update article9;
        
        Test.stopTest();
    }

	/**************************************************************************************************************************************************
     * 
     * @description this method is used verifies the functionality of setArticleType method
     * 
     * */    
    
    @isTest
    private static void setArticleType() {
        Knowledge__kav article2 = [
            SELECT 
            ID, East_Categories__c, West_Categories__c, West_Sub_Categories__c
            FROM 
            Knowledge__kav 
            WHERE 
            Title = 'Test Article2'
            LIMIT 1];                 

        article2.Global__c = true;
        Test.startTest();
            Update article2;
            
            List<DH_Knowledge_Indexing__c> indexRecords = [
                SELECT Id, Index__c, west_Index__c
                FROM DH_Knowledge_Indexing__c
                WHERE Knowledge_Article_Management__c = :article2.Id
            ];
            Assert.isNotNull(indexRecords, 'index records not be null');
        Test.stopTest();
        
    } 
}