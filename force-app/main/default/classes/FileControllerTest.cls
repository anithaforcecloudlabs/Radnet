/*

*********************************************************

Apex Class/LWC     : FileControllerTest

Created Date       : 19-07-2024

@description       : FileController Test Class

@jiraid            : CC-949

*********************************************************

*/
@isTest
public class FileControllerTest {
    
    @isTest
    public static void setupTestRecords() {
    	Id site=Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.ACCOUNT_RECORDTYPE_SITE).getRecordTypeId();
        Account testAccount = new Account(
         RecordTypeId=site,
         Name = 'Test Account',
         Phone = '1234567890'
        );
        insert testAccount;
         
        ContentVersion testContentVersion = new ContentVersion(
         VersionData = Blob.valueOf('Test Content'),
         Title = 'Test Document',
         PathOnClient = 'TestDocument.jpg',
         ContentLocation = 'S'
        );
        insert testContentVersion;
        
        List<ContentVersion> versions1 = FileController.getVersionFiles(testAccount.Id);
        ContentDocumentLink accountCdl = new ContentDocumentLink(
             ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
             LinkedEntityId = testAccount.Id,
             ShareType = 'V'
        );
        insert accountCdl;     
         
        List<ContentVersion> versions = FileController.getVersionFiles(testAccount.Id);
        System.assertEquals(true, versions != null);
        System.assertEquals(1, versions.size());
        ContentVersion firstVersion = versions.get(0);
        System.assertEquals(true,versions.size()>0,'checking if data is coming');
    }
    
    @isTest
    public static void testLexOrigin(){
        Test.startTest();
        String lex = FileController.getLexOrigin();
        Test.stopTest();
        System.assertEquals(true, lex.length() > 0, 'success');
    }
}