/******************************************************************************************************************************************************
 * 
 * Apex Controller : GoLiveCalendarController
 * 
 * Created Date    : 11/06/2024
 * 
 * @description    : This class is used to create event and search events on the basis of title, project category, region and goLive date.
 * 
 * @JIRA Id        : CC-103
 * 
 * */

public with sharing class GoLiveCalendarController {

    /**************************************************************************************************************************************************
     * 
     * @description this method is used to get all the region from Go_Live_Calendar__c
     * 
     * @return List of string of regions
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static List<String> getRegion(){
        List<String> region = new List<String>();
        try{
            List<Go_Live_Calendar__c> regionList = [SELECT Region__c FROM Go_Live_Calendar__c WITH SECURITY_ENFORCED];
            for(Go_Live_Calendar__c r :regionList){
                if(!region.contains(r.Region__c)){
                    region.add(r.Region__c);
               	}
        	}
        }
         catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured  : ' + e.getMessage());
        }
        return region ;
    }

    /**************************************************************************************************************************************************
     * 
     * @description this method returns the golive date picklist options
     * 
     * @return List of string of golive date options
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static List<String> getgoLiveDate(){        
        List<String> goLiveDateList = new List<String>{'Any','Past 90 Days','Past 30 Days','Next 30 Days','Next 90 Days','Archive(>90 Old)'};
        return goLiveDateList;  
    }

    /**************************************************************************************************************************************************
     * 
     * @description this method gets the title of events
     * 
     * @return List of string of titles
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static List<String> getTitle()
    {
        List<String> title = new List<String>();
        List<Go_Live_Calendar__c> titleList = [SELECT Title__c FROM Go_Live_Calendar__c WITH SECURITY_ENFORCED] ;
        try{
            for(Go_Live_Calendar__c r :titleList){
            	if(!title.contains(r.Title__c)){
                	title.add(r.Title__c);
            	}
        	}
        }
        
        catch (Exception e){
            system.debug(LoggingLevel.ERROR, 'Exception occured  : ' + e.getMessage());
        }
        return title ;
    }

    /**************************************************************************************************************************************************
     * 
     * @description this method returns project categories
     * 
     * @return List of string of project categories
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static List<String> getProjectCategory()
    {
        List<String> projectCategory = new List<String>();
        List<Go_Live_Calendar__c> projectCategoryList = [SELECT Category__c FROM Go_Live_Calendar__c WITH SECURITY_ENFORCED] ;
        try{
            for(Go_Live_Calendar__c r :projectCategoryList){
                if(!projectCategory.contains(r.Category__c)) {
                    projectCategory.add(r.Category__c);
                }
            }
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured  : ' + e.getMessage());
        }
        return projectCategory ;
    }


    /**************************************************************************************************************************************************
     * 
     * @description this method is used to get event records based on title, category, region and goLive date
     * 
     * @param title String of title of event
     * 
     * @param category String  of category of event
     * 
     * @param region String of region of event
     * 
     * @param goLiveD String of goLive date of event
     * 
     * @return List of Go_Live_Calendar__c records
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static List<Go_Live_Calendar__c> getEventRecords(String title, String category,String region, String goLiveD)
    {
        String titleName = '%' + title + '%';
        String categoryName = '%' + category + '%';
        if(category == null){
            categoryName='%' + '%';
        }
        if(title == null){
            titleName='%' + '%';
        }
       
        String regionName = '%' + region + '%';
        if(region=='Any' || region==null){
            regionName = '%' + '%';
       }
       
            
        List<Go_Live_Calendar__c> records;
      

        try{
             if(region=='Any' || region==null) {
                // records=[select id,Title__c,Go_Live_Date__c,Category__c, Region__c  from Go_Live_Calendar__c  where Region__c like :r AND Title__c  like :t AND Category__c like :c];
                if(goLiveD == 'Any'){
                    records=[select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c like :regionName AND Name  like :titleName AND Category__c like :categoryName WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Past 30 Days'){
                    records = [select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c like :regionName AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c>=LAST_N_DAYS:30 and Go_Live_Date__c <TODAY WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Past 90 Days'){
                    records = [select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c like :regionName AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c>=LAST_N_DAYS:90 and Go_Live_Date__c <TODAY WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Next 30 Days'){
                    records = [select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c like :regionName AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c <=NEXT_N_DAYS:30  and Go_Live_Date__c >TODAY WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Next 90 Days'){
                    records=[select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c like :regionName AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c <=NEXT_N_DAYS:90  and Go_Live_Date__c >TODAY WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Archive(>90 Old)'){
                    records=[select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c like :regionName AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c < LAST_90_DAYS WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else{
                    records=[select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c  where Region__c like :regionName AND Name  like :titleName AND Category__c like :categoryName WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
            }
            else{
                if(goLiveD == 'Any'){
                    records=[select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c =: region AND Name  like :titleName AND Category__c like :categoryName WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Past 30 Days'){
                    records = [select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c from Go_Live_Calendar__c where Region__c =: region AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c>=LAST_N_DAYS:30 and Go_Live_Date__c <TODAY WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Past 90 Days'){
                    records = [select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c =: region AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c>=LAST_N_DAYS:90 and Go_Live_Date__c <TODAY WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Next 30 Days'){
                    records = [select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c =: region AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c <=NEXT_N_DAYS:30  and Go_Live_Date__c >TODAY WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Next 90 Days'){
                    records=[select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c =: region AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c <=NEXT_N_DAYS:90  and Go_Live_Date__c >TODAY WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else if(goLiveD=='Archive(>90 Old)'){
        
                    records=[select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c =: region AND Name  like :titleName AND Category__c like :categoryName AND Go_Live_Date__c < LAST_90_DAYS WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
                else{
                    records=[select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c  where Region__c =: region AND Name  like :titleName AND Category__c like :categoryName WITH SECURITY_ENFORCED ORDER By CreatedDate DESC];
                }
            }
               
            // System.debug('Fetched Records are' + records);
            List<Go_Live_Calendar__c> glcId = [select Id from Go_Live_Calendar__c WITH SECURITY_ENFORCED];
            Set<Id> glcIdSet=new Set<Id>();
            for(Go_Live_Calendar__c glc:glcId){
                glcIdSet.add(glc.Id);
            }
            List<ContentDocumentLink> cdlList=[Select ContentDocument.Title,ContentDocument.FileExtension,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :glcIdSet WITH SECURITY_ENFORCED];
            Map<id, String> glcMap = new Map<id, String>();
            for(ContentDocumentLink cd:cdlList){
                glcMap.put(cd.LinkedEntityId, cd.ContentDocument.title);
            }
            for(Integer i=0; i<records.size(); i++){
                // String inputDateTimeString=String.valueOf(records[i].Go_Live_Date__c);
                Datetime dt=records[i].Go_Live_Date__c;
                // String inputDateTimeString=records[i].Go_Live_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                // Datetime dt = (Datetime)JSON.deserialize('"'+inputDateTimeString+'"',Datetime.class);
                String formattedDateTime = dt.format('EEE, MM/dd/yyyy-HH:mm');
                records[i].FormatedDateTime__c= formattedDateTime;
                // System.debug(formattedDateTime);
                String cdlTitle = glcMap.get(records[i].Id);
                records[i].RelatedDocumentName__c=cdlTitle;
            }
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured  : ' + e.getMessage());
        }        
        return records ;
    }


    /**************************************************************************************************************************************************
     * 
     * @description this method gets the document related to the event
     * 
     * @param recordId String recordId of event
     * 
     * @return String retuns the record id of document related to the event
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static ContentVersion getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs  
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT Id, FileType, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : fileIDs WITH SECURITY_ENFORCED LIMIT 1];
        //String docId= docs[0].ContentDocumentId;
        return docs[0];
    }
        

    /**************************************************************************************************************************************************
     * 
     * @description this method creates a new Event
     * 
     * @param title String title of event
     * 
     * @param goLiveDate Datetime goLive date of event
     * 
     * @param category String category name of event
     * 
     * @param region String region of event
     * 
     * @return string Id of the new event created
     * 
     * */
    @AuraEnabled
    public static string createEvent(String title, Datetime goLiveDate, String category, String region){
        Go_Live_Calendar__c glc =  new Go_Live_Calendar__c();
        try{
            glc.Name=title;
            glc.Title__c=title;
            glc.Go_Live_Date__c=goLiveDate;
            glc.Category__c=category;
            glc.Region__c=region;
            if(Schema.sObjectType.Go_Live_Calendar__c.fields.Region__c.isCreateable()){
                insert glc;
            }
            else{
                return null;
            }
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured  : ' + e.getMessage());
        }
        return glc.id;
        
        
    }
    
    /**************************************************************************************************************************************************
     * 
     * @description this method checks whether the user has the given permission set
     * 
     * @param permissionSetName name of the permission set
     * 
     * @return boolean return True/False depending on whether the user has the permission set or not
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static Boolean hasPermissionSet(String permissionSetName) {
        // Get the current user Id
        Id userId = UserInfo.getUserId();
 	
        // Query to check if the user has the specified permission set
        List<PermissionSetAssignment> psaList = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId
            AND PermissionSet.Name = :permissionSetName WITH SECURITY_ENFORCED
        ];
        
        User user = [Select Id, profileId from User where Id =: userId WITH SECURITY_ENFORCED LIMIT 1];
       	Profile p = [Select Id, Name from Profile where Id =: user.profileId WITH SECURITY_ENFORCED];
        if(p.Name == 'System Administrator'){
            return true;
        }
        
        // If the list is not empty, it means the user has the permission set
        return !psaList.isEmpty();
    }
}