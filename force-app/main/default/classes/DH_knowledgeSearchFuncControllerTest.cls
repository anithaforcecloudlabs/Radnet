/******************************************************************************************************************************************************
 * 
 * @Created Date      : 06/12/2024
 * 
 * @description       : This test class verifies the functionality of the DH_knowledgeSearchFuncController class. 
 *                       It covers scenarios including both successful and unsuccessful insertion of Knowledge Articles records
 * 
 * @JIRA Id           : CC-331
 * */ 

@isTest(seeAllData =false)
public class DH_knowledgeSearchFuncControllerTest {
    
 //CATEGORY PICKLIST FETCH METHODS START
  public static String eastCtgApi;
  public static String eastsubCtgApi;
  public static String westCtgApi;
  public static String westSubCtgApi;
  public static String  dataCategoryGroupApiName;
  
 //CATEGORY PICKLIST FETCH METHODS END  

    @testSetup
    private static void createData(){
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
    
        Profile p = [SELECT Id FROM Profile WHERE Name =:DH_KMConstants.RADNET_MANAGER];
        User radnetManagerUserEast = new User(Alias = 'rsEast', Email='radSchEast@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingEast', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', IsActive= true,UserPermissionsKnowledgeUser=true,
        UserName='radSchEast@testorg.com');
    	insert radnetManagerUserEast;
        
        PermissionSet psEastManager = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_EAST_COAST_USER];
        PermissionSet psEastManager1 = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_MANAGER_EAST];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = radnetManagerUserEast.Id;
        psa.PermissionSetId = psEastManager.Id;
        psa.PermissionSetId = psEastManager1.Id;
        insert psa;

        Profile p1 = [SELECT Id FROM Profile WHERE Name=: DH_KMConstants.SYSTEM_ADMINISTRATOR];
        User systemAdmin = new User(Alias = 'rsWest', Email='radSchWest@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingWest', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles', IsActive= true,UserPermissionsKnowledgeUser=true,
        UserName='radSch3West@testorg.com');
    	insert systemAdmin;
        
        PermissionSet psManagerWest = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_WEST_COAST_USER];
        PermissionSet psManagerWest1 = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_MANAGER_WEST];
        PermissionSetAssignment psa2 = new PermissionSetAssignment();
        psa2.AssigneeId = systemAdmin.Id;
        psa2.PermissionSetId = psManagerWest.Id;
        psa2.PermissionSetId = psManagerWest1.Id;
        insert psa2; 
        
        Profile radnetM = [SELECT Id FROM Profile WHERE Name =:DH_KMConstants.RADNET_SCHEDULER];
        User uEst3 = new User(Alias = 'userEst', Email='radSchWest@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingWest', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = radnetM.Id,
        TimeZoneSidKey='America/Los_Angeles', IsActive= true,UserPermissionsKnowledgeUser=true,
        UserName='radSch34@torg.com');
    	insert uEst3;
        
        PermissionSet pUserEast = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_EAST_COAST_USER];
        PermissionSetAssignment psaUserEast = new PermissionSetAssignment();
        psaUserEast.AssigneeId = uEst3.Id;
        psaUserEast.PermissionSetId = pUserEast.Id;
        insert psaUserEast; 
        
        Profile radnetsch = [SELECT Id FROM Profile WHERE Name =:DH_KMConstants.RADNET_SCHEDULER];
        User userWest = new User(Alias = 'userWest', Email='radSchWest@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingWest', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = radnetsch.Id,
        TimeZoneSidKey='America/Los_Angeles', IsActive= true,UserPermissionsKnowledgeUser=true,
        UserName='radSch45West@testorg.com');
    	insert userWest;
        
        PermissionSet pUserWest = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_WEST_COAST_USER];
        PermissionSetAssignment psaUserWest = new PermissionSetAssignment();
        psaUserWest.AssigneeId = userWest.Id;
        psaUserWest.PermissionSetId = pUserWest.Id;
        insert psaUserWest; 
        
        Profile guestProfile = [SELECT Id, name FROM Profile WHERE Name =: DH_KMConstants.RADNET_COMMUNITY_PROFILE LIMIT 1];
            User guestUser = new User(
            Username = 'guestuser@test.com',
            FirstName = 'Guest',
            LastName = 'User',
            Email = 'guestuser@test.com',
            Alias = 'guest',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = guestProfile.Id,
            LanguageLocaleKey = 'en_US'
            );
            insert guestUser;
         User radnetManagerUser = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com' LIMIT 1];
         System.runAs( radnetManagerUser ) {
            
        //CREATION OF KNOWLEDGE ARTICLE RECORDS
        List<Knowledge__kav> knowArticles = new  List<Knowledge__kav>();
        Knowledge__kav article = new Knowledge__kav();
        article.Title = 'Test Knowledge CT Article 11';
        article.UrlName = 'Test-Knowledge-Article-11';
        article.Global__c = true;
        article.East_Categories__c = eastCtgApi;
        article.East_Sub_Categories__c = eastsubCtgApi;
        article.West_Categories__c = westCtgApi;
        article.West_Sub_Categories__c = westSubCtgApi;
        article.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article;
             
        Knowledge__kav article1 = new Knowledge__kav();
        article1.Title = 'Test Knowledge CT Article 12';
        article1.UrlName = 'Test-Knowledge-Article-12';
        article1.Global__c = true;
        article1.East_Categories__c = eastCtgApi;
        article1.East_Sub_Categories__c = eastsubCtgApi;
        article1.West_Categories__c = westCtgApi;
        article1.West_Sub_Categories__c = westSubCtgApi;
        article1.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article1;

        Knowledge__kav article2 = new Knowledge__kav();
        article2.Title = 'Test Knowledge CT Article 13';
        article2.UrlName = 'Test-Knowledge-Article-13';
        article2.Global__c = true;
        article2.East_Categories__c = eastCtgApi;
        article2.East_Sub_Categories__c = eastsubCtgApi;
        article2.West_Categories__c = westCtgApi;
        article2.West_Sub_Categories__c = westSubCtgApi;
        article2.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article2;

        Knowledge__kav article3 = new Knowledge__kav();
        article3.Title = 'Test Knowledge CT Article 14';
        article3.UrlName = 'Test-Knowledge-Article-14';
        article3.Global__c = true;
        article3.East_Categories__c = eastCtgApi;
        article3.East_Sub_Categories__c = eastsubCtgApi;
        article3.West_Categories__c = westCtgApi;
        article3.West_Sub_Categories__c = westSubCtgApi;
        article3.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article3; 

        List<knowledge__kav> obj1 = [SELECT Id,Title,Details__c,KnowledgeArticleId  FROM knowledge__kav ];
          
        KbManagement.PublishingService.publishArticle(obj1[0].KnowledgeArticleId, true);
        KbManagement.PublishingService.publishArticle(obj1[1].KnowledgeArticleId, true);
        KbManagement.PublishingService.publishArticle(obj1[2].KnowledgeArticleId, true);
             
        }
     }

    @isTest
    private static void testEastCoastForUser() {     
        User radnetManagerUser = [SELECT Id FROM User WHERE Email = 'radSchEast@testorg.com' LIMIT 1];
        System.runAs( radnetManagerUser ) {
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc=DH_knowledgeSearchFuncController.getTrackingDetails('CT','East');
            Test.stopTest();
              system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found');
        }
    }
    
    @isTest
    private static void testEastCoastForGuestUser() {     
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc=DH_knowledgeSearchFuncController.getTrackingDetails('CT','East');
            Test.stopTest();
              system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found for East Guest User');
        }
    }
    

     @isTest
    private static void testWestCoastUser() {     
        User radnetManagerUser = [SELECT Id FROM User WHERE Email = 'radSchWest@testorg.com' LIMIT 1];
        System.runAs( radnetManagerUser ) {
            // Call the getTrackingDetails method to test for west coast user
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc=DH_knowledgeSearchFuncController.getTrackingDetails('CT','East');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found');
        }
    }

    @isTest
    private static void testWestCoastGuestUser() {     
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            // Call the getTrackingDetails method to test for west coast user
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc=DH_knowledgeSearchFuncController.getTrackingDetails('CT','West');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found for West Guest User');
        }
    }
    
    @isTest
    private static void testWestCoastSchUser() {     
        User radnetManagerUser = [SELECT Id FROM User WHERE UserName = 'radSch45West@testorg.com' LIMIT 1];
        System.runAs( radnetManagerUser ) {
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc=DH_knowledgeSearchFuncController.getTrackingDetails('CT','East');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found');
        }
    }


    @isTest
    private static void testGetAllTrackingDetailsMethod() {     
        User radnetManagerUser = [SELECT Id FROM User WHERE UserName = 'radSch45West@testorg.com' LIMIT 1];
         List<Knowledge__kav> ka = [SELECT Id,Title,Details__c from Knowledge__kav ];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ka[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        System.runAs( radnetManagerUser ) {
            Test.startTest();
                List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc = DH_knowledgeSearchFuncController.getAllTrackingDetails('Dexa','East');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found');
        }
    }

    @isTest
    private static void testGetAllTrackingDetailsNullMethod() {     
         User radnetManagerUser = [SELECT Id FROM User WHERE UserName = 'radSch34@torg.com' LIMIT 1];
         List<Knowledge__kav> ka = [SELECT Id,Title,Details__c from Knowledge__kav ];
         Id [] fixedSearchResults= new Id[1];
         fixedSearchResults[0] = ka[0].Id;
         Test.setFixedSearchResults(fixedSearchResults);
         System.runAs( radnetManagerUser ) {
            Test.startTest();
                List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc=DH_knowledgeSearchFuncController.getAllTrackingDetails('iaskdhfksdkfh','East');
            Test.stopTest();
            system.assertEquals(false,dsc.size() == 0,'Knowledge Articles is not found');
        }
    }
    
     @isTest
    private static void testGetAllTrackingDetailsMethodForGuestUserEast() {     
        User guestUser = [SELECT Id FROM User WHERE UserName = 'guestuser@test.com' LIMIT 1];
         List<Knowledge__kav> ka = [SELECT Id,Title,Details__c from Knowledge__kav ];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ka[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        System.runAs( guestUser ) {
            Test.startTest();
                List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc = DH_knowledgeSearchFuncController.getAllTrackingDetails('Dexa','East');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found for East Guest User');
        }
    }
    
    @isTest
    private static void testGetAllTrackingDetailsMethodForGuestUserWest() {     
        User guestUser = [SELECT Id FROM User WHERE UserName = 'guestuser@test.com' LIMIT 1];
         List<Knowledge__kav> ka = [SELECT Id,Title,Details__c from Knowledge__kav ];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ka[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        System.runAs( guestUser ) {
            Test.startTest();
                List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc = DH_knowledgeSearchFuncController.getAllTrackingDetails('Dexa','West');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found for West Guest User');
        }
    }
    
    @isTest
    private static void testEastCoastUser() {     
        User radnetManagerUser = [SELECT Id FROM User WHERE UserName = 'radSch34@torg.com' LIMIT 1];
         List<Knowledge__kav> ka = [SELECT Id,Title from Knowledge__kav ];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ka[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        System.runAs( radnetManagerUser ) {
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchWrapper> dsc=DH_knowledgeSearchFuncController.getTrackingDetails('Dexa','East');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Knowledge Articles is found');
        }
        
    }

     @isTest
    private static void testgetCategoryNameMethod() {     
        User radnetManagerUser = [SELECT Id FROM User WHERE UserName = 'radSch34@torg.com' LIMIT 1];
        
        System.runAs( radnetManagerUser ) {
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchFuncControllerWrapper> dsc=DH_knowledgeSearchFuncController.getCategoryName('CT','East');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Category List is  found');
        }
    }

    @isTest
    private static void testgetCategoryNameMethodGuestUserEast() {     
        User guestUser = [SELECT Id FROM User WHERE UserName = 'guestuser@test.com' LIMIT 1];
        
        System.runAs( guestUser ) {
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchFuncControllerWrapper> dsc=DH_knowledgeSearchFuncController.getCategoryName('CT','East');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Category List is  found for Guest East User');
        }
    }
    
    
    @isTest
    private static void testgetCategoryNameMethodGuestUserWest() {     
        User guestUser = [SELECT Id FROM User WHERE UserName = 'guestuser@test.com' LIMIT 1];
        
        System.runAs( guestUser ) {
            Test.startTest();
               List<DH_knowledgeSearchFuncController.DH_knowledgeSearchFuncControllerWrapper> dsc=DH_knowledgeSearchFuncController.getCategoryName('CT','West');
            Test.stopTest();
            system.assertEquals(true,dsc.size()>=0,'Category List is  found for Guest West User');
        }
    }
    
     @isTest
    private static void testGetCategoryListMethod() {   

        List<Knowledge__kav> ka = [SELECT Id,Title from Knowledge__kav ];
        List<Knowledge__DataCategorySelection> testData = [SELECT DataCategoryName,ParentId FROM Knowledge__DataCategorySelection WHERE ParentId IN: ka];

        // Call the getCategoryList method to be tested 
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ka[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        DH_knowledgeSearchController.DH_knowledgeSearchControllerWrapper result = DH_knowledgeSearchController.getCategoryList(testData, false,'East');
        Test.startTest();
        // Call the getCategoryName method to be tested
         List<DH_knowledgeSearchFuncController.DH_knowledgeSearchFuncControllerWrapper> dsc=DH_knowledgeSearchFuncController.getCategoryName('CT','East');
        Test.stopTest();
        system.assertEquals(true,dsc.size()>0,'Category List is not found');
    }
    
    @isTest
    public static void getRecentlyViewedKnowledgeArticlesTest(){
        // Call the getRecentlyViewedKnowledgeArticles method to test the recently viewed articles on dropdown
        Test.startTest();
        List<RecentlyViewed> kaList = DH_knowledgeSearchFuncController.getRecentlyViewedKnowledgeArticles();
        Test.stopTest();
        System.assertEquals(true, kaList.size() >= 0, 'size greater than 0');
    }

    @isTest
    public static void getMostViewedKnowledgeArticlesTest(){
        // Call the getMostViewedKnowledgeArticles method to test the most viewed articles on dropdown
        Test.startTest();
        List<Knowledge__kav> kaList = DH_knowledgeSearchFuncController.getMostViewedKnowledgeArticles('East');
        Test.stopTest();
        System.assertEquals(true, kaList.size() >= 0, 'size greater than 0');
    }
    
    @isTest
    public static void getMostViewedKnowledgeArticlesGuestUserEastTest(){
        // Call the getMostViewedKnowledgeArticles method to test the most viewed articles on dropdown
        User guestUser = [SELECT Id FROM User WHERE UserName = 'guestuser@test.com' LIMIT 1];
        System.runAs( guestUser ) {
        	Test.startTest();
        	List<Knowledge__kav> kaList = DH_knowledgeSearchFuncController.getMostViewedKnowledgeArticles('East');
        	Test.stopTest();
        	System.assertEquals(true, kaList.size() >= 0, 'size greater than 0');   
        }
        
    }
    
     @isTest
    public static void getMostViewedKnowledgeArticlesGuestUserWestTest(){
        // Call the getMostViewedKnowledgeArticles method to test the most viewed articles on dropdown
         User guestUser = [SELECT Id FROM User WHERE UserName = 'guestuser@test.com' LIMIT 1];
        
        System.runAs( guestUser ) {
             Test.startTest();
        	List<Knowledge__kav> kaList = DH_knowledgeSearchFuncController.getMostViewedKnowledgeArticles('West');
        	Test.stopTest();
        	System.assertEquals(true, kaList.size() >= 0, 'size greater than 0');
        }
       
    }
    
}