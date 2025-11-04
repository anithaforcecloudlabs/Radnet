global class batchZipCodeMapping implements Database.Batchable<sObject> {
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id,Address__PostalCode__s from Competition__c where Address__PostalCode__s != null';
        System.debug('Query: ' + query);
        return Database.getQueryLocator(query);
    }

    // Execute Method
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('scope : '+scope);
        List<Competition__c> competitions = (List<Competition__c>) scope;
        Set<String> competitionZipCodes = batchZipCodeMappingHelper.collectCompetitionZipCodes(competitions);
        
        List<Account> accountZipCodes = batchZipCodeMappingHelper.collectAccountZipCodes(competitionZipCodes);
        List<Account_Competition_Relationship__c> existAccountCompetitionRelationship = batchZipCodeMappingHelper.collectAccountCompetitionRelationship();        
        List<Account_Competition_Relationship__c> createAccountCompetitionRelationship = batchZipCodeMappingHelper.populateAccountCompetitionRelationship(
            competitions,
            accountZipCodes,
            existAccountCompetitionRelationship
        );
        system.debug('createAccountCompetitionRelationship ' + createAccountCompetitionRelationship);
        if(!createAccountCompetitionRelationship.isEmpty()){
            try{
                insert createAccountCompetitionRelationship ;
                system.debug('createAccountCompetitionRelationship : '+createAccountCompetitionRelationship);
            }catch(Exception e){
                System.debug('Error : '+e.getMessage()+' LineNo : '+e.getLineNumber());
            }
        }
    }

    // Finish Method
    global void finish(Database.BatchableContext BC) {
    }
}