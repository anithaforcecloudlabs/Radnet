public with sharing class TriggerFactory {

    public static final Map<String, TriggerHandler__mdt> SOBJECT_TRIGGER_SETTINGS = new Map<String, TriggerHandler__mdt>();
    public static final Map<String, Set<String>> SOBJECT_USERNAMES_TO_EXCLUDE = new Map<String, Set<String>>();
    public static final Map<String, TriggerHandler> SOBJECT_TRIGGER_HANDLERS = new Map<String, TriggerHandler>();
    public static final Set<String> CONTEXT_TO_RUN_VALIDATION = new Set<String>{'BEFORE_INSERT', 'BEFORE_UPDATE', 'AFTER_UPDATE', 'AFTER_INSERT'};

    public static void execute(Schema.SObjectType sObjectType) {
        TriggerHandler triggerHandler = getHandler(sObjectType);

        if (triggerHandler != null) {
            triggerHandler.execute(Trigger.operationType, Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, isRunValidation());
        }
    }
    public static Boolean isRunValidation() {
        system.debug('Trigger.operationType.name()' + Trigger.operationType.name());
        return CONTEXT_TO_RUN_VALIDATION.contains(Trigger.operationType.name());
    }
    public static void enable(Schema.SObjectType sObjectType) {
        changeActive(sObjectType, true);
    }

    public static void disable(Schema.SObjectType sObjectType) {
        changeActive(sObjectType, false);
    }

    private static void changeActive(Schema.SObjectType sObjectType, Boolean isActive) {
        if (sObjectType != null) {
            String sObjectName = sObjectType.getDescribe().getName();

            TriggerHandler__mdt triggerSetting = getHandlerSetting(sObjectName);

            if (triggerSetting != null) {
                triggerSetting.Enabled__c = isActive;

                SOBJECT_TRIGGER_SETTINGS.put(sObjectName, triggerSetting);
            }
        }
    }

    private static TriggerHandler getHandler(Schema.SObjectType sObjectType) {
        TriggerHandler handler;

        if (sObjectType != null) {
            String sObjectName = sObjectType.getDescribe().getName();

            TriggerHandler__mdt triggerSetting = getHandlerSetting(sObjectName);
//          Set<String> usernamesToExclude = SOBJECT_USERNAMES_TO_EXCLUDE.get(sObjectName);
            Set<String> usernamesToExclude = new Set<String>{};

            if (triggerSetting != null && triggerSetting.Enabled__c && !usernamesToExclude.contains(UserInfo.getUserName())) {
                if (SOBJECT_TRIGGER_HANDLERS.containsKey(sObjectName)) {
                    handler = SOBJECT_TRIGGER_HANDLERS.get(sObjectName);
                } else {
                    Type handlerType = Type.forName('', triggerSetting.Handler__c);

                    if (handlerType != null) {
                        handler = (TriggerHandler) handlerType.newInstance();

                        SOBJECT_TRIGGER_HANDLERS.put(sObjectName, handler);
                    }
                }
            }
        }

        return handler;
    }

    private static TriggerHandler__mdt getHandlerSetting(String sObjectName) {
        TriggerHandler__mdt handler;

        if (String.isNotBlank(sObjectName)) {
            if (SOBJECT_TRIGGER_SETTINGS.containsKey(sObjectName)) {
                handler = SOBJECT_TRIGGER_SETTINGS.get(sObjectName);
            } else {
                initHandlers();
                handler = SOBJECT_TRIGGER_SETTINGS.get(sObjectName);
                if (handler != null) {
                    SOBJECT_USERNAMES_TO_EXCLUDE.put(sObjectName,
                            (String.isNotBlank(handler.UsernamesToExclude__c)
                                    ? new Set<String>(handler.UsernamesToExclude__c.split(';'))
                                    : new Set<String>())
                    );
                } else {
                    handler = new TriggerHandler__mdt(
                            Enabled__c = false
                    );
                }
            }
        }

        return handler;
    }

    private static void initHandlers() {
        if (SOBJECT_TRIGGER_SETTINGS.isEmpty()) {
            for (TriggerHandler__mdt handler : [
                    SELECT Id, DeveloperName, Label, Enabled__c, Handler__c, Language, MasterLabel, NamespacePrefix,
                            Object__c, QualifiedApiName, UsernamesToExclude__c
                    FROM TriggerHandler__mdt]) {
                SOBJECT_TRIGGER_SETTINGS.put(handler.Object__c, handler);
            }
        }
    }

}