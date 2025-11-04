/*
* ***************************************************************************************************************************
* Apex Class Name - DH_RisTestDataFactory
* Created Date - 27-May-2024
* @description       : Utility class for test data setup for all functionalities.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-355                   20-Jun-2024          Original Version
* CC-943				   24-Sep-2024			Added NULL value to HealthCloudId.
* CC-943				   07-Oct-2024			Updated Test Data for Modality&Healthcare Procedure Issue.
* *******************************************************************************************************************************************
*/
public class DH_RisTestDataFactory {
	public static String insertParase() {
	String json =
			'{' +
			'  "patient": {' +
			'    "object_state": "modified",' +
			'    "health_cloud_id": null,' +
			'    "system_id": "CA",' +
			'    "data": {' +
			'      "patient_key": "26360779",' +
			'      "first_name": "SFTestA",' +
			'      "last_name": "Test",' +
			'      "middle_name": "qqqq",' +
			'      "patient_id": "29571315",' +
			'      "issuer_of_patient_id": "system",' +
			'      "birth_date": "1977-05-05T00:00:00",' +
			'      "gender_code": "M",' +
			'      "primary_address_line1": "23 Charlie St",' +
			'      "primary_address_line2": "address line 2",' +
			'      "primary_address_city": "Beverly Hills",' +
			'      "primary_address_state": "CA",' +
			'      "primary_address_zipcode": "90210",' +
			'      "primary_language_code": "EN",' +
			'      "master_patient_key": "398798798",' +
			'      "patientPhones": [' +
			'        {' +
			'          "patient_phone_key": "36745269",' +
			'          "phone_number": "(902) 555-1212",' +
			'          "mobile_flag": "Y",' +
			'          "primary_flag": "Y",' +
			'          "display_order": "1",' +
			'          "description": "Mobile",' +
			'          "master_mobile_flag": "Y"' +
			'        }' +
			'      ],' +
			'      "patientEmailAddresses": [' +
			'        {' +
			'          "patient_email_key": "3409854",' +
			'          "email_address": "a@b.com",' +
			'          "primary_flag": "Y",' +
			'          "display_order": "1"' +
			'        }' +
			'      ],' +
			'      "patientExtraInfo": [' +
			'        {' +
			'          "patient_extra_info_key": "234",' +
			'          "patient_extra_info_code": "STPALL",' +
			'          "value": "STPALL"' +
			'        }' +
			'      ],' +
			'      "patientAlerts": [' +
			'        {' +
			'          "patient_flag_code": "patient Alert updated"' +
			'        }' +
			'      ]' +
			'    },' +
			'    "patient_prefix_code": "MR",' +
			'    "patient_suffix_code": "IT"' +
			'  },' +
			'  "order": {' +
			'    "object_state": "modified",' +
			'    "health_cloud_id": null,' +
			'    "rescheduled_flag": "N",' +
			'    "created_with_study_flag": "N",' +
			'    "shortened_icode_url": "http://shortenedurl.com/ab732f3c",' +
			'    "data": {' +
			'      "patient_class_code": "O",' +
			'      "order_key": "63983176",' +
			'      "um_required_flag": "N",' +
			'      "um_complete_flag": "N",' +
			'      "requested_date": "2024-06-19T12:42:23.6855801Z",' +
			'      "entered_date": "2024-06-19T12:43:19.5784031Z",' +
			'      "order_category_code": "OBC Code",' +
			'      "status_code": "OrderSigned",' +
			'      "scheduling_next_fup_type_code": "test",' +
			'      "scheduling_next_fup_date": "2024-06-19T12:43:19.5784031Z",' +
			'      "confirmed_flag": "Y",' +
			'      "requested_by": {' +
			'        "person_key": "137789",' +
			'        "first_name": "AIMEE",' +
			'        "last_name": "SMITH",' +
			'        "npi": "1982882411",' +
			'        "id": "4718547IDX",' +
			'        "name_suffix_code.patient_suffix_code": "NP"' +
			'      },' +
			'      "requested_by_address": {' +
			'        "person_address_key": "166088",' +
			'        "address_line1": "1600 CREEKSIDE DR",' +
			'        "address_line2": "STE 3300",' +
			'        "city": "FOLSOM",' +
			'        "state": "CA        ",' +
			'        "zipcode": "95630     "' +
			'      },' +
			'      "referring_practices": [' +
			'        {' +
			'          "referring_practice_key": "1274",' +
			'          "practice_name": "CALIFORNIA MEDICAL CLINIC"' +
			'        }' +
			'      ],' +
			'      "filler_site_code": "SFI",' +
			'      "filler_practice_code": "BRS",' +
			'      "orderItems": [' +
			'        {' +
			'          "order_item_key": "72147954",' +
			'          "active_flag": "Y",' +
			'          "procedure_code.procedure_code": null,' +
			'          "procedure_code.description": "US Guided Varicose Veins Unilateral Radiofrequency Ablation, Multiple Veins",' +
			'          "procedure_code.procedure_group_code": null,' +
			'          "sequence_id": "0",' +
			'          "orderBillingCodes": [' +
			'            {' +
			'              "order_item_key": "72147954",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "36475",' +
			'              "billing_code.description": "ENDOVEN ABLTJ INCMPTNT VEIN XTR RF 1ST VEIN",' +
			'              "pre_cert_status": "N"' +
			'            },' +
			'            {' +
			'              "order_item_key": "72147954",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "36476",' +
			'              "billing_code.description": "ENDOVEN ABLTJ INCMPTNT VEIN XTR RF 2ND+ VEINS",' +
			'              "pre_cert_status": "N"' +
			'            }' +
			'          ]' +
			'        },' +
			'        {' +
			'          "order_item_key": "72147955",' +
			'          "active_flag": "N",' +
			'          "procedure_code.procedure_code": null,' +
			'          "procedure_code.description": "US Abdomen Complete and Retro Limited ",' +
			'          "procedure_code.procedure_group_code": null,' +
			'          "sequence_id": "1",' +
			'          "orderBillingCodes": [' +
			'            {' +
			'              "order_item_key": "72147955",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "76700",' +
			'              "billing_code.description": "ULTRASOUND, ABDOMINAL, REAL TIME WITH IMAGE DOCUMENTATION; COMPLETE",' +
			'              "pre_cert_status": "Required"' +
			'            },' +
			'            {' +
			'              "order_item_key": "72147955",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "76775",' +
			'              "billing_code.description": "ULTRASOUND, RETROPERITONEAL (EG, RENAL, AORTA, NODES), REAL TIME WITH IMAGE DOCUMENTATION; LIMITED",' +
			'              "pre_cert_status": "Required"' +
			'            }' +
			'          ]' +
			'        }' +
			'      ],' +
			'      "primary_carrier_code": "06010518",' +
			'      "secondary_carrier_code": "0601051833",' +
			'      "orderExtraInfo": [' +
			'        {' +
			'          "order_extra_info_key": "12677622",' +
			'          "order_extra_info_code": "STPORDER",' +
			'          "value": "N"' +
			'        },' +
			'        {' +
			'          "order_extra_info_key": "12677623",' +
			'          "order_extra_info_code": "health_cloud_id",' +
			'          "value": "0jyVa0000000ScDIAU"' +
			'        },' +
			'        {' +
			'          "order_extra_info_key": "12677624",' +
			'          "order_extra_info_code": "KioskURL",' +
			'          "value": "https://myradiologyconnectportal.com/Online_Forms_Test/DigitalForms/PatientKioskLanding?clientKey=4NXfNNw5b258MtU&kioskToken=8CFA9FAD6584A444151B25C31579753EC68E9E2D&pkey=26360779"' +
			'        },' +
			'        {' +
			'          "order_extra_info_key": "12677626",' +
			'          "order_extra_info_code": "STPORDER",' +
			'          "value": "Y"' +
			'        }' +
			'      ],' +
			'      "orderAlerts": [' +
			'        {' +
			'          "patient_flag_code": "updated Order Alert Code"' +
			'        }' +
			'      ]' +
			'    }' +
			'  },' +
			'  "study": {' +
			'    "object_state": "modified",' +
			'    "health_cloud_id": null,' +
			'    "data": {' +
			'      "study_key": "65659171",' +
			'      "accession_number": "35928502-TRAIN",' +
			'      "scheduled_start_date": "2024-06-19T16:30:00Z",' +
			'      "scheduled_modality_code.modality_code": "SFIUS1",' +
			'      "created_date": "2024-06-19T12:49:22.8046989Z",' +
			'      "cancelled_reason_code": "test can",' +
			'      "cancelled_date": "2024-06-19T12:49:22.8046989Z",' +
			'      "tech_only_flag": "Y",' +
			'      "reading_stat_flag": "N",' +
			'      "exam_stat_flag": "N",' +
			'      "status_code": "Scheduled",' +
			'      "site_code": "SFI",' +
			'      "practice_code": "BRS",' +
			'      "studyItems": [' +
			'        {' +
			'          "study_item_key": "67586196",' +
			'          "active_flag": "Y",' +
			'          "procedure_code.procedure_code": null,' +
			'          "procedure_code.description": "US Guided Varicose Veins Unilateral Radiofrequency Ablation, Multiple Veins",' +
			'          "procedure_code.procedure_group_code": null,' +
			'          "body_part_code.body_part_code": null,' +
			'          "laterality_code.laterality_code": null,' +
			'          "studyBillingCodes": [' +
			'            {' +
			'              "study_item_key": "67586196",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "36475",' +
			'              "billing_code.description": "ENDOVEN ABLTJ INCMPTNT VEIN XTR RF 1ST VEIN",' +
			'              "pre_cert_status": "N"' +
			'            },' +
			'            {' +
			'              "study_item_key": "67586196",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "36476",' +
			'              "billing_code.description": "ENDOVEN ABLTJ INCMPTNT VEIN XTR RF 2ND+ VEINS",' +
			'              "pre_cert_status": "N"' +
			'            }' +
			'          ]' +
			'        }' +
			'      ],' +
			'      "studyExtraInfo": [' +
			'        {' +
			'          "study_extra_info_key": "40742494",' +
			'          "study_extra_info_code": "health_cloud_id",' +
			'          "value": "0jQVa0000000D6vMAE"' +
			'        }' +
			'      ]' +
			'    }' +
			'  }' +
			'}';
		return json;
	}
	public static String updatedData() {
		String json =
			'{' +
			'  "patient": {' +
			'    "object_state": "modified",' +
			'    "health_cloud_id": null,' +
			'    "system_id": "CA",' +
			'    "data": {' +
			'      "patient_key": "26360779",' +
			'      "first_name": "SFTestA",' +
			'      "last_name": "Test",' +
			'      "middle_name": "qqqq",' +
			'      "patient_id": "29571315",' +
			'      "issuer_of_patient_id": "system",' +
			'      "birth_date": "1977-05-05T00:00:00",' +
			'      "gender_code": "M",' +
			'      "primary_address_line1": "23 Charlie St",' +
			'      "primary_address_line2": "address line 2",' +
			'      "primary_address_city": "Beverly Hills",' +
			'      "primary_address_state": "CA",' +
			'      "primary_address_zipcode": "90210",' +
			'      "primary_language_code": "EN",' +
			'      "master_patient_key": "398798798",' +
			'      "patientPhones": [' +
			'        {' +
			'          "patient_phone_key": "367452690",' +
			'          "phone_number": "(902) 555-0000",' +
			'          "mobile_flag": "Y",' +
			'          "primary_flag": "Y",' +
			'          "display_order": "1",' +
			'          "description": "Mobile",' +
			'          "master_mobile_flag": "Y"' +
			'        }' +
			'      ],' +
			'      "patientEmailAddresses": [' +
			'        {' +
			'          "patient_email_key": "34098541",' +
			'          "email_address": "abcd@b.com",' +
			'          "primary_flag": "Y",' +
			'          "display_order": "1"' +
			'        }' +
			'      ],' +
			'      "patientExtraInfo": [' +
			'        {' +
			'          "patient_extra_info_key": "2340",' +
			'          "patient_extra_info_code": "STPEML",' +
			'          "value": "STPALL"' +
			'        }' +
			'      ],' +
			'      "patientAlerts": [' +
			'        {' +
			'          "patient_flag_code": "patient Alert updated New"' +
			'        }' +
			'      ]' +
			'    },' +
			'    "patient_prefix_code": "MR",' +
			'    "patient_suffix_code": "IT"' +
			'  },' +
			'  "order": {' +
			'    "object_state": "modified",' +
			'    "health_cloud_id": null,' +
			'    "rescheduled_flag": "N",' +
			'    "created_with_study_flag": "N",' +
			'    "shortened_icode_url": "http://shortenedurl.com/ab732f3c",' +
			'    "data": {' +
			'      "patient_class_code": "O",' +
			'      "order_key": "63983176",' +
			'      "um_required_flag": "Y",' +
			'      "um_complete_flag": "Y",' +
			'      "requested_date": "2024-06-19T12:42:23.6855801Z",' +
			'      "entered_date": "2024-06-19T12:43:19.5784031Z",' +
			'      "order_category_code": "OBC Code",' +
			'      "status_code": "OrderSigned",' +
			'      "scheduling_next_fup_type_code": "test",' +
			'      "scheduling_next_fup_date": "2024-06-19T12:43:19.5784031Z",' +
			'      "confirmed_flag": "Y",' +
			'      "requested_by": {' +
			'        "person_key": "137789",' +
			'        "first_name": "AIMEE",' +
			'        "last_name": "SMITH",' +
			'        "npi": "1982882411",' +
			'        "id": "4718547IDX",' +
			'        "name_suffix_code.patient_suffix_code": "NP"' +
			'      },' +
			'      "requested_by_address": {' +
			'        "person_address_key": "166088",' +
			'        "address_line1": "1600 CREEKSIDE DR",' +
			'        "address_line2": "STE 3300",' +
			'        "city": "FOLSOM",' +
			'        "state": "CA        ",' +
			'        "zipcode": "95630     "' +
			'      },' +
			'      "referring_practices": [' +
			'        {' +
			'          "referring_practice_key": "1274",' +
			'          "practice_name": "CALIFORNIA MEDICAL CLINIC"' +
			'        }' +
			'      ],' +
			'      "filler_site_code": "SFI",' +
			'      "filler_practice_code": "BRS",' +
			'      "orderItems": [' +
			'        {' +
			'          "order_item_key": "72147954100",' +
			'          "active_flag": "Y",' +
			'          "procedure_code.procedure_code": null,' +
			'          "procedure_code.description": "US Guided Varicose Veins Unilateral Radiofrequency Ablation, Multiple Veins",' +
			'          "procedure_code.procedure_group_code": null,' +
			'          "sequence_id": "0",' +
			'          "orderBillingCodes": [' +
			'            {' +
			'              "order_item_key": "72147954100",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "36475",' +
			'              "billing_code.description": "ENDOVEN ABLTJ INCMPTNT VEIN XTR RF 1ST VEIN",' +
			'              "pre_cert_status": "N"' +
			'            },' +
			'            {' +
			'              "order_item_key": "72147954100",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "36476",' +
			'              "billing_code.description": "ENDOVEN ABLTJ INCMPTNT VEIN XTR RF 2ND+ VEINS",' +
			'              "pre_cert_status": "N"' +
			'            }' +
			'          ]' +
			'        },' +
			'        {' +
			'          "order_item_key": "72147955",' +
			'          "active_flag": "N",' +
			'          "procedure_code.procedure_code": null,' +
			'          "procedure_code.description": "US Abdomen Complete and Retro Limited ",' +
			'          "procedure_code.procedure_group_code": null,' +
			'          "sequence_id": "1",' +
			'          "orderBillingCodes": [' +
			'            {' +
			'              "order_item_key": "72147955",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "76700",' +
			'              "billing_code.description": "ULTRASOUND, ABDOMINAL, REAL TIME WITH IMAGE DOCUMENTATION; COMPLETE",' +
			'              "pre_cert_status": "Required"' +
			'            },' +
			'            {' +
			'              "order_item_key": "72147955",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "76775",' +
			'              "billing_code.description": "ULTRASOUND, RETROPERITONEAL (EG, RENAL, AORTA, NODES), REAL TIME WITH IMAGE DOCUMENTATION; LIMITED",' +
			'              "pre_cert_status": "Required"' +
			'            }' +
			'          ]' +
			'        }' +
			'      ],' +
			'      "primary_carrier_code": "06010518",' +
			'      "secondary_carrier_code": "0601051833",' +
			'      "orderExtraInfo": [' +
			'        {' +
			'          "order_extra_info_key": "12677622",' +
			'          "order_extra_info_code": "STPORDER",' +
			'          "value": "N"' +
			'        },' +
			'        {' +
			'          "order_extra_info_key": "1267762311",' +
			'          "order_extra_info_code": "new ORder Extra",' +
			'          "value": "0jyVa0000000ScDIAU"' +
			'        },' +
			'        {' +
			'          "order_extra_info_key": "1267762114",' +
			'          "order_extra_info_code": "KioskURL",' +
			'          "value": "https://myradiologyconnectportal.com/Online_Forms_Test/DigitalForms/PatientKioskLanding?clientKey=4NXfNNw5b258MtU&kioskToken=8CFA9FAD6584A444151B25C31579753EC68E9E2D&pkey=26360779"' +
			'        },' +
			'        {' +
			'          "order_extra_info_key": "1267762611",' +
			'          "order_extra_info_code": "Remove Order",' +
			'          "value": "Y"' +
			'        }' +
			'      ],' +
			'      "orderAlerts": [' +
			'        {' +
			'          "patient_flag_code": "updated Order Alert Code New"' +
			'        }' +
			'      ]' +
			'    }' +
			'  },' +
			'  "study": {' +
			'    "object_state": "modified",' +
			'    "health_cloud_id": null,' +
			'    "data": {' +
			'      "study_key": "65659171",' +
			'      "accession_number": "35928502-TRAIN",' +
			'      "scheduled_start_date": "2024-06-19T16:30:00Z",' +
			'      "scheduled_modality_code.modality_code": "SFIUS1",' +
			'      "created_date": "2024-06-19T12:49:22.8046989Z",' +
			'      "cancelled_reason_code": "test can",' +
			'      "cancelled_date": "2024-06-19T12:49:22.8046989Z",' +
			'      "tech_only_flag": "Y",' +
			'      "reading_stat_flag": "N",' +
			'      "exam_stat_flag": "N",' +
			'      "status_code": "Scheduled",' +
			'      "site_code": "SFI",' +
			'      "practice_code": "BRS",' +
			'      "studyItems": [' +
			'        {' +
			'          "study_item_key": "6758619600",' +
			'          "active_flag": "Y",' +
			'          "procedure_code.procedure_code": null,' +
			'          "procedure_code.description": "US Guided Varicose Veins Unilateral Radiofrequency Ablation, Multiple Veins",' +
			'          "procedure_code.procedure_group_code": null,' +
			'          "body_part_code.body_part_code": null,' +
			'          "laterality_code.laterality_code": null,' +
			'          "studyBillingCodes": [' +
			'            {' +
			'              "study_item_key": "6758619600",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "36475",' +
			'              "billing_code.description": "ENDOVEN ABLTJ INCMPTNT VEIN XTR RF 1ST VEIN",' +
			'              "pre_cert_status": "N"' +
			'            },' +
			'            {' +
			'              "study_item_key": "6758619600",' +
			'              "active_flag": "Y",' +
			'              "billing_code.billing_code": "36476",' +
			'              "billing_code.description": "ENDOVEN ABLTJ INCMPTNT VEIN XTR RF 2ND+ VEINS",' +
			'              "pre_cert_status": "N"' +
			'            }' +
			'          ]' +
			'        }' +
			'      ],' +
			'      "studyExtraInfo": [' +
			'        {' +
			'          "study_extra_info_key": "4074249411",' +
			'          "study_extra_info_code": "New Value Test",' +
			'          "value": "0jQVa0000000D6vMAE"' +
			'        }' +
			'      ]' +
			'    }' +
			'  }' +
			'}';
		return json;
	}
}