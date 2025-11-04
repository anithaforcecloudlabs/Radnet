trigger CompetitionTrigger on Competition__c (before insert, before update, after insert, after update) {
    TriggerFactory.execute(Competition__c.getSObjectType());
}