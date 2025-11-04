/******************************************************************************************************************************************************
 *
 * @Created Date    :  7/5/2024,
 * @description     : DH_RISOrderProcessor Class receives a parsed JSON request and Processes Order and it's realted  Object Records in SFHC
 * @parm			:
 * TODO				:
 * @Jira Id         : CC-355
 *
 * ****************************************************************************************************************************************************/

public class DH_RISOrderProcessor extends DH_RisBaseProcessor {
	private static final String STATE_MODIFIED = 'modified';
	private Boolean doCallOptIn;
	public Boolean isOptedOutMarketingCloud;

	private DH_RisUtilityClass common;
	public DH_RISOrderProcessor(DH_RisUtilityClass common) {
		super();
		this.common = common;
	}

	private Map<String, Id> getOrSetCodes(DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		Map<String, Id> codeSetRecords = utility.fetchCodeSetRecordIds(wrapper);
		Map<String, Id> codeSetRecordsToReturn = new Map<String, Id>();

		List<CodeSet> masterCodeSetListToInsert = new List<CodeSet>();
		if (codeSetRecords.get(wrapper.order.data.patient_class_code) == null && wrapper.order.data.patient_class_code != null && !Test.isRunningTest()) {
			CodeSet patientClassCode = new Codeset();
			PatientClassCode.Name = wrapper.order.data.patient_class_code;
			PatientClassCode.DH_RIS_Instance__c = wrapper.patient.system_id;
			PatientClassCode.DH_Code__c = wrapper.order.data.patient_class_code;
			PatientClassCode.DH_RISCodeset__c = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.patient_class_code, system.label.DH_Patient_Class);
			PatientClassCode.RecordTypeId = Schema.SObjectType.CodeSet.getRecordTypeInfosByName().get(system.label.DH_Patient_Class).getRecordTypeId();
			masterCodeSetListToInsert.add(patientClassCode);
		}

