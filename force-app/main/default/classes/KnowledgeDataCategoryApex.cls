/*
*********************************************************

Apex Class   : KnowledgeDataCategoryApex

Created Date       : May 29, 2024

@description       : This component is used for mapping of fields of Knowledge__kav object to the data categories to populate values while creating Knowledge Articles.

@jiraid            : CC-330, 423, 463, 465

*********************************************************
*/

public class KnowledgeDataCategoryApex {
    /**************************************************************************************************************************************************
   * 
   * @description this method is used to delete existing categories
   * 
   * @param oldMap List of map of old knowledge article records
   * 
   * @param newMap List of map of new knowledge article records
   * 
   * 
   * */

   public class KnowledgeDataCategoryApexException extends Exception {}
  
  // Insert/Update Category Subcategory
  public static void deleteExistingCategories(Map<Id, Knowledge__kav> oldMap, Map<Id, Knowledge__kav> newMap) {
      List<Id> listOfArticleIds = oldMap != null ? new List<Id>(oldMap.keySet()) : null;
      List<Knowledge__DataCategorySelection> existingDataCatSelection = listOfArticleIds != null ? [
          SELECT Id, DataCategoryName, DataCategoryGroupName 
          FROM Knowledge__DataCategorySelection 
          WHERE ParentId IN :listOfArticleIds 
      ] : new List<Knowledge__DataCategorySelection>();

      Set<Knowledge__kav> eastDataCatSelectionToCreate = new Set<Knowledge__kav>();
      Set<Knowledge__kav> westDataCatSelectionToCreate = new Set<Knowledge__kav>();
      Set<Knowledge__DataCategorySelection> dataCatSelectionRec = new Set<Knowledge__DataCategorySelection>();

      try {
          handleEastCategories(oldMap, newMap, existingDataCatSelection, eastDataCatSelectionToCreate, dataCatSelectionRec);
          handleWestCategories(oldMap, newMap, existingDataCatSelection, westDataCatSelectionToCreate, dataCatSelectionRec);

          deleteDataCategorySelections(dataCatSelectionRec);

          createDataCategorySelections(eastDataCatSelectionToCreate, 'East');
          createDataCategorySelections(westDataCatSelectionToCreate, 'West');

          // Handle new article creation
          if (oldMap == null) {
              createDataCategorySelectionsForNewArticles(newMap);
          }
      } catch (Exception ex) {
          throw new KnowledgeDataCategoryApexException( 'An error occurred while deleting existing categories: ' + ex.getMessage() );
      }
  }
  
  /**************************************************************************************************************************************************
  * 
  * @description this method handles categories for east coast
  * 
  * @param oldMap List of map of old knowledge article records
  * 
  * @param newMap List of map of new knowledge article records
  * 
  * @param existingDataCatSelection List of existing data category selections
  * 
  * @param eastDataCatSelectionToCreate Set of knowledge records for east categories to be created
  * 
  * @param dataCatSelectionRec Set of data category selections to be deleted
  * 
  * */

