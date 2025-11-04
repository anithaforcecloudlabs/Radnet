public with sharing class CompetitionTriggerHandler extends TriggerHandler{
    private Competition__c[] newCompetitions;
    private Competition__c[] oldCompetitions;
    private Map<Id, Competition__c> oldCompetitionsMap;
    private Map<Id, Competition__c> newCompetitionsMap;

    protected override void populateTriggerData(
        List<SObject> oldSObjectsList, 
        List<SObject> newSObjectsList,
        Map<Id, SObject> oldSObjectsMap, 
        Map<Id, SObject> newSObjectsMap
    ) {
        this.newCompetitions = (Competition__c[]) newSObjectsList;
        this.oldCompetitions = (Competition__c[]) oldSObjectsList;
        this.newCompetitionsMap = (Map<Id, Competition__c >) newSObjectsMap;
        this.oldCompetitionsMap = (Map<Id, Competition__c >) oldSObjectsMap;
    }

    protected override void onAfterInsert() {   
        Set<String> competitionZipCodes = batchZipCodeMappingHelper.collectCompetitionZipCodes(newCompetitions);        
        List<Account> accountZipCodes = batchZipCodeMappingHelper.collectAccountZipCodes(competitionZipCodes);
        List<Account_Competition_Relationship__c> existAccountCompetitionRelationship = batchZipCodeMappingHelper.collectAccountCompetitionRelationship();      
        List<Account_Competition_Relationship__c> createAccountCompetitionRelationship = batchZipCodeMappingHelper.populateAccountCompetitionRelationship(
            newCompetitions,
            accountZipCodes,
            existAccountCompetitionRelationship
        );
        
        if(!createAccountCompetitionRelationship.isEmpty()){
            try{
                insert createAccountCompetitionRelationship ;
                system.debug('createAccountCompetitionRelationship : '+createAccountCompetitionRelationship);
            }catch(Exception e){
                System.debug('Error : '+e.getMessage()+' LineNo : '+e.getLineNumber());
            }
        }
    }
}