/**
 * @File Name : DH_CustomPreChatFormController.cls
 * @Description : This controller supports the Pre-Chat form for Live Chat (MIAW).
 * @Author : Punith N S
 * @Last Modified By :
 * @Last Modified On : October 5, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | October 5, 2025 |   | Initial Version
 **/

/*
 * ***************************************************************************************************************************
 * Jira#                    Date                 Description
 * ----------------         --------------       ------------------------------
 *
 * ***********************************************************************************************************************************************
 */

public class DH_CustomPreChatFormController {
    
    // Public constant to avoid hardcoding the Business Hours name in code
    public static final String EAST_COAST_BH_NAME = 'East Coast (Eastern Standard Time)';
    
    @AuraEnabled(cacheable=true)
    public static Boolean isBusinessHoursOpen() {
        // Default to true if anything goes wrong to avoid blocking chat
        Boolean isOpen = true;
        try {
            // Prefer provided name, fallback to constant if blank
            String bhName = EAST_COAST_BH_NAME;
            BusinessHours bh = [
                SELECT Id, Name
                FROM BusinessHours
                WHERE IsActive = true AND Name = :bhName
                LIMIT 1
            ];
            if (bh != null) {
                /*
                Use the org-defined Business Hours directly. The BusinessHours engine evaluates
                    the provided instant against the Business Hours definition's time zone and daily
                    schedule. Passing Datetime.now() (equivalent to System.now()) is correct; it is
                    converted internally to the BH time zone before evaluation. This ensures users'
                    local machine time is not considered.
                     */
                isOpen = BusinessHours.isWithin(bh.Id, Datetime.now());
            }
        } catch (QueryException qe) {
            // No BH found with given name; keep default true
            isOpen = true;
        } catch (Exception e) {
            isOpen = true;
        }
        return isOpen;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<DH_Pre_Chat_Config__mdt> getMetadataForSite(String siteUrl) {
        String baseDomain = extractDomain(siteUrl);
        
        return [
        SELECT Field_Name__c, Picklist_Values__c
        FROM DH_Pre_Chat_Config__mdt
        WHERE Site_URL__c = :baseDomain
    ];
    }
    
    
    private static String extractDomain(String url) {
        try {
            if (String.isBlank(url)) return '';
            
            url = url.toLowerCase();
            
            // Remove protocol
            if (url.startsWith('http://')) url = url.substring(7);
            else if (url.startsWith('https://')) url = url.substring(8);
            
            // Remove path and query params
            Integer slashIndex = url.indexOf('/');
            if (slashIndex > 0) url = url.substring(0, slashIndex);
            
            // Remove port if present
            Integer colonIndex = url.indexOf(':');
            if (colonIndex > 0) url = url.substring(0, colonIndex);
            
            return url;
        } catch (Exception e) {
            return url;
        }
    }
    
}