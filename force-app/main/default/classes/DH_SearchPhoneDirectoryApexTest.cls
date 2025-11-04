/******************************************************************************************************************************************************
 * 
 * Apex Test Class : DH_SearchPhoneDirectoryApexTest
 * 
 * Created Date    : 11/06/2024
 * 
 * @description    : This test class verifies the functionality of the DH_SearchPhoneDirectoryApex class.
 * 
 * @JIRA Id        : CC-341
 * 
 * */ 
@isTest
public class DH_SearchPhoneDirectoryApexTest {
    
    @testSetup
    static void setup() {
        // Creating test data
        List<Phone_Directory__c> phoneDirectories = new List<Phone_Directory__c>();
        
        phoneDirectories.add(new Phone_Directory__c(
            Region__c = DH_KMConstants.REGION_NORTH,
            Entry_Point_Name__c = 'Main Office',
            Phone_Number__c = '123-456-7890',
            Comments__c = 'Main office in North region'
        ));
        
        phoneDirectories.add(new Phone_Directory__c(
            Region__c = DH_KMConstants.REGION_SOUTH,
            Entry_Point_Name__c = 'Branch Office',
            Phone_Number__c = '098-765-4321',
            Comments__c = 'Branch office in South region'
        ));
        
        phoneDirectories.add(new Phone_Directory__c(
            Region__c = DH_KMConstants.REGION_NORTH,
            Entry_Point_Name__c = 'Support Center',
            Phone_Number__c = '555-555-5555',
            Comments__c = 'Support center in North region'
        ));
        
        insert phoneDirectories;
    }
 
    @isTest
    static void testGetRegion() {
        // Test the getRegion method
        List<String> regions = DH_SearchPhoneDirectoryApex.getRegion();
        
        // Assert the results
        System.assertEquals(2, regions.size(), 'There should be 2 unique regions.');
        System.assert(regions.contains(DH_KMConstants.REGION_NORTH), 'Region should contain North.');
        System.assert(regions.contains(DH_KMConstants.REGION_SOUTH), 'Region should contain South.');
    }
    
    @isTest
    static void testGetEntryPointName() {
        // Test the getEntryPointName method
        List<String> entryPointNames = DH_SearchPhoneDirectoryApex.getEntryPointName();
        
        // Assert the results
        System.assertEquals(3, entryPointNames.size(), 'There should be 3 entry point names.');
        System.assert(entryPointNames.contains('Main Office'), 'EntryPointName should contain Main Office.');
        System.assert(entryPointNames.contains('Branch Office'), 'EntryPointName should contain Branch Office.');
        System.assert(entryPointNames.contains('Support Center'), 'EntryPointName should contain Support Center.');
    }
    
    @isTest
    static void testGetRecords() {
        // Test getRecords method for different scenarios
 
        // Case 1: Both region and entry point name are provided
        List<Phone_Directory__c> records = DH_SearchPhoneDirectoryApex.getRecords(DH_KMConstants.REGION_NORTH, 'Main Office');
        System.assertEquals(1, records.size(), 'There should be 1 record for North and Main Office.');
        System.assertEquals('123-456-7890', records[0].Phone_Number__c, 'Phone number should be 123-456-7890.');
 
        // Case 2: Only region is provided
        records = DH_SearchPhoneDirectoryApex.getRecords(DH_KMConstants.REGION_NORTH, null);
        System.assertEquals(2, records.size(), 'There should be 2 records for North.');
 
        // Case 3: Only entry point name is provided
        records = DH_SearchPhoneDirectoryApex.getRecords(null, 'Branch Office');
        System.assertEquals(1, records.size(), 'There should be 1 record for Branch Office.');
        System.assertEquals('098-765-4321', records[0].Phone_Number__c, 'Phone number should be 098-765-4321.');
 
        // Case 4: Neither region nor entry point name is provided
        records = DH_SearchPhoneDirectoryApex.getRecords(null, null);
        System.assertEquals(3, records.size(), 'There should be 3 records in total.');
    }
}