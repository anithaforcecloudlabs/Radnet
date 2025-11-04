/*
*********************************************************

Apex Class/ LWC Component Name    : KnowledgeDataCategory

Created Date       : May 29, 2024

@description       : This component is used as a trigger for KnowledgeDataCategory handler and DH_KnowledgeDataCategoryTriggerHandler classes. 

@jiraid            : CC-330, 423, 463, 465

*********************************************************
*/

trigger KnowledgeDataCategory on Knowledge__kav (before insert, after insert, before update, after update) {
    
     if (Trigger.isAfter && (Trigger.isInsert)) {
        KnowledgeDataCategoryApex.handleAfterInsertUpdate(Trigger.new, Trigger.oldMap,Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);
        DH_KnowledgeDataCategoryTriggerHandler.createIndexingObject(Trigger.new, Trigger.isInsert, Trigger.isUpdate);
    }

     if( Trigger.isAfter && Trigger.isUpdate) {
        //delete if category/subcategory was modified 
        //After delete insert the new knowledge data category mapping for it
        KnowledgeDataCategoryApex.handleAfterInsertUpdate(Trigger.new, Trigger.oldMap,Trigger.newMap,Trigger.isInsert, Trigger.isUpdate);
         DH_KnowledgeDataCategoryTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.new);
     }
    
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        KnowledgeDataCategoryApex.setArticleType(Trigger.new, Trigger.old, Trigger.isInsert, Trigger.isUpdate);
        KnowledgeDataCategoryApex.validateSubCategory(Trigger.new, Trigger.old, Trigger.isInsert, Trigger.isUpdate);
        
    }
    
   
}