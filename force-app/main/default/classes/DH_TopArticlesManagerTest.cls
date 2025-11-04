@isTest
public class DH_TopArticlesManagerTest {
	static void setupTestData() {
        // Create test Knowledge Articles
        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        for (Integer i = 1; i <= 6; i++) {
            articles.add(new Knowledge__kav(
                Title = 'Apex Test Article ' + i,
                Data_Category_Group__c = 'KM_Super_Users',
                West_Categories__c = 'West_KM_Super_Users',
                West_Sub_Categories__c = 'West_KM_Support_Documentation',
                East_Categories__c = 'East_KM_Super_Users',
                East_Sub_Categories__c = 'East_KM_Support_Documentation',
                Language = 'en_US',
				UrlName = 'Apex-Test' + i,                
                Global__c = True
            ));
        }
        insert articles;

        // Create Top 5 config records
        List<Top_Five_Knowledge_Articles_East__c> topRecords = new List<Top_Five_Knowledge_Articles_East__c>();
        for (Integer i = 0; i < 5; i++) {
            topRecords.add(new Top_Five_Knowledge_Articles_East__c(
                Name = 'Top ' + (i + 1),
                Order__c = i + 1,
                Knowledge_Article_Id__c = articles[i].Id
            ));
        }
        insert topRecords;
    }

    @isTest
    static void test_getSelectedTopArticles() {
        setupTestData();
        Test.startTest();
        List<Knowledge__kav> results = DH_TopArticlesManager.getSelectedTopArticles();
        Test.stopTest();
        System.assertEquals(5, results.size());
    }

    @isTest
    static void test_saveSelectedTopArticles_valid() {
        setupTestData();

        List<Knowledge__kav> allArticles = [
            SELECT Id FROM Knowledge__kav
            WHERE Language = 'en_US'
            LIMIT 5
        ];

        Test.startTest();
        DH_TopArticlesManager.saveSelectedTopArticles(new List<Id>{
            allArticles[0].Id,
            allArticles[1].Id,
            allArticles[2].Id,
            allArticles[3].Id,
            allArticles[4].Id
        });
        Test.stopTest();

        List<Top_Five_Knowledge_Articles_East__c> updated = [
            SELECT Knowledge_Article_Id__c FROM Top_Five_Knowledge_Articles_East__c
            WHERE Order__c IN (1, 2, 3, 4, 5)
        ];
        System.assertEquals(5, updated.size());
    }

    @isTest
    static void test_getAllArticles() {
        setupTestData();
        Test.startTest();
        List<Knowledge__kav> all = DH_TopArticlesManager.getAllArticles();
        Test.stopTest();
        System.assertEquals(True, !all.isEmpty(), 'Should return all en_US articles in the database');
    }
    
    @isTest
    static void test_getUserProfileName() {
        Test.startTest();
        String profileName = DH_TopArticlesManager.getUserProfileName();
        Test.stopTest();
        System.assertNotEquals(null, profileName, 'Should return the running user\'s profile name');
    }

    @isTest
    static void test_getArticlesByIds() {
        setupTestData();
        List<Knowledge__kav> articles = [SELECT Id FROM Knowledge__kav LIMIT 3];

        Test.startTest();
        List<Knowledge__kav> result = DH_TopArticlesManager.getArticlesByIds(new List<Id>{
            articles[0].Id, articles[1].Id, articles[2].Id
        });
        Test.stopTest();

        System.assertEquals(3, result.size());
    }
}