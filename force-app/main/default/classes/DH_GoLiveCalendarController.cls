/******************************************************************************************************************************************************
 * 
 * Apex Controller : DH_GoLiveCalendarController
 * 
 * Created Date    : 11/06/2024
 * 
 * @description    : This class is used to create event and search events on the basis of title, project category, region and goLive date.
 * 
 * @JIRA Id        : CC-103, CC-1135, CC-1137, CC-1138 
 * 
 * */

public without sharing class DH_GoLiveCalendarController {
// WITHOUT SHARING ADDED FOR CONTENT DISTRIBUTION OBJECT ACCESS TO GUEST USER 

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
            
            region=DH_KMQueryManager.getGoLiveCalendarRegion();
        }
         catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching region for Go live calendar : ' + e.getMessage()+' at line no: '+e.getLineNumber());
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
        List<Go_Live_Calendar__c> records;  
        try{
            records = DH_KMQueryManager.getGoLiveCalendarEventRecords( title,  category, region, goLiveD);

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
                Datetime dt=records[i].Go_Live_Date__c;
                String formattedDateTime = dt.format('EEE, MM/dd/yyyy-HH:mm');
                records[i].FormatedDateTime__c= formattedDateTime;
                String cdlTitle = glcMap.get(records[i].Id);
                records[i].RelatedDocumentName__c=cdlTitle;
            }
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching records for Go live Calendar : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }        
        return records ;
    }


    /**************************************************************************************************************************************************
     * 
     * @description this method gets the document related to the event
     * 
     * @param recordId String recordId of event
     * 
     * @return FileInfoWrapper retuns the file related fields
     * 
     * */
    @AuraEnabled(cacheable= false)
    public static FileInfoWrapper getRelatedFilesByRecordId(String recordId) {
        FileInfoWrapper fileObj = new FileInfoWrapper();
        // Get record file IDs  
        List<ID> fileIDs = new List<ID>();
        List<ContentVersion> docs = new List<ContentVersion>();
        try{
            docs = DH_KMQueryManager.getRelatedFilesByEventRecordId(recordId);
            String doclink = getFilePublicURL(docs[0].ContentDocumentId, recordId);
            
            // POPULATE WRAPPER
            fileObj.contentDocId = docs[0].ContentDocumentId;
            fileObj.publicUrl = doclink;
        }  
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching related files for Go live Calendar : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }          
        return fileObj;
    }
    
   /**************************************************************************************************************************************************
     *
     * @description this method gets the Public link for GoliveCalendar File
     *
     * @param   docId       ContentDocument Id of file Content Version
     * @param   recordId    String recordId of GoliveCalender event
     *
     * @return  link        retuns the Public link of GoliveCalendar File
     *
     * */
    // GET GOLIVE FILE PUBLIC LINK
    public static String getFilePublicURL(String docId, String recordId) {
        List<ContentDistribution > docs = new List<ContentDistribution>();
        String link ;
        
        try{
            
            if(docId.length() >0) {
                List<ContentDocumentLink> docLink = [SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordId  WITH SECURITY_ENFORCED LIMIT 1];
                List<ContentVersion> ver = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =:docLink[0].ContentDocumentId WITH SECURITY_ENFORCED LIMIT 1];
                docs = [SELECT Id, ContentDocumentId, ContentVersionId, DistributionPublicUrl  FROM ContentDistribution WHERE ContentDocumentId =:docLink[0].ContentDocumentId   LIMIT 1];   
                link = docs[0].DistributionPublicUrl;
                                
            }
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching FilePublicURL for Go live Calendar : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return link;        
    }
    
    // WRAPPER FOR PREVIEW FILE 
    public class FileInfoWrapper{
       
        @AuraEnabled public String contentDocId ;
        @AuraEnabled public String publicUrl;
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
            if(title.length()>0){
                glc.Name=title;
                glc.Title__c=title;
            }
            
           if(goLiveDate != null){
                glc.Go_Live_Date__c=goLiveDate;
           }
           
           if(category.length()>0){
                glc.Category__c=category;
           }
           if(region.length()>0){
            glc.Region__c=region;
           }
        
            if(Schema.sObjectType.Go_Live_Calendar__c.fields.Region__c.isCreateable()){
                insert glc;
            }
            else{
                return null;
            }
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while creating event : ' + e.getMessage()+' at line no: '+e.getLineNumber());
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
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        // Query to check if the user has the specified permission set
        psaList = DH_KMQueryManager.getUserInfoForPermissionSet(permissionSetName);  
       	Profile p = DH_KMQueryManager.getCurrentUserProfile();
        if(p.Name == DH_KMConstants.SYSTEM_ADMINISTRATOR){
            return true;
        }
        // If the list is not empty, it means the user has the permission set
        return !psaList.isEmpty();
    }
}