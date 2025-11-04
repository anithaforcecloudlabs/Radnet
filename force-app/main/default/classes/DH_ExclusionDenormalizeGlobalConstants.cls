/*
* ***************************************************************************************************************************
* Apex Class Name - DH_GlobalConstants
* Version - 0.1
* Created Date - 22-May-2024
* Function - Class to store constant values across platform.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Prasanna Anjankar                 22-May-2024          Initial version.
* *****************************************************************************************************************************
*/

public class DH_ExclusionDenormalizeGlobalConstants {

    public static final string EXCLUSION_RECORD_TYPE_NAME = 'Exclusions';
    public static final string MODALITY_PRIORITY_RECORD_TYPE_NAME = 'Modality Priority';
    public static final string CALL_CENTER_HOUR_RECORD_TYPE_NAME = 'Call Center Hours';
    public static final string CALL_CENTER_MAPPING_RECORD_TYPE_NAME = 'Call Center Mapping';
    public static final string REGION_RECORD_TYPE_NAME='RIS Instance / RIS System';
    public static final string SITE_RECORD_TYPE_NAME='Site';
    public static final string PRACTICE_RECORD_TYPE_NAME='Practice';
    public static final string PAYER_RECORD_TYPE_NAME='Payer';
    public static final string REF_GROUP_PRACTICE_NAME_NAME='Referring Practice';
    public static final string REF_DR_PRACTICE_ID_NAME='Physician';
    public static final string HEALTHCARE_PROCEDURE_MARKETING_RECORD_TYPE_NAME = 'Marketing Healthcare Procedure';
    

    public static final string EXCLUSION_RECORD_TYPE_Id =Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
	public static final string MODALITY_PRIORITY_RECORD_TYPE_Id =Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Modality Priority').getRecordTypeId();
	public static final string CALL_CENTER_HOUR_RECORD_TYPE_Id=Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
	public static final string CALL_CENTER_MAPPING_RECORD_TYPE_Id = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
    // public static final string HEALTHCARE_PROC_MARKETING_RECORD_TYPE_NAME='';
    public static final string CARE_SPECIALITY_MARKETING_RECORD_TYPE_NAME='Marketing Carespeciality';
    // public static final string CALL_CENTER_RECORD_TYPE_NAME='';

    // public static final string EXCLUSION_RECORD_TYPE_ID = '';
    // public static final string MODALITY_PRIORITY_RECORD_TYPE_ID = '';
    // public static final string CALL_CENTER_HOUR_RECORD_TYPE_ID = '';
    // public static final string CALL_CENTER_MAPPING_RECORD_TYPE_ID = '';
    public static final string REGION_RECORD_TYPE_ID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('RIS Instance / RIS System').getRecordTypeId();
    public static final string SITE_RECORD_TYPE_ID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
    public static final string PRACTICE_RECORD_TYPE_ID= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice').getRecordTypeId();
    public static final string PAYER_RECORD_TYPE_ID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();
    public static final string REF_GROUP_PRACTICE_NAME_ID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referring Practice').getRecordTypeId();
    public static final string REF_DR_PRACTICE_ID_ID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
    // public static final string HEALTHCARE_PROC_MARKETING_RECORD_TYPE_ID='';
    // public static final string CARE_SPECIALITY_MARKETING_RECORD_TYPE_ID='';
    // public static final string CALL_CENTER_RECORD_TYPE_ID='';

    public static final string OPERATION_TYPE_INSERT = 'insert';
    public static final string OPERATION_TYPE_UPDATE = 'update';
}