/*
 * ***************************************************************************************************************************
 * Apex Class Name - DH_ContactCenterQueryManager
 * Created Date - 29-July-2024
 * @description : General Query Manager class to handle queries for Contact Center.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ------------------------------
 * CC-702                   06-August-2024       Added getAccountList,getEngagmentList and getRelatedIdVsVoiceCallListMap methods.
 * CC-962                   07-August-2024       Added getUserlist method.
 * CC-940                   19-August-2024       Added getCaseList and getUniqueKeyAccountList method.
 * CC-633                   16-August-2024       Added getContactPointPhone method
 * CC-664                   16-August-2024       Added getContactPointEmail method
 * CC-1154                  26-August-2024       Added Fields in getEngagmentListMap
 * CC-520                   28-August-2024       Added getEmailTemplateList method
 * CC-572                   29-August-2024       Added getDefaultAccount and getPayloadList method
 * CC-691                   03-September-2024    Added get getCaseList method
 * CC-1268                  10-September-2024    Removed F9_DH_ModalityGroup__c field in SOQL from getVcList method
 * CC-1203,1204				17-September-2024    Added getProfileList, getPermissionSetGroup and getPermissionSets methods
 * CC-491            		18-September-2024	 Added getEiRecords and getIerList methods
 * CC-505                   23-September-2024    Updated getAccountList and getUniqueKeyAccountList methods
 * CC-1377                  30-September-2024    Changes in getRelatedIdVsVoiceCallListMap for retriev CallDisposition.
 * CC-1439                  30-Oct-2024			 Added F9_Call_ANI__c in the query on the VoiceCall object
 * *******************************************************************************************************************************************
 */
