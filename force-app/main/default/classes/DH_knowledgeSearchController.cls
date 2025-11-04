/******************************************************************************************************************************************************
 * 
 * @Created Date    : 17/05/2024
 * 
 * @description     : This class serves to obtain the Data Categories and Subcategories and FAQ Article mapped to them for Knowledge Article LWC component
 * 
 * @Jira Id         : CC-328 , CC-330, CC-964
 *  
 * */
public with sharing class DH_knowledgeSearchController {
    
    /**************************************************************************************************************************************************
     * 
     * @description : This method is used to get the DH_knowledgeSearchControllerWrapper containing Map of Data category group name vs Data category names, Map Category Vs Subcategory, Map of Category Label Vs API name, Map of Subcategory Label Vs API name,  Lists of coasts for the logged in User
     * 
     * @param       searchKnowledgeDataCategorySelection        List of Knowledge__DataCategorySelection fetched from DH_knowledgeSearchFuncController class     
     * @param       isSearchFunction                            Boolean value TRUE if method called from DH_knowledgeSearchFuncController class
     * @return      DH_knowledgeSearchControllerWrapper         DH_knowledgeSearchController Wrapper of dataCatGuserCoastLabelListroupNameVsDataCatNameMap,categVsSubCateg,subCategLabelVsNamesMap,categLabelVsNamesMap, usrCoastLabelsList   
     * 
     * */  
    @AuraEnabled(cacheable = true)
    public static DH_knowledgeSearchController.DH_knowledgeSearchControllerWrapper getCategoryList(List<Knowledge__DataCategorySelection> searchKnowledgeDataCategorySelection,Boolean isSearchFunction, String selectedCoast){
       	
        // STRING VS SET MAPS
        Map<String, Set<String>> subCategLabelVsNamesSet = new  Map<String, Set<String>>();
        Map<String, Set<String>> categLabelVsNamesSet = new  Map<String, Set<String>>();
        Map<String, Set<String>> categVsSubCategs = new Map<String, Set<String>>();
        Map<String, Set<String>> dataCategGroupNameVsCategNameSet = new Map<String, Set<String>>();
        Set<String> usrCoastLabelSet = new Set<String>();

        // STRING VS LIST WRAPPER MAPS
        Map<String, List<String>> dataCategGroupNameVsCategNames = new Map<String, List<String>>();
        Map<String, List<String>> categVsSubCateg = new Map<String, List<String>>();
        Map<String, List<String>> subCategLabelVsNamesMap = new Map<String, List<String>>();
        Map<String, List<String>> categLabelVsNamesMap = new Map<String, List<String>>();
        List<String> usrCoastLabelsList = new List<String>();

        try{
            Boolean isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false; 
            List<Knowledge__DataCategorySelection> knowlgDataCategSelections = new List<Knowledge__DataCategorySelection>();

            knowlgDataCategSelections = DH_knowledgeSearchController.getKnowledgeDataCategorySelection(searchKnowledgeDataCategorySelection,isSearchFunction);
            
            if(selectedCoast.contains('East')){
                selectedCoast = 'East';
            }else{ 
                selectedCoast = 'West';
            }
            
            Set<String> dataCategoryGroupName = new Set<String>();

            // GET MAP OF DATACATEGORY GROUPNAME VS DATACATEGORY SET
            for(Knowledge__DataCategorySelection knowlgDataCategSel : knowlgDataCategSelections){
                if(dataCategGroupNameVsCategNameSet.containsKey(knowlgDataCategSel.DataCategoryGroupName)){               
                    Set<String> dataCategoryNameSet = dataCategGroupNameVsCategNameSet.get(knowlgDataCategSel.DataCategoryGroupName);
                    dataCategoryNameSet.add(knowlgDataCategSel.DataCategoryName);
                    dataCategGroupNameVsCategNameSet.put(knowlgDataCategSel.DataCategoryGroupName,dataCategoryNameSet);
                }
                else{
                    dataCategGroupNameVsCategNameSet.put(knowlgDataCategSel.DataCategoryGroupName,new Set<String>{knowlgDataCategSel.DataCategoryName}); 
                }
            
                dataCategoryGroupName.add(knowlgDataCategSel.DataCategoryGroupName);
            }

            for(String grpName: dataCategoryGroupName ){            
                List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
                List <Schema.DescribeDataCategoryGroupStructureResult> results = new List <Schema.DescribeDataCategoryGroupStructureResult>();
                DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
                pair.setSobject(DH_KMConstants.OBJECT_NAME_KNOWLEDGE_ARTICLE_VERSION);
                pair.setDataCategoryGroupName(grpName);  
                pairs.add(pair);

                results = Schema.describeDataCategoryGroupStructures(pairs, false);
                List<Schema.DataCategory> childCategoriesTemp = new List<Schema.DataCategory>();
                List<Schema.DataCategory> childCategories = new List<Schema.DataCategory>();
                
                if(results[0].getTopCategories()[0].getLabel() == 'All'){
                    childCategoriesTemp = results[0].getTopCategories()[0].getChildCategories();  
                }
                else{
                    childCategoriesTemp = results[0].getTopCategories();   
                }
                // USER COAST CHECK FOR GUEST USER    
                if(isGuestUser){
                    for(Integer i = childCategoriesTemp.size()-1; i>=0; i--){
                        if(childCategoriesTemp[i].getName() == selectedCoast){
                            childCategories.add(childCategoriesTemp[i]); 
                        }
                    }
                }else{
                    childCategories.addAll(childCategoriesTemp);
                }
                
                for(Schema.DataCategory child: childCategories){

                    // SET OF COAST ASSIGNED TO USER
                    usrCoastLabelSet.add(child.getLabel());
                    
                    for(Schema.DataCategory subChild : child.getChildCategories() ){
                        Set<String> childSubChildSet = new Set<String>();
                        
                        // CHECK IF SUBCATERGORY IS PRESENT
                        if(subChild.getChildCategories() != null){                       
                            for(Schema.DataCategory childSubChild: subChild.getChildCategories()){
                                childSubChildSet.add(childSubChild.getLabel());
        
                                // POPULATE SUBCATEGORY LABEL VS SET OF API NAMES MAP 
                                if(subCategLabelVsNamesSet.containsKey(childSubChild.getLabel())){
                                    Set<String> subCatLabelVsNameSet = subCategLabelVsNamesSet.get(childSubChild.getLabel());
                                    subCatLabelVsNameSet.add(childSubChild.getName());
                                    subCategLabelVsNamesSet.put(childSubChild.getLabel(),subCatLabelVsNameSet);
                                }else{
                                    subCategLabelVsNamesSet.put(childSubChild.getLabel(),new Set<String>{childSubChild.getName()});    
                                }
                            }
                        }
                        // POPULATE CATEGORY VS SUBCATEGORY LABEL MAP
                        if(categVsSubCategs.containsKey(subChild.getLabel())){
                            Set<String> addChildSubChildSet = categVsSubCategs.get(subChild.getLabel());
                            addChildSubChildSet.addAll(childSubChildSet);
                            categVsSubCategs.put(subChild.getLabel(),addChildSubChildSet);
                        }
                        else{
                            categVsSubCategs.put(subChild.getLabel(),childSubChildSet);
                        }
                        // POPULATE CATEGORY LABEL VS SET OF API NAMES MAP
                        if(categLabelVsNamesSet.containsKey(subChild.getLabel())){
                            Set<String> subcategVsNameSet = categLabelVsNamesSet.get(subChild.getLabel());
                            subcategVsNameSet.add(subChild.getName());
                            categLabelVsNamesSet.put(subChild.getLabel(),subcategVsNameSet);
                        }else{
                            categLabelVsNamesSet.put(subChild.getLabel(),new Set<String>{subChild.getName()});    
                        }
                    }
                    
                }
                
                usrCoastLabelsList = new List<String>(usrCoastLabelSet);    
            }
            // POPULATE FINAL MAPS 
            for(String categ :categVsSubCategs.keySet()){
                categVsSubCateg.put(categ,new List<String>(categVsSubCategs.get(categ)));            
            }
            for(String subCategLabel :subCategLabelVsNamesSet.keySet()){
                subCategLabelVsNamesMap.put(subCategLabel,new List<String>(subCategLabelVsNamesSet.get(subCategLabel)));            
            }
            for(String categLabel :categLabelVsNamesSet.keySet()){
                categLabelVsNamesMap.put(categLabel,new List<String>(categLabelVsNamesSet.get(categLabel)));            
            }
            for(String dataCategGroup :dataCategGroupNameVsCategNameSet.keySet()){
                dataCategGroupNameVsCategNames.put(dataCategGroup,new List<String>(dataCategGroupNameVsCategNameSet.get(dataCategGroup)));            
            }
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error while fetching DH_knowledgeSearchControllerWrapper: ' +e.getMessage()+ ' at line no: '+e.getLineNumber());        
        }
        return new DH_knowledgeSearchController.DH_knowledgeSearchControllerWrapper(dataCategGroupNameVsCategNames,categVsSubCateg,subCategLabelVsNamesMap,categLabelVsNamesMap, usrCoastLabelsList);    
    }

    
    /**************************************************************************************************************************************************
     * 
     * @description : This method is used to get the ArticleListWrapper containing Knowledge Article records based on selected Category or Subcategory 
     * 
     * @param       selectedSubCtg              String Selected Category or Subcategory value fetched from from Knowledge Article component
     * @param       categLableVsApiNames        Map of Category Label Vs ApiName
     * @param       subcategLableVsApiNames     Map of Subcategory Label Vs ApiName
     * @param       groupVsCategNames           Map of Data category Group Vs Category & Subcategory Name 
     * @param       coastLabels                 List of Coast Labels assigned to user     
     *           
     * @return      articleWrapperList          List of ArticleListWrapper containing Knowledge Article records    
     * 
     * */  
    @AuraEnabled(cacheable = true)
    public static List<ArticleListWrapper> getArticleList(String selectedSubCtg, Map<String, List<String>> categLableVsApiNames, Map<String, List<String>> subcategLableVsApiNames,Map<String, List<String>> groupVsCategNames, List<String> coastLabels ){
        
        List<ArticleListWrapper> articleWrapperList = new List<ArticleListWrapper>();
        try{
            List<Knowledge__DataCategorySelection> knowlgDataCategSelections = DH_knowledgeSearchController.getKnowledgeDataCategorySelection(null,false);
            List<String> categNames = new List<String>();
                   
            if(categLableVsApiNames != null && categLableVsApiNames.containsKey(selectedSubCtg) ){
                categNames  = categLableVsApiNames.get(selectedSubCtg);
            }
            else if(subcategLableVsApiNames != null && subcategLableVsApiNames.containsKey(selectedSubCtg)){
                categNames = subcategLableVsApiNames.get(selectedSubCtg);
            }
        
            // GET FILTERED MAP OF GROUP VS CATEGORIES NAME 
            Map<String, List<String>> filterdGroupVsCatgMap = new Map<String,List<String>>();
            filterdGroupVsCatgMap = DH_knowledgeSearchController.filterGroupNameVsCategoriesMap(groupVsCategNames, categNames);

            // GET ARTICLE IDS FOR ARTICLE 
            List<Id> articleIds= new List<Id>(); 
            articleIds = DH_knowledgeSearchController.getKnowledgeArticleIds(filterdGroupVsCatgMap, knowlgDataCategSelections);

            // CALL KNOWLEDGE ARTICLE QUERY
            List<Knowledge__kav> articleList= new List<Knowledge__kav>(); 
            articleList = DH_KMQueryManager.getKnowledgeArticles(articleIds);
            
            // GET FILTERED ARTICLES SET
            Set<Knowledge__kav> articleSet = new Set<Knowledge__kav>();
            articleSet = DH_knowledgeSearchController.getFilteredArticleSet(articleList);  
            
            // SORT LIST BY INDEX
            List<Knowledge__kav> articleResults = new List<Knowledge__kav>(articleSet);
            SortArticlesByIndexClass sortByIndex = new SortArticlesByIndexClass(coastLabels);
            articleResults.sort(sortByIndex);
            
            // POPULATE ARTICLE WRAPPER
            for(Knowledge__kav ka : articleResults){
                ArticleListWrapper wrapperObj = new ArticleListWrapper();
                wrapperObj.id = Id.valueOf(ka.Id);
                wrapperObj.title = ka.Title;
                wrapperObj.articleDescription = ka.Article_Description__c != null ? ka.Article_Description__c : '';
                wrapperObj.details = ka.Details__c != null ? ka.Details__c : '';
                wrapperObj.trimmedDetails = ka.Details__c != null ? ka.Details__c?.stripHtmlTags().mid(0, 250) : '';
                wrapperObj.eastIndex = ka.Knowledge_Indexing__r != null && ka.Knowledge_Indexing__r.size() > 0 ? Integer.valueOf(ka.Knowledge_Indexing__r[0].Index__c) : 100;
                wrapperObj.westIndex = ka.Knowledge_Indexing__r != null && ka.Knowledge_Indexing__r.size() > 0 ? Integer.valueOf(ka.Knowledge_Indexing__r[0].west_Index__c) : 100;

                articleWrapperList.add(wrapperObj);
            }
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching KnowledgeArticleWrapper List: ' + e.getMessage()+ ' at line no: '+e.getLineNumber());        
        }    
        return articleWrapperList;

    } 

    /**************************************************************************************************************************************************
     * 
     * @description : This method is used to check selected category name in map of Datacategory Groupname vs Datacategories Name and return filterdGroupVsCatgMap 
     * 
     * @param       groupVsCategNames                   Map of Datacategory Groupname Vs Datacategories Name 
     * @param       categNames                          List of Knowledge__DataCategorySelection records 
     * @return      filteredGroupNameVsCategories       Map of filtered Datacategory Groupname vs Datacategories Name
     * 
     * */
    public static Map<String, List<String>> filterGroupNameVsCategoriesMap(Map<String, List<String>> groupVsCategNames, List<String> categNames){

        Map<String, List<String>> filteredGroupNameVsCategories = new Map<String,List<String>>();
        try{
            // CHECK SELECTED CATEGORY NAME IN MAP OF GROUP VS CATEGORY NAME AND POPULATE FILTERDGROUPVSCATGMAP
            for(String categName : categNames){
                for(String grpName : groupVsCategNames.keySet()){
                    List<String> grpCategories = groupVsCategNames.get(grpName);
                    for(String grpCategName : grpCategories){
                        if(grpCategName == categName){
                            if(filteredGroupNameVsCategories.containsKey(grpName)){
                                List<String> categories = filteredGroupNameVsCategories.get(grpName);
                                categories.add(categName);
                                filteredGroupNameVsCategories.put(grpName,categories);  
                            }
                            else{
                                List<String> categories = new List<String>();
                                categories.add(categName);
                                filteredGroupNameVsCategories.put(grpName,categories);  
                            }
                        }
                    }
                }
            }

        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching filtered GroupNameVsCategoriesMap: ' + e.getMessage()+ ' at line no: '+e.getLineNumber());        
        }
        return filteredGroupNameVsCategories;
    }

    /**************************************************************************************************************************************************
     * 
     * @description : This method is used to fetch List of Article Ids based on Knowledge__DataCategorySelection records and filterd GroupVsCategory Map
     * 
     * @param       filterdGroupVsCatgMap               Map of filtered Data Category Group Vs Data Categories 
     * @param       knowlgDataCategSelections           List of Knowledge__DataCategorySelection records 
     * @return      articleIds                          List of Ids of Knowledge Articles   
     * 
     * */
    public static List<Id> getKnowledgeArticleIds(Map<String, List<String>> filterdGroupVsCatgMap, List<Knowledge__DataCategorySelection> knowlgDataCategSelections){
        List<Id> articleIds = new List<Id>();
        try{
            // GET ARTICLE IDS FOR ARTICLE QUERY
            for(String grpNameMatch : filterdGroupVsCatgMap.keySet()){
                List<String> dataCategNameList = filterdGroupVsCatgMap.get(grpNameMatch);
                for(String dataCategMatch :dataCategNameList){
                    for(Knowledge__DataCategorySelection knowlgDataCategSel : knowlgDataCategSelections){
                        if(knowlgDataCategSel.DataCategoryGroupName == grpNameMatch &&  knowlgDataCategSel.DataCategoryName == dataCategMatch){
                            articleIds.add(knowlgDataCategSel.parentId);
                        }
                    }
                }
            }

        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching KnowledgeArticleIds: ' + e.getMessage()+ ' at line no: '+e.getLineNumber());        
        }
        return articleIds;
    }

    /**************************************************************************************************************************************************
     * 
     * @description : This method is used to check if articlelist ids present in articleids, remove duplicate articles and assgin to set 
     * 
     * @param       articleList         List of Knowledge__kav records from query
     * @return      articleSet          Set of Knowledge__kav records   
     * 
     * */  
    public static Set<Knowledge__kav> getFilteredArticleSet(List<Knowledge__kav> articleList){
        Set<Knowledge__kav> articleSet = new Set<Knowledge__kav>();
        try{
                // CHECK IF ARTICLELIST IDS PRESENT IN ARTICLEIDS, REMOVE DUPLICATE ARTICLES AND ASSGIN TO SET
                for(Knowledge__kav knowlgArticle : articleList){
                    if(!articleSet.isEmpty()){
                        Boolean isArticlePresentInSet = false;
                        for(Knowledge__kav knowlgSetArticle :articleSet){
                            if(knowlgArticle.Id == knowlgSetArticle.Id){
                                isArticlePresentInSet = true;
                                break;
                            }
                        }
                        if(!isArticlePresentInSet){
                            articleSet.add(knowlgArticle);
                        }
                    }else{
                        articleSet = new Set<Knowledge__kav>();
                        articleSet.add(knowlgArticle);
                    }
                }
        }catch(Exception e) {
                System.debug(LoggingLevel.ERROR,'Error while fetching filtered ArticlesList: ' + e.getMessage()+ ' at line no: '+e.getLineNumber());        
        }
        return articleSet;
    }


    /**************************************************************************************************************************************************
     * 
     * @description : This method is used to get the Knowledge__DataCategorySelection records 
     * 
     * @param       searchKnowledgeDataCategorySelection    List of Knowledge__DataCategorySelection when method called from DH_knowledgeSearchFuncController class
     * @param       isSearchFunction                        Boolean value TRUE if method called from DH_knowledgeSearchFuncController class
     * @return      knowlgDataCategSelections               List of Knowledge__DataCategorySelection records    
     * 
     * */  
    @AuraEnabled(cacheable = true)
    public static List<Knowledge__DataCategorySelection> getKnowledgeDataCategorySelection(List<Knowledge__DataCategorySelection> searchKnowledgeDataCategorySelection,Boolean isSearchFunction){
       List<Knowledge__DataCategorySelection> knowlgDataCategSelections = new List<Knowledge__DataCategorySelection>();
        
       try{
            if(!isSearchFunction){
                knowlgDataCategSelections = DH_KMQueryManager.queryKnowledgeDataCategorySelection();
            }
            else{
                knowlgDataCategSelections = searchKnowledgeDataCategorySelection; 
            }
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching Knowledge DataCategorySelection List: ' + e.getMessage()+ ' at line no: '+e.getLineNumber());        
        }
        return knowlgDataCategSelections;
    }  

    /**************************************************************************************************************************************************
     * 
     * @description : DH_knowledgeSearchControllerWrapper class containing its lists, maps and wrapper constructor
     *  
     * */ 
    public class DH_knowledgeSearchControllerWrapper{
        @AuraEnabled public List<String> usrCoastLabels ; 
        @AuraEnabled public Map<String, List<String>> categVsSubcategMap ;
       	@AuraEnabled public Map<String, List<String>> subcategLabelVsNames ;
       	@AuraEnabled public Map<String, List<String>> categLabelVsNames ;
        @AuraEnabled public Map<String, List<String>> dataCategGrpNameVsDataCategNames;

        /**************************************************************************************************************************************************
        * 
        * @description  : DH_knowledgeSearchControllerWrapper class constructor 
        *  
        * @param dataCategGrpNameVsDataCategNames       Map of data category group name Vs data category name
        * @param categVsSubcategMap                     Map of category vs subcategory 
        * @param subcategLabelVsNames                   Map of sub category label vs api name
        * @param categLabelVsNames                      Map of category label vs api name
        * @param usrCoastLabels                         List of user coasts labels
        *
        * */
        public DH_knowledgeSearchControllerWrapper(Map<String, List<String>>  dataCategGrpNameVsDataCategNames, Map<String, List<String>> categVsSubcategMap,Map<String, List<String>> subcategLabelVsNames, Map<String, List<String>> categLabelVsNames, List<String> usrCoastLabels){
            this.dataCategGrpNameVsDataCategNames = dataCategGrpNameVsDataCategNames;
            this.categVsSubcategMap = categVsSubcategMap;
            this.subcategLabelVsNames = subcategLabelVsNames;
            this.categLabelVsNames = categLabelVsNames;
            this.usrCoastLabels = usrCoastLabels;
        }
    }
    
    /**************************************************************************************************************************************************
     * 
     * @description : ArticleListWrapper class containing Knowledge Article and Knowledge Indexing fields
     *  
     * */ 
    public class ArticleListWrapper{
        @AuraEnabled public String id ;
        @AuraEnabled public String title ;
        @AuraEnabled public String articleDescription ;
        @AuraEnabled public String details;
        @AuraEnabled public String trimmedDetails;
        @AuraEnabled public Integer eastIndex;
        @AuraEnabled public Integer westIndex;
    }

    /**************************************************************************************************************************************************
     * 
     * @description : SortArticlesByIndexClass class implements Comparator interface 
     *  
     * */
    public class SortArticlesByIndexClass implements Comparator <Knowledge__kav>{
        List<String> coastLabelsList = new List<String>();

        /**************************************************************************************************************************************************
         * 
         * @description : SortArticlesByIndexClass constructor 
         *  
         * @param       coastsList      list of coasts assigned to user
         * 
         * */
        public SortArticlesByIndexClass(List<String> coastsList){
            coastLabelsList = coastsList;
        }

        /**************************************************************************************************************************************************
         * 
         * @description : This method compares two Knowledge Article object records based on the Index East or Index West field  
         * 
         * @param       e1      Knowledge Article object record
         * @param       e2      Knowledge Article object record 
         * @return      result  Integer result with value 0, 1, -1 based on index field comparison 
         * 
         * */    
        public Integer compare(Knowledge__kav e1, Knowledge__kav e2) {
            Integer result;
            try{
                if(coastLabelsList[0] == DH_KMConstants.COAST_EAST)  {
                    if (e1?.Knowledge_Indexing__r.isEmpty() && e2?.Knowledge_Indexing__r.isEmpty()) {
                        result = 0;
                    } else if (e1?.Knowledge_Indexing__r.isEmpty()) {
                        result = 1;
                    } else if (e2?.Knowledge_Indexing__r.isEmpty()) {
                        result = -1;
                    } else if (e1.Knowledge_Indexing__r[0].index__c == e2.Knowledge_Indexing__r[0].index__c) {
                        result = 0;
                    } else if ((e1.Knowledge_Indexing__r[0].index__c < e2.Knowledge_Indexing__r[0].index__c)) {
                        result = -1;
                    } else if (e1.Knowledge_Indexing__r[0].index__c > e2.Knowledge_Indexing__r[0].index__c) {
                        result = 1;
                    } else {
                        result = 0;
                    }
                }
                if(coastLabelsList[0] == DH_KMConstants.COAST_WEST)  {
                    if (e1?.Knowledge_Indexing__r.isEmpty() && e2?.Knowledge_Indexing__r.isEmpty()) {
                        result = 0;
                    } else if (e1?.Knowledge_Indexing__r.isEmpty()) {
                        result = 1;
                    } else if (e2?.Knowledge_Indexing__r.isEmpty()) {
                        result = -1;
                    } else if (e1.Knowledge_Indexing__r[0].west_Index__c == e2.Knowledge_Indexing__r[0].west_Index__c) {
                        result = 0;
                    } else if ((e1.Knowledge_Indexing__r[0].west_Index__c < e2.Knowledge_Indexing__r[0].west_Index__c)) {
                        result = -1;
                    } else if (e1.Knowledge_Indexing__r[0].west_Index__c > e2.Knowledge_Indexing__r[0].west_Index__c) {
                        result = 1;
                    } else {
                        result = 0;
                    }
                }
            } catch(exception e) {
                System.debug(LoggingLevel.ERROR, 'Error in SortArticlesByIndexClass : ' + e.getMessage() + ' at line no: '+e.getLineNumber());
            }
            return result;
        }
    }
}