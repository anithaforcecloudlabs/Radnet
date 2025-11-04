/*
* ***************************************************************************************************************************
* Apex Class Name - DH_DexOutServiceRisEngagementParser
* Created Date - 28-Aug-2024
* @description : Parser class to parse the json request of the DH_DexOutServiceRisEngagement service class.
* Modification Log :
* ---------------------------------------------------------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-491                   30-August-2024       Original Version
* **********************************************************************************************************************************
*/
public class DH_DexOutServiceRisEngagementParser {
    /**
	* @Jira CC-491
    * @description - Wrapper class for Request Body
	**/
    public class Request {
        public List<Data> data;
    }
    /**
	* @Jira CC-491
    * @description - Wrapper class for Data Body
	**/
    public class Data {
        public String SystemId;
        public Integer PatientKey;
        public List<DH_DexOutServiceRisEIEmailRequest> Emails;
        public List<DH_DexOutServiceRisEISmsRequest> Sms;
    }
    /**
	* @Jira CC-491
    * @description - Wrapper class for Response Body
	**/
    public class ResponseData {
        public String SfId;
        public Boolean ProcessedFlag;
    }
    /**
	* @Jira CC-491
    * @description - This method will return the list of request body which shall be passed to RIS
    * @param       - DH_DexOutServiceRisEngagementRequest
    * @return      - Map<String,String>
	**/
    public static Map<String,String> getRequestBodyList(DH_DexOutServiceRisEngagementRequest eIWrap){
        Map<String,et4ae5__IndividualEmailResult__c> ierMap = DH_ContactCenterCachingUtility.getIerMap(eIWrap);
        Map<String,String> regionVsRequestBodyMap = new Map<String,String>();
        if(eIWrap != null && ierMap != null && !ierMap.isEmpty()){
            regionVsRequestBodyMap = constructRequestPayload(eIWrap,ierMap);
        }
        return regionVsRequestBodyMap;
    }
    /**
	* @Jira CC-491
    * @description - This method will create a list of requests to be sent to the RIS system
    * @param       - DH_DexOutServiceRisEngagementRequest, Map<String,et4ae5__IndividualEmailResult__c>
    * @return      - Map<String,String>
	**/
    public static Map<String,String> constructRequestPayload(DH_DexOutServiceRisEngagementRequest eIWrap, Map<String,et4ae5__IndividualEmailResult__c> ierMap){
        Map<String, List<List<EngagementInteraction>>> regionPatKeyVsEmailSmsMap = eIWrap.regionPatKeyVsEmailSmsMap;
        Map<String, Request> regionVsrequestMap = new Map<String, Request>();
        Map<String,String> regionVsJsonRequestMap = new Map<String,String>();
        for(String key : regionPatKeyVsEmailSmsMap.keySet()){
            List<String> regionPatientKey = key.split('@%',2);
            String systemId = regionPatientKey[0];
            Data patRec = createData(regionPatKeyVsEmailSmsMap, key, ierMap);
            if(regionVsrequestMap.containsKey(systemId)){
                Request req = regionVsrequestMap.get(systemId);
                List<Data> dataList = req.data;
                dataList.add(patRec);
            }else{
                Request req = new Request();
                List<Data> dataList = new List<Data>();
                dataList.add(patRec);
                req.data = dataList;
                regionVsrequestMap.put(systemId,req);
            }
        }
        for(String region : regionVsrequestMap.keySet()){
            String jsonRequest = JSON.serialize(regionVsrequestMap.get(region));
            if(region != null && jsonRequest != null){
                regionVsJsonRequestMap.put(region,jsonRequest);
            }
        }
        return regionVsJsonRequestMap;
    }
    /**
	* @Jira CC-491
    * @description - This method will create the Data Wrapper
    * @param       - Map<String, List<List<EngagementInteraction>>>, String, Map<String,et4ae5__IndividualEmailResult__c>
    * @return      - Data
	**/
    public static Data createData(Map<String, List<List<EngagementInteraction>>> regionPatKeyVsEmailSmsMap, String key,Map<String,et4ae5__IndividualEmailResult__c> ierMap){
        List<List<EngagementInteraction>> emailSmsList = regionPatKeyVsEmailSmsMap.get(key);
        List<String> regionPatientKey = key.split('@%',2);
        String systemId = regionPatientKey[0];
        Integer patientKey = Integer.valueOf(regionPatientKey[1]);
        Data patRec = new Data();
        patRec.patientKey = patientKey;
        patRec.SystemId = systemId;
        if(regionPatKeyVsEmailSmsMap.get(key)[0].size() > 0){
            Map<String, String> dynamicTableColumnMapEmail = DH_CustomMetadataDao.getAttributeLabelVsAttributeName('DH_DexOutServiceRisEIEmailRequest');
            patRec.Emails = DH_GeneralUtility.createEmailWrapper(regionPatKeyVsEmailSmsMap.get(key)[0],ierMap,dynamicTableColumnMapEmail);
        }
        if(regionPatKeyVsEmailSmsMap.get(key)[1].size() > 0){
            Map<String, String> dynamicTableColumnMapSms = DH_CustomMetadataDao.getAttributeLabelVsAttributeName('DH_DexOutServiceRisEISmsRequest');
            patRec.Sms = DH_GeneralUtility.createSmsWrapper(regionPatKeyVsEmailSmsMap.get(key)[1],dynamicTableColumnMapSms);
        }
        return patRec;
    }
    /**
	* @Jira CC-491
    * @description - This method will create a Map of EI Ids and DH_isSynced__c and send it to updateEiRecords method
    * @param       - List<DH_DexOutGeneralServiceResponse>
	**/
    public static void updateSyncedEiRecords(List<DH_DexOutGeneralServiceResponse> responseList){
        if(responseList != null && !responseList.isEmpty()){
            List<ResponseData> finalresponseList = new List<ResponseData>();
            List<List<ResponseData>> responseDataList = new List<List<ResponseData>>();
            Map<String, Boolean> eiSyncMap = new Map<String, Boolean>();
            for(DH_DexOutGeneralServiceResponse res : responseList){
                responseDataList = (List<List<ResponseData>>) JSON.deserialize(res.response, List<List<ResponseData>>.class);
                List<ResponseData> resData = responseDataList[0];
                finalresponseList.addAll(resData);
            }
            for(ResponseData data : finalresponseList){
                eiSyncMap.put(data.SfId,data.ProcessedFlag);
            }   
            updateEiRecords(eiSyncMap);
        }
    }
    /**
	 * @Jira CC-491
	 * @description - This method will update the DH_isSynced__c field of Engagement Interaction
	 * @param       - Map<String, Boolean>
	 **/
	public static void updateEiRecords(Map<String, Boolean> eiIdvsIsSyncedMap) {
		try{
            List<EngagementInteraction> updatedRecords = new List<EngagementInteraction>();
			if(eiIdvsIsSyncedMap != null){
                Map<Id, EngagementInteraction> eiRecords = DH_ContactCenterCachingUtility.getEiMap(eiIdvsIsSyncedMap.keySet());
				for(String key : eiIdvsIsSyncedMap.keySet()){
					if(eiIdvsIsSyncedMap.get(key) != null && eiIdvsIsSyncedMap.get(key)){
						EngagementInteraction ei = new EngagementInteraction();
						ei.Id = key;
						ei.DH_isSynced__c = eiIdvsIsSyncedMap.get(key);
						updatedRecords.add(ei);
					}else if(eiIdvsIsSyncedMap.get(key) != null && !eiIdvsIsSyncedMap.get(key)){
                        EngagementInteraction ei = new EngagementInteraction();
						ei.Id = key;
						ei.DH_NumberOfRetries__c = eiRecords.get(key).DH_NumberOfRetries__c + 1;
						updatedRecords.add(ei);
                    }
				}
			}
			if(updatedRecords != null && Schema.sObjectType.EngagementInteraction.isUpdateable()){
				update updatedRecords;
			}
		}catch(Exception ex){
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.Exp =  ex;
            logWrapper.ClassName = 'DH_DexOutServiceRisEngagementParser-updateEiRecords';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
		}
	}
}