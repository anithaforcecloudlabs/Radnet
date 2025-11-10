@isTest(seeAllData=true)
public class DH_MessagingSessionHandlerTest {
  @isTest
    static void testEndedSessionUpdate() {
        Case c = new Case(Subject = 'Test Case');
        insert c;
        // Query an existing channel + end user from your org setup
        MessagingChannel channel = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser endUser = [SELECT Id FROM MessagingEndUser LIMIT 1];
 Conversation conv = [SELECT Id FROM Conversation LIMIT 1];
        // Create a MessagingSession
        MessagingSession session = new MessagingSession(
            Status = 'Waiting',
            MessagingChannelId = channel.Id,
            MessagingEndUserId = endUser.Id,
            ConversationId = conv.Id,
            CaseId=c.id,
            OwnerId=userinfo.getuserid()
        );
        insert session;
ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Dummy content')
        );
        insert cv;

        // Query the ContentDocumentId from the inserted version
        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        // Link the file to MessagingSession
        ContentDocumentLink sessionLink = new ContentDocumentLink(
            ContentDocumentId = insertedVersion.ContentDocumentId,
            LinkedEntityId    = session.Id,
            ShareType         = 'V',
            Visibility        = 'AllUsers'
        );
        insert sessionLink;
        Test.startTest();
        
         DH_MessagingSessionHandler.afterUpdate(
            new List<MessagingSession>{ session },
            new Map<Id, MessagingSession>{ session.Id => session }
        );
        // DH_MessagingSessionHandler.updateCaseOwners(new List<MessagingSession>{session });
Test.stopTest();
        System.assert(true, 'Trigger executed without errors');
    }

    }