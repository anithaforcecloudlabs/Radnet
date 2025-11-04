/*
* *****************************************************************************************************************************
* Apex Helper Class Name : DH_DexOutRetryUtility
* Created Date : 23-July-2024
* @description : Generic utility class for retry third party API.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* CC-482-507-520           23-July-2024         Added retryCallout method.
* CC-520                   08-August-2024       Updated retryCallout method
* CC-491                   09-September-2024    Added new retryCallout method
* *****************************************************************************************************************************
*/

public class DH_DexOutRetryUtility {
    /**
	* @Jira CC-482-507-520
    * @description    - Validate service integration setting to perform retry web callouts and enqueue payload record creation
    * @param          - DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse
    * @return         - DH_DexOutGeneralServiceResponse
    **/
    public static DH_DexOutGeneralServiceResponse retryCallout(DH_DexOutGeneralServiceRequest apiRequest,DH_DexOutGeneralServiceResponse apiResponse){
        Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest> payloadMap = new Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>();
        if(apiResponse != null && apiRequest != null && !payloadMap.containsKey(apiResponse)){
            payloadMap.put(apiResponse,apiRequest);
        }
        DH_ErrorCodeMapping__mdt errorCode = DH_CustomMetadataDao.getErrorCodeMappingList(apiRequest.apiSetting.DH_ServiceName__c,apiResponse.statusCode);
        Integer noOfRetries = 1;
        while(apiResponse.statusCode != 200 && (noOfRetries <= apiRequest.apiSetting.DH_OfRetries__c) && errorCode.DH_RetryEnabled__c == true){
            apiResponse = DH_DexOutGeneralService.invokeWebCallout(apiRequest);  
            if(apiResponse != null && apiRequest != null && !payloadMap.containsKey(apiResponse)){
                payloadMap.put(apiResponse,apiRequest);
            }
            noOfRetries++;
            if(apiRequest != null && apiResponse != null && apiResponse.statusCode == 200){
                break;
            }
            if(apiRequest != null && apiResponse != null && apiResponse.statusCode == 200){
                break;
            }
        }
        System.enqueueJob(new DH_GeneralPayloadQueueable(payloadMap));
        return apiResponse;
    }
    /**
	* @Jira CC-491
    * @description    - Validate service integration setting to perform retry web callouts and enqueue payload record creation based on the Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse>
    * @param          - Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse>
    * @return         - Map<List<DH_DexOutGeneralServiceResponse>,Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>>
    **/
    public static Map<List<DH_DexOutGeneralServiceResponse>,Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>> retryCallout(Map<DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse> retryMap){
        Map<List<DH_DexOutGeneralServiceResponse>,Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>> responseVsPayloadMap = new Map<List<DH_DexOutGeneralServiceResponse>,Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>>();
        Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest> payloadMap = new Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>();
        List<DH_DexOutGeneralServiceResponse> apiResponseList = new List<DH_DexOutGeneralServiceResponse>();
        for(DH_DexOutGeneralServiceRequest apiRequest : retryMap.keySet()){
            DH_ErrorCodeMapping__mdt errorCode = DH_CustomMetadataDao.getErrorCodeMappingList(apiRequest.apiSetting.DH_ServiceName__c,retryMap.get(apiRequest).statusCode);
            DH_DexOutGeneralServiceResponse apiResponse = retryMap.get(apiRequest);
            if(apiResponse != null && apiRequest != null && !payloadMap.containsKey(apiResponse)){
                payloadMap.put(apiResponse,apiRequest);
            }
            apiResponseList.add(retryMap.get(apiRequest));
            Integer noOfRetries = 1;
            while(apiResponse.statusCode != 200 && (noOfRetries <= apiRequest.apiSetting.DH_OfRetries__c) && errorCode.DH_RetryEnabled__c == true){
                apiResponse = DH_DexOutGeneralService.invokeWebCallout(apiRequest);  
                if(apiRequest != null && apiResponse != null && !payloadMap.containsKey(apiResponse)){
                    payloadMap.put(apiResponse,apiRequest);
                    apiResponseList.add(apiResponse);
                }
                noOfRetries++;
                if(apiRequest != null && apiResponse != null && apiResponse.statusCode == 200){
                    break;
                }
                if(apiRequest != null && apiResponse != null && apiResponse.statusCode == 200){
                    break;
                }
            }
        }
        responseVsPayloadMap.put(apiResponseList,payloadMap);
        return responseVsPayloadMap;
    }
}