public with sharing class lwcMealsCls {
    @AuraEnabled
    public static List<AccountContactRelation> getContacts(String recordId) {
        return [
            SELECT  Id,
                    AccountId,
                    Account.Name,
                    Account.RecordType.DeveloperName,
                    ContactId,
                    Contact.RecordType.DeveloperName,
                    Contact.Remaining_Budget__c,
                    Contact.Allocated_Budget__c,
                    Contact.Budget__c,
                    Contact.Budget_Spent__c,
                    Contact.Name
            FROM    AccountContactRelation
            WHERE   AccountId =: recordId
            AND     Contact.RecordType.DeveloperName = 'Physicians'
        ];
    }

    @AuraEnabled
    public static List<Map<String, String>> getPicklistValues() {
        //List<String> picklistvalues = new List<String>{'MRI','CT','US','DEXA','XR','PET','Mammo','FL','NM','Connect'};     
        List<Map<String, String>> values = new  List<Map<String, String>>();
        
        Schema.DescribeSObjectResult objSchema = Task.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();    
        List<Schema.Picklistentry>fld =fieldmap.get('Objective__c').getDescribe().getpicklistValues();    
        
        List<String> pickList = new List<String>();
        
        for(Schema.Picklistentry pl : fld) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label',  string.valueof(pl.getLabel()));
            valueMap.put('value',  pl.getValue());
            values.add(valueMap);
        }
        return values;
    }

    @AuraEnabled
    public static Task saveTask(Task recordId,List<String> whoIdsList, Boolean estimated){
    try {
        insert recordId;
        if (recordId.Id != null) {
            TaskRelation[] relations = new TaskRelation[whoIdsList.size()];
			for ( Integer i = 0; i < whoIdsList.size(); i++) {
				relations[i] = new TaskRelation();
				relations[i].TaskId = recordId.Id;
				relations[i].RelationId = whoIdsList[i];
			}
            insert relations;
        }
        
        Task createdtask = [SELECT Id, Cost__c, Allocated_Cost__c, Estimated_Cost__c FROM Task WHERE Id = :recordId.Id];
        Decimal relatedCost = createdtask.Cost__c / whoIdsList.size();
        createdtask.Allocated_Cost__c = (estimated) ? relatedCost : 0;
        createdtask.Estimated_Cost__c = (estimated) ? 0 : relatedCost;
        update createdtask;
        return recordId;
    } catch (Exception exp) {        
        system.debug('System.AuraHandledException: Script-thrown exception' +exp.getMessage() );
        throw new AuraHandledException(exp.getMessage());
    }
    }

    @AuraEnabled
    public static List<Contact> updateBudgetContacts(List<Contact> contactsToUpdate){
        if (!contactsToUpdate.isEmpty()) {
            try {
                update contactsToUpdate;
                return contactsToUpdate;
            } catch (Exception exp) {
                throw new AuraHandledException(exp.getMessage());
            }
        }
        return contactsToUpdate;
    }
/*
    @AuraEnabled
    public static string getMealsContactsSnowflackAPX(String taskId){
        string respBody = '';
        if (taskId != null ) {
            HttpRequest req = new HttpRequest();                
            req.setEndpoint('callout:EXPONSE_REPORT'+'/new_meal?taskid=' + taskId);
            //req.setEndpoint('https://sb3.kaupter.com/expense_management/new_meal?taskid=00TUw000005LnKeMAK');                
            req.setMethod('GET');      
            system.debug('req ' + req);     
            Http http = new Http();
            HttpResponse res = http.send(req);
             system.debug('res---'+res.getStatus());
            system.debug('res---'+res.getStatusCode());
            system.debug('res---'+res.getBody());
            if(res.getStatusCode() == 200){                   
                respBody = res.getBody();
            }
            }
        return respBody;
    }*/
}