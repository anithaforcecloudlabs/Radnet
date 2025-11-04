/*
 *********************************************************
Apex Class         : DH_SiteSearchController

Created Date       : May 15, 2024

@description       : Controller class for site search component(dH_siteSearch) to fetch site data

@jiraid            : CC-232, CC-945

 *********************************************************
 */


public with sharing class DH_SiteSearchController {

    /**************************************************************************************************************************************************
     *
     * @description this method is used to send site data to site search component
     *
     *
     * @return List of options for Region, practice, sitegroup, modalities, String sitecode, String address, latitude, longitude, siteRadius
     *
     * */
    @AuraEnabled
    public static  List<AccountWrapper> searchSites(List<String> region, List<String> practice, List<String> sitegroup, String siteCodeOrName, String address, List<String> modality, Double Lat, Double Longt, Integer siteRadius, String selectedcoast,List<String> subModality) { //,List<String> subModalitiesSelected
        return DH_KMQueryManager.searchSites(region, practice, sitegroup, siteCodeOrName, address, modality, Lat, Longt, siteRadius, selectedcoast, subModality); //,subModalitiesSelected

    }

    /**************************************************************************************************************************************************
     *
     * @description this Wrapper class used for create data for Account to send for site search
     *
     * */
    public class AccountWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String siteGroup;
        @AuraEnabled public String alert;
        @AuraEnabled public String phone;
        @AuraEnabled public String fax;
        @AuraEnabled public String schedulingHours;
        @AuraEnabled public String xRayHours;
        @AuraEnabled public String xrLinkLabel;
        @AuraEnabled public String taxID;
        @AuraEnabled public String npi;
        @AuraEnabled public String siteManager2;
        @AuraEnabled public String siteAddress;
        @AuraEnabled public Double ShippingLatitude;
        @AuraEnabled public Double ShippingLongitude;
        @AuraEnabled public String ShippingStreet;
        @AuraEnabled public String ShippingState;
        @AuraEnabled public String ShippingCity;
        @AuraEnabled public String ShippingCountry;
        @AuraEnabled public String ShippingPostalCode;
        @AuraEnabled public List<ModalityWrapper> careProviderFacilitySpecialties;
    }

    /**************************************************************************************************************************************************
     *
     * @description this Wrapper class used for create data for Site Moadlity (Accounts child object) to send for site search
     *
     * */
    public class ModalityWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String subModality;
    }

    /**************************************************************************************************************************************************
     *
     * @description this Method is used to assign value to Wrapper class
     *
     * */
    public static List<AccountWrapper> accountWrap(List<sObject> accList) {
        List<AccountWrapper> accWrapperList = new List<AccountWrapper>();
        try {
            Boolean isGuestUser = DH_KMUtility.getUserType();
            if (!accList.isEmpty() && accList != null) {
                for (sObject acc : accList) {
                    AccountWrapper accWrapper = new AccountWrapper();
                    accWrapper.Id = (String) acc.get('Id');
                    accWrapper.Name = (String) acc.get('Name');
                    accWrapper.siteGroup = (String) acc.get('Site_Group__c');
                    accWrapper.alert = (String) acc.get('Alert__c');
                    accWrapper.phone = (String) acc.get('Phone');
                    accWrapper.fax = (String) acc.get('Fax');
                    accWrapper.schedulingHours = (String) acc.get('Scheduling_Hours__c');
                    accWrapper.xRayHours = (String) acc.get('XR_Website__c');
                    accWrapper.xrLinkLabel= (String) acc.get('XR_Link_Label__c');
                    accWrapper.taxID = (String) acc.get('Tax_ID__c');
                    accWrapper.npi = (String) acc.get('NPI__c');
                    accWrapper.siteManager2 = (String) acc.get('Site_Manager2__c');
                    accWrapper.siteAddress = (String) acc.get('Site_Address__c');
                    accWrapper.ShippingLatitude = (Double) acc.get('ShippingLatitude');
                    accWrapper.ShippingLongitude = (Double) acc.get('ShippingLongitude');
                    accWrapper.ShippingStreet = (String) acc.get('ShippingStreet');
                    accWrapper.ShippingState = (String) acc.get('ShippingState');
                    accWrapper.ShippingCity = (String) acc.get('ShippingCity');
                    accWrapper.ShippingCountry = (String) acc.get('ShippingCountry');
                    accWrapper.ShippingPostalCode = (String) acc.get('ShippingPostalCode');
                    List<ModalityWrapper> modWrap = new List<ModalityWrapper>();
                    ModalityWrapper m;
                    if (isGuestUser) {
                        for (sObject csp : acc.getSObjects('DH_Site_Modality__r')) {
                            m = new ModalityWrapper();
                            m.name = (String) csp?.getSObject('DH_SpecialtyId__r')?.get('Name');
                            m.subModality = (String) csp?.get('DH_Description__c');
                            modWrap.add(m);
                        }
                        accWrapper.careProviderFacilitySpecialties = modWrap;
                    } else {
                        for (sObject csp : acc.getSObjects('Care_Provider_Facility_Specialties')) {
                            m = new ModalityWrapper();
                            m.name = (String) csp?.getSObject('Specialty')?.get('Name');
                            m.subModality = (String) csp?.get('Description__c');
                            modWrap.add(m);
                        }
                        accWrapper.careProviderFacilitySpecialties = modWrap;
                    }
                    accWrapperList.add(accWrapper);
                }
            }
        } catch (exception e) {
            DH_KMUtility.getException(e, 'Error in assigning account records to wrapper : ');
        }
        return accWrapperList;
    }
}