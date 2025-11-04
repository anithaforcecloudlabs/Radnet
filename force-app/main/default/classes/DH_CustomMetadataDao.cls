/*
 * ***************************************************************************************************************************
 * Apex Class Name - DH_CustomMetadataDao
 * Created Date - 27-May-2024
 * @description       : Generic class to fetch custom metadata records.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * JIRA#                   Date                Description
 * ----------------       --------------       ---------------------
 * CC-425,430             27-May-2024          Added getDynamicTableColumnList and getDynamicTableColumnMap methods.
 * CC-482-507             09-August-2024       Added getErrorCodeMappingList, getErrorMap and getErrorCodeVsErrorMap.
 * CC-520                 18-Aug-2024          Added getBatchDetailsMap and getBatchDetailsList methods
 * CC-481,CC-590		  22-Aug-2024		   Added getIntegrationSetting method
 * CC-491                 10-Sep-2024          Added getAttributeLabelVsAttributeName method
 * *****************************************************************************************************************************
 */
public class DH_CustomMetadataDao {
	/**
	 * Jira# CC-425,430
	 * @description method which will return the DH_DynamicTableColumns__mdt Setting custom metadata records whose component name is same as the parameter.
	 * @param       - String
	 * @return      - List<DH_DynamicTableColumns__mdt>
	 **/
	public static List<DH_DynamicTableColumns__mdt> getDynamicTableColumnList(String component) {
		List<DH_DynamicTableColumns__mdt> cloumnList = new List<DH_DynamicTableColumns__mdt>();
		Map<String, List<DH_DynamicTableColumns__mdt>> componentVsDynamicTableColumnsMap = new Map<String, List<DH_DynamicTableColumns__mdt>>();
		if (component != null) {
			componentVsDynamicTableColumnsMap = getDynamicTableColumnMap();
		}
		if (!componentVsDynamicTableColumnsMap.isEmpty() && componentVsDynamicTableColumnsMap != null && componentVsDynamicTableColumnsMap.containsKey(component)) {
			cloumnList = componentVsDynamicTableColumnsMap.get(component);
		}
		return cloumnList;
	}
	/**
	 * Jira# CC-425,430
	 * @description method which will return a map whose key is the component name and value is the list of DH_DynamicTableColumns__mdt custom metadata records.
	 * @param       - None
	 * @return      - Map<String,List<DH_DynamicTableColumns__mdt>>
	 **/
	public static Map<String, List<DH_DynamicTableColumns__mdt>> getDynamicTableColumnMap() {
		Map<String, List<DH_DynamicTableColumns__mdt>> componentVsDynamicTableColumnsMap = new Map<String, List<DH_DynamicTableColumns__mdt>>();
		for (DH_DynamicTableColumns__mdt metadataRec : DH_DynamicTableColumns__mdt.getAll().values()) {
			if (!componentVsDynamicTableColumnsMap.containsKey(metadataRec.DH_Component__c) && metadataRec.DH_IsActive__c == true) {
				componentVsDynamicTableColumnsMap.put(metadataRec.DH_Component__c, new List<DH_DynamicTableColumns__mdt>{ metadataRec });
			} else if (componentVsDynamicTableColumnsMap.containsKey(metadataRec.DH_Component__c) && metadataRec.DH_IsActive__c == true) {
				componentVsDynamicTableColumnsMap.get(metadataRec.DH_Component__c).add(metadataRec);
			}
		}
		return componentVsDynamicTableColumnsMap;
	}