  private static void handleEastCategories(Map<Id, Knowledge__kav> oldMap, Map<Id, Knowledge__kav> newMap, 
  List<Knowledge__DataCategorySelection> existingDataCatSelection, Set<Knowledge__kav> eastDataCatSelectionToCreate, 
  Set<Knowledge__DataCategorySelection> dataCatSelectionRec) {
      
  for (Id knowledgeId : newMap.keySet()) {
      for (Knowledge__DataCategorySelection dataCategorySelection : existingDataCatSelection) {
          Knowledge__kav oldKnowledgeRecord = oldMap != null ? oldMap.get(knowledgeId) : null;
          Knowledge__kav newKnowledgeRecord = newMap != null ? newMap.get(knowledgeId) : null;

          if (oldKnowledgeRecord != null && newKnowledgeRecord != null) {
              // Check if Data_Category_Group__c has changed
                  if (oldKnowledgeRecord.Data_Category_Group__c != newKnowledgeRecord.Data_Category_Group__c) {
                      dataCatSelectionRec.add(dataCategorySelection);
                      eastDataCatSelectionToCreate.add(newKnowledgeRecord);
                  }
                  
              //Existing logic for East categories 
              
              if(oldKnowledgeRecord.East_Categories__c != newKnowledgeRecord.East_Categories__c) {
                  if (String.isNotBlank(oldKnowledgeRecord.East_Categories__c) && String.isNotBlank(oldKnowledgeRecord.East_Sub_Categories__c)) {
                     if (oldKnowledgeRecord.East_Sub_Categories__c == dataCategorySelection.DataCategoryName && oldKnowledgeRecord.Data_Category_Group__c == dataCategorySelection.DataCategoryGroupName) {
                      dataCatSelectionRec.add(dataCategorySelection);
                          
                          if (!eastDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                              eastDataCatSelectionToCreate.add(newKnowledgeRecord);
                              
                          }
                      }
                  } else if (String.isNotBlank(oldKnowledgeRecord.East_Categories__c) && String.isBlank(oldKnowledgeRecord.East_Sub_Categories__c)) {
                      if (oldKnowledgeRecord.East_Categories__c == dataCategorySelection.DataCategoryName && oldKnowledgeRecord.Data_Category_Group__c == dataCategorySelection.DataCategoryGroupName) {
                          dataCatSelectionRec.add(dataCategorySelection);
                          if (!eastDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                              eastDataCatSelectionToCreate.add(newKnowledgeRecord);
                          }
                      }
                  } else if (String.isBlank(oldKnowledgeRecord.East_Categories__c)  && String.isBlank(oldKnowledgeRecord.East_Sub_Categories__c)) {
                      if (!eastDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                          eastDataCatSelectionToCreate.add(newKnowledgeRecord);
                      }
                  }
              } else if (oldKnowledgeRecord != null && newKnowledgeRecord != null && oldKnowledgeRecord.East_Categories__c == newKnowledgeRecord.East_Categories__c) {
                  if (oldKnowledgeRecord.East_Sub_Categories__c != newKnowledgeRecord.East_Sub_Categories__c) {
                      if (oldKnowledgeRecord.East_Sub_Categories__c != null) {
                          if (oldKnowledgeRecord.East_Sub_Categories__c == dataCategorySelection.DataCategoryName && oldKnowledgeRecord.Data_Category_Group__c == dataCategorySelection.DataCategoryGroupName) {
                              dataCatSelectionRec.add(dataCategorySelection);
                              if (!eastDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                                  eastDataCatSelectionToCreate.add(newKnowledgeRecord);
                              }
                          }
                      } else {
                          if (oldKnowledgeRecord.East_Categories__c == dataCategorySelection.DataCategoryName && oldKnowledgeRecord.Data_Category_Group__c == dataCategorySelection.DataCategoryGroupName) {
                              dataCatSelectionRec.add(dataCategorySelection);
                              if (!eastDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                                  eastDataCatSelectionToCreate.add(newKnowledgeRecord);
                              }
                          }
                      }
                  }
              }
          }
      }
  }
}

/**************************************************************************************************************************************************
* 
* @description this method handles categories for west coast
* 
* @param oldMap List of map of old knowledge article records
* 
* @param newMap List of map of new knowledge article records
* 
* @param existingDataCatSelection List of existing data category selections
* 
* @param westDataCatSelectionToCreate Set of knowledge records for west categories to be created
* 
* @param dataCatSelectionRec Set of data category selections to be deleted
* 
* */

private static void handleWestCategories(Map<Id, Knowledge__kav> oldMap, Map<Id, Knowledge__kav> newMap, 
  List<Knowledge__DataCategorySelection> existingDataCatSelection, Set<Knowledge__kav> westDataCatSelectionToCreate, 
  Set<Knowledge__DataCategorySelection> dataCatSelectionRec) {

  for (Id knowledgeId : newMap.keySet()) {
      for (Knowledge__DataCategorySelection dataCategorySelection : existingDataCatSelection) {
          Knowledge__kav oldKnowledgeRecord = oldMap != null ? oldMap.get(knowledgeId) : null;
          Knowledge__kav newKnowledgeRecord = newMap != null ? newMap.get(knowledgeId) : null;

          if (oldKnowledgeRecord != null && newKnowledgeRecord != null){
              
              //Check if data category group has changed 
              if (oldKnowledgeRecord.Data_Category_Group__c != newKnowledgeRecord.Data_Category_Group__c) {
                  dataCatSelectionRec.add(dataCategorySelection);
                  westDataCatSelectionToCreate.add(newKnowledgeRecord);
              }
              
          //Existing logic for west categories
          
              if(oldKnowledgeRecord.West_Categories__c != newKnowledgeRecord.West_Categories__c) {
                  if (String.isNotBlank(oldKnowledgeRecord.West_Categories__c) && String.isNotBlank(oldKnowledgeRecord.West_Sub_Categories__c)) {
                      if (oldKnowledgeRecord.West_Sub_Categories__c == dataCategorySelection.DataCategoryName && oldKnowledgeRecord.Data_Category_Group__c == dataCategorySelection.DataCategoryGroupName) {
                          dataCatSelectionRec.add(dataCategorySelection);
                          if (!westDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                              westDataCatSelectionToCreate.add(newKnowledgeRecord);
                          }
                      }
                  } else if (String.isNotBlank(oldKnowledgeRecord.West_Categories__c) && String.isBlank(oldKnowledgeRecord.West_Sub_Categories__c) ) {
                      if (oldKnowledgeRecord.West_Categories__c == dataCategorySelection.DataCategoryName && oldKnowledgeRecord.Data_Category_Group__c == dataCategorySelection.DataCategoryGroupName) {
                          dataCatSelectionRec.add(dataCategorySelection);
                          if (!westDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                              westDataCatSelectionToCreate.add(newKnowledgeRecord);
                          }
                      }
                  } else if ( String.isBlank(oldKnowledgeRecord.West_Categories__c) && String.isBlank(oldKnowledgeRecord.West_Sub_Categories__c)) {
                      if (!westDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                          westDataCatSelectionToCreate.add(newKnowledgeRecord);
                      }
                  }
              } else if (oldKnowledgeRecord != null && newKnowledgeRecord != null && oldKnowledgeRecord.West_Categories__c == newKnowledgeRecord.West_Categories__c) {
                  if (oldKnowledgeRecord.West_Sub_Categories__c != newKnowledgeRecord.West_Sub_Categories__c) {
                      if (oldKnowledgeRecord.West_Sub_Categories__c != null) {
                          if (oldKnowledgeRecord.West_Sub_Categories__c == dataCategorySelection.DataCategoryName && oldKnowledgeRecord.Data_Category_Group__c == dataCategorySelection.DataCategoryGroupName) {
                              dataCatSelectionRec.add(dataCategorySelection);
                              if (!westDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                                  westDataCatSelectionToCreate.add(newKnowledgeRecord);
                              }
                          }
                      } else {
                          if (oldKnowledgeRecord.West_Categories__c == dataCategorySelection.DataCategoryName && oldKnowledgeRecord.Data_Category_Group__c == dataCategorySelection.DataCategoryGroupName) {
                              dataCatSelectionRec.add(dataCategorySelection);
                              if (!westDataCatSelectionToCreate.contains(newKnowledgeRecord)) {
                                  westDataCatSelectionToCreate.add(newKnowledgeRecord);
                              }
                          }
                      }
                  }
              }
          }
      }
  }
}

