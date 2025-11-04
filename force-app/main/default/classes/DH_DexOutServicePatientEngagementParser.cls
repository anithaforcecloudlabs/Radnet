/*
* ***************************************************************************************************************************
* Apex Class Name : DH_DexOutServicePatientEngagementParser
* Created Date : 30-Jun-2024 
* @description : Parser class to parse the json response of the DH_DexOutServicePatientEngagement service class.
* Modification Log :
* ---------------------------------------------------------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-702                   30-Jun-2024          Added getEngagementList and constructEngagementList methods.
* CC-527,534               19 July-2024         Added getEngagementData,constructEngagmentData and constructCallHistory methods.
* CC-1154                  26-Aug-2024          Added updateEngagementInteractionMap method.
* CC-1288                  06-Sep-2024          Time and Date formate and Placement bug fix.
* CC-1377                  30-Sep-2024          Changes related to removal of in-progress voicecall from engagement interaction.
* CC-1483                  09-Jan-2025          Added logic to include AutoCalls and Inbound SMS in PE History
* **********************************************************************************************************************************
*/
public class DH_DexOutServicePatientEngagementParser{
    public static Map<String,List<DH_DexEngagementInteraction>> mapOfResponse = new Map<String,List<DH_DexEngagementInteraction>>();
    /**
    * @Jira CC-702
    * @description - This method returns engagement list for quick message based on quickMessageResponse.
    * @param       - String
    * @return      - List<DH_DexOutServiceEngagementResponse>
    **/
    public static List<DH_DexOutServiceEngagementResponse> getEngagementList(String quickMessageResponse){
        List<DH_DexOutServiceEngagementResponse> engagementList = new List<DH_DexOutServiceEngagementResponse>();
        if(quickMessageResponse != null){
        List<List<DH_DexOutServiceQuickMessageResponse>> quickMessageListOfList = (List<List<DH_DexOutServiceQuickMessageResponse>>) JSON.deserialize(quickMessageResponse, List<List<DH_DexOutServiceQuickMessageResponse>>.class);
        engagementList = constructEngagementList(quickMessageListOfList[0]);
        }
        return engagementList;
    }
    /**
    * @Jira CC-702
    * @description - This method returns concated final engagement list for all engagement data based on quickMessageResponse , Acc Id.
    * @param       - List<DH_DexOutServiceEngagementResponse> qmEgList, Id accId
    * @return      - List<DH_DexOutServiceEngagementResponse>
    **/
    public static List<DH_DexOutServiceEngagementResponse> getEngagementData(List<DH_DexOutServiceEngagementResponse> qmEgList, Id accId){
        List<DH_DexOutServiceEngagementResponse> engagementList = new List<DH_DexOutServiceEngagementResponse>();
        engagementList.addAll(qmEgList);
        Set<Id> recordSet = new Set<Id>();
        if(accId != null){
            recordSet.add(accId);
        }
        Map<Id, List<VoiceCall>> callData = new Map<Id, List<VoiceCall>>();
        Map<id,List<EngagementInteraction>> newEgMap = new Map<id,List<EngagementInteraction>>();
        if(recordSet != null){
            callData = DH_ContactCenterCachingUtility.getCallHistoryDetails(recordSet);
            newEgMap = DH_ContactCenterCachingUtility.getEngagementDetails(recordSet);
        }
        if(callData !=null && !callData.isEmpty()){
            engagementList.addAll(constructCallHistory(callData.get(accId)));
        }
        if(newEgMap != null && !newEgMap.isEmpty()){
            engagementList.addAll(constructEngagmentData(newEgMap.get(accID)));
        }
        engagementList.sort();
        return engagementList;
    }
    /**
    * @Jira CC-702
    * @description - This method returns engagement list for quick message based on quickMessage converted List.
    * @param       - List<DH_DexOutServiceQuickMessageResponse>
    * @return      - List<DH_DexOutServiceEngagementResponse>
    **/
    public static List<DH_DexOutServiceEngagementResponse> constructEngagementList(List<DH_DexOutServiceQuickMessageResponse> quickMessageList){
        List<DH_DexOutServiceEngagementResponse> engagementList = new List<DH_DexOutServiceEngagementResponse>();
        DateTime dateToday=DateTime.now();
        DateTime dateToCheck = dateToday.addDays(Integer.valueOf(System.Label.DH_MaxEngagementDaysCount));
        for (DH_DexOutServiceQuickMessageResponse qmessage : quickMessageList) {
            if(qmessage.contact_date>dateToCheck && engagementList.size()<Integer.valueOf(System.Label.DH_MaxQuickMessageCount)){
                DH_DexOutServiceEngagementResponse engagementRecord =new DH_DexOutServiceEngagementResponse();
                TimeZone userTimeZone = UserInfo.getTimeZone();
                engagementRecord.uniqueID = String.valueOf(qmessage.order_key);
                engagementRecord.subject = qmessage.notes;
                engagementRecord.iconVariant = 'standard:feedback';
                engagementRecord.description = qmessage.last_updated_by_user_id+' sent this message';
                engagementRecord.timeStamp = qmessage.contact_date;
                engagementRecord.displayTime = qmessage.contact_date.format('hh:mm a');
                engagementRecord.displayDate = qmessage.contact_date.format('MM-dd-yyyy');
                engagementList.add(engagementRecord);
            }else if(engagementList.size()<Integer.valueOf(System.Label.DH_MaxQuickMessageCount)){
                continue;
            }else{
                break;
            }
        }
        return engagementList;
    }
    /**
    * @Jira CC-702
    * @description - This method returns engagement list for SMS and Email based on EngagementInteraction data.
    * @param       - List<EngagementInteraction>
    * @return      - List<DH_DexOutServiceEngagementResponse>
    **/
    public static List<DH_DexOutServiceEngagementResponse> constructEngagmentData(List<EngagementInteraction> enganmentDataList){
        List<DH_DexOutServiceEngagementResponse> engagementList = new List<DH_DexOutServiceEngagementResponse>();
        DateTime dateToday=DateTime.now();
        DateTime dateToCheck = dateToday.addDays(Integer.valueOf(System.Label.DH_MaxEngagementDaysCount));
        updateEngagementInteractionMap(enganmentDataList);
        for (EngagementInteraction rec : enganmentDataList) {
            if(rec.StartDateTime>dateToCheck){
                DH_DexOutServiceEngagementResponse engagementRecord =new DH_DexOutServiceEngagementResponse();
                if(rec.CommunicationChannel == DH_GlobalConstants.EMAIL_CHANNEL){
                    engagementRecord.uniqueID = rec.Id;
                    engagementRecord.subject = rec.DH_Content_Body__c;
                    engagementRecord.iconVariant = 'custom:custom105';
                    engagementRecord.timeStamp = rec.StartDateTime;
                    engagementRecord.displayTime = rec.StartDateTime.format('hh:mm a');
                    engagementRecord.displayDate = rec.StartDateTime.format('MM-dd-yyyy');
                    engagementList.add(engagementRecord);
                }else if(rec.CommunicationChannel == DH_GlobalConstants.SMS_CHANNEL){
                    engagementRecord.uniqueID = rec.Id;
                    engagementRecord.subject = rec.DH_Content_Body__c;
                    if(rec.Type == 'Outbound'){
                        engagementRecord.iconVariant = 'standard:sms';
                    }else{
                        engagementRecord.iconVariant = 'standard:reply_text';
                    }
                    engagementRecord.responseList = mapOfResponse.get(String.valueOf(rec.DH_MessageTrackingId__c));
                    
                    if(engagementRecord.responseList!=null && engagementRecord.responseList.size()>0){
                        engagementRecord.responseList.sort();
                        engagementRecord.displayResponseList = true;
                    }else{
                        engagementRecord.displayResponseList = false;
                    }
                    engagementRecord.timeStamp = rec.StartDateTime;
                    engagementRecord.displayTime = rec.StartDateTime.format('hh:mm a');
                    engagementRecord.displayDate = rec.StartDateTime.format('MM-dd-yyyy');
                    engagementList.add(engagementRecord);
                }else if(rec.CommunicationChannel == DH_GlobalConstants.AUTOCALL_CHANNEL){
                    engagementRecord.uniqueID = rec.Id;
                    engagementRecord.subject = rec.DH_Content_Body__c;
                    engagementRecord.timeStamp = rec.StartDateTime;
                    engagementRecord.iconVariant = 'standard:call_coaching';
                    engagementRecord.displayTime = rec.StartDateTime.format('hh:mm a');
                    engagementRecord.displayDate = rec.StartDateTime.format('MM-dd-yyyy');
                    engagementList.add(engagementRecord);
                }
            }
        }
        return engagementList;
    }
	/**
    * @Jira CC-702
    * @description - This method returns engagement list for Call History based on EngagementInteraction data.
    * @param       - List<VoiceCall>
    * @return      - List<DH_DexOutServiceEngagementResponse>
    **/
    public static List<DH_DexOutServiceEngagementResponse> constructCallHistory(List<VoiceCall> callHistory){
        List<DH_DexOutServiceEngagementResponse> engagementList = new List<DH_DexOutServiceEngagementResponse>();
        DateTime dateToday=DateTime.now();
        DateTime dateToCheck = dateToday.addDays(Integer.valueOf(System.Label.DH_MaxEngagementDaysCount));
        for (VoiceCall vcId : callHistory) {
            if(vcId.CallStartDateTime>dateToCheck && vcId.CallDisposition.equalsignorecase(DH_GlobalConstants.COMPLETED)){
                DH_DexOutServiceEngagementResponse engagementRecord =new DH_DexOutServiceEngagementResponse();
                engagementRecord.uniqueID = String.valueOf(vcId.Id);
                engagementRecord.subject = vcId.F9_Call_skill_name__c;
                engagementRecord.iconVariant = 'standard:call_history';
                engagementRecord.description = vcId.CallType;
                engagementRecord.timeStamp = vcId.CallEndDateTime ;
                engagementRecord.displayTime = vcId.CallEndDateTime.format('hh:mm a');
                engagementRecord.displayDate = vcId.CallEndDateTime.format('MM-dd-yyyy');
                engagementList.add(engagementRecord);
                }
        }
        return engagementList;
	}
    /**
    * @Jira CC-1154
    * @description - This method returns update engagementInteractionMap
    * @param       - List<EngagementInteraction>
    * @return      - void
    **/
    public static void updateEngagementInteractionMap(List<EngagementInteraction> enganmentDataList){
        for(EngagementInteraction rec : enganmentDataList){
            DH_DexEngagementInteraction engagementInteraction = new DH_DexEngagementInteraction();
            if(rec.DH_ResponseToMessageTrackingId__c == null && !mapOfResponse.containsKey(String.valueOF(rec.DH_MessageTrackingId__c))){
                    mapOfResponse.put(String.valueOf(rec.DH_MessageTrackingId__c),new List<DH_DexEngagementInteraction>());
            }
            else{
                if(!mapOfResponse.containsKey(String.valueOF(rec.DH_ResponseToMessageTrackingId__c))){
                    mapOfResponse.put(String.ValueOf(rec.DH_ResponseToMessageTrackingId__c),new List<DH_DexEngagementInteraction>());
                    engagementInteraction.description=rec.DH_Content_Body__c;
                    engagementInteraction.subject = '';
                    engagementInteraction.iconVariant = 'standard:sms';
                    engagementInteraction.timeStamp=rec.StartDateTime;
                    engagementInteraction.uniqueID=rec.id;
                    engagementInteraction.displayDate=rec.StartDateTime.format('MM-dd-yyyy');
                    engagementInteraction.displayTime=rec.StartDateTime.format('hh:mm a');
                    if(rec.DH_ResponseToMessageTrackingId__c != null){
                        mapOfResponse.get(String.valueOf(rec.DH_ResponseToMessageTrackingId__c)).add(engagementInteraction);
                    }
                }
                else{
                    engagementInteraction.description=rec.DH_Content_Body__c;
                    engagementInteraction.subject = '';
                    engagementInteraction.iconVariant = 'standard:sms';
                    engagementInteraction.timeStamp=rec.StartDateTime;
                    engagementInteraction.uniqueID=rec.id;
                    engagementInteraction.displayDate=rec.StartDateTime.format('MM-dd-yyyy');
                    engagementInteraction.displayTime=rec.StartDateTime.format('hh:mm a');
                    if(rec.DH_ResponseToMessageTrackingId__c != null){
                        mapOfResponse.get(String.valueOf(rec.DH_ResponseToMessageTrackingId__c)).add(engagementInteraction);
                    }
                }
            }
        }
    }
}