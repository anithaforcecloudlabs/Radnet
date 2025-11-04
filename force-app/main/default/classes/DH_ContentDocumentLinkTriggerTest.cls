/*
 *********************************************************

Apex Class         : DH_ContentDocumentLinkTriggerTest
  
Created Date       : 19-07-2024
  
@description       : This class is used to test the functionality of DH_ContentDocumentLink trigger and its handler class

@jiraid            : CC-949

 *********************************************************
 */

@isTest
public class DH_ContentDocumentLinkTriggerTest {
    
    // This methods tests the visibility change of contentDocumentLink object
	@isTest
    static void testContentDocumentLinkVisibilityChange() {
        
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
 
        // Create and insert a ContentVersion
        ContentVersion version = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test data')
        );
        insert version;
        
        ContentVersion docQuery = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document' LIMIT 1];
        
        // Link the document to the Account
        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = acc.Id,
            ContentDocumentId = docQuery.ContentDocumentId,
            ShareType = 'I',
            Visibility = 'InternalUsers'
        );
        insert link;
 
        // Retrieve the ContentDocumentLink and check the Visibility
        ContentDocumentLink retrievedLink = [SELECT Id, Visibility FROM ContentDocumentLink WHERE Id = :link.Id];
        System.assertEquals('AllUsers', retrievedLink.Visibility);
    }
}