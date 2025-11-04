/*
 * ***************************************************************************************************************************
 * Apex Class Name : DH_DexOutGeneralServiceRequest
 * Created Date : 12-July-2024
 * Function : Wrapper class for DH_DexOutGeneralService utility class.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-482,CC-507,CC-520     12-July-2024         Added requestUrlParameter,requestBody,apiSetting and recordId variables.
 * CC-702                   05-August-2024       Added preActionUrlParameter variable.
 * CC-520                   09-August-2024       Added apiErrorSetting variable.
 * ***************************************************************************************************************************
 */
public class DH_DexOutGeneralServiceRequest {
	@AuraEnabled public String requestUrlParameter { get; set; }
	@AuraEnabled public String requestBody { get; set; }
	@AuraEnabled public DH_IntegrationSetting__mdt apiSetting { get; set; }
	@AuraEnabled public String recordId { get; set; }
	@AuraEnabled public String preActionUrlParameter { get; set; }
	@AuraEnabled public Map<Integer, DH_ErrorCodeMapping__mdt> apiErrorSetting { get; set; }
	@AuraEnabled public DH_DynamicTableColumns__mdt dynamicSetting { get; set; }
	@AuraEnabled public String patientId { get; set; }
}