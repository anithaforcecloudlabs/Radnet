/*
 
*********************************************************
 
Apex Class         : DH_ExclusionDenormalizeJsonConverter
 
Created Date       : June , 2024

Updated Date       : 20-June-2024

Code Coverage      : 0%
 
@description       :  Creates JSON Strng from object, Return object from JSON string.
 
@jiraid            : CC-283
 
*********************************************************
 
*/
public with sharing class DH_ExclusionDenormalizeJsonConverter {

      /**
    * @param Id
    * @description Converts call center data sheet object to JSON string.
    **/
    public static String callCenterDataSheetObjectToJSON(Id recordId) {
        // Get the fields and values of the object
        Map<String, Object> fieldsAndValues = new Map<String, Object>();
        SObject obj = Database.query('SELECT ' + getFields('DH_Call_Center_Data_Sheet__c') + ' FROM ' + 'DH_Call_Center_Data_Sheet__c' + ' WHERE Id  = :recordId' + ' WITH SECURITY_ENFORCED');
        for(Schema.SObjectField fieldName : obj.getSObjectType().getDescribe().fields.getMap().values()) {
            if (obj.get(fieldName) != null && String.valueOf(fieldName)!='DH_Previous_Value__c') {
                fieldsAndValues.put(String.valueOf(fieldName), obj.get(fieldName));
            }
        }
        // Convert the map to JSON format
        String scc= JSON.serializePretty(fieldsAndValues);
        return scc;
    }


  /**
    * @param Set<Id>
    * @description Updates call center data sheet objects previous value field.
    **/
    public static void updatePreviousValueCallCenterDataSheet(Set<Id> objectId){
        
        List<DH_Call_Center_Data_Sheet__c> updateccds = new List<DH_Call_Center_Data_Sheet__c> ();
        For(DH_Call_Center_Data_Sheet__c ccds: [SELECT Id, DH_Previous_Value__c FROM DH_Call_Center_Data_Sheet__c WHERE Id In :objectId  WITH SECURITY_ENFORCED]){
            ccds.DH_Previous_Value__c = String.valueof(callCenterDataSheetObjectToJSON(ccds.Id));
            updateccds.add(ccds);
        }
        if(updateccds!=null){
            update updateccds;
        }
    }


  /**
    * @param String
    * @description Helper method to get all fields of an object.
    **/
     private static String getFields(String objectAPIName) {
        String fields = '';
        for (SObjectField field : Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().values()) {
            fields += field.getDescribe().getName() + ', ';
        }
        return fields.removeEnd(', ');
    }

  /**
    * @param String
    * @description Returns Object using JSON String.
    **/
    public static DH_Call_Center_Data_Sheet__c getBackObjectFromJsonString(String jsonString){
        DH_Call_Center_Data_Sheet__c previousCallCenterDataSheetObject = new DH_Call_Center_Data_Sheet__c();
        try{
            previousCallCenterDataSheetObject = (DH_Call_Center_Data_Sheet__c)JSON.deserialize(jsonString, DH_Call_Center_Data_Sheet__c.class);
        }
        catch(Exception ex)
        {
            System.debug(' @@@@@ Cant convert to Call center data sheet object Don\'t visible '+ex.getMessage());
        }
        return previousCallCenterDataSheetObject;
    }
}