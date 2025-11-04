/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServicePatientEngagement
* Created Date : 30-Jun-2024
* @description : Service class to get patient engagement details for a patient.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-702                   30-June-2024         Added invokePatientEngagementApi methods.
* CC-430                   10-September-2024    Updated invokePatientEngagementApi method
* CC-1268                  18-September-2024    Updated invokePatientEngagementApi method
* CC-1557                  06-May-2025          Updated invokePatientEngagementApi method
* *****************************************************************************************************************************
*/
public class DH_DexOutServicePatientEngagement {
    public static List<DH_DexOutServiceEngagementResponse> invokePatientEngagementApi(DH_DexOutServiceEngagementRequest engageWrapper){
        DH_IntegrationSetting__mdt quickMessageSettings = DH_IntegrationSetting__mdt.getInstance('DH_RisQuickMessageServiceSetting');
		Map<Integer, DH_ErrorCodeMapping__mdt> errorMapping = DH_CustomMetadataDao.getErrorCodeVsErrorMap(quickMessageSettings.DH_ServiceName__c);
        DH_DexOutGeneralServiceRequest quickMessageRequest = new DH_DexOutGeneralServiceRequest();
        DH_DexOutGeneralServiceResponse quickMessageResponse = new DH_DexOutGeneralServiceResponse();
        List<DH_DexOutServiceEngagementResponse> engagementList = new List<DH_DexOutServiceEngagementResponse>();
        Boolean flag = false;

        Boolean sandboxEnv = true;
        sandboxEnv = [SELECT Id, isSandbox from Organization].isSandbox;

        if(quickMessageSettings != null && engageWrapper !=null && engageWrapper.systemId != null){
            if(engageWrapper.systemId != null && sandboxEnv && !engageWrapper.systemId.contains('_Training')){    
                engageWrapper.systemId = engageWrapper.systemId+System.Label.DH_ContactCenterTestingPhaseSuffix;
            }else if(engageWrapper.systemId != null && !sandboxEnv && engageWrapper.systemId.contains('_Training')){
                engageWrapper.systemId = engageWrapper.systemId.replace(System.Label.DH_ContactCenterTestingPhaseSuffix,'');
            }            
            quickMessageRequest.apiSetting = quickMessageSettings;
            quickMessageRequest.requestBody = quickMessageSettings.DH_SampleRequest__c;
            quickMessageRequest.recordId = engageWrapper.recordId;
            quickMessageRequest.apiErrorSetting = errorMapping;
            quickMessageRequest.preActionUrlParameter= engageWrapper.patientKey;
            quickMessageRequest.requestUrlParameter= '&systemID='+ engageWrapper.systemId;
            quickMessageResponse = DH_DexOutGeneralService.invokeWebCallout(quickMessageRequest);
        }
        else{
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.serviceName = quickMessageSettings.DH_ServiceName__c;
            String error = quickMessageSettings == null ? ' quickMessageSettings,':'';
            String error2  = engageWrapper == null ?' engageWrapper,': '';
            String error3 = engageWrapper.systemId == null?' engageWrapper.systemId':'';
            logWrapper.errorMessage = DH_GlobalConstants.MISSING_INFO+ error + error2 + error3;
            logWrapper.RelatedTo = quickMessageRequest.recordId;
            logWrapper.ClassName = 'DH_DexOutServicePatientEngagement-invokePatientEngagementApi';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
        if (quickMessageRequest != null && quickMessageResponse != null && quickMessageResponse.statusCode == 200){
            flag = true;
            engagementList = DH_DexOutServicePatientEngagementParser.getEngagementList(quickMessageResponse.response);
            System.enqueueJob(new DH_GeneralPayloadQueueable(quickMessageRequest, quickMessageResponse));
        }else if(quickMessageRequest != null && quickMessageResponse != null && quickMessageResponse.statusCode != 200){
            flag = false;
            quickMessageResponse = DH_DexOutRetryUtility.retryCallout(quickMessageRequest,quickMessageResponse);
        }
        if(quickMessageRequest!= null && quickMessageResponse.statusCode == 200 && flag == false){
            engagementList = DH_DexOutServicePatientEngagementParser.getEngagementList(quickMessageResponse.response);
        }else if(quickMessageResponse.statusCode != null && quickMessageResponse.statusCode != 200 && flag == false){
            DH_DexOutServiceEngagementResponse errorResponse = new DH_DexOutServiceEngagementResponse();
            errorResponse.responseError = quickMessageResponse.errorMessage;
            engagementList.add(errorResponse);
        }
        return engagementList;
    }

}