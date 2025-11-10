trigger DH_MessagingSessionTrigger on MessagingSession (before insert, after insert, before update, after update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            DH_MessagingSessionHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            DH_MessagingSessionHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            DH_MessagingSessionHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            DH_MessagingSessionHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}