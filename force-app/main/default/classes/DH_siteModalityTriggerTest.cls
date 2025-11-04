/*
 *********************************************************

Apex Class         : DH_siteModalityTriggerTest
    
Created Date       : May 15, 2024
    
@description       : Test class for trigger handler on Site modality(DH_siteModalityTriggerHandler and DH_siteModalityTrigger) object to avoid duplicates and to auto-populate name of site modality

@jiraid            : CC-104

 *********************************************************

 */
@isTest
public class DH_siteModalityTriggerTest {
    
    /**
     * @description: Create test data for test class in test setup method
     **/
    @testSetup
    private static void createData(){
        List<Account> accountsList = new List<Account>();
        RecordType siteRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :DH_KMConstants.ACCOUNT_RECORDTYPE_SITE LIMIT 1];
        Account acc = new Account(Name = 'Test Account', Site_Code__c = 'TEST', Phone = '1234567890', RecordTypeId = siteRecordType.Id);
        Insert acc;
        List<CareSpecialty> careSpeciltyList = new List<CareSpecialty>();
        CareSpecialty specialty = new CareSpecialty(Name = 'Test Specialty',CareSpecialty_External_ID__c='Test Specialty Ext');
        careSpeciltyList.add(specialty);
        CareSpecialty specialty2 = new CareSpecialty(Name = 'Test Specialty2',CareSpecialty_External_ID__c='Test Specialty Ext2');
        careSpeciltyList.add(specialty2);
        Insert careSpeciltyList;
        CareProviderFacilitySpecialty siteModRecord = new CareProviderFacilitySpecialty(Name= 'Site Mod 1', AccountId = acc.Id, SpecialtyId = specialty.Id);
        insert siteModRecord;
    }
    
    /**
     * @description: Test method to check duplicate site modalities for same site
     **/
    @isTest
    static void testDupliacteSiteModality() {
        // Create test data: Accounts
        Account acc = [SELECT Id, Name, Site_Code__c, Phone, RecordTypeId FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // Create test data: Care Specialties / Modalities
        CareSpecialty specialty = [SELECT Id, Name FROM CareSpecialty WHERE Name = 'Test Specialty' LIMIT 1];
        CareSpecialty specialty2 = [SELECT Id, Name FROM CareSpecialty WHERE Name = 'Test Specialty2' LIMIT 1];
        // Create a site modality object record
        CareProviderFacilitySpecialty junction1 = [SELECT Id, name from CareProviderFacilitySpecialty where NAME = 'Site Mod 1' LIMIT 1];
        
        // Try to create a duplicate  site modality record
        
        try {
            // Attempt to insert a duplicate  site modality record
            CareProviderFacilitySpecialty junction2 = new CareProviderFacilitySpecialty(AccountId = acc.Id, SpecialtyId = specialty.Id);
            insert junction2;
            System.assert(false, 'Expected DMLException was not thrown for insert.');
        }
        catch (DMLException e) {
            System.assert(e.getMessage().contains('This site modality already exists'));
        }
        
        // Update the  site modality object record
        junction1.SpecialtyId = specialty2.id; // Updating to the same SpecialtyId
        Test.startTest();
        try {
            // Attempt to update the  site modality object record
            update junction1;
            
        } catch (DMLException e) {
            System.assert(e.getMessage().contains('This site modality already exists'));
        }
        Test.stopTest();
    }
    
    /**
     * @description: test delete and undelete of site modality object record to test if cloned records site midality also deleted /Undeleted
     **/
    @isTest
    static void testDeteteUndeleteCloneObject() {
        CareProviderFacilitySpecialty siteMod1 = [SELECT Id, name from CareProviderFacilitySpecialty where NAME = 'Site Mod 1' LIMIT 1];
        DH_CareProviderFacilitySpecialty__c dHsiteMod1 = [SELECT Id, name from DH_CareProviderFacilitySpecialty__c where NAME = 'Site Mod 1' LIMIT 1];
        // Delete and Undelete the  site modality object record to test if cloned records site midality also deleted /Undeleted
        Test.startTest();
        delete siteMod1;
        undelete siteMod1;
        System.assertEquals('Site Mod 1', siteMod1.name, 'Site Modality Restored');
        System.assertEquals('Site Mod 1', dHsiteMod1.name, 'Dh Site Modality cloned Restored');
        Test.stopTest();
    }
}