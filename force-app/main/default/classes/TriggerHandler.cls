public abstract with sharing class TriggerHandler {
    public void execute(TriggerOperation operationType,
            List<SObject> oldSObjectsList, List<SObject> newSObjectsList,
            Map<Id, SObject> oldSObjectsMap, Map<Id, SObject> newSObjectsMap, Boolean isRunValidation) {
            populateTriggerData(oldSObjectsList, newSObjectsList, oldSObjectsMap, newSObjectsMap);
                if(isRunValidation){
                    validate();
                }
        switch on operationType {
            when BEFORE_INSERT {
                onBeforeInsert();
            }
            when BEFORE_UPDATE {
                onBeforeUpdate();
            }
            when BEFORE_DELETE {
                onBeforeDelete();
            }
            when AFTER_INSERT {
                onAfterInsert();
            }
            when AFTER_UPDATE {
                onAfterUpdate();
            }
            when AFTER_DELETE {
                onAfterDelete();
            }
            when AFTER_UNDELETE {
                onAfterUndelete();
            }
        }
    }
    protected virtual void validate() {
    }

    protected virtual void onBeforeInsert() {
    }

    protected virtual void onBeforeUpdate() {
    }

    protected virtual void onBeforeDelete() {
    }

    protected virtual void onAfterInsert() {
    }

    protected virtual void onAfterUpdate() {
    }

    protected virtual void onAfterDelete() {
    }

    protected virtual void onAfterUndelete() {
    }

    protected abstract void populateTriggerData(List<SObject> oldSObjectsList, List<SObject> newSObjectsList,
            Map<Id, SObject> oldSObjectsMap, Map<Id, SObject> newSObjectsMap);
}