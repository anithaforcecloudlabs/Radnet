/*
* ***************************************************************************************************************************
* Apex Class Name - DH_SendCallCenterDataSheetDatatoSFMC
* Version - 0.1
* Created Date - 20-Jun-2024
* Function - Generate the JSON body for callout.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Raj Ranjan               20-Jun-2024          Intial version.
* *****************************************************************************************************************************
*/
public without sharing class DH_JSONGeneratorNormalized {
    /**
    * @author Raj Ranjan | 20-Jun-2024 
    * @param List<SObject>,List<SObject>,String
    * @description method which will generate the JSON for all the normalized records.
    **/
    public Static String generateJSONforObject(List<SObject> listOfRecords,List<SObject> recordsToDelete,String objectname){       
        List<Map<String,Object>> finalRecordsToSend = new List<Map<String,Object>>(); 
        if(listOfRecords!=null){
        finalRecordsToSend.addAll(createJSON(listOfRecords,false));
        }
        if(recordsToDelete!=null){
        finalRecordsToSend.addAll(createJSON(recordsToDelete,true));
        }
        //System.debug(JSON.serializePretty(finalRecordsToSend));
        return JSON.serializePretty(finalRecordsToSend);
    }
    
    public Static List<Map<String,Object>> createJSON(List<SObject> listOfRecords,Boolean deletedRecord){
         List<Map<String,Object>> recordMap = new List<Map<String,Object>>();
         for(SObject obj : listOfRecords){
            Map<String,Object> finalmap = new Map<String,Object>();
            Map<String,Object> key = new Map<String,Object>();
            Map<String, Object> fieldsAndValues = new Map<String, Object>();
        
        if(deletedRecord){
             fieldsAndValues.put('isDeleted','true');
        }
        else{
            for(Schema.SObjectField fieldName : obj.getSObjectType().getDescribe().fields.getMap().values()) {   
            //System.debug('field name '+String.valueOf(fieldName)+' value :'+obj.get(fieldName));
            if (obj.get(fieldName) != null) {
                if(String.valueOf(fieldName)!='Id' && String.valueOf(fieldName)!='IsDeleted' && String.valueOf(fieldName)!='Name'){
                    fieldsAndValues.put(String.valueOf(fieldName), obj.get(fieldName));
                }
            }   
        }
        fieldsAndValues.put('Name',obj.id);
        fieldsAndValues.put('isDeleted','false');
            
        }    
        Key.put('Id',obj.id);
        finalmap.put('Values',fieldsAndValues);
        finalmap.put('Keys',Key);
        recordMap.add(finalmap);
       }
        return recordMap;
    }
    /**
    * @author Raj Ranjan | 20-Jun-2024 
    * @description method will create JSON body for token callout.
    **/
    public Static String generateTokenbody(){
        Map<String,Object> requestBody= new Map<String,Object>();
         requestBody.put('account_id',DH_APIAuthDetails__c.getValues('DH_SFMCAuthTokenBody').DH_Account_ID__c);
         requestBody.put('client_secret',DH_APIAuthDetails__c.getValues('DH_SFMCAuthTokenBody').DH_Client_Secret__c);
         requestBody.put('client_id',DH_APIAuthDetails__c.getValues('DH_SFMCAuthTokenBody').DH_Client_ID__c);
         requestBody.put('grant_type',DH_APIAuthDetails__c.getValues('DH_SFMCAuthTokenBody').DH_Grant_Type__c);
        return JSON.serializePretty(requestBody);
    }
    /**
    * @author Raj Ranjan | 21-Jun-2024 
    * @param List<Account>
    * @description method will create JSON body for token callout.
    **/
    Public static String generateJSONforOptIn(List<Account> patientList){
        List<String> mobileNumbers = new List<String>();
        System.debug('inside the json generator');
        //fetch all the mobile numbers from the patient
        List<ContactPointPhone> contactPointPhones = new List<ContactPointPhone>();
        for(Account ac:patientList){
            contactPointPhones.addAll(ac.ContactPointPhones);       
        }
        System.debug('contact point phones '+contactPointPhones);
        for(ContactPointPhone ccp:contactPointPhones){
            String cphone = ccp.TelephoneNumber;
            String phoneString = '1'+cphone.replaceAll('\\D','');
            mobileNumbers.add(phoneString);
        }
        Map<String,Object> mapToSend = new Map<String,Object>();
        mapToSend.put('shortCode',System.label.DH_ShortCodeSFMC);
        mapToSend.put('messageText',System.label.DH_messageTextSFMC);
        mapToSend.put('mobileNumbers',mobileNumbers);
        System.debug(JSON.serializePretty(mapToSend));
        return JSON.serializePretty(mapToSend);
    }
}