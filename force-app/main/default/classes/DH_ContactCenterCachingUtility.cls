/*
* ***************************************************************************************************************************
* Apex Class Name - DH_ContactCenterCachingUtility
* Created Date - 29-July-2024
* @description : Caching Utility class to handle DH_ContactCenterQueryManager.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ------------------------------
* CC-702                   30-Jul-2024          Added getAccountsMap,updateAccountsMap,getCallHistoryDetails,updateUserMap methods.
* CC-962                   07-Aug-2024          Added getUsersMap,updateUserMap methods.
* CC-940                   16-Aug-2024          Added getUniqueKeyVsAccountMap and updateUniqueKeyVsAccountsMap methods
* CC-633,CC-664            21-Aug-2024          Added getContactPhoneList,updateContactPhoneMap,getContactEmailList,updateContactEmailMap methods
* CC-572                   12-Aug-2024          Added updatePayloadMap and getPayloadMap methods
* CC-520                   18-Aug-2024          Added getEmailTemplateMap and updateEtMap method
* CC-691                   19-Aug-2024          Added getCaseMap method which return  case map using the related AccoutId
* CC-1203                  17-Sep-2024          Added getPermissionSetMap,updatePermissionNameVsPermissionsetMap and getProfileNameVsProfileMap
* CC-1204                  17-Sep-2024          Added getPermissionSetGroupMap,updatePermissionSetGroupMap and updateProfileNameVsProfileMap
* CC-491				   30-Aug-2024			Added getIerMap, updateIerMap, getEiMap, updateEiMap, methods
* ***********************************************************************************************************************************************
*/
public without sharing class DH_ContactCenterCachingUtility {
    public static Map<Id, Account> accountsMap;
    public static Map<String, Account> uniqueKeyVsAccountMap;
	public static Map<Id, VoiceCall> voiceCallsMap;
	public static Map<Id, List<VoiceCall>> relatedIdVsVoiceCallListMap;
	public static Map<Id, User> userMap;
	public static Map<Id, List<EngagementInteraction>> relatedIdEngagementInteractionMap;
    public static Map<Id, Case> caseMap;
	public static Map<String,ContactPointPhone> contactPhoneMap;
	public static Map<String,ContactPointEmail> contactEmailMap;
    public static Map<String, Group> groupsMap;
    public static Map<Id, DH_PayloadData__c> payloadMap;
    public static Map<String, EmailTemplate> emailTemplateMap;
    public static Map<String, PermissionSet> permissionNameVsPermissionsetMap;
    public static Map<String, Profile> profileNameVsProfileMap;
	public static Map<String, PermissionSetGroup> permissionSetGroupMap;
	public static Map<String,et4ae5__IndividualEmailResult__c> ierMap;
	public static Map<Id, EngagementInteraction> eiMap;

		/**
    * @Jira CC-526,702
    * @description - This method will return a map of Accounts whose id are in the given accIdSet.
    * @param       - Set<Id>
    * @return      - Map<Id,Account>
    **/
	public static Map<Id,Account> getAccountsMap(Set<Id> accIdSet) {
        try {
            if(accountsMap==null){
                accountsMap= new map<Id,Account>();
            }
            if(accIdSet==null || accIdSet.size()==0){
                return accountsMap;
            }  
            List<Id> accIds = new List<Id>();
            for(Id idVal : accIdSet){
                if(accountsMap.containsKey(idVal)){
                    continue;
                }
                accIds.add(idVal);
            }
            List<Account> newAccList = new List<Account>();
            if(accIds.size()>0){
                newAccList = DH_ContactCenterQueryManager.getAccountList(accIds);
            }
            if(newAccList!=null && newAccList.size()>0){
                updateAccountsMap(newAccList);
            }
        }catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return accountsMap;
    }
	/**
	 * @Jira CC-526,702
	 * @description - This method will update the accountsMap with the new Account data.
	 * @param       - List<Account
	 * @return      - None
	 **/
	public static void updateAccountsMap(List<Account> newAccList) {
		for(Account accRec : newAccList){
            if(!accountsMap.containsKey(accRec.id)){
                accountsMap.put(accRec.id,accRec);
            }
        }
    }
	 /**
    * @Jira CC-702
    * @description - This method will return a map of VoiceCalls whose id are in the given relatedId.
    * @param       - Set<Id>
    * @return      - Map<Id,List<Voicecall>>
    **/
    public static Map<Id,List<VoiceCall>> getCallHistoryDetails(Set<Id> relatedId) {
        try {
            if(relatedIdVsVoiceCallListMap==null){
                relatedIdVsVoiceCallListMap= new  Map<Id,List<VoiceCall>>();
            }
            if(relatedId==null || relatedId.size()==0){
                return relatedIdVsVoiceCallListMap;
            }  
            List<Id> relatedIdList = new List<Id>();
            for(Id idVal : relatedId){
                if(relatedIdVsVoiceCallListMap.containsKey(idVal)){
                    continue;
                }
                relatedIdList.add(idVal);
            }
            Map<id,List<VoiceCall>> newVcMap = new Map<id,List<VoiceCall>>();
            if(relatedIdList.size()>0){
                newVcMap = DH_ContactCenterQueryManager.getRelatedIdVsVoiceCallListMap(relatedIdList);
            }
            if(newVcMap!=null && newVcMap.size()>0){
                updateRelatedVcMap(newVcMap);
            }
        }catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return relatedIdVsVoiceCallListMap;
    }
    /**
    * @Jira CC-702
    * @description - This method will update the relatedIdVsVoiceCallListMap with the new VoiceCall data.
    * @param       - Map<Id,List<VoiceCall>>
    * @return      - None
    **/
    public static void updateRelatedVcMap(Map<Id,List<VoiceCall>> newRelatedVcMap) {
        for(Id relatedId : newRelatedVcMap.keySet()){
            if(!relatedIdVsVoiceCallListMap.containsKey(relatedId)){
                relatedIdVsVoiceCallListMap.put(relatedId,newRelatedVcMap.get(relatedId));
            }
        }
    }
    /**
    * @Jira CC-702
    * @description - This method will return a map of EngagementInteraction whose id are in the given relatedId.
    * @param       - Set<Id>
    * @return      - Map<Id,List<EngagementInteraction>>
    **/
    public static Map<Id,List<EngagementInteraction>> getEngagementDetails(Set<Id> accId) {
        try {
            if(relatedIdEngagementInteractionMap==null){
                relatedIdEngagementInteractionMap= new  Map<Id,List<EngagementInteraction>>();
            }
            if(accId==null || accId.size()==0){
                return relatedIdEngagementInteractionMap;
            }  
            List<Id> accIdList = new List<Id>();
            for(Id idVal : accId){
                if(relatedIdEngagementInteractionMap.containsKey(idVal)){
                    continue;
                }
                accIdList.add(idVal);
            }
            Map<id,List<EngagementInteraction>> newEgMap = new Map<id,List<EngagementInteraction>>();
            if(accIdList.size()>0){
                newEgMap = DH_ContactCenterQueryManager.getEngagmentListMap(accIdList);
            }
            if(newEgMap!=null && newEgMap.size()>0){
                updateRelatedEgMap(newEgMap);
            }
        }catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return relatedIdEngagementInteractionMap;
    }
    /**
    * @Jira CC-702
    * @description - This method will update the relatedIdEngagementInteractionMap with the new EngagementInteraction data.
    * @param       - ap<Id,List<EngagementInteraction>>
    * @return      - None
    **/
    public static void updateRelatedEgMap(Map<Id,List<EngagementInteraction>> newRelatedEgMap) {
        for(Id accId : newRelatedEgMap.keySet()){
            if(!relatedIdEngagementInteractionMap.containsKey(accId)){
                relatedIdEngagementInteractionMap.put(accId,newRelatedEgMap.get(accId));
            }
        }
    }
    /**
    * @Jira CC-962
    * @description - This method will return a map of users whose id is on the list of Ids.
    * @param       - Set<Id>
    * @return      - Map<Id,User>
    **/
    public static Map<Id,User> getUsersMap(Set<Id> userIdSet) {
        try {
            if(userMap==null){
                userMap= new map<Id,User>();
            }
            if(userIdSet==null || userIdSet.size()==0){
                return userMap;
            }  
            List<Id> userIds = new List<Id>();
            for(Id idVal : userIdSet){
                if(userMap.containsKey(idVal)){
                    continue;
                }
                userIds.add(idVal);
            }
            List<User> newUserList = new List<User>();
            if(userIds.size()>0){
                newUserList = DH_ContactCenterQueryManager.getUserList(userIds);
            }
            if(newUserList!=null && newUserList.size()>0){
                updateUserMap(newUserList);
            }
        }catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return userMap;
    }
	/**
    * @Jira CC-962
    * @description - This method will update the usermap with the new timezone data.
    * @param       - List<User>
    * @return      - None
    **/
    public static void updateUserMap(List<User> newUserList) {
        for(User usr : newUserList){
            if(!userMap.containsKey(usr.Id)){
                userMap.put(usr.Id,usr);
            }
        }
    }
	/**
	 * @Jira CC-940
	 * @description - This method will return a map of VoiceCall whose Id is in the given vcIds.
	 * @param       - Set<Id>
	 * @return      - Map<Id,VoiceCall>
	 **/
	public static Map<Id, VoiceCall> getVcMap(Set<Id> vcIds) {
		try {
			if (voiceCallsMap == null) {
				voiceCallsMap = new Map<Id, VoiceCall>();
			}
			if (vcIds == null || vcIds.size() == 0) {
				return voiceCallsMap;
			}
			List<Id> vcList = new List<Id>();
			for (Id idVal : vcIds) {
				if (voiceCallsMap.containsKey(idVal)) {
					continue;
				}
				vcList.add(idVal);
			}
			List<VoiceCall> newVcList = new List<VoiceCall>();
			if (vcList.size() > 0) {
				newVcList = DH_ContactCenterQueryManager.getVcList(vcList);
			}
			if (newVcList != null && newVcList.size() > 0) {
				updateVcMap(newVcList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return voiceCallsMap;
	}
	/**
	 * @Jira CC-526
	 * @description - This method will update the voiceCallsMap with the new Voice call data.
	 * @param       - List<Group>
	 * @return      - None
	 **/
	public static void updateVcMap(List<VoiceCall> newVcList) {
		for (VoiceCall vcRec : newVcList) {
			if (!voiceCallsMap.containsKey(vcRec.Id)) {
				voiceCallsMap.put(vcRec.Id, vcRec);
			}
		}
	}
	/**
	* @Jira CC-940
	* @description - This method will return a map of Accounts whose DH_RIS_Unique_Code__c are in the given  in uniqueKeySet.
	* @param       - Set<String>
	* @return      - Map<String,Account>
	**/
    public static Map<String,Account> getUniqueKeyVsAccountMap(Set<String> uniqueKeySet){
        try {
			if (uniqueKeyVsAccountMap == null) {
				uniqueKeyVsAccountMap = new Map<String, Account>();
			}
			if (uniqueKeySet == null || uniqueKeySet.size() == 0) {
				return uniqueKeyVsAccountMap;
			}
			List<String> accIds = new List<String>();
			for (String idVal : uniqueKeySet) {
				if (uniqueKeyVsAccountMap.containsKey(idVal)) {
					continue;
				}
				accIds.add(idVal);
			}
			List<Account> newAccList = new List<Account>();
			if (accIds.size() > 0) {
				newAccList = DH_ContactCenterQueryManager.getUniqueKeyAccountList(accIds);
			}
			if (newAccList != null && newAccList.size() > 0) {
				updateUniqueKeyVsAccountsMap(newAccList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return uniqueKeyVsAccountMap;
    }
	/**
	* @Jira CC-940
	* @description - This method will update the map of Accounts(uniqueKeyVsAccountMap) with the new account data
	* @param       - List<Account>
	* @return      - void
	**/
    public static void updateUniqueKeyVsAccountsMap(List<Account> newAccList) {
		for (Account accRec : newAccList) {
			if (!uniqueKeyVsAccountMap.containsKey(accRec.DH_RIS_Unique_Code__c )) {
				uniqueKeyVsAccountMap.put(accRec.DH_RIS_Unique_Code__c , accRec);
			}
		}
	}
	/**
     * @Jira CC-633
     * @description - This method will return a map of ContactPointPhone whose key are in the given phoneKey.
     * @param       - Set<String>
     * @return      - Map<String,ContactPointPhone>
     **/
    public static Map<String,ContactPointPhone> getContactPhoneMap(Set<String> phoneKey,Id patientId) {
        try {
            if (contactPhoneMap == null) {
                contactPhoneMap = new Map<String,ContactPointPhone>();
            }
            if (phoneKey == null || phoneKey.size() == 0) {
                return contactPhoneMap;
            }
            List<String> phoneKeyList = new List<String>();
            for (String idVal : phoneKey) {
                if (contactPhoneMap.containsKey(idVal)) {
                    continue;
                }
                phoneKeyList.add(idVal);
            }
            List<ContactPointPhone> newPhoneList = new List<ContactPointPhone>();
            if (phoneKeyList.size() > 0) {
                newPhoneList = DH_ContactCenterQueryManager.getContactPointPhone(phoneKeyList,patientId);
            }
            if (newPhoneList != null && newPhoneList.size() > 0) {
                updateContactPhoneMap(newPhoneList);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return contactPhoneMap;
    }
    /**
     * @Jira CC-633
     * @description - This method will update the contactPhoneMap with the new data.
     * @param       - List<ContactPointPhone>
     * @return      - None
     **/
    public static void updateContactPhoneMap(List<ContactPointPhone> newPhoneList) {
        for (ContactPointPhone phoneRec : newPhoneList) {
            if (!contactPhoneMap.containsKey(phoneRec.DH_RIS_PhoneKey__c)) {
                contactPhoneMap.put(phoneRec.DH_RIS_PhoneKey__c, phoneRec);
            }
        }
    }
    /**
     * @Jira CC-664
     * @description - This method will return a map of ContactPointEmail whose key are in the given emailKey.
     * @param       - Set<String>
     * @return      - Map<String,ContactPointEmail>
     **/
    public static Map<String,ContactPointEmail> getContactEmailMap(Set<String> emailKey,Id patientId) {
        try {
            if (contactEmailMap == null) {
                contactEmailMap = new Map<String,ContactPointEmail>();
            }
            if (emailKey == null || emailKey.size() == 0) {
                return contactEmailMap;
            }
            List<String> emailKeyList = new List<String>();
            for (String idVal : emailKey) {
                if (contactEmailMap.containsKey(idVal)) {
                    continue;
                }
                emailKeyList.add(idVal);
            }
            List<ContactPointEmail> newEmailList = new List<ContactPointEmail>();
            if (emailKeyList.size() > 0) {
                newEmailList = DH_ContactCenterQueryManager.getContactPointEmail(emailKeyList,patientId);
            }
            if (newEmailList != null && newEmailList.size() > 0) {
                updateContactEmailMap(newEmailList);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return contactEmailMap;
    }
    /**
     * @Jira CC-664
     * @description - This method will update the contactEmailMap with the new data.
     * @param       - List<ContactPointEmail>
     * @return      - None
     **/
    public static void updateContactEmailMap(List<ContactPointEmail> newEmailList) {
        for (ContactPointEmail phoneRec : newEmailList) {
            if (!contactEmailMap.containsKey(phoneRec.DH_RIS_EmailKey__c)) {
                contactEmailMap.put(phoneRec.DH_RIS_EmailKey__c, phoneRec);
            }
        }
    }
    /**
     * @Jira CC-526
     * @description - This method will return a map of Groups whose developer name are in the given grpNames.
     * @param       - Set<String>
     * @return      - Map<Id,Group>
     **/
    public static Map<String, Group> getGroupList(Set<String> grpNames) {
        try {
            if (groupsMap == null) {
                groupsMap = new Map<String, Group>();
            }
            if (grpNames == null || grpNames.size() == 0) {
                return groupsMap;
            }
            List<String> grpList = new List<String>();
            for (String idVal : grpNames) {
                if (groupsMap.containsKey(idVal)) {
                    continue;
                }
                grpList.add(idVal);
            }
            List<Group> newGrpList = new List<Group>();
            if (grpList.size() > 0) {
                newGrpList = DH_ContactCenterQueryManager.getGroupList(grpList);
            }
            if (newGrpList != null && newGrpList.size() > 0) {
                updateGroupsMap(newGrpList);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return groupsMap;
    }
    /**
     * @Jira CC-526
     * @description - This method will update the groupsMap with the new group data.
     * @param       - List<Group>
     * @return      - None
     **/
    public static void updateGroupsMap(List<Group> newGrpList) {
        for (Group grpRec : newGrpList) {
            if (!groupsMap.containsKey(grpRec.DeveloperName)) {
                groupsMap.put(grpRec.DeveloperName, grpRec);
            }
        }
    }
	/**
	 * @Jira CC-572
	 * @description - This method will return a map of Accounts whose id are in the given accIdSet.
	 * @param       - Set<Id>
	 * @return      - Map<Id,Account>
	 **/
	public static Map<Id, DH_PayloadData__c> getPayloadMap(Set<Id> realtedToIdSet) {
		try {
			if (payloadMap == null) {
				payloadMap = new Map<Id, DH_PayloadData__c>();
			}
			if (realtedToIdSet == null || realtedToIdSet.size() == 0) {
				return payloadMap;
			}
			List<Id> relatedToIds = new List<Id>();
			for (Id idVal : realtedToIdSet) {
				if (payloadMap.containsKey(idVal)) {
					continue;
				}
				relatedToIds.add(idVal);
			}
			List<DH_PayloadData__c> newPayList = new List<DH_PayloadData__c>();
			if (relatedToIds.size() > 0) {
				newPayList = DH_ContactCenterQueryManager.getPayloadList(relatedToIds);
			}
			if (newPayList != null && newPayList.size() > 0) {
				updatePayloadMap(newPayList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return payloadMap;
	}
	/**
	 * @Jira CC-526
	 * @description - This method will update the accountsMap with the new Account data.
	 * @param       - List<Account
	 * @return      - None
	 **/
	public static void updatePayloadMap(List<DH_PayloadData__c> newPayList) {
		for (DH_PayloadData__c payRec : newPayList) {
			if (!payloadMap.containsKey(payRec.DH_RelatedTo__c)) {
				payloadMap.put(payRec.DH_RelatedTo__c, payRec);
			}
		}
	}
    /**
	 * @Jira CC-691
	 * @description - This method will return a map of Case whose id are in the given relatedAccountIdSet.
	 * @param       - Set<Id>
	 * @return      - Map<Id,Case>
	 **/
    public static Map<Id, Case> getCaseMap(Set<Id> relatedAccountIdSet){
        try {
			if (caseMap == null) {
				caseMap = new Map<Id, Case>();
			}
			if (relatedAccountIdSet == null || relatedAccountIdSet.size() == 0) {
				return caseMap;
			}
			List<Id> caseId = new List<Id>();
			for (Id idVal : relatedAccountIdSet) {
				if (caseMap.containsKey(idVal)) {
					continue;
				}
				caseId.add(idVal);
			}
			List<Case> newCaseList = new List<Case>();
			if (caseId.size() > 0) {
				newCaseList = DH_ContactCenterQueryManager.getCaseList(caseId);
			}
			if (newCaseList != null && newCaseList.size() > 0) {
				updateCaseMap(newCaseList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage() + e.getLineNumber());
		}
		return caseMap;
    }
    /**
	 * @Jira CC-691
	 * @description - This method will update the caseMap with the new Case data.
	 * @param       - List<Account
	 * @return      - None
	 **/
	public static void updateCaseMap(List<Case> newCaseList) {
		for (Case caseRec : newCaseList) {
			if (!caseMap.containsKey(caseRec.AccountId)) {
				caseMap.put(caseRec.AccountId, caseRec);
			}
		}
	}

	/**
	 * @Jira CC-520
     * @description - This method will return a map of email templates whose developer name are in the given eTNames.
	 * @param       - Set<String>
	 * @return      - Map<String, EmailTemplate>
	 **/
	public static Map<String, EmailTemplate> getEmailTemplateMap(Set<String> eTNames) {
		
		try {
			if (emailTemplateMap == null) {
				emailTemplateMap = new Map<String, EmailTemplate>();
			}
			if (eTNames == null || eTNames.size() == 0) {
				return emailTemplateMap;
			}
			Set<String> eTList = new Set<String>();
			for (String idVal : eTNames) {
				if (emailTemplateMap.containsKey(idVal)) {
					continue;
				}
				eTList.add(idVal);
			}
			List<EmailTemplate> newEmailTemplateList = new List<EmailTemplate>();
			if (eTList.size() > 0) {
				newEmailTemplateList = DH_ContactCenterQueryManager.getEmailTemplateList(eTList);
			}
			if (newEmailTemplateList != null && newEmailTemplateList.size() > 0) {
				updateEtMap(newEmailTemplateList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		
		return emailTemplateMap;
	}
	/**
	 * @Jira CC-520
	 * @description - This method will update the EmailTemplatesMap with the new EmailTemplate data.
	 * @param       - List<EmailTemplate>
	 * @return      - None
	 **/
	public static void updateEtMap(List<EmailTemplate> newEmailTemplateList) {
		for (EmailTemplate emailTemplateRec : newEmailTemplateList) {
			if (!emailTemplateMap.containsKey(emailTemplateRec.DeveloperName)) {
				emailTemplateMap.put(emailTemplateRec.DeveloperName, emailTemplateRec);
			}
		}
	}
	/**
	* @Jira CC-1203,1024
	* @description - This method will return a map of Name of permission set vs permissionset.
	* @param       - Set<String>
	* @return      - Map<String,PermissionSet>
	**/
	public static Map<String, PermissionSet> getPermissionSetMap(Set<String> permissionNameSet){
		try {
			if (permissionNameVsPermissionsetMap == null) {
				permissionNameVsPermissionsetMap = new Map<String, PermissionSet>();
			}
			if (permissionNameSet == null || permissionNameSet.size() == 0) {
				return permissionNameVsPermissionsetMap;
			}
			List<String> permissionNameList = new List<String>();
			for (String permissionName : permissionNameSet) {
				if (permissionNameVsPermissionsetMap.containsKey(permissionName)) {
					continue;
				}
				permissionNameList.add(permissionName);
			}
			List<PermissionSet> newPermissionSetList = new List<PermissionSet>();
			if (permissionNameList.size() > 0) {
				newPermissionSetList = DH_ContactCenterQueryManager.getPermissionSets(permissionNameList);
			}
			if (newPermissionSetList != null && newPermissionSetList.size() > 0) {
				updatePermissionNameVsPermissionsetMap(newPermissionSetList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage()  + ' ' +e.getLineNumber());
		}
		return permissionNameVsPermissionsetMap;
	}
	/**
	* @Jira CC-1203,1024
	* @description - This method will update the map of permissionNameVsPermissionsetMap
	* @param       - Set<String>
	* @return      - Void
	**/
	public static void updatePermissionNameVsPermissionsetMap(List<PermissionSet> newPermissionSetList) {
		for (PermissionSet permissionSetRec : newPermissionSetList) {
			if (!permissionNameVsPermissionsetMap.containsKey(permissionSetRec.Name )) {
				permissionNameVsPermissionsetMap.put(permissionSetRec.Name , permissionSetRec);
			}
		}
	}
    /**
	* @Jira CC-1203,1024
	* @description - This method will return a map of Name of profile  vs its ID.
	* @param       - Set<String>
	* @return      - Map<String,PermissionSet>
	**/
	public static Map<String,Profile > getProfileNameVsProfileMap(Set<String> permissionSetGroupSet){
		try {
			if (profileNameVsProfileMap == null) {
				profileNameVsProfileMap = new Map<String, Profile>();
			}
			if (permissionSetGroupSet == null || permissionSetGroupSet.size() == 0) {
				return profileNameVsProfileMap;
			}
			List<String> profileNameList = new List<String>();
			for (String profileName : permissionSetGroupSet) {
				if (profileNameVsProfileMap.containsKey(profileName)) {
					continue;
				}
				profileNameList.add(profileName);
			}
			List<Profile> newProfileList = new List<Profile>();
			if (profileNameList.size() > 0) {
				newProfileList = DH_ContactCenterQueryManager.getProfileList(profileNameList);
			}
			if (newProfileList != null && newProfileList.size() > 0) {
				updateProfileNameVsProfileMap(newProfileList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage()  + ' ' +e.getLineNumber());
		}
		return profileNameVsProfileMap;
	}
	/**
	* @Jira CC-1203,1024
	* @description - This method will update the map of profileNameVsProfileMap
	* @param       - Set<String>
	* @return      - Void
	**/
	public static void updateProfileNameVsProfileMap(List<Profile> newProfileList) {
		for (Profile prof : newProfileList) {
			if (!profileNameVsProfileMap.containsKey(prof.Name)) {
				profileNameVsProfileMap.put(prof.Name , prof);
			}
		}
	}
	/**
	* @Jira CC-1203,1204
	* @description - This method will return a map of Permission set Group.
	* @param       - Set<String>
	* @return      - Map<String,PermissionSet>
	**/
	public static Map<String,PermissionSetGroup > getPermissionSetGroupMap(Set<String> permissionSetGroupSet){
        try {
			if (permissionSetGroupMap == null) {
				permissionSetGroupMap = new Map<String, PermissionSetGroup>();
			}
			if (permissionSetGroupSet == null || permissionSetGroupSet.size() == 0) {
				return permissionSetGroupMap;
			}
			List<String> permissionSetGroupList = new List<String>();
			for (String prsmGroupName : permissionSetGroupSet) {
				if (permissionSetGroupMap.containsKey(prsmGroupName)) {
					continue;
				}
				permissionSetGroupList.add(prsmGroupName);
			}
			List<PermissionSetGroup> newPermissionSetGroupList = new List<PermissionSetGroup>();
			if (permissionSetGroupList.size() > 0) {
				newPermissionSetGroupList = DH_ContactCenterQueryManager.getPermissionSetGroup(permissionSetGroupList);
			}
			if (newPermissionSetGroupList != null && newPermissionSetGroupList.size() > 0) {
				updatePermissionSetGroupMap(newPermissionSetGroupList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage()  + ' ' +e.getLineNumber());
		}
		return permissionSetGroupMap;
	}
	/**
	 * @Jira CC-1203,1204
	 * @description - This method will update the permissionSetGroupMap with the new nameVspermissionSetGroup Interaction data.
	 * @param       - List<EngagementInteraction>
	 * @return      - None
	 **/
	public static void updatePermissionSetGroupMap(List<PermissionSetGroup> newPermSetGroupList) {
		for (PermissionSetGroup permSetGroup : newPermSetGroupList) {
			if (!permissionSetGroupMap.containsKey(permSetGroup.DeveloperName)) {
				permissionSetGroupMap.put(permSetGroup.DeveloperName, permSetGroup);
			}
		}
	}
	/**
	 * @Jira CC-491
	 * @description - This method will return a map of EngagementInteraction whose id are in the given accIdSet.
	 * @param       - Set<String>
	 * @return      - Map<Id, EnagagementInteraction>
	 **/
	public static Map<Id, EngagementInteraction> getEiMap(Set<String> eiIdSet) {
		try {
			if (eiMap == null) {
				eiMap = new Map<Id, EngagementInteraction>();
			}
			if (eiIdSet == null || eiIdSet.size() == 0) {
				return eiMap;
			}
			List<String> eiIds = new List<String>();
			for (String idVal : eiIdSet) {
				if (eiMap.containsKey(idVal)) {
					continue;
				}
				eiIds.add(idVal);
			}
			List<EngagementInteraction> newEiList = new List<EngagementInteraction>();
			if (eiIds.size() > 0) {
				newEiList = DH_ContactCenterQueryManager.getEiRecords(eiIds);
			}
			if (newEiList != null && newEiList.size() > 0) {
				updateEiMap(newEiList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
		return eiMap;
	}
	/**
	 * @Jira CC-491
	 * @description - This method will update the eiMap with the new Engagement Interaction data.
	 * @param       - List<EngagementInteraction>
	 * @return      - None
	 **/
	public static void updateEiMap(List<EngagementInteraction> newEiList) {
		for (EngagementInteraction eiRec : newEiList) {
			if (!eiMap.containsKey(eiRec.id)) {
				eiMap.put(eiRec.id, eiRec);
			}
		}
	}
	/**
	 * @Jira CC-491
	 * @description - This method will return a map of IER based on the values from the DH_DexOutServiceRisEngagementRequest wrapper.
	 * @param       - DH_DexOutServiceRisEngagementRequest
	 * @return      - Map<String,et4ae5__IndividualEmailResult__c>
	 **/
	public static Map<String,et4ae5__IndividualEmailResult__c> getIerMap(DH_DexOutServiceRisEngagementRequest wrapper){
		try {
				Set<String> batchIdSet = new Set<String>();
				Set<String> emailIdSet = new Set<String>();
				Set<String> jobIdSet = new Set<String>();
				Set<String> subscriberIdSet = new Set<String>();
				if(ierMap == null) {
					ierMap = new Map<String,et4ae5__IndividualEmailResult__c>();
				}
				if(wrapper == null) {
					return ierMap;
				}
				for(String keyVal : wrapper.uniqueKeyVsEiMap.keySet()) {
					if (ierMap.containsKey(keyVal)) {
						continue;
					}
					batchIdSet.add(wrapper.uniqueKeyVsEiMap.get(keyVal).DH_BatchId__c);
					emailIdSet.add(wrapper.uniqueKeyVsEiMap.get(keyVal).DH_EmailId__c);
					jobIdSet.add(wrapper.uniqueKeyVsEiMap.get(keyVal).DH_JobId__c);
					subscriberIdSet.add(wrapper.uniqueKeyVsEiMap.get(keyVal).ExternalIdentifier);
				}
				DH_DexOutServiceRisEngagementRequest eIWrapper = new DH_DexOutServiceRisEngagementRequest();
				eIWrapper.batchIdSet = batchIdSet;
				eIWrapper.emailIdSet = emailIdSet;
				eIWrapper.jobIdSet = jobIdSet;
				eIWrapper.subscriberIdSet = subscriberIdSet;
				List<et4ae5__IndividualEmailResult__c> newIerList = new List<et4ae5__IndividualEmailResult__c>();
				if(eIWrapper != null) {
					newIerList = DH_ContactCenterQueryManager.getIerList(eIWrapper);
				}
				if(newIerList != null && newIerList.size() > 0) {
					updateIerMap(newIerList);
				}
			} 
			catch(Exception e) {
				System.debug(LoggingLevel.ERROR, e.getMessage());
			}
		return ierMap;
	}
	/**
	 * @Jira CC-491
	 * @description - This method will update the ierMap with the new IER data where the key will be the uniquekey combination of batchId,jobId,emailId and subscriberId.
	 * @param       - List<et4ae5__IndividualEmailResult__c>
	 * @return      - None
	 **/
	public static void updateIerMap(List<et4ae5__IndividualEmailResult__c> newIerList) {
		for(et4ae5__IndividualEmailResult__c ier : newIerList) {
			String key = ier.et4ae5__BatchId__c + ier.et4ae5__Email_ID__c + ier.et4ae5__JobId__c + ier.et4ae5__SubscriberId__c;
			if(!ierMap.containsKey(ier.Id)) {
				ierMap.put(key,ier);
			}
		}
	}
}