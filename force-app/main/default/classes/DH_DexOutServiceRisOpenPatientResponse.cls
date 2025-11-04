/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisOpenPatientResponse
* Created Date - 06-August-2024 
* @description : Response Wrapper class for DH_DexOutServiceRisOpenPatient service class.
* Modification Log :
* -------------------------------------------------------------------------------------------------------
* Jira#                          Date                 Description
* --------------------        --------------       ---------------------
* CC-505                      06-August-2024         Original Version
* CC-716                      21-August-2024         Added variables related to ris open patient.
* *********************************************************************************************************************************************
*/
public class DH_DexOutServiceRisOpenPatientResponse {
    @AuraEnabled public String url{get;set;}
    @AuraEnabled public Data data{get;set;}
    public class Data {
        @AuraEnabled public String patient_key{get;set;}
        @AuraEnabled public String first_name{get;set;}
        @AuraEnabled public String last_name{get;set;}
        @AuraEnabled public String middle_name{get;set;}
        @AuraEnabled public String patient_id{get;set;}
        @AuraEnabled public String issuer_of_patient_id{get;set;}
        @AuraEnabled public String birth_date{get;set;}
        @AuraEnabled public String gender_code{get;set;}
        @AuraEnabled public String primary_address_line1{get;set;}
        @AuraEnabled public String primary_address_line2{get;set;}
        @AuraEnabled public String primary_address_city{get;set;}
        @AuraEnabled public String primary_address_state{get;set;}
        @AuraEnabled public String primary_address_zipcode{get;set;}
        @AuraEnabled public List<PatientPhones> patientPhones{get;set;}
        @AuraEnabled public List<PatientEmailAddresses> patientEmailAddresses{get;set;}
        @AuraEnabled public List<PatientExtraInfo> patientExtraInfo{get;set;}
        @AuraEnabled public List<PatientAlert> patientAlerts{get;set;}
    }
    public class PatientPhones{
        @AuraEnabled public Integer patient_phone_key{get;set;}
        @AuraEnabled public String phone_number{get;set;}
        @AuraEnabled public String mobile_flag{get;set;}
        @AuraEnabled public String primary_flag{get;set;}
        @AuraEnabled public Integer display_order{get;set;}
    }
    public class PatientEmailAddresses{
        @AuraEnabled public Integer patient_email_key{get;set;}
        @AuraEnabled public String email_address{get;set;}
        @AuraEnabled public String primary_flag{get;set;}
        @AuraEnabled public Integer display_order{get;set;}
    }
    public class PatientExtraInfo {
		@AuraEnabled public String patient_extra_info_key;
		@AuraEnabled public String patient_extra_info_code;
		@AuraEnabled public String value;
	}
	public class PatientAlert {
		@AuraEnabled public String patient_flag_code;
	}
}