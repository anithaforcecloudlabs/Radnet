@isTest
public class ActSpeedDialSearchTest {

    @testSetup
    static void setupTestData() {
        // Create a test user with Region__c field
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            Coast__c = 'East Coast',
            Region__c = 'NE;MA' // Simulating both regions for coverage
        );
        insert u;

        // Create Speed_Dials__c records
        insert new Speed_Dials__c(
            Name = 'East Contact',
            Phone_Number__c = '1234567890',
            Description__c = 'EC XFR',
            Region__c = 'NE',
            External_Id__c = 'EAST123'
        );

        insert new Speed_Dials__c(
            Name = 'West Contact',
            Phone_Number__c = '9876543210',
            Description__c = 'West WC',
            Region__c = 'MA',
            External_Id__c = 'WEST123'
        );

        insert new Speed_Dials__c(
            Name = 'Unmatched Contact',
            Phone_Number__c = '5555555555',
            Description__c = 'South',
            Region__c = 'South',
            External_Id__c = 'SOUTH123'
        );
    }

    static testmethod void testGetDials() {
        // Run as the user with Region__c set
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@example.com' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            List<ActSpeedDialSearch.SpeedDialSearchResult> results = ActSpeedDialSearch.getDials();
            Test.stopTest();

            System.assertNotEquals(0, results.size(), 'Should return matching Speed_Dials__c records');
            Set<String> expectedNames = new Set<String>{'East Contact', 'West Contact'};
            for (ActSpeedDialSearch.SpeedDialSearchResult res : results) {
                System.assert(expectedNames.contains(res.name), 'Unexpected dial name returned');
                System.assertNotEquals(null, res.id, 'ID should not be null');
                System.assertNotEquals(null, res.phoneNumber, 'Phone number should not be null');
            }
        }
    }
	
}