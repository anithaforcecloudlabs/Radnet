/******************************************************************************************************************************************************
 *
 * @Created Date    : 3/13/2024,
 *
 * @description     : Apex class to parse the JSON to Wrapper Class
 *
 * @Jira Id         : CC-355
 *
 * */

global class DH_PatientInfoWrapper {
	public cls_patient patient;
	public cls_order order;
	public Study study;

	public class cls_patient {
		public String object_state;
		public String health_cloud_id;
		public String system_id;
		public String patient_prefix_code;
		public String patient_suffix_code;
		public cls_data data;
	}
	public class cls_data {
		public String patient_Key;
		public String first_name;
		public String last_name;
		public String middle_name;
		public String patient_id;
		public String issuer_of_patient_id;
		public String birth_date;
		public String gender_code;
		public String primary_address_line1;
		public String primary_address_line2;
		public String primary_address_city;
		public String primary_address_state;
		public String primary_address_zipcode;
		public String primary_language_code;
		public string master_patient_key;
		public PatientEmailAddresses[] patientEmailAddresses;
		public PatientPhones[] patientPhones;
		public PatientExtraInfo[] patientExtraInfo;
		public PatientAlerts[] patientAlerts;

		//Order Fields -  same using for new data model object - Clinical Service Request
		public String patient_class_code;
		public String order_key;
		public String um_required_flag;
		public String um_complete_flag;
		public Datetime requested_date;
		public Datetime entered_date;
		public String order_category_code;
		public String status_code;
		public String scheduling_next_fup_type_code;
		public Datetime scheduling_next_fup_date;
		public String confirmed_flag;
		public String filler_site_code;
		public String filler_practice_code;
		public String primary_carrier_code;
		public String secondary_carrier_code;
		public OrderAlerts[] orderAlerts;
		public OrderExtraInfo[] orderExtraInfo;
		public OrderItems[] orderItems;
		public Referring_Practices[] referring_practices;
		public Requested_by requested_by;
		public Requested_by_address requested_by_address;

		//Study Fields
		public String study_key;
		public String accession_number;
		public Datetime scheduled_start_date;
		public String scheduled_modality_code;
		public cls_studyItems[] studyItems;
		public studyExtraInfo[] studyExtraInfo;
		public Datetime created_date;
		public String cancelled_reason_code;
		public Datetime cancelled_date;
		public String tech_only_flag;
		public String reading_stat_flag;
		public String exam_stat_flag;
		public String site_code;
		public String practice_code;
	}

	public class PatientEmailAddresses {
		public String patient_email_key;
		public String email_address;
		public String primary_flag;
		public String display_order;
	}

	public class PatientPhones {
		public String patient_phone_key;
		public String phone_number;
		public String mobile_flag;
		public String primary_flag;
		public String display_order;
		public String description;
		public String master_mobile_flag;
	}

	public class PatientExtraInfo {
		public String patient_extra_info_key;
		public String patient_extra_info_code;
		public String value;
	}
	public class PatientAlerts {
		public String patient_flag_code;
	}
	public class cls_order {
		public String object_state;
		public String health_cloud_id;
		public string rescheduled_flag;
		public string created_with_study_flag;
		public boolean icode_eligible;
		public String new_or_rescheduled;
		public string shortened_icode_url;
		public cls_data data;
	}

	public class Requested_by {
		public String person_key;
		public String first_name;
		public String last_name;
		public String npi;
		public string id;
		public string suffixCode;
	}
	public class Requested_by_address {
		public String person_address_key;
		public String address_line1;
		public String address_line2;
		public String city;
		public String state;
		public String zipcode;
	}
	public class Referring_Practices {
		public String referring_practice_key;
		public String practice_name;
	}
	public class OrderItems {
		public String order_item_key;
		public String active_flag;
		public string ProcedureCode;
		public string Description;
		public string groupCode;
		public String sequence_id;
        public String body_part_code;
		public cls_orderBillingCodes[] orderBillingCodes;
	}

	public class cls_orderBillingCodes {
		public String order_item_key;
		public String active_flag;
		public string orderbilling_code;
		public string orderdescription;
		public string pre_cert_status;
	}

	public class OrderExtraInfo {
		public String order_extra_info_key;
		public String order_extra_info_code;
		public String value;
	}
	public class OrderAlerts {
		public String patient_flag_code;
	}
	public class Study {
		public String object_state;
		public String health_cloud_id;
		public cls_data data;
	}

	public class cls_studyItems {
		public String study_item_key;
		public String active_flag;
		public string ProcedureCode;
		public string Description;
		public string groupCode;
		public string bodyPartCode;
		public string lateralitycode;
		public cls_studyBillingCodes[] studyBillingCodes;
	}

	public class cls_studyBillingCodes {
		public String study_item_key;
		public String active_flag;
		public String orderbilling_code;
		public String orderdescription;
		public String pre_cert_status;
	}
	public class studyExtraInfo {
		public String study_extra_info_key;
		public String study_extra_info_code;
		public String value;
	}
	public static DH_PatientInfoWrapper parse(String json) {
		return (DH_PatientInfoWrapper) System.JSON.deserialize(json, DH_PatientInfoWrapper.class);
	}
}