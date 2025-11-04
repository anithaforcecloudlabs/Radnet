/*
* ***************************************************************************************************************************
* Apex Class Name : DH_BatchRisEngagement
* Created Date : 30-August-2024 
* @description : Batch Class for syncing Patient Engagement data from HC to RIS.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-491                   30-August-2024       Original Version
* CC-1557                  06-May-2025          Updated the execute method 
* ************************************************************************************************************************************
*/
global class DH_BatchRisEngagement implements Database.Batchable<SObject>,Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        try {
            DH_BatchSettings__mdt batchRisEngagement = DH_CustomMetadataDao.getBatchDetailsList('DH_BatchRisEngagement');
            query = 'SELECT Id,Reason,StartDateTime,DH_ClinicalServiceRequest__r.DH_Order_Key__c,DH_JobId__c,DH_BatchId__c,DH_EmailId__c,ExternalIdentifier,CommunicationChannel,DH_JourneyName__c, DH_JourneyTouchPoint__c,Status,DH_Account__r.Region__c, DH_Account__r.DH_Patient_Key__c,DH_Content_Body__c,PhoneNumber FROM EngagementInteraction WHERE '
                + batchRisEngagement.DH_WhereCondition1__c;
        } catch (Exception ex) {
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.exp =  ex;
            logWrapper.serviceName = 'DH_BatchRisEngagement';
            logWrapper.className = 'DH_BatchRisEngagement-start';
            logWrapper.responseCode =  '400';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<EngagementInteraction> scope) {
        Boolean sandboxEnv = true;
        sandboxEnv = [SELECT Id, isSandbox from Organization].isSandbox;

        Map<String,EngagementInteraction> uniqueKeyVsEiMap = new Map<String,EngagementInteraction>();
        Set<String> batchIdSet = new Set<String>();
		Set<String> emailIdSet = new Set<String>();
		Set<String> jobIdSet = new Set<String>();
		Set<String> subscriberIdSet = new Set<String>();
        Map<String, List<List<EngagementInteraction>>> regionPatKeyVsEmailSmsMap = new  Map<String, List<List<EngagementInteraction>>>();
        try {
            if(scope != null && scope.size()>0){
                for(EngagementInteraction erRec : scope){
                    if(erRec.DH_Account__r.Region__c == null || erRec.DH_Account__r.DH_Patient_Key__c == null || erRec.DH_ClinicalServiceRequest__r.DH_Order_Key__c == null){
                        continue;
                    }
                    /**if(erRec.DH_Account__r.Region__c != null && sandboxEnv && !erRec.DH_Account__r.Region__c.contains('_Training')){
                		System.debug('inside 1');
                		erRec.DH_Account__r.Region__c = erRec.DH_Account__r.Region__c+System.Label.DH_ContactCenterTestingPhaseSuffix;
            		}else if(erRec.DH_Account__r.Region__c != null && !sandboxEnv && erRec.DH_Account__r.Region__c.contains('_Training')){
                		System.debug('inside 2');
                		erRec.DH_Account__r.Region__c = erRec.DH_Account__r.Region__c.replace(System.Label.DH_ContactCenterTestingPhaseSuffix,'');
            		}**/
                    String region = sandboxEnv ? erRec.DH_Account__r.Region__c + System.Label.DH_ContactCenterTestingPhaseSuffix : erRec.DH_Account__r.Region__c;
                    String key = region + '@%' + erRec.DH_Account__r.DH_Patient_Key__c;
                    if(regionPatKeyVsEmailSmsMap.containsKey(key) && erRec.CommunicationChannel == DH_GlobalConstants.EMAIL_EI){
                        List<List<EngagementInteraction>> emailSmsList = regionPatKeyVsEmailSmsMap.get(key);
                        emailSmsList[0].add(erRec);
                    }else if(regionPatKeyVsEmailSmsMap.containsKey(key) && erRec.CommunicationChannel == DH_GlobalConstants.SMS_EI){
                        List<List<EngagementInteraction>> emailSmsList = regionPatKeyVsEmailSmsMap.get(key);
                        emailSmsList[1].add(erRec);
                    }else if(!regionPatKeyVsEmailSmsMap.containsKey(key) && erRec.CommunicationChannel == DH_GlobalConstants.EMAIL_EI){
                        List<List<EngagementInteraction>> emailSmsList = new List<List<EngagementInteraction>>{new List<EngagementInteraction>(), new List<EngagementInteraction>()};
                        emailSmsList[0].add(erRec);
                        regionPatKeyVsEmailSmsMap.put(key,emailSmsList);
                    }else if(!regionPatKeyVsEmailSmsMap.containsKey(key) && erRec.CommunicationChannel == DH_GlobalConstants.SMS_EI){
                        List<List<EngagementInteraction>> emailSmsList = new List<List<EngagementInteraction>>{new List<EngagementInteraction>(), new List<EngagementInteraction>()};
                        emailSmsList[1].add(erRec);
                        regionPatKeyVsEmailSmsMap.put(key,emailSmsList);
                    }
                    if(erRec.CommunicationChannel == DH_GlobalConstants.EMAIL_EI){
                        String uniqueKey = erRec.DH_BatchId__c + erRec.DH_EmailId__c + erRec.DH_JobId__c + erRec.ExternalIdentifier;
                        if(uniqueKey != null && !uniqueKeyVsEiMap.containsKey(uniqueKey)){
                            uniqueKeyVsEiMap.put(uniqueKey,erRec);
                        }
                    }
                    batchIdSet.add(erRec.DH_BatchId__c);
                    emailIdSet.add(erRec.DH_EmailId__c);
                    jobIdSet.add(erRec.DH_JobId__c);
                    subscriberIdSet.add(erRec.ExternalIdentifier);
                }
            }
            DH_DexOutServiceRisEngagementRequest request = new DH_DexOutServiceRisEngagementRequest();
            request.uniqueKeyVsEiMap = uniqueKeyVsEiMap;
            request.batchIdSet = batchIdSet;
            request.emailIdSet = emailIdSet;
			request.jobIdSet = jobIdSet;
			request.subscriberIdSet = subscriberIdSet;
            request.regionPatKeyVsEmailSmsMap = regionPatKeyVsEmailSmsMap;
            if(request != null){
                DH_DexOutServiceRisEngagement.invokeRisEngagementApi(request);
            }
        } catch (Exception ex) {
            DH_DexLoggingUtility.Logger logWrapper = new DH_DexLoggingUtility.Logger();
            logWrapper.exp =  ex;
            logWrapper.serviceName = 'DH_BatchRisEngagement';
            logWrapper.className = 'DH_BatchRisEngagement-execute';
            logWrapper.responseCode =  '400';
            DH_DexLoggingUtility.createLogRecord(logWrapper);
        }
	}
    global void finish(Database.BatchableContext bc) {
	}
}