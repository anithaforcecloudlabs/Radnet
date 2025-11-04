/******************************************************************************************************************************************************
 * 
 * Apex Controller : DH_SearchSiteDirectory
 * 
 * Created Date    : 21/03/2025
 * 
 * @description    : It is the apex controller for the lwc component - 'dH_searchSiteDirectory' used to fetch the records in the knowledge article.
 * 
 * @JIRA Id        : CC-1519
 * 
 * */
public with sharing class DH_SearchSiteDirectory {
    
    @AuraEnabled(cacheable=true)
    public static List<Site_Directory__c> getRecords()
    {        
    return [SELECT State__c,Site_Group__c,Site_Code__c,Site_Name__c,Address__c,Site_Phone__c,Site_Fax_Number__c,Site_Medical_Records_Ring_Group__c,Site_Front_Desk_Ring_Group__c,Scheduling_Main__c,Extra_Info__c FROM Site_Directory__c ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Site_Directory__c> getRecordsForLL()
    {       
    return [SELECT Site_Code__c,Site_Name__c,Address__c FROM Site_Directory__c ];
    
    }
}