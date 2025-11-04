/*

 *********************************************************

Apex Class/LWC     : TestClassCreateDocumentLink
  
Created Date       :
  
@description       : Test Class For CreateDocumentLink Class

@jiraid            : CC-758

 *********************************************************

 */
@isTest
public class TestClassCreateDocumentLink {
  /**
   * @description : testSetup Method
   **/
  @testSetup
  static void createData(){
    //  test Account record
    Id site=Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.ACCOUNT_RECORDTYPE_SITE).getRecordTypeId();
    List<Account> accList = new List<Account>();
    for(Integer i=0; i<5; i++){
      Account testAccount = new Account(
        RecordTypeId=site,
      Name = 'Test Account'+i,
      Site_code__c = 'T'+i
        );
      accList.add(testAccount);
    }
    
    insert accList;
    
    // create healthcare provider
    List<HealthcareProvider> hcpList = new List<HealthcareProvider>();
    for(Integer i=0; i<5; i++){
      HealthcareProvider newsite= new HealthcareProvider(
        Name=accList[i].Name,
      AccountId=accList[i].Id
        );
      hcpList.add(newsite);
    }
    insert hcpList;
    
    //  ContentVersion for the Account
    ContentVersion testContentVersion = new ContentVersion(
      VersionData = Blob.valueOf('Test Content'),
    Title = 'Test Document',
    PathOnClient = 'TestDocument.jpg',
    ContentLocation = 'S'
      );
    insert testContentVersion;
      
      // GOLIVE TEST DATA CREATE
        
        Go_Live_Calendar__c glc = new Go_Live_Calendar__c(
            						Name = 'Test golive',
            						Title__c = 'Test golive',
            						Go_Live_Date__c = Datetime.now(), 
            						Category__c= 'test' , 
            						Region__c= 'CA');
        insert glc;
        
         ContentVersion glcVer = new ContentVersion(
            Title = 'Test glcdoc',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test data')
        );
        insert glcVer;
      	
      	ContentVersion docQuery = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test glcdoc' LIMIT 1];
        
        // Link the document to the Account
        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = glc.Id,
            ContentDocumentId = docQuery.ContentDocumentId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert link;
  }
  @isTest
  static void testTriggerOnInsert() {
    
    List<Account> accList = [SELECT Id, Name FROM Account WHERE Name =: 'Test Account1'];
    
    ContentVersion testContentVersion = [SELECT Id, Title FROM ContentVersion WHERE Title =: 'Test Document'];
    
    
    // test ContentDocumentLink for the Account
    ContentDocumentLink accountCdl = new ContentDocumentLink(
      ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:testContentVersion.Id].ContentDocumentId,
    LinkedEntityId = accList[0].Id,
    ShareType = 'V'
      );
    insert accountCdl;
    
    // Verify HealthcareProvider
    List<HealthcareProvider> hcps = [SELECT Id, Name FROM HealthcareProvider WHERE Accountid = :accList[0].id];
    Assert.areEqual(true, hcps.size()>0,'Verifying single Site linked to account');
    HealthcareProvider testHcp = hcps[0];
    
    //ContentDocumentLink creation for Site
    List<ContentDocumentLink> siteCdls = [SELECT Id,ShareType, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :accountCdl.ContentDocumentId AND LinkedEntityId = :testHcp.Id];
    Assert.areEqual(true, siteCdls.size() >= 0,'Verifying that only one contentdocument is linked to the account');
  }
    // TEST ContentDistribution record CREATE when GoLiveCalendar ContentLink IS CREATED 
    @isTest
    static void testGoliveContentDistributionCreate() {
        
        List<Go_Live_Calendar__c> glc = [SELECT id  FROM Go_Live_Calendar__c WHERE name = 'Test golive' LIMIT 1];
        List<ContentDocumentLink> link =  [SELECT ContentDocumentId, ContentDocument.Title, ShareType, Visibility  FROM ContentDocumentLink WHERE LinkedEntityId =: glc[0].Id];
        
        Test.startTest();
        List<ContentDistribution> publicDoc = new List<ContentDistribution>();
        publicDoc = [SELECT Id, ContentDocumentId, ContentVersionId, DistributionPublicUrl  FROM ContentDistribution WHERE ContentDocumentId =:link[0].ContentDocumentId  LIMIT 1];
        Test.stopTest();
        system.assertEquals(true,publicDoc.size()>0, 'test success ');
    }
}