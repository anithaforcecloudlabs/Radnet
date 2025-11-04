/*
 *********************************************************

Apex Class         : DH_KMConstants
    
Created Date       : May 14, 2024
    
@description       : Global Constant Class for Knowledge Management


 *********************************************************
 */
public class DH_KMConstants {
    public static final string SS_FUNCTION_NAME_DIRECTION = 'functionDirection';
    public static final string SS_FUNCTION_NAME_REMOVE_MARKER = 'RemoveMarker';
    public static final string SS_FUNCTION_NAME_ADD_MARKER = 'AddMarkerForInputAddress';
    public static final string SS_FUNCTION_NAME_REMOVE_ALL_MARKER = 'removeAllMarkers';
    public static final string SS_LIGHTNING_ACCOUNT_URL = '/lightning/r/Account/';
    public static final string SS_POPUPCONTENT_NAME = '<strong>Name:</strong> <a id="vfMessage" ';
    public static final string SS_POPUPCONTENT_TARGET = ' style="cursor:pointer;" onclick="handleNameClick()" value="';
    public static final string SS_CLOSE_ANCHOR_TAG = '">';
    public static final string SS_POPUPCONTENT_ADDRESS = '<strong>Address: </strong>';
    public static final string SS_INPUTADDRESSVALUE = 'InputAddressValue';
    public static final string SS_MAPID_FIRST = 'MapId1';
    public static final string SS_MAPID_SECOND = 'MapId2';
    public static final string SS_GOOGLE_PARAMETER_NAME = '?api=1&origin=';
    public static final string SS_GOOGLE_PARAMETER_DESTINATION = '&destination=';
    public static final String HELPER_LOCATIONIQ = 'locationiq';
    public static final string SS_SITE_DOT_COM = System.Label.DH_Site_Dot_Com;
    public static final string SS_RADNETCOMMPORTAL_DETAIL = System.Label.DH_Radnet_Community_Portal_Detail;
    
    public static final string EX_ACCOUNT_RECORDTYPE_NAME = 'Practice';
    public static final string EX_ACCOUNT_RECORDTYPE_NAME_VP = 'Virtual Practice';
    public static final string EX_CARESPECIALTY_RECORDTYPE_NAME = 'KM Modality';
    public static final string EX_HEALTHCARE_RECORDTYPE_NAME = 'KM Healthcare Procedure';
    
    public static final string EX_DH_HEALTHCARE_RECORDTYPE_NAME = 'DH KM Healthcare Procedure';
    public static final string EX_SYNC_BUTTON_LABEL = System.Label.DH_Sync_Button_Label;
    public static final string EX_SYNC_SUCCESS_MSG = System.Label.DH_Sync_Success_Message;
    public static final string EX_ALREADY_SYNCED_MSG = System.Label.DH_Already_Sync_Message;
    public static final string EX_SUCCESS = System.Label.DH_Success;
    public static final string EX_SYNCED = System.Label.DH_Synced;
    
    public static final string EX_ROWNO = 'rowNo';
    public static final string EX_ROW_NUMBER = 'Row Number-';
    public static final string EX_PRACTICE_CODE_EMPTY_ERROR = ' causing error because the value for practice code is an empty string';
    public static final string EX_MODALITY_CODE_EMPTY_ERROR = ' causing error because the value for modality code is an empty string';
    public static final string EX_PRACTICE_CODE_NOT_FOUND = ' causing error because no such practice(';
    public static final string EX_MODALITY_CODE_NOT_FOUND = ' causing error because no such modality code(';
    public static final string EX_FOUND_IN_DB = ') found in database';
    public static final string EX_PRACTICE_CODE = 'practiceCode';
    public static final string EX_MODALITY_CODE = 'modalityCode';
    public static final string EX_PROCEDURE_DESCRIPTION = 'procedureDescription';
    public static final string EX_PROCEDURE_CODE = 'procedureCode';
    public static final string EX_BODY_PART = 'bodyPart';
    public static final string EX_CLINICAL_INDICATION = 'clinicalIndication';
    public static final string EX_SPECIAL_INSTRUCTIONS = 'specialInstructions';
    public static final string EX_CAUSING_ERROR_MSG = ' causing error because of ';
    
