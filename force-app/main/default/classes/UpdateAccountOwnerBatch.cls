global class UpdateAccountOwnerBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('Database.getQueryLocator:');
        return Database.getQueryLocator([
            SELECT Id, Name, OwnerId, Owner.Name, Owner__c,
                (SELECT Id, AccountId, Subject, IsTask, ActivityDate, CreatedDate, OwnerId, Owner.Name, Status, ActivityType FROM ActivityHistories ORDER BY CreatedDate DESC Limit 1)
            FROM Account]);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        system.debug('=== Batch Execute ==='+scope);
        
        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : scope) {
            system.debug('=== ActivityHistories ==='+acc.ActivityHistories);
            if (!acc.ActivityHistories.isEmpty()) {
                acc.Owner__c = acc.ActivityHistories[0].OwnerId;
                accountsToUpdate.add(acc);
            }
        }
        system.debug('Updated Accounts2: ' + accountsToUpdate);

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
            system.debug('Updated Accounts: ' + accountsToUpdate);
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}