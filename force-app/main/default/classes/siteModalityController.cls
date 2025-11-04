/*

 *********************************************************

Apex Class         : siteModalityController
    
Created Date       : May 15, 2024
    
@description       : Controller class for site site modality related list component(siteModalityRelatedList) component on site detail page

@jiraid            : CC-104,CC-949, CC-770

 *********************************************************

 */
public with sharing  class siteModalityController {
    
    /**
     * @description     : Wrapper for Site Modality records for original and cloned object
     **/
    public class CpfsWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String specialtyName;
    }
    
    /**
     * @description     : Method to get all related sitemodality records
     * @param           : Site recordId
     * @return          : List<CpfsWrapper> to show related site modalities on account
     **/
    @AuraEnabled(cacheable=true)
    public static List<CpfsWrapper> getSiteModalities(String record){
        List<CpfsWrapper> cpfsWrapperList = new List<CpfsWrapper>();
        try{
            if(record != null && (record.length() == 18 || record.length() == 15)){
                Boolean isGuestUser = DH_KMUtility.getUserType();
                List<sObject> sitemodList = DH_KMQueryManager.getSiteModality(record, isGuestUser);
                if(isGuestUser){  //If Guest user then use cloned DH Care provider facility specialty object
                    for(sObject s: sitemodList){
                        CpfsWrapper cpfsWp =new CpfsWrapper();
                        CpfsWp.Id = (String)s.get('Id');
                        CpfsWp.name = (String)s.get('Name');
                        CpfsWp.description = (String)s.get('DH_Description__c');
                        CpfsWp.specialtyName = (String)s.getSObject('DH_SpecialtyId__r')?.get('Name');
                        cpfsWrapperList.add(CpfsWp);
                    }
                }
                else{
                    for(sObject s: sitemodList){ //If not Guest user then standard Care provider facility specialty object
                        CpfsWrapper cpfsWp =new CpfsWrapper();
                        CpfsWp.Id = (String)s.get('Id');
                        CpfsWp.name = (String)s.get('Name');
                        CpfsWp.description = (String)s.get('Description__c');
                        CpfsWp.specialtyName = (String)s.getSObject('Specialty')?.get('Name');
                        cpfsWrapperList.add(CpfsWp);
                    }
                }
            }
            return cpfsWrapperList; //all related sitemodalities on account page
        }
        catch (Exception e){
            DH_KMUtility.getException(e,'An error occurred While fetching related list : ');
        }
        return null;
    }
    
    /**
     * @description //delete site modalities
     * @param           : SiterecordId
     **/
    @AuraEnabled
    public static void deleteSiteModalityRecord(String recordId){
        try{
            if(recordId != null && (recordId.length() == 18 || recordId.length() == 15)){
                List<CareProviderFacilitySpecialty> sitemodList = DH_KMQueryManager.deleteSiteModality(recordId);
                if(!sitemodList.isEmpty()){
                    if (Schema.sObjectType.CareProviderFacilitySpecialty.isDeletable()) {
                        delete sitemodList;
                    }
                }
            }
        }
        catch (Exception e){
            DH_KMUtility.getException(e,'An error occurred While deleting site modality : ');
        }
    }
    
    /**
     * @description       : check create access for site modality, if yes then only show new button
     * * @return          : if current user have create access on site modality
     **/
    @AuraEnabled(cacheable=true)
    public static Boolean hasCreateAccess(){
        Boolean isGuestUser = DH_KMUtility.getUserType();
        Boolean createAccess = Schema.sObjectType.CareProviderFacilitySpecialty.isCreateable();
        if(isGuestUser){
            return false;
        }
        else
        {
            return createAccess;
        }
    }
    
    /**
     * @description     : check delete access for site modality, if yes then only show delete button
     * @return          : if current user have delete access on site modality
     **/
    @AuraEnabled(cacheable=true)
    public static Boolean hasDeleteAccess(){
        Boolean isGuestUser = DH_KMUtility.getUserType();
        Boolean deleteAccess = Schema.sObjectType.CareProviderFacilitySpecialty.isDeletable();
        if(isGuestUser){
            return false;
        }
        else
        {
            return deleteAccess;
        }
    }
    
    /**
     * @description     : check update access for site modality, if yes then only show edit button
     * @return          : if current user have update access on site modality
     **/
    @AuraEnabled(cacheable=true)
    public static Boolean hasUpdateAccess(){
        Boolean isGuestUser = DH_KMUtility.getUserType();
        Boolean updateAccess = Schema.sObjectType.CareProviderFacilitySpecialty.isUpdateable();
        if(isGuestUser){
            return false;
        }
        else
        {
            return updateAccess;
        }
    }
}