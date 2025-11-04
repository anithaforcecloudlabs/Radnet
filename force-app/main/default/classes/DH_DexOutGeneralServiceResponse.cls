/*
 * ***************************************************************************************************************************
 * Apex Class Name : DH_DexOutGeneralServiceResponse
 * Created Date : 12-July-2024
 * Function - Response wrapper class for DH_DexOutGeneralService utility class.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-482,CC-507,CC-520     12-July-2024         Added statusCode and response variables.
 * CC-520                   09-Aug-2024          Added errorMessage and errorRecord variables
 * ***************************************************************************************************************************
 */
public class DH_DexOutGeneralServiceResponse {
	@AuraEnabled public Integer statusCode { get; set; }
	@AuraEnabled public String response { get; set; }
	@AuraEnabled public String errorMessage { get; set; }
	@AuraEnabled public DH_ErrorCodeMapping__mdt errorRecord { get; set; }
}