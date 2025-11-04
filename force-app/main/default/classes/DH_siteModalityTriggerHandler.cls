/*

 *********************************************************

Apex Class         : DH_siteModalityTriggerHandler
    
Created Date       : May 15, 2024
    
@description       : Trigger handler on Site modality object to avoid duplicates and to auto-populate name of site modality

@jiraid            : CC-104, CC-947, CC-761

 *********************************************************

 */
public without sharing class DH_siteModalityTriggerHandler {
    
    public static String careSpecialtyQuery = 'SELECT Id, name from CareSpecialty where Id in : modalityId';
    public static String duplicateSiteModalityError = System.Label.DH_DuplicateSiteModalityError;
    /**
     * @description:  check duplicates before insert
     * @param trigger.new
     **/
    public static void handleBeforeInsert(List<CareProviderFacilitySpecialty> newSiteMods){
        Set<Id> modalityId = new Set<Id>();  // used for auto updating Site modality name
        Set<Id> accountIdSet = new Set<Id>(); // used for auto updating Site modality region
        Map<String, CareProviderFacilitySpecialty> smDuplicateMap = new Map<String, CareProviderFacilitySpecialty>(); //used for site modality duplicate check
        Set<String> accountsetId =new Set<String>();
        Set<String> modalitysetId =new Set<String>();
        try{
            for(CareProviderFacilitySpecialty c: newSiteMods){  //Loop used to get all specialty ids
                modalityId.add(c.SpecialtyId);
                accountIdSet.add(c.AccountId);
            }
            List<CareSpecialty> modalityList = new List<CareSpecialty>();
            modalityList=Database.query(careSpecialtyQuery);
            Map<Id, CareSpecialty> modalityMap = new Map<Id, CareSpecialty>(modalityList); // Map created to assign name of modality to site modality
            
            List<Account> accList = new List<Account>();
            accList= [SELECT Id, name, Region__c from Account where Id in : accountIdSet];
            Map<Id,Account> accountMap = new Map<Id,Account>(accList);
            
            for(CareProviderFacilitySpecialty c: newSiteMods){ // used for auto updating Site modality name
                c.IsActive = true;
                if(c.Region__c == NULL && c.AccountId != NULL && accountMap.get(c.AccountId) != NULL){
                    c.Region__c = accountMap.get(c.AccountId)?.Region__c; //Assigning accounts region if Null
                }
                if(c.name == NULL && modalityMap.get(c.SpecialtyId) != NULL){
                    c.name = modalityMap.get(c.SpecialtyId)?.name; //adding name of site modality to its Modality name as name is mandatory
                }
                String smkey = c.AccountId+' '+c.SpecialtyId;
                if(smDuplicateMap.containskey(smkey)){
                    c.addError(duplicateSiteModalityError); //Throw error if uploading site modalities bulk and duplicates found in new site modalities
                }
                else{
                    smDuplicateMap.put(smkey,c);
                }
                accountsetId.add(c.AccountId);
                modalitysetId.add(c.SpecialtyId);
            }
            errorOnDuplicateSiteModality(smDuplicateMap, accountsetId, modalitysetId);
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error while creating site modality record'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    
    /**
     * @description:  check duplicate site modalities before update and throw error if duplicate site modality exists
     * @param trigger.new
     **/
    public static void handleBeforeUpdate(List<CareProviderFacilitySpecialty> newSiteMods, Map<Id,CareProviderFacilitySpecialty> oldMap){
        Set<Id> modalityId = new Set<Id>();  // used for auto updating Site modality name
        Map<String,CareProviderFacilitySpecialty> smDuplicateMap = new Map<String,CareProviderFacilitySpecialty>(); //used for site modality duplicate check
        Set<String> accountsetId =new Set<String>();
        Set<String> modalitysetId =new Set<String>();
        try{
            for(CareProviderFacilitySpecialty c: newSiteMods){
                modalityId.add(c.SpecialtyId);
            }
            List<CareSpecialty> modalityList = new List<CareSpecialty>();
            modalityList=Database.query(careSpecialtyQuery);
            Map<id,CareSpecialty> modalityMap = new Map<id,CareSpecialty>(modalityList);
            for(CareProviderFacilitySpecialty c: newSiteMods){ // used for auto updating Site modality name
                if(c.SpecialtyId != oldMap.get(c.Id).SpecialtyId || c.AccountId != oldMap.get(c.Id).AccountId){
                    if(modalityMap.get(c.SpecialtyId) != NULL){
                        c.name = modalityMap.get(c.SpecialtyId).name;  //assign name of new modality
                    }
                    String smkey = c.AccountId+' '+c.SpecialtyId;
                    if(smDuplicateMap.containskey(smkey)){
                        c.addError(duplicateSiteModalityError);  //Throw error if uploading site modalities bulk and duplicates found in new site modalities
                    }
                    else{
                        smDuplicateMap.put(smkey,c);
                    }
                    accountsetId.add(c.AccountId);
                    modalitysetId.add(c.SpecialtyId);
                }
            }
            errorOnDuplicateSiteModality(smDuplicateMap, accountsetId, modalitysetId);
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error while Updating record'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    
    /**
     * @description : Throw error message if any duplicate site modality present in database before Insert or update
     * @return: void
     * @throws: DMLException
     * @param smDuplicateMap
     **/
    public static void errorOnDuplicateSiteModality( Map<String,CareProviderFacilitySpecialty> smDuplicateMap, Set<String> accountsetId, Set<String> modalitysetId){
        for(CareProviderFacilitySpecialty c: [SELECT Id, AccountId, SpecialtyId 
                                              from CareProviderFacilitySpecialty 
                                              WHERE AccountId IN: accountsetId 
                                              AND SpecialtyId IN: modalitysetId]){ //used for site modality duplicate check
            String smKey=  c.AccountId+' '+c.SpecialtyId;
            CareProviderFacilitySpecialty smdetail =  smDuplicateMap.get(smKey);
            smdetail.SpecialtyId.addError(duplicateSiteModalityError);
        }
    }
    
    /**
     * @description:  Method to delete related cloned objects record of the site modality
     * @param trigger.old
     **/
    public static void handleAfterDelete(List<CareProviderFacilitySpecialty> oldSiteMods){
        try{
            Set<String> cpfsExternalIds = new Set<String>();
            if(!oldSiteMods.isEmpty()){
                for(CareProviderFacilitySpecialty sm: oldSiteMods){
                    cpfsExternalIds.add(sm.CPFS_External_Id__c) ;
                }
            }
            List<DH_CareProviderFacilitySpecialty__c> clonedRecordsToDelete = [SELECT Id, name, DH_CPFS_External_Id__c from DH_CareProviderFacilitySpecialty__c  WHERE DH_CPFS_External_Id__c IN: cpfsExternalIds];
            if(!clonedRecordsToDelete.isEmpty()){
                delete clonedRecordsToDelete; //havent checked CRUD as records need to delete even if user dont have access
            }
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error while deleting record'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    
    /**
     * @description: Method to undelete related cloned objects record of the site modality
     * @param trigger.old
     **/
    public static void handleAfterUndelete(List<CareProviderFacilitySpecialty> newSiteMods){
        try{
            Set<String> cpfsExternalIds = new Set<String>();
            if(!newSiteMods.isEmpty()){
                for(CareProviderFacilitySpecialty sm: newSiteMods){
                    cpfsExternalIds.add(sm.CPFS_External_Id__c) ;
                }
            }
            List<DH_CareProviderFacilitySpecialty__c> clonedRecordsToUndelete = [SELECT Id, name, DH_CPFS_External_Id__c from DH_CareProviderFacilitySpecialty__c  WHERE DH_CPFS_External_Id__c IN: cpfsExternalIds AND IsDeleted = TRUE ALL ROWS];
            if(!clonedRecordsToUndelete.isEmpty()){
                undelete clonedRecordsToUndelete; //havent checked CRUD as records need to restored even if user dont have access
            }
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error while undeleting record'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
}