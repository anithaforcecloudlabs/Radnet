/*
* *****************************************************************************************************************************
* Apex Helper Class Name - DH_DexLoggingUtility
* Created Date - 29-May-2024
* @description       : Generic utility class for logging salesforce API and DML transactions.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* CC-426                   29-May-2024          Added getStagingRecord method and Logger class.
* CC-430                   30-May-2024          Added createLogRecord method.
* CC-520				   09-Aug-2023			Added and updates existing createLogRecord methods.
* CC-716                   16-August-2024       Updated createLogRecord method.
* CC-491                   09-September-2024    Updated createLogRecord method. 
* CC-491                   09-October-2024    	Updated createLogRecord method. 
* *****************************************************************************************************************************
*/
public without sharing class DH_DexLoggingUtility {
    /**
	 * @Jira CC-716
	 * @description Wrapper class for DH_DexLoggingUtility Controller.
	 **/
	public class Logger {
		@AuraEnabled public string serviceName { get; set; }
        @AuraEnabled public String relatedTo { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
		@AuraEnabled public Exception exp { get; set; }
        @AuraEnabled public String className { get; set; }
        @AuraEnabled public String responseCode { get; set; }
        @AuraEnabled public String payload { get; set; }
	}
    /**
	* @Jira CC-426
    * @description Creates a DH_PayloadData__c record and splits JSON data across multiple fields if necessary.
    **/
    public static DH_PayloadData__c getStagingRecord(String jsonRequest){
        Integer maxSize = 131071;
        DH_PayloadData__c stagedRecord = new DH_PayloadData__c(); 
        if(jsonRequest.length() < maxSize){
            stagedRecord.DH_Payload1__c = jsonRequest;
        }else{
            stagedRecord.DH_Payload1__c = jsonRequest.subString(0,maxSize);
            jsonRequest =  jsonRequest.subString(maxSize);
            for(integer i=2 ; i<=3;i++){
                if(jsonRequest.length() < maxSize){
                    stagedRecord.put('DH_Payload'+i+'__c',jsonRequest);	
                }else{
                    stagedRecord.put('DH_Payload'+i+'__c',jsonRequest.subString(0,maxSize));
                    jsonRequest =  jsonRequest.subString(maxSize);	
                }
            }
        }
        return	stagedRecord;
    }
	/**
	 * @Jira CC-520
	 * @param - DH_DexOutGeneralServiceRequest,DH_DexOutGeneralServiceResponse
	 * @description Creates a log record for outbound API use cases.
	 **/
	public static void createLogRecord(DH_DexOutGeneralServiceRequest apiRequest, DH_DexOutGeneralServiceResponse apiResponse) {
        Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest> apiResponseVsRequestMap = new Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>();
        apiResponseVsRequestMap.put(apiResponse,apiRequest);
        createLogRecord(apiResponseVsRequestMap);
	}
    /**
	 * @Jira CC-491
	 * @param - Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest>
	 * @description Creates a log record for outbound API use cases
	 **/
	public static void createLogRecord(Map<DH_DexOutGeneralServiceResponse,DH_DexOutGeneralServiceRequest> apiResponseVsRequestMap) {
        String recordId;
        try{
            List<DH_PayloadData__c> payLoadList = new List<DH_PayloadData__c>();
            for(DH_DexOutGeneralServiceResponse apiResponse: apiResponseVsRequestMap.keySet()){
                DH_PayloadData__c payloadData = new DH_PayloadData__c();
                if (apiResponseVsRequestMap.get(apiResponse).requestBody != null) {
                    payloadData = getStagingRecord(String.valueOf(apiResponseVsRequestMap.get(apiResponse).requestBody));
                }
                if (apiResponse.response != null) {
                    payloadData.DH_OutboundResponse__c = String.valueOf(apiResponse.response);
                }
                if (apiResponseVsRequestMap.get(apiResponse).apiSetting.DH_ServiceName__c != null) {
                    payloadData.DH_ServiceName__c = apiResponseVsRequestMap.get(apiResponse).apiSetting.DH_ServiceName__c;
                }
                if (apiResponseVsRequestMap.get(apiResponse).recordId != null) {
                    payloadData.DH_RelatedTo__c = apiResponseVsRequestMap.get(apiResponse).recordId;
                    recordId = apiResponseVsRequestMap.get(apiResponse).recordId;
                }
                if (apiResponseVsRequestMap.get(apiResponse).requestUrlParameter != null) {
                    payloadData.DH_APIEndPoint__c = 'callout:' + apiResponseVsRequestMap.get(apiResponse).apiSetting.DH_NameCredential__c + '/' + apiResponseVsRequestMap.get(apiResponse).requestUrlParameter;
                }else{
                    payloadData.DH_APIEndPoint__c = 'callout:' + apiResponseVsRequestMap.get(apiResponse).apiSetting.DH_NameCredential__c + '/';
                }
                if (apiResponse.statusCode != null) {
                    payloadData.DH_Status__c = apiResponse.statusCode == 200 ? DH_GlobalConstants.SUCCESS : DH_GlobalConstants.FAILURE;
                }
                if (apiResponse.statusCode != null) {
                    payloadData.DH_ResponseCode__c = String.valueOf(apiResponse.statusCode);
                }
                if (Schema.sObjectType.DH_PayloadData__c.isCreateable()) {
                    payLoadList.add(payloadData);
                }
            }
            insert payLoadList;
        }catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'e.getMessage()' + e.getMessage());
            DH_DexLoggingUtility.Logger log = new DH_DexLoggingUtility.Logger();
			log.exp = e;
			log.className = 'DH_DexLoggingUtility/createLogRecord';
            log.relatedTo = recordId;
			createLogRecord(log);
        }
    }
    /**
	 * @Jira CC-716
	 * @description - Creates a log record for dml exception.
	 * @param       - DH_DexLoggingUtility.Logger
	**/
    @AuraEnabled
	public static void createLogRecord(DH_DexLoggingUtility.Logger log) {
		DH_PayloadData__c payloadData = new DH_PayloadData__c();
		try {
			if (log != null) {
				payloadData.DH_ServiceName__c = log.serviceName != null ? log.serviceName : DH_GlobalConstants.DML_EXCEPTION;
                payloadData.DH_Error__c = log.exp != null ? log.exp.getMessage() : log.errorMessage;
				payloadData.DH_ClassName__c = log.className;
				payloadData.DH_RelatedTo__c = log.relatedTo;
                payloadData.DH_ResponseCode__c = log.responseCode;
                payloadData.DH_Payload1__c = log.payload != null ? log.payload : null;
			}
			if (payloadData != null && Schema.sObjectType.DH_PayloadData__c.isCreateable()) {
				insert payloadData;
			}
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'ex.getMessage()' + ex.getMessage());
		}
	}
}