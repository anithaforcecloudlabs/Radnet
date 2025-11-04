global class CountPhysiciansBatch implements Database.Batchable<Sobject>,Schedulable{

     global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id,Physicians__c FROM Account]);
    }
    global void execute(Database.BatchableContext bc,List<Account> accList)
    {
        Map<Id,List<AccountContactRelation>> conMap=new Map<Id,List<AccountContactRelation>>();
        for(AccountContactRelation con:[SELECT Id,AccountId FROM AccountContactRelation WHERE AccountId IN:accList AND AccountId!=NULL AND Contact.RecordType.DeveloperName = 'Physicians']){
            if(conMap.containsKey(con.AccountId)){
                conMap.get(con.AccountId).add(con);
            }
            else{
                conMap.put(con.AccountId,new List<AccountContactRelation>{con});
            }
        }
        
        List<Account> acclisttoUpdate=new List<Account>();
        for(Account acc:accList){
            if(conMap.containsKey(acc.Id)){
                if(conMap.get(acc.Id).size()!=acc.Physicians__c){
                    acc.Physicians__c=conMap.get(acc.Id).size();
                    acclisttoUpdate.add(acc);
                }
            }
        }
        if(!acclisttoUpdate.isEmpty()){
            update acclisttoUpdate;
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new CountPhysiciansBatch());
    }
    
}