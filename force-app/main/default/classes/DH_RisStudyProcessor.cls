/******************************************************************************************************************************************************
 *
 * @Created Date    :  7/5/2024,
 * @description     : DH_RisStudyProcessor Class receives a parsed JSON request and Processes Study and it's realted  Object Records in SFHC
 * @parm			:
 * TODO				:
 * @Jira Id         : CC-355
 *
 * ****************************************************************************************************************************************************/

public class DH_RisStudyProcessor {
	private static final String STATE_MODIFIED = 'modified';

	private Map<String, Id> getCancelledReasonCode(DH_PatientInfoWrapper wrapper) {
		Map<String, Id> codeSetRecordsToReturn = new Map<String, Id>();
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		Map<String, Id> codeSetRecords = utility.fetchCodeSetRecordIds(wrapper);

		List<CodeSet> cancelledReasonRecordToInsert = new List<CodeSet>();
		if (codeSetRecords.get(wrapper.study.data.cancelled_reason_code) == null && wrapper.study.data.cancelled_reason_code != null && !Test.isRunningTest()) {
			CodeSet cancelledCode = new Codeset();
			cancelledCode.Name = wrapper.study.data.cancelled_reason_code;
			cancelledCode.DH_RIS_Instance__c = wrapper.patient.system_id;
			cancelledCode.DH_Code__c = wrapper.study.data.cancelled_reason_code;
			cancelledCode.DH_RISCodeset__c = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.cancelled_reason_code, system.label.DH_Cancelled_Reason_Code);
			cancelledCode.RecordTypeId = Schema.SObjectType.CodeSet.getRecordTypeInfosByName().get(System.label.DH_Cancelled_Reason_Code).getRecordTypeId();
			cancelledReasonRecordToInsert.add(cancelledCode);

			if (cancelledReasonRecordToInsert != null) {
				insert cancelledReasonRecordToInsert;
			}
		}
		for (codeSet codes : cancelledReasonRecordToInsert) {
			codeSetRecordsToReturn.put(codes.DH_Code__c, codes.Id);
		}

