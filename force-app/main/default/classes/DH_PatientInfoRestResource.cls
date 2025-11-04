/******************************************************************************************************************************************************
 *
 * @Created Date    : 5/6/2024
 * @description     : APEX Restful Class to Receives a Request from RIS to process the Records in SFHC
 * @parm			:
 * TODO				:
 * @Jira Id         : CC-355
 *
 * ****************************************************************************************************************************************************/

@RestResource(urlMapping='/OrderResource/*')
global class DH_PatientInfoRestResource {
	private static final Integer MAX_PAYLOAD_SIZE = Integer.valueOf(System.label.MAX_PAYLOAD_SIZE);
	private static final String HEADER_CONTENT_TYPE = 'Content-Type';
	private static final String CONTENT_TYPE_JSON = 'application/json';

	global class Response {
		Boolean success;
		String error;
		String stacktrace;
		PatientInfoResponse data;

		public Response() {
			this.success = true;
		}

		public Response(String error) {
			this.success = false;
			this.error = error;
		}

		public Response(String error, String stacktrace) {
			this.success = false;
			this.error = error;
			this.stacktrace = stacktrace;
		}

		public Response(PatientInfoResponse data) {
			this.success = true;
			this.data = data;
		}
	}

	global class PatientInfoResponse {
		public String system_id;
		public String patient_key;
		public Id patient_id;
		public String order_key;
		public Id order_id;
		public String study_key;
		public Id study_id;
	}

	@HttpPost
	global static Response handleOrderCreation() {
		RestResponse res = RestContext.response;
		RestRequest req = RestContext.request;
		DH_PatientInfoRestResource restResourceInstance = new DH_PatientInfoRestResource();
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();
		DH_PayloadData__c pld = new DH_PayloadData__c();
		DH_PatientInfoWrapper wrapper;

		String payload = req.requestBody.toString();
		if (String.isEmpty(payload)) {
			res.statusCode = 400;
			return new Response('empty body');
		} else {
			pld.DH_Payload1__c = payload;
			insert pld;
		}
		Savepoint savepoint = Database.setSavepoint();
		Id patientID;
		Id orderID;
		Id studyId;
		String systemId;
		String patientKey;
		String orderKey;
		String studyKey;
		String errorStackTrace;
		try {
			wrapper = utilityInstance.formatJSON(payload);

			DH_RisPatientProcessor risPatientProcessor = new DH_RisPatientProcessor();
			DH_RISOrderProcessor orderInstance = new DH_RISOrderProcessor(utilityInstance);
			DH_RisStudyProcessor studyInstance = new DH_RisStudyProcessor();

			systemId = wrapper.patient.system_id;
			patientKey = wrapper.patient.data.patient_Key;
			patientID = risPatientProcessor.patientProcessor(wrapper);
			orderInstance.isOptedOutMarketingCloud = risPatientProcessor.isOptedOutMarketingCloud;
			if (wrapper.order != null) {
				orderKey = wrapper.order.data.order_key;
				orderID = orderInstance.orderProcessor(patientID, wrapper);
			}
			if (wrapper.study != null && orderID!=null) {
				studyKey = wrapper.study.data.study_key;
				studyId = studyInstance.studyProcessor(patientId, orderId, wrapper);
			}

			restResourceInstance.logPayloadData(pld, systemId, patientKey, orderKey, studyKey, null, null, String.valueOf(res.statusCode), true);
		} catch (DmlException dmle) {
           	errorStackTrace = dmle.getMessage();
			Database.rollback(savepoint);
			res.statusCode = errorStackTrace.contains('DUPLICATE_VALUE') ||errorStackTrace.contains('UNABLE_TO_LOCK_ROW')? 500 : 400;
			restResourceInstance.logPayloadData(pld, systemId, patientKey, orderKey, studyKey, dmle.getMessage(), dmle.getStackTraceString(), String.valueOf(res.statusCode), false);
			return new Response(dmle.getMessage(), dmle.getStackTraceString().replaceAll('\n', ' -> '));
		} catch (Exception e) {
			Database.rollback(savepoint);
			res.statusCode = 500;

			restResourceInstance.logPayloadData(pld, systemId, patientKey, orderKey, studyKey, e.getMessage(), e.getStackTraceString(), String.valueOf('500'), false);

			return new Response(e.getMessage());
		}

		PatientInfoResponse respdata = new PatientInfoResponse();

		respdata.system_id = wrapper.patient.system_id;
		respdata.patient_key = wrapper.patient.data.patient_key;
		respdata.patient_id = patientID;
		respdata.order_key = orderKey;
		respdata.order_id = orderID;
		respdata.study_id = studyId;
		respdata.study_key = studyKey;
		return new Response(respdata);
	}
	public void logPayloadData(DH_PayloadData__c pld, String systemId, String patientKey, String orderKey, String studyKey, String errorMessage, String traceError, String errorCode, Boolean isSuccess) {
		if (isSuccess) {
			pld.DH_Processed__c = true;
			pld.DH_Status__c = System.label.success;
		} else {
			pld.DH_Status__c = System.label.Fail;
			pld.DH_Error__c = errorMessage;
			pld.DH_OutboundResponse__c = traceError;
			pld.DH_ErrorCode__c = errorCode;
		}
		pld.Name =  System.label.ServiceName+'__ '+ patientKey;
		pld.DH_ClassName__c = DH_PatientInfoRestResource.class.getName();
		pld.DH_ServiceName__c = System.label.ServiceName;
		pld.DH_APIEndPoint__c = System.label.ServiceName;
		pld.DH_ProcessedDateTime__c = DateTime.now();
		pld.DH_SystemId__c = systemId;
		pld.DH_PatientKey__c = patientKey;
		pld.DH_OrderKey__c = orderKey;
		pld.DH_StudyKey__c = studyKey;

		if (pld != null) {
			update pld;
		}
	}
}