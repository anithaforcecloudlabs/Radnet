/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServiceRisOpenPatient
* Created Date : 01-August-2024
* @description : RIS Open Patient Service class to generate url to open patient in RIS system.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ------------------------------------
* CC-505                   01-August-2024       Added invokeRisOpenPatientApi methods.
* CC-716                   21-August-2024       Updated invokeRisOpenPatientApi methods.
* CC-430                   10-September-2024    Updated invokeRisOpenPatientApi method
* CC-1268                  20-September-2024    Updated invokeRisOpenPatientApi method
* CC-1557                  06-May-2025          Updated invokeRisOpenPatientApi method
* *****************************************************************************************************************************
*/
public without sharing class DH_DexOutServiceRisOpenPatient {
    /**
	* @Jira CC-505
    * @description - This method calls the open patients in ris and log the returned URL in payload record.
    * @param       - DH_DexOutServiceRisOpenPatientRequest
    * @return      - String
	**/
    @AuraEnabled
    public static String invokeRisOpenPatientApi(DH_DexOutServiceRisOpenPatientRequest urlParametersWrapper){
        Boolean flag = false;
        DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_RisOpenPatientServiceSetting');
		Map<Integer, DH_ErrorCodeMapping__mdt> errorMapping = DH_CustomMetadataDao.getErrorCodeVsErrorMap(integrationSettingMetadata.DH_ServiceName__c);
        String accId;
        DH_DexOutGeneralServiceRequest psRequest = new DH_DexOutGeneralServiceRequest();
        DH_DexOutGeneralServiceResponse psResponse = new DH_DexOutGeneralServiceResponse();
        
        Boolean sandboxEnv = true;
        sandboxEnv = [SELECT Id, isSandbox from Organization].isSandbox;
        urlParametersWrapper.sandboxEnv = sandboxEnv;

        if(urlParametersWrapper != null && integrationSettingMetadata!=null && urlParametersWrapper.systemId != null){
            if(sandboxEnv && !urlParametersWrapper.systemId.contains('_Training')){    
                urlParametersWrapper.systemId = urlParametersWrapper.systemId+System.Label.DH_ContactCenterTestingPhaseSuffix;
            }else if(!sandboxEnv && urlParametersWrapper.systemId.contains('_Training')){
                urlParametersWrapper.systemId = urlParametersWrapper.systemId.replace(System.Label.DH_ContactCenterTestingPhaseSuffix,'');
            }            
            String userId = DH_GeneralUtility.getUserFederationId();
            String request = integrationSettingMetadata.DH_SampleRequest__c;
            String requestBody = request.replace('userFedId', userId).replace('timeout',String.valueOf(integrationSettingMetadata.DH_TimeOutInMilliseconds__c.intValue()));
            psRequest.recordId = urlParametersWrapper.recordId;
            psRequest.apiSetting=integrationSettingMetadata;
            psRequest.apiErrorSetting=errorMapping;
            psRequest.requestBody = requestBody;
            psRequest.preActionUrlParameter= urlParametersWrapper.patientKey;
            psRequest.requestUrlParameter= '&systemID='+urlParametersWrapper.systemId;
            psResponse = DH_DexOutGeneralService.invokeWebCallout(psRequest);
        }
        else{
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.serviceName = integrationSettingMetadata.DH_ServiceName__c;
            String error = urlParametersWrapper == null ? ' urlParametersWrapper,':'';
            String error2  = integrationSettingMetadata==null ?' integrationSettingMetadata,': '';
            String error3 = urlParametersWrapper.systemId == null?' urlParametersWrapper.systemId':'';
            logWrapper.errorMessage = DH_GlobalConstants.MISSING_INFO+ error + error2 + error3;
            logWrapper.RelatedTo = psRequest.recordId;
            logWrapper.ClassName = 'DH_DexOutServiceRisOpenPatient-invokeRisOpenPatientApi';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
        if (psRequest != null && psResponse != null && psResponse.statusCode == 200){
            flag = true;
            accId = DH_DexOutServiceRisOpenPatientParser.constructResponse(psResponse.response,urlParametersWrapper);
            System.enqueueJob(new DH_GeneralPayloadQueueable(psRequest,psResponse));
        }else if(psRequest != null && psResponse != null && psResponse.statusCode != 200){
            flag = false;
            psResponse = DH_DexOutRetryUtility.retryCallout(psRequest,psResponse);
        }
        if(psResponse!= null && psResponse.statusCode == 200 && flag == false){
            accId = DH_DexOutServiceRisOpenPatientParser.constructResponse(psResponse.response,urlParametersWrapper);
        }
        return accId;
    }
}