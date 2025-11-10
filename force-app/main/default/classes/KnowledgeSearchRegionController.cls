/*
 * ***************************************************************************************************************************
 * Apex Class Name : KnowledgeSearchRegionController
 * Created Date : 27-october-2025
 * @description :
 * Modification Log :
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       --------------------------------------------------------------------------------------------------------------------------------------
 *  Live Chat               27-october-2025       Added searchArticles method
 * *************************************************************************************************************************************************************************************
 */
/**
 * KnowledgeSearchRegionController
 *
 * Description:
 * - Provides a cacheable Apex API to fetch Knowledge articles filtered by a business "region".
 * - Region is mapped to a Knowledge Article Record Type DeveloperName:
 *     East -> 'FAQ'
 *     West -> 'FAQ_Template_1'
 * - Applies the following data rules:
 *     - PublishStatus = 'Online'
 *     - IsLatestVersion = true
 *     - IsVisibleInPkb = true
 * - Applies an optional search filter across Title, Summary, and UrlName.
 * - Enforces field-level security by stripping inaccessible fields/records via Security.stripInaccessible.
 * - Results are ordered by LastPublishedDate DESC, then Id DESC, and limited by the provided page size.
 *
 * Usage:
 *   KnowledgeSearchRegionController.PageResult pr =
 *     KnowledgeSearchRegionController.searchArticles('East', 'mri', 10);
 *
 * Notes:
 * - If the mapped Record Type does not exist in the org, an empty result set is returned (no exceptions).
 * - The method is @AuraEnabled(cacheable=true) and is intended to be invoked from Lightning Web Components.
 */
public with sharing class KnowledgeSearchRegionController {
    
    /**
     * DTO representing a subset of Knowledge article fields returned to the client.
     * Fields:
     *  - id: Article Id
     *  - title: Article Title
     *  - urlName: SEO-friendly URL segment for building article links
     *  - language: Language of the article (e.g., en_US)
     *  - recordTypeId: Record Type Id associated with the article (derived from region mapping)
     *  - lastPublishedDate: Timestamp of the most recent publish action
     */
    public class ArticleDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String title;
        @AuraEnabled public String urlName;
        @AuraEnabled public String language;
        @AuraEnabled public String recordTypeId;
        @AuraEnabled public Datetime lastPublishedDate;
    }
    
    /**
     * Wrapper for the results returned by searchArticles.
     * - results: List of ArticleDTOs; never null. May be empty when no data matches filters
     *            or when the mapped Record Type does not exist.
     */
    public class PageResult {
        @AuraEnabled public List<ArticleDTO> results;
    }
    
    // Record Type Developer Names for Knowledge Articles by region mapping
    private static final String EAST_RT_DEV_NAME = 'East_Patient_Facing';
    private static final String WEST_RT_DEV_NAME = 'West_Patient_Facing';
    
    /**
     * Searches Knowledge articles by region mapping and optional search term.
     *
     * Parameters:
     *  - region: String business region selector. Supported values:
     *      'East' -> maps to RecordType DeveloperName 'FAQ'
     *      'West' -> maps to RecordType DeveloperName 'FAQ_Template_1'
     *      any other value defaults to 'East'
     *  - searchTerm: Optional text used to filter Title, Summary, or UrlName (LIKE '%term%').
     *                Null or blank will skip search filtering.
     *  - pageSize: Max number of results to return (LIMIT). Must be a positive integer.
     *
     * Behavior:
     *  - If the mapped RecordType DeveloperName cannot be resolved to an Id in the target org,
     *    returns an empty PageResult without throwing an exception.
     *  - Applies PublishStatus='Online', IsLatestVersion=true, and IsVisibleInPkb=true constraints.
     *  - Orders by LastPublishedDate DESC, then Id DESC.
     *  - Applies Security.stripInaccessible for read access before mapping to DTOs.
     *
     * Returns:
     *  - PageResult with a non-null List<ArticleDTO>. The list may be empty.
     */
    @AuraEnabled(cacheable=true)
    public static PageResult searchArticles(String region, String searchTerm, Integer pageSize) {
        // Determine RecordType DeveloperName based on region
        String rtDevName;
        if (region ==  DH_KMConstants.COAST_EAST) rtDevName = EAST_RT_DEV_NAME;
        else if (region == DH_KMConstants.COAST_WEST) rtDevName = WEST_RT_DEV_NAME;
        else rtDevName = EAST_RT_DEV_NAME;
        
        // Resolve RecordTypeId without SOQL
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName();
        Id rtId = rtMap.containsKey(rtDevName) ? rtMap.get(rtDevName).getRecordTypeId() : null;
        
        PageResult pr = new PageResult();
        pr.results = new List<ArticleDTO>();
        
        if (rtId == null) {
            return pr;
        }
        
        // WHERE
        List<String> whereParts = new List<String>();
        whereParts.add('PublishStatus = \'Online\'');
        whereParts.add('IsLatestVersion = true');
        whereParts.add('RecordTypeId = \'' + String.escapeSingleQuotes(String.valueOf(rtId)) + '\'');
        whereParts.add('IsVisibleInPkb = true');
        if (!String.isBlank(searchTerm)) {
            String pattern = '%' + String.valueOf(searchTerm).trim() + '%';
            String escPattern = String.escapeSingleQuotes(pattern);
            whereParts.add('(Title LIKE \'' + escPattern + '\' OR Summary  LIKE \'' + escPattern + '\' OR UrlName LIKE \'' + escPattern + '\')');
        }
        String whereClause = String.join(whereParts, ' AND ');
        
        String soql = 'SELECT Id, Title, UrlName, Language, RecordTypeId, LastPublishedDate ' +
            'FROM Knowledge__kav ' +
            'WHERE ' + whereClause +
            ' ORDER BY LastPublishedDate DESC, Id DESC ' +
            'LIMIT :pageSize';
        
        List<Knowledge__kav> rows = Database.query(soql);
        SObjectAccessDecision dec = Security.stripInaccessible(AccessType.Readable, rows);
        List<Knowledge__kav> accessible = (List<Knowledge__kav>) dec.getRecords();
        
        for (Knowledge__kav k : accessible) {
            ArticleDTO dto = new ArticleDTO();
            dto.id = k.Id;
            dto.title = k.Title;
            dto.urlName = k.UrlName;
            dto.language = k.Language;
            dto.recordTypeId = k.RecordTypeId;
            dto.lastPublishedDate = k.LastPublishedDate;
            pr.results.add(dto);
        }
        return pr;
    }
}