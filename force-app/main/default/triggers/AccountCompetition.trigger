trigger AccountCompetition on Account_Competition_Relationship__c (after insert, after update) {
//public static void createRefreshRecordPlatformEvents(List<Account_Competition_Relationship__c > newAccountCompetitionRelationships ){
        
        List<Refresh_Record_Event__e> refreshRecordEventList = new List<Refresh_Record_Event__e>();
        Refresh_Record_Event__e refreshEventObj = new Refresh_Record_Event__e();
        
                            
        for (Account_Competition_Relationship__c acc : Trigger.new) {
            refreshEventObj = new Refresh_Record_Event__e();
            refreshEventObj.Record_Id__c = acc.Id;
            refreshEventObj.User_Id__c = UserInfo.getUserId();
            
            refreshRecordEventList.add(refreshEventObj);
        }
        
        try{
            if(refreshRecordEventList <> null && !refreshRecordEventList.isEmpty())
                EventBus.publish(refreshRecordEventList);
        }catch(Exception e){
            System.debug('Exception during publishing of refresh platform events-->'+e.getMessage());
        }
}