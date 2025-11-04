/******************************************************************************************************************************************************
 *
 * @Created Date      :  7/8/2024
 *
 * @description       :  This Query Manager class used to keep queries for Normal Healthcloud Users and Guest users to fetch data from different objects and return sObjects
 *
 * @JIRA Id           :  CC-819, CC-231, CC-945, CC-946, CC-947, CC-949, CC-964
 * */
public with sharing class DH_KMQueryManager {
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch records for HealthCareProcedure object and cloned object for Healthcloud user and Guest user respectively
     *
     * @return List of sObject from HealthCareProcedure or cloned object
     *
     * */
    public static List<sObject> getHealthcareProcedureRecords(List<String> practice, List<String> modalities, Boolean isGuestUser){
        List<sObject> hpRecordList = new List<sObject>();
        try{
            if(isGuestUser){
                //querying from cloned object for UCC for active records and with recordtype DH KM Healthcare Procedure
                if (DH_HealthCareProcedure__c.SObjectType.getDescribe().isAccessible()){
                    hpRecordList = [SELECT Id,Name, DH_Name__c, DH_Practice_Code_s__c, DH_New_Modality_codes__c, DH_Body_Parts__c,
                                    DH_Reason_for_Exam__c, DH_Procedure_Codes__c, DH_Special_Instructions__c, DH_Active__c, createddate,
                                    DH_Practice_Code_s__r.Practice_code__c, DH_New_Modality_codes__r.Name
                                    FROM DH_HealthCareProcedure__c 
                                    WHERE DH_New_Modality_codes__c != null AND DH_New_Modality_codes__r.Name = : modalities 
                                    AND DH_Practice_Code_s__c != null AND DH_Practice_Code_s__r.Practice_code__c IN : practice 
                                    AND RecordType.DeveloperName = :DH_KMConstants.CLONED_EX_HEALTHCARE_RECORDTYPE_NAME
                                    AND DH_Active__c = true 
                                    WITH SECURITY_ENFORCED];
                }
            }else{
                //querying from original object for HealthCloud for active records and with recordtype KM Healthcare Procedure
                if (HealthCareProcedure.SObjectType.getDescribe().isAccessible()){
                    hpRecordList = [SELECT Id, Name, Practice_Codes__c, Modality_Codes__c,Body_Parts__c,  
                                    Reason_for_Exam__c, Code, Special_Instructions__c, isActive, createddate, 
                                    Practice_Codes__r.Practice_code__c, Modality_Codes__r.Name  
                                    FROM HealthCareProcedure 
                                    WHERE Modality_Codes__c != null AND Modality_Codes__r.Name = : modalities 
                                    AND Practice_Codes__c != null AND Practice_Codes__r.Practice_code__c IN : practice 
                                    AND RecordType.Name = :DH_KMConstants.EX_HEALTHCARE_RECORDTYPE_NAME
                                    AND isActive = true 
                                    WITH SECURITY_ENFORCED];
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching procedure records :' +e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return hpRecordList;
    }
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch records for Modality for special instructions object and cloned object for Healthcloud user and Guest user respectively
     *
     * @return List of sObject from Modality for special instructions or cloned object
     *
     * */
    public static List<sObject> getSpecialInstructionsRecords(List<String> practice, List<String> modalities, Boolean isGuestUser){
        List<sObject> siRecordList = new List<sObject>();
        try{
            if(isGuestUser){
                //querying from original object with cloned modality field made for UCC
                if (Special_Instructions__c.SObjectType.getDescribe().isAccessible()){
                    siRecordList = [SELECT Id,Name, Practice_Codes__c, DH_Modality_Codes__c, Special_Instructions__c, DH_Modality_Codes__r.Name, Practice_Codes__r.Practice_code__c 
                                    From Special_Instructions__c 
                                    WHERE (DH_Modality_Codes__r.Name ='' OR DH_Modality_Codes__r.Name = : modalities) 
                                    AND Practice_Codes__r.Practice_code__c IN : practice 
                                    AND isActive__c = true
                                    WITH SECURITY_ENFORCED];
                }
                
            }else{
                //querying from original object with original modality field made for HealthCloud
                if (Special_Instructions__c.SObjectType.getDescribe().isAccessible()){
                    siRecordList = [SELECT Id, Name, Practice_Codes__c, Modality_Codes__c, Special_Instructions__c, Modality_Codes__r.Name, Practice_Codes__r.Practice_code__c 
                                    From Special_Instructions__c 
                                    WHERE (Modality_Codes__r.Name ='' OR Modality_Codes__r.Name = : modalities) 
                                    AND Practice_Codes__r.Practice_code__c IN : practice 
                                    AND isActive__c = true
                                    WITH SECURITY_ENFORCED];
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching Special instructions records :' +e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return siRecordList;
    }
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch records for HealthcarePayerNetwork object and cloned object for Healthcloud user and Guest user respectively
     *
     * @param region List of regions selected
     *
     * @param isGuestUser boolean to check if user is guest user or not
     *
     * @return List of sObject from HealthcarePayerNetwork or cloned object
     *
     * */
    public static List<sObject> getHealthcarePayerNetworkList(List<String> region, Boolean isGuestUser){
        List<sObject> hpRecordList = new List<sObject>();
        try{
            if(isGuestUser){
                //querying from cloned healthcarePayerNetwork object for UCC
                if (region.size() >0 && DH_HealthcarePayerNetwork__c.SObjectType.getDescribe().isAccessible()){
                    hpRecordList =  [select Id, DH_PayerId__r.Name, DH_PayerId__r.Carrier_Code_in_RIS__c, DH_Region__r.Name, DH_Region__r.Region__c, DH_Modality_Description__c,
                    DH_Exam_Covered__c from DH_HealthcarePayerNetwork__c where DH_Region__r.Region__c IN : region AND DH_IsActive__c = true WITH SECURITY_ENFORCED];
                }
            }else{
                //querying from standard HealthcarePayerNetwork object
                if (region.size() >0 && HealthcarePayerNetwork.SObjectType.getDescribe().isAccessible()){
                    hpRecordList = [select Id, Payer.Name, Payer.Carrier_Code_in_RIS__c, Region__r.Name,Region__r.Region__c, Modality_Description__c,
                    Exam_Covered__c from HealthcarePayerNetwork where Region__r.Region__c IN : region AND IsActive = true WITH SECURITY_ENFORCED];
                }
            }
            
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching SpecialBills for SpecialAcc_SpecialBillController :' +e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return hpRecordList;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches records for special accomodation table
     *
     * @param region List of String containing region
     *
     * @param practice List of String containing practices
     *
     * @param isGuestUser boolean to check whether the user is guest user or not
     *
     * @return List of special accommodation records
     *
     * */
    public static List<sObject> getSpecialAccomodationBillsList(List<String> region, List<String> practice, Boolean isGuestUser){
        List<Special_accomodation_practice__c> specialAccomodationBillsList = new List<Special_accomodation_practice__c>();
        
        String subquery ='SELECT id, Notes__c, Special_Accomodation_and_Protocols__r.Name,Practice__r.Parent.Region__c,Practice__r.Practice_code__c,Practice__r.Name from Special_accomodation_practice__c';
        String specialAccRegion = ' WHERE Practice__r.Parent.Region__c IN : region WITH SECURITY_ENFORCED';
        String specialAccPractice =' WHERE Practice__r.Practice_code__c IN : practice AND Practice__r.Parent.Region__c IN : region WITH SECURITY_ENFORCED';
        try {
            if (region.size() > 0 && Special_accomodation_practice__c.SObjectType.getDescribe().isAccessible()) {
                List<String> tempInput = new List<String>();
                //fetch all the practices under NJIN
                if (practice.contains(DH_KMConstants.NJIN_PRACTICE_CODE)) {
                    practice.addAll(DH_KMUtility.virtualGroupingNJIN());
                }
                //If practice is not selected show all special accomodation coming under the selected region
                if (practice.size() == 0) {
                    String query = subquery + specialAccRegion;
                    specialAccomodationBillsList = Database.query(String.escapeSingleQuotes(query));
                    
                } else {
                    //filter special accomodation based on practice
                    String query = subquery+specialAccPractice;
                    specialAccomodationBillsList = Database.query(String.escapeSingleQuotes(query));
                    
                }
            }
            
        } catch (exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching SpecialAccomodationBills for SpecialAcc_SpecialBillController : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return specialAccomodationBillsList;
    }
    
    // MACHINE WEIGHT METHODS START
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on Modality, Practice, Site selection for HealthCloud user
     *
     * @param   modalities      List of String of selected modalities
     * @param   practices       List of String of selected practices
     * @param   siteCodeName    String of selected siteCodeName
     *
     * @return  machineWeightList List of sObject from Machine&Weight object
     *
     * */
    // GET RECORD BASED ON MODALITY FOR HEALTHCLOUD USER
    public static List<sObject> getMachineWeightListByModality(List<String> modalities, List<String> practices, String siteCodeName){
        List<sObject> machineWeightList = new List<sObject>();
        try{
            
            String subQuery = 'SELECT id, Name, Machine__c, Weight__c, Room__c, Slice__c, Site_Modality__r.Name, '
                + 'Site_Modality__r.Account.Site_Code__c,Site_Modality__r.AccountId, Site_Modality__r.Account.Name, '
                + 'Site_Modality__r.Account.Parent.Name, Site_Modality__r.Account.Parent.Practice_code__c, Description__c '
                + 'FROM HL_Machine_and_Weight__c ';
            
            String wherePracticeQuery = 'WHERE Site_Modality__r.Account.Parent.Practice_code__c IN : practices WITH SECURITY_ENFORCED';
            String whereSiteCodeQuery = 'WHERE Site_Modality__r.Account.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String whereModalityAndSiteCodeQuery = 'WHERE Site_Modality__r.Name = : modalities and Site_Modality__r.Account.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String whereModalityAndPracticeQuery = 'WHERE Site_Modality__r.Name = : modalities and Site_Modality__r.Account.Parent.Practice_code__c IN : practices WITH SECURITY_ENFORCED';
            
            if (modalities.size() <= 0 && practices.size() > 0) {
                String query = subQuery + wherePracticeQuery ;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (modalities.size() <= 0 && siteCodeName.length() > 0) {
                String query = subQuery + whereSiteCodeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (modalities.size() > 0 && siteCodeName.length() > 0) {
                String query = subQuery + whereModalityAndSiteCodeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (modalities.size() > 0 && practices.size() > 0) {
                String query = subQuery + whereModalityAndPracticeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            }
            
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching MachineWeight record by Modality for HC : ' + e.getMessage());
        }
        return machineWeightList;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on Modality, Practice, Site selection for Guest User
     *
     * @param   modalities      List of String of selected modalities
     * @param   practices       List of String of selected practices
     * @param   siteCodeName    String of selected siteCodeName
     *
     * @return  machineWeightList List of sObject from Machine&Weight object
     *
     * */
    // GET RECORD BASED ON MODALITY FOR GUEST USER
    public static List<sObject> getMachineWeightListByModalityForGuest(List<String> modalities, List<String> practices, String siteCodeName){
        
        List<sObject> machineWeightList = new List<sObject>();
        try{
            String subQuery = 'SELECT id, Name, Machine__c, Weight__c, Room__c, Slice__c, DH_CareProviderFacilitySpecialty__r.Name, '
                + 'DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Site_Code__c,DH_CareProviderFacilitySpecialty__r.DH_AccountId__c, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name, '
                + 'DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c, Description__c '
                + 'FROM HL_Machine_and_Weight__c ';
            String wherePracticeQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c IN : practices WITH SECURITY_ENFORCED';
            String whereSiteCodeQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String whereModalityAndSiteCodeQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.Name = : modalities and DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String whereModalityAndPracticeQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.Name = : modalities and DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c IN : practices WITH SECURITY_ENFORCED';
            
            if (modalities.size() <= 0 && practices.size() > 0) {
                
                String query = subQuery + wherePracticeQuery ;
                machineWeightList = Database.query(String.escapeSingleQuotes(query));
                
            } else if (modalities.size() <= 0 && siteCodeName.length() > 0) {
                String query = subQuery + whereSiteCodeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (modalities.size() > 0 && siteCodeName.length() > 0) {
                
                String query = subQuery + whereModalityAndSiteCodeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (modalities.size() > 0 && practices.size() > 0) {
                String query = subQuery + whereModalityAndPracticeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            }
            
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching MachineWeight record by Modality for Guest : ' + e.getMessage());
        }
        return machineWeightList;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on Practice, Site selection for HealthCloud User
     *
     * @param   practices       List of String of selected practices
     * @param   siteCodeName    String of selected siteCodeName
     *
     * @return  machineWeightList List of sObject from Machine&Weight object
     *
     * */
    // GET RECORD BASED ON PRACTICE FOR HEALTHCLOUD USER
    public static List<sObject> getMachineWeightListByPractice( List<String> practices, String siteCodeName){
        
        List<sObject> machineWeightList = new List<sObject>();
        try{
            
            String subQuery = 'SELECT id, Name, Machine__c, Weight__c, Room__c, Slice__c, Site_Modality__r.Name, '
                + 'Site_Modality__r.Account.Site_Code__c,Site_Modality__r.AccountId, Site_Modality__r.Account.Name, '
                + 'Site_Modality__r.Account.Parent.Name, Site_Modality__r.Account.Parent.Practice_code__c, Description__c '
                + 'FROM HL_Machine_and_Weight__c ';
            String wherePracticeSiteCQuery = 'WHERE Site_Modality__r.Account.Parent.Practice_code__c '
                + 'IN : practices AND Site_Modality__r.Account.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String whereSiteCodeQuery = 'WHERE Site_Modality__r.Account.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String wherePracticeQuery = 'WHERE Site_Modality__r.Account.Parent.Practice_code__c IN : practices WITH SECURITY_ENFORCED';
            
            if (practices.size() > 0 && siteCodeName.length() > 0) {
                String query = subQuery + wherePracticeSiteCQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (practices.size() <= 0 && siteCodeName.length() > 0) {
                String query = subQuery + whereSiteCodeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
                
            } else if (practices.size() > 0 && siteCodeName.length() <= 0) {
                String query = subQuery + wherePracticeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            }
            
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching MachineWeight record by Practice for HC : ' + e.getMessage());
        }
        return machineWeightList;
        
    }
    
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on Practice, Site selection for Guest User
     *
     * @param   practices       List of String of selected practices
     * @param   siteCodeName    String of selected siteCodeName
     *
     * @return  machineWeightList List of sObject from Machine&Weight object
     *
     * */
    // GET RECORD BASED ON PRACTICE FOR GUEST USER
    public static List<sObject> getMachineWeightListByPracticeForGuest( List<String> practices, String siteCodeName){
        
        List<sObject> machineWeightList = new List<sObject>();
        try{
            String subQuery = 'SELECT id, Name, Machine__c, Weight__c, Room__c, Slice__c, DH_CareProviderFacilitySpecialty__r.Name, '
                + 'DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Site_Code__c,DH_CareProviderFacilitySpecialty__r.DH_AccountId__c, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name, '
                + 'DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c, Description__c '
                + 'FROM HL_Machine_and_Weight__c ';
            String wherePracticeSiteCQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c '
                + '= : practices AND DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String whereSiteCodeQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String wherePracticeQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c = : practices WITH SECURITY_ENFORCED';
            
            if (practices.size() > 0 && siteCodeName.length() > 0) {
                String query = subQuery + wherePracticeSiteCQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (practices.size() <= 0 && siteCodeName.length() > 0) {
                String query = subQuery + whereSiteCodeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (practices.size() > 0 && siteCodeName.length() <= 0) {
                String query = subQuery + wherePracticeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
            }
            
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching MachineWeight record by Pracitce for Guest : ' + e.getMessage());
        }
        return machineWeightList;
        
    }
    
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on Practice, Site selection for HealthCloud User
     *
     * @param   practices       List of String of selected practices
     * @param   siteCodeName    String of selected siteCodeName
     *
     * @return  machineWeightList List of sObject from Machine&Weight object
     *
     * */
    // GET RECORD BASED ON SITE FOR HEALTHCLOUD USER
    public static List<sObject> getMachineWeightListBySite( List<String> practices, String siteCodeName){
        
        List<sObject> machineWeightList = new List<sObject>();
        try{
            
            String subQuery = 'SELECT id, Name, Machine__c, Weight__c, Room__c, Slice__c, Site_Modality__r.Name, '
                + 'Site_Modality__r.Account.Site_Code__c,Site_Modality__r.AccountId, Site_Modality__r.Account.Name, '
                + 'Site_Modality__r.Account.Parent.Name, Site_Modality__r.Account.Parent.Practice_code__c, Description__c '
                + 'FROM HL_Machine_and_Weight__c ';
            String wherePracticeSiteCQuery = 'WHERE Site_Modality__r.Account.Parent.Practice_code__c '
                + 'IN : practices and Site_Modality__r.Account.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String whereSiteCodeQuery = 'WHERE Site_Modality__r.Account.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String wherePracticeQuery = 'WHERE Site_Modality__r.Account.Parent.Practice_code__c IN : practices WITH SECURITY_ENFORCED';
            
            if (practices.size() > 0 && siteCodeName.length() > 0) {
                String query = subQuery + wherePracticeSiteCQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (practices.size() <= 0 && siteCodeName.length() > 0) {
                String query = subQuery + whereSiteCodeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (practices.size() > 0 && siteCodeName.length() <= 0) {
                String query = subQuery + wherePracticeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
            }
            
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching MachineWeight record by Site for HC : ' + e.getMessage());
        }
        return machineWeightList;
        
    }
    
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on Practice, Site selection for Guest User
     *
     * @param   practices       List of String of selected practices
     * @param   siteCodeName    String of selected siteCodeName
     *
     * @return  machineWeightList List of sObject from Machine&Weight object
     *
     * */
    // GET RECORD BASED ON SITE FOR GUEST USER
    public static List<sObject> getMachineWeightListBySiteForGuest( List<String> practices, String siteCodeName){
        
        List<sObject> machineWeightList = new List<sObject>();
        try{
            
            String subQuery = 'SELECT id, Name, Machine__c, Weight__c, Room__c, Slice__c, DH_CareProviderFacilitySpecialty__r.Name, '
                + 'DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Site_Code__c,DH_CareProviderFacilitySpecialty__r.DH_AccountId__c, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name, '
                + 'DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c, Description__c '
                + 'FROM HL_Machine_and_Weight__c ';
            String wherePracticeSiteCQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c '
                + 'IN : practices AND DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String whereSiteCodeQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name = : siteCodeName WITH SECURITY_ENFORCED';
            String wherePracticeQuery = 'WHERE DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c IN : practices WITH SECURITY_ENFORCED';
            
            if (practices.size() > 0 && siteCodeName.length() > 0) {
                String query = subQuery + wherePracticeSiteCQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (practices.size() <= 0 && siteCodeName.length() > 0) {
                String query = subQuery + whereSiteCodeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
                
            } else if (practices.size() > 0 && siteCodeName.length() <= 0) {
                String query = subQuery + wherePracticeQuery;
                machineWeightList =  Database.query(String.escapeSingleQuotes(query));
            }
            
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,  'Error while fetching MachineWeight record by Site for Guest : ' +e.getMessage());
        }
        return machineWeightList;
        
    }
    
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch all Account records of recordtype SITE from Region MA or NE or FL
     *              for MachineWeight components SiteCode Search Bar
     *
     * @return      accList     List of sObject of Account records
     *
     * */
    // GET SITE RECORDS FOR M&W LWC SITE SEARCH BAR
    public static List<sObject> getSiteListQuery() {
        List<sObject> accList = new List<sObject>();
        try{
            accList = [ SELECT Name FROM Account WHERE RecordType.Name =: DH_KMConstants.ACCOUNT_RECORDTYPE_SITE 
            AND (Region__c =: DH_KMConstants.REGION_MA 
            OR Region__c =: DH_KMConstants.REGION_NE 
            OR Region__c =: DH_KMConstants.REGION_FL) 
                        WITH SECURITY_ENFORCED ];
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error while fetching Site record : ' +e.getMessage());
        }
        return accList;
    }
    // MACHINE WEIGHT METHODS END
    
    
    // SITE SEARCH METHOD STARTS
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches records for Account object with recordtype 'RIS Instance/RIS System'
     *
     * @param region String selectedcoast
     *
     * @return List of options for Region
     *
     * */
    
    public static List<Account> getRISRecords(String selectedCoast){
        List<Account> risRecords = new List<Account>();
        try{
            if(Account.SObjectType.getDescribe().isAccessible()) {
                risRecords = [ SELECT Id, Name, Coast__c, DH_Site_Group_Region__c 
                        FROM Account 
                        WHERE RecordType.Name = :DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM
                        WITH SECURITY_ENFORCED 
                        ORDER BY Name ASC ];
            }
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching RIS Instance/RIS System recordtype records :' +e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return risRecords;
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
    
    public static List<Account> getPracticeRecords(List<String> regionList, String selectedCoast){
        List<Account> practiceList = new List<Account>();
        try{
            if(Account.SObjectType.getDescribe().isAccessible()){
                String baseQuery = 'SELECT Id, Name, Coast__c, DH_Site_Group_Region__c, Parent.Name from Account  ';
                String conditions = ' WHERE RecordType.Name = :recordTypeName ';
                Map<String,Object> bindMap = new Map<String,Object>();
                bindMap.put( 'recordTypeName', DH_KMConstants.PRACTICE_RECORD_TYPE );
                //based on region
                if (!regionList.isEmpty()) {
                    conditions += ' AND AccountRegion__r.Name IN : regionList ';
                    bindMap.put( 'regionList', regionList );
                    
                    //default RegionList, show all practices
                } else {
                    List<String> defaultRegionList = new List<String>();
                    for (Account region : DH_SiteSearchOptions.getRIS(selectedCoast)) {
                        defaultRegionList.add(region.Coast__c);
                    }
                    bindMap.put( 'defaultRegionList', defaultRegionList );
                    conditions += ' AND Coast__c IN : defaultRegionList ';
                }
                conditions += ' WITH SECURITY_ENFORCED ORDER BY Name ASC';
                String dynamicSoqlQuery = baseQuery + conditions;
                practiceList = Database.queryWithBinds( dynamicSoqlQuery, bindMap, AccessLevel.SYSTEM_MODE);
            }
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching practice options records :' +e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return practiceList;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches options of Site Group field 'DH_Site_Group_Region__c'
     *
     * @param region List of String containing region and practice and selectedcoast
     *
     * @return List of options for Site group
     *
     * */
    
    public static List<Account> getSiteGroupOptionRecords(List<String> practicesList, List<String> regionList, String selectedCoast){
        List<Account> siteGroups = new List<Account>();
        try{
            if(Account.SObjectType.getDescribe().isAccessible()){
                String baseQuery = 'SELECT Id, Name, Coast__c, DH_Site_Group_Region__c, Account_Practice__r.Name FROM Account  ';
                String conditions = ' WHERE DH_Site_Group_Region__c <> null ';
                conditions += ' AND Coast__c IN :coastList ';
                Map<String,Object> bindMap = new Map<String,Object>();
                bindMap.put( 'coastList', DH_SiteSearchOptions.getCoastList(selectedCoast));
                //based on practice
                if(!practicesList.isEmpty()) {
                    if (practicesList.contains(DH_KMConstants.NJIN)) {
                        practicesList.addAll(DH_KMUtility.virtualGroupingNJINForSiteSearch());
                    }
                    conditions += ' AND Account_Practice__r.Name IN :practicesList ';
                    bindMap.put( 'practicesList', practicesList );
                    //based on region
                } else if(!regionList.isEmpty()) {
                    conditions += ' AND AccountRegion__r.Name IN :regionList ';
                    bindMap.put( 'regionList', regionList );
                }
                conditions += ' WITH SECURITY_ENFORCED ';
                
                String dynamicSoqlQuery = baseQuery + conditions;
                siteGroups = Database.queryWithBinds( dynamicSoqlQuery, bindMap, AccessLevel.SYSTEM_MODE);
            }
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching site group options records :' +e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return siteGroups;
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
 
    
    public static List<sObject> searchFindRecords(String searchKey, String objectName, String selectedCoast) {
    List<sObject> records = new List<sObject>();
    List<sObject> recordsWithBrackets = new List<sObject>();
    List<sObject> otherRecords = new List<sObject>();
      
    try {
        // Initialize base query
        String queryString = 'SELECT Id, Name, Site_Code__c FROM ' + objectName;
        String whereClause = ' WHERE RecordType.Name = :recordTypeSite ';
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put('recordTypeSite', 'Site');
        bindMap.put('searchKeyString', '%' + searchKey + '%');

      //query to find records if healthcloud user is east user or guest user selects east coast
        if (DH_SiteSearchOptions.isCurrentUserBelongsToEastCoast() || 
            (DH_SiteSearchOptions.isCurrentUserGuest() && selectedCoast.contains('East'))) {
            queryString += whereClause + ' AND (Name LIKE :searchKeyString OR Site_Code__c LIKE :searchKeyString)';
            queryString += ' AND Coast__c = :coast';
            bindMap.put('coast', 'East coast');
        } //query to find records if healthcloud user is west user or guest user selects west coast
        else if (DH_SiteSearchOptions.isCurrentUserBelongsToWestCoast() || 
                   (DH_SiteSearchOptions.isCurrentUserGuest() && selectedCoast.contains('West'))) {
            queryString += whereClause + ' AND (Name LIKE :searchKeyString OR Site_Code__c LIKE :searchKeyString)';
            queryString += ' AND Coast__c = :coast';
            bindMap.put('coast', 'West coast');
        } //query if user is system administrator
        else {
            queryString += whereClause + ' AND (Name LIKE :searchKeyString OR Site_Code__c LIKE :searchKeyString)';
        }

        queryString += ' WITH SECURITY_ENFORCED';
        
        // Execute the query
        records = Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE);

        // Manual sorting: prioritize records with searchKey inside brackets
        String searchKeyWithBracketsCaptital = '(' + searchKey.toUpperCase() + ')';

        for (sObject record : records) {
            String name = (String)record.get('Name');
            if (name != null && name.contains(searchKeyWithBracketsCaptital)) {
                recordsWithBrackets.add(record); // Prioritize records with the search key inside brackets
            } else {
                otherRecords.add(record); // Add all other records
            }
        }

        // Clear original list and add sorted records
        records.clear();
        records.addAll(recordsWithBrackets);
        records.addAll(otherRecords);

        // Create a new list to hold only the first 6 records
        List<sObject> limitedRecords = new List<sObject>();
        Integer count = 0;
        for (sObject record : records) {
            if (count < 6) {
                limitedRecords.add(record);
                count++;
            } else {
                break; // Stop adding records once we reach 6
            }
        }
        return limitedRecords;

    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Error while searching records: ' + e.getMessage() + ' at line no: ' + e.getLineNumber());
        return new List<sObject>(); // Return an empty list in case of an error
    }
}
   
    // Site Modality controller to show related list
    public static List<sObject> getSiteModality(String record, Boolean isGuest){
        List<sObject> cpfsRecords = new List<sObject>();
        try{
            if(isGuest){
                cpfsRecords = [SELECT id, Name, DH_Description__c, DH_SpecialtyId__r.Name from DH_CareProviderFacilitySpecialty__c where DH_AccountId__c =: record and DH_SpecialtyId__c !=: NULL  WITH SECURITY_ENFORCED ORDER BY DH_SpecialtyId__r.DH_Order__c ];
            }
            else{
                cpfsRecords = [SELECT id, Name, Description__c, Specialty.Name from CareProviderFacilitySpecialty where AccountId =: record and SpecialtyId !=: NULL  WITH SECURITY_ENFORCED ORDER BY Specialty.Order__c];
            }
        }catch(Exception e) {
            DH_KMUtility.getException(e,'Error in quering CPFS related list : ');
        }
        return cpfsRecords;
    }
    // Site Modality controller to delete CareProviderFacilitySpecialty records
    public static List<CareProviderFacilitySpecialty> deleteSiteModality(String recordId){
        List<CareProviderFacilitySpecialty> cpfsRecords = new List<CareProviderFacilitySpecialty>();
        try{
            cpfsRecords = [SELECT Id, Name from CareProviderFacilitySpecialty where Id =: recordId WITH SECURITY_ENFORCED ];
        }catch(Exception e) {
            DH_KMUtility.getException(e,'Error in quering CPFS delete list : ');
        }
        return cpfsRecords;
    }
    // SITE SEARCH METHOD END
    
    // KNOWLEDGE SEARCH METHODS START
    
    // query Knowledge__DataCategorySelection records
    public static List<sObject> queryKnowledgeDataCategorySelection(){
        
        List<Knowledge__DataCategorySelection> knowDataCatSelection = new List<Knowledge__DataCategorySelection>();
        try{
            knowDataCatSelection = [SELECT Id, DataCategoryName, ParentId, DataCategoryGroupName FROM Knowledge__DataCategorySelection WITH SECURITY_ENFORCED];
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return knowDataCatSelection;
        
    }
    
    public static List<sObject> getKnowledgeArticles(List<Id> articleIdList ){
        
        List<Knowledge__kav> knowArticles = new List<Knowledge__kav>();
        try{
            // WITH SECURITY ENFORCED NOT ADDED FOR ARTICLELIST QUERY
            // due to Knowledge index Obj field permission restriction required for list views
            // Knowledge Indexing object East-index field permission not granted to west coast permission sets and vice-versa
            
            knowArticles = [Select Id,Title,Details__c, Article_Description__c, Index__c, (SELECT id, index__c, west_Index__c from Knowledge_Indexing__r LIMIT 1 ) from Knowledge__kav where Id in :articleIdList AND PublishStatus =:DH_KMConstants.PUBLISH_STATUS_ONLINE];
            
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return knowArticles;
        
    }
    //KNOWLEDGE SEARCH FUNCTIONALITY METHODS
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get the most viewed articles from all the published knowledge Articles
     *
     * @param coasts coast types fetched from coastType method from DH_KMUtility class
     *
     * @param isGuest boolean to check whether the user is guest user or not
     *
     * @return list of most viewed articles by checking the ArticleTotalViewCount field which stores the view count for Articles
     *
     * */
    public static List<sObject> getMostViewedKnowledgeArticlesRecordsList(List<String> coasts ,Boolean isGuest){
        List<Knowledge__kav> mostViewedArticles = new List<Knowledge__kav>();
        try{
            //Querying all the knowledge articles containing the search key based on guest user and coast selected
            if(isGuest){
                mostViewedArticles=[SELECT Id, Title,Article_type__c,ArticleTotalViewCount FROM Knowledge__kav  WHERE PublishStatus =: DH_KMConstants.PUBLISH_STATUS_ONLINE AND Article_type__c IN:coasts WITH SECURITY_ENFORCED  ORDER BY ArticleTotalViewCount DESC  LIMIT 5];
            }
            else{
                //Querying all the knowledge articles containing the search key
                mostViewedArticles=[SELECT Id, Title,Article_type__c,ArticleTotalViewCount FROM Knowledge__kav  WHERE PublishStatus =: DH_KMConstants.PUBLISH_STATUS_ONLINE  WITH SECURITY_ENFORCED ORDER BY ArticleTotalViewCount DESC  LIMIT 5 ];
            }
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return mostViewedArticles;
    }
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get knowledge articles for typeahead with most viewed articles on top containing the search key
     *
     * @param querySearchKey search value modified for SOSL query
     *
     * @param coasts coast types fetched from coastType method from DH_KMUtility class
     *
     * @param isGuest boolean to check whether the user is guest user or not
     *
     * @return list of list of knowledge articles
     *
     * */
    
    public static List<List<sObject>> getTrackingDetailsRecordsList(String querySearchKey, List<String> coasts ,Boolean isGuest){
        List<List<Knowledge__kav>> trackingDetails = new List<List<Knowledge__kav>>();
        String query;
        try{
            String publishStatusOnline = DH_KMConstants.PUBLISH_STATUS_ONLINE;
            String subquery =' IN ALL FIELDS RETURNING Knowledge__kav(Id,Title,Details__c,Article_type__c,ArticleTotalViewCount WHERE PublishStatus=:publishStatusOnline';
            //Querying all the knowledge articles containing the search key based on guest user and coast selected
            if(isGuest){
                query ='FIND :querySearchKey' +subquery +' AND Article_type__c IN: coasts ORDER BY ArticleTotalViewCount DESC)';
            }
            else{
                //Querying all the knowledge articles containing the search key
                query ='FIND :querySearchKey' +subquery +' ORDER BY ArticleTotalViewCount DESC)';
            }
            
            trackingDetails=Search.query(query);
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return trackingDetails;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get all the knowledge articles containing the search key
     *
     * @param querySearchKey search value modified for SOSL query
     *
     * @param coasts coast types fetched from coastType method from DH_KMUtility class
     *
     * @param isGuest boolean to check whether the user is guest user or not
     *
     * @return list of list of knowledge articles
     *
     * */
    public static List<List<sObject>> getAllTrackingDetailsRecordsList(String querySearchKey, List<String> coasts ,Boolean isGuest){
        List<List<Knowledge__kav>> allTrackingDetails = new List<List<Knowledge__kav>>();
        String query;
        try{
            String publishStatusOnline = DH_KMConstants.PUBLISH_STATUS_ONLINE;
            String subquery =' IN ALL FIELDS RETURNING Knowledge__kav(Id,Title,Details__c,Article_type__c,ArticleTotalViewCount WHERE PublishStatus=:publishStatusOnline';
            //Querying all the knowledge articles containing the search key based on guest user and coast selected
            if(isGuest){
                query ='FIND :querySearchKey' +subquery +' AND Article_type__c IN: coasts)';
            }
            else{
                //Querying all the knowledge articles containing the search key
                query ='FIND :querySearchKey' +subquery+ ')';
            }
            allTrackingDetails=Search.query(query);
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return allTrackingDetails;
    }
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get the sub categories and their respective knowledge articles containing the search key
     *
     * @param querySearchKey search value modified for SOSL query
     *
     * @param coasts coast types fetched from coastType method from DH_KMUtility class
     *
     * @param isGuest boolean to check whether the user is guest user or not
     *
     * @return list of list of knowledge articles
     *
     * */
    public static List<List<sObject>> getCategoryNameRecords(String querySearchKey, List<String> coasts ,Boolean isGuest){
        List<List<Knowledge__kav>> categoryNameRecords = new List<List<Knowledge__kav>>();
        String query;
        try{
            String publishStatusOnline = DH_KMConstants.PUBLISH_STATUS_ONLINE;
            String subquery =' IN ALL FIELDS RETURNING Knowledge__kav(Id,Title,Details__c,Article_type__c,ArticleTotalViewCount WHERE PublishStatus=:publishStatusOnline';
            //Querying all the knowledge articles containing the search key based on guest user and coast selected
            if(isGuest){
                query ='FIND :querySearchKey' +subquery +' AND Article_type__c IN: coasts)';
            }
            else{
                //Querying all the knowledge articles containing the search key
                query ='FIND :querySearchKey' +subquery+')';
            }
            categoryNameRecords=Search.query(query);
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return categoryNameRecords;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method is used to update the total view count of the knowledge articles viewed in UCC
     *
     * @param knowledgeArticleId record id of knowledge article
     *
     * */
    @AuraEnabled
    public static void articleViewCountUpdate(Id knowledgeArticleId){
        boolean isGuest =DH_KMUtility.getUserType();
        try{
            if(isGuest){
                Knowledge__kav updateViewCount = [SELECT Id from knowledge__kav where Id=: knowledgeArticleId WITH SECURITY_ENFORCED UPDATE VIEWSTAT];
            }
        } catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error while updating view count of Knowledge Article'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        
    }
    
    // KNOWLEDGE SEARCH METHODS END
    
    //Site Search Controller method START
    /**************************************************************************************************************************************************
     *
     * @description this method is used to send site data to site search component
     *
     *
     * @return List of options for Region, practice, sitegroup, modalities, String sitecode, String address, latitude, longitude, siteRadius
     *
     * */
    
    
    @AuraEnabled
    public static List<DH_SiteSearchController.AccountWrapper> searchSites( List<String> region, List<String> practice, List<String> sitegroup, String siteCodeOrName, String address, List<String> modality, Double Lat,Double Longt,Integer siteRadius, String selectedcoast, List<String> subModalitiesSelected) { // List<String> subModalitiesSelected
        
        List<DH_SiteSearchController.AccountWrapper> accountsToSend = new List<DH_SiteSearchController.AccountWrapper>();
        
        try{
            Boolean isModalityFilterEnabled = false;
            string miles = 'mi';
            
            String modalitiesQuery = 'SELECT Id, Name, Description__c, Specialty.name, AccountId FROM CareProviderFacilitySpecialty';
            String modalitiesSubQuery = 'SELECT Id, Name, Description__c, Specialty.name, AccountId FROM Care_Provider_Facility_Specialties';
            String modalitiesQueryGuest = 'SELECT Id, Name, DH_Description__c, DH_SpecialtyId__r.name, DH_AccountId__c FROM DH_CareProviderFacilitySpecialty__c';
            String modalitiesSubQueryGuest = 'SELECT Id, Name, DH_Description__c, DH_SpecialtyId__r.name, DH_AccountId__c FROM DH_Site_Modality__r';
            
            
            Boolean isGuestUser = DH_KMUtility.getUserType();
            
            //Modality Filter
            if ( !modality.isEmpty() ) {
                
                //site search data by its modality
                modalitiesQuery += ' WHERE Name IN :accmodality';
                modalitiesQueryGuest += ' WHERE Name IN :accmodality';
                isModalityFilterEnabled = true;
                
            }

            String subQuery = modalitiesSubQuery;
            String subQueryGuest = modalitiesSubQueryGuest;
            String shippingAddressFields = 'Site_Address__c,ShippingAddress,ShippingLatitude,ShippingLongitude,ShippingStreet,ShippingState,ShippingCity,ShippingCountry,ShippingPostalCode';
            String query = '';
            
            if(isGuestUser){
                //query for guest user for UCC
                query = 'SELECT Id, Name, Site_Group__c, Account.Site_Code__c, Alert__c, ' + shippingAddressFields + ', Phone, Fax, Scheduling_Hours__c,XR_Website__c,XR_Link_Label__c,Tax_ID__c, NPI__c, Site_Manager2__c, ( '+ subQueryGuest +' ) FROM Account';
            }
            else{
                //query for healthcloud user for Health cloud
                query = 'SELECT Id, Name, Site_Group__c, Account.Site_Code__c, Alert__c, ' + shippingAddressFields + ', Phone, Fax, Scheduling_Hours__c,XR_Website__c,XR_Link_Label__c,Tax_ID__c, NPI__c, Site_Manager2__c, ( '+ subQuery +' ) FROM Account';
            }
            query += ' WHERE RecordType.Name = :recordTypeSite';
            
            
            if(Lat!=null && Longt!=null){
                
                //return sites from radius given by user
                query +=  ' AND DISTANCE(ShippingAddress, GEOLOCATION('+ Lat+','+ Longt+'),'+'\'mi\' '+' ) < '+siteRadius+'';
            }
            
            List<String> filterQuery = new List<String>();
            if ( !region.isEmpty() ) {
                //region filter
                filterQuery.add( ' AccountRegion__r.Name IN :accregion' );
            }
            //query for guest user for selected coast as east
            if(isGuestUser && selectedcoast == DH_KMConstants.ACCOUNT_EAST_COAST){
                filterQuery.add( ' Coast__c =: accCoast' );
            }
            //query for guest user for selected coast as west
            if(isGuestUser && selectedcoast == DH_KMConstants.ACCOUNT_WEST_COAST){
                filterQuery.add( ' Coast__c =: accCoast' );
            }
            
            if ( !practice.isEmpty() ) {
                //practice filter
                if( practice.contains( DH_KMConstants.NJIN ) ){
                    practice.addAll( DH_KMUtility.virtualGroupingNJINForSiteSearch() );
                }
                filterQuery.add( ' Account_Practice__r.Name IN :accpractice' );
            }
            
            String siteGrpRegion;
            
            if ( !sitegroup.isEmpty() ) {
                siteGrpRegion = '(\'' + String.join(sitegroup, '\', \'') + '\')';
                //sitegroup filter
                filterQuery.add( ' DH_Site_Group_Region__c INCLUDES '+ siteGrpRegion + ' ');
            }
            
            if ( !String.isBlank( siteCodeOrName ) ) {
                //sitecode filter
                filterQuery.add( ' ( Site_Code__c LIKE :accsitecodeorname OR Name LIKE :accsitecodeorname ) ' );
            }
            
            if ( !filterQuery.isEmpty() ) {
                query += ' AND ( ' + String.join( filterQuery, ' AND ' ) + ' ) ';
            }
            
            Map<String, Object> acctBinds = new Map<String, Object>{
                'recordTypeSite' => 'Site',
                'accregion' => region,
                'accpractice' => practice,
                'accsitegroup' => sitegroup,
                'accsitecodeorname' => '%' + siteCodeOrName + '%',
                'accCoast' => selectedcoast
            };
            
            
            Map<String, Object> modBinds = new Map<String, Object>{ 'accmodality' => modality }; 
            List<Account> accts =  Database.queryWithBinds( query, acctBinds, AccessLevel.SYSTEM_MODE );
            
            List<sObject> modsForSiteSearch = new List<sObject>();
            
            
            if(isGuestUser){
                //query for modalities for guest user for site search
                modsForSiteSearch = Database.queryWithBinds( modalitiesQueryGuest, modBinds, AccessLevel.SYSTEM_MODE );

                Map<id,sObject> siteListForGuestUser = New Map<id,sObject>();
                if(!subModalitiesSelected.isEmpty()){
                    for(sObject modal: modsForSiteSearch){
                        
                           if(!String.isBlank(String.valueOf(modal.get('DH_Description__c')))){
                             
                            List<String> subModsStringForGuest = String.valueOf(modal.get('DH_Description__c'))?.split(';');
                          
                            for(String str : subModsStringForGuest){
                                for(String s : subModalitiesSelected){
                                    
                                    if(str.trim()==s.trim()){
                                        siteListForGuestUser.put(String.valueOf(modal.get('Id')),modal);
                                    }
                                }
                            } 
                        }
                }
                modsForSiteSearch=siteListForGuestUser.values();
            
            } 
        } else {                
                //query for modalities for healthcloud user for site search
                modsForSiteSearch = Database.queryWithBinds( modalitiesQuery, modBinds, AccessLevel.SYSTEM_MODE );

                Map<id,sObject> siteListForHCUser = New Map<id,sObject>();
                if(!subModalitiesSelected.isEmpty()){
                    for(sObject m: modsForSiteSearch){                        
                           if(!String.isBlank(String.valueOf(m.get('Description__c')))){
                             
                            List<String> subModsString = String.valueOf(m.get('Description__c'))?.split(';');
                          
                            for(String str : subModsString){
                                for(String s : subModalitiesSelected){
                                    if(str.trim()==s.trim()){
                                        siteListForHCUser.put(String.valueOf(m.get('Id')),m);
                                    }
                                }
                            } 
                        }
                }
                modsForSiteSearch=siteListForHCUser.values();
            } 
        }    

             Set<Id> modsSetOfAccountIds = new Set<Id>();
            for (sObject mod : modsForSiteSearch ) {
                id accId;
                
                if(isGuestUser){
                        modsSetOfAccountIds.add( (Id)mod.get('DH_AccountId__c') );
                    } else{
                    modsSetOfAccountIds.add( (Id)mod.get('AccountId') );
                    
                }
            }
        
            //return all filtered accounts for site search
            List<sObject> filteredAccounts = new List<sObject>();
            if(!accts.isEmpty() && accts!= null){
                for ( sObject acc : accts ) {
                    if ( isModalityFilterEnabled && !modsSetOfAccountIds.contains(acc.Id) ) {
                        continue;
                    }
                    filteredAccounts.add( acc );
                }
            }
            accountsToSend = DH_SiteSearchController.accountWrap(filteredAccounts);
        }
        catch (exception e) {
            DH_KMUtility.getException(e,'Error in sending data site search LWC component: ');
        }
        return accountsToSend;
    }

    //Site Search Controller method END
    
    //Search phone directory Controller START
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get all the region from Phone_Directory__c
     *
     * @return List of string of regions
     *
     * */
    
    public static List<String> getPhoneDirectoryRegion(){
        List<String> regionList = new List<String>();
        try{
            for(Phone_Directory__c r :[SELECT Region__c from Phone_Directory__c WITH SECURITY_ENFORCED]){
                
                if(!regionList.contains(r.Region__c)){
                    regionList.add(r.Region__c);
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error while fetching region for phone directory '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return regionList;
    }
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get all the entry point name from Phone_Directory__c
     *
     * @return List of string of all entry points
     *
     * */
    
    public static List<String> getAllEntryPointName(){
        List<String> entryPointNameList = new List<String>();
        try{
            for(Phone_Directory__c r : [SELECT Entry_Point_Name__c from Phone_Directory__c WITH SECURITY_ENFORCED]){
                entryPointNameList.add(r.Entry_Point_Name__c);
            }
        } catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error while fetching entry point '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return entryPointNameList;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get list of phone directory records on the basis of region and entry point name
     *
     * @param string region name
     *
     * @param string entry point name
     *
     * @return List of Phone_Directory__c records
     *
     * */
    public static List<Phone_Directory__c> getPhoneDirectoryRecords(String reg,String entry) {
        List<Phone_Directory__c> phoneDirectoryRecords;
        String subquery = 'SELECT Entry_Point_Name__c,Region__c,Phone_Number__c,Comments__c FROM Phone_Directory__c ';
        String query;
        try{
            if(reg!=null && entry!=null){
                query= subquery+' WHERE Region__c=:reg AND Entry_Point_Name__c=:entry WITH SECURITY_ENFORCED';
            }
            else if(reg==null && entry!=null){
                query= subquery+ 'WHERE Entry_Point_Name__c=:entry WITH SECURITY_ENFORCED';
            }
            else if(reg!=null && entry==null){
                query= subquery+ 'WHERE Region__c=:reg WITH SECURITY_ENFORCED';
            }
            else{
                query= subquery+ 'WITH SECURITY_ENFORCED';
            }
            phoneDirectoryRecords = Database.query(String.escapeSingleQuotes(query));
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error while fetching phone directory records'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return phoneDirectoryRecords;
    }
    
    //Search phone directory Controller END
    
    // Link Site Images START
    /**
     * @description                             This method is used to get the file versions
     * @param          recordId                 RecordId of the account record
     * @return         List<ContentVersion>     returns list of contentVersion attached to the account record with the given Id
     **/
    public static List<ContentVersion> getSiteImageVersionFiles(String recordId) {
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        Set<Id> contentDocumentIds = new Set<Id>();
        try{
            if(recordId.length() >0) {
                //contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId FROM   ContentDocumentLink WHERE  LinkedEntityId =: recordId WITH SECURITY_ENFORCED];
                
                for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM   ContentDocumentLink WHERE  LinkedEntityId =: recordId WITH SECURITY_ENFORCED]){
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
                
                contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension,
                                                   ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                   CreatedDate, ContentDocumentId, ContentDocument.FileType
                                                   FROM   ContentVersion 
                                                   WHERE  ContentDocumentId IN : contentDocumentIds WITH SECURITY_ENFORCED];
            }
        }
        catch(exception e){
            System.debug(LoggingLevel.ERROR,'Error while fetching file versions : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return contentVersionList;
    }
    
    // Link Site Images END
    
    // Go Live Calendar START
    
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get all the region from Go_Live_Calendar__c
     *
     * @return List of string of regions
     *
     * */
    public static List<String> getGoLiveCalendarRegion(){
        List<String> region = new List<String>();
        try{
            
            // store unique values for region
            for(Go_Live_Calendar__c r :[SELECT Region__c FROM Go_Live_Calendar__c WITH SECURITY_ENFORCED]){
                if(!region.contains(r.Region__c)){
                    region.add(r.Region__c);
                }
            }
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching region for Go live calendar : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return region ;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method is used to get event records based on title, category, region and goLive date
     *
     * @param title String of title of event
     *
     * @param category String  of category of event
     *
     * @param region String of region of event
     *
     * @param goLiveD String of goLive date of event
     *
     * @return List of Go_Live_Calendar__c records
     *
     * */
    public static List<Go_Live_Calendar__c> getGoLiveCalendarEventRecords(String title, String category,String region, String goLiveD){
        String titlePattern = '%' + title + '%';
        String categoryPattern = '%' + category + '%';
        if(category == null){
            categoryPattern='%' + '%';
        }
        if(title == null){
            titlePattern='%' + '%';
        }
        
        String regionPattern = '%' + region + '%';
        if(region=='Any' || region==null){
            regionPattern = '%' + '%';
        }
        List<Go_Live_Calendar__c> goLiveCalendarRecords = new List<Go_Live_Calendar__c>();
        String query='';
        String subqueryWithPattern='select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c like :regionPattern AND Name  like :titlePattern AND Category__c like :categoryPattern ';
        String subquery='select id,Name,Title__c,Go_Live_Date__c,Category__c, Region__c, RelatedDocumentName__c, FormatedDateTime__c  from Go_Live_Calendar__c where Region__c =: region AND Name  like :titlePattern AND Category__c like :categoryPattern';
        String securityEnforced=' WITH SECURITY_ENFORCED ORDER By CreatedDate DESC';
        try{
            if(region=='Any' || region==null) {
                // records=[select id,Title__c,Go_Live_Date__c,Category__c, Region__c  from Go_Live_Calendar__c  where Region__c like :r AND Title__c  like :t AND Category__c like :c];
                if(goLiveD == 'Any'){
                    query= subqueryWithPattern + securityEnforced;
                }
                else if(goLiveD=='Past 30 Days'){
                    query = subqueryWithPattern +'AND Go_Live_Date__c>=LAST_N_DAYS:30 and Go_Live_Date__c <TODAY' + securityEnforced;
                }
                else if(goLiveD=='Past 90 Days'){
                    query =  subqueryWithPattern + 'AND Go_Live_Date__c>=LAST_N_DAYS:90 and Go_Live_Date__c <TODAY' + securityEnforced;
                }
                else if(goLiveD=='Next 30 Days'){
                    query = subqueryWithPattern + 'AND Go_Live_Date__c <=NEXT_N_DAYS:30  and Go_Live_Date__c >TODAY' + securityEnforced;
                }
                else if(goLiveD=='Next 90 Days'){
                    query= subqueryWithPattern +'AND Go_Live_Date__c <=NEXT_N_DAYS:90  and Go_Live_Date__c >TODAY' + securityEnforced;
                }
                else if(goLiveD=='Archive(>90 Old)'){
                    query= subqueryWithPattern + 'AND Go_Live_Date__c < LAST_90_DAYS' + securityEnforced;
                }
                else{
                    query= subqueryWithPattern + securityEnforced;
                }
            }
            else{
                if(goLiveD == 'Any'){
                    query=subquery + securityEnforced;
                }
                else if(goLiveD=='Past 30 Days'){
                    query=subquery + 'AND Go_Live_Date__c >=LAST_N_DAYS:30  and Go_Live_Date__c <TODAY'+ securityEnforced;
                }
                else if(goLiveD=='Past 90 Days'){
                    query=subquery + 'AND Go_Live_Date__c >=LAST_N_DAYS:90  and Go_Live_Date__c <TODAY'+ securityEnforced;
                }
                else if(goLiveD=='Next 30 Days'){
                    query=subquery + 'AND Go_Live_Date__c <=NEXT_N_DAYS:30  and Go_Live_Date__c >TODAY'+ securityEnforced;
                }
                else if(goLiveD=='Next 90 Days'){
                    query=subquery + 'AND Go_Live_Date__c <=NEXT_N_DAYS:90  and Go_Live_Date__c >TODAY' + securityEnforced;
                }
                else if(goLiveD=='Archive(>90 Old)'){
                    
                    query=subquery + 'AND Go_Live_Date__c < LAST_90_DAYS' +securityEnforced;
                }
                else{
                    
                    query= subquery +securityEnforced;
                }
            }
            goLiveCalendarRecords = Database.query(String.escapeSingleQuotes(query));
        } catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching Go live calendar records : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return goLiveCalendarRecords;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method gets the document related to the event
     *
     * @param recordId String recordId of event
     *
     * @return List retuns the all document related to the event
     *
     * */
    
    public static List<ContentVersion> getRelatedFilesByEventRecordId(String recordId) {
        List<ID> fileIDs = new List<ID>();
        List<ContentVersion> docs = new List<ContentVersion>();
        try{
            if(recordId.length() >0) {
                for (ContentDocumentLink docLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED]) {
                    fileIDs.add(docLink.ContentDocumentId);
                }
                docs = [SELECT Id, FileType, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : fileIDs WITH SECURITY_ENFORCED LIMIT 1];
            }
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching related files for Go live Calendar : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return docs;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method checks whether the user has the given permission set
     *
     * @param permissionSetName name of the permission set
     *
     * @return List return  the permission set assignment for current user
     *
     * */
    public static List<PermissionSetAssignment> getUserInfoForPermissionSet(String permissionSetName){
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        try{
            // Query to check if the user has the specified permission set
            permissionSetList = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
                AND PermissionSet.Name = :permissionSetName WITH SECURITY_ENFORCED
            ];
            
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching user info for Go live Calendar : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return permissionSetList;
    }
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches the profile of the current user
     *
     * @return Profile return the profile of current user
     *
     * */
    public static Profile getCurrentUserProfile(){
        Profile p = new Profile();
        try{
            p = [Select Id, Name from Profile where Id =: UserInfo.getProfileId() WITH SECURITY_ENFORCED];
        }
        catch (Exception e){
            system.debug(LoggingLevel.ERROR,'Exception occured while fetching user profile for Go live Calendar : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return p;
    }
    
    // Go Live Calendar END
    
    
    // ---------------------Excel Import STARTS -------------------
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches all healthcare procedure records of given recordTypeId
     *
     * @param  healthCareProcedureRecordTypeIdKM  recordtypeId of healthcareProcedure record
     *
     * @return List of healthcare procedure records
     *
     * */
    public static List<HealthcareProcedure> getHealthcareProcedure(Id healthCareProcedureRecordTypeIdKM){
        return [Select Id, Name, IsActive, Practice_Codes__c, Modality_Codes__c, Code, Body_Parts__c, Reason_for_Exam__c, Special_Instructions__c, Modality_Codes__r.CareSpecialty_External_ID__c from HealthcareProcedure where RecordtypeId =: healthCareProcedureRecordTypeIdKM WITH SECURITY_ENFORCED];
    }
    
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches all cloned healthcare procedure records of given recordTypeId
     *
     * @param  dhhcpRecordTypeId  recordtypeId of dh_healthcareProcedureRecord__c
     *
     * @return List of dh_healthcareProcedure__c records
     *
     * */
    public static List<DH_HealthcareProcedure__c> getClonedHealthcareProcedureRecords(Id dhhcpRecordTypeId){
        return [Select Id from DH_HealthCareProcedure__c where RecordTypeId =: dhhcpRecordTypeId WITH SECURITY_ENFORCED];
    }
    
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches all cloned care specialty records having recordtype = 'KM Modality'
     *
     * @return List of dh_careSpecialty__c records
     *
     * */
    public static List<DH_CareSpecialty__c> getClonedCareSpecialties(){
        return [Select Id, DH_CareSpecialty_External_ID__c, Name from DH_CareSpecialty__c where RecordType.Name =: DH_KMConstants.EX_CARESPECIALTY_RECORDTYPE_NAME WITH SECURITY_ENFORCED];
    }
}