		if (codeSetRecords.get(wrapper.order.data.order_category_code) == null && wrapper.order.data.order_category_code != null && !Test.isRunningTest()) {
			CodeSet orderCategoryCode = new CodeSet();
			orderCategoryCode.name = wrapper.order.data.order_category_code;
			orderCategoryCode.DH_RIS_Instance__c = wrapper.patient.system_id;
			orderCategoryCode.DH_Code__c = wrapper.order.data.order_category_code;
			orderCategoryCode.DH_RISCodeset__c = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.order_category_code, system.label.DH_Order_Category);
			orderCategoryCode.RecordTypeId = Schema.SObjectType.CodeSet.getRecordTypeInfosByName().get(system.label.DH_Order_Category).getRecordTypeId();
			masterCodeSetListToInsert.add(orderCategoryCode);
		}

		if (codeSetRecords.get(wrapper.order.data.scheduling_next_fup_type_code) == null && wrapper.order.data.scheduling_next_fup_type_code != null && !Test.isRunningTest()) {
			CodeSet followUpCodes = new CodeSet();
			followUpCodes.name = wrapper.order.data.scheduling_next_fup_type_code;
			followUpCodes.DH_RIS_Instance__c = wrapper.patient.system_id;
			followUpCodes.DH_Code__c = wrapper.order.data.scheduling_next_fup_type_code;
			followUpCodes.DH_RISCodeset__c = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.scheduling_next_fup_type_code, system.label.DH_FollowUp_Type);
			followUpCodes.RecordTypeId = Schema.SObjectType.CodeSet.getRecordTypeInfosByName().get(system.label.DH_FollowUp_Type).getRecordTypeId();
			masterCodeSetListToInsert.add(followUpCodes);
		}

		if (masterCodeSetListToInsert.size() > 0) {
			insert masterCodeSetListToInsert;
			System.debug('Inserted codeset records ---' + masterCodeSetListToInsert);
		}
		for (String codekey : codeSetRecords.keySet()) {
			codeSetRecordsToReturn.put(codekey, codeSetRecords.get(codekey));
			System.debug('existing code set Records keys ==' + codeSetRecords.keySet());
		}

		for (codeSet codes : masterCodeSetListToInsert) {
			System.debug('codeset records before adding to map---' + masterCodeSetListToInsert);
			codeSetRecordsToReturn.put(codes.DH_Code__c, codes.Id);
		}

		return codeSetRecordsToReturn;
	}
	private Map<String, Id> modalityProcessor(Id systemId, DH_PatientInfoWrapper wrapper) {
		// unique List for modalities
		set<String> uniqueModalities = new Set<String>();
		Id modalityRecordTypeId = Schema.SObjectType.CareSpecialty.getRecordTypeInfosByName().get(system.label.DH_ModalityRecordTypeName).getRecordTypeId();

		for (DH_PatientInfoWrapper.OrderItems procedureCode : wrapper.order.data.OrderItems) {
			uniqueModalities.add(wrapper.patient.System_id + '_' + procedureCode.groupCode);
		}

		List<CareSpecialty> existingModalities = [SELECT Id, Name, DH_Region_Instance__c, SpecialtyCode, DH_SFMC_Speciality_Code__c,CareSpecialty_External_ID__c FROM CareSpecialty WHERE SpecialtyCode IN :UniqueModalities AND RecordTypeId = :modalityRecordTypeId];
		map<String, CareSpecialty> existingModalitiesMap = new Map<String, CareSpecialty>();
		for (CareSpecialty existingModality : existingModalities) {
			existingModalitiesMap.put(existingModality.SpecialtyCode, existingModality);
		}
		map<String, CareSpecialty> carespecialityMapToUpsert = new Map<String, CareSpecialty>();
		List<CareSpecialty> modalityListToInsert = new List<CareSpecialty>();
		for (DH_PatientInfoWrapper.OrderItems procedureCode : wrapper.order.data.OrderItems) {
			if (procedureCode.groupCode != null) {
				string uniqueCode = wrapper.patient.System_id + '_' + procedureCode.groupCode;
				CareSpecialty cs = new CareSpecialty();
				cs.Name = procedureCode.groupCode;
				cs.DH_RIS_Code__c = uniqueCode;
				cs.SpecialtyCode = uniqueCode;
				cs.CareSpecialty_External_ID__c = uniqueCode;
				cs.DH_Region_Instance__c = systemID != null ? systemID : null;
				cs.DH_SFMC_Speciality_Code__c = procedureCode.groupCode;
				cs.RecordTypeId = modalityRecordTypeId;
				cs.isActive = true;
				if (!existingModalitiesMap.containsKey(uniqueCode)) {
					modalityListToInsert.add(cs);
				}

				//carespecialityMapToUpsert.put(wrapper.patient.System_id + '_' + procedureCode.groupCode, cs);
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
		for (DH_PatientInfoWrapper.OrderItems procedureCode : wrapper.order.data.orderItems) {
			uniqueHealthcareProcedures.add(wrapper.patient.System_id + '_' + procedureCode.ProcedureCode);
		}

		List<HealthCareProcedure> existingHealthcareProcedureList = [SELECT Id, DH_RIS_Healthcare_Procedure__c, DH_Region_Instance__c, Code, CodeDescription, IsActive,DH_Procedure_Group_Code__c FROM HealthCareProcedure WHERE DH_RIS_Healthcare_Procedure__c IN :uniqueHealthcareProcedures AND RecordTypeId = :hcpRecordTypeId];
		Map<String, HealthCareProcedure> procedureCodeIterateMap = new Map<String, HealthCareProcedure>();
		for (HealthCareProcedure existingHealthcareProcedure : existingHealthcareProcedureList) {
			procedureCodeIterateMap.put(existingHealthcareProcedure.DH_RIS_Healthcare_Procedure__c, existingHealthcareProcedure);
		}
		List<HealthCareProcedure> procedureListToInsert = new List<HealthCareProcedure>();
		Map<String, HealthCareProcedure> procedureMapToUpsert = new Map<String, HealthCareProcedure>();
		for (DH_PatientInfoWrapper.OrderItems procedureCode : wrapper.order.data.OrderItems) {
			if (procedureCode.procedureCode != null) {
				String uniqueCode = wrapper.patient.System_id + '_' + procedureCode.ProcedureCode;
				String uniqueModality = wrapper.Patient.System_Id + '_' + ProcedureCode.GroupCode;
				if (!procedureCodeIterateMap.containsKey(uniqueCode)) {
					HealthCareProcedure hcp = new HealthCareProcedure();
					hcp.Name = procedureCode.ProcedureCode + '_' + procedureCode.Description;
					hcp.DH_RIS_Healthcare_Procedure__c = uniqueCode;
					hcp.Modality_Codes__c = !modalities.isempty() ? modalities.get(uniqueModality) : null;
					hcp.DH_Region_Instance__c = systemID != null ? systemID : null;
					hcp.Code = procedureCode.ProcedureCode;
					hcp.CodeDescription = procedureCode.Description;
					hcp.IsActive = procedureCode.active_flag != null && procedureCode.active_flag == 'Y' ? true : false;
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
	private Map<String, Id> billingCodeProcessor(Id systemID, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		//List<DH_BillingCode__c> billingCodesToUpsert = new List<DH_BillingCode__c>();
		Map<String, DH_BillingCode__c> billingCodeToUpsert = new Map<String, DH_BillingCode__c>();

		Set<String> uniqueBillingCodes = new Set<String>();
		for (DH_PatientInfoWrapper.OrderItems orderItem : wrapper.order.data.orderItems) {
			for (DH_PatientInfoWrapper.cls_orderBillingCodes billingCode : orderItem.orderBillingCodes) {
				uniqueBillingCodes.add(utility.uniqueIdentifier(wrapper.patient.system_id, billingCode.orderbilling_code, System.Label.DH_BillingCodeRecordTypeName));
			}
		}
		List<DH_BillingCode__c> existingBillingCodes = [SELECT Id, DH_RIS_BillingCode__c FROM DH_BillingCode__c WHERE DH_RIS_BillingCode__c IN :uniqueBillingCodes];
		Map<String, DH_BillingCode__c> billingCodeIterateMap = new Map<String, DH_BillingCode__c>();
		for (DH_BillingCode__c billcode : existingBillingCodes) {
			billingCodeIterateMap.put(billcode.DH_RIS_BillingCode__c, billcode);
		}

		for (DH_PatientInfoWrapper.OrderItems orderItem : wrapper.order.data.orderItems) {
			for (DH_PatientInfoWrapper.cls_orderBillingCodes billingCode : orderItem.orderBillingCodes) {
				String billingcodeIdentifier = utility.uniqueIdentifier(wrapper.patient.system_id, billingCode.orderbilling_code, System.Label.DH_BillingCodeRecordTypeName);
				if (!billingCodeIterateMap.containsKey(billingcodeIdentifier)) {
					DH_BillingCode__c billCode = new DH_BillingCode__c();
					billCode.DH_RIS_BillingCode__c = billingcodeIdentifier;
					billCode.DH_AccountRegion__c = systemID != null ? systemID : null;
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

	private void orderbillingProcessor(Id systemID, Map<String, Id> csrdItemKeytoIdMap, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		Map<String, Id> billingcodeMap = billingCodeProcessor(systemID, wrapper);

		map<String, DH_Order_Billing_Codes__c> orderBillCodeMap = new Map<String, DH_Order_Billing_Codes__c>();

		for (DH_PatientInfoWrapper.OrderItems orderItem : wrapper.order.data.orderItems) {
			for (DH_PatientInfoWrapper.cls_orderBillingCodes eachOrderBillingCode : orderItem.orderBillingCodes) {
				if (eachOrderBillingCode.orderbilling_code != null) {
					String obcUnique = wrapper.patient.system_id + '_' + eachOrderBillingCode.order_item_key + '_' + eachOrderBillingCode.orderbilling_code + '_' + System.label.DH_orderBillRecordTypeName;
					String billingIdentifier = wrapper.patient.system_id + '_' + eachOrderBillingCode.orderbilling_code + '_' + system.label.DH_BillingCodeRecordTypeName;
					DH_Order_Billing_Codes__c obc = new DH_Order_Billing_Codes__c();
					obc.Name = wrapper.patient.system_id + '_' + eachOrderBillingCode.orderbilling_code;
					obc.DH_BillingCode__c = billingcodeMap.size() > 0 ? billingcodeMap.get(billingIdentifier) : null;
					obc.DH_Order_Item_Key__c = eachOrderBillingCode.order_item_key;
					obc.DH_Active_Flag__c = eachOrderBillingCode.active_flag != null && eachOrderBillingCode.active_flag == 'Y' ? true : false;
					obc.DH_Pre_Cert_Status__c = eachOrderBillingCode.pre_cert_status;
					obc.DH_Clinical_Service_Request_Detail__c = !csrdItemKeytoIdMap.isempty() ? csrdItemKeytoIdMap.get(eachOrderBillingCode.order_item_key) : null;
					obc.DH_OrderItem_RIS__c = obcUnique;
					orderBillCodeMap.put(obcUnique, obc);
				}
			}
		}
		if (orderBillCodeMap.size() > 0) {
			upsert orderBillCodeMap.values() DH_OrderItem_RIS__c;
		}
	}

	public Map<String, Id> ReferringPracticeProcessor(Id systemID, Id orderID, DH_PatientInfoWrapper wrapper) {
		Map<String, Account> referringPracticemapToUpsert = new Map<String, Account>();
		Map<String, Id> returnMap = new Map<String, Id>();
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		Set<String> uniqueReferringPractice = new Set<String>();
		for (DH_PatientInfoWrapper.Referring_Practices recs : wrapper.Order.data.referring_practices) {
			uniqueReferringPractice.add(utility.uniqueIdentifier(wrapper.patient.system_id, recs.referring_practice_key, System.label.DH_ReferringPracticeRecordTypeName));
		}
		List<Account> existingReferringPractice = [SELECT Id, DH_RIS_Unique_Code__c FROM Account WHERE DH_RIS_Unique_Code__c IN :uniqueReferringPractice AND recordtype.name = :System.label.DH_ReferringPracticeRecordTypeName];
		Map<String, Account> referringPracticeIterateMap = new Map<String, Account>();
		for (Account referringPractice : existingReferringPractice) {
			referringPracticeIterateMap.put(referringPractice.DH_RIS_Unique_Code__c, referringPractice);
		}
		if (wrapper.order.data.referring_practices != null) {
			for (DH_PatientInfoWrapper.Referring_Practices recs : wrapper.Order.data.referring_practices) {
				String refRisUnique = utility.uniqueIdentifier(wrapper.patient.system_id, recs.referring_practice_key, System.label.DH_ReferringPracticeRecordTypeName);
				if (!referringPracticeIterateMap.containsKey(refRisUnique)) {
					String referringPracticeKey = recs.referring_practice_key;
					Account newRef = new Account();
					newRef.Name = recs.practice_name;
					newRef.DH_RIS_Unique_Code__c = refRisUnique;
					newRef.AccountRegion__c = systemID != null ? systemID : null;
					newRef.DH_Referring_Practice_Name__c = recs.practice_name;
					newRef.DH_Referring_Practice_Key__c = recs.referring_practice_key;
					newRef.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.DH_ReferringPracticeRecordTypeName).getRecordTypeId();
					referringPracticemapToUpsert.put(refRisUnique, newRef);
				}
			}
			if (referringPracticemapToUpsert.size() > 0) {
				insert referringPracticemapToUpsert.values();
			}

			for (Account acc : existingReferringPractice) {
				returnMap.put(acc.DH_RIS_Unique_Code__c, acc.Id);
			}
			for (Account acc : referringPracticemapToUpsert.values()) {
				returnMap.put(acc.DH_RIS_Unique_Code__c, acc.Id);
			}
		}
		return returnMap;
	}
	private void orderReferringPracticeProcessor(Id orderID, String systemID, String orderKey, Map<String, Id> referringPractices, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		Map<string, Id> referringPractice = referringPractices;
		List<String> orderPracticeKeys = new List<String>();
		Map<String, DH_Order_Referring_Practice__c> orderPracticesToInsert = new Map<String, DH_Order_Referring_Practice__c>();
		for (DH_PatientInfoWrapper.Referring_Practices recs : wrapper.Order.data.referring_practices) {
			String refPracticeKey = utility.uniqueIdentifier(wrapper.patient.system_id, recs.referring_practice_key, System.Label.DH_ReferringPracticeRecordTypeName);
			String orderReferringPracticeKey = utility.uniqueIdentifier(wrapper.patient.system_id, recs.referring_practice_key + '_' + wrapper.order.data.order_key, System.Label.DH_ReferringPracticeRecordTypeName);
			orderPracticeKeys.add(orderReferringPracticeKey);

			DH_Order_Referring_Practice__c orderRef = new DH_Order_Referring_Practice__c();
			orderRef.DH_RIS_OrderPractice__c = orderReferringPracticeKey;
			orderRef.DH_Clinical_Service_Request__c = orderID;
			orderRef.DH_Referring_Practice_Account__c = referringPractice.get(refPracticeKey);
			orderRef.DH_Referring_Practice_Group_Code__c = recs.referring_practice_key;
			orderPracticesToInsert.put(orderReferringPracticeKey, orderRef);
		}
		if (orderPracticesToInsert.size() > 0) {
			upsert orderPracticesToInsert.values() DH_RIS_OrderPractice__c;
		}

		List<DH_Order_Referring_Practice__c> orderPracticesToDelete = [SELECT Id FROM DH_Order_Referring_Practice__c WHERE DH_Clinical_Service_Request__c = :orderID AND DH_RIS_OrderPractice__c NOT IN :orderPracticeKeys];

		if (orderPracticesToDelete.size() > 0) {
			delete orderPracticesToDelete;
		}
	}

	private Map<String, Id> orderItemProcessor(Id orderID, Map<String, Id> procedureMapToUpsert, DH_PatientInfoWrapper wrapper) {
		List<ClinicalServiceRequestDetail> serviceRequestDetailList = new List<ClinicalServiceRequestDetail>();
		List<ClinicalServiceRequestDetail> recordsToDeactivate = new List<ClinicalServiceRequestDetail>();
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		Set<String> currentPayloadOrderItemKeys = new Set<String>();
		List<String> orderItemKeys = new List<String>();

		for (DH_PatientInfoWrapper.orderItems details : wrapper.Order.data.orderItems) {
			String orderItemKey = Details.order_item_key;
			currentPayloadOrderItemKeys.add(orderItemKey);
			String orderItemrisUnique = utility.uniqueIdentifier(wrapper.patient.system_id, details.order_item_key, System.label.DH_ClinicalServiceRequest_DetailRecordTypeName);
			orderItemKeys.add(orderItemrisUnique);
			string uniqueProcedureCode = wrapper.patient.System_id + '_' + details.ProcedureCode;
			ClinicalServiceRequestDetail csd = new ClinicalServiceRequestDetail();
			csd.ClinicalServiceRequestId = orderID;
            csd.Body_Part__c = details.body_part_code;
			csd.DH_Healthcare_Procedure__c = !procedureMapToUpsert.isempty() ? procedureMapToUpsert.get(uniqueProcedureCode) : null;
			csd.DH_Order_Item_Key__c = Details.order_item_key;
			csd.DH_RIS_OrderItemKey__c = orderItemrisUnique;
			csd.DetailType = system.label.csd_detailType;
			csd.DetailRecordId = orderID;
			csd.isActive__c = Details.active_flag != null && Details.active_flag == 'Y' ? true : false;
			csd.DH_Sequence_Id__c = Integer.valueOf(Details.sequence_id);
			serviceRequestDetailList.add(csd);
		}
		List<ClinicalServiceRequestDetail> oldOrderItems = [SELECT Id FROM ClinicalServiceRequestDetail WHERE ClinicalServiceRequestId = :orderID AND DH_RIS_OrderItemKey__c NOT IN :orderItemKeys];
		for (ClinicalServiceRequestDetail csrdToDeact : oldOrderItems) {
			csrdToDeact.isActive__c = false;
			recordsToDeactivate.add(csrdToDeact);
		}

		if (serviceRequestDetailList.size() > 0) {
			upsert serviceRequestDetailList DH_RIS_OrderItemKey__c;
		}
		if (recordsToDeactivate.size() > 0) {
			update recordsToDeactivate;
		}
		if (recordsToDeactivate.size() > 0) {
			Set<String> csrdChildRecordsToDelete = new Set<String>();
			for (ClinicalServiceRequestDetail records : recordsToDeactivate) {
				csrdChildRecordsToDelete.add(records.Id);
			}
			List<DH_Order_Billing_Codes__c> orderBillingCodeRecords = [
				SELECT Id
				FROM DH_Order_Billing_Codes__c
				WHERE DH_Clinical_Service_Request_Detail__c IN :csrdChildRecordsToDelete
			];
			if (orderBillingCodeRecords.size() > 0) {
				delete orderBillingCodeRecords;
			}
		}
		Map<string, Id> csrdItemKeytoIdMap = new Map<string, string>();
		for (ClinicalServiceRequestDetail eachRec : serviceRequestDetailList) {
			csrdItemKeytoIdMap.put(eachRec.DH_Order_Item_Key__c, eachRec.id);
		}
		return csrdItemKeytoIdMap;
	}
	private Id physicianProcessor(Id SytemId, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		if (wrapper.order.data.requested_by != null) {
			String risPhysicianUnique = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.requested_by.person_key, System.label.DH_PhysicianRecordTypeName);
			List<Account> existingReferringPhysician = [SELECT Id, DH_RIS_Unique_Code__c FROM Account WHERE DH_RIS_Unique_Code__c = :risPhysicianUnique AND recordtype.name = :System.label.DH_PhysicianRecordTypeName LIMIT 1];
			if (existingReferringPhysician.isEmpty()) {
				Account phyAcc = new Account();
				phyAcc.DH_RIS_Unique_Code__c = risPhysicianUnique;
				phyAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.DH_PhysicianRecordTypeName).getRecordTypeId();
				PhyAcc.AccountRegion__c = SytemId != null ? SytemId : null;
				PhyAcc.DH_Requested_By_Person_Key__c = wrapper.order.data.requested_by.person_key;
				phyAcc.DH_Physician_Key__c = String.valueOf(wrapper.order.data.requested_by.person_key);
                PhyAcc.DH_Physician_Id__c = wrapper.order.data.requested_by.Id;
				PhyAcc.DH_Requested_By_First_Name__c = wrapper.order.data.requested_by.first_name;
				PhyAcc.DH_Requested_By_Last_Name__c = wrapper.order.data.requested_by.last_name;
				phyAcc.Name = wrapper.order.data.requested_by.first_name + ' ' + wrapper.order.data.requested_by.last_name;
				PhyAcc.DH_Requested_By_NPI__c = wrapper.order.data.requested_by.npi;
				PhyAcc.DH_Name_suffix_code_patient_suffix_Code__c = wrapper.order.data.Requested_by.suffixCode != null ? wrapper.order.data.Requested_by.suffixCode : null;
				PhyAcc.DH_Requested_by_Id__c = wrapper.order.data.requested_by.Id;

				insert phyAcc;
				return phyAcc.id;
			}
			return existingReferringPhysician[0].Id;
		}
		return null;
	}
	public Id PhysicianAndAddressProcessor(Id SytemId, DH_PatientInfoWrapper wrapper) {
		Id physicianId = physicianProcessor(SytemId, wrapper);
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		if (wrapper.order.data.requested_by_address != null) {
			String locationRisUnique = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.requested_by_address.person_address_key, system.label.DH_locationRecordTypeName);
			List<Schema.Location> locations = [SELECT Id FROM Location WHERE DH_RIS_Location_Key__c = :locationRisUnique LIMIT 1];
			Schema.Location loc = new Schema.Location();
			if (locations.size() > 0) {
				loc = locations[0];
			} else {
				loc.DH_Physician__c = physicianId != null ? physicianId : null;
				loc.Name = String.valueOf(physicianId);
				loc.LocationType = System.label.DH_LocationType;
				loc.DH_Physician_Key__c = wrapper.order.data.requested_by.person_key;
				loc.DH_RIS_Location_Key__c = locationRisUnique;

				if (loc != null) {
					insert loc;
				}
			}
			Schema.Address add = new Schema.Address();
			String addressRisUnique = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.requested_by_address.person_address_key, system.label.DH_AddressRecordTypeName);
			List<Schema.Address> addresses = [SELECT Id FROM Address WHERE DH_RIS_AddressKey_Rec__c = :addressRisUnique LIMIT 1];
			if (addresses.size() > 0) {
				add = addresses[0];
			} else {
				add.DH_Person_Address_Key__c = wrapper.order.data.requested_by_address.person_address_key;
				add.DH_RIS_AddressKey_Rec__c = addressRisUnique;
				add.DH_Address_Line_1__c = wrapper.order.data.requested_by_address.address_line1;
				add.DH_Address_Line_2__c = wrapper.order.data.requested_by_address.address_line2;
				add.City = wrapper.order.data.requested_by_address.city;
				add.State = wrapper.order.data.requested_by_address.state;
				add.PostalCode = wrapper.order.data.requested_by_address.zipcode;
				add.locationtype = System.label.DH_LocationType;
				add.parentId = loc.id;

				if (add != null) {
					insert add;
				}
			}
		}
		return physicianId;
	}

	public Id orderProcessor(Id patientID, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();

		if (wrapper.order.object_state != STATE_MODIFIED) {
			String csrRisUnique = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.order_key, System.label.DH_ClinicalServiceRequestRecordTypeName);
			List<ClinicalServiceRequest> existingOrder = [SELECT Id FROM ClinicalServiceRequest WHERE DH_RIS_OrderKey__c = :csrRisUnique AND PatientId = :patientID LIMIT 1];
			if (!existingOrder.isEmpty()) {
				return existingOrder[0].Id;
			}
		}

		String regionKey = wrapper.patient.system_id;
		Id systemID;
		if (regionKey != null) {
			systemID = utility.fetchRegion(regionKey);
		}
		Id site;
		if (wrapper.order.data.filler_site_code != null) {
			site = utility.fetchSite(regionKey, wrapper.order.data.filler_site_code);
		}
		Id practice;
		if (wrapper.order.data.filler_practice_code != null) {
			practice = utility.fetchPractice(regionKey, wrapper.order.data.filler_practice_code);
		}

		Map<String, Id> orderCodesMap = getOrSetCodes(wrapper);
		System.debug('fetching codes set from order---' + orderCodesMap);
		//orderCodesMap.get(utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.patient_class_code, system.label.DH_Patient_Class));

		Id physicianID;
		if (wrapper.order.data.requested_by != null) {
			//= physicianProcessor(wrapper);
			physicianID = PhysicianAndAddressProcessor(systemID, wrapper);
		}

		ClinicalServiceRequest csr = new ClinicalServiceRequest();
		csr.DH_RIS_OrderKey__c = utility.uniqueIdentifier(wrapper.patient.system_id, wrapper.order.data.order_key, System.label.DH_ClinicalServiceRequestRecordTypeName);
		csr.PatientId = patientID;
		csr.DH_Site_Code__c = site != null ? site : null;
		csr.DH_Practice_Code__c = practice != null ? practice : null;
		csr.DH_Patient_Class_Code__c = orderCodesMap.get(wrapper.order.data.patient_class_code);
		csr.DH_Order_Category_Code__c = orderCodesMap.get(wrapper.order.data.order_category_code);
		csr.DH_Scheduling_Next_Fup_type_code__c = orderCodesMap.get(wrapper.order.data.scheduling_next_fup_type_code);
		csr.DH_System_Code__c = systemID != null ? systemID : null;
		csr.DH_Shortened_Icode_url__c = wrapper.order.shortened_icode_url;
		csr.DH_Created_with_Study_flag__c = wrapper.order.created_with_study_flag != null && wrapper.order.created_with_study_flag == 'Y' ? true : false;
		csr.DH_Rescheduled_Flag__c = wrapper.Order.rescheduled_flag;
		csr.DH_Order_Key__c = wrapper.order.data.order_key;
		csr.DH_Um_Required_Flag__c = wrapper.Order.data.Um_Required_Flag != null && wrapper.Order.data.Um_Required_Flag == 'Y' ? true : false;
		csr.DH_Um_Completed_Flag__c = wrapper.Order.data.Um_Complete_Flag != null && wrapper.Order.data.Um_Complete_Flag == 'Y' ? true : false;
		csr.DH_Requested_Date__c = wrapper.Order.data.Requested_Date != null ? wrapper.Order.data.Requested_Date : null;
		csr.DH_Entered_Date__c = wrapper.Order.data.Entered_Date != null ? wrapper.Order.data.Entered_Date : null;
		csr.DH_Status_Code__c = wrapper.Order.data.status_code;
		csr.Status = wrapper.Order.data.status_code;
		csr.Type = system.label.csr_type;
		csr.DH_Scheduling_Next_Fup_date__c = wrapper.Order.data.scheduling_next_fup_date != null ? wrapper.Order.data.scheduling_next_fup_date : null;
		csr.DH_Filler_Site_Code__c = wrapper.Order.data.Filler_Site_Code;
		csr.DH_Filler_Practice_Code__c = wrapper.Order.data.Filler_Practice_Code;
		csr.DH_Primary_Carrier_Code__c = wrapper.Order.data.Primary_Carrier_Code;
		csr.DH_Secondary_Carrier_Code__c = wrapper.Order.data.Secondary_Carrier_Code;
		csr.DH_Confirmed_Flag__c = wrapper.order.data.confirmed_flag != null && wrapper.order.data.confirmed_flag == 'Y' ? true : false;
		csr.DH_Physician__c = physicianID;

		for (DH_PatientInfoWrapper.orderExtraInfo orderExtra : wrapper.order.data.orderExtraInfo) {
			if (orderExtra.order_extra_info_code == System.label.DH_StopOrder) {
				csr.DH_HasOrderOptedOut__c = true;
                csr.DH_HasOrderOptedOutDate__c=DateTime.now();
			} else {
				csr.DH_HasOrderOptedOut__c = false;
                csr.DH_HasOrderOptedOutDate__c=null;
			}
		}

		if (csr != null) {
			upsert csr DH_RIS_OrderKey__c;
		}

		Id orderID = csr.Id;

		if (wrapper.order.data.referring_practices != null) {
			Map<String, Id> referringPracticeMap = ReferringPracticeProcessor(systemID, orderID, wrapper);
			orderReferringPracticeProcessor(orderID, wrapper.patient.system_id, wrapper.order.data.order_key, referringPracticeMap, wrapper);
		}
		if (wrapper.order.data.orderItems != null) {
			Map<String, Id> procedureMapToUpsert = procedureProcessor(systemID, wrapper);
			Map<String, Id> orderItemMap = orderItemProcessor(orderID, procedureMapToUpsert, wrapper);

			orderbillingProcessor(systemID, orderItemMap, wrapper);
		}
		if (wrapper.order.data.orderExtraInfo != null) {
			orderExtraProcessor(orderID, systemID, wrapper, patientID);
		}
		if (wrapper.order.data.orderAlerts != null) {
			orderAlertProcessor(orderID, patientID, systemID, wrapper);
		}
		return orderID;
	}

	public Boolean orderExtraProcessor(Id orderID, Id systemID, DH_PatientInfoWrapper wrapper, Id patientId) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		List<String> orderExtraInfoKeys = new List<String>();
		List<DH_PatientOrderExtraInfo__c> orderExtralist = new List<DH_PatientOrderExtraInfo__c>();
		Boolean stopOrder = false;

		for (DH_PatientInfoWrapper.orderExtraInfo orderExtra : wrapper.order.data.orderExtraInfo) {
			String orderExtraRisUnique = utility.uniqueIdentifier(wrapper.patient.system_id, orderExtra.order_extra_info_key, System.label.DH_PatientOrderExtraInfoRecordTypeName);
			orderExtraInfoKeys.add(orderExtraRisUnique);

			DH_PatientOrderExtraInfo__c poe = new DH_PatientOrderExtraInfo__c();
			poe.Name = orderExtra.order_extra_info_code;
			poe.DH_Clinical_Service_Request__c = orderID;
			poe.DH_RIS_OrderExtraKey__c = orderExtraRisUnique;
			poe.DH_Order_Extra_Info_Key__c = orderExtra.order_extra_info_key;
			poe.DH_Order_Extra_Info_Code__c = orderExtra.order_extra_info_code;
			poe.DH_Value__c = orderExtra.value;
			orderExtralist.add(poe);

			if (orderExtra.order_extra_info_code == System.label.DH_StopOrder) {
				stopOrder = true;
			}
		}
		if (orderExtralist.size() > 0) {
			upsert orderExtralist DH_RIS_OrderExtraKey__c;
		}
		if (stopOrder == true) {
			doCallOptIn = false;
		} else {
			doCallOptIn = true;
		}
		if (doCallOptIn == true && isOptedOutMarketingCloud == true) {
			List<Id> patientIdsList = new List<Id>();
			patientIdsList.add(patientID);
			//DH_SendCallCenterDataSheetDatatoSFMC.sendOptInData(patientIdsList);
		}
		List<DH_PatientOrderExtraInfo__c> recordsToDelete = [SELECT Id FROM DH_PatientOrderExtraInfo__c WHERE DH_Clinical_Service_Request__c = :orderID AND DH_RIS_OrderExtraKey__c NOT IN :orderExtraInfoKeys];
		if (recordsToDelete.size() > 0) {
			delete recordsToDelete;
		}
		return true;
	}

	public Boolean orderAlertProcessor(Id orderID, Id patientID, Id systemID, DH_PatientInfoWrapper wrapper) {
		DH_RisUtilityClass utility = new DH_RisUtilityClass();
		CodeSetBundle code = [SELECT Id FROM CodeSetBundle WHERE Name = :System.label.DH_CodeSetBundleRecordName LIMIT 1];
		List<String> orderAlertKeys = new List<String>();
		List<ClinicalAlert> clinicalAlertListToUpsert = new List<ClinicalAlert>();
		for (DH_PatientInfoWrapper.OrderAlerts alert : wrapper.Order.data.orderAlerts) {
			String orderAlertRisUnique = utility.uniqueIdentifier(wrapper.patient.system_id, alert.patient_flag_code, System.label.DH_OrderAlertRecordTypeName);
			String orderAlertUnique = wrapper.patient.system_id + '_' + wrapper.order.data.order_key + '_' + alert.patient_flag_code + '_' + System.label.DH_OrderAlertRecordTypeName;
			orderAlertKeys.add(orderAlertUnique);

			ClinicalAlert cli = new ClinicalAlert();
			cli.SubjectId = patientID;
			cli.Status = System.label.cli_status;
			cli.CodeId = code != null ? code.Id : null;
			cli.DH_Clinical_Service_Request__c = orderID;
			cli.DH_Patient_Flag_Code__c = alert.patient_flag_code;
			cli.DH_RIS_PFlag_RecType_PKey__c = orderAlertUnique;
			cli.RecordTypeId = Schema.SObjectType.ClinicalAlert.getRecordTypeInfosByName().get(system.label.DH_OrderAlertRecordTypeName).getRecordTypeId();
			clinicalAlertListToUpsert.add(cli);
		}
		if (clinicalAlertListToUpsert.size() > 0) {
			upsert clinicalAlertListToUpsert DH_RIS_PFlag_RecType_PKey__c;
		}
		List<ClinicalAlert> clinicalAlertRecordsToDelete = [SELECT Id FROM ClinicalAlert WHERE SubjectId = :patientID AND RecordType.Name = :system.label.DH_OrderAlertRecordTypeName AND DH_RIS_PFlag_RecType_PKey__c NOT IN :orderAlertKeys];
		if (clinicalAlertRecordsToDelete.size() > 0) {
			delete clinicalAlertRecordsToDelete;
		}
		return true;
	}
}