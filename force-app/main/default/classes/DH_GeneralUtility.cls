/*
* ***************************************************************************************************************************
* Apex Class Name : DH_GeneralUtility
* Created Date : 12-July-2024
* Function : Used for general utility methods
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-482,CC-507,CC-520     12-July-2024         Added getLabelValue
* CC-962                   07-August-2024       Added getTimeStamp method
* cc-940                   09-August-2024       Added createContactCenterPatient,createContactCenterCase methods
* CC-572				   12-August-2024		Added createNewPatientServicePatient ,createDefaultPersonAccount and getLabelValue methods
* CC-481,CC-590			   19-August-2024		Added createRequestBody method
* CC-426                   18-August-2024       Added getPatientSearchedData
* CC-691			       28-August-2024		Updated createContactCenterCase method with global constant variable. Removed isAccecible
* CC-692			       02-September-2024    Updated createContactCenterCase method with global constant variable.
* CC-1312                  12-September-2024    Added isValidPhNo method.
* CC-491                   06-September-2024    Added createEmailWrapper, createSMSWrapper, getUTCDateTime methods
* CC-572,CC-481,CC-590	   03-October-2024		Updated  createDefaultPersonAccount, createNewPatientServicePatient method.
* CC-1439                  30-Oct-2024			Replaced all instances of FromPhoneNumber with F9_Call_ANI__c.
* ***************************************************************************************************************************
*/
public without sharing class DH_GeneralUtility {
	/**
	 * Jira CC-505
	 * @description method to get the user federation id of the current login user.
	 * @param       - None
	 * @return      - String
	 **/
	@AuraEnabled
	public static String getUserFederationId() {
		String userFederationId;
		try {
			User userInfo = new User();
			Set<Id> userIdSet = new Set<Id>();
			userIdSet.add(System.UserInfo.getUserId());
			Map<Id, User> usermap = DH_ContactCenterCachingUtility.getUsersMap(userIdSet);
			if (usermap != null && !usermap.isEmpty()) {
				userInfo = usermap.get(System.UserInfo.getUserId());
			}
			if (userInfo != null && userInfo.FederationIdentifier != null) {
				List<String> userList = userInfo.FederationIdentifier.split('@');
				userFederationId = userList[0];
			}
		} catch (Exception ex) {
			System.debug(LoggingLevel.ERROR, ex.getMessage());
		}
		return userFederationId;
	}
	/**
	 * @Jira CC-572
	 * @description - This method will fetch error message based on error code
	 * @param       - DH_ErrorCodeMapping__mdt
	 * @return      - String
	 **/
	@AuraEnabled
	public static String getLabelValue(DH_ErrorCodeMapping__mdt errorCode) {
		String errorMessage;
		if (errorCode != null && errorCode.DH_ErrorMessageLabel__c != null) {
			errorMessage = Label.get('', errorCode.DH_ErrorMessageLabel__c);
		} else {
			errorMessage = System.Label.DH_DefaultErrorMessage;
		}

		return errorMessage;
	}
	/**
	 * Jira CC-962
	 * @description method to get the time as per users time zone.
	 * @param       - Id,String,String
	 * @return      - String
	 **/
	public static String getTimeStamp(Id userId, String dateToFormat, String dateTimeFormat) {
		String timeStamp;
		try {
			DateTime convertedDateTime = DateTime.valueOf(dateToFormat.replaceAll('T|Z', ' '));
			User user = DH_ContactCenterCachingUtility.getUsersMap(new Set<Id>{ userId }).get(userId);
			TimeZone userTimeZone = TimeZone.getTimeZone(user.TimeZoneSidKey);
			DateTime dtUserTimeZone = convertedDateTime.addMinutes(userTimeZone.getOffset(convertedDateTime) / Integer.valueOf(System.label.DH_DateTimeOffsetDivisor));
			timeStamp = dtUserTimeZone.format(dateTimeFormat);
		} catch (Exception ex) {
			system.debug(LoggingLevel.ERROR + ex.getMessage());
		}
		return timeStamp;
	}
	/**
	 * Jira CC-940
	 * @description method to create Contact Center Case related to the voicecall and patient .
	 * @param       - Id,Id
	 * @return      - void
	 **/
	public static void createContactCenterCase(Id patientId, Id voiceCallRecordId) {
		Map<Id, VoiceCall> voiceCallMap = DH_ContactCenterCachingUtility.getVcMap(new Set<Id>{ voiceCallRecordId });
		DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
		try {
			VoiceCall vc = voiceCallMap.get(voiceCallRecordId);
			if(vc.CallDisposition!=DH_GlobalConstants.CALL_STATUS_COMPLETED){
				Id currentUserId = UserInfo.getUserId();
				Case c = new Case();
				c.AccountId = patientId;
				c.Status = DH_GlobalConstants.CASE_STATUS_NEW;
				c.Subject = vc.F9_Call_skill_name__c + DH_GlobalConstants.PIPE_DELIMITER + vc.CallStartDateTime.format(DH_GlobalConstants.DATE_TIME_FORMAT_1);
				c.Priority = DH_GlobalConstants.CASE_PRIORITY_LOW;
				c.DH_VoiceCall__c = voiceCallRecordId;
				c.OwnerId = currentUserId;
				insert c;
			}
		} catch (Exception e) {
			logWrapper.exp = e;
			logWrapper.relatedTo = voiceCallRecordId;
			logWrapper.className = 'DH_GeneralUtility-createContactCenterCase';
			DH_DexLoggingUtility.createLogRecord(logWrapper);
		}
	}
	/**
	 * Jira CC-572,481,590
	 * @description - It is used to create place holder Patient acccount on API Service down case
	 * @param       - String
	 * @return      - Account
	 **/
	@AuraEnabled
	public static Account createNewPatientServicePatient(VoiceCall vc) {
		Account pat = new Account();
		try {
			pat.lastName = vc.F9_Call_ANI__c;
			pat.firstName = ' ' + vc.F9_Call_ANI__c;
			pat.DH_Status__c = DH_GlobalConstants.PERSON_ACCOUNT_STATUS;
			pat.Region__c = vc.F9_DH_SystemId__c;
			pat.recordTypeId = DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
			if (pat != null){
				insert pat;
			}
			return pat;
		} catch (Exception e) {
			System.debug(LoggingLevel.DEBUG + e.getStackTraceString());
			return null;
		}
	}
	/**
	 * Jira CC-426
	 * @description It is used to create a map which stores the parameters along with there values which are fetched from the DH_Payload1__c field of the DH_PayloadData__c record.
	 * @param       - String
	 * @return      - Map<String,String>
	 **/
	@AuraEnabled
	public static Map<String, String> getPatientSearchedData(String recordId) {
		Map<String, String> parameterMap = new Map<String, String>();
		try {
			if (recordId != null) {
				DH_PayloadData__c plList = new DH_PayloadData__c();
				if (Schema.sObjectType.DH_PayloadData__c.isAccessible()) {
					plList = (DH_ContactCenterCachingUtility.getPayloadMap(new Set<Id>{ recordId })).get(recordId) != null ? (DH_ContactCenterCachingUtility.getPayloadMap(new Set<Id>{ recordId })).get(recordId) : null;
				}
				if (plList != null) {
					List<String> parameterList = plList.DH_APIEndPoint__c.split('/', 2)[1].split('&');
					for (String str : parameterList) {
						parameterMap.put(str.split('=')[0], str.split('=')[1]);
					}
				} else {
					return parameterMap;
				}
			}
		} catch (Exception ex) {
			system.debug('Error in getPatientSearchedData method in DH_VerifyCallerController class' + ex.getMessage());
		}
		return parameterMap;
	}
	/**
	 * Jira CC-481,CC-590
	 * @description - this method fetch the request from meta data and forms the Request Body
	 * @param       - String, DH_DexOutServiceRisNewPatientRequest
	 * @return      - String
	 **/
	public static String createRequestBody(DH_DexOutGeneralServiceRequest apiRequest) {
		String requestBody;
		if (apiRequest != null) {
			DH_IntegrationSetting__mdt integrationMetadata = DH_CustomMetadataDao.getIntegrationSetting('DH_RisNewPatientServiceSetting');
			requestBody = integrationMetadata.DH_SampleRequest__c;
			List<DH_DynamicTableColumns__mdt> toBeReplaced = DH_CustomMetadataDao.getDynamicTableColumnList('DH_DexOutServiceRisNewPatient');
			Map<String, String> dataMap = DH_GeneralUtility.getPatientSearchedData(apiRequest.recordId);
			for (DH_DynamicTableColumns__mdt record : toBeReplaced) {
				String value = dataMap.get(record.DH_AttributeLabel__c) != null ? dataMap.get(record.DH_AttributeLabel__c) : '';
				if (record.DH_AttributeName__c != null) {
					requestBody = requestBody.replace(DH_GlobalConstants.ACCOUNTIDREP, apiRequest.patientId);
					requestBody = requestBody.replace(DH_GlobalConstants.USERID_REP, getUserFederationId());
					requestBody = requestBody.replace(DH_GlobalConstants.EXPIRE_REP, DH_VerifyCallerController.getExpiryTimeForApi());
					requestBody = requestBody.replace(record.DH_AttributeName__c, value); 
				}
			}
		}
		return requestBody;
	}
	/**
	 * Jira CC-572
	 * @description - this method Creates the Region specific Account
	 * @param       - String
	 * @return      - Account
	 **/
	public static Account createDefaultPersonAccount(String systemId) {
		Account pat = new Account();
		DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
		try {
			pat.FirstName = systemID != null ? systemID : null;
			pat.lastname = DH_GlobalConstants.DEFAULT_NAME;
			pat.Region__c = systemID != null ? systemID : null;
			pat.RecordTypeId = DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
			if (pat != null){
				insert pat;
			}
			return pat;
		} catch (Exception e) {
			logWrapper.Exp = e;
			logWrapper.ClassName = 'DH_GeneralUtility-createDefaultPersonAccount';
			DH_DexLoggingUtility.createLogRecord(logWrapper);
			return null;
		}
	}
	/**
	* @Jira CC-491
    * @description - This method will create the Email Wrapper for Engagement Interaction Record
    * @param       - List<EngagementInteraction>, Map<String, et4ae5__IndividualEmailResult__c>,Map<String, String>
    * @return      - List<DH_DexOutServiceRisEIEmailRequest>
	**/
    public static List<DH_DexOutServiceRisEIEmailRequest> createEmailWrapper(List<EngagementInteraction> emailList,Map<String,et4ae5__IndividualEmailResult__c> ierMap, Map<String, String> dynamicTableColumnMapEmail){
        List<DH_DexOutServiceRisEIEmailRequest> emailWrappers = new List<DH_DexOutServiceRisEIEmailRequest>();
        for(EngagementInteraction ei : emailList){
            String key = ei.DH_BatchId__c+ei.DH_EmailId__c+ei.DH_JobId__c+ei.ExternalIdentifier;
            DH_DexOutServiceRisEIEmailRequest emailWrapper = new DH_DexOutServiceRisEIEmailRequest();
            emailWrapper.SfId = (String)ei.get(dynamicTableColumnMapEmail.get('sf_id')) != null ? (String)ei.get(dynamicTableColumnMapEmail.get('sf_id')) : '';
            if(ei.get(dynamicTableColumnMapEmail.get('sentDate')) != null){
				String utcSentDate= getUTCDateTime((DateTime)ei.get(dynamicTableColumnMapEmail.get('sentDate')));
				emailWrapper.SentDate = utcSentDate;
			}
            emailWrapper.SubjectLine = (String)ei.get(dynamicTableColumnMapEmail.get('subjectLine')) != null ? (String)ei.get(dynamicTableColumnMapEmail.get('subjectLine')) : ''; 
            emailWrapper.JobId = Integer.valueOf(ei.get(dynamicTableColumnMapEmail.get('jobID'))) != null ? Integer.valueOf(ei.get(dynamicTableColumnMapEmail.get('jobID'))): null;
			String str = dynamicTableColumnMapEmail.get('orderKey');
			List<String> strList = str.split(':');
			if(ei.getSObject(strList[0]) != null){
				emailWrapper.OrderKey = Integer.valueOf(ei.getSObject(strList[0]).get(strList[1]))!= null ? Integer.valueOf(ei.getSObject(strList[0]).get(strList[1])) : null;
			}
			emailWrapper.NotSent = ei.get(dynamicTableColumnMapEmail.get('notSent')) == 'DH_Undelivered' ? true : false;
            emailWrapper.BatchId =  Integer.valueOf(ei.get(dynamicTableColumnMapEmail.get('batchID'))) != null ?  Integer.valueOf(ei.get(dynamicTableColumnMapEmail.get('batchID'))) : null;
            emailWrapper.SubscriberID =  Integer.valueOf(ei.get(dynamicTableColumnMapEmail.get('subscriberID'))) != null ?  Integer.valueOf(ei.get(dynamicTableColumnMapEmail.get('subscriberID'))) : null;
            emailWrapper.DateBounced = ierMap.get(key) != null ? String.valueOf(ierMap.get(key).get(dynamicTableColumnMapEmail.get('dateBounced'))) : ''; 
            emailWrapper.NumberOfTotalClicks =  ierMap.get(key) != null ? Integer.valueOf(ierMap.get(key).get(dynamicTableColumnMapEmail.get('numberOfTotalClicks'))) : null;
            emailWrapper.JourneyName = (String)ei.get(dynamicTableColumnMapEmail.get('journeyName')) != null ? (String)ei.get(dynamicTableColumnMapEmail.get('journeyName')) : '';
            emailWrapper.JourneyTouchPoint = (String)ei.get(dynamicTableColumnMapEmail.get('journeyTouchPoint')) != null ? (String)ei.get(dynamicTableColumnMapEmail.get('journeyTouchPoint')) : '';
            emailWrappers.add(emailWrapper);
        }
        return emailWrappers;
    }
    /**
	* @Jira CC-491
    * @description - This method will create that Sms Wrapper for Engagement Interaction Record
    * @param       - List<EngagementInteraction>, Map<String, String>
    * @return      - List<DH_DexOutServiceRisEISmsRequest>
	**/
    public static List<DH_DexOutServiceRisEISmsRequest> createSmsWrapper(List<EngagementInteraction> smsList, Map<String, String> dynamicTableColumnMapSms){
        List<DH_DexOutServiceRisEISmsRequest> smsWrappers = new List<DH_DexOutServiceRisEISmsRequest>();
        for(EngagementInteraction ei : smsList){
            String key = ei.DH_BatchId__c+ei.DH_EmailId__c+ei.DH_JobId__c+ei.ExternalIdentifier;
            DH_DexOutServiceRisEISmsRequest smsWrapper = new DH_DexOutServiceRisEISmsRequest();
            smsWrapper.SfId = (String)ei.get(dynamicTableColumnMapSms.get('sf_id')) != null ? (String)ei.get(dynamicTableColumnMapSms.get('sf_id')) : '';
            if(ei.get(dynamicTableColumnMapSms.get('sentDate')) != null){
				String utcSentDate= getUTCDateTime((DateTime)ei.get(dynamicTableColumnMapSms.get('sentDate')));	
				smsWrapper.SentDate = utcSentDate;
			}
			smsWrapper.Content = (String)ei.get(dynamicTableColumnMapSms.get('content')) != null ? (String)ei.get(dynamicTableColumnMapSms.get('content')) : '';
            smsWrapper.JobId = Integer.valueOf(ei.get(dynamicTableColumnMapSms.get('jobID'))) != null ? Integer.valueOf(ei.get(dynamicTableColumnMapSms.get('jobID'))) : null;
			String str = dynamicTableColumnMapSms.get('orderKey');
			List<String> strList = str.split(':');
			if(ei.getSObject(strList[0]) != null){
				smsWrapper.OrderKey = Integer.valueOf(ei.getSObject(strList[0]).get(strList[1]))!= null ? Integer.valueOf(ei.getSObject(strList[0]).get(strList[1])) : null;
			}
            smsWrapper.BatchId = Integer.valueOf(ei.get(dynamicTableColumnMapSms.get('batchID'))) != null ? Integer.valueOf(ei.get(dynamicTableColumnMapSms.get('batchID'))) : null;
            smsWrapper.SubscriberID = Integer.valueOf(ei.get(dynamicTableColumnMapSms.get('subscriberID'))) != null ? Integer.valueOf(ei.get(dynamicTableColumnMapSms.get('subscriberID'))) : null;
            smsWrapper.Sent = ei.get(dynamicTableColumnMapSms.get('sent')) == 'DH_Sent' ? true : false;
            smsWrapper.NotSent = ei.get(dynamicTableColumnMapSms.get('notSent')) == 'DH_Undelivered' ? true : false;
            smsWrapper.PhoneNumber = (String)ei.get(dynamicTableColumnMapSms.get('phoneNumber')) != null ? (String)ei.get(dynamicTableColumnMapSms.get('phoneNumber')) : '';
            smsWrapper.JourneyName = (String)ei.get(dynamicTableColumnMapSms.get('journeyName')) != null ? (String)ei.get(dynamicTableColumnMapSms.get('journeyName')) : '';
            smsWrapper.JourneyTouchPoint = (String)ei.get(dynamicTableColumnMapSms.get('journeyTouchPoint')) != null ? (String)ei.get(dynamicTableColumnMapSms.get('journeyTouchPoint')) : '';
            smsWrappers.add(smsWrapper);
        }
        return smsWrappers;
    }
	/**
	* @Jira CC-491
    * @description - This method will return UTC format of Date
    * @param       - DateTime
    * @return      - DateTime
	**/
	public static String getUTCDateTime(DateTime dt){
        String formatted = dt.formatGMT('yyyy-MM-dd HH:mm:ss');
		return formatted;
	}
	/**
	 * @Jira CC-1312
	 * @description - This method will validate if the phone number is a valid phone number or not.
	 * @param       - String
	 * @return      - Boolean
	 **/
	@AuraEnabled
	public static Boolean isValidPhNo(String phoneNum) {
		Boolean isValid = false;
		if (phoneNum != null) {
			String regex = System.Label.DH_IsValidPhone;
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(phoneNum);
			isValid = matcher.matches();
		}
		return isValid;
	}
}