/*
* ***************************************************************************************************************************
* Apex Class Name - DH_TopArticlesManager
* Created Date - 21-May-2025
* @description       : Apex Class Controller for Top 5 Knowledge Management Articles East
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1534                   21-May-2025         Defined all functions required essential for Top KM East functionality
* ************************************************************************************************************************************
*/
public class DH_TopArticlesManager {
    
    // Method to fetch current selected top 5 articles
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getSelectedTopArticles() {
        List<Top_Five_Knowledge_Articles_East__c > topRecords = [
            SELECT Knowledge_Article_Id__c, Order__c
            FROM Top_Five_Knowledge_Articles_East__c 
            ORDER BY Order__c ASC
        ];
    
        List<Id> articleIds = new List<Id>();
        for (Top_Five_Knowledge_Articles_East__c  record : topRecords) {
            if (String.isNotBlank(record.Knowledge_Article_Id__c)) {
                articleIds.add(record.Knowledge_Article_Id__c);
            }
        }
    
        if (articleIds.isEmpty()) return new List<Knowledge__kav>();
    
        // Fetch all articles in one query
        Map<Id, Knowledge__kav> articleMap = new Map<Id, Knowledge__kav>(
            [SELECT Id, Title FROM Knowledge__kav WHERE Id IN :articleIds]
        );
    
        // Rebuild list in Order__c sequence
        List<Knowledge__kav> orderedArticles = new List<Knowledge__kav>();
        for (Top_Five_Knowledge_Articles_East__c  record : topRecords) {
            if (articleMap.containsKey(record.Knowledge_Article_Id__c)) {
                orderedArticles.add(articleMap.get(record.Knowledge_Article_Id__c));
            }
    	}

    	return orderedArticles;
	}
	
    // Method to save newly selected top 5 KM Articles 
    @AuraEnabled
    public static void saveSelectedTopArticles(List<Id> articleIds) {
        if (articleIds == null || articleIds.size() != 5) {
            throw new AuraHandledException('Exactly 5 articles must be selected.');
        }

        // Fetch existing Top 5 article config records by Order__c
        List<Top_Five_Knowledge_Articles_East__c > existingRecords = [
            SELECT Id, Order__c, Knowledge_Article_Id__c
            FROM Top_Five_Knowledge_Articles_East__c 
            WHERE Order__c IN (1, 2, 3, 4, 5)
        ];

        Map<Integer, Top_Five_Knowledge_Articles_East__c > orderMap = new Map<Integer, Top_Five_Knowledge_Articles_East__c >();
        for (Top_Five_Knowledge_Articles_East__c  record : existingRecords) {
            orderMap.put((Integer)record.Order__c, record);
        }

        List<Top_Five_Knowledge_Articles_East__c > updates = new List<Top_Five_Knowledge_Articles_East__c >();
        for (Integer i = 0; i < articleIds.size(); i++) {
            Id articleId = articleIds[i];
            Integer orderNum = i + 1;

            if (orderMap.containsKey(orderNum)) {
                Top_Five_Knowledge_Articles_East__c  existing = orderMap.get(orderNum);
                existing.Knowledge_Article_Id__c = articleId;
                updates.add(existing);
            }
        }

        update updates;
    }
	
    // Method to get running user profile name
    @AuraEnabled(cacheable=true)
    public static String getUserProfileName() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
	
    // Method to check if running user has Knowledge_Search_Super_User PS assignment
    @AuraEnabled(cacheable=true)
    public static Boolean hasKnowledgeSuperUserPermission() {
        return [
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() 
            AND PermissionSet.Name = 'Knowledge_Search_Super_User' 
            LIMIT 1
        ].size() > 0;
    }
	
    // Method to fetch all KM articles to display in selection box
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getAllArticles() {
        return [
            SELECT Id, Title
            FROM Knowledge__kav
            LIMIT 500
        ];
    }
    
    // Method to fetch KM articles by list of record ids
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getArticlesByIds(List<Id> articleIds) {
        Map<Id, Knowledge__kav> articleMap = new Map<Id, Knowledge__kav>(
            [SELECT Id, Title FROM Knowledge__kav WHERE Id IN :articleIds]
        );

        List<Knowledge__kav> orderedArticles = new List<Knowledge__kav>();
        for (Id id : articleIds) {
            if (articleMap.containsKey(id)) {
                orderedArticles.add(articleMap.get(id));
            }
        }

        return orderedArticles;
    }

}