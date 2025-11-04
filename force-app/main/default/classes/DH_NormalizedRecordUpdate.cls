/*
 
*********************************************************
 
Apex Class         : DH_NormalizedRecordUpdate
 
Created Date       : June , 2024

Updated Date       : 20-June-2024

Code Coverage      : 0%
 
@description       :  Class to create a  wrapper of normalized objects to be added, deleted and updated.
 
@jiraid            : CC-283
 
*********************************************************
 
*/
public class DH_NormalizedRecordUpdate {
/**
    * @param Object, Object, Id , String , List<String> , DH_BatchForNormalization.BatchQueryWrapper Wrapper, DH_BatchForNormalization.normalizedDataWrapper Wrapper
    * @description Returns a Wrapper of existing normalised SObject to be deleted,updated,inserted related to a particular denormalized Object.
    **/
    public static DH_NormalizedRecordUpdate.WrapperOfObjects handleUpdateOfDenormalizedRecords( DH_Call_Center_Data_Sheet__c denormalizedObjectold, DH_Call_Center_Data_Sheet__c denormalizedObjectnew, Id denormalizedObjectId, String recordTypeName, List<String> listOfSimilarFields, DH_BatchForNormalization.BatchQueryWrapper mapWrapper, DH_BatchForNormalization.normalizedDataWrapper normalizedRecordData){
        System.debug('inside update class');
         List<String> listOfOldObject =  	DH_CreateCombinationDenormalizedRecord.compileMultFieldsAndCreateCombination(denormalizedObjectold);
         List<String> listOfNewObject =  	DH_CreateCombinationDenormalizedRecord.compileMultFieldsAndCreateCombination(denormalizedObjectnew);
         List<String> objectsNotToBeDeletedList = new List<String>();
         List<String> objectsToBeAddedList = new List<String>();
       
        //Map<Id, DH_NormalizedRecordUpdate.WrapperOfObjects> recordsToBeUpdatedMap = new Map<Id, DH_NormalizedRecordUpdate.WrapperOfObjects>();
         DH_NormalizedRecordUpdate.WrapperOfObjects recordOperationWrapper = new DH_NormalizedRecordUpdate.WrapperOfObjects();
           
           for (String oldOjectString : listOfOldObject) {
               if (listOfNewObject.contains(oldOjectString)) {
                 objectsNotToBeDeletedList.add(oldOjectString);
               }
             }
          
         System.debug('objects not to be deleted size and list\n'+  ' ' + objectsNotToBeDeletedList.size()+ ' ;' + objectsNotToBeDeletedList );
         for (String newObjectString : listOfNewObject) {
           if (!listOfOldObject.contains(newObjectString)) {
             objectsToBeAddedList.add(newObjectString);
           }
         }
           system.debug('objectsToBeAddedList ' + objectsToBeAddedList.size()+ ' ' + objectsToBeAddedList);
     
         //delete non required records statement
         //DH_ExclusionModalityCallcenterRecrdDelet.deleteUsingObjectsToBeDeletedList( denormalizedObjectId, recordTypeName, objectsToBeDeletedList);
         System.debug('Sending for deletiong records that are not needed');
       //  recordsToBeDeleted=//
          recordOperationWrapper.objectsToBeDeleted=DH_NormalizedRecordDelete.deleteUsingObjectsToBeDeletedList( denormalizedObjectId, recordTypeName, objectsNotToBeDeletedList,mapWrapper,normalizedRecordData);
         List<Id> listOfIdToBedeleted=new List<Id>();
         for(sObject objectToBeDeleted : recordOperationWrapper.objectsToBeDeleted){
           listOfIdToBedeleted.add(objectToBeDeleted.Id);
         }
         system.debug('list delete size '  +listOfIdToBedeleted.size());
         //To Update Previously present records
         //nonrequired objects are deleted previouly now //only list of similr fields should be updated as the combination fields will be added to the toBeAddedList already and will be created separately
     
         //update existing statement
         //functionality here
         List<Sobject> temporaryUpdateObjectList = updateExistingRecords(denormalizedObjectId,recordTypeName,listOfSimilarFields,normalizedRecordData) ;
         List<Sobject> finalListToBeUpdated = new List<Sobject>();
           for(SObject temporaryUpdateObject : temporaryUpdateObjectList){
           if(!listOfIdToBedeleted.contains(temporaryUpdateObject.Id)){
             finalListToBeUpdated.add(temporaryUpdateObject);
           }
         }
           recordOperationWrapper.objectsToBeUpdated=finalListToBeUpdated;
             system.debug('list update size ' + recordOperationWrapper.objectsToBeUpdated.size());
     
          
         
         //add newly reequired records statement
         recordOperationWrapper.objectsToBeCreated= DH_NormalizedRecordsCreation.createListsOfNormalizedRecordsTobeCreated( denormalizedObjectnew, recordTypeName, objectsToBeAddedList, listOfSimilarFields,mapWrapper);
         // recordsToBeUpdatedMap.put(denormalizedObjectId,recordOperationWrapper);
         return recordOperationWrapper;
       }
     
     
     
