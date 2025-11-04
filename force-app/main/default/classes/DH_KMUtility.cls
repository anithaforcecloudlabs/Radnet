/*

 *********************************************************

Apex Class         : DH_KMUtility
  
Created Date       : June 15, 2024
  
@description       : Utility class for redundant methods

@jiraid            : CC-819, CC-231, CC-945, CC-946, CC-947, CC-949

 *********************************************************

 */
public with sharing class DH_KMUtility {
  
  public static List<String> virtualGroupingNJIN() {
    List<Practice__mdt> virtualPracticeGrouping = new  List<Practice__mdt>();
    List<String> subPractice = new List<String>();
    try {
      virtualPracticeGrouping = Practice__mdt.getAll().Values();
      if(virtualPracticeGrouping.size()>0){
        for (Practice__mdt practice : virtualPracticeGrouping)
        {
          if(practice.Practice__c == DH_KMConstants.NJIN_PRACTICE_CODE && practice.Sub_practice__c <> null){
            subPractice.add(practice.Sub_practice__c);
          }
          
        }
        
      }
    } catch (exception e) {
      System.debug(LoggingLevel.ERROR,'Error while fetching virtualGrouping : ' + e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return subPractice;
  }
  
  
  //for site search
  public static List<String> virtualGroupingNJINForSiteSearch() {
    List<Practice__mdt> virtualPracticeGrouping = new  List<Practice__mdt>();
    List<String> subPracticeFullName = new List<String>();
    try {
      virtualPracticeGrouping = Practice__mdt.getAll().Values();
      if(virtualPracticeGrouping.size()>0){
        for (Practice__mdt practice : virtualPracticeGrouping)
        {
          if(practice.Practice__c == DH_KMConstants.NJIN_PRACTICE_CODE && practice.Sub_practice__c <> null){
            subPracticeFullName.add(practice.Full_name_of_account__c);
          }
          
        }
        
      }
    } catch (exception e) {
      System.debug(LoggingLevel.ERROR,'Error while fetching virtualGrouping for DH_SiteSearchOptions : ' + e.getMessage());
    }
    return subPracticeFullName;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches values for Practice option
   *
   * @param region List of String containing region
   *
   * @return List of practices from custom metadata
   *
   * */
  @AuraEnabled(cacheable = true)
  public static List<Practice__mdt> getPractice(List<String> region) {
    List<Practice__mdt> practiceList = new List<Practice__mdt>();
    try {
      if (region.size() > 0) {
        practiceList = [ SELECT Practice__c, Sort_Order__c FROM Practice__mdt where Region__c IN : region WITH SECURITY_ENFORCED Order By Sort_Order__c ASC  ];
      }
    } catch (exception e) {
      System.debug(LoggingLevel.ERROR,'Error while fetching practices for Modality Search : ' + e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return practiceList;
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches values for Practice option for Modality Procedure Search result
   *
   * @return List of practices from custom metadata
   *
   * */
  @AuraEnabled(cacheable = true)
  public static List<Practice__mdt> getPracticeforModalitySearch() {
    List<Practice__mdt> practiceList = New List<Practice__mdt>();
    try {
      practiceList = [ SELECT Practice__c, Region__c, Sort_Order__c FROM Practice__mdt WHERE Sort_Order__c != null WITH SECURITY_ENFORCED Order By Sort_Order__c ASC ];
    } catch (exception e) {
      System.debug('Error in getting practice options : ' + e.getMessage());
    }
    return practiceList;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches values for region option
   *
   * @return List of region from custom metadata
   *
   * */
  @AuraEnabled(cacheable = true)
  public static List<String> getRegion() {
    List<String> regionNames = new List<String>();
    try {
      List<Region__mdt> regionList = new List<Region__mdt>();
      regionList = [ SELECT Region__c,Sort_Order__c from Region__mdt WITH SECURITY_ENFORCED Order By Sort_Order__c ASC];
      if(regionList.size()>0){
        for (Region__mdt r : regionList) {
          regionNames.add(r.Region__c);
        }
      }
    } catch (exception e) {
      System.debug(LoggingLevel.ERROR,'Error while fetching region for SpecialAcc_SpecialBillController : ' + e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return regionNames;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches values for Modality option for modality procedure
   *
   * @return List of modalities from custom metadata
   *
   * */
  
  
  @AuraEnabled(cacheable = true)
  public static List<Modality__mdt> getModalities(String region, String practice) {
    List<Modality__mdt> modalityList = New List<Modality__mdt>();
    try {
      modalityList =
        [ SELECT Modality__c, Sort_Order__c FROM Modality__mdt WHERE Sort_Order__c != null WITH SECURITY_ENFORCED Order By Sort_Order__c ];
      
    } catch (exception e) {
      System.debug('Error in getting modality options : ' + e.getMessage());
    }
    return modalityList;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches options of Modalities from custom metadata for site search
   *
   *
   * @return List of options for Modalities
   *
   * */
  
  public static List<Modality__mdt> getModalityRecords(List<String> regions, List<String> practices){
    List<Modality__mdt> modalityList = new List<Modality__mdt>();
    try{
      modalityList = [SELECT Modality__c, Sort_Order__c 
            FROM Modality__mdt 
            WHERE Sort_Order__c != null AND Modality__c != 'NP' 
            WITH SECURITY_ENFORCED 
            ORDER BY Modality__c ];
    }
    catch(Exception e) {
      System.debug('Error in getting modality records for site search: ' + e.getMessage());
    }
    return modalityList;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description method is used to fetch public groups from custom metadata based on the coast name
   *
   * @return List of public groups from custom metadata
   *
   * */
  
  private static List<String> getGroupNameFromMetadata( String coastName ) {
    List<Public_Groups__mdt> listOfGroups = [ SELECT Id, Public_Group_Name__c, Coast__c
                                                FROM Public_Groups__mdt 
                                                WHERE Coast__c = :coastName ];
    List<String> coastGroupsList = new List<String>();
    
    try{
      for ( Public_Groups__mdt publicgroup : listOfGroups ) {
        coastGroupsList.add( publicgroup.Public_Group_Name__c );
      }
    }
    catch (exception e) {
      System.debug(LoggingLevel.ERROR,'Error while fetching groups : ' + e.getMessage());
    }
    return coastGroupsList;
  }
  
  //Method to check if a user belongs to a specific coast
  
  public static Boolean isUserInCoast(Id userId, String coastName) {
    List<String> coastGroups = getGroupNameFromMetadata(coastName);
    List<GroupMember> groupMembers = new List<GroupMember>();
    
    if(GroupMember.SObjectType.getDescribe().isAccessible()){
      groupMembers = [SELECT Id, UserOrGroupId, Group.DeveloperName
                            FROM GroupMember 
                            WHERE Group.DeveloperName IN :coastGroups 
                            AND UserOrGroupId = :userId 
                            WITH SECURITY_ENFORCED];
    }
    return !groupMembers.isEmpty();
  }
  
  /**************************************************************************************************************************************************
   *
   * @description : Gets the list of DH_Data_Category_Icon_Name__mdt metadata records for Knowledge Articles component
   *
   * @return      categoryVsIconNameList      List of DH_Data_Category_Icon_Name__mdt metadata records containing fields Category_Icon_Name__c and Data_Category_Label__c
   *
   * */
  @AuraEnabled(cacheable = true)
  public static List<DH_Data_Category_Icon_Name__mdt> getCategoryVsIconNames() {
    List<DH_Data_Category_Icon_Name__mdt> categoryVsIconNameList = New List<DH_Data_Category_Icon_Name__mdt>();
    categoryVsIconNameList = [SELECT Category_Icon_Name__c, Data_Category_Label__c FROM DH_Data_Category_Icon_Name__mdt WITH SECURITY_ENFORCED];
    return categoryVsIconNameList;
  }
  
  
  // --- START --- Methods to fetch Category Subcategory CategoryGroup picklist values for Knowledge Article Test Classes
  
  /**************************************************************************************************************************************************
   *
   * @description : MyPickListInfo class used in getGlobalPickList method
   *
   * */
  public class MyPickListInfo {
    public String validFor;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description : This method is used to fetch category and subcategory picklist values from picklist field in knowledge article object
   *
   * @param        controllingF      String category picklist field name
   * @param        dependentF        String subcategory picklist field name
   * @return       controllingInfo   Map of Category Vs Subcategory picklist value API names from Knowledge Article Object
   *
   * */
  public static Map < String, List < String >> getGlobalPickList(String controllingF, String dependentF) {
    
    String controllingField = controllingF; // Define controlling picklist value field
    String dependentField = dependentF; // Define dependent picklist value field
    
    // Declare map variable to store list of dependent value for controlling field
    Map < String, List < String >> controllingInfo = new Map < String, List < String >> (); //Get the type being dealt with
    
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(DH_KMConstants.OBJECT_NAME_KNOWLEDGE_KAV);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe(); // Get controlling field values
    Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap()
      .get(controllingField)
      .getDescribe(); // Get dependent field values
    Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap()
      .get(dependentField)
      .getDescribe();
    List < Schema.PicklistEntry > controllingValues = controllingFieldInfo.getPicklistValues();
    
    List < Schema.PicklistEntry > dependentValues = dependentFieldInfo.getPicklistValues(); // Get the label for controlling picklist value set
    
    for (Schema.PicklistEntry currControllingValue: controllingValues) {
      controllingInfo.put(currControllingValue.getValue(), new List < String > ());
    }
    // Iterate through the dependent values
    for (Schema.PicklistEntry currDependentValue: dependentValues) {
      //get the validFor
      String jsonString = JSON.serialize(currDependentValue);
      MyPickListInfo info = (MyPickListInfo) JSON.deserialize(
        jsonString,
      MyPickListInfo.class
        );
      String hexString = EncodingUtil.convertToHex(
        EncodingUtil.base64Decode(info.validFor)
        )
        .toUpperCase();
      Integer baseCount = 0;
      for (Integer curr: hexString.getChars()) {
        Integer val = 0;
        if (curr >= 65) {
          val = curr - 65 + 10;
        } else {
          val = curr - 48;
        }
        if ((val & 8) == 8) {
          controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getValue());
        }
        if ((val & 4) == 4) {
          controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getValue());
        }
        if ((val & 2) == 2) {
          controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getValue());
        }
        if ((val & 1) == 1) {
          controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getValue());
        }
        baseCount += 4;
      }
    }
    return controllingInfo;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description  : This method is used to fetch label of picklist values from picklist field in knowledge article object
   *
   * @param        key         String category or subcategory picklist value API name
   * @param        fieldName   String category or subcategory picklist field API name
   * @return       fieldLabel  String category or subcategory picklist value Label
   *
   * */
  
  public static String getApiNameVsLabel(String key, String fieldName) {
    String fieldLabel;
    
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(DH_KMConstants.OBJECT_NAME_KNOWLEDGE_KAV);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe(); // Get controlling field values
    Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap()
      .get(fieldName)
      .getDescribe();
    
    List < Schema.PicklistEntry > values = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry v: values) {
      if (v.getValue() == key) {
        fieldLabel = v.getLabel();
      }
    }
    return fieldLabel;
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description  : This method is used to fetch Datacategory Group Name picklist value from Data_Category_Group__c picklist field in knowledge article object
   *
   * @param        fieldName       String Data_Category_Group__c picklist field name
   * @return       groupApiName    String DataCategoryGroup picklist value API Name
   *
   * */
  public static String getDataCategoryGroupApiName(String fieldName) {
    String groupApiName;
    
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(DH_KMConstants.OBJECT_NAME_KNOWLEDGE_KAV);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe(); // Get controlling field values
    Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap()
      .get(fieldName)
      .getDescribe();
    
    List< Schema.PicklistEntry > values = fieldResult.getPicklistValues();
    groupApiName = values[0].getValue();
    return groupApiName;
  }
  // --- END --- Methods to fetch Category Subcategory CategoryGroup picklist values for Knowledge Article Test Classes
  
  /**************************************************************************************************************************************************
   *
   * @description  : This method is used to fetch type of logged in user
   *
   * @param        N/A
   * @return       isGuestUser    Boolean if user is guest user or not
   *
   * */
  @AuraEnabled(cacheable=true)
  public static Boolean getUserType() {
    Boolean isGuestUser = false;
    try{
      isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false;
    } catch (exception e) {
      System.debug('Error  : ' + e.getMessage());
    }
    return isGuestUser;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description  : This method is used to fetch type of logged in user
   *
   * @param        Exception e, String msg
   * @return       NA
   *
   * */
  public static void getException(Exception e, String msg){
    System.debug(LoggingLevel.ERROR, msg +' : '+ e.getMessage()+' at line no: '+e.getLineNumber());
  }

   /**************************************************************************************************************************************************
   *
   * @description  : This method is used to get article type of selected coast
   *
   * @param        selectedCoast      coast selected by the guest user
   * @return       coastAdded         Article type list (East,West,Global)
   *
   * */
  public static List<String> coastType(String selectedCoast){
    List<String> coastAdded= new List<String>();
    
    if(selectedCoast.contains('East')){
      coastAdded.add('East');
      coastAdded.add('Global');
    }
    else if(selectedCoast.contains('West')){
      coastAdded.add('West');
      coastAdded.add('Global');
    }
    return coastAdded;
  }

  
    
  public static List<DH_specialAccomodationAndBillController.SpecialBillsWrapper> getHealthcarePayerNetworkRecords(Map<String,List<String>> specialBillsParam,List<sObject> healthcarePayerNetworkList){
    
    List<DH_specialAccomodationAndBillController.SpecialBillsWrapper> sbWrapperList = new List<DH_specialAccomodationAndBillController.SpecialBillsWrapper>();

    try{
      for(sObject s: healthcarePayerNetworkList){
        DH_specialAccomodationAndBillController.SpecialBillsWrapper specialBills= new DH_specialAccomodationAndBillController.SpecialBillsWrapper();
        specialBills.id = (String)s.get(specialBillsParam.get('id').get(0));
        specialBills.payerName = (String)s.getSObject(specialBillsParam.get('payerName').get(0)).get(specialBillsParam.get('payerName').get(1));
        specialBills.carrierCode = (String)s.getSObject(specialBillsParam.get('carrierCode').get(0)).get(specialBillsParam.get('carrierCode').get(1));
        specialBills.modalityDescription = (String)s.get(specialBillsParam.get('modalityDescription').get(0));
        specialBills.examCovered = (String)s.get(specialBillsParam.get('examCovered').get(0));
        specialBills.regionName = (String)s.getSObject(specialBillsParam.get('regionName').get(0)).get(specialBillsParam.get('regionName').get(1));
        specialBills.regionsRegion = (String)s.getSObject(specialBillsParam.get('regionsRegion').get(0)).get(specialBillsParam.get('regionsRegion').get(1));
        
        sbWrapperList.add(specialBills);
      }
    } 
    catch (exception e) {
      System.debug('Error  : ' + e.getMessage()+' at line no. '+e.getLineNumber());
    }
    return sbWrapperList;
  }

  /**************************************************************************************************************************************************
     *
     * @description this method fetches records for Procedure table
     *
     * @param Map of String,List of String containing procRecordsParam and List of sObject procRecords
     *
     * @return List of HealthcareProcedure Wrapper
     *
     * */

  public static List<DH_ModalityBasedPracticeController.HealthCareProcedureWrapper> getHealthcareProcRecords (Map<String,List<String>> procRecordsParam, List<sObject> procRecords) {

    List<DH_ModalityBasedPracticeController.HealthCareProcedureWrapper> hcpWrapperList = new List<DH_ModalityBasedPracticeController.HealthCareProcedureWrapper>();

    try{
      for(sObject s: procRecords) {
          
        DH_ModalityBasedPracticeController.HealthCareProcedureWrapper hcp = new DH_ModalityBasedPracticeController.HealthCareProcedureWrapper();
        hcp.id = (String)s.get(procRecordsParam.get('id').get(0));
        hcp.name = (String)s.get(procRecordsParam.get('name').get(0));
        hcp.procedureCode = (String)s.get(procRecordsParam.get('procedureCode').get(0));
        hcp.bodyParts = (String)s.get(procRecordsParam.get('bodyParts').get(0));
        hcp.reasonForExam = (String)s.get(procRecordsParam.get('reasonForExam').get(0));
        hcp.specialInstructions = (String)s.get(procRecordsParam.get('specialInstructions').get(0));
        hcp.practice = (String)s.getSObject(procRecordsParam.get('practice').get(0)).get(procRecordsParam.get('practice').get(1));
        hcp.modality = (String)s.getSObject(procRecordsParam.get('modality').get(0)).get(procRecordsParam.get('modality').get(1));
        
        hcpWrapperList.add(hcp);
      }
    } 
    catch (exception e) {
      System.debug('Error  : ' + e.getMessage()+' at line no. '+e.getLineNumber());
    }
    return hcpWrapperList;
  }

  /**************************************************************************************************************************************************
     *
     * @description this method fetches records for Special Instructions table
     *
     * @param Map of String,List of String containing specInsParam and List of sObject instruct
     *
     * @return List of specialInstructionsWrapper
     *
     * */


  public static List<DH_ModalityBasedPracticeController.specialInstructionsWrapper> getSpecialInstructions (Map<String,List<String>> specInsParam, List<sObject> instruct ) { 

    List<DH_ModalityBasedPracticeController.specialInstructionsWrapper> siWrapperList = new List<DH_ModalityBasedPracticeController.specialInstructionsWrapper>();

    try{
      for(sObject s: instruct) {
        DH_ModalityBasedPracticeController.specialInstructionsWrapper si = new DH_ModalityBasedPracticeController.specialInstructionsWrapper();
        si.id = (String)s.get(specInsParam.get('id').get(0));
        si.name = (String)s.get(specInsParam.get('name').get(0));
        si.practiceCodes = (String)s.getSObject(specInsParam.get('practiceCodes').get(0)).get(specInsParam.get('practiceCodes').get(1));
         
          SObject modalityCodeObject = s.getSObject(specInsParam.get('modalityCodes').get(0));
          if(modalityCodeObject != null) {
            si.modalityCodes = (String) modalityCodeObject.get(specInsParam.get('modalityCodes').get(1));
          } else {
            si.modalityCodes = 'For all modalities';
          }
          si.specialInstructions = (String)s.get(specInsParam.get('specialInstructions').get(0));
          
        siWrapperList.add(si);
      }
    } 
    catch (exception e) {
      System.debug('Error  : ' + e.getMessage()+' at line no. '+e.getLineNumber());
    }
    return siWrapperList;
  }

  /**************************************************************************************************************************************************
     *
     * @description this method serves as a reusable method for inserting categories/sub categories for existing and new articles 
     *
     * @param List of Knowledge__DataCategorySelection object, knowledgeRecord, String category, sub category
     *
     * @return List of dataCatSelectionInsertRecsList
     *
     * */

  public static void addDataCategorySelection(List<Knowledge__DataCategorySelection> dataCatSelectionInsertRecsList, Knowledge__kav knowledgeRecord, String category, String subCategory ) {

    
    if(category != null && subCategory == null) {
      Knowledge__DataCategorySelection dataCat = new Knowledge__DataCategorySelection();
            dataCat.ParentId = knowledgeRecord.Id;
            dataCat.DataCategoryGroupName = knowledgeRecord.Data_Category_Group__c;
            dataCat.DataCategoryName = category;
            dataCatSelectionInsertRecsList.add(dataCat);
        }
        if (category != null && subCategory != null) {
            Knowledge__DataCategorySelection dataCat = new Knowledge__DataCategorySelection();
            dataCat.ParentId = knowledgeRecord.Id;
            dataCat.DataCategoryGroupName = knowledgeRecord.Data_Category_Group__c;
            dataCat.DataCategoryName = subCategory;
            dataCatSelectionInsertRecsList.add(dataCat);
        }
      }
        public static void insertDataCategorySelections(List<Knowledge__DataCategorySelection> dataCatSelectionInsertRecsList) {
          if (Schema.sObjectType.Knowledge__DataCategorySelection.isCreateable() && !dataCatSelectionInsertRecsList.isEmpty()) {
              try {
                  Database.insert(dataCatSelectionInsertRecsList, false);
              } catch (DmlException ex) {
                  System.debug('An error occurred while inserting Data Category Selections: ' + ex.getMessage());
              }
          }
    }
}