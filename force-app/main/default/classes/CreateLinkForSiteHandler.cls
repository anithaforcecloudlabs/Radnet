/******************************************************************************************************************************************************
 *
 * @Created Date      :  March 2024
 *
 * @description       : Create Content Document Link on HealthcareProvider object if new attachement added on related account
 *
 * @JIRA Id           :  CC-758
 * */
public without sharing class CreateLinkForSiteHandler {
  
  /**
   * @description //Create Content Document Link
   * @param new content document links
   **/
  public void createCDLForHealthcareProvider(List<ContentDocumentLink> newRecords) {
    try {
      List<Account> accounts = new List<Account>(); //Store list of accounts where attachment is added
      List<HealthcareProvider> healthcareProviderList = new List<HealthcareProvider>(); //List for HealthcareProvider related to account on which attachment added
      List<HealthcareProvider> healthcareProviderUpdate = new List<HealthcareProvider>();  // List of HealthcareProvider to update ProviderPhotoId field
      List<ContentDocumentLink> contentDocToCreate = new List<ContentDocumentLink>();  //content document link need to create on healthcareprovider object same as related account
      List<Id> accLinkEntityId = new List<Id>();
      List<String> accNames= new List<String>();
      Map<Id,HealthcareProvider> accHcpMap = new Map<Id,HealthcareProvider>();
      
      for (ContentDocumentLink cdl : newRecords) {
        if(cdl.LinkedEntityId != null){
          accLinkEntityId.add(cdl.LinkedEntityId);
        }
      }
      if (Account.SObjectType.getDescribe().isAccessible()){
        accounts = [SELECT Id, name 
                   FROM account WHERE Id IN: accLinkEntityId WITH SECURITY_ENFORCED];
      }
      if(!accounts.isEmpty()){
        for(Account a: accounts){
          accNames.add(a.Name);
        }
      }
      healthcareProviderList = [SELECT Id, name, AccountId, ProviderPhotoId 
               FROM HealthcareProvider WHERE name IN: accNames]; //havent checked CRUD because need to attach document to HealthcareProvider even if user dont have access
      for(HealthcareProvider h: healthcareProviderList){
        accHcpMap.put(h.AccountId,h);
      }
      for (ContentDocumentLink cdl : newRecords) {  //create content document link for healthcareProvider with matching account name(if attachment is added on account)
        if(accHcpMap.containsKey(cdl.LinkedEntityId)){
          ContentDocumentLink cd = new ContentDocumentLink();
          cd.ContentDocumentId = cdl.ContentDocumentId;
          cd.LinkedEntityId = accHcpMap.get(cdl.LinkedEntityId).Id;
          cd.Visibility = cdl.Visibility;
          cd.ShareType = 'V';
          accHcpMap.get(cdl.LinkedEntityId).ProviderPhotoId = cd.ContentDocumentId;
          healthcareProviderUpdate.add(accHcpMap.get(cdl.LinkedEntityId));
          contentDocToCreate.add(cd);
        }
      }
      //havent checked CRUD because need to attach document to HealthcareProvider even if user dont have access
      if(!healthcareProviderUpdate.isEmpty() && healthcareProviderUpdate != null){
        Database.update(healthcareProviderUpdate, false);  //update ProviderPhotoId field on healthcareProvider object where attachment is added
      }
      if(!contentDocToCreate.isEmpty() && contentDocToCreate != null){
        Database.insert(contentDocToCreate, false);  //create content document link for healthcareProvider with matching account name(if attachment is added on account)
      }
    }
    catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'Error while attaching record on HealthcareProvider'+ e.getMessage()+' at line no: '+e.getLineNumber());
    }
  }
    
    public static void handleAfterInsertGolive(List<ContentDocumentLink> newRecords){
        
      try{
          List<Id> glcLinkEntityId = new List<Id>();
          List<Go_Live_Calendar__c> glcList = new List<Go_Live_Calendar__c>();
          List<Id> glcId = new List<Id>();
          Set<Id> cdlIds = new Set<Id>();
          List<ContentDistribution> contDistList = new List<ContentDistribution>();
          List<ContentVersion> ver = new List<ContentVersion>();
          
          for (ContentDocumentLink cdl : newRecords) {
            
            if(cdl.LinkedEntityId != null){
                glcLinkEntityId.add(cdl.LinkedEntityId);
                  cdlIds.add(cdl.ContentDocumentId);
            }
          }
          
          ver = [SELECT Id, ContentDocumentId, Title, FileType FROM ContentVersion WHERE ContentDocumentId IN: cdlIds ];

          Map<Id, ContentVersion> verMap = new Map<Id, ContentVersion>();
          for(ContentVersion v: ver){
              verMap.put(v.ContentDocumentId, v);
          }
        
          glcList = [SELECT Id  FROM Go_Live_Calendar__c WHERE Id IN: glcLinkEntityId WITH SECURITY_ENFORCED];
          if(glcList.size() != null){
            for(Go_Live_Calendar__c glc :glcList){
                glcId.add(glc.Id);
            } 
          }
          
          for (ContentDocumentLink cdl : newRecords) { 
              if(glcId.contains(cdl.LinkedEntityId)){
                    ContentDistribution cd = new ContentDistribution();
                      
                      cd.ContentVersionId = verMap.get(cdl.ContentDocumentId).Id;
                      cd.Name = verMap.get(cdl.ContentDocumentId).Title;
                      cd.PreferencesAllowViewInBrowser = true;
                      cd.PreferencesLinkLatestVersion = true;
                      cd.PreferencesAllowPDFDownload = (verMap.get(cdl.ContentDocumentId).FileType.toLowerCase() == 'jpg' || verMap.get(cdl.ContentDocumentId).FileType.toLowerCase() == 'png' || verMap.get(cdl.ContentDocumentId).FileType.toLowerCase() == 'jpeg') ? false : true;

                    contDistList.add(cd);
                  
              }
          }
          if(contDistList.size() != null || contDistList.size()>0){
              Insert contDistList;
          }
    }
    catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'Error while creating ContentDistribution record for GoliveCalendar ContentLink '+ e.getMessage()+' at line no: '+e.getLineNumber());
    }
       
    }
}