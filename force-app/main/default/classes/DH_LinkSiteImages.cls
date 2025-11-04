/*

*********************************************************

Apex Class/LWC     : DH_LinkSiteImages

Created Date       : 19-07-2024

@description       : Get Content Version List. Modified for UCC as well.

@jiraid            : CC-949

*********************************************************

*/
public with sharing class DH_LinkSiteImages{
    
    /**
    * @description                             This method is used to get the file versions 
    * @param          recordId                 RecordId of the account record
    * @return         List<ContentVersion>     returns list of contentVersion attached to the account record with the given Id
    **/
    @AuraEnabled
    public static List<ContentVersion> getVersionFiles(String recordId){ 
       
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        
        try{
            contentVersionList=DH_KMQueryManager.getSiteImageVersionFiles(recordId);
        }catch(exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching file versions : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        
        return contentVersionList;            
    }

    
    /**
    * @description                  This method is used to get the lex origin of the org
    * @return         String        Returns the lex origin of org as a string
    **/
    @AuraEnabled
    public static String getLexOrigin(){
        Boolean isGuestUser = DH_SiteSearchOptions.isCurrentUserGuest();
        String lexOrigin = '';
        try{
            if (isGuestUser) {
                lexOrigin = DH_SiteSearchOptions.getVFOrigin().replace(DH_KMConstants.DDC, '').replace(DH_KMConstants.FORCECOM, DH_KMConstants.SITECOM);
            }
            else {
                lexOrigin= URL.getOrgDomainUrl().toExternalForm().split(DH_KMConstants.DOTMYDOT)[0]+DH_KMConstants.LIGHTNING_FORCECOM;
            }
        }catch(exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching the lex origin of the org : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return lexOrigin;
		
    }
}