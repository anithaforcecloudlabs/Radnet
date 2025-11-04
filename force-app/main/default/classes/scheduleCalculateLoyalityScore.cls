global class scheduleCalculateLoyalityScore implements Schedulable{
    global void execute(SchedulableContext sc) {
        CalculateLoyalityScore cls = new CalculateLoyalityScore();
        database.executeBatch(cls, 200);
    }

}