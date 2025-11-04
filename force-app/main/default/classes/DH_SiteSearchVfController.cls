/*

 *********************************************************

Apex Class         : DH_SiteSearchVfController
    
Created Date       : May 15, 2024
    
@description       : Controller class for site search vfpage(dH_siteSearchVfpage) to send lexorigin and access token from metadata

@jiraid            : CC-233


 *********************************************************

 */
public class DH_SiteSearchVfController {
    
    // This variable holds the lexOrigin for the org
    
    public string lexOrigin {
        get{ //this is used to return type of user if user is guest user or not
            if (DH_KMUtility.getUserType()) {
                return DH_SiteSearchOptions.getVFOrigin().replace(DH_KMConstants.DDC, '').replace(DH_KMConstants.FORCECOM, DH_KMConstants.SITECOM);
            }
            return URL.getOrgDomainUrl().toExternalForm().split(DH_KMConstants.DOTMYDOT)[0] + DH_KMConstants.LIGHTNING_FORCECOM;
        }
    }
    
    public string functionNameDirection {
        get{ //this is used to return method to get direction on map
            return DH_KMConstants.SS_FUNCTION_NAME_DIRECTION;
        }
        set;
    }
    
    public string functionNameRemoveMarker {
        get{ //this is used to return method to remove markers on map
            return DH_KMConstants.SS_FUNCTION_NAME_REMOVE_MARKER;
        }
        set;
    }
    
    public string functionNameAddMarker {
        get{ //this is used to return method to add markers on the map
            return DH_KMConstants.SS_FUNCTION_NAME_ADD_MARKER;
        }
        set;
    }
    
    public string functionNameRemoveAllMarker {
        get{  //this is used to return method to remove markers as well as direction on the map
            return DH_KMConstants.SS_FUNCTION_NAME_REMOVE_ALL_MARKER;
        }
        set;
    }
    
    public string lightningAccountURL {
        get{   //this is used to return string to create account URL on popup
            return DH_KMConstants.SS_LIGHTNING_ACCOUNT_URL;
        }
        set;
    }
    
    public string popupContentName {
        get{ //this is used to return bold string on map popup tile
            return DH_KMConstants.SS_POPUPCONTENT_NAME;
        }
        set;
    }
    
    public string popupContentTarget {
        get{ //this is used to return popup content on hover on path
            return DH_KMConstants.SS_POPUPCONTENT_TARGET;
        }
        set;
    }
    
    public string popupContentAddress {
        get{  //this is used to return site address on popup content
            return DH_KMConstants.SS_POPUPCONTENT_ADDRESS;
        }
        set;
    }
    
    public string inputAddressValue {
        get{ //this is used to return input address value name
            return DH_KMConstants.SS_INPUTADDRESSVALUE;
        }
        set;
    }
    
    public string mapIdFirst {
        get{ //this is used to return map id inside map search address
            return DH_KMConstants.SS_MAPID_FIRST;
        }
        set;
    }
    
    public string mapIdSecond {
        get{ //this is used to return map id inside map search address
            return DH_KMConstants.SS_MAPID_SECOND;
        }
        set;
    }
    
    public string googleParameterName {
        get{ //this is used to return google link parameters
            return DH_KMConstants.SS_GOOGLE_PARAMETER_NAME;
        }
        set;
    }
    
    public string googleParameterDestination {
        get{ //this is used to return google link destinations parameter
            return DH_KMConstants.SS_GOOGLE_PARAMETER_DESTINATION;
        }
        set;
    }
    
    public string siteDotCom {
        get{  //this is used to create site.com link for UCC
            return DH_KMConstants.SS_SITE_DOT_COM;
        }
        set;
    }
    
    public string radnetCommPortalDetail {
        get{  //this is used to create site.com link for UCC
            return DH_KMConstants.SS_RADNETCOMMPORTAL_DETAIL;
        }
        set;
    }
    
    public string closeAnchorTag {
        get{  //this is used to create site.com link for UCC
            return DH_KMConstants.SS_CLOSE_ANCHOR_TAG;
        }
        set;
    }
    
    // variable used to get locationIq access token from metadata
    public string getApiKeyForHelper {
        get{
            try{
                Map<String, Map_Helper_Setting__mdt> settingsMap = Map_Helper_Setting__mdt.getAll();
                for (Map_Helper_Setting__mdt setting : settingsMap.values()) {
                    if (setting.Label == DH_KMConstants.HELPER_LOCATIONIQ) {
                        return setting.Token__c;
                    }
                }
            }
            catch(DmlException e){
                System.debug(LoggingLevel.ERROR, 'Error while fetching access token'+ e.getMessage()+' at line no: '+e.getLineNumber());
            }
            return '';
        }
        set;
    }
}