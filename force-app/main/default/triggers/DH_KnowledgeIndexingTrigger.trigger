trigger DH_KnowledgeIndexingTrigger on DH_Knowledge_Indexing__c (before insert, before update, after update) {
    // Before Update
    if (Trigger.isBefore && (Trigger.isUpdate)) {
        DH_KnowledgeIndexingTriggerHandler.beforeUpdateCheckDuplicates(Trigger.new, Trigger.oldMap);
    }
     // After Update
    if (Trigger.isAfter && (Trigger.isUpdate)) {
        DH_KnowledgeIndexingTriggerHandler.afterUpdateCopyIndex(Trigger.new, Trigger.oldMap);
    }
}