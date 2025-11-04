/*
 * ***************************************************************************************************************************
 * Apex Class Name : DH_DexOutGeneralService
 * Created Date : 12-July-2024
 * @description : Service class which is used to send and receive the api callout.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-482,CC-507,CC-520     12-July-2024         Added invokeWebCallout method.
 * CC - 572                 08-August-2024       Update invokeWebCallout to assign errorMessage and errorRecord
 * CC-1247  				04-September-2024    Updated invokeWebCallout method for exception handling 
 * *****************************************************************************************************************************
 */
public class DH_DexOutGeneralService {
    /**
     * @Jira CC-482-507-520
     * @description   - Generic method used to make api callout based on DH_DexOutGeneralServiceRequest request
     * @param         - DH_DexOutGeneralServiceRequest
     * @return        - DH_DexOutGeneralServiceResponse
     **/
    public static DH_DexOutGeneralServiceResponse invokeWebCallout(DH_DexOutGeneralServiceRequest httpRequestParameters) {
        DH_DexOutGeneralServiceResponse responseWrapper = new DH_DexOutGeneralServiceResponse();
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        try {
            HttpRequest request = new HttpRequest();
            if (httpRequestParameters != null) {
                if (httpRequestParameters.requestUrlParameter != null && httpRequestParameters.preActionUrlParameter == null && httpRequestParameters.apiSetting.DH_Action__c == null) {
                    request.setEndpoint('callout:' + httpRequestParameters.apiSetting.DH_NameCredential__c + '/' + httpRequestParameters.requestUrlParameter);
                } else if (httpRequestParameters.requestUrlParameter != null && httpRequestParameters.preActionUrlParameter != null && httpRequestParameters.apiSetting.DH_Action__c != null) {
                    request.setEndpoint('callout:' + httpRequestParameters.apiSetting.DH_NameCredential__c + '/' + httpRequestParameters.preActionUrlParameter + '?action=' + httpRequestParameters.apiSetting.DH_Action__c + httpRequestParameters.requestUrlParameter);
                } else if (httpRequestParameters.requestUrlParameter != null && httpRequestParameters.preActionUrlParameter == null && httpRequestParameters.apiSetting.DH_Action__c != null) {
                    request.setEndpoint('callout:' + httpRequestParameters.apiSetting.DH_NameCredential__c + '?action=' + httpRequestParameters.apiSetting.DH_Action__c + httpRequestParameters.requestUrlParameter);
                } else if (httpRequestParameters.requestUrlParameter == null) {
                    request.setEndpoint('callout:' + httpRequestParameters.apiSetting.DH_NameCredential__c);
                }
                if (httpRequestParameters.apiSetting.DH_Method__c != null) {
                    request.setMethod(httpRequestParameters.apiSetting.DH_Method__c);
                }
                if (httpRequestParameters.requestBody != null) {
                    request.setBody(httpRequestParameters.requestBody);
                }
                if (httpRequestParameters.apiSetting.DH_TimeOutInMilliseconds__c != null) {
                    request.setTimeout(Integer.valueOf(httpRequestParameters.apiSetting.DH_TimeOutInMilliseconds__c));
                }
            }
            response = http.send(request);
            responseWrapper.response = response.getBody();
            responseWrapper.statusCode = response.getStatusCode();
            responseWrapper.errorMessage = DH_GeneralUtility.getLabelValue(httpRequestParameters.apiErrorSetting.get(response.getStatusCode()));
            responseWrapper.errorRecord = httpRequestParameters.apiErrorSetting.get(response.getStatusCode());
        } catch (Exception ex) {
			boolean timeOut = ex.getMessage()==DH_GlobalConstants.TIMEOUT_ERROR ? true:false;
			responseWrapper.statusCode = timeOut?-1:-100; 
			responseWrapper.errorMessage = DH_GeneralUtility.getLabelValue(httpRequestParameters.apiErrorSetting.get(responseWrapper.statusCode)); 
            responseWrapper.response = ex.getMessage() + ':' + ex.getStackTraceString();
			responseWrapper.errorRecord = httpRequestParameters.apiErrorSetting.get(responseWrapper.statusCode);
        }
        return responseWrapper;
    }
}