         /**
         * @param Id , String , List<String> ,DH_BatchForNormalization.normalizedDataWrapper Wrapper
         * @description Returns a list of existing normalised SObject to be updated.
         **/
       public static List<sObject>  updateExistingRecords( Id denormalizedObjectId, String recordTypeName, List<String> listOfSimilarFields,DH_BatchForNormalization.normalizedDataWrapper normalizedRecordData) {
        System.debug('Inside updating similar fields fucntion of compare class' + recordTypeName);
        List<sObject> recordsTobeUpdated = new List<sObject>();
        List<DH_Exclusions__c> listOfPreviousExclusions = new List<DH_Exclusions__c>();
        List<DH_Modality_Priority__c> listOfPreviousModalityPriority = new List<DH_Modality_Priority__c>();
        List<DH_Call_Center_Mapping__c> listOfPreviousCallCenterMapping = new List<DH_Call_Center_Mapping__c>();
        List<DH_Call_Center_Hours__c> listOfPreviousCallCenterHours = new List<DH_Call_Center_Hours__c>();
        for(DH_Exclusions__c exclusion : normalizedRecordData.exclusionList){
          if(exclusion.DH_CallCenterDataSheet__c == denormalizedObjectId){
             listOfPreviousExclusions.add(exclusion);
          }
        }
        for(DH_Modality_Priority__c modalityPriority  : normalizedRecordData.modalityPriorityList){
          if(modalityPriority.DH_CallCenterDataSheet__c == denormalizedObjectId){
             listOfPreviousModalityPriority.add(modalityPriority);
          }
        }
        for(DH_Call_Center_Mapping__c callCenterMapping :normalizedRecordData.callCenterMappingList){
          if(callCenterMapping.DH_CallCenterDataSheet__c == denormalizedObjectId){
             listOfPreviousCallCenterMapping.add(callCenterMapping);
          }
        }
        for(DH_Call_Center_Hours__c callCenterHour : normalizedRecordData.callCenterHourList){
          if(callCenterHour.DH_CallCenterDataSheet__c == denormalizedObjectId){
             listOfPreviousCallCenterHours.add(callCenterHour);
          }
        }
        
           if (recordTypeName == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_NAME) {
          // List<DH_Exclusions__c> listOfPreviousExclusions = new List<DH_Exclusions__c>();
          // listOfPreviousExclusions = [ SELECT DH_Notes__c FROM DH_Exclusions__c WHERE DH_CallCenterDataSheet__c = :denormalizedObjectId ];
           for (DH_Exclusions__c exclusion : listOfPreviousExclusions) {
             exclusion.DH_Notes__c = listOfSimilarFields[0];
               List<String> oldUniqueKeyValueList = exclusion.DH_UniqueKey__c.split('#-#');
               exclusion.DH_UniqueKey__c = oldUniqueKeyValueList[0];
           }
           recordsTobeUpdated.addAll(listOfPreviousExclusions);    
         }
         if (recordTypeName == DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_NAME) {
           //List<DH_Modality_Priority__c> listOfPreviousModalityPriority = new List<DH_Modality_Priority__c>();
           //listOfPreviousModalityPriority = [SELECT DH_Description__c, DH_Portal_Procedure_Group_Modality_Code__c, DH_Relative_Priority__c, DH_Notes__c FROM DH_Modality_Priority__c WHERE DH_CallCenterDataSheet__c = :denormalizedObjectId ];
           for (DH_Modality_Priority__c modalityPriority : listOfPreviousModalityPriority) {
             modalityPriority.DH_Description__c = listOfSimilarFields[0];
             modalityPriority.DH_Portal_Procedure_Group_Modality_Code__c = listOfSimilarFields[1];
             if(listOfSimilarFields[2]!=null){
               modalityPriority.DH_Relative_Priority__c = integer.valueof(listOfSimilarFields[2]);
             }
             modalityPriority.DH_Notes__c = listOfSimilarFields[3];
             List<String> oldUniqueKeyValueList = modalityPriority.DH_UniqueKey__c.split('#-#');
             modalityPriority.DH_UniqueKey__c = oldUniqueKeyValueList[0] +'#-#'+listOfSimilarFields[1] + listOfSimilarFields[2];
           }
           

           recordsTobeUpdated.addAll(listOfPreviousModalityPriority);
           //      if(listOfPreviousExclusions.size()>8000) {
              //   DH_ExclusionModalityCallcentrRecrdCreatn.processRecordList(listOfPreviousModalityPriority,'update');
             //    } else{
                     //database.update(listOfPreviousModalityPriority,true);
             //    }
         }
         if (recordTypeName == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_NAME) {
             
           //List<DH_Call_Center_Mapping__c> listOfPreviousCallCenterMapping = new List<DH_Call_Center_Mapping__c>();
           //listOfPreviousCallCenterMapping = [SELECT DH_Fake_call_center_site_code_Lookup__c, DH_Phone_Number_1__c, DH_Phone_Number_2__c, DH_Phone_Number_3__c, DH_Phone_Number_4__c, DH_Phone_Number_5__c, DH_URL1_to_give_RADAR__c, DH_URL2_to_give_RADAR__c, DH_URL3_to_give_RADAR__c, DH_URL4_to_give_RADAR__c, DH_URL5_to_give_RADAR__c, DH_Notes__c, DH_Site_Code_or_Call_Center_Code__c FROM DH_Call_Center_Mapping__c WHERE DH_CallCenterDataSheet__c = :denormalizedObjectId ];
           for (DH_Call_Center_Mapping__c callCenterMapping : listOfPreviousCallCenterMapping) {
             callCenterMapping.DH_Phone_Number_1__c = listOfSimilarFields[0];
             callCenterMapping.DH_Phone_Number_2__c = listOfSimilarFields[1];
             callCenterMapping.DH_Phone_Number_3__c = listOfSimilarFields[2];
             callCenterMapping.DH_Phone_Number_4__c = listOfSimilarFields[3];
             callCenterMapping.DH_Phone_Number_5__c = listOfSimilarFields[4];
             callCenterMapping.DH_URL1_to_give_RADAR__c = listOfSimilarFields[5];
             callCenterMapping.DH_URL2_to_give_RADAR__c = listOfSimilarFields[6];
             callCenterMapping.DH_URL3_to_give_RADAR__c = listOfSimilarFields[7];
             callCenterMapping.DH_URL4_to_give_RADAR__c = listOfSimilarFields[8];
             callCenterMapping.DH_URL5_to_give_RADAR__c = listOfSimilarFields[9];
             callCenterMapping.DH_Notes__c = listOfSimilarFields[10];
             callCenterMapping.DH_Site_Code_or_Call_Center_Code__c = listOfSimilarFields[11];
             List<String> oldUniqueKeyValueList = callCenterMapping.DH_UniqueKey__c.split('#-#');
             callCenterMapping.DH_UniqueKey__c = oldUniqueKeyValueList[0] +'#-#'+listOfSimilarFields[0] +listOfSimilarFields[1]+listOfSimilarFields[2]+listOfSimilarFields[3]+listOfSimilarFields[4]+listOfSimilarFields[5]+listOfSimilarFields[6]+listOfSimilarFields[7]+listOfSimilarFields[8]+listOfSimilarFields[9]+listOfSimilarFields[11];
           }
           recordsTobeUpdated.addAll(listOfPreviousCallCenterMapping);
         }
         if (recordTypeName == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_NAME) {
           //List<DH_Call_Center_Hours__c> listOfPreviousCallCenterHours = new List<DH_Call_Center_Hours__c>();
           //listOfPreviousCallCenterHours = [SELECT DH_Latest_Time_for_RADAR_Outreach__c, DH_Earliest_Time_for_RADAR_Outreach__c, DH_Notes2__c FROM DH_Call_Center_Hours__c WHERE DH_CallCenterDataSheet__c = :denormalizedObjectId ];
     
           for (DH_Call_Center_Hours__c callCenterHour : listOfPreviousCallCenterHours) {
             callCenterHour.DH_Latest_Time_for_RADAR_Outreach__c = (listOfSimilarFields[0] != null)?stringToTime(listOfSimilarFields[0]):null;
             callCenterHour.DH_Earliest_Time_for_RADAR_Outreach__c=(listOfSimilarFields[1] != null)?stringToTime(listOfSimilarFields[1]):null;
             callCenterHour.DH_Notes2__c = listOfSimilarFields[2];
             callCenterHour.DH_timezone__c=(listOfSimilarFields[3]!=null)?listOfSimilarFields[3]:null;
               List<String> oldUniqueKeyValueList = callCenterHour.DH_UniqueKey__c.split('#-#');
             callCenterHour.DH_UniqueKey__c = oldUniqueKeyValueList[0] +'#-#'+listOfSimilarFields[0]+listOfSimilarFields[1]+listOfSimilarFields[3];
           }
           recordsTobeUpdated.addAll(listOfPreviousCallCenterHours);
          // if(listOfPreviousExclusions.size()>8000) {
                      //   DH_ExclusionModalityCallcentrRecrdCreatn.processRecordList(listOfPreviousCallCenterHours,'update');
                      // } else{
                    // database.update(listOfPreviousCallCenterHours,true);
            //     }
            
         }
         return recordsTobeUpdated;
       }
     
     
         /** 
         * @param String
         * @description Converts string to time.
         **/
       public static Time stringToTime(String timeString) {
         List<String> timeParts = timeString.split(':');
         Integer hours = Integer.valueOf(timeParts[0]);
         Integer minutes = Integer.valueOf(timeParts[1]);
         Integer seconds = Integer.valueOf(timeParts[2]);
         return Time.newInstance(hours, minutes, seconds, 0);
       }
         
           /** 
         * @param 
         * @description Wrapper class which contains a lists of the objects to be deleted, inserted , updated 
         **/
         
         public class WrapperOfObjects {
            public List<sObject>  objectsToBeCreated{get;set;}
            public List<sObject>  objectsToBeDeleted {get;set;}
            public List<sObject>  objectsToBeUpdated {get;set;}
            //public List<String>  listOfSimilarFieldRelatedToObjects{get;set;}
             
            
         }  

}