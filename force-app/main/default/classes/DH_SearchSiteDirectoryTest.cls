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
@isTest
public class DH_SearchSiteDirectoryTest {
    @testSetup
    static void setup() {
        // Creating test data
        List<Site_Directory__c> siteDirectories = new List<Site_Directory__c>();
        
        siteDirectories.add(new Site_Directory__c(
            State__c = 'AZ',
            Site_Group__c = 'Arizona',
            Site_Code__c = 'AZH',
            Site_Name__c = 'AZD-SiteName',
            Address__c= 'Arizon , 3446 street , Address1',
            Site_Phone__c= '(400)567-535',
            Site_Fax_Number__c= '(401)564-5365',
            Site_Medical_Records_Ring_Group__c='(401)564-5365',
            Site_Front_Desk_Ring_Group__c='(401)564-5365',
            Scheduling_Main__c='(401)564-5365'
        ));
        
        siteDirectories.add(new Site_Directory__c(
            State__c = 'AZ',
            Site_Group__c = 'Antelope Valley',
            Site_Code__c = 'AZH',
            Site_Name__c = 'AZD-SiteName1',
            Address__c= 'Arizon , 3446 street , Address1',
            Site_Phone__c= '(400)567-535',
            Site_Fax_Number__c= '(401)564-5365',
            Site_Medical_Records_Ring_Group__c='(401)564-5361',
            Site_Front_Desk_Ring_Group__c='(401)564-5365',
            Scheduling_Main__c='(401)564-5365'
        ));
        
        siteDirectories.add(new Site_Directory__c(
            State__c = 'AZ',
            Site_Group__c = 'Arizona',
            Site_Code__c = 'AZH',
            Site_Name__c = 'AZD-SiteName2',
            Address__c= 'Arizon , 3446 street , Address1',
            Site_Phone__c= '(400)567-530',
            Site_Fax_Number__c= '(401)564-5360',
            Site_Medical_Records_Ring_Group__c='(401)564-5360',
            Site_Front_Desk_Ring_Group__c='(401)564-5360',
            Scheduling_Main__c='(401)564-5369'
        ));
        
        insert siteDirectories;
    }
 @isTest
    static void testGetRecords() {
        // Test getRecords method for different scenarios
 
        // Case 1: Both region and entry point name are provided
        List<Site_Directory__c> records = DH_SearchSiteDirectory.getRecords();
        System.assertEquals(3, records.size(), 'There should be 1 record for AZ and Arizona.');
        System.assertEquals('(400)567-535', records[0].Site_Phone__c, 'Site Phone number should be (400)567-535.');
 
        // Case 2: Only region is provided
        records = DH_SearchSiteDirectory.getRecords();
        System.assertEquals(3, records.size(), 'There should be 3 records for Az.');
 
        List<Site_Directory__c> records1 = DH_SearchSiteDirectory.getRecordsForLL();
        System.assertEquals(3, records.size(), 'There should be 1 record for AZ and Arizona.');
        System.assertEquals('AZH', records[0].Site_Code__c, 'Site Code should be AZH.');
        
        records1 = DH_SearchSiteDirectory.getRecordsForLL();
        System.assertEquals(3, records.size(), 'There should be 3 records for Az.');
    }

}