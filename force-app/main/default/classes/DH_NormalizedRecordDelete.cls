/*
 
*********************************************************
 
Apex Class         : DH_NormalizedRecordDelete
 
Created Date       : June , 2024

Updated Date       : 20-June-2024

Code Coverage      : 0%
 
@description       :  Class to return a list of the normalized objects to be deleted
 
@jiraid            : CC-283
 
*********************************************************
 
*/
public without sharing class DH_NormalizedRecordDelete {
    /**
  * @param Id , String , List<String>,DH_BatchForNormalization.BatchQueryWrapper Wrapper,DH_BatchForNormalization.normalizedDataWrapper Wrapper
  * @description Returns a list of SObject to be delete related to a particular denormalized record
  **/
  public static List<sObject> deleteUsingObjectsToBeDeletedList(Id denormalizedObjectId, String recordTypeName, List<String> notTobeDeletedList,DH_BatchForNormalization.BatchQueryWrapper mapWrapper,DH_BatchForNormalization.normalizedDataWrapper normalizedRecordData){
      List<DH_Exclusions__c> listOfExistingExclusionObjects = new List<DH_Exclusions__c>();
      List<DH_Modality_Priority__c> listOfExistingModalityPriotityObjects = new List<DH_Modality_Priority__c>();
      List<DH_Call_Center_Mapping__c> listOfExistingCCMappingObjects = new List<DH_Call_Center_Mapping__c>();
      List<DH_Call_Center_Hours__c> listOfExistingCCHoursObjects = new List<DH_Call_Center_Hours__c>();
      List<sObject> objectsToBeDeleted= new List<sObject>();

      Map<Id,String> regionMap=mapWrapper.regionMapDelete;
      Map<Id,String> practiceMap = mapWrapper.practiceMapDelete;
      Map<Id,String> siteMap = mapWrapper.siteMapDelete;
      Map<Id,String> carrierCodePayerAccountMap =mapWrapper.carrierCodePayerAccountMapDelete;
      
      Map<Id, String> modalityCodeCareSpecialtyMap= mapWrapper.modalityCodeCareSpecialtyMapDelete;
      Map<Id,String> callCenterMap = mapWrapper.callCenterMapDelete;
      Map<Id,String> procedureCodeHealthCareProcedureMap=mapWrapper.procedureCodeHealthCareProcedureMapDelete;        
      
      Map<Id,String>  RefPracticeOrGrpCodeNameMap=mapWrapper.RefPracticeOrGrpCodeNameDelete;
      Map<Id,String>  RefDrIdMap=mapWrapper.RefDrIdDelete;



      Map<Id,String> mapTobeComparedWithTobeDeletedList = new Map<Id,String>();
      String stringMadeByExistingObjects='';
      List<Id> idsNotToBeDeleted = new List<Id>();


      for(DH_Exclusions__c exclusion : normalizedRecordData.exclusionList){
          if(exclusion.DH_CallCenterDataSheet__c == denormalizedObjectId){
          listOfExistingExclusionObjects.add(exclusion);
        }
      }
      for(DH_Modality_Priority__c modalityPriority  : normalizedRecordData.modalityPriorityList){
        if(modalityPriority.DH_CallCenterDataSheet__c == denormalizedObjectId){
           listOfExistingModalityPriotityObjects.add(modalityPriority);
        }
      }
      for(DH_Call_Center_Mapping__c callCenterMapping :normalizedRecordData.callCenterMappingList){
        if(callCenterMapping.DH_CallCenterDataSheet__c == denormalizedObjectId){
           listOfExistingCCMappingObjects.add(callCenterMapping);
        }
      }
      for(DH_Call_Center_Hours__c callCenterHour : normalizedRecordData.callCenterHourList){
        if(callCenterHour.DH_CallCenterDataSheet__c == denormalizedObjectId){
           listOfExistingCCHoursObjects.add(callCenterHour);
        }
      }
        for(String ntlist: notTobeDeletedList){
              System.debug('ntlist '+ntlist);
          }


      if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_NAME){
         // List<DH_Exclusions__c> listOfExistingExclusionObjects = [select Id, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_procedure_group_code__c, DH_Procedure_Code__c,  DH_Carrier_Code__c, DH_Referring_Group_Code__c, DH_referring_id__c, DH_Order_Nrf__c,DH_CallCenterDataSheet__r.Name from DH_Exclusions__c where DH_CallCenterDataSheet__c =:denormalizedObjectId ];
          System.debug('listOfExistingExclusionObjects' + listOfExistingExclusionObjects);
          for(DH_Exclusions__c ex : listOfExistingExclusionObjects){
              stringMadeByExistingObjects=(ex.DH_System__c!=null?regionMap.get(ex.DH_System__c):'')+','+(ex.DH_Practice_Code__c!=null?practiceMap.get(ex.DH_Practice_Code__c):'')+','+(ex.DH_Site_Code__c!=null?siteMap.get(ex.DH_Site_Code__c):'')+','+(ex.DH_procedure_group_code__c!=null?modalityCodeCareSpecialtyMap.get(ex.DH_procedure_group_code__c):'')+','+(ex.DH_Procedure_Code__c!=null?procedureCodeHealthCareProcedureMap.get(ex.DH_Procedure_Code__c):'')+','+(ex.DH_Carrier_Code__c!=null?carrierCodePayerAccountMap.get(ex.DH_Carrier_Code__c):'')+','+(ex.DH_Referring_Group_Code__c!=null?RefPracticeOrGrpCodeNameMap.get(ex.DH_Referring_Group_Code__c):'')+','+(ex.DH_referring_id__c!=null?RefDrIdMap.get(ex.DH_referring_id__c):'')+','+(ex.DH_Order_Nrf__c!=null?ex.DH_Order_Nrf__c:'')+','+('end');
              mapTobeComparedWithTobeDeletedList.put(ex.Id,stringMadeByExistingObjects);
          }
          for(Id mapId: mapTobeComparedWithTobeDeletedList.keySet()){
              String tempstring= mapTobeComparedWithTobeDeletedList.get(mapId);
              System.debug('tempstring' + tempstring); 
              if(notTobeDeletedList.contains(tempstring)){
                  idsNotToBeDeleted.add(mapId);
              }
          }

          for(DH_Exclusions__c exclusion : listOfExistingExclusionObjects){
              if(!idsNotToBeDeleted.contains(exclusion.Id)){
                  objectsToBeDeleted.add(exclusion);
              }  
          }
          System.debug('objectsToBeDeleted ' + objectsToBeDeleted.size() + ' ' + objectsToBeDeleted );
      }
      else if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_NAME){
         // List<DH_Modality_Priority__c> listOfExistingModalityPriotityObjects = [select Id, DH_System__c, DH_procedure_group_code__c, DH_CallCenterDataSheet__r.Name from DH_Modality_Priority__c where DH_CallCenterDataSheet__c =:denormalizedObjectId ];
          for(DH_Modality_Priority__c mp : listOfExistingModalityPriotityObjects){
              stringMadeByExistingObjects=(mp.DH_System__c!=null?regionMap.get(mp.DH_System__c):'')+','+(mp.DH_procedure_group_code__c!=null?modalityCodeCareSpecialtyMap.get(mp.DH_procedure_group_code__c):'')+','+('end');
              mapTobeComparedWithTobeDeletedList.put(mp.Id,stringMadeByExistingObjects);
              
          }
          for(Id mapId: mapTobeComparedWithTobeDeletedList.keySet()){
              String tempstring= mapTobeComparedWithTobeDeletedList.get(mapId);

              System.debug('tempstring' + tempstring);
              if(notTobeDeletedList.contains(tempstring)){
                  idsNotToBeDeleted.add(mapId);
              }
          }

          for(DH_Modality_Priority__c modalityPriority : listOfExistingModalityPriotityObjects){
              if(!idsNotToBeDeleted.contains(modalityPriority.Id)){
                  objectsToBeDeleted.add(modalityPriority);
              }  
          }
          System.debug('objectsToBeDeleted ' + objectsToBeDeleted.size() + ' ' + objectsToBeDeleted );

          //List<DH_Modality_Priority__c> objectsToBeDeleted = [SELECT Id From DH_Modality_Priority__c WHERE DH_CallCenterDataSheet__c =:denormalizedObjectId and Id NOT IN: idsNotToBeDeleted];

      }
      else if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_NAME){
     //     List<DH_Call_Center_Mapping__c> listOfExistingCCMappingObjects = [select Id, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_ZIP__c, DH_Modality_Code__c, DH_Procedure_Code__c, DH_Fake_call_center_site_code_Lookup__c,	DH_Referring_Group_Code__c, DH_CallCenterDataSheet__r.Name from DH_Call_Center_Mapping__c where DH_CallCenterDataSheet__c =:denormalizedObjectId ];
          for(DH_Call_Center_Mapping__c ccm : listOfExistingCCMappingObjects){
              System.debug('ccm.DH_Practice_Code__c '+ccm.DH_Practice_Code__c);
              stringMadeByExistingObjects=(ccm.DH_System__c!=null?regionMap.get(ccm.DH_System__c):'')+','+(ccm.DH_Practice_Code__c!=null?practiceMap.get(ccm.DH_Practice_Code__c):'')+','+(ccm.DH_Site_Code__c!=null?siteMap.get(ccm.DH_Site_Code__c):'')+','+(ccm.DH_ZIP__c!=null?ccm.DH_ZIP__c:'')+','+(ccm.DH_Modality_Code__c!=null?modalityCodeCareSpecialtyMap.get(ccm.DH_Modality_Code__c):'')+','+(ccm.DH_Procedure_Code__c!=null?procedureCodeHealthCareProcedureMap.get(ccm.DH_Procedure_Code__c):'')+','+(ccm.DH_Fake_call_center_site_code_Lookup__c!=null?callCenterMap.get(ccm.DH_Fake_call_center_site_code_Lookup__c):'') +','+(ccm.DH_Referring_Group_Code__c!=null?RefPracticeOrGrpCodeNameMap.get(ccm.DH_Referring_Group_Code__c):'')+','+('end');
              mapTobeComparedWithTobeDeletedList.put(ccm.Id,stringMadeByExistingObjects);
          }
          for(Id mapId: mapTobeComparedWithTobeDeletedList.keySet()){
              String tempstring= mapTobeComparedWithTobeDeletedList.get(mapId);
              System.debug('tempstring' + tempstring);
              if(notTobeDeletedList.contains(tempstring)){
                  idsNotToBeDeleted.add(mapId);
              }
          }
          
          for(DH_Call_Center_Mapping__c callCenterMappig : listOfExistingCCMappingObjects){
              if(!idsNotToBeDeleted.contains(callCenterMappig.Id)){
                  objectsToBeDeleted.add(callCenterMappig);
              }  
          }
          System.debug('objectsToBeDeleted ' + objectsToBeDeleted.size() + ' ' + objectsToBeDeleted );
          //List<DH_Call_Center_Mapping__c> objectsToBeDeleted = [SELECT Id From DH_Call_Center_Mapping__c WHERE DH_CallCenterDataSheet__c =:denormalizedObjectId and Id NOT IN: idsNotToBeDeleted];

      }
      else if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_NAME){
      //    List<DH_Call_Center_Hours__c> listOfExistingCCHoursObjects = [select Id, DH_System__c,DH_Practice_Code__c, DH_Call_Center_Code_Lookup__c, DH_Site_Code__c, DH_Day_of_Week__c, DH_Specific_Date__c, DH_Notes1__c, DH_Contact_Method__c, DH_iCode__c, DH_CallCenterDataSheet__r.Name from DH_Call_Center_Hours__c where DH_CallCenterDataSheet__c =:denormalizedObjectId ];
          for(DH_Call_Center_Hours__c cch : listOfExistingCCHoursObjects){
              String finalStringValueForDate;
              if(cch.DH_Specific_Date__c!=null){
                  String stringDateValue = string.valueOf(cch.DH_Specific_Date__c);
                  List<String> stringDateParts = stringDateValue.split('-');
                  finalStringValueForDate =stringDateParts[1] +'/'+ stringDateParts[2] +'/'+ stringDateParts[0];
              } 
              //removed notes from 6th index for notes changes
              stringMadeByExistingObjects=(cch.DH_System__c!=null?regionMap.get(cch.DH_System__c):'')+','+(cch.DH_Practice_Code__c!=null?practiceMap.get(cch.DH_Practice_Code__c):'')+','+(cch.DH_Call_Center_Code_Lookup__c!=null?callCenterMap.get(cch.DH_Call_Center_Code_Lookup__c):'')+','+(cch.DH_Site_Code__c!=null?siteMap.get(cch.DH_Site_Code__c):'')+','+(cch.DH_Day_of_Week__c!=null?cch.DH_Day_of_Week__c:'')+','+(cch.DH_Specific_Date__c!=null?finalStringValueForDate:'')+','+(cch.DH_Contact_Method__c!=null?cch.DH_Contact_Method__c:'')+','+(cch.DH_iCode__c!=null?cch.DH_iCode__c:'')+','+('end');
              mapTobeComparedWithTobeDeletedList.put(cch.Id,stringMadeByExistingObjects);
          }
          
          for(Id mapId: mapTobeComparedWithTobeDeletedList.keySet()){
              String tempstring= mapTobeComparedWithTobeDeletedList.get(mapId);
              System.debug('tempstring' + tempstring);
              if(notTobeDeletedList.contains(mapTobeComparedWithTobeDeletedList.get(mapId))){
                  idsNotToBeDeleted.add(mapId);
              }
          }

          for(DH_Call_Center_Hours__c callCenterHours : listOfExistingCCHoursObjects){
              if(!idsNotToBeDeleted.contains(callCenterHours.Id)){
                  objectsToBeDeleted.add(callCenterHours);
              }  
          }
          System.debug('objectsToBeDeleted ' + objectsToBeDeleted.size() + ' ' + objectsToBeDeleted );
         // List<DH_Call_Center_Hours__c> objectsToBeDeleted = [SELECT Id From DH_Call_Center_Hours__c WHERE DH_CallCenterDataSheet__c =:denormalizedObjectId and Id NOT IN: idsNotToBeDeleted];
 
      }
      return objectsToBeDeleted;
  }

}