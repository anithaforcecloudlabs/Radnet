public with sharing class KnowledgeArticleController {
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getArticles() {
        return [SELECT Id, Title, Summary 
                FROM Knowledge__kav 
                WHERE PublishStatus='Online' AND Language='en_US'
                LIMIT 50];
    }
}