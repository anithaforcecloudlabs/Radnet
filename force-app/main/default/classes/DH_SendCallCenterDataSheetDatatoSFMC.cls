/*
* ***************************************************************************************************************************
* Apex Class Name - DH_SendCallCenterDataSheetDatatoSFMC
* Version - 0.1
* Created Date - 20-Jun-2024
* Function - Make Callout to the SFMC to send the normalized records.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Raj Ranjan               20-Jun-2024          Intial version.
* *****************************************************************************************************************************
*/
public without sharing class DH_SendCallCenterDataSheetDatatoSFMC {
    /**
    * @author Raj Ranjan | 20-Jun-2024 
    * @param List<SObject>,List<SObject>,Boolean
    * @description method which will make a callout to get the auth token form SFMC.
    **/
    public static String sendDataToSFMC(List<SObject> listOfObject,List<SObject> recordstoDelete,String objectName){
	  String result='';
         try{
         if(listOfObject!=null || recordstoDelete!=null){
             System.debug('token call out');
             Http h = new Http();
             HttpRequest req = new HttpRequest();
             req.setEndpoint(System.label.DH_SFMCtokentoSendNormalized);
             req.setMethod('POST');
             req.setHeader('Content-Type', 'application/json');
             req.setBody(DH_JSONGeneratorNormalized.generateTokenbody());
             HttpResponse res = h.send(req);
             if(res.getStatusCode()!=200){
                 System.debug('error sending payload token'+res.getStatusCode());
                 result = 'Error :'+String.valueOf(res.getBody());
              }
             else{
                 result = 'Success';
             }
             System.debug('token success '+res.getStatusCode());
             Map<String,Object> mapstr= (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
             String authtoken=mapstr.get('access_token').toString();
             result = sendNormalizeData(listOfObject,recordstoDelete,authtoken,objectName);
        }
        }catch(Exception ex){ 
             return result;
        }
        System.debug('result==>'+result);
        return result;
    }
    
    /**
    * @author Raj Ranjan | 20-Jun-2024 
    * @param List<SObject>,List<SObject>,Boolean
    * @description method which will make a callout with the all the inserted or deleted record list in the body.
    **/
    public static String sendNormalizeData(List<SObject> listOfRecords,List<SObject> recordstoDelete,String token,String objectname){
        try{
        System.debug('sendNormalizeData inside the function');
        List<SObject> objectList = new List<SObject>();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        if(objectname==System.label.DH_ExclusionAPIname){
            req.setEndpoint(System.label.DH_MarketingAPIendpointExclusion);
            if(listOfRecords!=null){
            Set<Id> idlist = (new Map<Id,SObject>(listOfRecords)).keySet();
            objectList=Database.query(System.label.DH_ExclusionsQuery + ' WHERE id in :idlist');
            }
        }
        else if(objectname==System.label.DH_CallCenterMappingAPIname){
            req.setEndpoint(System.label.DH_MarketingAPIendpointCallCenterMapping);   
            if(listOfRecords!=null){
            Set<Id> idlist = (new Map<Id,SObject>(listOfRecords)).keySet();
            objectList=Database.query(System.label.DH_CallCenterMappingQuery + ' WHERE id in :idlist');
            }
        }
        else if(objectname==System.label.DH_CallCenterHoursAPIname){
            req.setEndpoint(System.label.DH_MarketingAPIendpointCallCenterHours);
            if(listOfRecords!=null){
            Set<Id> idlist = (new Map<Id,SObject>(listOfRecords)).keySet();
            objectList=Database.query(System.label.DH_CallCenterHoursQuery + ' WHERE id in :idlist');
            }
        }
        else if(objectname==System.label.DH_ModalityPriorityAPIname){
            req.setEndpoint(System.label.DH_MarketingAPIendpointModalityPriority);
            if(listOfRecords!=null){
            Set<Id> idlist = (new Map<Id,SObject>(listOfRecords)).keySet();
            objectList=Database.query(System.label.DH_ModalityPriorityQuery + ' WHERE id in :idlist');
            }
        }
        else if(objectname=='Account'){
            req.setEndpoint(System.label.DH_OptInSFMCEndPoint);
        }
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization','Bearer '+token);
        req.setTimeout(120000);
        if(objectname=='Account'){
             req.setBody(DH_JSONGeneratorNormalized.generateJSONforOptIn(listOfRecords));
        }
        else{
             req.setBody(DH_JSONGeneratorNormalized.generateJSONforObject(objectList,recordstoDelete,objectname));
        }
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200){
            system.debug('getting status code as success 200==>'+res.getStatusCode());
            if(listOfRecords!=null)
            updateTimeStamp(listOfRecords,objectname);  
            return 'Success';
        }
        else{
            system.debug('getting status code as fail==>'+res.getStatusCode());
            system.debug('error');
            system.debug('this is the error body '+res.getBody());
            //update the published status on parent
            return 'Error :'+String.valueOf(res.getBody());
        }
        }
        catch(Exception e){
            System.debug('Exception ======= '+e);
            system.debug(e.getMessage());
            return 'Error :'+String.valueOf(e.getMessage());            
        }
    }
   /**** 
    * @author Raj Ranjan | 24-Jun-2024 
    * @param List<Id>
    * @description method will be used to do a callout for the order data based on the RIS data received
    ****/
    @future(callout=true)
    public static void  sendOptInData(List<Id> listofIds){
        System.debug('list of ids'+listofIds);
        List<Account> recordList = [SELECT id,(SELECT TelephoneNumber FROM ContactPointPhones) FROM Account WHERE id in :listofIds  WITH SECURITY_ENFORCED];
        System.debug('recorddlist after query '+recordList);
        sendDataToSFMC(recordList,null,'Account');
   }
    
    public static void updateTimeStamp(List<SObject> listOfRecords,String objectname){
        try{
            List<DH_Call_Center_Data_Sheet__c> callcenterdatasheetrecords = fetchDenormalizeRecords(listOfRecords,objectname);
            for(DH_Call_Center_Data_Sheet__c callcenterdatasheet:callcenterdatasheetrecords){
                callcenterdatasheet.DH_Last_Sync_Timestamp__c=System.now();
                callcenterdatasheet.Published__c  = true;
                callcenterdatasheet.DH_Error_Log__c ='';
                callcenterdatasheet.DH_isError__c = false;
                System.debug('publish is set to true');
             }
            if (Schema.sObjectType.DH_Call_Center_Data_Sheet__c.isUpdateable()) {
                update callcenterdatasheetrecords;
            }
        }
        catch(Exception e){
             System.debug('error'+e);
        }
    }
    /*
    public static void updatePublishOnFail(List<SObject> listOfRecords,String objectname){
            List<DH_Call_Center_Data_Sheet__c> callcenterdatasheetrecords = fetchDenormalizeRecords(listOfRecords,objectname);
            for(DH_Call_Center_Data_Sheet__c callcenterdatasheet:callcenterdatasheetrecords){
                callcenterdatasheet.Published__c  = false;
             }
            update callcenterdatasheetrecords;
        
    }
*/
    public static List<DH_Call_Center_Data_Sheet__c> fetchDenormalizeRecords(List<SObject> listOfRecords,String objectname){
        Set<id> callcenterdatasheetids = new Set<id>();
            if(objectname==System.label.DH_ExclusionAPIname){
                List<DH_Exclusions__c> exclusionlist=listOfRecords;
                for(DH_Exclusions__c exclusion:exclusionlist){
                    callcenterdatasheetids.add(exclusion.DH_CallCenterDataSheet__c);
                }
            }
            else if(objectname==System.label.DH_CallCenterHoursAPIname){
                List<DH_Call_Center_Hours__c> callcenterhourslist=listOfRecords;
                for(DH_Call_Center_Hours__c callcenterhours:callcenterhourslist){
                    callcenterdatasheetids.add(callcenterhours.DH_CallCenterDataSheet__c);
                }
            }
            else if(objectname==System.label.DH_CallCenterMappingAPIname){
                List<DH_Call_Center_Mapping__c> callcentermappinglist=listOfRecords;
                for(DH_Call_Center_Mapping__c callcentermapping:callcentermappinglist){
                    callcenterdatasheetids.add(callcentermapping.DH_CallCenterDataSheet__c);
                }
            }
            else if(objectname==System.label.DH_ModalityPriorityAPIname){
                List<DH_Modality_Priority__c> modalityprioritylist=listOfRecords;
                for(DH_Modality_Priority__c modalitypriority:modalityprioritylist){
                    callcenterdatasheetids.add(modalitypriority.DH_CallCenterDataSheet__c);
                }
            }
            return  [SELECT Id,DH_Last_Sync_Timestamp__c,Published__c  from DH_Call_Center_Data_Sheet__c WHERE Id in :callcenterdatasheetids WITH SECURITY_ENFORCED];
    }
}