    public static final string EX_SUCCESS_MESSAGE = 'File Uploaded Successfully!';
    public static final string EX_CHOOSE_FILE_MESSAGE = 'Please choose a file';
    public static final string EX_ERRORS_FOUND = 'Errors Found';
    public static final string EX_WRONG_FILE_TYPE_MESSAGE = 'Please upload file of extension : "xlsx" or "xls"';
    public static final string EX_WRONG_EXCEL_FILE_MESSAGE = 'File data is not compatible for the object data please upload correct "xlsx" or "xls" file';
    public static final string EX_PRACTICE_CODE_HEADER = 'Practice Code(s)';
    public static final string EX_MODALITY_CODE_HEADER = 'Modality Code(s)';
    public static final string EX_PROCEDURE_DESCRIPTION_HEADER = 'Procedure Description';
    public static final string EX_PROCEDURE_CODE_HEADER = 'Procedure Code(s)';
    public static final string EX_BODY_PART_HEADER = 'Body Part(s)';
    public static final string EX_CLINICAL_INDICATION_HEADER = 'Clinical Indication(s)';
    public static final string EX_SPECIAL_INSTRUCTION_HEADER = 'Special Instructions';
    public static final string EX_NO_RECORDS_MESSAGE = 'No Records Found. Please select valid file';
    public static final string RECENTLY_VIEWED_TYPE = 'Knowledge__ka';
    public static final string PUBLISH_STATUS_ONLINE = 'Online';
    public static final string PUBLISH_STATUS_ARCHIVED = 'Archived';
    
    public static final string OBJECT_NAME_KNOWLEDGE_KAV = 'Knowledge__kav';
    public static final string OBJECT_NAME_KNOWLEDGE_ARTICLE_VERSION = 'KnowledgeArticleVersion';
    
    public static final string DATA_CATEGORY_GROUP = 'Data_Category_Group__c';
    public static final string EAST_SUB_CATEGORIES = 'East_Sub_Categories__c';
    public static final string EAST_CATEGORIES = 'East_Categories__c';
    public static final string WEST_SUB_CATEGORIES = 'West_Sub_Categories__c';
    public static final string WEST_CATEGORIES = 'West_Categories__c';
    
    public static final string KNOWLEDGE_SEARCH_EAST_COAST_USER = 'Knowledge_Search_East_Coast_User';
    public static final string KNOWLEDGE_SEARCH_MANAGER_EAST = 'Knowledge_Search_Manager_East';
    public static final string KNOWLEDGE_SEARCH_WEST_COAST_USER = 'Knowledge_Search_West_Coast_User';
    public static final string KNOWLEDGE_SEARCH_MANAGER_WEST = 'Knowledge_Search_Manager_West';
    
    public static final string SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final string RADNET_SCHEDULER = 'Radnet Scheduler';
    public static final string RADNET_MANAGER = 'Radnet Manager';
    public static final string USER_EMAIL_EAST = 'radSchEast@testorg.com';
    public static final string USER_EMAIL_WEST = 'radSchWest@testorg.com';
    
    public static final string RIS_INSTANCE_RIS_SYSTEM= 'RIS Instance / RIS System';
    public static final string PRACTICE_RECORD_TYPE= 'Practice';
    public static final string PAYER_RECORD_TYPE= 'Payer';
    public static final string MODALITY_SEARCH_PERMISSION_SET= 'Modality_Search_Permission_Set';
    public static final string HEALTHCLOUD_FOUNDATION_PERMISSION_SET= 'HealthCloudFoundation';
    public static final string SITE_SEARCH_SUPER_USER = 'Site_Search_Super_User';
    public static final string SITE_SEARCH_PERMISSION_SET = 'Site_Search_Permission_Set';
    public static final string USER_EAST= 'User_East';
    public static final string ARTICLE_TYPE_EAST = 'East';
    public static final string ARTICLE_TYPE_WEST = 'West';
    public static final string ARTICLE_TYPE_GLOBAL = 'Global';
    public static final string NJIN = '(NJIN) New Jersey Imaging Network';
    public static final string COAST_EAST = 'East';
    public static final string COAST_WEST = 'West';
    public static final string ACCOUNT_COAST_FIELD_EAST = 'East coast';
    public static final string ACCOUNT_COAST_FIELD_WEST = 'West coast';
    