	/**
	 * Jira# CC-482,507,520
	 * @description method which will return a map whose key is the Service name and value is the list of DH_ErrorCodeMapping__mdt custom metadata records.
	 * @param       - None
	 * @return      - Map<String,List<DH_ErrorCodeMapping__mdt>>
	 **/
	public static Map<String, List<DH_ErrorCodeMapping__mdt>> getErrorMap() {
		Map<String, List<DH_ErrorCodeMapping__mdt>> componentVsDynamicTableColumnsMap = new Map<String, List<DH_ErrorCodeMapping__mdt>>();
		for (DH_ErrorCodeMapping__mdt metadataRec : DH_ErrorCodeMapping__mdt.getAll().values()) {
			if (!componentVsDynamicTableColumnsMap.containsKey(metadataRec.DH_ServiceName__c)) {
				componentVsDynamicTableColumnsMap.put(metadataRec.DH_ServiceName__c, new List<DH_ErrorCodeMapping__mdt>{ metadataRec });
			} else if (componentVsDynamicTableColumnsMap.containsKey(metadataRec.DH_ServiceName__c)) {
				componentVsDynamicTableColumnsMap.get(metadataRec.DH_ServiceName__c).add(metadataRec);
			}
		}
		return componentVsDynamicTableColumnsMap;
	}
	/**
	 * Jira# CC-482,507,520
	 * @description method which will return a map whose key is the Service name and value is the list of DH_ErrorCodeMapping__mdt custom metadata records.
	 * @param       - String serviceName
	 * @return      - Map<Integer,List<DH_ErrorCodeMapping__mdt>>
	 **/
	public static Map<Integer, DH_ErrorCodeMapping__mdt> getErrorCodeVsErrorMap(String serviceName) {
		Map<Integer, DH_ErrorCodeMapping__mdt> errorCodeVsErrorMap = new Map<Integer, DH_ErrorCodeMapping__mdt>();
		Map<String, List<DH_ErrorCodeMapping__mdt>> errorMap = getErrorMap();
		List<DH_ErrorCodeMapping__mdt> errorList;
		List<DH_ErrorCodeMapping__mdt> errorDefaultList;
		if (serviceName != null) {
			errorList = errorMap.containsKey(serviceName) ? getErrorMap().get(serviceName) : new List<DH_ErrorCodeMapping__mdt>();
			errorDefaultList = errorMap.containsKey(DH_GlobalConstants.DEFAULT_NAME) ? errorMap.get(DH_GlobalConstants.DEFAULT_NAME) : new List<DH_ErrorCodeMapping__mdt>();
			errorList.addAll(errorDefaultList);
		} else {
			errorList = errorMap.containsKey(DH_GlobalConstants.DEFAULT_NAME) ? errorMap.get(DH_GlobalConstants.DEFAULT_NAME) : new List<DH_ErrorCodeMapping__mdt>();
		}
		if (errorList != null && errorList.size() > 0) {
			for (DH_ErrorCodeMapping__mdt metadataRec : errorList) {
				Integer errorCode = Integer.valueOf(metadataRec.DH_ErrorCode__c);
				if (!errorCodeVsErrorMap.containsKey(errorCode)) {
					errorCodeVsErrorMap.put(errorCode, metadataRec);
				}
			}
		}
		return errorCodeVsErrorMap;
	}
	/**
	 * Jira# CC-482,507,520
	 * @description This method which will return the DH_ErrorCodeMapping__mdt Setting custom metadata records based on the service names and error codes
	 * @param       - String, Integer
	 * @return      - DH_ErrorCodeMapping__mdt
	 **/
	public static DH_ErrorCodeMapping__mdt getErrorCodeMappingList(String serviceName, Integer errorCode) {
		DH_ErrorCodeMapping__mdt errorCodeList = new DH_ErrorCodeMapping__mdt();
		List<DH_ErrorCodeMapping__mdt> errorList = getErrorMap().get(serviceName);
		Boolean flag = true;
		if (serviceName != null && errorCode != null && errorList != null) {
			for (DH_ErrorCodeMapping__mdt metadataRec : errorList) {
				if (metadataRec.DH_ServiceName__c == serviceName && metadataRec.DH_ErrorCode__c == errorCode) {
					errorCodeList = metadataRec;
					flag = false;
				}
			}
		}
		if (flag) {
			errorList = getErrorMap().get(DH_GlobalConstants.DEFAULT_NAME);
			for (DH_ErrorCodeMapping__mdt metadataRec : errorList) {
				if (metadataRec.DH_ErrorCode__c == errorCode) {
					errorCodeList = metadataRec;
				}
			}
		}
		return errorCodeList;
	}
	/**
	 * Jira# 520
	 * @description This method which will return the set of Error Code and Service Name where Admin Email is Enabled and Email Address is populated
	 * @param       - None
	 * @return      - Set<String>
	 **/
	public static Set<String> getErrorCodeServiceNameSet() {
		Set<String> emailEnabledRecordsSet = new Set<String>();
		for (DH_ErrorCodeMapping__mdt metadataRec : DH_ErrorCodeMapping__mdt.getAll().values()) {
			if (metadataRec.DH_AdminEmailEnabled__c == true && metadataRec.DH_AdminEmailAddress__c != null) {
				String str = Integer.valueOf(metadataRec.DH_ErrorCode__c) + '|' + metadataRec.DH_ServiceName__c;
				emailEnabledRecordsSet.add(str);
			}
		}
		return emailEnabledRecordsSet;
	}

