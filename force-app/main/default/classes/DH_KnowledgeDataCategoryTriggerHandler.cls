/*

 *********************************************************

Apex Class         : DH_KnowledgeDataCategoryTriggerHandler
    
Created Date       : June 11, 2024
    
@description       : trigger handler for knowledge.kav object to set auto indexing for knowledge indexing record called from trigger KnowledgeDataCategory

@jiraid            : CC-330, CC-749

 *********************************************************

 */
public without sharing class DH_KnowledgeDataCategoryTriggerHandler {
    
    /**
     * @description Update related indexing record if user updates category or subcategory of knowledge record
     * @param trigger.oldMap and trigger.new
     **/
    public static void handleAfterUpdate(Map<Id, Knowledge__kav> oldMap, List<Knowledge__kav> updatedRecords) {
        try{
            List<DH_Knowledge_Indexing__c> childRecordsToUpdate = new List<DH_Knowledge_Indexing__c>();
            
            // Sets to track category keys for querying existing indexing records
            Set<String> categoryKeysEast = new Set<String>();  // Variable used to store East category and subcategory combination for current records to query same combination existing records
            Set<String> categoryKeysWest = new Set<String>();  // Variable used to store West category and subcategory combination for current records to query same combination existing records
            Set<Id> currentIds =new Set<Id>();  //Variable used to store Ids in trigger.new to find related indexing records
            List<DH_Knowledge_Indexing__c> knowledgeChildRecords= new List<DH_Knowledge_Indexing__c>();
            
            String publishStatusArchived = DH_KMConstants.PUBLISH_STATUS_ARCHIVED ;
            String subQuerySelectFrom = 'SELECT East_Category__c, title__c, index__c, West_Category__c, west_Index__c FROM DH_Knowledge_Indexing__c ';
            String subQueryWhereAnd = ' AND Knowledge_Article_Management__r.PublishStatus !=: publishStatusArchived AND Knowledge_Article_Management__r.Id NOT IN: currentIds';
            String queryEast = '';
            String queryWest = '';
            
            // Track records that need updates based on changes in categories or subcategories
            for (Knowledge__kav knowledge : updatedRecords) {
                Knowledge__kav oldRecord = oldMap.get(knowledge.Id);
                Boolean isEastCategoryChanged = knowledge.East_Categories__c != oldRecord.East_Categories__c || knowledge.East_Sub_Categories__c != oldRecord.East_Sub_Categories__c;
                Boolean isWestCategoryChanged = knowledge.West_Categories__c != oldRecord.West_Categories__c || knowledge.West_Sub_Categories__c != oldRecord.West_Sub_Categories__c;
                //proceed only if category or subcategory is changed
                if (isEastCategoryChanged || isWestCategoryChanged) {
                    if (knowledge.East_Categories__c != null) {
                        String categoryKeyEast = knowledge.East_Categories__c + (knowledge.East_Sub_Categories__c != null ? knowledge.East_Sub_Categories__c : '');
                        categoryKeysEast.add(categoryKeyEast);
                    }
                    if (knowledge.West_Categories__c != null) {
                        String categoryKeyWest = knowledge.West_Categories__c + (knowledge.West_Sub_Categories__c != null ? knowledge.West_Sub_Categories__c : '');
                        categoryKeysWest.add(categoryKeyWest);
                    }
                    currentIds.add(knowledge.Id);
                }
            }
            //Haven't checked CRUD because we need to run this trigger for whole data
            Map<Id, DH_Knowledge_Indexing__c> currentKnowledgeIndexingMap = new Map<Id, DH_Knowledge_Indexing__c>();
            for(DH_Knowledge_Indexing__c ki:   [SELECT East_Category__c, title__c, index__c, West_Category__c, west_Index__c, Knowledge_Article_Management__c, Knowledge_Article_Management__r.Id
                                                FROM DH_Knowledge_Indexing__c
                                                WHERE Knowledge_Article_Management__r.Id IN: currentIds
                                                ]){
                if(ki.Knowledge_Article_Management__r.Id != null){
                    currentKnowledgeIndexingMap.put(ki.Knowledge_Article_Management__c,ki);
                }
            }
            if (!categoryKeysEast.isEmpty() || !categoryKeysWest.isEmpty()){
                
                // Query to get the max East index for each category and subcategory combination
                queryEast = subQuerySelectFrom + ' WHERE East_Category__c IN :categoryKeysEast ' +subQueryWhereAnd;
                List<DH_Knowledge_Indexing__c> existingChildRecordsEast = Database.query(queryEast) ;
                
                // Query to get the max West index for each category and subcategory combination
                queryWest = subQuerySelectFrom + '  WHERE West_Category__c IN :categoryKeysWest ' +subQueryWhereAnd;
                List<DH_Knowledge_Indexing__c> existingChildRecordsWest = Database.query(queryWest) ;
                
                // Initialize the map to store the maximum index for each east category
                Map<String, Integer> maxIndexMapEast = findEastMaxIndexWrtCategories(existingChildRecordsEast);
                
                // Initialize the map to store the maximum index for each west category
                Map<String, Integer> maxIndexMapWest = findWestMaxIndexWrtCategories(existingChildRecordsWest);
                
                // Create child records with the correct index
                for (Knowledge__kav knowledge : updatedRecords) {
                    //checked if category or subcategory changed or not only if category or subcategory is changed then only we have to update current records index
                    String categoryKeyWest ='';
                    String categoryKeyEast ='';
                    Knowledge__kav oldRecord = oldMap.get(knowledge.Id);
                    String oldcategoryKeyWest ='';
                    String oldcategoryKeyEast ='';
                    if(knowledge.East_Categories__c != null){
                        categoryKeyEast = knowledge.East_Categories__c + (knowledge.East_Sub_Categories__c != null ? knowledge.East_Sub_Categories__c : '');
                    }
                    if(knowledge.West_Categories__c != null){
                        categoryKeyWest = knowledge.West_Categories__c + (knowledge.West_Sub_Categories__c != null ? knowledge.West_Sub_Categories__c : '');
                    }
                    //old category and subcategory combination
                    if(oldRecord.East_Categories__c != null){
                        oldcategoryKeyEast = oldRecord.East_Categories__c + (oldRecord.East_Sub_Categories__c != null ? oldRecord.East_Sub_Categories__c : '');
                    }
                    if(oldRecord.West_Categories__c != null){
                        oldcategoryKeyWest = oldRecord.West_Categories__c + (oldRecord.West_Sub_Categories__c != null ? oldRecord.West_Sub_Categories__c : '');
                    }
                    Integer maxIndexEast = maxIndexMapEast.get(categoryKeyEast);
                    Integer maxIndexWest = maxIndexMapWest.get(categoryKeyWest);
                    if (maxIndexEast == null) {
                        maxIndexEast = 0;  // Initialize to 0 if no previous records
                        maxIndexMapEast.put(categoryKeyEast, maxIndexEast);
                    }
                    if (maxIndexWest == null) {
                        maxIndexWest = 0;  // Initialize to 0 if no previous records
                        maxIndexMapWest.put(categoryKeyWest, maxIndexWest);
                    }
                    // Update indexing records if categories changed
                    if(categoryKeyEast !=null || categoryKeyWest!=null){
                        
                        DH_Knowledge_Indexing__c newChild = currentKnowledgeIndexingMap.get(knowledge.id);
                        if(newChild != null){
                            if(categoryKeyEast !='' && categoryKeyEast != oldcategoryKeyEast){
                                newChild.Index__c = maxIndexEast + 1;
                            }
                            else if(categoryKeyEast ==''){
                                newChild.Index__c = null;
                            }
                            if(categoryKeyWest !='' && categoryKeyWest != oldcategoryKeyWest){
                                newChild.west_Index__c = maxIndexWest + 1;
                            }
                            else if(categoryKeyWest ==''){
                                newChild.west_Index__c = null ;
                            }
                            //Logic to assign East Categories/Subcategories or west categories/subcategories picklist value on knowledge indexing object
                            if(knowledge.East_Categories__c != oldRecord.East_Categories__c){
                                newChild.East_Categories__c = knowledge.East_Categories__c;
                            }
                            if(knowledge.East_Sub_Categories__c != oldRecord.East_Sub_Categories__c ){
                                newChild.East_Sub_Categories__c = knowledge.East_Sub_Categories__c;
                            }
                            if(knowledge.West_Categories__c != oldRecord.West_Categories__c){
                                newChild.West_Categories__c = knowledge.West_Categories__c;
                            }
                            if(knowledge.West_Sub_Categories__c != oldRecord.West_Sub_Categories__c ){
                                newChild.West_Sub_Categories__c = knowledge.West_Sub_Categories__c;
                            }
                            knowledgeChildRecords.add(newChild);
                            
                            // Update the max index map
                            maxIndexMapEast.put(categoryKeyEast, maxIndexEast + 1);
                            maxIndexMapWest.put(categoryKeyWest, maxIndexWest + 1);
                        }
                    }
                }
            }
            //Haven't checked CRUD because we need to run this trigger for whole data
            if (!knowledgeChildRecords.isEmpty()) {
                update knowledgeChildRecords;
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error message : '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    
    /**
     * @description Method to create knowledge indexing record if knowledge.kav record is created with any category and subcategory
     * @param trigger.new
     **/
    public static void createIndexingObject(List<Knowledge__kav> newRecords, Boolean isInsert, Boolean isUpdate) {
        try{
            List<DH_Knowledge_Indexing__c> knowledgeChildRecords = new List<DH_Knowledge_Indexing__c>();
            // Grouping the knowledge records by their category and subcategory
            Set<Id> kAIdSet = new Set<Id>();
            // Collect unique category and subcategory combinations
            Set<String> categoryKeysEast = new Set<String>(); // Variable used to store East category and subcategory combination for current records to query same combination existing records
            Set<String> categoryKeysWest = new Set<String>(); // Variable used to store West category and subcategory combination for current records to query same combination existing records
            Map<Id,DH_Knowledge_Indexing__c> editAsDraftMap = new Map<Id, DH_Knowledge_Indexing__c>();
            
            String publishStatusArchived = DH_KMConstants.PUBLISH_STATUS_ARCHIVED ;
            String subQuerySelectFrom = 'SELECT East_Category__c, title__c, index__c, West_Category__c, west_Index__c FROM DH_Knowledge_Indexing__c ';
            String subQueryWhere = ' AND Knowledge_Article_Management__r.PublishStatus !=: publishStatusArchived ';
            String queryEast = '';
            String queryWest = '';
            
            for (Knowledge__kav knowledge : newRecords) {
                if(knowledge.East_Categories__c != null){
                    String categoryKeyEast;
                    if(knowledge.East_Sub_Categories__c !=null){
                        categoryKeyEast = knowledge.East_Categories__c + knowledge.East_Sub_Categories__c;
                    }
                    else{
                        categoryKeyEast = knowledge.East_Categories__c;
                    }
                    categoryKeysEast.add(categoryKeyEast);
                }
                if(knowledge.West_Categories__c != null){
                    String categoryKeyWest;
                    if(knowledge.West_Sub_Categories__c !=null){
                        categoryKeyWest = knowledge.West_Categories__c + knowledge.West_Sub_Categories__c;
                    }
                    else{
                        categoryKeyWest = knowledge.West_Categories__c;
                    }
                    categoryKeysWest.add(categoryKeyWest);
                }
                if(knowledge.KnowledgeArticleId != NULL){
                    kAIdSet.add(knowledge.KnowledgeArticleId);
                }
            }
            //Haven't checked CRUD because we need to run this trigger for whole data
            //if user create edit as draft for published article
            if (!kAIdSet.isEmpty()){
                for(DH_Knowledge_Indexing__c ind: [SELECT East_Category__c, title__c, Index__c, West_Category__c, west_Index__c, Knowledge_Article_Management__r.KnowledgeArticleId
                                                        FROM DH_Knowledge_Indexing__c
                                                        WHERE Knowledge_Article_Management__r.PublishStatus =: DH_KMConstants.PUBLISH_STATUS_ONLINE
                                                        AND Knowledge_Article_Management__r.KnowledgeArticleId IN: kAIdSet
                                                        ])
                {
                    editAsDraftMap.put(ind.Knowledge_Article_Management__r.KnowledgeArticleId, ind);
                }
                
            }
            if (!categoryKeysEast.isEmpty() || !categoryKeysWest.isEmpty()){
                // Query to get the max East index for each category and subcategory combination
                queryEast = subQuerySelectFrom + ' WHERE East_Category__c IN :categoryKeysEast ' +subQueryWhere;
                List<DH_Knowledge_Indexing__c> existingChildRecordsEast = Database.query(queryEast) ;
                
                // Query to get the max West index for each category and subcategory combination
                queryWest = subQuerySelectFrom + '  WHERE West_Category__c IN :categoryKeysWest ' +subQueryWhere;
                List<DH_Knowledge_Indexing__c> existingChildRecordsWest = Database.query(queryWest) ;
                
                // Initialize the map to store the maximum index for each east category
                Map<String, Integer> maxIndexMapEast = findEastMaxIndexWrtCategories(existingChildRecordsEast);
                
                // Initialize the map to store the maximum index for each west category
                Map<String, Integer> maxIndexMapWest = findWestMaxIndexWrtCategories(existingChildRecordsWest);
                
                // Create child records with the correct index
                for (Knowledge__kav knowledge : newRecords) {
                    String categoryKeyWest ='';
                    String categoryKeyEast ='';
                    if(knowledge.East_Categories__c != null){
                        categoryKeyEast = knowledge.East_Categories__c + (knowledge.East_Sub_Categories__c != null ? knowledge.East_Sub_Categories__c : '');
                    }
                    if(knowledge.West_Categories__c != null){
                        categoryKeyWest = knowledge.West_Categories__c + (knowledge.West_Sub_Categories__c != null ? knowledge.West_Sub_Categories__c : '');
                    }
                    Integer maxIndexEast = maxIndexMapEast.get(categoryKeyEast);
                    
                    Integer maxIndexWest = maxIndexMapWest.get(categoryKeyWest);
                    if (maxIndexEast == null) {
                        maxIndexEast = 0;  // Initialize to 0 if no previous records
                        maxIndexMapEast.put(categoryKeyEast, maxIndexEast);
                    }
                    if (maxIndexWest == null) {
                        maxIndexWest = 0;  // Initialize to 0 if no previous records
                        maxIndexMapWest.put(categoryKeyWest, maxIndexWest);
                    }
                    // Create new indexing record if any east category or west category present on the article
                    if(categoryKeyEast !=null || categoryKeyWest!=null){
                        DH_Knowledge_Indexing__c newChild = new DH_Knowledge_Indexing__c();
                        newChild.Knowledge_Article_Management__c = knowledge.Id;
                        if(editAsDraftMap.containsKey(knowledge.KnowledgeArticleId)){
                            newChild.Index__c  = editAsDraftMap.get(knowledge.KnowledgeArticleId).Index__c;
                            newChild.west_Index__c = editAsDraftMap.get(knowledge.KnowledgeArticleId).west_Index__c;
                        }
                        else{
                            if(categoryKeyEast !=''){
                                newChild.Index__c = maxIndexEast + 1;
                            }
                            if(categoryKeyWest !=''){
                                newChild.west_Index__c = maxIndexWest + 1;
                            }
                        }
                        //Logic to assign East Categories/Subcategories or west categories/subcategories picklist value on knowledge indexing object
                        if(knowledge.East_Categories__c != null){
                            newChild.East_Categories__c = knowledge.East_Categories__c;
                        }
                        if(knowledge.East_Sub_Categories__c !=null){
                            newChild.East_Sub_Categories__c = knowledge.East_Sub_Categories__c;
                        }
                        if(knowledge.West_Categories__c != null){
                            newChild.West_Categories__c = knowledge.West_Categories__c;
                        }
                        if(knowledge.West_Sub_Categories__c !=null){
                            newChild.West_Sub_Categories__c = knowledge.West_Sub_Categories__c;
                        }
                        knowledgeChildRecords.add(newChild);
                        
                        // Update the max index map
                        maxIndexMapEast.put(categoryKeyEast, maxIndexEast + 1);
                        maxIndexMapWest.put(categoryKeyWest, maxIndexWest + 1);
                    }
                }
            }
            //Haven't checked CRUD because we need to run this trigger for whole data
            if (!knowledgeChildRecords.isEmpty()) {
                insert knowledgeChildRecords;
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error message : '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    
    /**
     * @description Method to put maximum east index and category/subcategory combination in a map
     * @param existingChildRecordsEast
     **/
    public static Map<String, Integer> findEastMaxIndexWrtCategories(List<DH_Knowledge_Indexing__c> existingChildRecordsEast) {
        Map<String, Integer> maxIndexMapEast = new Map<String, Integer>();
        try{
            // Populate the maxIndexMapEast with the query results east
            for (DH_Knowledge_Indexing__c child : existingChildRecordsEast) {
                String categoryKey = child.East_Category__c;
                Integer currentIndex = maxIndexMapEast.get(categoryKey);
                Integer childIndex =  Integer.ValueOf(child.Index__c);
                // Update the map with the maximum Index__c for each east category
                if (currentIndex == null || childIndex > currentIndex) {
                    maxIndexMapEast.put(categoryKey, childIndex);
                }
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error message : '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return maxIndexMapEast;
    }
    
    /**
     * @description Method to put maximum west index and category/subcategory combination in a map
     * @param existingChildRecordsWest
     **/
    public static Map<String, Integer> findWestMaxIndexWrtCategories(List<DH_Knowledge_Indexing__c> existingChildRecordsWest) {
        Map<String, Integer> maxIndexMapWest = new Map<String, Integer>();
        try{
            // Populate the maxIndexMapWest with the query results west
            for (DH_Knowledge_Indexing__c child : existingChildRecordsWest) {
                String categoryKeyWest = child.west_Category__c;
                Integer currentIndexWest = maxIndexMapWest.get(categoryKeyWest);
                Integer childIndexWest =  Integer.ValueOf(child.west_Index__c);
                // Update the map with the maximum Index__c for each west category
                if (currentIndexWest == null || childIndexWest > currentIndexWest) {
                    maxIndexMapWest.put(categoryKeyWest, childIndexWest);
                }
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error message : '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return maxIndexMapWest;
    }
}