		for (String codekey : codeSetRecords.keySet()) {
			codeSetRecordsToReturn.put(codekey, codeSetRecords.get(codekey));
		}
		return codeSetRecordsToReturn;
	}

	public Map<String, Id> modalityProcessor(Id SystemId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		String regionKey = wrapper.patient.system_id;

		// unique List for modalities
		set<String> uniqueModalities = new Set<String>();
		Id modalityRecordTypeId = Schema.SObjectType.CareSpecialty.getRecordTypeInfosByName().get(system.label.DH_ModalityRecordTypeName).getRecordTypeId();

		for (DH_PatientInfoWrapper.cls_studyItems procedureCode : wrapper.study.data.studyItems) {
			uniqueModalities.add(wrapper.patient.System_id + '_' + procedureCode.groupCode);
		}

		List<CareSpecialty> existingModalities = [SELECT Id, Name, DH_Region_Instance__c, SpecialtyCode, DH_SFMC_Speciality_Code__c,CareSpecialty_External_ID__c FROM CareSpecialty WHERE SpecialtyCode IN :UniqueModalities AND RecordTypeId = :modalityRecordTypeId];
		map<String, CareSpecialty> existingModalitiesMap = new Map<String, CareSpecialty>();
		for (CareSpecialty existingModality : existingModalities) {
			existingModalitiesMap.put(existingModality.SpecialtyCode, existingModality);
		}
		map<String, CareSpecialty> carespecialityMapToUpsert = new Map<String, CareSpecialty>();
		List<CareSpecialty> modalityListToInsert = new List<CareSpecialty>();
		for (DH_PatientInfoWrapper.cls_studyItems procedureCode : wrapper.study.data.studyItems) {
			if (procedureCode.groupCode != null) {
				string uniqueCode = wrapper.patient.System_id + '_' + procedureCode.groupCode;
				CareSpecialty cs = new CareSpecialty();
				cs.Name = procedureCode.groupCode;
				cs.DH_RIS_Code__c = uniqueCode;
				cs.SpecialtyCode = uniqueCode;
				cs.CareSpecialty_External_ID__c = uniqueCode;
				cs.DH_Region_Instance__c = SystemId != null ? SystemId : null;
				cs.DH_SFMC_Speciality_Code__c = procedureCode.groupCode;
				cs.RecordTypeId = modalityRecordTypeId;
				cs.isActive = true;
				if (!existingModalitiesMap.containsKey(uniqueCode)) {
					modalityListToInsert.add(cs);
				}
			}
		}
		if (modalityListToInsert.size() > 0) {
			insert modalityListToInsert;
		}
		Map<String, Id> modalityMapToReturn = new Map<String, Id>();
		for (CareSpecialty cs : modalityListToInsert) {
			modalityMapToReturn.put(cs.CareSpecialty_External_ID__c, cs.Id);
		}
        
	   for (CareSpecialty cs : existingModalitiesMap.values()) {
			modalityMapToReturn.put(cs.CareSpecialty_External_ID__c, cs.Id);
		}
		return modalityMapToReturn;
	}
	private Map<String, Id> procedureProcessor(Id systemID, DH_PatientInfoWrapper wrapper) {
		Map<String, Id> modalities = modalityProcessor(systemID, wrapper);
		Id hcpRecordTypeId = Schema.SObjectType.HealthCareProcedure.getRecordTypeInfosByName().get(system.label.DH_hcpRecordType).getRecordTypeId();

		List<String> uniqueHealthcareProcedures = new List<String>();
		for (DH_PatientInfoWrapper.cls_studyItems procedureCode : wrapper.study.data.studyItems) {
			uniqueHealthcareProcedures.add(wrapper.patient.System_id + '_' + procedureCode.ProcedureCode);
		}

		List<HealthCareProcedure> existingHealthcareProcedureList = [SELECT Id, DH_RIS_Healthcare_Procedure__c, DH_Region_Instance__c, Code, CodeDescription, IsActive,DH_Body_Part_Code__c,DH_Laterality_Code__c,DH_Procedure_Group_Code__c FROM HealthCareProcedure WHERE DH_RIS_Healthcare_Procedure__c IN :uniqueHealthcareProcedures AND RecordTypeId = :hcpRecordTypeId];
		Map<String, HealthCareProcedure> procedureCodeIterateMap = new Map<String, HealthCareProcedure>();
		for (HealthCareProcedure existingHealthcareProcedure : existingHealthcareProcedureList) {
			procedureCodeIterateMap.put(existingHealthcareProcedure.DH_RIS_Healthcare_Procedure__c, existingHealthcareProcedure);
		}
		List<HealthCareProcedure> procedureListToInsert = new List<HealthCareProcedure>();
		//Map<String, HealthCareProcedure> procedureMapToUpsert = new Map<String, HealthCareProcedure>();
		for (DH_PatientInfoWrapper.cls_studyItems procedureCode : wrapper.study.data.studyItems) {
			if (procedureCode.procedureCode != null) {
				String uniqueCode = wrapper.patient.System_id + '_' + procedureCode.ProcedureCode;
				String uniqueModality = wrapper.Patient.System_Id + '_' + ProcedureCode.GroupCode;
				if (!procedureCodeIterateMap.containsKey(uniqueCode)) {
					HealthCareProcedure hcp = new HealthCareProcedure();
					hcp.Name = procedureCode.ProcedureCode + '_' + procedureCode.Description;
					hcp.DH_RIS_Healthcare_Procedure__c = uniqueCode;
					hcp.Modality_Codes__c = !modalities.isempty() ? modalities.get(uniqueModality) : null;
					hcp.DH_Region_Instance__c = systemID;
					hcp.Code = procedureCode.ProcedureCode;
					hcp.CodeDescription = procedureCode.Description;
					hcp.IsActive = procedureCode.active_flag != null && procedureCode.active_flag == 'Y' ? true : false;
					hcp.DH_Body_Part_Code__c = procedureCode.bodyPartCode;
					hcp.DH_Laterality_Code__c = procedureCode.lateralitycode;
					hcp.RecordTypeId = hcpRecordTypeId;
                    hcp.DH_Procedure_Group_Code__c= procedureCode.GroupCode;
					procedureListToInsert.add(hcp);
					//procedureMapToUpsert.put(wrapper.patient.System_id + '_' + procedureCode.ProcedureCode, hcp);
				}
			}
		}
		if (procedureListToInsert.size() > 0) {
			insert procedureListToInsert;
		}
		Map<String, Id> mapToReturn = new Map<String, Id>();
		for (HealthCareProcedure hcp : procedureListToInsert) {
			mapToReturn.put(hcp.DH_RIS_Healthcare_Procedure__c, hcp.Id);
		}
		for (HealthCareProcedure hcp : procedureCodeIterateMap.values()) {
			mapToReturn.put(hcp.DH_RIS_Healthcare_Procedure__c, hcp.Id);
		}
		return mapToReturn;
	}
	public Id studyProcessor(Id patientId, Id orderId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();
		Map<String, Id> codeSetmap = getCancelledReasonCode(wrapper);

		Id pmpdId;
		String studyUniqueRis = utilityInstance.uniqueIdentifier(wrapper.patient.system_id, wrapper.study.data.study_key, System.label.DH_PatientMedicalProcedureRecordTypeName);
		List<PatientMedicalProcedure> existingPMP = [SELECT Id FROM PatientMedicalProcedure WHERE DH_RIS_StudyKey__c = :studyUniqueRis AND PatientId = :patientId LIMIT 1];
		if (wrapper.study.object_state != STATE_MODIFIED) {
			if (!existingPMP.isEmpty()) {
				return existingPMP[0].Id;
			}
		}

		String regionKey = wrapper.patient.system_id;
		Id region;

		if (regionKey != null) {
			region = utilityInstance.fetchRegion(regionKey);
		}

		PatientMedicalProcedure pmp = new PatientMedicalProcedure();
		pmp.DH_RIS_StudyKey__c = studyUniqueRis;
		pmp.PatientId = patientId != null ? patientId : null;
		pmp.DH_Clinical_Service_Request__c = orderId != null ? orderId : null;
		pmp.DH_Cancelled_Reason_Code__c = codeSetmap.get(wrapper.study.data.cancelled_reason_code);
		pmp.DH_Study_Key__c = Decimal.valueOf(wrapper.study.data.Study_Key).setScale(0);
		pmp.DH_Accession_Number__c = wrapper.study.data.Accession_Number;
		pmp.StartDate = wrapper.study.data.Scheduled_Start_Date != null ? wrapper.study.data.Scheduled_Start_Date : null;
		pmp.DH_CreatedDate__c = wrapper.Study.Data.created_date != null ? wrapper.Study.Data.created_date : null;
		pmp.Status = System.label.pmp_Status;
		pmp.DH_Scheduled_Modality_Code__c = wrapper.Study.data.scheduled_modality_code;
		pmp.DH_Site_Code__c = wrapper.Study.data.site_code;
		pmp.DH_Cancelled_Date__c = wrapper.study.data.Cancelled_Date != null ? wrapper.study.data.Cancelled_Date : null;
		pmp.DH_Tech_Only_flag__c = wrapper.study.data.Tech_Only_Flag != null && wrapper.study.data.Tech_Only_Flag == 'Y' ? true : false;
		pmp.DH_Reading_Stat_Flag__c = wrapper.study.data.Reading_Stat_Flag != null && wrapper.study.data.Reading_Stat_Flag == 'Y' ? true : false;
		pmp.DH_Exam_Stat_Flag__c = wrapper.study.data.Exam_Stat_Flag != null && wrapper.study.data.Exam_Stat_Flag == 'Y' ? true : false;
		pmp.DH_Status_Code__c = wrapper.study.data.status_code;
		pmp.AssertionSourceId = patientId != null ? patientId : null;
		pmp.DH_Practice_Code__c = wrapper.study.data.Practice_Code;

		// upsert Patient medical procedure
		if (pmp != null) {
			upsert pmp DH_RIS_StudyKey__c;
			pmpdId = pmp.Id;
		}

		if (wrapper.study.data.studyItems != null) {
			Map<String, Id> procedures = procedureProcessor(region, wrapper);
			Map<String, Id> studyItemsMap = processStudyItems(pmpdId, procedures, wrapper);
		}

		if (wrapper.study.data.studyExtraInfo != null) {
			studyExtraInfoProcessor(pmpdId, wrapper);
		}
		return pmpdId;
	}
	public Map<String, Id> processStudyItems(Id pmpdId, Map<String, Id> procedures, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();
		String regionKey = wrapper.patient.system_id;
		Id region;

		if (regionKey != null) {
			region = utilityInstance.fetchRegion(regionKey);
		}

		List<String> studyItemKeys = new List<String>();
		List<PatientMedicalProcedureDetail> patientMedicaProcedureDetailsList = new List<PatientMedicalProcedureDetail>();
		Set<String> currentPayloadStudyItemKey = new Set<String>();
		List<PatientMedicalProcedureDetail> recordsToDeactivate = new List<PatientMedicalProcedureDetail>();

		for (DH_PatientInfoWrapper.cls_studyItems item : wrapper.study.data.studyItems) {
			string uniqueProcedureCode = wrapper.patient.System_id + '_' + Item.ProcedureCode;
			String studyItemKey = Item.study_item_key;
			currentPayloadStudyItemKey.add(StudyItemKey);
			String studyItemrisUniqueKey = utilityInstance.uniqueIdentifier(wrapper.patient.system_id, item.study_item_key, System.label.DH_PatientMedicalProcedureDetailRecordTypeName);
			studyItemKeys.add(studyItemrisUniqueKey);

			PatientMedicalProcedureDetail pmd = new PatientMedicalProcedureDetail();
			pmd.PatientMedicalProcedureId = pmpdId;
			pmd.Healthcare_Procedure__c = !procedures.isEmpty() ? procedures.get(uniqueProcedureCode) : null;
			pmd.DetailType = System.label.pmd_DetailType;
			pmd.DetailRecordId = pmpdId;
			pmd.DH_Study_Item_Key__c = Item.study_item_key;
			pmd.DH_Active_Flag__c = Item.active_flag != null && Item.active_flag == 'Y' ? true : false;
			pmd.DH_RIS_StudyItemKey__c = studyItemrisUniqueKey;
			patientMedicaProcedureDetailsList.add(pmd);
		}

		// upsert list
		if (patientMedicaProcedureDetailsList.size() > 0) {
			upsert patientMedicaProcedureDetailsList DH_RIS_StudyItemKey__c;
		}
		Map<string, Id> orderItemToReturnMap = new Map<String, Id>();
		for (PatientMedicalProcedureDetail pmpd : patientMedicaProcedureDetailsList) {
			orderItemToReturnMap.put(pmpd.DH_Study_Item_Key__c, pmpd.Id);
		}
		List<PatientMedicalProcedureDetail> studyItemToDeactivate = [SELECT Id FROM PatientMedicalProcedureDetail WHERE PatientMedicalProcedureId = :pmpdId AND DH_RIS_StudyItemKey__c NOT IN :studyItemKeys];
		for (PatientMedicalProcedureDetail pmpdDeact : studyItemToDeactivate) {
			pmpdDeact.DH_Active_Flag__c = false;
			recordsToDeactivate.add(pmpdDeact);
		}

		// Deactivate Patient medical procedure detail record
		if (recordsToDeactivate.size() > 0) {
			update recordsToDeactivate;
		}
		// if the Patient medical procedure detail is deactivated then delete child records
		if (recordsToDeactivate.size() > 0) {
			Set<String> pmpdRecordIds = new Set<String>();
			for (PatientMedicalProcedureDetail pmd : recordsToDeactivate) {
				pmpdRecordIds.add(pmd.Id);
			}
			// query related Child Records to be deleted
			List<DH_Study_BillingCodes__c> childRecords = [SELECT Id FROM DH_Study_BillingCodes__c WHERE DH_Patient_Medical_Procedure_Detail__c IN :pmpdRecordIds];

			if (childRecords.size() > 0) {
				delete childRecords;
			}
		}
		if (wrapper.study.data.studyItems != null) {
			studyBillingCodeProcessor(region, orderItemToReturnMap, wrapper);
		}
		return orderItemToReturnMap;
	}
	private Map<String, Id> billingCodeProcessor(String systemID, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		String regionKey = wrapper.patient.system_id;
		Id region;
		if (regionKey != null) {
			region = utility.fetchRegion(regionKey);
		}
		//List<DH_BillingCode__c> billingCodesToUpsert = new List<DH_BillingCode__c>();
		Map<String, DH_BillingCode__c> billingCodeToUpsert = new Map<String, DH_BillingCode__c>();

		Set<String> uniqueBillingCodes = new Set<String>();
		for (DH_PatientInfoWrapper.cls_studyItems studyItem : wrapper.study.data.studyItems) {
			for (DH_PatientInfoWrapper.cls_studyBillingCodes billingCode : studyItem.studyBillingCodes) {
				uniqueBillingCodes.add(utility.uniqueIdentifier(wrapper.patient.system_id, billingCode.orderbilling_code, System.Label.DH_BillingCodeRecordTypeName));
			}
		}
		List<DH_BillingCode__c> existingBillingCodes = [SELECT Id, DH_RIS_BillingCode__c FROM DH_BillingCode__c WHERE DH_RIS_BillingCode__c IN :uniqueBillingCodes];
		Map<String, DH_BillingCode__c> billingCodeIterateMap = new Map<String, DH_BillingCode__c>();
		for (DH_BillingCode__c billcode : existingBillingCodes) {
			billingCodeIterateMap.put(billcode.DH_RIS_BillingCode__c, billcode);
		}

		for (DH_PatientInfoWrapper.cls_studyItems studyItem : wrapper.study.data.studyItems) {
			for (DH_PatientInfoWrapper.cls_studyBillingCodes billingCode : studyItem.studyBillingCodes) {
				String billingcodeIdentifier = utility.uniqueIdentifier(wrapper.patient.system_id, billingCode.orderbilling_code, System.Label.DH_BillingCodeRecordTypeName);
				if (!billingCodeIterateMap.containsKey(billingcodeIdentifier)) {
					DH_BillingCode__c billCode = new DH_BillingCode__c();
					billCode.DH_RIS_BillingCode__c = billingcodeIdentifier;
					billCode.DH_AccountRegion__c = region != null ? region : null;
					billCode.Name = billingCode.orderbilling_code;
					billCode.DH_Description__c = billingCode.orderdescription.length() > 254 ? billingCode.orderdescription.substring(0, 254) : billingCode.orderdescription;
					billingCodeToUpsert.put(billingcodeIdentifier, billCode);
				}
			}
		}

		if (billingCodeToUpsert.size() > 0) {
			insert billingCodeToUpsert.values();
		}

		Map<String, Id> billingCodeIds = new Map<String, Id>();
		for (DH_BillingCode__c billingCode : billingCodeToUpsert.values()) {
			billingCodeIds.put(billingCode.DH_RIS_BillingCode__c, billingCode.Id);
		}
		for (DH_BillingCode__c billingCode : billingCodeIterateMap.values()) {
			billingCodeIds.put(billingCode.DH_RIS_BillingCode__c, billingCode.Id);
		}

		return billingCodeIds;
	}
	private Boolean studyBillingCodeProcessor(Id systemID, Map<String, Id> csrdItemKeytoIdMap, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		String regionKey = wrapper.patient.system_id;
		Id region;
		if (regionKey != null) {
			region = utility.fetchRegion(regionKey);
		}
		Map<String, Id> billingcodeMap = billingCodeProcessor(region, wrapper);

		map<String, DH_Study_BillingCodes__c> studyBillCodeMap = new Map<String, DH_Study_BillingCodes__c>();

		for (DH_PatientInfoWrapper.cls_studyItems studyItem : wrapper.study.data.studyItems) {
			for (DH_PatientInfoWrapper.cls_studyBillingCodes eachOrderBillingCode : studyItem.studyBillingCodes) {
				if (eachOrderBillingCode.orderbilling_code != null) {
					String sbcUnique = wrapper.patient.system_id + '_' + eachOrderBillingCode.study_item_key + '_' + eachOrderBillingCode.orderbilling_code + '_' + System.label.DH_StudyBillingCodeRecordTypeName;
					String billingIdentifier = wrapper.patient.system_id + '_' + eachOrderBillingCode.orderbilling_code + '_' + system.label.DH_BillingCodeRecordTypeName;
					DH_Study_BillingCodes__c bills = new DH_Study_BillingCodes__c();
					bills.Name = wrapper.patient.system_id + '_' + eachOrderBillingCode.orderbilling_code;
					bills.DH_Billing_Code__c = billingcodeMap.size() > 0 ? billingcodeMap.get(billingIdentifier) : null;
					bills.DH_Active_Flag__c = eachOrderBillingCode.active_flag != null && eachOrderBillingCode.active_flag == 'Y' ? true : false;
					bills.DH_Pre_Cert_Status__c = eachOrderBillingCode.pre_cert_status;
					bills.DH_Patient_Medical_Procedure_Detail__c = !csrdItemKeytoIdMap.isempty() ? csrdItemKeytoIdMap.get(eachOrderBillingCode.study_item_key) : null;
					bills.DH_StudyItemKey_RIS__c = sbcUnique;
					studyBillCodeMap.put(sbcUnique, bills);
				}
			}
		}
		if (studyBillCodeMap.size() > 0) {
			upsert studyBillCodeMap.values() DH_StudyItemKey_RIS__c;
		}
		return true;
	}
	public void studyExtraInfoProcessor(Id pmpId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utilityInstance = new DH_RisUtilityClass();

		List<String> studyExtraInfoKeys = new List<String>();
		List<DH_Study_Extra_Info__c> studyExtraInfoListToUpsert = new List<DH_Study_Extra_Info__c>();
		for (DH_PatientInfoWrapper.studyExtraInfo extraInfo : wrapper.study.data.studyExtraInfo) {
			String studyExtraInfoRisUnique = utilityInstance.uniqueIdentifier(wrapper.patient.system_id, extraInfo.study_extra_info_key, System.label.DH_studyExtraInfoRecordTypeName);
			studyExtraInfoKeys.add(studyExtraInfoRisUnique);

			DH_Study_Extra_Info__c studyExtra = new DH_Study_Extra_Info__c();
			studyExtra.Name = extraInfo.study_extra_info_code;
			studyExtra.DH_Patient_Medical_Procedure__c = pmpId != null ? pmpId : null;
			studyExtra.DH_Study_Extra_Info_Key__c = extraInfo.study_extra_info_key;
			studyExtra.DH_RIS_StudyExtraInfoKey__c = studyExtraInfoRisUnique;
			studyExtra.DH_Study_Extra_Info_Code__c = extraInfo.study_extra_info_code;
			studyExtra.DH_Value__c = extraInfo.value;
			studyExtraInfoListToUpsert.add(studyExtra);
		}

		if (studyExtraInfoListToUpsert.size() > 0) {
			upsert studyExtraInfoListToUpsert DH_RIS_StudyExtraInfoKey__c;
		}
		List<DH_Study_Extra_Info__c> studyeExtraInfoRecordsToDelete = [SELECT Id FROM DH_Study_Extra_Info__c WHERE DH_Patient_Medical_Procedure__c = :pmpId AND DH_RIS_StudyExtraInfoKey__c NOT IN :studyExtraInfoKeys];
		if (studyeExtraInfoRecordsToDelete.size() > 0) {
			delete studyeExtraInfoRecordsToDelete;
		}
	}
}