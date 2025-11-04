/*

*********************************************************

Apex Class/LWC     : FileController

Created Date       : 19-07-2024

@description       : Get Content Version List. Modified for UCC as well.

@jiraid            : CC-949

*********************************************************

*/
public with sharing class FileController{
    
    /**
    * @description                             This method is used to get the file versions 
    * @param          recordId                 RecordId of the account record
    * @return         List<ContentVersion>     returns list of contentVersion attached to the account record with the given Id
    **/
    @AuraEnabled
    public static List<ContentVersion> getVersionFiles(String recordId){ 
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId 
                                                    FROM   ContentDocumentLink 
                                                    WHERE  LinkedEntityId =: recordId WITH SECURITY_ENFORCED];
        Set<Id> contentDocumentId = new Set<Id>();
            
        for(ContentDocumentLink cdl : contentDocumentList){
            contentDocumentId.add(cdl.ContentDocumentId);
        }
            
        List<ContentVersion> contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension,
                                                    ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                    CreatedDate, ContentDocumentId, ContentDocument.FileType
                                                    FROM   ContentVersion 
                                                    WHERE  ContentDocumentId IN : contentDocumentId WITH SECURITY_ENFORCED];
        return contentVersionList;            
    }

    
    /**
    * @description                  This method is used to get the lex origin of the org
    * @return         String        Returns the lex origin of org as a string
    **/
    @AuraEnabled
    public static String getLexOrigin(){
        Boolean isGuestUser = DH_SiteSearchOptions.isCurrentUserGuest();
        if (isGuestUser) {
			return DH_SiteSearchOptions.getVFOrigin().replace(DH_KMConstants.DDC, '').replace(DH_KMConstants.FORCECOM, DH_KMConstants.SITECOM);
        }
		return URL.getOrgDomainUrl().toExternalForm().split(DH_KMConstants.DOTMYDOT)[0]+DH_KMConstants.LIGHTNING_FORCECOM;
    }
}