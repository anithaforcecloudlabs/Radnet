@isTest(SeeAllData=true)
public class DH_MessagingSessionTriggerHelperTest {
    
    @isTest
    static void testValidatePreviousVerifiedChat() {
        User userRec=DH_TestDataFactory.createRadNetMarketingUser();
        System.runAs(userRec) {
        // Setup: create Account and Case
        Id paRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('DH_PersonAccount').getRecordTypeId();
        
        Account acc = new Account(
            LastName = 'Test Account',
            RecordTypeId = paRecordTypeId
        );
        insert acc;
        
        Case c = new Case(Subject = 'Test Case');
        insert c;
        
        // Query required Messaging records (must exist in org)
        MessagingChannel channel = new MessagingChannel(
          //  Name = 'Test Channel',
            MessagingPlatformKey = 'PlatformKeyTest3',
            MessageType = 'EmbeddedMessaging',
       DeveloperName='CustomMessagingForInAppandWeb6',
       MasterLabel='Custom Messaging For In App and Web6'
            // Fill in any other required fields
        );
        insert channel;
       MessagingEndUser endUser = new MessagingEndUser(
            Name = 'Test Chat User2',
            MessagingChannelId = channel.Id,
            MessageType = 'EmbeddedMessaging',
            MessagingPlatformKey = 'v2/iamessage/UNAUTH/NA/uid:42985d80-edcc-46b1-a722-5474e755664',
            Locale = 'en_US',AccountId=acc.id
         
        );
        // Try to get a valid Conversation record (required for rich content channels)
      insert endUser;
            endUser.AccountId=acc.id;
            update endUser;
            Conversation conv = [SELECT Id FROM Conversation LIMIT 1];
       Id dummyConversationId = conv.id;
        MessagingSession session = new MessagingSession(
            First_Name__c='Vikas',LastName__c='test',Region__c='East',
            Status = 'Waiting',
            MessagingChannelId = channel.Id,
            MessagingEndUserId = endUser.Id,
           ConversationId = dummyConversationId,     // may be null if none exist
            CaseId = c.Id,
            System_Id__c = 'MA'
        );
        insert session;
            system.debug('session'+session.enduseraccountid);
        // Run methods under test
            Test.startTest();
            DH_MessagingSessionTriggerHelper.validatePreviousVerifiedChat(session.Id);
            Account verifiedPatient = DH_MessagingSessionTriggerHelper.getPreviousVerifiedPatient(session.Id);
            DH_MessagingSessionTriggerHelper.createNewPatient(session.Id);
            Test.stopTest();
            
            // Assertions
            MessagingEndUser updatedEndUser = [
                SELECT Id, AccountId
                FROM MessagingEndUser 
                WHERE Id = :endUser.Id
            ];
            
            System.assertNotEquals(null, updatedEndUser.Id, 'EndUser should exist after test');
    }
    }
    
    @isTest(seeAllData=true)
    static void testValidatecreateNewPatient() {
        User userRec=DH_TestDataFactory.createRadNetWestManagerUser();
        System.runAs(userRec) {
        Id paRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('DH_PersonAccount').getRecordTypeId();
        
        Account acc = new Account(
            LastName = 'Test Account',
            RecordTypeId = paRecordTypeId
        );
        insert acc;
        
        Case c = new Case(Subject = 'Test Case');
        insert c;
        
        // Query required Messaging records (must exist in org)
        MessagingChannel channel = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser endUser = [SELECT Id, AccountId FROM MessagingEndUser LIMIT 1];
        
        // Try to get a valid Conversation record (required for rich content channels)
        Id convId;
        List<Conversation> convList = [SELECT Id FROM Conversation LIMIT 1];
        if (!convList.isEmpty()) {
            convId = convList[0].Id;
        }
        
        // Create MessagingSession linked to that end user
        MessagingSession session = new MessagingSession(
            Status = 'Waiting',
            MessagingChannelId = channel.Id,
            MessagingEndUserId = endUser.Id,
            ConversationId = convId,     // may be null if none exist
            CaseId = c.Id,
            System_Id__c = 'MA'
        );
        insert session;
        
        // Assign Account to MessagingEndUser for validation
        endUser.AccountId = acc.Id;
        update endUser;
        
        // Run methods under test
            Test.startTest();
            DH_MessagingSessionTriggerHelper.invokeNewPatientService(session.Id, acc);
            DH_MessagingSessionTriggerHelper.createContactCenterCaseForMessaging(acc.Id,session.Id);
            Test.stopTest();
            
            // Assertions
            MessagingEndUser updatedEndUser = [
                SELECT Id, AccountId 
                FROM MessagingEndUser 
                WHERE Id = :endUser.Id
            ];
            
            System.assertNotEquals(null, updatedEndUser.Id, 'EndUser should exist after test');
       
    }
    }
    
    @isTest(seeAllData=true)
    static void testGetMessMapAndGetMSList() {
        User userRec=DH_TestDataFactory.createRadNetMarketingUser();
        System.runAs(userRec) {
        // Setup: create Case + dummy session
        Case c = new Case(Subject = 'Test Case 2');
        insert c;
        
        MessagingChannel channel = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser endUser = [SELECT Id FROM MessagingEndUser LIMIT 1];
        
        Id convId;
        List<Conversation> convList = [SELECT Id FROM Conversation LIMIT 1];
        if (!convList.isEmpty()) {
            convId = convList[0].Id;
        }
        
        MessagingSession session = new MessagingSession(
            Status = 'Waiting',
            MessagingChannelId = channel.Id,
            MessagingEndUserId = endUser.Id,
            ConversationId = convId,     // may be null if none exist
            CaseId = c.Id
        );
        insert session;
        
        // Run methods
        Test.startTest();
        Map<Id, MessagingSession> msMap = DH_MessagingSessionTriggerHelper.getMessMap(new Set<Id>{session.Id});
        Test.stopTest();
    }
    }
}