global class scheduleRollupContactLoyaltyScore implements Schedulable{
     global void execute(SchedulableContext sc) {
        rollupContactLoyaltyScoreToAccount rcl = new rollupContactLoyaltyScoreToAccount();
        database.executeBatch(rcl, 200);
    }

}