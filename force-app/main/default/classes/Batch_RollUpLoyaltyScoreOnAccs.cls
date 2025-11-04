global with sharing class Batch_RollUpLoyaltyScoreOnAccs implements Database.Batchable<AggregateResult>{
   
    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        String query = System.Label.Batch_RollUpLoyaltyScoreOnAccs_Query1;
        if(Test.isRunningTest()){
            query = query + ' LIMIT 5';
        }
        return new AggregateResultIterable(query);
    } 

    global void execute(Database.BatchableContext bc, List<AggregateResult> listAggResRecs){ 
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        if(listAggResRecs!=null && !listAggResRecs.isEmpty()){
            for(AggregateResult aggrResRec : listAggResRecs){
                decimal charge = 0.0;
                Account accRec = new Account();
                if((string)aggrResRec.get('accountId')!=null && (string)aggrResRec.get('accountId')!=''  && (decimal)aggrResRec.get('loyaltyScore')!=null && (integer)aggrResRec.get('totalContacts')!=null){
                    accRec.Id = (string)aggrResRec.get('accountId');
                    accRec.Loyalty_Score__c = (decimal)aggrResRec.get('loyaltyScore')/(integer)aggrResRec.get('totalContacts');
                    mapAccounts.put(accRec.Id, accRec);
                }
            }
        }

        if(mapAccounts!=null && !mapAccounts.isEmpty()){
            List<Database.SaveResult> listSaveResults = Database.update(mapAccounts.values());
        }
    }

    global void finish(Database.BatchableContext bc){

    }
}