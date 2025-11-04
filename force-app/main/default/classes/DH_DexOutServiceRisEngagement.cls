/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisEngagement
* Created Date - 26-Aug-2024
* @description : RIS Patient Engagement Service class to send email and SMS to RIS system
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-491                   26-Aug-2024          Original Version                  
* *****************************************************************************************************************************
*/
public class DH_DexOutServiceRisEngagement {
	/**
	* @Jira CC-491
    * @description - This method invokes the Patient Engagement API
    * @param      - DH_DexOutServiceRisEngagementRequest
	**/
    @AuraEnabled
    public static void invokeRisEngagementApi(DH_DexOutServiceRisEngagementRequest urlParametersWrapper){
        DH_IntegrationSetting__mdt integrationSetting = DH_IntegrationSetting__mdt.getInstance('DH_RisEngagementServiceSetting');
        Map<Integer, DH_ErrorCodeMapping__mdt> errorMapping = DH_CustomMetadataDao.getErrorCodeVsErrorMap(integrationSetting.DH_ServiceName__c);
        List<DH_DexOutGeneralServiceRequest> eIRequestList = new List<DH_DexOutGeneralServiceRequest>();
        DH_DexOutGeneralServiceResponse eIResponse = new DH_DexOutGeneralServiceResponse();
        List<DH_DexOutGeneralServiceResponse> eIResponseAfterRetry = new List<DH_DexOutGeneralServiceResponse>();
        List<DH_DexOutGeneralServiceResponse> eIResponseAfterRetrySuccess = new List<DH_DexOutGeneralServiceResponse>();
        Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse> eiSuccessResponseMap = new Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse>();
        Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse> eiFailureResponseMap = new Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse>();
        Map<String,String> regionVsRequestMap = new Map<String,String>(); 
        Map<List<DH_DexOutGeneralServiceResponse>,Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>> responseVsPayloadMap;
        if(urlParametersWrapper != null && integrationSetting!=null){
            regionVsRequestMap = DH_DexOutServiceRisEngagementParser.getRequestBodyList(urlParametersWrapper);
        }
        if(regionVsRequestMap != null && !regionVsRequestMap.isEmpty()){
            for(String region : regionVsRequestMap.keySet()){
                DH_DexOutGeneralServiceRequest eIRequest = new DH_DexOutGeneralServiceRequest();
                eIRequest.apiSetting = integrationSetting;
                eIRequest.apiErrorSetting = errorMapping;
                eIRequest.requestBody = regionVsRequestMap.get(region);
                eIRequest.requestUrlParameter = '&systemID=' + region;
                eIRequestList.add(eIRequest);
            }
        }
        if(eIRequestList != null && eIRequestList.size()>0){
            for(DH_DexOutGeneralServiceRequest eIRequest: eIRequestList){
                eIResponse = DH_DexOutGeneralService.invokeWebCallout(eIRequest);
                if(eIResponse.statusCode == 200 && !eiSuccessResponseMap.containsKey(eIRequest)){
                    eiSuccessResponseMap.put(eIRequest,eIResponse);
                }
                if(eIResponse.statusCode != 200 && !eiFailureResponseMap.containsKey(eIRequest)){
                    eiFailureResponseMap.put(eIRequest,eIResponse);
                }
            }
        }
        Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest> payLoadMap = new Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>();
        if (eiSuccessResponseMap != null && !eiSuccessResponseMap.isEmpty()){
            for(DH_DexOutGeneralServiceRequest request : eiSuccessResponseMap.keySet()){
                if(!payLoadMap.containsKey(eiSuccessResponseMap.get(request))){
                    payLoadMap.put(eiSuccessResponseMap.get(request),request);
                }
            }
        }
        if (eiFailureResponseMap != null && !eiFailureResponseMap.isEmpty()){
            Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse> retryMap = new Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse>();
            for(DH_DexOutGeneralServiceRequest request : eiFailureResponseMap.keySet()){
                if(request != null && eiFailureResponseMap.get(request) != null && !retryMap.containsKey(request)){
                    retryMap.put(request,eiFailureResponseMap.get(request));
                }
            }
            responseVsPayloadMap = DH_DexOutRetryUtility.retryCallout(retryMap);
        }
        if(responseVsPayloadMap != null && !responseVsPayloadMap.isEmpty()){
            for(List<DH_DexOutGeneralServiceResponse> responseList : responseVsPayloadMap.keySet()){
                if(responseList != null && !responseList.isEmpty()){
                    eIResponseAfterRetry.addAll(responseList);
                    payLoadMap.putAll(responseVsPayloadMap.get(responseList));
                }
            }
        }
        if(eIResponseAfterRetry != null && !eIResponseAfterRetry.isEmpty()){
            for(DH_DexOutGeneralServiceResponse response : eIResponseAfterRetry){
                if(response != null && response.statusCode == 200){
                    eIResponseAfterRetrySuccess.add(response);
                }
            }
            if(eIResponseAfterRetrySuccess != null){
                DH_DexOutServiceRisEngagementParser.updateSyncedEiRecords(eIResponseAfterRetrySuccess);
            }
        }
        if(eiSuccessResponseMap != null && !eiSuccessResponseMap.isEmpty()){
            DH_DexOutServiceRisEngagementParser.updateSyncedEiRecords(eiSuccessResponseMap.values());
        }
        if(payLoadMap != null && !payLoadMap.isEmpty()){
            System.enqueueJob(new DH_GeneralPayloadQueueable(payloadMap));
        }
    }
}