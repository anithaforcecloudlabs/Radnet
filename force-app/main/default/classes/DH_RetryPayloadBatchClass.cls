/*
* *****************************************************************************************************************************
* Apex Class Name - DH_RetryPayloadBatchClass
* Author - Persistent
* Version - 1.0
* Created Date - 03-June-2024 
* Code Coverage - 94%
* Function - This batch class is designed to retry failed payloads by sending them to specific endpoints based on the system ID. 
It implements the `Database.Batchable`, `Database.Stateful`, and `Database.AllowsCallouts` interfaces to handle 
large data sets, maintain state across transactions, and perform HTTP callouts.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
*          03-June-2024          Initial Version 
*          06-June-2024          Batch Chaining & Custom Metadata Dynamic Binding
*           10-June-2024          Email Notification
* *****************************************************************************************************************************
*/
global class DH_RetryPayloadBatchClass implements Schedulable, Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
	/**
	 * @author   | 04-06-2024
	 * @param BatchableContext
	 * @description This method defines the query to select failed payload records for processing. It returns a `Database.QueryLocator`
	 *			   object to enable batch processing.
	 * @return `Database.Querylocator` - A query locator for batch processing.
	 **/
	global Integer regionSelector = 1;
	global String region = null;
	global Map<Id, String> failedRecordId = new Map<Id, String>();
	global Map<Integer, String> regionMap = new Map<Integer, String>();

	// Default constructor
	public DH_RetryPayloadBatchClass() {
		if(regionSelector == 1){
			fetchUniqueRegions();
		}
		region = regionMap.get(regionSelector);
	}

	public DH_RetryPayloadBatchClass(Integer selector, Map<Id, String> failed,Map<Integer, String> regMap) {
        RegionSelector = selector;
		failedRecordId = Failed;
		if(regionSelector == 1){
			fetchUniqueRegions();
        }else{
          regionMap=regMap;  
        }
		region = regionMap.get(regionSelector);
	}

	public void fetchUniqueRegions(){
		List<Account>regionAccounts = new List<Account>();
		regionAccounts = [select id,Name,Region__c from Account where RecordType.Name='RIS Instance / RIS System' order by Region__c];
		Integer Key = 1;
		for(Account region:regionAccounts){
			regionMap.put(key,region.Region__c);
			key++;
		}
	}

	public static integer noOfRetries = 3;

	global Database.Querylocator start(Database.BatchableContext bc) {
		DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_ResendToSFHealthCloud');

		NoOfRetries = (integrationSettingMetadata != null && integrationSettingMetadata.DH_OfRetries__c != null) ? Integer.valueof(integrationSettingMetadata.DH_OfRetries__c) : null;

		//string query = System.label.DH_BatchQuery;
		String query = 'SELECT Id, DH_PatientKey__c, Name,DH_OrderKey__c, DH_No_of_Attempts__c, DH_StudyKey__c, DH_SystemId__c, DH_Status__c, DH_Processed__c, DH_AvailableForRetry__c ' + 'FROM DH_PayloadData__c ' + 'WHERE DH_Status__c = \'fail\' ' + 'AND (DH_AvailableForRetry__c = True AND DH_Processed__c = false) ' + 'AND DH_SystemId__c = :Region ' + 'AND DH_PatientKey__c != null AND (DH_No_of_Attempts__c <= :NoOfRetries OR DH_No_of_Attempts__c = NULL)';
        return Database.getQueryLocator(query);
        
	}
	/**
	 * @author   | 06-03-2024
	 * @param Database.BatchableContext bc` - Provides the batch job context.
	 * 		 `List<DH_PayloadData__c> scope` - A list of `DH_PayloadData__c` records to process in the current batch.
	 * @description This method processes each batch of payload records by categorizing them based on their system ID
	 *			   and then performing HTTP callouts to retry sending the payloads to respective endpoints.
	 **/
	global void execute(Database.BatchableContext bc, List<DH_PayloadData__c> scope) {
		DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_ResendToSFHealthCloud');
		String action = integrationSettingMetadata.DH_Action__c != null ? String.valueof(integrationSettingMetadata.DH_Action__c) : null;
        
		Set<String> patientSystemId = new Set<String>();
		List<DH_PayloadData__c> recToUpdate = new List<DH_PayloadData__c>();
		Map<Id, DH_PayloadData__c> recordsToUpdate = new Map<Id, DH_PayloadData__c>();

		for (DH_PayloadData__c pld : scope) {
			String systemId = pld.DH_SystemId__c != null ? String.valueOf(pld.DH_SystemId__c) : null;
			String patientKey = (pld.DH_PatientKey__c != null && pld.DH_SystemId__c != null) ? String.valueOf(pld.DH_PatientKey__c + pld.DH_SystemId__c) : null;

			if (!patientSystemId.contains(patientKey)) {
				patientSystemId.add(patientKey);

				if (systemId.equalsIgnoreCase(Region)) {
					recToUpdate.addAll(createAndSendJsonPayload(pld,action));
				}
			}
		}
		if (recToUpdate != null) {
			recordsToUpdate.putAll(recToUpdate);
			update recordsToUpdate.values();
		}
	}
	/**
	 * @author   | 06-06-2024
	 * @param - Map<Id, DH_PayloadData__c> regionData - A map of `DH_PayloadData__c` records categorized by region.
	 *		   String region - The region identifier.
	 *		   String endpoint - The endpoint URL for the HTTP callout.
	 *	       String xApiKey - The API key for authorization (if applicable).
	 * @description This method converts the payload data to JSON and sends it to the specified endpoint via an HTTP POST request.
	 *			   It also handles the response and any potential errors.  .
	 * @returns List<DH_PayloadData__c>` - A list of `DH_PayloadData__c` records to process in the current batch.
	 **/
	public List<DH_PayloadData__c> createAndSendJsonPayload(DH_PayloadData__c record,String action) {
		List<DH_PayloadData__c> records = new List<DH_PayloadData__c>();
		List<Map<String, Object>> recordsToRetry = new List<Map<String, Object>>();
		// Populate recordsToRetry list
		Map<String, Object> recordMap = new Map<String, Object>();
		// Always add PatientKey and SystemID
		recordMap.put('PatientKey', record.DH_PatientKey__c);
		recordMap.put('SystemID', record.DH_SystemId__c);
		// Conditionally add OrderKey and StudyKey if they are not null
		if (record.DH_OrderKey__c != null) {
			recordMap.put('OrderKey', record.DH_OrderKey__c);
		}
		if (record.DH_StudyKey__c != null) {
			recordMap.put('StudyKey', record.DH_StudyKey__c);
		}
		recordsToRetry.add(recordMap);
		// Prepare payload
		Map<String, Object> payload = new Map<String, Object>{ 'data' => new Map<String, Object>{ 'RecordsToRetry' => recordsToRetry } };
		// Serialize payload to JSON
		String jsonPayload = JSON.serialize(payload);
		// Perform callout
		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:RetryAPI'+ '?action='+action+'&systemID='+record.DH_SystemId__c+'_Training');    
		req.setMethod('POST');
		//req.setHeader('Content-Type', 'application/json');
		req.setBody(jsonPayload);
		System.debug('JSON Request' + jsonPayload);
		req.setTimeout(80000); //max timeout is 120 seconds
		Http http = new Http();
		try {
			HttpResponse res = http.send(req);
			System.debug('Request--' + req);
			if (res.getStatusCode() == 200 && res.getBody() != null) {
				Records = processResponse(String.ValueOf(res.getBody()), jsonPayload, String.valueOf(res.getStatusCode()));
			}
			if (res.getStatusCode() != 200 && res.getBody() != null) {
				Records = processFailedResponse(jsonPayload, String.valueof(res.getBody()), String.valueOf(res.getStatusCode()), req.getEndpoint());
			}
		} catch (exception e) {
			system.debug(e);
		}

		return Records;
	}
	/**
	 * @author   | 06-06-2024
	 * @param String response - The HTTP response received from the endpoint.
	 *		 String jsonPayload - The JSON payload that was sent in the request.
	 * @description This method processes the successful response by updating the `DH_PayloadData__c` records with the
	 *			   response details and setting the processed flag to true.
	 * @returns List<DH_PayloadData__c>  - A list of `DH_PayloadData__c` records to process in the current batch.
	 **/
	public List<DH_PayloadData__c> processResponse(String response, String jsonPayload, String responseCode) {
		List<DH_PayloadData__c> recordsToUpdate = new List<DH_PayloadData__c>();
		String jsonString = response;
		List<Object> payload = (List<Object>) JSON.deserializeUntyped(jsonString);
		// Access the deserialized data and create a map of patient IDs and ProcessedFlag
		Map<Integer, Boolean> patientIdToProcessedFlagMap = new Map<Integer, Boolean>();
		for (Object innerListObj : payload) {
			List<Object> innerList = (List<Object>) innerListObj;
			for (Object recordObj : innerList) {
				Map<String, Object> record = (Map<String, Object>) recordObj;
				Integer patientId = (Integer) record.get('PatientKey');
				Boolean processedFlag = (Boolean) record.get('ProcessedFlag');
				patientIdToProcessedFlagMap.put(patientId, processedFlag);
			}
		}
		if (!patientIdToProcessedFlagMap.IsEmpty()) {
			Set<String> patientKeys = new Set<String>();
			for (Integer patientId : patientIdToProcessedFlagMap.keySet()) {
				patientKeys.add(String.valueOf(patientId));
			}
			DH_PayloadData__c[] payloadRecords = [SELECT Id, DH_AvailableForRetry__c, DH_SystemId__c, DH_OutboundResponse__c, DH_Processed__c, DH_ProcessedDateTime__c, DH_Status__c, DH_Error__c, DH_PatientKey__c, DH_ErrorCode__c FROM DH_PayloadData__c WHERE DH_PatientKey__c IN :patientKeys AND DH_AvailableForRetry__c = TRUE AND (DH_No_of_Attempts__c <= :NoOfRetries OR DH_No_of_Attempts__c = NULL) AND DH_SystemId__c = :Region];
			for (DH_PayloadData__c pd : payloadRecords) {
				pd.DH_OutboundResponse__c = String.valueof(response);
				Boolean isProcessed = patientIdToProcessedFlagMap.containsKey(Integer.valueOf(pd.DH_PatientKey__c)) && patientIdToProcessedFlagMap.get(Integer.valueOf(pd.DH_PatientKey__c));
				if (isProcessed) {
					pd.DH_Processed__c = true;
					pd.DH_ProcessedDateTime__c = DateTime.now();
					pd.DH_OutboundResponse__c = String.valueof(response);
					pd.DH_AvailableForRetry__c = false;
					pd.DH_ResponseCode__c = responseCode;
					pd.DH_ErrorCode__c = null;
					recordsToUpdate.add(pd);
				}
			}
		}
		return recordsToUpdate;
	}
	/**
	 * @author   | 06-06-2024
	 * @param - String request - The JSON payload that was sent in the failed request.
	 * 		   String response - The HTTP response received from the endpoint.
	 *		   Integer responseCode - The HTTP status code of the response.
	 * @description This method processes the failed response by updating the `DH_PayloadData__c` records with
	 *				   the error details, incrementing the attempt count, and setting the processed flag to false.
	 * @returns List<DH_PayloadData__c> - A list of `DH_PayloadData__c` records to process in the current batch.
	 **/
	public List<DH_PayloadData__c> processFailedResponse(String request, String response, String responseCode,String endpoint) {
        List<DH_PayloadData__c> recordsToUpdate = new List<DH_PayloadData__c>();
		String jsonString = request;
		Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
		Map<String, Object> data = (Map<String, Object>) payload.get('data');
		List<Object> recordsToRetry = (List<Object>) data.get('RecordsToRetry');
		// Access the deserialized data and create a map of patient IDs
		Set<String> patientKeys = new Set<String>();
		for (Object recordObj : recordsToRetry) {
			Map<String, Object> record = (Map<String, Object>) recordObj;
			String patientId = String.Valueof(record.get('PatientKey'));
			patientKeys.add(patientId);
		}
		if (patientKeys.isEmpty()) {
			return recordsToUpdate;
		}

		DH_PayloadData__c[] payloadRecords = [
			SELECT Id, Name, DH_No_of_Attempts__c, DH_AvailableForRetry__c, DH_OutboundResponse__c, DH_Processed__c, DH_SystemId__c, DH_ProcessedDateTime__c, DH_Status__c, DH_Error__c, DH_PatientKey__c, DH_ErrorCode__c
			FROM DH_PayloadData__c
			WHERE DH_PatientKey__c IN :patientKeys AND DH_AvailableForRetry__c = TRUE AND (DH_No_of_Attempts__c <= :NoOfRetries OR DH_No_of_Attempts__c = NULL) AND DH_SystemId__c = :region
		];

		for (DH_PayloadData__c pd : payloadRecords) {
			Decimal attemptCount = pd.DH_No_of_Attempts__c == null ? pd.DH_No_of_Attempts__c = 1 : pd.DH_No_of_Attempts__c + 1;
			pd.DH_No_of_Attempts__c = attemptCount;
			pd.DH_OutboundResponse__c = String.valueOf(response);
			pd.DH_ErrorCode__c = responseCode;
			pd.DH_Payload2__c = jsonString;
			pd.DH_APIEndPoint__c = endpoint;
			recordsToUpdate.add(pd);
			if (attemptCount >= noOfRetries && !failedRecordId.containsKey(pd.Id)) {
				failedRecordId.put(pd.Id, pd.Name);
			}
		}

		return recordsToUpdate;
	}

	global void execute(SchedulableContext sc) {
		Map<Id, String> failedRec = new Map<Id, String>();
		DH_RetryPayloadBatchClass batchInstance = new DH_RetryPayloadBatchClass( 1, FailedRec,null);
		Database.executeBatch(batchInstance, 200);
	}
	/**
	 * @author   | 06-06-2024
	 * @param Database.BatchableContext bc - Provides the batch job context.
	 * @description This method is called once at the end of the batch processing to perform any final operations or cleanup tasks.
	 * @returns: None
	 **/
	global void finish(Database.BatchableContext bc) {
		++RegionSelector;
		if (RegionSelector <= regionMap.size()) {
			Database.executeBatch(new DH_RetryPayloadBatchClass(RegionSelector, failedRecordId,regionMap), 200);
		}
		if (failedRecordId != null && !failedRecordId.isEmpty() && RegionSelector > regionMap.size()) {
			sendMail(failedRecordId);
			List<DH_PayloadData__c> recordsToUpdate = new List<DH_PayloadData__c>();
			for (DH_PayloadData__c c : [SELECT id, DH_AvailableForRetry__c FROM DH_PayloadData__c WHERE ID IN :failedRecordId.keySet()]) {
				c.DH_AvailableForRetry__c = false;
				c.DH_No_of_Attempts__c = 3;
				recordsToUpdate.add(c);
			}
			if (recordsToUpdate != null) {
				database.update(recordsToUpdate, true);
			}
		}
	}
	/**
	 * @author   | 06-06-2024
	 * @param None
	 * @description This method is used for scheduling batch class every date at 12:00 AM.
	 * @returns: None
	 */
	public static void scheduleMe() {
		System.schedule('DH_RetryPayloadBatchClass Batch - 12:00 AM', '0 0 0 * * ?', new DH_RetryPayloadBatchClass());
	}
	/**
	 * @author   | 06-06-2024
	 * @param Map of ID and Name that contains Failed Record which exceeded the maximum number of retries.
	 * @description This method is used sending email notification to the configured user for notifying the
	 *              details of failed record which exceeded the maximum number of retries.
	 * @returns: None
	 */
	public static void sendMail(Map<Id, String> failedRecordId) {
		String baseUrl = Url.getOrgDomainUrl().toExternalForm() + '/';
		DH_IntegrationSetting__mdt integrationSettingMetadata = DH_IntegrationSetting__mdt.getInstance('DH_ResendToSFHealthCloud');
		String email;
		if (integrationSettingMetadata.DH_Email__c != null && integrationSettingMetadata.DH_Email_Notification__c) {
			email = integrationSettingMetadata.DH_Email__c;
		}
		String emailBody = 'Greetings!,\n\n';
		emailBody += 'The following records have failed and have exceeded the maximum number of retries. \nPlease review and take the necessary actions:\n\n';
		Integer counter = 1;
		for (Id recordId : failedRecordId.keySet()) {
			String recordName = failedRecordId.get(recordId);
			String recordUrl = baseUrl + recordId;
			emailBody += counter + '. ' + recordName + ' - ' + recordUrl + '\n';
			counter++;
		}

		emailBody += '\n';
		emailBody += 'Thanks!';

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new List<String>{ email };
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Salesforce Support');
		mail.setSubject('Failed Payload Records');
		mail.setBccSender(false);
		mail.setPlainTextBody(emailBody);
		try {
			if (email != null) {
				Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
			}
		} catch (Exception e) {
			system.debug(e.getMessage());
		}
	}
}