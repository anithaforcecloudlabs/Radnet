trigger RISRequestTrigger on RIS_Requests__c (after update) {
    TriggerFactory.execute(RIS_Requests__c.getSObjectType());
}