/******************************************************************************************************************************************************
 *
 * @Created Date      :  3/30/2024
 *
 * @description       : This class serves to obtain the data for Special Accomodation and Bill search functionality in Modality Search LWC component
 *
 * @JIRA Id           :  CC-22, CC-793
 * */
public with sharing class DH_specialAccomodationAndBillController {
    
    /**************************************************************************************************************************************************
     *
     * @description this method fetches recordsHealthcarePayerNetwork for special bill table
     *
     * @param region List of String containing region
     *
     * @return List of special Bills records
     *
     * */
    @AuraEnabled(cacheable = true)
    public static List<SpecialBillsWrapper> getHealthcarePayerNetwork(List<String> region) {
        List<SpecialBillsWrapper> sbWrapperList = new List<SpecialBillsWrapper>();
        List<sObject> healthcarePayerNetworkList = new List<sObject>();
        Boolean isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false;
        try {
            if (region.size() > 0) {
                healthcarePayerNetworkList = DH_KMQueryManager.getHealthcarePayerNetworkList(region, isGuestUser);
                if(isGuestUser){
                    Map<String,List<String>> specialBillsParam = new Map<String,List<String>>();
                    specialBillsParam.put('id',new List<String>{'Id'});
                    specialBillsParam.put('payerName',new List<String>{'DH_PayerId__r','Name'});
                    specialBillsParam.put('carrierCode',new List<String>{'DH_PayerId__r','Carrier_Code_in_RIS__c'});
                    specialBillsParam.put('regionName',new List<String>{'DH_Region__r','Name'});
                    specialBillsParam.put('regionsRegion',new List<String>{'DH_Region__r','Region__c'});
                    specialBillsParam.put('modalityDescription',new List<String>{'DH_Modality_Description__c'});
                    specialBillsParam.put('examCovered',new List<String>{'DH_Exam_Covered__c'});

                    sbWrapperList = DH_KMUtility.getHealthcarePayerNetworkRecords(specialBillsParam,healthcarePayerNetworkList);

                    // for(sObject s: healthcarePayerNetworkList){
                    //     SpecialBillsWrapper specialBills= new SpecialBillsWrapper();
                    //     specialBills.id = (String)s.get('Id');
                    //     specialBills.payerName = (String)s.getSObject('DH_PayerId__r').get('Name');
                    //     specialBills.carrierCode = (String)s.getSObject('DH_PayerId__r').get('Carrier_Code_in_RIS__c');
                    //     specialBills.regionName = (String)s.getSObject('DH_Region__r').get('Name');
                    //     specialBills.regionsRegion = (String)s.getSObject('DH_Region__r').get('Region__c');
                    //     specialBills.modalityDescription = (String)s.get('DH_Modality_Description__c');
                    //     specialBills.examCovered = (String)s.get('DH_Exam_Covered__c');
                    //     sbWrapperList.add(specialBills);
                    // }
                }
                else{
                    Map<String,List<String>> specialBillsParam = new Map<String,List<String>>();
                    specialBillsParam.put('id',new List<String>{'Id'});
                    specialBillsParam.put('payerName',new List<String>{'Payer','Name'});
                    specialBillsParam.put('carrierCode',new List<String>{'Payer','Carrier_Code_in_RIS__c'});
                    specialBillsParam.put('regionName',new List<String>{'Region__r','Name'});
                    specialBillsParam.put('regionsRegion',new List<String>{'Region__r','Region__c'});
                    specialBillsParam.put('modalityDescription',new List<String>{'Modality_Description__c'});
                    specialBillsParam.put('examCovered',new List<String>{'Exam_Covered__c'});

                    sbWrapperList = DH_KMUtility.getHealthcarePayerNetworkRecords(specialBillsParam,healthcarePayerNetworkList);

                    // for(sObject s: healthcarePayerNetworkList){
                    //     SpecialBillsWrapper specialBills= new SpecialBillsWrapper();
                    //     specialBills.id = (String)s.get('Id');
                    //     specialBills.payerName = (String)s.getSObject('Payer').get('Name');
                    //     specialBills.carrierCode = (String)s.getSObject('Payer').get('Carrier_Code_in_RIS__c');
                    //     specialBills.regionName = (String)s.getSObject('Region__r').get('Name');
                    //     specialBills.regionsRegion = (String)s.getSObject('Region__r').get('Region__c');
                    //     specialBills.modalityDescription = (String)s.get('Modality_Description__c');
                    //     specialBills.examCovered = (String)s.get('Exam_Covered__c');
                    //     sbWrapperList.add(specialBills);
                    // }
                }
                
            }
        } catch (exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching HealthcarePayerNetwork for SpecialAcc_SpecialBillController ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return sbWrapperList;
    }
    /**************************************************************************************************************************************************
     *
     * @description this Wrapper class used for create data for HealthcarePayerNetwork and cloned object DH_HealthcarePayerNetwork__c
     *
     * */
    public class SpecialBillsWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String payerName;
        @AuraEnabled public String carrierCode;
        @AuraEnabled public String regionName;
        @AuraEnabled public String regionsRegion;
        @AuraEnabled public String modalityDescription;
        @AuraEnabled public String examCovered;
    }
    /**************************************************************************************************************************************************
     *
     * @description this method fetches records for special accomodation table
     *
     * @param region List of String containing region
     *
     * @return List of special accommodation records
     *
     * */
    @AuraEnabled(cacheable = true)
    public static List<SObject> getSpecialAccomodationBills(List<String> region, List<String> practice) {
        List<SObject> specialAccomodationBills = new List<SObject>();
        try {
            Boolean isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false;
            specialAccomodationBills = DH_KMQueryManager.getSpecialAccomodationBillsList(region, practice, isGuestUser);
        } catch (exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching SpecialAccomodationBills for SpecialAcc_SpecialBillController : ' + e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return specialAccomodationBills;
    }
}