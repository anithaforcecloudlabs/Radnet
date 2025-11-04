/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisPatientSearch
* Created Date - 22-May-2024
* @description : RIS Search Patient Service class to search patient in RIS system.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-430                   22-May-2024          Added invokeRisPatientSearchApi and constructApiUrl methods.
* CC-476,CC-474            25-June-2024         Updated invokeRisPatientSearchApi method.
* CC-482,CC-507,CC-520     09-August-2024       Updated invokeRisPatientSearchApi and constructApiUrl method.
* CC-430                   10-September-2024    Updated invokeRisPatientSearchApi and constructApiUrl methods
* CC-1312                  12-September-2024    Updated invokeRisPatientSearchApi method.
* CC-1268                  20-September-2024    Updated invokeRisPatientSearchApi method
* CC-1365                  30-September-2024    Updated invokeRisPatientSearchApi method
* CC-1312,1365             10-April-2025        Updated invokeRisPatientSearchApi method 
* CC-1545                  20-April-2025        Updated constructApiUrl method
* CC-1557                  06-May-2025          Updated invokeRisPatientSearchApi method
* *****************************************************************************************************************************
*/
public class DH_DexOutServiceRisPatientSearch {
    /**
	* @Jira CC-430,CC-476,CC-474
    * @description - This method calls the search additional patients in ris api and returns the map of patient records 
                        where the key is the grouping key of the patient and value is the list of patient records which 
                        has the same grouping key and grouped in the specific order based on the criteria mentioned in CC-476,CC-474.
    * @param       - DH_DexOutServiceRisPatientSearchRequest
    * @return      - Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>
	**/
    @AuraEnabled
    public static Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> invokeRisPatientSearchApi(DH_DexOutServiceRisPatientSearchRequest urlParametersWrapper){
        Boolean flag = false;
        DH_IntegrationSetting__mdt advancePsSetting = DH_IntegrationSetting__mdt.getInstance('DH_RisAdvSearchPatientServiceSetting');
        DH_IntegrationSetting__mdt psSetting = DH_IntegrationSetting__mdt.getInstance('DH_RisSearchPatientServiceSetting');
        DH_IntegrationSetting__mdt integrationSettingMetadata = urlParametersWrapper.isAdvanceSearch == true? advancePsSetting: psSetting;
        Map<Integer, DH_ErrorCodeMapping__mdt> errorMapping = DH_CustomMetadataDao.getErrorCodeVsErrorMap(integrationSettingMetadata.DH_ServiceName__c);
        Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>> jsonResponseMap = new Map<Integer,List<DH_DexOutServiceRisPatientSearchResponse>>();
        DH_DexOutGeneralServiceRequest psRequest = new DH_DexOutGeneralServiceRequest();
        DH_DexOutGeneralServiceResponse psResponse = new DH_DexOutGeneralServiceResponse();
        List<DH_DexOutServiceRisPatientSearchResponse> emptyResponse = new List<DH_DexOutServiceRisPatientSearchResponse>();
        Boolean isValid;
        Boolean isPhoneEx = false;
        // Caller Number [ANI] is not populated during inbound call
        if((urlParametersWrapper.phoneNumber == null || urlParametersWrapper.phoneNumber == '') && urlParametersWrapper.isAdvanceSearch == false && urlParametersWrapper.callType != 'Outbound'){
            psRequest.recordId = urlParametersWrapper.recordId;
            DH_DexOutServiceRisPatientSearchResponse response = new DH_DexOutServiceRisPatientSearchResponse();
            response.errorMessage = System.Label.DH_PhoneNumberError;
            emptyResponse.add(response);
            jsonResponseMap.put(-2,emptyResponse);
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.serviceName = integrationSettingMetadata.DH_ServiceName__c;
            logWrapper.errorMessage = System.Label.DH_PhoneNumberError;
            logWrapper.RelatedTo = psRequest.recordId;
            logWrapper.ClassName = 'DH_DexOutServiceRisPatientSearch-invokeRisPatientSearchApi';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
            return jsonResponseMap;
        }
        else if(urlParametersWrapper != null && urlParametersWrapper.phoneNumber != null){
  		 if(urlParametersWrapper.phoneNumber.contains('(')){
              urlParametersWrapper.phoneNumber =urlParametersWrapper.phoneNumber.replace('(','').replace(')','').replace('-','').replace(' ','');   
             }
            isValid = DH_GeneralUtility.isValidPhNo(urlParametersWrapper.phoneNumber);
        }

        // valid request (when wrapper & metadata & system id populated)
        Boolean isValidRequest = (urlParametersWrapper != null && integrationSettingMetadata!=null && urlParametersWrapper.systemId != null && urlParametersWrapper.systemId != '');
        
        // not valid inbound senario (when Primary Search && Phone Populated && Phone Number not valid && Inbound Call) 
        Boolean isNotValidForSearchInbound = (urlParametersWrapper.isAdvanceSearch != true && urlParametersWrapper.phoneNumber != null && !isValid && urlParametersWrapper.callType == 'Inbound');
        
        // not valid outbound senario (when outbound call)
        Boolean isNotValidForSearchOutbound = (urlParametersWrapper.callType == 'Outbound');
        
        // valid senario ({Secondary Search OR (Phone Valid AND Primary Search)} AND Inbound Call)
        Boolean isValidForSearch = (((urlParametersWrapper.isAdvanceSearch == true || (urlParametersWrapper.phoneNumber != null && isValid && urlParametersWrapper.isAdvanceSearch != true))  && urlParametersWrapper.callType != 'Outbound'));
        
        Boolean sandboxEnv = true;
        sandboxEnv = [SELECT Id, isSandbox from Organization].isSandbox;
    
        if(isValidRequest && isValidForSearch){
            if(urlParametersWrapper.systemId != null && sandboxEnv && !urlParametersWrapper.systemId.contains('_Training')){
                urlParametersWrapper.systemId = urlParametersWrapper.systemId+System.Label.DH_ContactCenterTestingPhaseSuffix;
            }else if(urlParametersWrapper.systemId != null && !sandboxEnv && urlParametersWrapper.systemId.contains('_Training')){
                urlParametersWrapper.systemId = urlParametersWrapper.systemId.replace(System.Label.DH_ContactCenterTestingPhaseSuffix,'');
            }
            psRequest.recordId = urlParametersWrapper.recordId;
            psRequest.apiSetting=integrationSettingMetadata;
            psRequest.apiErrorSetting = errorMapping;
            psRequest.requestUrlParameter= constructApiUrl(urlParametersWrapper);
            psResponse = DH_DexOutGeneralService.invokeWebCallout(psRequest);
        }
        else if(isNotValidForSearchInbound){
            psRequest.recordId = urlParametersWrapper.recordId;
            DH_DexOutServiceRisPatientSearchResponse response = new DH_DexOutServiceRisPatientSearchResponse();
            response.errorMessage = System.Label.DH_InvalidPhoneNumber;
            emptyResponse.add(response);
            jsonResponseMap.put(-1,emptyResponse);
            isPhoneEx = true;
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.serviceName = integrationSettingMetadata.DH_ServiceName__c;
            logWrapper.errorMessage = System.Label.DH_InvalidPhoneNumber;
            logWrapper.RelatedTo = psRequest.recordId;
            logWrapper.ClassName = 'DH_DexOutServiceRisPatientSearch-invokeRisPatientSearchApi';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }else if(isNotValidForSearchOutbound){
            psRequest.recordId = urlParametersWrapper.recordId;
            DH_DexOutServiceRisPatientSearchResponse response = new DH_DexOutServiceRisPatientSearchResponse();
            response.errorMessage = System.Label.DH_PatientSearchPhoneErrorMessage;
            emptyResponse.add(response);
            jsonResponseMap.put(-1,emptyResponse);
            isPhoneEx = true;
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.serviceName = integrationSettingMetadata.DH_ServiceName__c;
            logWrapper.errorMessage = System.Label.DH_PatientSearchPhoneErrorMessage;
            logWrapper.RelatedTo = psRequest.recordId;
            logWrapper.ClassName = 'DH_DexOutServiceRisPatientSearch-invokeRisPatientSearchApi';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
        else if(!isValidRequest){
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.serviceName = integrationSettingMetadata.DH_ServiceName__c;
            String error = urlParametersWrapper == null ? ' urlParametersWrapper,':'';
            String error2  = integrationSettingMetadata == null ?' integrationSettingMetadata,': '';
            String error3 = urlParametersWrapper.systemId == null?' urlParametersWrapper.systemId':'';
            logWrapper.errorMessage = DH_GlobalConstants.MISSING_INFO+ error + error2 + error3;
            logWrapper.RelatedTo = psRequest.recordId;
            logWrapper.ClassName = 'DH_DexOutServiceRisPatientSearch-invokeRisPatientSearchApi';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
            isPhoneEx = true;
        }
        if (psRequest != null && psResponse != null && psResponse.statusCode == 200){
            flag = true;
            jsonResponseMap = DH_DexOutServiceRisPatientSearchParser.constructPatientData(psResponse.response);
            System.enqueueJob(new DH_GeneralPayloadQueueable(psRequest,psResponse));
        }else if(psRequest != null && psResponse != null && psResponse.statusCode != 200 && isPhoneEx == false){
            flag = false;
            psResponse = DH_DexOutRetryUtility.retryCallout(psRequest,psResponse);
        }
        if(psResponse!= null && psResponse.statusCode == 200 && flag == false){
            jsonResponseMap = DH_DexOutServiceRisPatientSearchParser.constructPatientData(psResponse.response);
        }else if(psResponse.statusCode != null && psResponse.statusCode != 200 && flag == false){
            DH_DexOutServiceRisPatientSearchResponse errorResponse = new DH_DexOutServiceRisPatientSearchResponse();
            errorResponse.errorMessage = psResponse.errorMessage;
            emptyResponse.add(errorResponse);
            jsonResponseMap.put(-1,emptyResponse);
        }
        return jsonResponseMap;
    }      
    /**
	* @Jira CC-430
    * @description - This method will construct the base url from the given parameters and returns the constructed base url.
    * @param       - String,DH_DexOutServiceRisPatientSearchRequest
    * @return      - String
	**/
    public static String constructApiUrl(DH_DexOutServiceRisPatientSearchRequest urlParametersWrapper){
        String url;
        if(urlParametersWrapper != null){
            String lastName = urlParametersWrapper.lastName != null?'&LastName='+ EncodingUtil.urlEncode(urlParametersWrapper.lastName, 'UTF-8') :'';
            String firstName = urlParametersWrapper.firstName != null?'&FirstName='+ EncodingUtil.urlEncode(urlParametersWrapper.firstName, 'UTF-8') :'';
            String phoneNumber = urlParametersWrapper.phoneNumber != null?'&PhoneNumber='+urlParametersWrapper.phoneNumber:'';
            String email = urlParametersWrapper.email != null?'&Email='+urlParametersWrapper.email:'';
            String dateOfBirth = urlParametersWrapper.dateOfBirth != null && !urlParametersWrapper.dateOfBirth.isAlphaSpace() ?'&BirthDate='+urlParametersWrapper.dateOfBirth:'';
            String patientMrn = urlParametersWrapper.patientMRN != null?'&MRN='+urlParametersWrapper.patientMRN:'';
            String accessionNumber= urlParametersWrapper.accessionNumber != null?'&AccessionNumber='+urlParametersWrapper.accessionNumber:'';
            String consVar='PageNumber=1';
            String systemId= '&SystemID='+ urlParametersWrapper.systemId;
            String parameters = systemId+lastName+firstName+phoneNumber+email+dateOfBirth+patientMrn+accessionNumber;
            url = consVar+parameters;
        }
        return url;
    }
}