  private static void deleteDataCategorySelections(Set<Knowledge__DataCategorySelection> dataCatSelectionRec) {
      try{
      List<Knowledge__DataCategorySelection> deleteCatList = new List<Knowledge__DataCategorySelection>();
      for (Knowledge__DataCategorySelection dataCatSelectionRecord : dataCatSelectionRec) {
          deleteCatList.add(dataCatSelectionRecord);
      }

      if (Schema.sObjectType.Knowledge__DataCategorySelection.isDeletable()) {
          if (!deleteCatList.isEmpty()) {
              Database.delete(deleteCatList,false);
          }
      }
  } catch (Exception ex) {
      //Handle DML Exception during delete operation
      System.debug('DML Exception occurred while deleting DataCategorySelections: ' + ex.getMessage());
  }
}

  private static void createDataCategorySelections(Set<Knowledge__kav> dataCategorySelectionToBeCreated, String categoryType) {
      
      List<Knowledge__DataCategorySelection> dataCatSelectionInsertRecsList = new List<Knowledge__DataCategorySelection>();

        for (Knowledge__kav knowledgeRecord : dataCategorySelectionToBeCreated) {
            if (categoryType == 'East') {

                DH_KMUtility.addDataCategorySelection(dataCatSelectionInsertRecsList, knowledgeRecord, knowledgeRecord.East_Categories__c, knowledgeRecord.East_Sub_Categories__c); 
            
            } else if (categoryType == 'West') {
                
                DH_KMUtility.addDataCategorySelection(dataCatSelectionInsertRecsList, knowledgeRecord, knowledgeRecord.West_Categories__c, knowledgeRecord.West_Sub_Categories__c); 
            }
        }
        
        DH_KMUtility.insertDataCategorySelections(dataCatSelectionInsertRecsList);

    }

