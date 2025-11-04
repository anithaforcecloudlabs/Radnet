global class rollupContactLoyaltyScoreToAccount implements Database.Batchable<AggregateResult>{
    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        
        String query = 'select sum(Loyalty_Score__c),count(id),accountid from contact where accountid != null and Loyalty_Score__c != null GROUP BY accountid';
        return new AggregateResultIterable(query);
    } 
    // The batch job executes and operates on one batch of records
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        
        list<account> accList = new list<account>();
        for(sObject ar : scope){
            system.debug('ar==============> '+ar);
            decimal rollUp = decimal.valueOf(string.valueOf(ar.get('expr0')));
            system.debug(' rollUp ==============> '+ rollUp);
            decimal totalContacts = decimal.valueOf(string.valueOf(ar.get('expr1')));
            system.debug('totalContacts ==============> '+ totalContacts);
            decimal rollUpScore = (rollUp/totalContacts).setScale(2);
             //decimal rollUpScore = (rollUp/totalContacts);
             //decimal percentrollUpScore = (rollUpScore * 100).setScale(2);
            system.debug('rollUpScore ==============> '+ rollUpScore);
            
            accList.add(new account(id =string.valueOf(ar.get('AccountId')),Loyalty_Score__c = rollUpScore));
            
        }
        if(!accList.isEmpty()){
            update accList;  
        }
        
        
        
        
        
    }
    // The batch job finishes
    global void finish(Database.BatchableContext bc){ }
    
}