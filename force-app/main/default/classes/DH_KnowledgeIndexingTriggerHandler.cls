/*

 *********************************************************

Apex Class         : DH_KnowledgeIndexingTriggerHandler
    
Created Date       : June 11, 2024
    
@description       : trigger handler for knowledge_Indexing__c object to duplicate check and copy index

@jiraid            : CC-330, CC-750

 *********************************************************

 */
public without sharing class DH_KnowledgeIndexingTriggerHandler{
    public static String publishStatusArchived =DH_KMConstants.PUBLISH_STATUS_ARCHIVED;
    public static String duplicatErrorMsg = System.Label.DH_DuplicateKnowledgeIndexingError;
    public static String knowledgeKavSubQuery='SELECT Id, Title, KnowledgeArticleId from Knowledge__kav ';
    public static String knowledgeIndexingSubQuery='SELECT Id, East_Category__c, Index__c, West_Category__c, west_Index__c,  Knowledge_Article_Management__r.KnowledgeArticleId FROM DH_Knowledge_Indexing__c WHERE Knowledge_Article_Management__r.PublishStatus !=: publishStatusArchived';
    
    /**
     * @description Method used to restrict user if he tries to add same index for category and subcategory combination
     * @param trigger.new and trigger.oldmap
     **/
    public static void beforeUpdateCheckDuplicates(List<DH_Knowledge_Indexing__c> newRec, Map<id,DH_Knowledge_Indexing__c> oldMap) {
        try{
            // Collect the eastCategory/index and westCategory/westIndex values from the incoming records where index or westIndex is updated
            Set<String> eastCategoryIndexSet = new Set<String>();  //Set to store east category and subcategory combinations if index changed
            Set<Integer> eastIndexSet = new Set<Integer>();
            Set<String> westCategoryIndexSet = new Set<String>(); //Set to store west category and subcategory combinations if index changed
            Set<Integer> westIndexSet = new Set<Integer>();
            List<String> eastBulkCheck = new List<String>();  //List to throw error if multiple east records index changed and if they have same category/subcategory and index combination
            List<String> westBulkCheck = new List<String>(); //List to throw error if multiple east records index changed and if they have same category/subcategory and index combination
            Set<Id> knowledgeIds = new Set<Id>();
            Set<Id> knowledgeIdsToFind = new Set<Id>();
            
            DH_Knowledge_Indexing__c oldRecord;
            String eastKey = '';
            Integer eastIndex;
            String eastCombinedKey = '';
            String westKey = '';
            Integer westIndex;
            String westCombinedKey = '';
            
            for (DH_Knowledge_Indexing__c record : newRec) {
                oldRecord = oldMap.get(record.Id);
                knowledgeIdsToFind.add(record.Knowledge_Article_Management__c);
                eastCombinedKey = '';
                westCombinedKey = '';
                if (record.index__c != oldRecord.index__c) {
                    eastKey = record.East_Category__c;
                    eastIndex = Integer.ValueOf(record.Index__c);
                    eastCombinedKey = record.East_Category__c +  Integer.ValueOf(record.Index__c); //Store unique combination of east category/subcategory and index
                    if(eastBulkCheck.contains(eastCombinedKey)){
                        record.addError(duplicatErrorMsg); //throw error if multiple east records index changed and if they have same category/subcategory and index combination
                    }
                    else{
                        eastBulkCheck.add(eastCombinedKey);
                    }
                    eastCategoryIndexSet.add(eastKey);
                    eastIndexSet.add(eastIndex);
                }
                if (record.west_Index__c != oldRecord.west_Index__c) {
                    westKey = record.West_Category__c;
                    westIndex= Integer.ValueOf(record.west_Index__c);
                    westCombinedKey = record.West_Category__c +  Integer.ValueOf(record.west_Index__c); //Store unique combination of west category/subcategory and index
                    if(westBulkCheck.contains(westCombinedKey)){
                        record.addError(duplicatErrorMsg);  //throw error if multiple west records index changed and if they have same category/subcategory and index combination
                    }
                    else{
                        westBulkCheck.add(westCombinedKey);
                    }
                    westCategoryIndexSet.add(westKey);
                    westIndexSet.add(westIndex);
                }
            }
            
            String query = knowledgeKavSubQuery+'where Id IN: knowledgeIdsToFind AND PublishStatus !=: publishStatusArchived';
            List<Knowledge__kav> knowledgeKavList = Database.query(query);
            List<Knowledge__kav> knowledgeKavs = new List<Knowledge__kav>(knowledgeKavList);  //all related knowledge articles in which index is updated
            if(!knowledgeKavs.isEmpty()){
                for(Knowledge__kav k: knowledgeKavs){
                    knowledgeIds.add(k.KnowledgeArticleId);  //store knolwdge articles id to skip error if same index updated for any version of article
                }
            }
            // Only proceed if there are records with updated Eastindex or westIndex
            if (!eastCategoryIndexSet.isEmpty() || !westCategoryIndexSet.isEmpty()) {
                // Query existing records to see if there are any duplicates for eastCategory/index
                String existingEastRecordsQuery = knowledgeIndexingSubQuery+' AND Index__c IN : eastIndexSet AND East_Category__c IN :eastCategoryIndexSet  AND Knowledge_Article_Management__r.KnowledgeArticleId NOT IN : knowledgeIds';
                List<DH_Knowledge_Indexing__c> existingEastRecords = Database.query(existingEastRecordsQuery);
                
                // Query existing records to see if there are any duplicates for westCategory/westIndex
                String existingWestRecordsQuery = knowledgeIndexingSubQuery+' AND west_Index__c IN : westIndexSet AND West_Category__c IN :westCategoryIndexSet AND Knowledge_Article_Management__r.KnowledgeArticleId NOT IN : knowledgeIds';
                List<DH_Knowledge_Indexing__c> existingWestRecords = Database.query(existingWestRecordsQuery);
                
                // Create a map to store existing eastCategoryIndexKey and related knowledge record Id
                Map<String, Id> existingEastRecordsMap = new Map<String, Id>();
                for (DH_Knowledge_Indexing__c existingRecord : existingEastRecords) {
                    eastKey = existingRecord.East_Category__c + ':' + Integer.ValueOf(existingRecord.Index__c);
                    existingEastRecordsMap.put(eastKey, existingRecord.Id);
                }
                // Create a map to store existing westCategoryIndexKey and related knowledge record Id
                Map<String, Id> existingWestRecordsMap = new Map<String, Id>();
                for (DH_Knowledge_Indexing__c existingRecord : existingWestRecords) {
                    westKey = null;
                    westKey = existingRecord.West_Category__c + ':' + Integer.ValueOf(existingRecord.west_Index__c);
                    existingWestRecordsMap.put(westKey, existingRecord.Id);
                }
                
                for (DH_Knowledge_Indexing__c record : newRec) {
                    oldRecord = oldMap.get(record.Id);
                    String oldeastKey =  oldRecord.East_Category__c + ':' + Integer.ValueOf(oldRecord.index__c);
                    String oldwestKey = oldRecord.West_Category__c + ':' + Integer.ValueOf(oldRecord.west_Index__c);
                    if(existingEastRecordsMap.containsKey(oldeastKey)){  //remove current record to avoid duplication
                        existingEastRecordsMap.remove(oldeastKey);
                    }
                    if(existingWestRecordsMap.containsKey(oldwestKey)){  //remove current record to avoid duplication
                        existingWestRecordsMap.remove(oldwestKey);
                    }
                }
                // Check if there are any duplicates for eastCategory/index and add errors if found
                for (DH_Knowledge_Indexing__c record : newRec) {
                    oldRecord = oldMap.get(record.Id);
                    if (record.index__c != oldRecord.index__c) {
                        eastKey = record.East_Category__c + ':' + Integer.ValueOf(record.Index__c);
                        if (existingEastRecordsMap.containsKey(eastKey) && existingEastRecordsMap.get(eastKey) != record.Id && record.East_Category__c != null) {
                            record.addError(duplicatErrorMsg);  //throw error once east duplicate found
                        }
                        if(existingEastRecordsMap.get(eastKey) == record.Id){
                            existingEastRecordsMap.remove(eastKey);
                        }
                    }
                    if (record.west_Index__c != oldRecord.west_Index__c) {
                        westKey = null;
                        westKey = record.West_Category__c + ':' + Integer.ValueOf(record.west_Index__c);
                        if (existingWestRecordsMap.containsKey(westKey) && existingWestRecordsMap.get(westKey) != record.Id && record.West_Category__c != null) {
                            record.addError(duplicatErrorMsg); //throw error once west duplicate found
                        }
                        if(existingWestRecordsMap.get(westKey) == record.Id){
                            existingWestRecordsMap.remove(westKey);
                        }
                    }
                }
            }
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error while updating record Duplicate records '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    /**
     * @description Method used to copy the index to other versions if online/draft versions present for same article
     * @param trigger.new and trigger.oldmap
     **/
    public static void afterUpdateCopyIndex(List<DH_Knowledge_Indexing__c> newRec, Map<id,DH_Knowledge_Indexing__c> oldMap) {
        try{
            Set<Id> knowledgeIds = new Set<Id>();
            Set<Id> knowledgeIdsToFind = new Set<Id>();
            Set<Id> currentRec = new Set<Id>(); //Store all recor ids in which index is changed
            DH_Knowledge_Indexing__c oldRecord;
            for (DH_Knowledge_Indexing__c record : newRec) { //check if records index updated or not and then add record id into currentRec if index changed
                oldRecord = oldMap.get(record.Id);
                if (Integer.ValueOf(record.index__c) != Integer.ValueOf(oldRecord.index__c) || Integer.ValueOf(record.west_Index__c) != Integer.ValueOf(oldRecord.west_Index__c)) {
                    knowledgeIdsToFind.add(record.Knowledge_Article_Management__c);
                    currentRec.add(record.Id);
                }
            }
            
            String query = knowledgeKavSubQuery+' where Id IN: knowledgeIdsToFind AND PublishStatus !=: publishStatusArchived'; //Query all the knowledge articles records which for which index is updated and store them into knowledgeKavList
            List<Knowledge__kav> knowledgeKavList=Database.query(query);
            List<Knowledge__kav> knowledgeKavs = new List<Knowledge__kav>(knowledgeKavList);
            if(!knowledgeKavs.isEmpty()){
                for(Knowledge__kav k: knowledgeKavs){ //loop to store KnowledgeArticleId for finding versions of updated index articles
                    knowledgeIds.add(k.KnowledgeArticleId);
                }
            }
            String existingRecordsQuery = knowledgeIndexingSubQuery+' AND Knowledge_Article_Management__r.KnowledgeArticleId  IN : knowledgeIds AND Id NOT IN : currentRec'; //Find all versions existing Knowledge.kav records except currently updated version
            List<DH_Knowledge_Indexing__c> existingRecords = Database.query(existingRecordsQuery);
            
            String currentRecordsQuery = knowledgeIndexingSubQuery+' AND Id IN : currentRec'; //Knowledge records related to currently updated indexing records
            List<DH_Knowledge_Indexing__c> currentRecords =  Database.query(currentRecordsQuery);
            Map<Id,DH_Knowledge_Indexing__c> knowledgeIdAndIndexMap = new Map<Id,DH_Knowledge_Indexing__c>(); //Map to store KnowledgeArticleId and related knowledges indexing record for existing records
            if(!existingRecords.isEmpty()){
                for(DH_Knowledge_Indexing__c k:existingRecords){
                    knowledgeIdAndIndexMap.put(k.Knowledge_Article_Management__r.KnowledgeArticleId,k);
                }
            }
            List<DH_Knowledge_Indexing__c> recListToUpdate = new List<DH_Knowledge_Indexing__c>(); //indexing records which need to updated
            if(!existingRecords.isEmpty()){  //
                for (DH_Knowledge_Indexing__c record : currentRecords) {  //loop to update other versions indexing records if one of the versions indexing is changed
                    oldRecord = oldMap.get(record.Id);
                    if(knowledgeIdAndIndexMap.containsKey(record.Knowledge_Article_Management__r.KnowledgeArticleId)){
                        DH_Knowledge_Indexing__c i= knowledgeIdAndIndexMap.get(record.Knowledge_Article_Management__r.KnowledgeArticleId);
                        if(Integer.ValueOf(record.Index__c) != Integer.ValueOf(oldRecord.Index__c)){
                            i.Index__c = Integer.ValueOf(record.Index__c);
                        }
                        if(Integer.ValueOf(record.west_Index__c) != Integer.ValueOf(oldRecord.west_Index__c)){
                            i.west_Index__c = Integer.ValueOf(record.west_Index__c);
                        }
                        if(!currentRec.contains(i.Id)){
                            recListToUpdate.add(i);
                        }
                        
                    }
                }
            }
            if(!recListToUpdate.isEmpty()){
                Update recListToUpdate;
            }
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error while updating record: '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
}