/******************************************************************************************************************************************************
 * 
 * @Created Date    : 17/05/2024
 * 
 * @description     : This test class verifies the functionality of the DH_knowledgeSearchController class
 * 
 * @Jira Id         : CC-328, CC-964
 * 
 * */ 
@isTest (seeAllData =false)
public class DH_knowledgeSearchControllerTest {

  public static String eastCtgApi;
  public static String eastsubCtgApi;
  public static String westCtgApi;
  public static String westSubCtgApi;
  public static String eastctgLabel;
  public static String eastsubCtgLabel;
  public static String westctgLabel;
  public static String westsubCtgLabel;
  public static String dataCategoryGroupApiName;

  @testSetup
  private static void createData() {
    
    // PICKLIST data create     
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

    // GET LABEL FROM API NAME
    eastctgLabel = DH_KMUtility.getApiNameVsLabel(eastCtgApi, DH_KMConstants.EAST_CATEGORIES);
    eastsubCtgLabel = DH_KMUtility.getApiNameVsLabel(eastsubCtgApi, DH_KMConstants.EAST_SUB_CATEGORIES);
    westctgLabel = DH_KMUtility.getApiNameVsLabel(westCtgApi, DH_KMConstants.WEST_CATEGORIES);
    westsubCtgLabel = DH_KMUtility.getApiNameVsLabel(westSubCtgApi, DH_KMConstants.WEST_SUB_CATEGORIES);

    // TEST USER data create DH_KMConstants.RADNET_MANAGER
    Profile p = [SELECT Id FROM Profile WHERE Name =: DH_KMConstants.RADNET_MANAGER];
    User radnetManagerUserEast = new User(Alias = 'rsEast', Email = 'radSchEast@testorg.com',
      EmailEncodingKey = 'UTF-8', LastName = 'TestingEast', LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US', ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = true,
      UserName = 'radSchEast@testorg.com');
    insert radnetManagerUserEast;

    PermissionSet psEastManager = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_EAST_COAST_USER];
    PermissionSet psEastManager1 = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_MANAGER_EAST];
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = radnetManagerUserEast.Id;
    psa.PermissionSetId = psEastManager.Id;
    psa.PermissionSetId = psEastManager1.Id;
    insert psa;

    Profile p1 = [SELECT Id FROM Profile WHERE Name =: DH_KMConstants.SYSTEM_ADMINISTRATOR];
    User systemAdmin = new User(Alias = 'rsWest', Email = 'radSchWest@testorg.com',
      EmailEncodingKey = 'UTF-8', LastName = 'TestingWest', LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US', ProfileId = p1.Id,
      TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = true,
      UserName = 'radSch3West@testorg.com');
    insert systemAdmin;

    Profile radnetM = [SELECT Id FROM Profile WHERE Name =: DH_KMConstants.RADNET_SCHEDULER];
    User uEst3 = new User(Alias = 'userEst', Email = 'radSchWest@testorg.com',
      EmailEncodingKey = 'UTF-8', LastName = 'TestingWest', LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US', ProfileId = radnetM.Id,
      TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = true,
      UserName = 'radSch34@torg.com');
    insert uEst3;

    PermissionSet pUserEast = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_EAST_COAST_USER];
    PermissionSetAssignment psaUserEast = new PermissionSetAssignment();
    psaUserEast.AssigneeId = uEst3.Id;
    psaUserEast.PermissionSetId = pUserEast.Id;
    insert psaUserEast;

    Profile radnetsch = [SELECT Id FROM Profile WHERE Name =: DH_KMConstants.RADNET_SCHEDULER];
    User userWest = new User(Alias = 'userWest', Email = 'radSchWest@testorg.com',
      EmailEncodingKey = 'UTF-8', LastName = 'TestingWest', LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US', ProfileId = radnetsch.Id,
      TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = true,
      UserName = 'radSch45West@testorg.com');
    insert userWest;

    PermissionSet pUserWest = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.KNOWLEDGE_SEARCH_WEST_COAST_USER];
    PermissionSetAssignment psaUserWest = new PermissionSetAssignment();
    psaUserWest.AssigneeId = userWest.Id;
    psaUserWest.PermissionSetId = pUserWest.Id;
    insert psaUserWest;

    User radnetAdmin = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com'
      LIMIT 1
    ];
    System.runAs(radnetAdmin) {

        // KA record data create 
        Knowledge__kav article = new Knowledge__kav();
        article.Title = 'Test Knowledge CT Article 5';
        article.UrlName = 'Test-Knowledge-Article-5';
        article.Global__c = true;
        article.East_Categories__c = eastCtgApi;
        article.East_Sub_Categories__c = eastsubCtgApi;
        article.West_Categories__c = westCtgApi;
        article.West_Sub_Categories__c = westSubCtgApi;
        article.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article;
      
        Knowledge__kav article1 = new Knowledge__kav();
        article1.Title = 'Test Knowledge CT Article 6';
        article1.UrlName = 'Test-Knowledge-Article-6';
        article1.Global__c = true;
        article1.East_Categories__c = eastCtgApi;
        article1.East_Sub_Categories__c = eastsubCtgApi;
        article1.West_Categories__c = westCtgApi;
        article1.West_Sub_Categories__c = westSubCtgApi;
        article1.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article1;

        Knowledge__kav article2 = new Knowledge__kav();
        article2.Title = 'Test Knowledge CT Article 7';
        article2.UrlName = 'Test-Knowledge-Article-7';
        article2.Global__c = true;
        article2.East_Categories__c = eastCtgApi;
        article2.East_Sub_Categories__c = eastsubCtgApi;
        article2.West_Categories__c = westCtgApi;
        article2.West_Sub_Categories__c = westSubCtgApi;
        article2.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article2;

        Knowledge__kav article3 = new Knowledge__kav();
        article3.Title = 'Test Knowledge CT Article 8';
        article3.UrlName = 'Test-Knowledge-Article-8';
        article3.Global__c = true;
        article3.East_Categories__c = eastCtgApi;
        article3.East_Sub_Categories__c = eastsubCtgApi;
        article3.West_Categories__c = westCtgApi;
        article3.West_Sub_Categories__c = westSubCtgApi;
        article3.Data_Category_Group__c = dataCategoryGroupApiName;
        insert article3;

      List < knowledge__kav > obj1 = [SELECT Id, Title, Details__c, KnowledgeArticleId FROM knowledge__kav];

      KbManagement.PublishingService.publishArticle(obj1[0].KnowledgeArticleId, true);
      KbManagement.PublishingService.publishArticle(obj1[1].KnowledgeArticleId, true);
      KbManagement.PublishingService.publishArticle(obj1[2].KnowledgeArticleId, true);

    }
      
    	String guestUserName = 'guestuser' + DateTime.now().getTime() + '@testorg.com';
        Profile guestProfile = [SELECT Id, name FROM Profile WHERE Name =: DH_KMConstants.RADNET_COMMUNITY_PROFILE LIMIT 1];
        User guestUser = new User(
            Alias = 'guestT', 
            Email='guestuser@test.com', 
            FirstName = 'Guest', LastName = 'User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = guestProfile.Id,
            EmailEncodingKey='UTF-8',
            TimeZoneSidKey='America/Los_Angeles',
            UserName=guestUserName
        );
        insert guestUser;     
  }

  @isTest
  private static void testGetCategoryList() {
    // test method for  getCategoryList to fetch user coasts list category and subcategory maps - dataCategGrpNameVsDataCategNames, categVsSubcategMap, subcategLabelVsNames, categLabelVsNames
    User u = [SELECT Id FROM User WHERE UserName = 'radSch34@torg.com'
      LIMIT 1
    ];
    System.runAs(u) {

      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
      String selectedCoast = 'East';
      List < Knowledge__DataCategorySelection > testData = new List < Knowledge__DataCategorySelection > ();
      testData.add(new Knowledge__DataCategorySelection(DataCategoryName = 'EAST_CT', ParentId = null, DataCategoryGroupName = dataCategoryGroupApiName));

      Test.startTest();
      DH_knowledgeSearchController.DH_knowledgeSearchControllerWrapper result = DH_knowledgeSearchController.getCategoryList(testData, false, selectedCoast);
      DH_knowledgeSearchController.DH_knowledgeSearchControllerWrapper result1 = DH_knowledgeSearchController.getCategoryList(testData, true, selectedCoast);

      System.assertNotEquals(null, result, 'test success ');
      System.assertNotEquals(null, result.dataCategGrpNameVsDataCategNames, 'test success ');
      System.assertNotEquals(null, result.categVsSubcategMap, 'test success ');
      System.assertNotEquals(null, result.subcategLabelVsNames, 'test success ');
      System.assertNotEquals(null, result.categLabelVsNames, 'test success ');

      System.assertNotEquals(null, result1, 'test success ');
      System.assertNotEquals(null, result1.dataCategGrpNameVsDataCategNames, 'test success ');
      System.assertNotEquals(null, result1.categVsSubcategMap, 'test success ');
      System.assertNotEquals(null, result1.subcategLabelVsNames, 'test success ');
      System.assertNotEquals(null, result1.categLabelVsNames, 'test success ');
      Test.stopTest();
    }
  }

  @isTest
  private static void testGetArticleListNoCategories() {
    // test method to get wrapper of Article List selected category is not in existing categories
    User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com'
      LIMIT 1
    ];
    System.runAs(u) {
      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
      
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
        
      String selectedSubCtg = 'EAST_CT';
      Map < String, List < String >> catLableVsApiName = new Map < String, List < String >> ();
      
      Map < String, List < String >> groupVsCatName = new Map < String, List < String >> ();
      groupVsCatName.put(dataCategoryGroupApiName, new List < String > { westCtgApi, westSubCtgApi });
      
      List < String > coasts = new List < String > ();
      coasts.add(DH_KMConstants.COAST_EAST);
      Test.startTest();
      List < DH_knowledgeSearchController.ArticleListWrapper > articleList = DH_knowledgeSearchController.getArticleList(selectedSubCtg, catLableVsApiName, null, groupVsCatName, coasts);

      System.assertNotEquals(null, articleList, 'test success ');
      System.assertEquals(0, articleList.size(), 'test success ');
      Test.stopTest();
    }
  }

  @isTest
  private static void testGetArticleListWithCategoriesAndgroupVsCatNameWest() {

    // test method to get wrapper of Article List when west coast category is selected
    // test method to get wrapper of Article List when west coast sub-category is selected

    User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com'
      LIMIT 1
    ];
    System.runAs(u) {

      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
        
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

      westctgLabel = DH_KMUtility.getApiNameVsLabel(westCtgApi, DH_KMConstants.WEST_CATEGORIES);
      westsubCtgLabel = DH_KMUtility.getApiNameVsLabel(westSubCtgApi, DH_KMConstants.WEST_SUB_CATEGORIES);

      List < Knowledge__kav > ka = [SELECT Id, Title from Knowledge__kav Limit 2];

      List < Knowledge__DataCategorySelection > testDataList = [Select id, DataCategoryName, ParentId, DataCategoryGroupName
        from Knowledge__DataCategorySelection
      ];
      List < Knowledge__DataCategorySelection > testData = new List < Knowledge__DataCategorySelection > ();
      for (Knowledge__DataCategorySelection i: testDataList) {
        if (i.ParentId == ka[0].Id || i.ParentId == ka[1].Id) {
          testData.add(i);
        }
      }

      String selectedSubCtg = westCtgApi;
      Map < String, List < String >> catLableVsApiName = new Map < String, List < String >> ();
      catLableVsApiName.put(westctgLabel, new List < String > {
        westCtgApi
      });
      Map < String, List < String >> subCatLableVsApiName = new Map < String, List < String >> ();
      subCatLableVsApiName.put(westsubCtgLabel, new List < String > {
        westSubCtgApi
      });
      Map < String, List < String >> groupVsCatName = new Map < String, List < String >> ();
      groupVsCatName.put(dataCategoryGroupApiName, new List < String > {
        westCtgApi,
        westSubCtgApi
      });
      List < String > coasts = new List < String > ();
      coasts.add(DH_KMConstants.COAST_WEST);

      Test.startTest();
      List < DH_knowledgeSearchController.ArticleListWrapper > articleList =
        DH_knowledgeSearchController.getArticleList(westctgLabel, catLableVsApiName, null, groupVsCatName, coasts);

      List < DH_knowledgeSearchController.ArticleListWrapper > articleList1 =
        DH_knowledgeSearchController.getArticleList(westsubCtgLabel, null, subCatLableVsApiName, groupVsCatName, coasts);

      System.assertNotEquals(null, articleList, 'test success ');
      System.assertNotEquals(null, articleList1, 'test success ');

      Test.stopTest();
    }
  }

  @isTest
  private static void testGetArticleListWithCategoriesAndgroupVsCatNameEast() {
    
    // test method to get wrapper of Article List when east coast category is selected
    // test method to get wrapper of Article List when east coast sub-category is selected
    
    User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com'
      LIMIT 1
    ];
    System.runAs(u) {

      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
        
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

      eastctgLabel = DH_KMUtility.getApiNameVsLabel(eastCtgApi, DH_KMConstants.EAST_CATEGORIES);
      eastsubCtgLabel = DH_KMUtility.getApiNameVsLabel(eastsubCtgApi, DH_KMConstants.EAST_SUB_CATEGORIES);

      List < Knowledge__kav > ka = [SELECT Id, Title from Knowledge__kav Limit 2];

      List < Knowledge__DataCategorySelection > testDataList = [Select id, DataCategoryName, ParentId, DataCategoryGroupName
        from Knowledge__DataCategorySelection
      ];
      List < Knowledge__DataCategorySelection > testData = new List < Knowledge__DataCategorySelection > ();
      for (Knowledge__DataCategorySelection i: testDataList) {
        if (i.ParentId == ka[0].Id || i.ParentId == ka[1].Id) {
          testData.add(i);
        }
      }

      String selectedSubCtg = eastCtgApi;
      Map < String, List < String >> catLableVsApiName = new Map < String, List < String >> ();
      catLableVsApiName.put(eastctgLabel, new List < String > {
        eastCtgApi
      });
      Map < String, List < String >> subCatLableVsApiName = new Map < String, List < String >> ();
      subCatLableVsApiName.put(eastsubCtgLabel, new List < String > {
        eastsubCtgApi
      });
      Map < String, List < String >> groupVsCatName = new Map < String, List < String >> ();
      groupVsCatName.put(dataCategoryGroupApiName, new List < String > {
        eastCtgApi,
        eastsubCtgApi
      });
      List < String > coasts = new List < String > ();
      coasts.add(DH_KMConstants.COAST_EAST);

      Test.startTest();
      List < DH_knowledgeSearchController.ArticleListWrapper > articleList =
        DH_knowledgeSearchController.getArticleList(eastctgLabel, catLableVsApiName, null, groupVsCatName, coasts);

      List < DH_knowledgeSearchController.ArticleListWrapper > articleList1 =
        DH_knowledgeSearchController.getArticleList(eastsubCtgLabel, null, subCatLableVsApiName, groupVsCatName, coasts);

      System.assertNotEquals(null, articleList, 'test success ');
      System.assertNotEquals(null, articleList1, 'test success ');

      Test.stopTest();
    }
  }

  @isTest
  private static void testSortArticlesByIndexClassNullIndex() {
    // test method to sort Article List when one article index is null

    User u = [SELECT Id FROM User WHERE UserName = 'radSch45West@testorg.com'
      LIMIT 1
    ];
    System.runAs(u) {

      Knowledge__kav article1 = new Knowledge__kav();
      Knowledge__kav article2 = new Knowledge__kav(Index__c = 2);
      List < String > coasts = new List < String > ();
      coasts.add(DH_KMConstants.COAST_WEST);
	  List < String > coasts1 = new List < String > ();
      coasts1.add(DH_KMConstants.COAST_EAST);
      
      DH_knowledgeSearchController.SortArticlesByIndexClass sorter = new DH_knowledgeSearchController.SortArticlesByIndexClass(coasts);
      Integer comparisonResult = sorter.compare(article1, article2);
      
      DH_knowledgeSearchController.SortArticlesByIndexClass sorter1 = new DH_knowledgeSearchController.SortArticlesByIndexClass(coasts1);
      Integer comparisonResult1 = sorter.compare(article1, article2);

      System.assertNotEquals(null, comparisonResult, 'test success ');
      System.assertNotEquals(null, comparisonResult1, 'test success ');

    }
  }

  @isTest
  private static void testGetArticleListNoSubCategories() {
    // test method to get wrapper of Article List when east coast category selected is not in existing categories

    User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com'
      LIMIT 1
    ];
    System.runAs(u) {

      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
      
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
        
      String selectedSubCtg = 'TestCategory';
      Map < String, List < String >> subCatLableVsApiName = new Map < String, List < String >> ();
        
      Map < String, List < String >> groupVsCatName = new Map < String, List < String >> ();
      groupVsCatName.put(dataCategoryGroupApiName, new List < String > { westCtgApi, westSubCtgApi });
        
      List < String > coasts = new List < String > ();
      coasts.add(DH_KMConstants.COAST_EAST);

      Test.startTest();
      List < DH_knowledgeSearchController.ArticleListWrapper > articleList =
        DH_knowledgeSearchController.getArticleList(selectedSubCtg, null, subCatLableVsApiName, groupVsCatName, coasts);

      System.assertNotEquals(null, articleList, 'test success ');
      Test.stopTest();
    }
  }

  @isTest
  private static void testGetKnowledgeDataCategorySelection() {
    // test method to get Knowledge__DataCategorySelection records List 

    User u = [SELECT Id FROM User WHERE Email = 'radSchEast@testorg.com'
      LIMIT 1
    ];
    System.runAs(u) {
      Test.startTest();
      List < Knowledge__DataCategorySelection > datacatgoryselectionList = DH_knowledgeSearchController.getKnowledgeDataCategorySelection(null, true);
      List < Knowledge__DataCategorySelection > datacatgoryselectionList1 = DH_knowledgeSearchController.getKnowledgeDataCategorySelection(null, false);

      System.assertEquals(null, datacatgoryselectionList, 'test success ');
      System.assertNotEquals(null, datacatgoryselectionList1, 'test success ');

      Test.stopTest();
    }
  }
    
    @isTest
  private static void testGetCategoryListForGuest() {
    // test method for getCategoryList to fetch user coasts list category and subcategory maps for Guest User
    User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];

    System.runAs(guestUser) {

      dataCategoryGroupApiName = DH_KMUtility.getDataCategoryGroupApiName(DH_KMConstants.DATA_CATEGORY_GROUP);
      String selectedCoast = 'West';
      List < Knowledge__DataCategorySelection > testData = new List < Knowledge__DataCategorySelection > ();
      testData.add(new Knowledge__DataCategorySelection(DataCategoryName = 'WEST_CT', ParentId = null, DataCategoryGroupName = dataCategoryGroupApiName));

      Test.startTest();
      DH_knowledgeSearchController.DH_knowledgeSearchControllerWrapper result = DH_knowledgeSearchController.getCategoryList(testData, false, selectedCoast);

      System.assertNotEquals(null, result, 'test success ');
      System.assertNotEquals(null, result.dataCategGrpNameVsDataCategNames, 'test success ');
      System.assertNotEquals(null, result.categVsSubcategMap, 'test success ');
      System.assertNotEquals(null, result.subcategLabelVsNames, 'test success ');
      System.assertNotEquals(null, result.categLabelVsNames, 'test success ');

      Test.stopTest();
    }
  }

  @isTest
  private static void testCompareIndexEast() {
    // test method to sort Article List when one article index is null

    User u = [SELECT Id FROM User WHERE UserName = 'radSch45West@testorg.com'
      LIMIT 1
    ];
    System.runAs(u) {

      List <Knowledge__kav> kaList = [select id, title,East_Categories__c, East_Sub_Categories__c, Data_Category_Group__c, (select id, Index__c, west_Index__c from Knowledge_Indexing__r where Index__c >2) from Knowledge__kav limit 1];
      List <Knowledge__kav> kaList1 = [select id, title,East_Categories__c, East_Sub_Categories__c, Data_Category_Group__c, (select id, Index__c, west_Index__c from Knowledge_Indexing__r where Index__c <2) from Knowledge__kav limit 1];
      List < String > coasts = new List < String > ();
      coasts.add(DH_KMConstants.COAST_EAST);

      DH_knowledgeSearchController.SortArticlesByIndexClass sorter = new DH_knowledgeSearchController.SortArticlesByIndexClass(coasts);
      Integer comparisonResult = sorter.compare(kaList[0], kaList1[0]);
      Integer comparisonResult1 = sorter.compare(kaList1[0], kaList[0]);

      System.assertNotEquals(null, comparisonResult, 'test success ');
      System.assertNotEquals(null, comparisonResult1, 'test success ');

    }
  }
    @isTest
  private static void testCompareIndexWest() {
    // test method to sort Article List when one article index is null

    User u = [SELECT Id FROM User WHERE UserName = 'radSch45West@testorg.com'
      LIMIT 1
    ];
    System.runAs(u) {

      List <Knowledge__kav> kaList = [select id, title,East_Categories__c, East_Sub_Categories__c, Data_Category_Group__c, (select id, Index__c, west_Index__c from Knowledge_Indexing__r where west_Index__c >2) from Knowledge__kav limit 1];
      List <Knowledge__kav> kaList1 = [select id, title,East_Categories__c, East_Sub_Categories__c, Data_Category_Group__c, (select id, Index__c, west_Index__c from Knowledge_Indexing__r where west_Index__c <2) from Knowledge__kav limit 1];
      List < String > coasts = new List < String > ();
      coasts.add(DH_KMConstants.COAST_WEST);

      DH_knowledgeSearchController.SortArticlesByIndexClass sorter = new DH_knowledgeSearchController.SortArticlesByIndexClass(coasts);
      Integer comparisonResult = sorter.compare(kaList[0], kaList1[0]);
      Integer comparisonResult1 = sorter.compare(kaList1[0], kaList[0]);

      System.assertNotEquals(null, comparisonResult, 'test success ');
      System.assertNotEquals(null, comparisonResult1, 'test success ');


    }
  }
}