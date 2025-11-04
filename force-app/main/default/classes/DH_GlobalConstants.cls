/*
* ***************************************************************************************************************************
* Apex Class Name - DH_GlobalConstants
* Created Date - 22-May-2024
* @description       : Class to store constant values across platform.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-425                   22-May-2024          Added DH_VERIFY_CALLER_CLASS variable.
* CC-426                   27-May-2024          Added DH_PATIENT_SEARCH_CLASS,RIS_NEW_PATIENT_SERVICE variables.
* CC-430                   27-May-2024          Added RIS_SEARCH_PATIENT_SERVICE variable.
* CC-428                   29-May-2024          Added CASE_STATUS_NEW,CASE_PRIORITY_LOW,SUCCESS,FAILURE and CASE_SUBJECT variables.
* CC-429                   29-May-2024          Added PERSON_ACCOUNT_RECORD_TYPE_ID variables.
* CC-572                   06-Aug-2024          Added DEFAULT_NAME,CASE_TYPE variable
* CC-702                   06-Aug-2024          Added SMS_CHANNEL,EMAIL_CHANNEL variables
* CC-691,692,940           13-Aug-2024          Added Account,CASE_STATUS_CLOSED,DATE_FORMAT_1 Variables
* CC-940                   20-Aug-2024          Added PIPE_DELIMITER Variables
* CC-481,CC-590            20-Aug-2024          Added ACCOUNTIDREP,EXPIRE_REP,USERID_REP
* CC-691                   28-Aug-2024			Added DATE_TIME_FORMAT_1 and CALL_END_EVENT Variables
* CC-692                   02-Sep-2024          Added CALL_STATUS_COMPLETED and CALL_TYPE_TRANSFER variable
* CC-1247                  04-Sep-2024   		Added TIMEOUT_ERROR variable
* CC-430                   11-Sep-2024          Added MISSING_INFO variable
* CC-1199				   10-Sep-2024			Added CALL_DISPOSITION_TRANSFERRED variable
* CC-491                   03-Sep-2024          Added EMAIL_EI,SMS_EI variables
* CC-1377                  01-Oct-2024          Added COMPLETED variable
* CC-1453				   29-Nov-2024			Added NO_PATIENT_LAUNCH  and IN_PROGRESS variable
* CC-1609			   	   16-Jun-2024			Added ABANDON variable
* CC-1562			   	   18-Jun-2024			Added OPERATION_ENQUEUED variable
* *****************************************************************************************************************************
*/

public class DH_GlobalConstants {
	public static final String DH_VERIFY_CALLER_CLASS = 'DH_VerifyCallerController';
	public static final String DH_PATIENT_SEARCH_CLASS = 'dH_PatientSearch';
	public static final string CASE_STATUS_NEW = 'New';
	public static final string CASE_PRIORITY_LOW = 'Low';

	public static final string VOICE_CALL_ROW_CAUSE = 'Manual';
	public static final string VOICE_CALL_ACCESS = 'Read';

	public static final string RIS_NEW_PATIENT_SERVICE = 'RIS New Patient Service';
	public static final string RIS_SEARCH_PATIENT_SERVICE = 'RIS Search Patient Service';

	public static final string SUCCESS = 'Success';
	public static final string FAILURE = 'Failure';

	public static final string CASE_SUBJECT = 'New Case';

	public static final Id PERSON_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
	public static final String PERSON_ACCOUNT_STATUS = 'Draft';

	public static final string DML_EXCEPTION = 'dmlException';

	public static final string DEFAULT_NAME = 'Default';
	public static final string CASE_TYPE = 'PAP';
	public static final String EMAIL_CHANNEL = 'DH_Email';
	public static final String SMS_CHANNEL = 'DH_SMS';
    public static final String AUTOCALL_CHANNEL = 'DH_AutoCall';
	
	public static final string ACCOUNT = 'Account';
	public static final String ACCOUNTIDREP = 'accountId';
    public static final String EXPIRE_REP = 'expiryInSecondsRep';
    public static final String USERID_REP = 'userIdRep';

	public static final string CASE_STATUS_CLOSED = 'Closed';
	public static final string DATE_TIME_FORMAT_1 = 'MM/dd/yyyy hh:mm a';
	public static final string CALL_END_EVENT ='CallEndEvent';
	public static final string PIPE_DELIMITER = '|';
	public static final String CALL_STATUS_COMPLETED = 'completed';
	public static final String CALL_TYPE_TRANSFER = 'Transfer';
	
	public static final String TIMEOUT_ERROR = 'Read timed out';

	public static final String MISSING_INFO = 'Missing Info:';
	public static final String CALL_DISPOSITION_TRANSFERRED = 'Transferred';

	public static final String EMAIL_EI = 'DH_Email';
	public static final String SMS_EI = 'DH_SMS';

	public static final String COMPLETED = 'completed';
	public static final String IN_PROGRESS = 'in-progress';

	public static final String NO_PATIENT_LAUNCH = 'No Patient Launch';

	public static final String ABANDON = 'Abandon';
    
    public static final String OPERATION_ENQUEUED = 'OPERATION_ENQUEUED';
}