	/**
	 * Jira# 520
	 * @description This method returns a map of Admin Email Address Versus Error Code and Error Message
	 * @param       - List<DH_PayloadData__c>
	 * @return      - Map<String,List<String>>
	 **/
	public static Map<String, List<String>> adminEmailVsErrorCodeMessage(Set<String> records) {
		List<DH_ErrorCodeMapping__mdt> metadataRecordsList = new List<DH_ErrorCodeMapping__mdt>();
		for (String record : records) {
			List<String> codeMessage = record.split('\\|', 2);
			metadataRecordsList.add(getErrorCodeMappingList(codeMessage[1], Integer.valueOf(codeMessage[0])));
		}
		Map<String, List<String>> emailVsCodeMessage = new Map<String, List<String>>();
		for (DH_ErrorCodeMapping__mdt metadataRec : metadataRecordsList) {
			List<String> emails = metadataRec.DH_AdminEmailAddress__c.split('\\,');
			String errorCodeMessage = Integer.valueOf(metadataRec.DH_ErrorCode__c) + '|' + DH_GeneralUtility.getLabelValue(metadataRec);
			for (String email : emails) {
				if (!emailVsCodeMessage.containsKey(email)) {
					List<String> lst = new List<String>();
					lst.add(errorCodeMessage);
					emailVsCodeMessage.put(email, lst);
				} else {
					List<String> lst = emailVsCodeMessage.get(email);
					lst.add(errorCodeMessage);
					emailVsCodeMessage.put(email, lst);
				}
			}
		}
		return emailVsCodeMessage;
	}
    
    /**
	 * Jira# CC-520
	 * @description method which will return the DH_BatchSettings__mdt Setting custom metadata records whose batch name is same as the parameter.
	 * @param       - String
	 * @return      - List<DH_BatchSettings__mdt>
	 **/
	public static DH_BatchSettings__mdt getBatchDetailsList(String batchName) {
		DH_BatchSettings__mdt batchSetting = new DH_BatchSettings__mdt();
        List<DH_BatchSettings__mdt> batchSettingList = new List<DH_BatchSettings__mdt>();
		Map<String, List<DH_BatchSettings__mdt>> batchNameVsBatchSettingMap = new Map<String, List<DH_BatchSettings__mdt>>();
		if (batchName != null) {
			batchNameVsBatchSettingMap = getBatchDetailsMap();
		}
		if (!batchNameVsBatchSettingMap.isEmpty() && batchNameVsBatchSettingMap != null && batchNameVsBatchSettingMap.containsKey(batchName)) {
			batchSettingList = batchNameVsBatchSettingMap.get(batchName);
		}
        for(DH_BatchSettings__mdt meatdataRec :batchSettingList ){
            if(meatdataRec.DH_BatchName__c == batchName){
                batchSetting = meatdataRec;
            }
        }
		return batchSetting;
	}
	/**
	 * Jira# CC-520
	 * @description method which will return a map whose key is the batch name and value is the list of DH_BatchSettings__mdt custom metadata records.
	 * @param       - None
	 * @return      - Map<String,List<DH_BatchSettings__mdt>>
	 **/
	public static Map<String, List<DH_BatchSettings__mdt>> getBatchDetailsMap() {
		Map<String, List<DH_BatchSettings__mdt>> batchNameVsBatchSettingMap = new Map<String, List<DH_BatchSettings__mdt>>();
		for (DH_BatchSettings__mdt metadataRec : DH_BatchSettings__mdt.getAll().values()) {
			if (!batchNameVsBatchSettingMap.containsKey(metadataRec.DH_BatchName__c)) {
				batchNameVsBatchSettingMap.put(metadataRec.DH_BatchName__c, new List<DH_BatchSettings__mdt>{ metadataRec });
			} else if (batchNameVsBatchSettingMap.containsKey(metadataRec.DH_BatchName__c)) {
				batchNameVsBatchSettingMap.get(metadataRec.DH_BatchName__c).add(metadataRec);
			}
		}
		return batchNameVsBatchSettingMap;
	}
	
	/**
    * Jira# CC-572,CC-481
    * @description method which will return a Integration Metadata 
    * @param       - String
    * @return      - DH_IntegrationSetting__mdt
    **/
	public static DH_IntegrationSetting__mdt getIntegrationSetting(String settingName) {
		DH_IntegrationSetting__mdt integrationMetadata;
		if (settingName != null) {
			integrationMetadata = [SELECT Id, DH_SampleRequest__c, DH_ServiceName__c FROM DH_IntegrationSetting__mdt WHERE DeveloperName = :settingName];
		}
		return integrationMetadata;
	}

	/**
    * Jira# CC-491
    * @description This method will return Map of Attribute Label vs Attribute Name
    * @param       - String
    * @return      - Map<String, String>
    **/
	public static Map<String, String> getAttributeLabelVsAttributeName(String componentName) {
		Map<String,String> labelVsNameMap = new Map<String,String>();
		List<DH_DynamicTableColumns__mdt> records = getDynamicTableColumnList(componentName);
		if(records != null){
			for(DH_DynamicTableColumns__mdt record : records){
				labelVsNameMap.put(record.DH_AttributeLabel__c,record.DH_AttributeName__c);
			}
		}
		return labelVsNameMap;
	}
}