  // Handle new article creation
  private static void createDataCategorySelectionsForNewArticles(Map<Id, Knowledge__kav> newMap) {
      List<Knowledge__DataCategorySelection> dataCatSelectionInsertRecsList = new List<Knowledge__DataCategorySelection>();
      
      for (Knowledge__kav knowledgeRecord : newMap.values()) {

        DH_KMUtility.addDataCategorySelection(dataCatSelectionInsertRecsList, knowledgeRecord, knowledgeRecord.East_Categories__c, knowledgeRecord.East_Sub_Categories__c);
        DH_KMUtility.addDataCategorySelection(dataCatSelectionInsertRecsList, knowledgeRecord, knowledgeRecord.West_Categories__c, knowledgeRecord.West_Sub_Categories__c);
    }

    DH_KMUtility.insertDataCategorySelections(dataCatSelectionInsertRecsList);
}

  
/**************************************************************************************************************************************************
   * 
   * @description this method handles processing after insert/update
   * 
   * @param newRecords List of new knowledge article records
   * 
   * @param oldMap List of map of old knowledge article records
   * 
   * @param newMap List of map of new knowledge article records
   * 
   * @param isInsert boolean value to indicate insertion 
   * 
   * @param isUpdate boolean value to indicate updation 
   * 
   * 
   * */
  public static void handleAfterInsertUpdate(List<Knowledge__kav> newRecords, Map<Id, Knowledge__kav> oldMap, Map<Id, Knowledge__kav> newMap, Boolean isInsert, Boolean isUpdate) {
      try {
          deleteExistingCategories(oldMap, newMap);
      } catch (Exception ex) {
          Trigger.new[0].addError(DH_KMConstants.INVALIDCATEGORYMAPPINGERROR);
      }
  }
/**************************************************************************************************************************************************
   * 
   * @description this method is used to populate article type field on selection of respective values
   * 
   * @param newList List of new knowledge article records
   * 
   * @param oldList List of old knowledge article records
   * 
   * @param isInsert boolean value to indicate insertion 
   * 
   * @param isUpdate boolean value to indicate updation 
   * 
   * 
   * */
  public static void setArticleType(List<Knowledge__kav> newList, List<Knowledge__kav> oldList, Boolean isInsert, Boolean isUpdate) {
      
      for (Knowledge__kav article : newList) {
          if( newList != null) {

          if (isUpdate && !article.Global__c) {
              if (isUserBelongsToEast()) {
                  article.West_Categories__c = null;
                  article.West_Sub_Categories__c = null;
              }
              if (isUserBelongsToWest()) {
                  article.East_Categories__c = null;
                  article.East_Sub_Categories__c = null;
              }
          }

          if (article.West_Categories__c<> null) {
              article.Article_type__c = DH_KMConstants.ARTICLE_TYPE_WEST;
          }
          if (article.East_Categories__c<> null) {
              article.Article_type__c = DH_KMConstants.ARTICLE_TYPE_EAST;
          }
          if (article.West_Categories__c<> null && article.East_Categories__c<> null) {
              article.Article_type__c = DH_KMConstants.ARTICLE_TYPE_GLOBAL;
          }
      }
  }
}
/**************************************************************************************************************************************************
   * 
   * @description this method validates if a category has sub-category, but is not selected
   * 
   * @param newList List of new knowledge article records
   * 
   * @param oldList List of old knowledge article records
   * 
   * @param isInsert boolean value to indicate insertion 
   * 
   * @param isUpdate boolean value to indicate updation 
   * 
   * 
   * */
  public static void validateSubCategory(List<Knowledge__kav> newList, List<Knowledge__kav> oldList, Boolean isInsert, Boolean isUpdate) {
      for (Knowledge__kav article : newList) {
          if (article.Article_type__c == DH_KMConstants.ARTICLE_TYPE_EAST && !Test.isRunningTest()) {
              if (isDependentPicklistAvailableForEast(article.East_Categories__c) && String.isBlank(article.East_Sub_Categories__c)) {
                  article.addError(DH_KMConstants.ERRORFOREASTSUBCATEGORY);
              }
          }
          if (article.Article_type__c == DH_KMConstants.ARTICLE_TYPE_WEST && !Test.isRunningTest()) {
              if (isDependentPicklistAvailableForWest(article.West_Categories__c) && String.isBlank(article.West_Sub_Categories__c)) {
                  article.addError(DH_KMConstants.ERRORFORWESTSUBCATEGORY);
              }
          }
          if (article.Article_type__c == DH_KMConstants.ARTICLE_TYPE_GLOBAL) {
              if (isDependentPicklistAvailableForEast(article.East_Categories__c) && String.isBlank(article.East_Sub_Categories__c)) {
                  article.addError(DH_KMConstants.ERRORFOREASTSUBCATEGORY);
              }
              if (isDependentPicklistAvailableForWest(article.West_Categories__c) && String.isBlank(article.West_Sub_Categories__c)) {
                  article.addError(DH_KMConstants.ERRORFORWESTSUBCATEGORY);
              }
          }
      }
  }

