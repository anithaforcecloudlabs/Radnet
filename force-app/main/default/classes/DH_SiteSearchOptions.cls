/*
 *********************************************************

Apex Class         : DH_SiteSearchOptions
  
Created Date       : April 20, 2024
  
@description       : This class is used to fetch options of dropdown fields in Site Search

@jiraid            : CC-231, CC-945

 *********************************************************
 */


public without sharing class DH_SiteSearchOptions {
  
  /**************************************************************************************************************************************************
   *
   * @description this method checks the user type
   *
   * @return Returns true if the user is a guest user and false otherwise
   *
   * */
  @AuraEnabled(cacheable=true)
  public static Boolean isCurrentUserGuest() {
    Boolean isGuestUser = false;
    isGuestUser = (System.UserInfo.getUserType() == DH_KMConstants.GUEST);
    return isGuestUser;
  }
  /**************************************************************************************************************************************************
   *
   * @description this method fetches records for Account object with recordtype 'RIS Instance/RIS System' based on healthcloud user and guest user.
   *
   * @param region String selectedcoast
   *
   * @return List of options for Region
   *
   * */
  
  @AuraEnabled(cacheable = true)
  public static List<Account> getRIS(String selectedCoast) {
    List<Account> risList = new List<Account>();
    try {
      List<Account> risRecords = DH_KMQueryManager.getRISRecords(selectedCoast);
      if (!isCurrentUserGuest() && !isCurrentUserAdministrator() && risRecords.size() > 0) {
        for (Account region : risRecords) {
          if (isCurrentUserBelongsToEastCoast() && region.Coast__c == DH_KMConstants.ACCOUNT_COAST_FIELD_EAST) {
            risList.add(region);
          }
          if (isCurrentUserBelongsToWestCoast() && region.Coast__c == DH_KMConstants.ACCOUNT_COAST_FIELD_WEST) {
            risList.add(region);
          }
        }
      } else if(isCurrentUserGuest() && risRecords.size() > 0 ) {
        for(Account region : risRecords) {
          if( (selectedCoast.contains(DH_KMConstants.COAST_EAST) && (region.Coast__c == DH_KMConstants.ACCOUNT_COAST_FIELD_EAST)) ){
            risList.add(region);
          }
          if((selectedCoast.contains(DH_KMConstants.COAST_WEST) && (region.Coast__c == DH_KMConstants.ACCOUNT_COAST_FIELD_WEST)) ){
            risList.add(region);
          }
        }
      } else {
        risList = risRecords;
      }
    }catch (exception e) {
      System.debug(LoggingLevel.ERROR, 'Error in getting region options : '+ e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return risList;
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches records for Account object with recordtype 'Practice'
   *
   * @param region List of String containing region and selectedcoast
   *
   * @return List of options for practice
   *
   * */
  
  
  @AuraEnabled(cacheable = true)
  public static List<Account> getPractice(List<String> regionList, String selectedCoast) {
    List<Account> practiceNamesList = new List<Account>();
    try {
      List<Account> practiceList = DH_KMQueryManager.getPracticeRecords(regionList, selectedCoast);
      
      //utility method for fetching NJIN virtual practice
      List<String> njinSubPractices = DH_KMUtility.virtualGroupingNJINForSiteSearch();
      Boolean isNJINExists = false;
      Account njinAccount = new Account(Name = DH_KMConstants.NJIN);
      if(practiceList.size() > 0){
        for (Account prac : practiceList) {
          if(njinSubPractices.contains(prac.Name)) {
            isNJINExists = true;
          } else {
            practiceNamesList.add(prac);
          }
        }
      }
      if (isNJINExists) {
        practiceNamesList.add(njinAccount);
      }
    }catch (exception e) {
      System.debug(LoggingLevel.ERROR, 'Error in getting practice options : '+ e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return practiceNamesList;
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches options of Site Group field 'DH_Site_Group_Region__c'
   *
   * @param region List of String containing region and practice and String selectedcoast
   *
   * @return List of options for Site group
   *
   * */
  
  
  @AuraEnabled(cacheable = true)
  public static List<String> getsiteGroupOptions(List<String> practicesList, List<String> regionList, String selectedCoast) {
      List<String> siteGroupList = new List<String>();
    try {
      
      List<Account> siteGroups = DH_KMQueryManager.getSiteGroupOptionRecords(practicesList, regionList, selectedCoast);
      Set<String> siteGroupRecords = new Set<String>();
      if(siteGroups.size()>0){
        for (Account acc : siteGroups) {
          List<String> siteGrpList = acc?.DH_Site_Group_Region__c.split(';');
          siteGroupRecords.addAll(siteGrpList);
        }
        siteGroupList.addAll(new List<String>(siteGroupRecords));
      }
      siteGroupList.sort();
    }catch (exception e) {
      System.debug(LoggingLevel.ERROR, 'Error in getting sitegroup options : '+ e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return siteGroupList;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description this method is used to fetch the coast list
   *
   * @param  String  selectedCoast - coast name
   *
   * @return List of string of coast list
   *
   * */
  public static List<String> getCoastList( String selectedCoast ) {
    Set<String> coastSet = new Set<String>();
    for (Account acc : getRIS(selectedCoast)) {
      coastSet.add(acc.Coast__c);
    }
    return new List<String>(coastSet);
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches options of Modalities from custom metadata
   *
   *
   * @return List of options for Modalities
   *
   * */
  
  
  @AuraEnabled(cacheable = true)
  public static List<Modality__mdt> getModalities(List<String> regions, List<String> practices) {
    List<Modality__mdt> modalityList = New List<Modality__mdt>();
    try {
      modalityList = DH_KMUtility.getModalityRecords(regions, practices);
      
    }catch (exception e) {
      System.debug(LoggingLevel.ERROR, 'Error in getting modality options : '+ e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return modalityList;
  }
  
  /**************************************************************************************************************************************************
   *
   * @description this method fetches options of Sub-Modalities from CareProviderFacilitySpecialty object
   *
   *
   * @return List of options for Sub-Modalities
   *
   * */
  
  @AuraEnabled(cacheable = true)
  public static List<String> getSubModalities(List<String> modality) {
    List<String> subModalities = new List<String>();
    try {
      // Use a set to automatically handle duplicate sub-modalities
      Set<String> subModalitySet = new Set<String>();
      
      Boolean isGuestUser = isCurrentUserGuest();
      
      // Fetch and process records for health cloud users
      if (!isGuestUser) {
        List<CareProviderFacilitySpecialty> specialties;
        if (!modality.isEmpty()) {
          specialties = [SELECT Name, Description__c FROM CareProviderFacilitySpecialty WHERE Name IN :modality WITH SECURITY_ENFORCED];
        }
        
        // Process health cloud user records
        for (CareProviderFacilitySpecialty specialty : specialties) {
          if (specialty.Description__c != null) {
            String[] subModalitiesArray = specialty.Description__c.split(';');
            for (String subModality : subModalitiesArray) {
              subModalitySet.add(subModality.trim());
            }
          }
        }
        
      } else { // Fetch and process records for guest users
        List<DH_CareProviderFacilitySpecialty__c> guestSpecialties;
        if (!modality.isEmpty()) {
          guestSpecialties = [SELECT Name, DH_Description__c FROM DH_CareProviderFacilitySpecialty__c WHERE Name IN :modality WITH SECURITY_ENFORCED];
        }
        
        // Process guest user records
        for (DH_CareProviderFacilitySpecialty__c guestSpecialty : guestSpecialties) {
          if (guestSpecialty.DH_Description__c != null) {
            String[] guestSubModalitiesArray = guestSpecialty.DH_Description__c.split(';');
            for (String subModality : guestSubModalitiesArray) {
              subModalitySet.add(subModality.trim());
            }
          }
        }
      }
      
      // Convert the set to a list to remove duplicates
      subModalities = new List<String>(subModalitySet);
      subModalities.sort();
      
    } catch (exception e) {
      System.debug(LoggingLevel.ERROR, 'Error in getting sub modality options : ' + e.getMessage() + ' at line no: ' + e.getLineNumber());
    }
    return subModalities;
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description this method is used to search Site accounts and get records from custom lookup field
   *
   * @param String searchKey, objectName and selectedcoast
   *
   * @return query of accounts based on User coast
   *
   * */
  
  
  @AuraEnabled(cacheable = true)
  public static List<sobject> findRecords(String searchKey, String objectName, String selectedCoast) {
    
    List<sObject> records = new List<sObject>();
    try{
      records = DH_KMQueryManager.searchFindRecords(searchKey, objectName, selectedCoast);
    } catch (exception e) {
      System.debug(LoggingLevel.ERROR, 'Error in searching records : '+ e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return records;
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description this method is used to check if user belongs to east coast
   *
   * @return    Boolean     Returns true if the current user belongs to east coast
   * */
  
  public static Boolean isCurrentUserBelongsToEastCoast() {
    return DH_KMUtility.isUserInCoast(UserInfo.getUserId(), DH_KMConstants.ACCOUNT_COAST_FIELD_EAST);
  }
  
  /**************************************************************************************************************************************************
   *
   * @description this method is used to check if user belongs to west coast
   *
   * @return    Boolean     Returns true if the current user belongs to west coast
   *
   * */
  
  public static Boolean isCurrentUserBelongsToWestCoast() {
    return DH_KMUtility.isUserInCoast(UserInfo.getUserId(), DH_KMConstants.ACCOUNT_COAST_FIELD_WEST);
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description this method is used to check if user has a System Administrator profile
   *
   * @return    Boolean    Returns true if the current user is System administrator and false otherwise
   * */
  
  private static Boolean isCurrentUserAdministrator() {
    Profile profileRecord;
    if (GroupMember.SObjectType.getDescribe().isAccessible()){
      profileRecord = [ SELECT Id, Name from Profile WHERE Id = : UserInfo.getProfileId() WITH SECURITY_ENFORCED];
    }
    return profileRecord.Name == DH_KMConstants.SYSTEM_ADMINISTRATOR;
  }
  
  
  /**************************************************************************************************************************************************
   *
   * @description this method is used to generate URL for vfpage componet to render map
   *
   * @return   String   Returns vf origin specific to the org
   * */
  
  @AuraEnabled(cacheable = true)
  public static string getVFOrigin() {
    string vfOrigin = '';
    try{
      string baseURL = URL.getOrgDomainUrl().toExternalForm();
      string vfAppend = DH_KMConstants.DDC + '.' + DH_KMConstants.FORCECOM;
      if (baseURL.contains(DH_KMConstants.SANDBOX)) {
        vfAppend = DH_KMConstants.DDC + '.' + DH_KMConstants.SANDBOX + '.' + DH_KMConstants.FORCECOM;
      }
      vfOrigin = baseURL.split('\\.')[0] + vfAppend;
    }
    catch (exception e) {
      System.debug(LoggingLevel.ERROR, 'Error in setting Vforigin for site search Vfpage : '+ e.getMessage()+' at line no: '+e.getLineNumber());
    }
    return vfOrigin;
  }

  /**************************************************************************************************************************************************
   * CC-1245
   * @description this method is used to update the Account field XR Link Label
   *
   * @param String accountId - Account Id, String linklabel- LinkLabel
   *
   * */
   @AuraEnabled(cacheable=false)
        public static void updateAccountXRLink (String accountId, String linkLabel){
          Account acc = new Account(Id=accountId, XR_Link_Label__c=linkLabel);
          update acc;
        }
}