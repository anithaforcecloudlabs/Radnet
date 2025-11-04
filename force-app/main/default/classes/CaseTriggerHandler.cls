public class CaseTriggerHandler extends TriggerHandler{
    private Case[] newCases;
    private Case[] oldCases;
    private Map<Id, Case> oldCasesMap;
    private Map<Id, Case> newCasesMap;

    protected override void populateTriggerData(
        List<SObject> oldSObjectsList, 
        List<SObject> newSObjectsList,
        Map<Id, SObject> oldSObjectsMap, 
        Map<Id, SObject> newSObjectsMap
    ) {
        this.newCases = (Case[]) newSObjectsList;
        this.oldCases = (Case[]) oldSObjectsList;
        this.newCasesMap = (Map<Id, Case >) newSObjectsMap;
        this.oldCasesMap = (Map<Id, Case >) oldSObjectsMap;
    }

    protected override void onBeforeInsert() {
        Map<Id, Case> emailCases = new Map<Id, Case>();
        for(Case newCase : newCases) {
            if (newCase.Type == 'Email') {
                emailCases.put(newCase.Id, newCase);
            }   
        }
        populateRisRequest(emailCases); 
    }

    private static void populateRisRequest(Map<Id, Case>  emailCases) {
        List<RIS_Requests__c> createRisRequest = new List<RIS_Requests__c>();
       
        for (Case newCase: emailCases.values()) {
            createRisRequest.add(
                new RIS_Requests__c(
                    Status__c = 'Closed',
                    Type__c = 'Email',
                    Subject__c = newCase.subject,
                    ContactId__c = newCase.ContactId,
                    Account_Name__c = newCase.AccountId,
                    Description__c = newCase.Description,
                    Date_Time_opened__c = Date.today()
                )
            );
        }
        insert createRisRequest;
    }

    protected override void onAfterInsert() {
        List<Case> emailDeleteCases = new List<Case>();
        for(Case newCase : newCasesMap.values()) {
            if (newCase.Type == 'Email') {
                emailDeleteCases.add(new Case(Id = newCase.Id));
            }
        }
        Database.delete(emailDeleteCases);
    }
}