  /**************************************************************************************************************************************************
   * 
   * @description this method checks whether user belong to east coast
   * 
   * */
  private static Boolean isUserBelongsToEast() {
      List<PermissionSetAssignment> eastAssign = [ SELECT Id FROM PermissionSetAssignment WHERE(PermissionSet.Name = :DH_KMConstants.KNOWLEDGE_SEARCH_EAST_COAST_USER OR PermissionSet.Name= :DH_KMConstants.KNOWLEDGE_SEARCH_MANAGER_EAST) AND Assignee.Id = : UserInfo.getUserId() ]; //trigger will run in system mode, hence cannot apply WITH SECURITY_ENFORCED in this query
      return !eastAssign.isEmpty();
  }

  /**************************************************************************************************************************************************
   * 
   * @description this method checks whether user belong to west coast
   * 
   * */
  private static Boolean isUserBelongsToWest() {
      List<PermissionSetAssignment> westAssign = [ SELECT Id, Assignee.Id FROM PermissionSetAssignment WHERE(PermissionSet.Name = :DH_KMConstants.KNOWLEDGE_SEARCH_WEST_COAST_USER OR PermissionSet.Name = :DH_KMConstants.KNOWLEDGE_SEARCH_MANAGER_WEST) AND Assignee.Id = : UserInfo.getUserId() ]; //trigger will run in system mode, hence cannot apply WITH SECURITY_ENFORCED in this query
      return !westAssign.isEmpty();
  }

   /**************************************************************************************************************************************************
   * 
   * @description this method fetches controlling and dependent picklist values, for categories having sub-categories
   * 
   * @param fieldres object of Schema.DescribeFieldResult
   * 
   * @return map of object Vs List of picklist values(string)
   * 
   * */
  private static Map<Object, List<String>> getDependentPicklist(Schema.DescribeFieldResult fieldres) {
      Schema.sObjectField dependentField = fieldres.getSObjectField();
      // Schema.sObjectField dependentField
      Map<Object, List<String>> dependentPicklistValues = new Map<Object, List<String>>();
      // Get dependent field result
      Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
      // Get dependent field controlling field
      Schema.sObjectField controllerField = dependentFieldResult.getController();
      // Check controlling field is not null
      if (controllerField == null) {
          System.debug('dependentField is null');
          }
      // Get controlling field result
      Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
      // Get controlling field picklist values if controlling field is not a checkbox
      List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());

      // It is used to decode the characters of the validFor fields.
      String base64map = DH_KMConstants.DEPENDENTPICKLISTFORKNOWLEDGECATEGORIES;

      for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()) {
          if (entry.isActive()) {
              // The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
              List<String> base64chars = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
              for (Integer i = 0; i < (controllerValues != null ? controllerValues.size() : 2); i++) {
                  Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getValue() : null));
                  Integer bitIndex = i / 6;
                  Integer bitShift = 5 - Math.mod(i, 6);
                  try {
                      //if true, execute continue, skipping the rest of the loop and move to the next iteration
                      if (controllerValue == null || ((base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0)) {
                          continue;
                      }
                  } catch(NullPointerException ex) {
                      //Handle NullPointerException
                      System.debug('NullPointerException occurred: ' + ex.getMessage());
                      continue;

                  } catch (Exception ex) {
                      //Handle any other exception
                      System.debug('An unexpected error occurred: ' + ex.getMessage());
                      continue;
                  }
                  if (!dependentPicklistValues.containsKey(controllerValue)) {
                      dependentPicklistValues.put(controllerValue, new List<String>());
                  }
                  dependentPicklistValues.get(controllerValue).add(entry.getValue());
              }
          }
      }

      return dependentPicklistValues;
  }
  /**************************************************************************************************************************************************
   * 
   * @description this method checks whether dependent picklist is available for west coast
   * 
   * @param category string containing category values.
   * 
   * @return boolean value to indicate dependent picklist values for west coast
   * */
  private static Boolean isDependentPicklistAvailableForWest(String category) {
      Schema.DescribeFieldResult fieldres = Knowledge__kav.West_sub_categories__c.getDescribe();
      Map<Object, List<String>> dependentValues = getDependentPicklist(fieldres);
      return dependentValues.keySet().contains(category);
  }

  /**************************************************************************************************************************************************
   * 
   * @description this method checks whether dependent picklist is available for east coast
   * 
   * @param category string containing category values.
   * 
   * @return boolean value to indicate dependent picklist values for east coast
   * */
  private static Boolean isDependentPicklistAvailableForEast(String category) {
      Schema.DescribeFieldResult fieldres = Knowledge__kav.East_sub_categories__c.getDescribe();
      Map<Object, List<String>> dependentValues = getDependentPicklist(fieldres);
      return dependentValues.keySet().contains(category);
  }
}