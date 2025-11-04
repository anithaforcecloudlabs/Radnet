/*
 * ***************************************************************************************************************************
 * Apex Class Name - DH_DexOutServiceRisNewPatient
 * Created Date - 27-May-2024
 * @description       : Service class which is used to make the create new patient in Ris api callout.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-426                   27-May-2024          Added invokeCreatePatientInRisApi method.
 * CC-520                   09-August-2024       Updated invokeCreatePatientInRisApi method.
 * CC-572,CC-481			12-August-2024		 Updated invokeCreatePatientInRisApi method to call DH_GeneralCaseQueueable
 * CC-481,CC-590			19-August-2024		 Updated invokeCreatePatientInRisApi method.
 * CC-430                   10-September-2024    Updated invokeCreatePatientInRisApi method
 * CC-1268                  18-September-2024    Updated invokeCreatePatientInRisApi method
 * CC-1557                  06-May-2025          Updated invokeCreatePatientInRisApi method
 * *****************************************************************************************************************************
 */
public class DH_DexOutServiceRisNewPatient {
	/**
	 * @Jira CC-426
	 * @description - This method will call the create patient in RIS api and will return the jsonResponseList.
	 * @param       - DH_DexOutServiceRisNewPatientRequest
	 * @return      - String
	 **/
	@AuraEnabled
	public static DH_DexOutGeneralServiceResponse invokeCreatePatientInRisApi(DH_DexOutServiceRisNewPatientRequest urlParametersWrapper) {
		Boolean flag = false;
		DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisNewPatientServiceSetting');
		Map<Integer, DH_ErrorCodeMapping__mdt> errorMapping = DH_CustomMetadataDao.getErrorCodeVsErrorMap(integrationSettingMetadata.DH_ServiceName__c);
		DH_DexOutGeneralServiceRequest npRequest = new DH_DexOutGeneralServiceRequest();
		DH_DexOutGeneralServiceResponse npResponse = new DH_DexOutGeneralServiceResponse();
		npRequest.patientId = urlParametersWrapper.sfId;
		npRequest.recordId = urlParametersWrapper.recordId;
		npRequest.apiSetting = integrationSettingMetadata;

        Boolean sandboxEnv = true;
        sandboxEnv = [SELECT Id, isSandbox from Organization].isSandbox;

		String request = DH_GeneralUtility.createRequestBody(npRequest);
		if (urlParametersWrapper != null && request != null && urlParametersWrapper.systemId != null) {
			if(sandboxEnv && !urlParametersWrapper.systemId.contains('_Training')){    
                urlParametersWrapper.systemId = urlParametersWrapper.systemId+System.Label.DH_ContactCenterTestingPhaseSuffix;
            }else if(!sandboxEnv && urlParametersWrapper.systemId.contains('_Training')){
                urlParametersWrapper.systemId = urlParametersWrapper.systemId.replace(System.Label.DH_ContactCenterTestingPhaseSuffix,'');
            }            			
			npRequest.requestUrlParameter = '&systemID=' + urlParametersWrapper.systemId;
			npRequest.apiErrorSetting = errorMapping;
			npRequest.requestBody = request;
			npResponse = DH_DexOutGeneralService.invokeWebCallout(npRequest);
		}
		else{
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.serviceName = integrationSettingMetadata.DH_ServiceName__c;
			String error = DH_GlobalConstants.MISSING_INFO+ urlParametersWrapper == null ? ' urlParametersWrapper,':'';
            String error2  = integrationSettingMetadata==null ?' integrationSettingMetadata,': '';
            String error3 = urlParametersWrapper.systemId == null?' urlParametersWrapper.systemId':'';
            logWrapper.errorMessage = error+error2+error3;
            logWrapper.RelatedTo = npRequest.recordId;
            logWrapper.ClassName = 'DH_DexOutServiceRisNewPatient-invokeCreatePatientInRisApi';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
		if (npRequest != null && npResponse != null && npResponse.statusCode == 200) {
			flag = true;
			System.enqueueJob(new DH_GeneralPayloadQueueable(npRequest, npResponse));
			System.enqueueJob(new DH_GeneralCaseQueueable(urlParametersWrapper.sfId, urlParametersWrapper.recordId));
		} else if (npRequest != null && npResponse != null && npResponse.statusCode != 200) {
			npResponse = DH_DexOutRetryUtility.retryCallout(npRequest, npResponse);
		}
		if (npResponse.statusCode != null && npResponse.statusCode == 500) {
            urlParametersWrapper.systemID = urlParametersWrapper.systemID.contains('_Training') ? urlParametersWrapper.systemID.split('_')[0] :urlParametersWrapper.systemID;
			Account patAccount = DH_ContactCenterQueryManager.getDefaultAccount(urlParametersWrapper.systemID);
			System.enqueueJob(new DH_GeneralCaseQueueable(patAccount.Id, urlParametersWrapper.recordId));
		}
		return npResponse;
	}
}