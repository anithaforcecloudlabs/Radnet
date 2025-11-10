@isTest(seeAllData=true)
public class DH_MessagingSessionFileHandlerTest {

    @isTest
    static void testAfterInsert_FileLinkedToCase() {
        // Create a Case
        Case c = new Case(Subject = 'Test Case');
        insert c;

        // Get required org data (Messaging setup already exists in your org)
        MessagingChannel channel   = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser endUser   = [SELECT Id FROM MessagingEndUser LIMIT 1];
        Conversation conv          = [SELECT Id FROM Conversation LIMIT 1];

        // Create a MessagingSession linked to the Case
        MessagingSession session = new MessagingSession(
            Status = 'Waiting',
            MessagingChannelId = channel.Id,
            MessagingEndUserId = endUser.Id,
            ConversationId = conv.Id,
            CaseId = c.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert session;

        // Create a test file (ContentVersion)
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Dummy content')
        );
        insert cv;

        // Get the ContentDocumentId
        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        // Create ContentDocumentLink to MessagingSession
        ContentDocumentLink sessionLink = new ContentDocumentLink(
            ContentDocumentId = insertedVersion.ContentDocumentId,
            LinkedEntityId    = session.Id,
            ShareType         = 'V',
            Visibility        = 'AllUsers'
        );

        Test.startTest();
        insert sessionLink; // This will invoke DH_MessagingSessionFileHandler.afterInsert
        Test.stopTest();

        // Verify: The same file is now linked to the Case
        List<ContentDocumentLink> caseLinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :c.Id
        ];

        System.assert(!caseLinks.isEmpty(), 'File should be linked to Case');
        System.assertEquals(insertedVersion.ContentDocumentId, caseLinks[0].ContentDocumentId,
            'The same ContentDocument should be linked to the Case');
    }
}