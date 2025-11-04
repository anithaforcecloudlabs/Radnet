/******************************************************************************************************************************************************
 * 
 * Apex Controller : DH_SearchPhoneDirectoryApex
 * 
 * Created Date    : 11/06/2024
 * 
 * @description    : It is the apex controller for the lwc component - 'searchPhoneDirectory' used to fetch the phone number in the knowledge article.
 * 
 * @JIRA Id        : CC-341
 * 
 * */

public with sharing class DH_SearchPhoneDirectoryApex {
    
    /**************************************************************************************************************************************************
     * 
     * @description this method is used to get all the region from Phone_Directory__c
     * 
     * @return List of string of regions
     * 
     * */
	@AuraEnabled(cacheable=true)
    public static List<String> getRegion()
    {
        List<String> region = new List<String>();
        
            region=DH_KMQueryManager.getPhoneDirectoryRegion();
       
        return region;
    }
    
    /**************************************************************************************************************************************************
     * 
     * @description this method is used to get all the entry point name from Phone_Directory__c
     * 
     * @return List of string of all entry points
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static List<String> getEntryPointName()
    {
        List<String> entryPointName = new List<String>();
            entryPointName=DH_KMQueryManager.getAllEntryPointName();
        
        return entryPointName ;
    }
    
    /**************************************************************************************************************************************************
     * 
     * @description this method is used to get list of phone directory records on the basis of region and entry point name
     * 
     * @param string region name
     * 
     * @param string entry point name
     * 
     * @return List of Phone_Directory__c records
     * 
     * */
    @AuraEnabled(cacheable=true)
    public static List<Phone_Directory__c> getRecords(String reg, String entry)
    {
        List<Phone_Directory__c> records;
        
            records = DH_KMQueryManager.getPhoneDirectoryRecords(reg,entry);  
        return records ;
    }
}