/**
*********************************************************

Apex Class         : DH_HealthcarePayerNetworkTrigger_Handler

Created Date       : July 03, 2024

@description       : Handler class for trigger on HealthcarePayerNetwork object, deletes/ undeletes HealthcarePayerNetwork_clone object record when HealthcarePayerNetwork object reocrd deleted/ undeleted

@jiraid            : CC-793

*********************************************************
**/
public with sharing class DH_HealthcarePayerNetworkTrigger_Handler {

    //Delete cloned object record if HealthcarePayerNetwork object records gets deleted
    public static void handleAfterDelete(List<HealthcarePayerNetwork> oldSpecialBills){
        Set<String> specialBillsExternalIds = new Set<String>();
        if(!oldSpecialBills.isEmpty()){
        for(HealthcarePayerNetwork sb: oldSpecialBills){
            specialBillsExternalIds.add(sb.External_Id__c) ;
        } 
      }
        List<DH_HealthcarePayerNetwork__c> clonedRecordsToDelete = [SELECT Id, Name, DH_External_Id__c from DH_HealthcarePayerNetwork__c  WHERE DH_External_Id__c IN: specialBillsExternalIds];
        if(!clonedRecordsToDelete.isEmpty()){
            try{
                delete clonedRecordsToDelete; //havent checked CRUD as records need to delete even if user dont have access
            }
            catch(DmlException e){
                System.debug('Error while deleting record'+e.getMessage());
            }
        }
    }
    
    //UnDelete cloned object record if HealthcarePayerNetwork object records gets deleted
    public static void handleAfterUndelete(List<HealthcarePayerNetwork> newSpecialBills){
        Set<String> specialBillsExternalIds = new Set<String>(); 
        if(!newSpecialBills.isEmpty()){
        for(HealthcarePayerNetwork sb: newSpecialBills){
            specialBillsExternalIds.add(sb.External_Id__c) ;
        }
      }
        List<DH_HealthcarePayerNetwork__c> clonedRecordsToUndelete = [SELECT Id, Name, DH_External_Id__c from DH_HealthcarePayerNetwork__c  WHERE DH_External_Id__c IN: specialBillsExternalIds AND IsDeleted = TRUE ALL ROWS];
        if(!clonedRecordsToUndelete.isEmpty()){
            try{
                undelete clonedRecordsToUndelete; //havent checked CRUD as records need to restored even if user dont have access
            }
            catch(DmlException e){
                System.debug('Error while undeleting record'+e.getMessage());
            }
        }
    }
}