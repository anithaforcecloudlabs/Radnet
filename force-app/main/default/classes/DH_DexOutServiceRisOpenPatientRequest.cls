/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServiceRisOpenPatientRequest
* Created Date : 01-August-2024
* @description : Wrapper class to store the request data for DH_DexOutServiceRisOpenPatient.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-505                   01-August-2024       Added the recordId,patientKey,systemId,userId,expiryInSec variables.
* CC-1557                  06-May-2025          Added sandboxEnv variable
* *****************************************************************************************************************************
*/
public class DH_DexOutServiceRisOpenPatientRequest {
    @AuraEnabled public String recordId{get;set;}
    @AuraEnabled public String patientKey{get;set;}
    @AuraEnabled public String systemId{get;set;}    
    @AuraEnabled public Boolean sandboxEnv{get;set;}
}