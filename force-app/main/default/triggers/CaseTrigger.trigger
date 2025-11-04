trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    TriggerFactory.execute(Case.getSObjectType());
}