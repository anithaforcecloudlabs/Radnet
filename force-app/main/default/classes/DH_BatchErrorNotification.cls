/*
* ***************************************************************************************************************************
* Apex Class Name : DH_BatchErrorNotification
* Created Date : 14-August-2024 
* @description : Batch Class for sending error notification to SF admin adn RIS admin
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-520                 14-August-2024       Original Version
* ************************************************************************************************************************************
*/
global  class DH_BatchErrorNotification implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        DH_BatchSettings__mdt batchErrorNotification = DH_CustomMetadataDao.getBatchDetailsList('DH_BatchErrorNotification');
        DateTime pastOneHour = System.Now().addHours(Integer.valueOf(batchErrorNotification.DH_WhereCondition2__c));
        String query = 'SELECT Id , DH_ServiceName__c, DH_ResponseCode__c  FROM DH_PayloadData__c Where '+ batchErrorNotification.DH_WhereCondition1__c +  ' AND CreatedDate >: pastOneHour';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<DH_PayloadData__c> scope){
        Set<String> errorRecordsEmailEnabled = DH_CustomMetadataDao.getErrorCodeServiceNameSet();
        Set<String> errorCodeServiceNameSet = new Set<String>();
        DH_ErrorCodeMapping__mdt errorMapping =new DH_ErrorCodeMapping__mdt();
        try{
            for(DH_PayloadData__c payLoad : scope){
                if(payLoad != null){
                    String errorCodeServiceName = payLoad.DH_ResponseCode__c +'|'+ payLoad.DH_ServiceName__c;
                    if(!errorCodeServiceNameSet.contains(errorCodeServiceName) && errorRecordsEmailEnabled.contains(errorCodeServiceName)){
                        errorCodeServiceNameSet.add(errorCodeServiceName);
                        errorMapping = DH_CustomMetadataDao.getErrorCodeMappingList(payLoad.DH_ServiceName__c,Integer.valueOf(payLoad.DH_ResponseCode__c));
                    }
                }
            }
        } catch(Exception e){
            system.debug(LoggingLevel.DEBUG,+e.getMessage());
        }
        
        Map<String, List<String>> emailVscodeMessage;
        if(errorCodeServiceNameSet != null){
            emailVscodeMessage = DH_CustomMetadataDao.adminEmailVsErrorCodeMessage(errorCodeServiceNameSet);
        }
        
        Set<String> emailTemplateSet = new Set<String>{errorMapping.DH_EmailTemplate__c};
        Map<String,EmailTemplate> et = DH_ContactCenterCachingUtility.getEmailTemplateMap(emailTemplateSet);
        for(String key : emailVscodeMessage.keySet()){ 
        
            String emailBody = et.get(errorMapping.DH_EmailTemplate__c).Body.substringBefore('<body>') + '\n';
            List<String> errorBody = emailVscodeMessage.get(key);
            
            for(String str : errorBody){
                List<String> splitStr = str.split('\\|');
                emailBody += splitStr[0] + ' : ' +splitStr[1] + '\n';
            }
            emailBody +=  et.get(errorMapping.DH_EmailTemplate__c).Body.substringAfter('<body>');

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new List<String>{key};
		    email.setToAddresses(toAddresses);
            email.setTemplateId(et.get(errorMapping.DH_EmailTemplate__c).Id);
            email.setSenderDisplayName(errorMapping.DH_EmailDisplayName__c);
            email.setPlainTextBody(emailBody);
            email.setBccSender(false);
            email.setSubject(et.get(errorMapping.DH_EmailTemplate__c).Subject);

            try {
                if (toAddresses != null) {
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
                    system.debug(LoggingLevel.DEBUG,'Mail Sent!');
                }
            } catch (Exception e) {
                system.debug(LoggingLevel.DEBUG,+e.getMessage());
            }
		}
    }
    global void finish(Database.BatchableContext bc){
    }
}