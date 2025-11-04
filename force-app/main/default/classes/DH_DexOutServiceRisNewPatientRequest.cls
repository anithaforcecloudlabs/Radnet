/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisNewPatientRequest
* Created Date - 30-May-2024
* @description       : Wrapper class for DH_DexOutServiceRisPatientSearch service class.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-426                   30-May-2024          Added Parameters,Data,PatienClass class and recordId,
                                                userID,expiryInSeconds,firstName,lastName,phoneNumber,emailAddress variables.
* CC-520                   09-August-2024       Added systemID
* CC-572                   12-August-2024       Added sfId,isAdvanceSearch,dateOfBirth,accessionNumber,patientMRN variables
* CC-520                   13-August-2024       Updated sfId
* ***************************************************************************************************************************
*/
public class DH_DexOutServiceRisNewPatientRequest {
	@AuraEnabled public String recordId {get;set;}
	@AuraEnabled public String systemID{get;set;}
	@AuraEnabled public String sfId { get; set; }
	@AuraEnabled public Parameters parameters {get;set;}
	
	/**
	 * Jira# CC-426
	 * @description Class to store the data of Parameters class.
	 **/
	public class Parameters{
		@AuraEnabled public Data data {get;set;}
	}
	/**
	 * Jira# CC-426
	 * @description Class to store the data of Data class variables.
	 **/
	public class Data {
		@AuraEnabled public String expiryInSeconds { get; set; }
		@AuraEnabled public PatientClass patient { get; set; }
		@AuraEnabled public String userID { get; set; }
	}
	/**
	 * Jira# CC-426,CC-572
	 * @description Class to store the data of PatientClass class variables.
	 **/
	public class PatientClass {
		@AuraEnabled public String firstName { get; set; }
		@AuraEnabled public String lastName { get; set; }
		@AuraEnabled public String phoneNumber { get; set; }
		@AuraEnabled public String emailAddress { get; set; }
		@AuraEnabled public String dateOfBirth { get; set; }
		@AuraEnabled public String accessionNumber { get; set; }
		@AuraEnabled public String patientMRN { get; set; }
	}
}