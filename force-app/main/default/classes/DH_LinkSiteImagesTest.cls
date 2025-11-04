/*

*********************************************************

Apex Class/LWC     : DH_LinkSiteImagesTest

Created Date       : 

@description       : DH_LinkSiteImages Test Class

@jiraid            : CC-

*********************************************************

*/
@isTest
public class DH_LinkSiteImagesTest {
  @TestSetup
  public static void setupTestRecords() {
    Profile guestProfile = [SELECT Id, name FROM Profile WHERE Name =: DH_KMConstants.RADNET_COMMUNITY_PROFILE LIMIT 1];
    User guestUser = new User(
      Username = 'guestuser@test.com',
      FirstName = 'Guest',
      LastName = 'User',
      Email = 'guestuser@test.com',
      Alias = 'guest',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = guestProfile.Id,
      LanguageLocaleKey = 'en_US' );
    insert guestUser;
    
    Profile p1 = [SELECT Id FROM Profile WHERE Name =: DH_KMConstants.SYSTEM_ADMINISTRATOR];
    User systemAdmin = new User(Alias = 'rsWest', Email = 'radSchWest@testorg.com',
                                EmailEncodingKey = 'UTF-8', LastName = 'TestingWest', LanguageLocaleKey = 'en_US',
                                LocaleSidKey = 'en_US', ProfileId = p1.Id,
                                TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, UserPermissionsKnowledgeUser = true,
                                UserName = 'radSch3West@testorg.com');
    insert systemAdmin;	
    System.runAs(systemAdmin){
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
    }    
  }
  @isTest
  public static void testgetVersionFiles(){
    User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com' LIMIT 1];
    System.runAs(u) {
      Account testAccount = [Select Id from Account where Name ='Test Account' LIMIT 1];
      ContentVersion testContentVersion = [Select Id from ContentVersion where Title ='Test Document' LIMIT 1];
      List<ContentVersion> versions1 = DH_LinkSiteImages.getVersionFiles(testAccount.Id);
      ContentDocumentLink accountCdl = new ContentDocumentLink(
          ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
          LinkedEntityId = testAccount.Id,
          ShareType = 'V'
      );
      insert accountCdl;     
        
      List<ContentVersion> versions = DH_LinkSiteImages.getVersionFiles(testAccount.Id);
      System.assertEquals(true, versions != null);
      System.assertEquals(1, versions.size());
      ContentVersion firstVersion = versions.get(0);
      System.assertEquals(true,versions.size()>0,'checking if data is coming');
    }
  }
  
  @isTest
  public static void testgetLexOriginGuestuser(){
    User u = [SELECT Id FROM User WHERE UserName = 'guestuser@test.com' LIMIT 1];
    System.runAs(u) {
      String result =DH_LinkSiteImages.getLexOrigin();
      System.assertEquals(true,result.length()>0,'checking if data is coming');
    }    
  }

  @isTest
  public static void testgetLexOrigin(){
    User u = [SELECT Id FROM User WHERE UserName = 'radSch3West@testorg.com' LIMIT 1];
    System.runAs(u) {
      String result =DH_LinkSiteImages.getLexOrigin();
      System.assertEquals(true,result.length()>0,'checking if data is coming');
    }
  }
}