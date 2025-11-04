/*
 * ***************************************************************************************************************************
 * Apex Class Name - DH_DexOutServiceRisPatientSearchRequest
 * Created Date - 23-May-2024
 * @description       : Wrapper class for DH_DexOutServiceRisPatientSearchRequest service call.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-430                   23-May-2024          Added recordId,firstName,lastName,phoneNumber,email,dateOfBirth,patientMRN,accessionNumber,accessionNumber,systemId variables.
 * CC-572                   12-Aug-2024          Added isAdvancedSearch variable
 * CC-1365 					10-Apr-2025			 Added callType variable
 * *******************************************************************************************************************************************************************
 */
public class DH_DexOutServiceRisPatientSearchRequest {
	@AuraEnabled public String recordId{get;set;}
	@AuraEnabled public String firstName{get;set;}
	@AuraEnabled public String lastName{get;set;}
	@AuraEnabled public String phoneNumber{get;set;}
	@AuraEnabled public String email{get;set;}
	@AuraEnabled public String dateOfBirth{get;set;}
	@AuraEnabled public String patientMRN{get;set;}
	@AuraEnabled public String accessionNumber{get;set;}
	@AuraEnabled public String systemId{get;set;}
	@AuraEnabled public boolean isAdvanceSearch { get; set; }
	@AuraEnabled public String queueName{get;set;}
    @AuraEnabled public String callType{get;set;}
}