public without sharing class DH_ContactCenterQueryManager {
	/**
	 * @Jira CC-526,702
	 * @description - This method will return a list of Account records whose id is in the given accountIds list.
	 * @param       - List<Id>
	 * @return      - List<sObject>
	 **/
	public static List<Account> getAccountList(List<Id> acctIds) {
		List<Account> accList = new List<Account>();
		try {
			accList = [SELECT Id, Region__c, DH_Patient_Key__c, FirstName, LastName, PersonBirthdate, PersonEmail, Phone, DH_Patient_Id__c, DH_RIS_Unique_Code__c FROM Account WHERE Id IN :acctIds WITH SECURITY_ENFORCED];
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return accList;
	}
	/**
	 * @Jira CC-526
	 * @description - This method will return a list of public group records whose developer name is in grpNames set.
	 * @param       - Set<String>
	 * @return      - List<sObject>
	 **/
	public static List<Group> getGroupList(List<String> grpNames) {
		List<Group> groupList = new List<Group>();
		try {
			groupList = [SELECT Id, DeveloperName, Type FROM Group WHERE Type = 'Regular' AND DeveloperName IN :grpNames WITH SECURITY_ENFORCED];
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return groupList;
	}
	/**
	 * @Jira CC-526
	 * @description - This method will return a list of voice call records for passed voice call ids.
	 * @param       - Set<String>
	 * @return      - List<sObject>
	 **/
	public static List<VoiceCall> getVcList(List<Id> vcIds) {
		List<VoiceCall> vcList = new List<VoiceCall>();
		try {
			vcList = [SELECT Id, F9_DH_SystemId__c, RelatedRecordId, PreviousCallId, CallType, F9_Call_disposition_name__c, F9_Call_skill_name__c, CallStartDateTime, CallEndDateTime, CallDisposition, FromPhoneNumber,F9_Call_ANI__c, DH_TransferNotes__c, Five9BYOT__F9_AgentName__c, DH_TransferNotesSummary__c, DH_TransferredFrom__c, NextCallId, DH_TransferredTo__c
				FROM VoiceCall
				WHERE Id IN :vcIds
				WITH SECURITY_ENFORCED
			];
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return vcList;
	}
	/**
	 * @Jira CC-702
	 * @description - This method will return a map of related id vs list of voice call records for passed related ids.
	 * @param       - Set<Id> relatedIds
	 * @return      - Map<id,List<VoiceCall>>
	 **/
	public static Map<id, List<VoiceCall>> getRelatedIdVsVoiceCallListMap(List<Id> relatedIds) {
		Map<id, List<VoiceCall>> relatedIdVsVoiceCallListMap = new Map<id, List<VoiceCall>>();
		List<VoiceCall> vcList = new List<VoiceCall>();
		try {
			if (Schema.SObjectType.VoiceCall.isAccessible()) {
				vcList = [SELECT Id, CallType, CallStartDateTime,Five9BYOT__F9_AgentName__c,CallEndDateTime, F9_Call_skill_name__c, RelatedRecord.Name, CallDisposition FROM VoiceCall WHERE RelatedRecordId IN :relatedIds];
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		if (vcList != null && vcList.size() > 0) {
			for (VoiceCall vcRec : vcList) {
				if (!relatedIdVsVoiceCallListMap.containsKey(vcRec.RelatedRecordId)) {
					relatedIdVsVoiceCallListMap.put(vcRec.RelatedRecordId, new List<VoiceCall>{ vcRec });
				} else {
					relatedIdVsVoiceCallListMap.get(vcRec.RelatedRecordId).add(vcRec);
				}
			}
		}
		return relatedIdVsVoiceCallListMap;
	}
	/**
    /**
	* @Jira CC-702
    * @description - This method will return a map of related id vs list of EngagementInteraction records for passed related ids.
    * @param       - Set<Id> relatedIds
    * @return      - Map<id,List<EngagementInteraction>>
	**/
	public static Map<id, List<EngagementInteraction>> getEngagmentListMap(List<Id> relatedIds) {
		Map<id, List<EngagementInteraction>> relatedIdVsEgListMap = new Map<id, List<EngagementInteraction>>();
		List<EngagementInteraction> egList = new List<EngagementInteraction>();
		try {
			egList = [SELECT Id, Reason, DH_Content_Body__c, StartDateTime, CommunicationChannel, DH_Account__c, DH_ResponseToMessageTrackingId__c, DH_MessageTrackingId__c, Type FROM EngagementInteraction WHERE DH_Account__c IN :relatedIds WITH SECURITY_ENFORCED];
        } catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		if (egList != null && egList.size() > 0) {
			for (EngagementInteraction egRec : egList) {
				if (!relatedIdVsEgListMap.containsKey(egRec.DH_Account__c)) {
					relatedIdVsEgListMap.put(egRec.DH_Account__c, new List<EngagementInteraction>{ egRec });
				} else {
					relatedIdVsEgListMap.get(egRec.DH_Account__c).add(egRec);
				}
			}
		}
		return relatedIdVsEgListMap;
	}
	/**
	 * @Jira CC-962
	 * @description - This method will return the User with the UserIds provided as parameter.
	 * @param       - List<Id>
	 * @return      - List<User>
	 **/
	public static List<User> getUserList(List<Id> userIds) {
		List<User> userList = new List<User>();
		try {
			userList = [SELECT FederationIdentifier, TimeZoneSidKey FROM User WHERE Id = :userIds WITH SECURITY_ENFORCED];
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return userList;
	}
	/**
	* @Jira CC-691,716
	* @description - This method will return a list of Account records whose Unique Id is in the given uniqueId list.
	* @param       - List<Id>
	* @return      - List<sObject>
	**/
	public static List<Account> getUniqueKeyAccountList(List<String> uniqueId){
		DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
		List<Account> accList = new List<Account>();
		try {
			accList = [SELECT Id, FirstName, LastName, PersonBirthdate, PersonEmail, Phone, DH_Patient_Key__c,
						 DH_RIS_Unique_Code__c,Region__c,DH_Patient_Id__c,DH_Issuer_Of_Patient_Id__c,
						 DH_Gender_Code__c,DH_Primary_Address_Line1__c,DH_Primary_Address_Line2__c,DH_Primary_Address_City__c, 
						 DH_Primary_Address_State__c,DH_Primary_Address_Zipcode__c,DH_Patient_Extra_Info__c,DH_Patient_Alerts__c,DH_Contact_Point_Email__c
				         FROM Account WHERE DH_RIS_Unique_Code__c IN :uniqueId WITH SECURITY_ENFORCED LIMIT 1];
		}
		catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return accList;
	}
	/**
    * @Jira CC-633
    * @description - This method will return a list of ContactPointPhone based on the patientId and phoneKeyList.
    * @param       - List<String>
    * @return      - List<ContactPointPhone>
    **/
    public static List<ContactPointPhone> getContactPointPhone(List<String> phoneKeyList,Id patientId) {
        List<ContactPointPhone> phoneList = new List<ContactPointPhone>();
        try {
            phoneList = [SELECT Id,DH_RIS_PhoneKey__c FROM ContactPointPhone WHERE ParentId = :patientId AND DH_RIS_PhoneKey__c NOT IN :phoneKeyList WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return phoneList;
    }
    /**
    * @Jira CC-664
    * @description - This method will return a list of ContactPointEmail based on the patientId and emailKeyList.
    * @param       - List<String>
    * @return      - List<ContactPointEmail>
    **/
    public static List<ContactPointEmail> getContactPointEmail(List<String> emailKeyList,Id patientId) {
        List<ContactPointEmail> emailList = new List<ContactPointEmail>();
        try {
            emailList = [SELECT Id,DH_RIS_EmailKey__c FROM ContactPointEmail WHERE ParentId = :patientId AND DH_RIS_EmailKey__c NOT IN :emailKeyList WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return emailList;
    }
    /**
    * @Jira CC-520
    * @description - This method will return a list of email templates records whose developer name is in eTNames set.
    * @param       - Set<String>
    * @return      - List<EmailTemplate>
    **/
    public static List<EmailTemplate> getEmailTemplateList(Set<String> eTNames) {
        List<EmailTemplate> eTList = new List<EmailTemplate>();
        try {          
            eTList = [SELECT Id, Subject, Body,DeveloperName FROM EmailTemplate WHERE DeveloperName =: eTNames WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return eTList;
    }
	/**
    * @Jira CC-572
    * @description - This method will return a list of Account records whose id is in the given accountIds list.
    * @param       - List<Id>
    * @return      - List<DH_PayloadData__c>
    **/
	public static List<DH_PayloadData__c> getPayloadList(List<Id> relatedToIds) {
		List<DH_PayloadData__c> plList = new List<DH_PayloadData__c>();
		try {
			plList = [SELECT Name, DH_APIEndPoint__c, DH_Payload1__c, DH_RelatedTo__c, DH_ServiceName__c FROM DH_PayloadData__c WHERE DH_RelatedTo__c IN :relatedToIds AND DH_ServiceName__c = 'RIS Advance Search Patient Service' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return plList;
	}
	/**
	* @Jira CC-572
	* @description - this method will query default Account bases on the Region
	* @param       - String
	* @return      - Account
	**/
	public static Account getDefaultAccount(String systemID) {
		DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
		Account pat = new Account();
		try {
			Account[] existingPat = [SELECT FirstName, LastName FROM Account WHERE FirstName = :systemid AND lastName = :DH_GlobalConstants.DEFAULT_NAME AND RecordTypeId = :DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID WITH SECURITY_ENFORCED LIMIT 1];
			if (!existingPat.isempty()) {
				pat = existingPat[0];
			} else {
				pat = DH_GeneralUtility.createDefaultPersonAccount(systemID);
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
	* @Jira CC-691
	* @description - This method will return a list of Case records whose related Accout Id is in the given relatedAccountIds list.
	* @param       - List<Id>
	* @return      - List<sObject>
	**/
	public static List<Case> getCaseList(List<Id> relatedAccountId) {
		List<Case> caseList = new List<Case>();
		try {
			caseList = [SELECT id, Status, CreatedDate,AccountId FROM case WHERE AccountId = :relatedAccountId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage()  + e.getLineNumber());
		}
		return caseList;
	}
	/**
	 * @Jira CC-1203,1204
	 * @description - this method returns the Id of Profile.
	 * @param       - String
	 * @return      - Id
	 **/
	public static List<Profile> getProfileList(List<String> profileName){
		List<Profile> profileList = [SELECT Id,Name FROM Profile WHERE Name IN :profileName WITH SECURITY_ENFORCED];
		return profileList;
	}
	/**
	* @Jira CC-1203,1204
	* @description - this method returns List of Permission Sets Group.
	* @param       - None
	* @return      - List<permissionSetGroup>
	**/
	public static List<PermissionSetGroup> getPermissionSetGroup(List<String> prmSetGroup){
		List<PermissionSetGroup> permSetGroup = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN :prmSetGroup WITH SECURITY_ENFORCED];
		return permSetGroup;
	}
	/**
    * @Jira CC-1203,1204
    * @description - this method returns List of Permission Sets.
    * @param       - None
    * @return      - List<permissionSet>
    **/
    public static List<PermissionSet> getPermissionSets(List<String> permissionSetList){
        List<PermissionSet> prmslist = [Select id,name from PermissionSet  where Name IN :permissionSetList WITH SECURITY_ENFORCED];
        return prmslist;
    }
	/**
	 * @Jira CC-491
	 * @description - This method will return a list of Individual Email Results based on the eIIdList.
	 * @param       - DH_DexOutServiceRisEngagementRequest
	 * @return      - List<et4ae5__IndividualEmailResult__c>
	 **/
	public static List<et4ae5__IndividualEmailResult__c> getIerList(DH_DexOutServiceRisEngagementRequest wrapper) {
		List<et4ae5__IndividualEmailResult__c> ierList = new List<et4ae5__IndividualEmailResult__c>();
		try {
			if(wrapper != null){
				ierList = [SELECT Id,et4ae5__BatchId__c,et4ae5__Email_ID__c,et4ae5__JobId__c,et4ae5__SubscriberId__c,et4ae5__DateBounced__c,et4ae5__NumberOfTotalClicks__c FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__BatchId__c IN: wrapper.batchIdSet AND et4ae5__Email_ID__c IN : wrapper.emailIdSet AND et4ae5__JobId__c IN : wrapper.jobIdSet AND et4ae5__SubscriberId__c IN : wrapper.subscriberIdSet WITH SECURITY_ENFORCED];
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return ierList;
	}
	/**
	* @Jira CC-491
	* @description - This method will return list of Engagement Interaction records to be updated
	* @param       - List<String>
	* @return      - List<EngagementInteraction>
	**/
	public static List<EngagementInteraction> getEiRecords(List<String> sfIds){
		List<EngagementInteraction> eiRecords = new List<EngagementInteraction>();
		try{
			if(sfIds != null){
				eiRecords = [SELECT Id, DH_isSynced__c, DH_NumberOfRetries__c FROM EngagementInteraction WHERE Id IN :sfIds WITH SECURITY_ENFORCED];
			}
		}catch(Exception ex){
			System.debug(LoggingLevel.ERROR, ex.getMessage());
		}
		return eiRecords;
	}
}