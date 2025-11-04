global with sharing class Batch_RollUpLoyaltyScoreOnAccs_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_RollUpLoyaltyScoreOnAccs(), 50);
    }
}