    public static final string REGION_MA = 'MA';
    public static final string REGION_NE = 'NE';
    public static final string REGION_FL = 'FL';
    public static final string ACCOUNT_RECORDTYPE_SITE = 'Site';
    
    public static final string MODALITY_XRAY = 'X Ray';
    public static final string MODALITY_DEXA = 'Dexa';
    public static final string MODALITY_FLUOROSCOPY = 'Fluoroscopy';
    public static final string MODALITY_ULTRASOUND = 'Ultrasound';
    public static final string MODALITY_MRI = 'MRI';
    public static final string MODALITY_CT = 'CT';
    public static final string MODALITY_NM = 'Nuclear Medicine';
    public static final string MODALITY_PETCT = 'PET / CT';
    
    public static final string REGION_NORTH = 'North';
    public static final string REGION_SOUTH = 'South';
    public static final string NJIN_PRACTICE_CODE = 'NJIN';
    
    public static final string RADNET_COMMUNITY_PROFILE = 'Radnet Community Portal Profile';
    
    public static final string CLONED_EX_HEALTHCARE_RECORDTYPE_NAME = 'DH_KM_Healthcare_Procedure';
    public static final string ACCOUNT_EAST_COAST = 'East Coast';
    public static final string ACCOUNT_WEST_COAST = 'West Coast';
    
    // Changes in DH_SiteSearchVFController, FileController, DH_SiteSearchOptions
    public static final string DDC = System.Label.DH_DDC;
    public static final string FORCECOM = System.Label.DH_Vf_Force_Dot_Com;
    public static final string SITECOM = System.Label.DH_My_Site_Dot_Com;
    public static final string DOTMYDOT = System.Label.DH_My;
    public static final string LIGHTNING_FORCECOM = System.Label.DH_Lightning_Force_Dot_Com;
    
    // Changes in DH_SiteSearchOptions
    public static final string GUEST = System.Label.DH_Guest;
    public static final string SANDBOX = System.Label.DH_Sandbox;
    
    // Changes in DH_ContentDocumentLinkTriggerHandler
    public static final string INTERNALUSERS = System.Label.DH_InternalUsers;
    public static final string ALLUSERS = System.Label.DH_AllUsers;
    
    public static final Integer SIX =  Integer.valueOf(System.Label.DH_SIX);
    
    //Changes in KnowledgeDataCategoryApex trigger handler 

    public static final string ERRORFOREASTSUBCATEGORY = System.Label.DH_AddErrorForEastSubCategory;
    public static final string ERRORFORWESTSUBCATEGORY = System.Label.DH_AddErrorForWestSubCategory;
    public static final string INVALIDCATEGORYMAPPINGERROR = System.Label.DH_InvalidCategoryMappingError;
    public static final string DEPENDENTPICKLISTFORKNOWLEDGECATEGORIES = System.Label.DH_DependentPicklistForKnowledgeCategories;

    //constants for go live calendar controller
    public static final string GO_LIVE_DATE_ANY = 'Any';
    public static final string GO_LIVE_DATE_PAST_90_DAYS = 'Past 90 Days';
    public static final string GO_LIVE_DATE_PAST_30_DAYS = 'Past 30 Days';
    public static final string GO_LIVE_DATE_NEXT_30_DAYS = 'Next 30 Days';
    public static final string GO_LIVE_DATE_NEXT_90_DAYS = 'Next 90 Days';
    public static final string GO_LIVE_DATE_ARCHIVE_90_OLD = 'Archive(>90 Old)';

}