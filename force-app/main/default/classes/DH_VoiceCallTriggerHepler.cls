/*
* ***************************************************************************************************************************
* Apex Class Name - DH_VoiceCallTriggerHepler
* Created Date - 24-July-2024
* @description : Helper class for DH_VoiceCallTriggerHandler.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ----------------------------------------------
* CC-526                   24-July-2024         Added createVoiceCallShareRecord and getPublicGroups methods.
* CC-691                   06-August-2024       Added closeCase and invokeCloseTabEvent methods
* CC-692                   02-September-2024    Added updatePreviousVoiceCallRecord and udpateTransferredVoiceCall methods.
* CC-1199                  09-September-2024    Updated F9_Call_disposition_name__c to 'Transferred'
* CC-1347                  30-September-2024    Updated Trasnferred to, Transferred From and Transfer notes summary.
* CC-692                   30-September-2024    Added spaces before and after the delimiter in transfer notes summary.
* CC-1453				   29-November-2024		Updated invokeCloseTabEvent method and reduced cognitive complexity.
* *******************************************************************************************************************************************
*/
public without sharing class DH_VoiceCallTriggerHepler {
    /**
	* @Jira CC-526
    * @description - This method will create VoiceCallShare record which will provide access to the VoiceCall record.
    * @param       - List<VoiceCall>
    * @return      - None
	**/
    public static void createVoiceCallShareRecord(List<VoiceCall> newVoiceCall, Map<Id,VoiceCall> oldmap){
        List<VoiceCallShare> vcShareRecList = new List<VoiceCallShare>();
        List<VoiceCall> listName = new List<VoiceCall>();
        DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
        Id userId = userInfo.getUserId();
		User currentUser = [select id,DH_User_Region__c from User where id=:userId];
        String recordId;
        Map<String,Id> grpNameVsId = DH_VoiceCallTriggerHepler.getPublicGroups();
        List<String> eastCoastRegion = DH_VoiceCallTriggerHepler.getEastCoastRegion();
        List<String> westCoastRegion = DH_VoiceCallTriggerHepler.getWestCoastRegion();
        Set<Id> vcIds = new Set<Id>();
        try {
            for(VoiceCall vc : newVoiceCall){
                if(vc.callType=='Outbound' && currentUser.DH_User_Region__c=='East'){
                    for(String eastRegion :eastCoastRegion){
                    vcShareRecList.add(DH_VoiceCallTriggerHepler.getVoiceCallShareRecord(vc,grpNameVsId.get(eastRegion)));  
                    }                 	   
                }
                else if(vc.callType=='Outbound' && currentUser.DH_User_Region__c=='West'){
                    for(String westRegion :westCoastRegion){
					vcShareRecList.add(DH_VoiceCallTriggerHepler.getVoiceCallShareRecord(vc,grpNameVsId.get(westRegion)));   
                    }       
                }
              	else if(vc.F9_DH_SystemId__c!= null && grpNameVsId != null && !(grpNameVsId.isEmpty())){					
                    vcShareRecList.add(DH_VoiceCallTriggerHepler.getVoiceCallShareRecord(vc,grpNameVsId.get(vc.F9_DH_SystemId__c)));
                }
            }
            if(vcShareRecList != null && Schema.sObjectType.VoiceCallShare.isCreateable()){
                insert vcShareRecList;
            }
        } catch (Exception ex) {
            logWrapper.exp =  ex;
            logWrapper.relatedTo = recordId;
            logWrapper.className = 'DH_VoiceCallTriggerHepler-createVoiceCallShareRecord';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
    }
    /**
	* @Jira CC-526
    * @description - This method will return a map where we will store the public group developer name as key and Id as value.
    * @param       - None
    * @return      - Map<String,Id>
	**/
    public static Map<String,Id> getPublicGroups(){
        Set<String> regionSet = new Set<String>{'AZ_Region_Team','CA_Region_Team','FL_Region_Team','MA_Region_Team','NE_Region_Team'};        
        List<Group> regionsList = DH_ContactCenterCachingUtility.getGroupList(regionSet).values();
        Map<String,Id> grpNameVsId = new Map<String,Id>();
        if(regionsList != null){
            for(Group gc : regionsList){
                String regionName = gc.DeveloperName.substring(0,2);
                grpNameVsId.put(regionName,gc.Id);
            }
        }
        return grpNameVsId;
    }
    
    /**
	* @Jira 
    * @description - This method will return list of east coast regions.
    * @param       - None
    * @return      - List<String>
	**/
    public static List<String> getEastCoastRegion(){
        List<String> eastCoastRegionList = new List<String>{'FL','MA','NE'};        
        return eastCoastRegionList;
    }
    

  /**
	* @Jira 
    * @description - This method will return list of west coast regions.
    * @param       - None
    * @return      - List<String>
	**/
    public static List<String> getWestCoastRegion(){
        List<String> westCoastRegionList = new List<String>{'AZ','CA','TX'};        
        return westCoastRegionList;
    }
    
     /**
	* @Jira 
    * @description - This method will return voicecallshare record.
    * @param       - None
    * @return      - List<String>
	**/
    public static VoiceCallShare getVoiceCallShareRecord(VoiceCall vc,Id region){
 	VoiceCallShare vcShareRec = new VoiceCallShare();
    vcShareRec.ParentId = vc.Id;
    vcShareRec.AccessLevel = DH_GlobalConstants.VOICE_CALL_ACCESS;
    vcShareRec.RowCause = DH_GlobalConstants.VOICE_CALL_ROW_CAUSE;
    vcShareRec.UserOrGroupId = region;
    return vcShareRec;
    }
    
    
    /**
	* @Jira CC-691
    * @description - This method will invoke a close tab platform event.
    * @param       - Map<Id,VoiceCall> , Map<id,VoiceCall>
    * @return      - void
	**/
    public static void invokeCloseTabEvent(Map<Id, VoiceCall> oldVoiceCallMap,Map<Id, VoiceCall> newVoiceCallMap){
        Boolean isMultiChannel = Boolean.valueOf(System.Label.DH_IsMultipleChannel);
        Id currentUserId = UserInfo.getUserId();
        System.debug('isMultiChannel'+isMultiChannel);
        System.debug('currentUserId'+currentUserId);
        Set<Id> relatedRecordIdList = new Set<Id>();
        for(VoiceCall vc: newVoiceCallMap.values()){
            if(vc.RelatedRecordId!=null){
                relatedRecordIdList.add(vc.RelatedRecordId);
            }
        }
        Map<Id,Case> caseMap = DH_ContactCenterCachingUtility.getCaseMap(relatedRecordIdList);
        List<Case> caseUpdateList = new List<Case>();
        for(Id vc : newVoiceCallMap.keySet()){
            System.debug('Outside if condition invokeCloseTabEvent method vc id'+vc);
            System.debug('Outside New VC Map F9_Call_disposition_name__c'+newVoiceCallMap.get(vc).F9_Call_disposition_name__c);
            System.debug('Outside Old VC Map F9_Call_disposition_name__c'+oldVoiceCallMap.get(vc).F9_Call_disposition_name__c);
            System.debug('Outside New VC Map CallDisposition'+newVoiceCallMap.get(vc).CallDisposition);
            System.debug('Outside Old VC Map CallDisposition'+oldVoiceCallMap.get(vc).CallDisposition);
            System.debug('DH_GlobalConstants.COMPLETED'+DH_GlobalConstants.COMPLETED);
            System.debug('DH_GlobalConstants.IN_PROGRESS'+DH_GlobalConstants.IN_PROGRESS);
            if(((newVoiceCallMap.get(vc).F9_Call_disposition_name__c !=null && oldVoiceCallMap.get(vc).F9_Call_disposition_name__c==null) && newVoiceCallMap.get(vc).CallDisposition !=null && (newVoiceCallMap.get(vc).CallDisposition).equalsIgnoreCase(DH_GlobalConstants.COMPLETED))
            || (newVoiceCallMap.get(vc).CallDisposition !=null && oldVoiceCallMap.get(vc).CallDisposition != null && ((newVoiceCallMap.get(vc).CallDisposition).equalsIgnoreCase(DH_GlobalConstants.COMPLETED) && (oldVoiceCallMap.get(vc).CallDisposition).equalsIgnoreCase(DH_GlobalConstants.IN_PROGRESS)) && newVoiceCallMap.get(vc).F9_Call_disposition_name__c!=null))
            {
                System.debug('Inside invokeCloseTabEvent method vc id'+vc);
                String eventApiName;
                Database.SaveResult sr;
                if(isMultiChannel){
                    System.debug('Inside MultipleChannel condition');
                    Integer groupNum = DH_VoiceCallTriggerHepler.getGroupNumberForUser(newVoiceCallMap.get(vc).OwnerId);
                    System.debug('groupNum'+groupNum);
                    if (groupNum == null) {
                        groupNum = 1;
                    }
                    eventApiName = 'CloseVC_Group' + groupNum + '__e';
                    sObject eventInstance = (sObject)Type.forName(eventApiName).newInstance();
                    eventInstance.put('DH_ServiceName__c', DH_GlobalConstants.CALL_END_EVENT);
                    eventInstance.put('DH_SObjectId__c', newVoiceCallMap.get(vc).DH_NameFormula__c);
                    System.debug('eventInstance'+eventInstance);
                    sr = EventBus.publish(eventInstance);  
                    System.debug('Using Channel : '+eventApiName);
                }else{
                    System.debug('Using Channel : DH_EventLog__e');
                    DH_EventLog__e callEvent = new DH_EventLog__e(DH_SObjectId__c=newVoiceCallMap.get(vc).DH_NameFormula__c, DH_ServiceName__c=DH_GlobalConstants.CALL_END_EVENT);
                    sr = EventBus.publish(callEvent);
                }
                DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
                boolean closeCase = newVoiceCallMap.get(vc).RelatedRecordId!=null && String.valueof((Id.valueOf(newVoiceCallMap.get(vc).RelatedRecordId)).getSObjectType())==DH_GlobalConstants.ACCOUNT;
                if(closeCase){
                    caseUpdateList.add(caseMap.get(newVoiceCallMap.get(vc).RelatedRecordId));
                }
                String errorMsg='';
                for(Database.Error err : sr.getErrors()) {                 
                    errorMsg =errorMsg + ' ' + err.getStatusCode() + ': ' + err.getMessage();
                }
                String eventName = isMultiChannel ? eventApiName : 'DH_EventLog__e';
                String caseId = closeCase?String.valueOf(caseMap.get(newVoiceCallMap.get(vc).RelatedRecordId)):DH_GlobalConstants.NO_PATIENT_LAUNCH;
               	logWrapper.relatedTo = String.valueOf(vc);
                logWrapper.className = 'DH_VoiceCallTriggerHepler-invokeCloseTabEvent'+eventName+'-'+String.valueOf(vc)+'-'+caseId;
                if(errorMsg.contains(DH_GlobalConstants.OPERATION_ENQUEUED)){
                    logWrapper.payload = errorMsg;
                }else{
                    logWrapper.errorMessage = errorMsg;
                }
              	logWrapper.serviceName = DH_GlobalConstants.CALL_END_EVENT;
                DH_DexLoggingUtility.createLogRecord(logWrapper);
                System.debug('Log record created');
            }
        }
        if(caseUpdateList !=null && caseUpdateList.size()>0){
            closeCase(caseUpdateList);
        }
    }
    
    /**
	* @Jira        - CC-1578
    * @description - This method will get the group number for the user
    * @param       - None
    * @return      - List<String>
	**/
    @AuraEnabled
    public static Integer getGroupNumberForUser(Id userId) {
        List<GroupMember> memberships = [
            SELECT Group.Name
            FROM GroupMember
            WHERE UserOrGroupId = :userId
              AND Group.Type = 'Regular'
              AND Group.Name LIKE 'AgentGroup%' LIMIT 1
        ];
        if(memberships.size() == 0){
            return 1;
        }
        GroupMember gm = memberships[0];
        String groupName = gm.Group.Name;
        if (groupName.startsWith('AgentGroup')) {
            String groupNumStr = groupName.replace('AgentGroup', '');
            return Integer.valueOf(groupNumStr);
        }
        return null;
    }

 /**
	* @Jira 
    * @description - This method will update the phone format
    * @param       - None
    * @return      - List<String>
	**/
    public static void updatePhoneFormat(List<VoiceCall> newVoiceCall){
        for(VoiceCall vc : newVoiceCall){
        String phNumber='';
        if(vc.F9_Call_ANI__c!=null && !vc.F9_Call_ANI__c.contains('(')){
         vc.F9_Call_ANI__c = '('+ newVoiceCall[0].F9_Call_ANI__c.substring(0,3)+') '+newVoiceCall[0].F9_Call_ANI__c.substring(3,6)+'-'+newVoiceCall[0].F9_Call_ANI__c.substring(6,10);
        } 
        if(vc.F9_Call_DNIS__c!=null && !vc.F9_Call_DNIS__c.contains('(')){
         vc.F9_Call_DNIS__c = '('+ newVoiceCall[0].F9_Call_DNIS__c.substring(0,3)+') '+newVoiceCall[0].F9_Call_DNIS__c.substring(3,6)+'-'+newVoiceCall[0].F9_Call_DNIS__c.substring(6,10);
        }            
    }
    }

     /**
	* @Jira 
    * @description - This method will remove the phone format
    * @param       - None
    * @return      - String
	**/
    public static String removePhoneFormat(String phoneNumber){
      String phNumber =phoneNumber.replace('(','').replace(')','').replace('-','').replace(' ','');   
      return phNumber;      
    }

    
     /**
	* @Jira 
    * @description - This method will update the previous verified caller as null 
    * @param       - None
    * @return      - List<String>
	**/
    @AuraEnabled
    public static void validatePreviousVerifiedCaller(Id voiceCallId){
       VoiceCall vc = [Select Id,RelatedRecordId from VoiceCall where id=:voiceCallId];
        if(vc!=null){
            vc.RelatedRecordId=null;
            update vc;
        }
        
    }
    
    /**
	* @Jira CC-691
    * @description - This method will mark the case status as closed.
    * @param       - String , String 
    * @return      - void
	**/
    public static void closeCase(List<Case> caseList){
        DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
        try{
            List<Case> updateCaseList = new List<Case>();
            for(Case cs: caseList){
                cs.Status = DH_GlobalConstants.CASE_STATUS_CLOSED;
                updateCaseList.add(cs);
            }
            if(updateCaseList != null && updateCaseList.size()>0 && Schema.sObjectType.Case.isUpdateable()){
                update updateCaseList;
            }
        }catch(Exception e){
            logWrapper.exp =  e;
            logWrapper.className = 'DH_VoiceCallTriggerHepler-closeCase';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
    }
    /**
	* @Jira CC-692
    * @description - This method will update the Transfered Notes Summary, Related Record Id and Transfered from field.
    * @param       - Map , Map 
    * @return      - void
	**/
    public static void udpateTransferredVoiceCall(Map<Id, VoiceCall> oldVoiceCallMap,Map<Id, VoiceCall> newVoiceCallMap){
        DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
        try {
            Set<Id> voiceCallIds =  new Set<Id>();
            Map<Id, VoiceCall> idVsVoiceCall =  new Map<Id, VoiceCall>();
            List<VoiceCall> voicecallsToBeUpdated = new List<VoiceCall>();
            for(VoiceCall vc : newVoiceCallMap.Values()){
            if(newVoiceCallMap.get(vc.Id).F9_DH_SystemId__c!=null &&
                (vc.callType.equalsIgnoreCase(DH_GlobalConstants.CALL_TYPE_TRANSFER) && vc.PreviousCallId!=null)){
                    voiceCallIds.add(vc.Id);
                    voiceCallIds.add(vc.PreviousCallId);
                }
            }
            if(voiceCallIds.size()!=0){
                idVsVoiceCall = DH_ContactCenterCachingUtility.getVcMap(voiceCallIds) ;
            }
            for(VoiceCall vc : newVoiceCallMap.Values()){
                if(newVoiceCallMap.get(vc.Id).F9_DH_SystemId__c!=null && vc.PreviousCallId!=null&& vc.callType.equalsIgnoreCase(DH_GlobalConstants.CALL_TYPE_TRANSFER)){

                    if(idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotes__c==null && idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotesSummary__c!=null){
                        vc.DH_TransferNotesSummary__c =  idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotesSummary__c;
                    }
                    else if(idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotes__c!=null && idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotesSummary__c==null){
                        vc.DH_TransferNotesSummary__c =  idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotes__c;
                    }
                    else if(idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotes__c!=null && idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotesSummary__c!=null){
                        vc.DH_TransferNotesSummary__c =  idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotes__c+' '+DH_GlobalConstants.PIPE_DELIMITER+' '+idVsVoiceCall.get(vc.PreviousCallId).DH_TransferNotesSummary__c;
                    }
                    else{
                        vc.DH_TransferNotesSummary__c=null;
                    }
                    vc.DH_TransferredFrom__c =idVsVoiceCall.get(vc.PreviousCallId).Five9BYOT__F9_AgentName__c;
                    system.debug(' vc.RelatedRecordId '+ vc.RelatedRecordId);
                    vc.RelatedRecordId = idVsVoiceCall.get(vc.PreviousCallId).RelatedRecordId;
                    voicecallsToBeUpdated.add(vc);
                }
            }
            if(voicecallsToBeUpdated.size()!=0  && Schema.sObjectType.VoiceCall.isUpdateable()){
                update voicecallsToBeUpdated;
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + e.getLineNumber());
        }
    }

    /**
	* @Jira CC-692
    * @description - This method will update the Transfered To field.
    * @param       - Map , Map 
    * @return      - void
	**/
    public static void updatePreviousVoiceCallRecord(Map<Id, VoiceCall> oldVoiceCallMap,Map<Id, VoiceCall> newVoiceCallMap){
        DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
        try {
            Set<Id> voiceCallIds =  new Set<Id>();
            Map<Id, VoiceCall> idVsVoiceCall =  new Map<Id, VoiceCall>();
            List<VoiceCall> voicecallsToBeUpdated = new List<VoiceCall>();
            for(VoiceCall vc : newVoiceCallMap.Values()){
                if(newVoiceCallMap.get(vc.Id).F9_DH_SystemId__c!=null &&
                (vc.callType.equalsIgnoreCase(DH_GlobalConstants.CALL_TYPE_TRANSFER) && vc.PreviousCallId!=null)){
                    voiceCallIds.add(vc.Id);
                    voiceCallIds.add(vc.PreviousCallId);
                }      
            }
            if(voiceCallIds.size()!=0){
                idVsVoiceCall = DH_ContactCenterCachingUtility.getVcMap(voiceCallIds) ;    
            }
            for(VoiceCall vc : idVsVoiceCall.values()){
                if(vc.NextCallId!=null){
                    vc.DH_TransferredTo__c = (newVoiceCallMap.get(vc.NextCallId).F9_Call_skill_name__c!=null?newVoiceCallMap.get(vc.NextCallId).F9_Call_skill_name__c +' '+ DH_GlobalConstants.PIPE_DELIMITER+' '+newVoiceCallMap.get(vc.NextCallId).Five9BYOT__F9_AgentName__c:newVoiceCallMap.get(vc.NextCallId).Five9BYOT__F9_AgentName__c);
                    vc.F9_Call_disposition_name__c=DH_GlobalConstants.CALL_DISPOSITION_TRANSFERRED;
                    voicecallsToBeUpdated.add(vc);
                }
            }
            if(voicecallsToBeUpdated.size()!=0 && Schema.sObjectType.VoiceCall.isUpdateable()){
                update voicecallsToBeUpdated;
            }
        } catch (Exception e) {
            System.debug(e.getMessage()+e.getLineNumber());
        }
    }    
}