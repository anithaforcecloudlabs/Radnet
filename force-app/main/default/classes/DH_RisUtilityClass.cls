/******************************************************************************************************************************************************
 *
 * @Created Date    :  6/12/2024
 * @description     : DH_RisUtilityClass Class is a Code Re-Useability Class to send Data/Fomatted JSON to Patient,Order and Study Classes
 * @parm			:
 * TODO				:
 * @Jira Id         : CC-355
 *
 * ****************************************************************************************************************************************************/

public class DH_RisUtilityClass extends DH_RisBaseProcessor {
	public static String CONTACT_TYPE = 'Content-Type';
	public static String APP_JSON = 'application/json';

	public DH_RisUtilityClass() {
		super();
	}
	public String uniqueIdentifier(String SystemId, String Key, String RecordTypeName) {
		String uniqueIdentifier;

		uniqueIdentifier = systemId + '_' + key + '_' + recordTypeName;

		return uniqueIdentifier;
	}
	public String fourKeysUnique(String SystemId, String patientKey, String Key, String RecordTypeName) {
		String uniqueIdentifer = SystemId + '_' + patientKey + '_' + Key + '_' + RecordTypeName;

		return uniqueIdentifer;
	}

	public DH_PatientInfoWrapper formatJSON(String data) {
		String formatedData = data.replaceAll('billing_code.billing_code', 'orderbilling_code')
			.replaceAll('billing_code.description', 'orderdescription')
			.replaceAll('procedure_code.procedure_code', 'ProcedureCode')
			.replaceAll('procedure_code.description', 'Description')
			.replaceAll('procedure_code.procedure_group_code', 'groupCode')
			.replaceAll('body_part_code.body_part_code', 'bodyPartCode')
			.replaceAll('laterality_code.laterality_code', 'lateralitycode')
			.replaceAll('name_suffix_code.patient_suffix_code', 'suffixCode')
			.replaceAll('scheduled_modality_code.modality_code', 'scheduled_modality_code');

		DH_PatientInfoWrapper wrapper = (DH_PatientInfoWrapper) JSON.deserialize(formatedData, DH_PatientInfoWrapper.class);

		return wrapper;
	}
	public Id fetchRegion(String region) {
		String query = region;
		String recordTypeName = system.label.DH_AccountRegionRecordTypeName;

		Account[] accountRegion = [SELECT Id, Name FROM Account WHERE Region__c = :query AND RecordType.Name = :RecordTypeName];

		if (accountRegion.size() > 0) {
			return accountRegion[0].Id;
		} else {
			return null;
		}
	}
	public Id fetchPractice(String risRegion, String practice) {
		String region = risRegion;
		String practiceCode = practice;
		String practiceRecordType = system.label.DH_practiceRecordtTypeName;
		String queryGen = region + '_' + practiceCode + '_' + practiceRecordType;
		String query = queryGen;

		Account[] practiceAccount = [SELECT Id, Name, DH_RIS_Unique_Code__c FROM Account WHERE DH_RIS_Unique_Code__c = :query AND RecordType.Name = :practiceRecordType];

		if (practiceAccount.size() > 0) {
			return practiceAccount[0].Id;
		} else {
			return null;
		}
	}

	public Id fetchSite(String risRegion, String site) {
		String region = risRegion;
		String siteCode = site;
		String siteRecordType = system.label.DH_siteRecordTypeName;
		String queryGen = region + '_' + siteCode + '_' + siteRecordType;
		String query = queryGen;

		Account[] siteAccount = [SELECT id, Name, Site_Code__c, DH_RIS_Unique_Code__c FROM Account WHERE DH_RIS_Unique_Code__c = :query AND RecordType.name = :siteRecordType];

		if (siteAccount.size() > 0) {
			return siteAccount[0].Id;
		} else {
			return null;
		}
	}

	public Map<String, Id> fetchCodeSetRecordIds(DH_PatientInfoWrapper wrapper) {
		List<CodeSet> queryCodeSetRecords = new List<CodeSet>();
		Map<String, Id> codeSetRecordsMap = new Map<String, id>();

		String patientClassCode;
		String orderCategoryCode;
		String followUpCode;
		String cancelledReasonCode;

		if (wrapper.patient.system_id != null && wrapper.order != null) {
			patientClassCode = wrapper.patient.system_id + '_' + wrapper.order.data.patient_class_code + '_' + system.label.DH_Patient_Class;
		}
		if (wrapper.patient.system_id != null && wrapper.order != null) {
			orderCategoryCode = wrapper.patient.system_id + '_' + wrapper.order.data.order_category_code + '_' + System.label.DH_Order_Category;
		}
		if (wrapper.patient.system_id != null && wrapper.order != null) {
			followUpCode = wrapper.patient.system_id + '_' + wrapper.order.data.scheduling_next_fup_type_code + '_' + System.label.DH_FollowUp_Type;
		}
		if (wrapper.patient.system_id != null && wrapper.study != null) {
			cancelledReasonCode = wrapper.patient.system_id + '_' + wrapper.study.data.cancelled_reason_code + '_' + System.label.DH_Cancelled_Reason_Code;
		}
		queryCodeSetRecords = [SELECT Id, Name, DH_RIS_Instance__c, Code, DH_code__c FROM CodeSet WHERE Code = :patientClassCode OR Code = :orderCategoryCode OR Code = :followUpCode OR code = :cancelledReasonCode];

		if (!queryCodeSetRecords.isempty()) {
			for (CodeSet codes : queryCodeSetRecords) {
				if (codes.Code == patientClassCode) {
					codeSetRecordsMap.put(wrapper.order.data.patient_class_code, codes.Id);
				} else if (codes.Code == orderCategoryCode) {
					codeSetRecordsMap.put(wrapper.order.data.order_category_code, codes.Id);
				} else if (codes.Code == followUpCode) {
					codeSetRecordsMap.put(wrapper.order.data.scheduling_next_fup_type_code, codes.Id);
				} else if (codes.Code == cancelledReasonCode) {
					codeSetRecordsMap.put(wrapper.study.data.cancelled_reason_code, codes.Id);
				}
			}
		}
		return codeSetRecordsMap;
	}
}