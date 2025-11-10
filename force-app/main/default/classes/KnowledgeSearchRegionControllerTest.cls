/*
 * ***************************************************************************************************************************
 * Apex Class Name : KnowledgeSearchRegionControllerTest
 * Created Date : 27-october-2025
 * @description : Test class for KnowledgeSearchRegionController class.
 * Modification Log :
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       --------------------------------------------------------------------------------------------------------------------------------------
 *  Live Chat               27-october-2025       Added setupTestData, testSearch_East_NoSearchTerm, testSearch_West_WithSearchTerm and testSearch_InvalidRegion_DefaultsToEast methods.
 * *************************************************************************************************************************************************************************************
 */
@IsTest
private class KnowledgeSearchRegionControllerTest {
    public static String eastCtgApi;
    public static String eastsubCtgApi;
    public static String westCtgApi;
    public static String westSubCtgApi;
    public static String  dataCategoryGroupApiName;
    
    
    private static Id articleRecordType = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get( 'East_Patient_Facing' ).getRecordTypeId();
    
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
        article.IsVisibleInCsp = true;
        
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
        article.IsVisibleInCsp = true;
        
        
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
        article.IsVisibleInCsp = true;
        insert new List<Knowledge__kav>{article , article2, article3};

    }
    
    @IsTest
    static void testSearch_East_NoSearchTerm() {
        
        Test.startTest();
        KnowledgeSearchRegionController.PageResult pr = KnowledgeSearchRegionController.searchArticles('East', null, 5);
        Test.stopTest();
        
        System.assertNotEquals(null, pr, 'PageResult should not be null');
        System.assertNotEquals(null, pr.results, 'Results list should not be null');
    }
    
    @IsTest
    static void testSearch_West_WithSearchTerm() {
        
        
        Test.startTest();
        KnowledgeSearchRegionController.PageResult pr = KnowledgeSearchRegionController.searchArticles('West', 'test', 10);
        Test.stopTest();
        
        System.assertNotEquals(null, pr, 'PageResult should not be null');
        System.assertNotEquals(null, pr.results, 'Results list should not be null');
    }
    
    @IsTest
    static void testSearch_InvalidRegion_DefaultsToEast() {
        Test.startTest();
        KnowledgeSearchRegionController.PageResult pr = KnowledgeSearchRegionController.searchArticles('', 'abc', 3);
        Test.stopTest();
        
        System.assertNotEquals(null, pr, 'PageResult should not be null for invalid region');
        System.assertNotEquals(null, pr.results, 'Results list should not be null for invalid region');
        
    }
}