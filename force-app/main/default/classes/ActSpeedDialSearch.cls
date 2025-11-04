/*
* ***************************************************************************************************************************
* Apex Class Name - ActSpeedDialSearch
* Created Date - 24-July-2024
* @description : Controller for the speed dial component 
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ----------------------------------------------
* CC-1549                  01-Jun-2025          Added all getDials method to fetch all speed dials with region filter
* *******************************************************************************************************************************************
*/
public with sharing class ActSpeedDialSearch {
    
    // Speed Dial wrapper
    public class SpeedDialSearchResult {
        @AuraEnabled    
        public String name;

        @AuraEnabled
        public String phoneNumber;

        @AuraEnabled
        public String description;

        @AuraEnabled
        public String id;

        public SpeedDialSearchResult(Speed_Dials__c info) {
            this.name = info.Name;
            this.phoneNumber = info.Phone_Number__c;
            this.description = info.Description__c;
            this.id = info.External_Id__c;
        }
    }
    
    // Method to fetch speed dials from custom settings - filtered as per running users' region.
	@AuraEnabled
    public static List<SpeedDialSearchResult> getDials() {
        List<String> userRegions = new List<String>();
        String regionString = [Select Id, Name, Region__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Region__c;
        if(regionString!=null){
            userRegions = regionString.split(';');
        }
        userRegions.add('ALL');
        
        List<Speed_Dials__c> SpeedDials = [SELECT Id, Name, Description__c, Phone_Number__c, Region__c, External_Id__c FROM Speed_Dials__c WHERE Region__c IN :userRegions ORDER BY Description__c];
        
        List<SpeedDialSearchResult> results = new List<SpeedDialSearchResult>();
        for (Speed_Dials__c speedDial : speedDials) {
             SpeedDialSearchResult result = new SpeedDialSearchResult(speedDial);
             result.name = speedDial.Name;
             result.phoneNumber = speedDial.Phone_Number__c;
             result.description = speedDial.Description__c;
             result.id = speedDial.External_Id__c;
             results.add(result);
        }
        
        return results;
    }
}