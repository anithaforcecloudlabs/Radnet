/*
* ***************************************************************************************************************************
* Apex Class Name - DH_BatchForNormalization
* Version - 0.1
* Created Date - 
* Function - Batch to create and delete nomalized records and call function to send data to SFMC.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Prasanna Anjakar                               Intial version.
* *****************************************************************************************************************************
*/

global class DH_BatchForNormalization implements Database.stateful,Database.Batchable<SObject>,Database.AllowsCallouts{
    global Integer recordTypeSelector = 1;
    global Integer batchSize = 20;
    global Integer reprocessFailedRecordsBatchSize=20;
    global List<DH_Call_Center_Data_Sheet__c>ccdsRecords;  
    global List<DH_Call_Center_Data_Sheet__c>failedCCDsToReprocess=new List<DH_Call_Center_Data_Sheet__c>();
    public Set<Id> processingIds = new Set<Id>();
    
    global List<SObject> combinedNormalizedRecordsToBeInserted = new List<SObject>();
    global List<SObject> combinedNormalizedRecordsToBeUpdated = new List<SObject>();
    global Map<Id,DH_Call_Center_Data_Sheet__c> combinedNormalizedRecordsOldValuesForRollback = new Map<Id,DH_Call_Center_Data_Sheet__c>();
    global List<SObject> combinedNormalizedRecordsToBeDeleted = new List<SObject>();
    global Set<Integer> errorRecordTypeSelectorSet = new Set<Integer>();
    global String recordTypeName;
    
    
    //RecordTypeSelector 1=>Exclusion,2=>ModalityPriority,3=>call center mapping,4=> call center hours
    //Initialization of map wrapper
    global static DH_BatchForNormalization.BatchQueryWrapper mapWrapper = new DH_BatchForNormalization.BatchQueryWrapper();
    
    
	 @TestVisible global static Boolean isTestSetup = false; 
 
 	 // Private method
    @TestVisible global static void updateIsTestSetup(Boolean isTestSetupValue) {
        // Do something
		isTestSetup = isTestSetupValue;
    }
    
    /**
    * @description constructor to initialize the selected records.
    **/
    global DH_BatchForNormalization(Integer recordTypeSelector,List<DH_Call_Center_Data_Sheet__c>ccdsRecords){
      this.recordTypeSelector = recordTypeSelector;
      this.ccdsRecords= ccdsRecords;
    }

         /**
    * @author Prasanna Anjankar | 20-Jun-2024 
    * @param List<DH_Call_Center_Data_Sheet__c>,Integer
    * @description constructor to initialize the selected records.
    **/
    global DH_BatchForNormalization(Integer recordTypeSelector,List<DH_Call_Center_Data_Sheet__c>ccdsRecords,List<DH_Call_Center_Data_Sheet__c>failedCcdsRecords){
        this.recordTypeSelector = recordTypeSelector;
        this.ccdsRecords= ccdsRecords;
        this.failedCCDsToReprocess = failedCcdsRecords;
      }

   
    /**
    * @description Start Method for batch class
    **/
    global Database.Querylocator Start(Database.BatchableContext bc){
       if(recordTypeSelector==1){
           recordTypeName=DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_NAME;
       }
       if(recordTypeSelector==2){
          recordTypeName=DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_NAME;
       }
       if(recordTypeSelector==3){
          recordTypeName=DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_NAME;
       }      
        if(recordTypeSelector==4){
           recordTypeName=DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_NAME;
       }
       //If selector value is 1 check for the ccdsrecords whose record type is exclusion
      String query = 'select Id,Name,RecordTypeId,DH_Previous_Value__c,DH_New_or_Re_Schedule__c, DH_Ref_Dr__c,DH_Ref_Group_Code__c,Published__c, DH_System__c, DH_Practice_Code__c, DH_Modality_Code_aka_Proc_Group_Code__c,DH_Site_Code_or_Call_Center_Code__c, DH_Fake_call_center_site_code__c,DH_Site_Code__c, DH_Procedure_Code__c, DH_Portal_Procedure_Group_Modality_Code__c,DH_iCode__c, DH_Carrier_Code__c,DH_Relative_Priority__c, DH_Description__c,DH_Notes_1__c, DH_Notes_2__c, DH_Specific_Date__c, DH_Day_of_Week__c, DH_Earliest_Time_for_RADAR_Outreach__c, DH_timezone__c, DH_Latest_Time_for_RADAR_Outreach__c, DH_URL1_to_give_RADAR__c,DH_URL2_to_give_RADAR__c, DH_URL3_to_give_RADAR__c, DH_URL4_to_give_RADAR__c,DH_URL5_to_give_RADAR__c, DH_Phone_Number_1__c, DH_Phone_Number_2__c, DH_Phone_Number_3__c,DH_Phone_Number_4__c, DH_Phone_Number_5__c, DH_Contact_Method__c, DH_ZIP__c from DH_Call_Center_Data_Sheet__c where RecordType.Name=:recordTypeName and ID in:ccdsRecords';
       return Database.getQueryLocator(query);
    }
    
             /**
    * @param  Database.BatchableContext, (Scope) list<DH_Call_Center_Data_Sheet__c>
    * @description Start Method for batch class
    **/
    global void execute(Database.BatchableContext bc, List<DH_Call_Center_Data_Sheet__c> scope) {
    //ifRecordtype selector value is 1==do processing for exclusion etc
    Savepoint sp = Database.setSavepoint();
    set<String>uniqueKeysToBUpsertedInsertedAll = new set<String>();
    set<String>uniqueKeysToBDeletedAll = new set<String>();
    map<Id,DH_Call_Center_Data_Sheet__c> duplicateErrorMapOfDenormalizedRec = new  map<Id,DH_Call_Center_Data_Sheet__c>();
       List<SObject> normalizedRecordsToBeInserted = new List<SObject>();
       List<SObject> normalizedRecordsToBeUpdated = new List<SObject>();
       List<SObject> normalizedRecordsToBeDeleted = new List<SObject>();
       
       Map<Id,Boolean> recordWithExistingChilds = new Map<Id,Boolean>();
       Map<Id,List<Sobject>> recordsToBeInsertedMap = new Map<Id,List<Sobject>>();
       Map<Id,DH_NormalizedRecordUpdate.WrapperOfObjects> recordsToBeUpdatedMap = new Map<Id,DH_NormalizedRecordUpdate.WrapperOfObjects>();
       Set<DH_Call_Center_Data_Sheet__c> recordsInserted = new Set<DH_Call_Center_Data_Sheet__c>();
       Set<DH_Call_Center_Data_Sheet__c> recordsUpdated = new  Set<DH_Call_Center_Data_Sheet__c>();
       List<DH_Exclusions__c> exclusionList = new List<DH_Exclusions__c>();
       List<DH_Modality_Priority__c> modalityPriorityList = new List<DH_Modality_Priority__c>();
       List<DH_Call_Center_Mapping__c> callCenterMappingList = new List<DH_Call_Center_Mapping__c>();
       List<DH_Call_Center_Hours__c> callCenterHourList = new List<DH_Call_Center_Hours__c>();
       
       DH_BatchForNormalization.normalizedDataWrapper normalizedRecordData = new DH_BatchForNormalization.normalizedDataWrapper();
       DH_NormalizedRecordUpdate.WrapperOfObjects recordsToBeUpdatedWrapper=new DH_NormalizedRecordUpdate.WrapperOfObjects();
       mapWrapper = DH_BatchForNormalization.createMapsFromList(scope);
       
        
        //Set to store the id of records part of process after duplicate check and whose previous value is to be updated;
        Set<Id> idsOfObjectsForPreviousValueUpdate = new Set<Id>();
       
       for(DH_Call_Center_Data_Sheet__c cc: scope){
           If(cc.RecordTypeId !=null){
               processingIds.add(cc.id);          
           }
       }
       
    if(recordTypeSelector==1){
        exclusionList = [select Id, Name, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_Site_Code_Formula__c,
        DH_Carrier_Code_Formula__c, DH_Referring_ID_Formula__c, DH_Procedure_Code_Formula__c,DH_Procedure_Group_Code_Formula__c, DH_Practice_Code_Formula__c, DH_FileExclUniqueKey__c,
        DH_Referring_Group_Code_Formula__c,DH_Procedure_Code__c,  DH_Carrier_Code__c, DH_Referring_Group_Code__c, DH_referring_id__c, DH_Order_Nrf__c,
        DH_CallCenterDataSheet__c,CreatedById,DH_iCode__c,LastModifiedById,DH_New_or_Re_Schedule__c,DH_Notes__c,
        OwnerId,DH_Procedure_Group_Code__c,DH_UniqueKey__c,
        RecordTypeId,DH_System_Formula__c,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,
        LastViewedDate,LastReferencedDate, DH_CallCenterDataSheet__r.Name from DH_Exclusions__c where DH_CallCenterDataSheet__c 
        IN :processingIds];
    }
    
    if(recordTypeSelector==2){
        modalityPriorityList=[select Id, Name, DH_System__c, DH_procedure_group_code__c,DH_CallCenterDataSheet__c, DH_Relative_Priority__c, 
        DH_Procedure_Group_Code_Formula__c, DH_System_Formula__c, DH_FilePriorityUniqueKey__c, DH_CallCenterDataSheet__r.Name,
        CreatedById,DH_Description__c,LastModifiedById,OwnerId,DH_Portal_Procedure_Group_Modality_Code__c,DH_UniqueKey__c,
    RecordTypeId,IsDeleted,LastModifiedDate,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDatE from 
        DH_Modality_Priority__c where DH_CallCenterDataSheet__c IN :processingIds];
    }
    
    if(recordTypeSelector==3){
        callCenterMappingList=[select Id, Name, DH_System__c, DH_Practice_Code__c, DH_Site_Code__c, DH_ZIP__c, 
        DH_Modality_Code__c, DH_Procedure_Code__c, DH_Fake_call_center_site_code_Lookup__c,	DH_Referring_Group_Code__c,DH_Notes__c,
        DH_Fake_call_center_site_code__c,DH_URL1_to_give_RADAR__c,DH_URL2_to_give_RADAR__c,DH_URL3_to_give_RADAR__c,DH_UniqueKey__c,
        DH_URL4_to_give_RADAR__c,DH_URL5_to_give_RADAR__c,DH_Phone_Number_1__c,DH_Phone_Number_2__c,DH_Phone_Number_3__c,
        DH_Phone_Number_4__c,DH_Phone_Number_5__c,DH_System_Formula__c,DH_Practice_Code_Formula__c,DH_Site_Code_Formula__c,
        DH_Referring_Group_Code_Formula__c,DH_Modality_Code_Formula__c,DH_Procedure_Code_Formula__c,
        OwnerId,IsDeleted,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastViewedDate,
        LastReferencedDate,DH_Site_Code_or_Call_Center_Code__c,RecordTypeId,
        DH_CallCenterDataSheet__c, DH_CallCenterDataSheet__r.Name from DH_Call_Center_Mapping__c where 
        DH_CallCenterDataSheet__c IN :processingIds];
    }
    if(recordTypeSelector==4){
        callCenterHourList=[select Id, Name, DH_System__c,DH_Practice_Code__c, DH_Call_Center_Code_Lookup__c, DH_Site_Code__c, DH_Day_of_Week__c, 
        DH_FileCCHoursUniqueKey__c, DH_Call_Center_Code__c, DH_timezone__c, DH_CSTStartTime__c, DH_CSTEndTime__c, DH_System_Formula__c, DH_SIte_Code_Formula__c, 
        DH_Practice_Code_Formula__c, DH_Specific_Date__c, DH_Notes1__c, DH_Contact_Method__c, DH_iCode__c,DH_CallCenterDataSheet__c, 
        CreatedById ,DH_Earliest_Time_for_RADAR_Outreach__c  ,DH_isHoliday__c ,RecordTypeId,DH_UniqueKey__c,
    LastModifiedById, DH_Latest_Time_for_RADAR_Outreach__c , DH_Notes2__c,DH_Outreach_Timezone__c,OwnerId,IsDeleted,LastModifiedDate,
    SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate,DH_CallCenterDataSheet__r.Name from DH_Call_Center_Hours__c where DH_CallCenterDataSheet__c IN :processingIds];
    }	        
    
    normalizedRecordData.exclusionList=exclusionList;
    normalizedRecordData.modalityPriorityList=modalityPriorityList;
    normalizedRecordData.callCenterMappingList=callCenterMappingList;
    normalizedRecordData.callCenterHourList=callCenterHourList;
       
       for(DH_Call_Center_Data_Sheet__c callCenterRecord: scope){
           if(callCenterRecord.DH_Previous_Value__c!=null){
                recordsUpdated.add(callCenterRecord);
           }
           else{
               recordsInserted.add(callCenterRecord);
           }
       }
       Map<DH_Call_Center_Data_Sheet__c,set<String>>mapDenormalizedRecVsListOfKeysToBInserted = new Map<DH_Call_Center_Data_Sheet__c,set<String>>();
       if(!recordsInserted.isEmpty()){
           for(DH_Call_Center_Data_Sheet__c denormalizedObjectnew: recordsInserted){
               
                   List<String> allCombinationfinal = new List<String>();
                   //calling for fetching all combinations;
                   allCombinationfinal =  	DH_CreateCombinationDenormalizedRecord.compileMultFieldsAndCreateCombination(denormalizedObjectnew);
                   //calling for creation of records;                    
                   String recordTypeName =  Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosById().get(denormalizedObjectnew.RecordTypeId).getName();                    
                   List<String> listOfSimilarFields = createListForSmilarFields(denormalizedObjectnew);
                   //List<Sobject> listOfObjectToRecievedToBeCreated = DH_NormalizedRecordsCreation.createListsOfNormalizedRecordsTobeCreated(denormalizedObjectnew,recordTypeName,allCombinationfinal,listOfSimilarFields,mapWrapper);    
                   List<Sobject> listOfObjectToRecievedToBeCreated = DH_NormalizedRecordsCreation.createListsOfNormalizedRecordsTobeCreated(denormalizedObjectnew, recordTypeName, allCombinationfinal, listOfSimilarFields,mapWrapper);
                   //Iterate over To B inserted normalized records and create unique Keys list for them
                   set<String>setOfNormalizedKeysForParent = new set<String>();
                   if(!listOfObjectToRecievedToBeCreated.isEmpty()){
                    for(Sobject normalizedObToBCreated : listOfObjectToRecievedToBeCreated){
                        String uniqueKeyNormalizedKey = (String)normalizedObToBCreated.get('DH_UniqueKey__c');
                        setOfNormalizedKeysForParent.add(uniqueKeyNormalizedKey);
                        uniqueKeysToBUpsertedInsertedAll.add(uniqueKeyNormalizedKey);
                    }
                    if(!setOfNormalizedKeysForParent.isEmpty()){
                        mapDenormalizedRecVsListOfKeysToBInserted.put(denormalizedObjectnew,setOfNormalizedKeysForParent);
                    }
                   }
                   recordsToBeInsertedMap.put(denormalizedObjectnew.Id,listOfObjectToRecievedToBeCreated);
           }

       }
       Map<DH_Call_Center_Data_Sheet__c,set<String>>mapDenormalizedRecVsListOfKeysToBUpdated = new Map<DH_Call_Center_Data_Sheet__c,set<String>>();
       if(!recordsUpdated.isEmpty()){
          for(DH_Call_Center_Data_Sheet__c denormalizedObjectnew: recordsUpdated){
                set<String>setOfNormalizedKeysForParent = new set<String>();
                 DH_Call_Center_Data_Sheet__c objectWithOldValues = new  DH_Call_Center_Data_Sheet__c();
                 
               if(recordsUpdated.contains(denormalizedObjectnew)){
                    objectWithOldValues = DH_ExclusionDenormalizeJsonConverter.getBackObjectFromJsonString(String.ValueOf(denormalizedObjectnew.DH_Previous_Value__c));
                       combinedNormalizedRecordsOldValuesForRollback.put(objectWithOldValues.id,objectWithOldValues);
               }
               String recordTypeName =  Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosById().get(denormalizedObjectnew.RecordTypeId).getName();
               List<String> listOfSimilarFields = createListForSmilarFields(denormalizedObjectnew);
               recordsToBeUpdatedWrapper = DH_NormalizedRecordUpdate.handleUpdateOfDenormalizedRecords(objectWithOldValues, denormalizedObjectnew, denormalizedObjectnew.Id, recordTypeName, listOfSimilarFields,mapWrapper,normalizedRecordData);
               recordsToBeUpdatedMap.put(denormalizedObjectnew.Id,recordsToBeUpdatedWrapper);
               
               for(Sobject normalizedObToBCreated:recordsToBeUpdatedMap.get(denormalizedObjectnew.Id).objectsToBeCreated){
                    String uniqueKeyNormalizedKey = (String)normalizedObToBCreated.get('DH_UniqueKey__c');
                    setOfNormalizedKeysForParent.add(uniqueKeyNormalizedKey);
                    uniqueKeysToBUpsertedInsertedAll.add(uniqueKeyNormalizedKey);
               }
               for(Sobject normalizedObToBUpdated:recordsToBeUpdatedMap.get(denormalizedObjectnew.Id).objectsToBeUpdated){
                    String uniqueKeyNormalizedKey = (String)normalizedObToBUpdated.get('DH_UniqueKey__c');
                    setOfNormalizedKeysForParent.add(uniqueKeyNormalizedKey);
                    uniqueKeysToBUpsertedInsertedAll.add(uniqueKeyNormalizedKey);
               }
                for(Sobject normalizedObToBDeleted:recordsToBeUpdatedMap.get(denormalizedObjectnew.Id).objectsToBeDeleted){
                    String uniqueKeyNormalizedKey = (String)normalizedObToBDeleted.get('DH_UniqueKey__c');                 
                    uniqueKeysToBDeletedAll.add(uniqueKeyNormalizedKey);
               }
               if(!setOfNormalizedKeysForParent.isEmpty()){
                mapDenormalizedRecVsListOfKeysToBUpdated.put(denormalizedObjectnew,setOfNormalizedKeysForParent);
            }
           }
       }
        List<SObject> listOfExistingNormRecsWithSameKeys = new List<sObject>();
           if(recordTypeSelector==1){
                listOfExistingNormRecsWithSameKeys=[select Id, DH_UniqueKey__c,DH_CallCenterDataSheet__c from DH_Exclusions__c where DH_UniqueKey__c IN :uniqueKeysToBUpsertedInsertedAll];
           }else if(recordTypeSelector==2){
                listOfExistingNormRecsWithSameKeys=[select Id, DH_UniqueKey__c,DH_CallCenterDataSheet__c from DH_Modality_Priority__c where DH_UniqueKey__c IN :uniqueKeysToBUpsertedInsertedAll];
                }
           else if(recordTypeSelector==3){
                listOfExistingNormRecsWithSameKeys=[select Id, DH_UniqueKey__c,DH_CallCenterDataSheet__c from DH_Call_Center_Mapping__c where DH_UniqueKey__c IN :uniqueKeysToBUpsertedInsertedAll];
               }
           else if(recordTypeSelector==4){
                listOfExistingNormRecsWithSameKeys=[select Id, DH_UniqueKey__c,DH_CallCenterDataSheet__c from DH_Call_Center_Hours__c where DH_UniqueKey__c IN :uniqueKeysToBUpsertedInsertedAll];
                   }

        //Duplicate check
        if(!mapDenormalizedRecVsListOfKeysToBInserted.isEmpty()){
            for(DH_Call_Center_Data_Sheet__c denormalizedObjectnew:mapDenormalizedRecVsListOfKeysToBInserted.keySet()){
                set<String>uniqueKeysToBInserted = mapDenormalizedRecVsListOfKeysToBInserted.get(denormalizedObjectnew);
                for(String ToBInsertedKey:uniqueKeysToBInserted){
                    //Check if the list of normalized records to B inserted already exist in Database
                    if(!listOfExistingNormRecsWithSameKeys.isEmpty()){ 
                        for(sObject existingObjNormalized:listOfExistingNormRecsWithSameKeys){
                            if(ToBInsertedKey.equalsIgnoreCase((String)existingObjNormalized.get('DH_UniqueKey__c')) && !uniqueKeysToBDeletedAll.contains(ToBInsertedKey)){
                                 duplicateErrorMapOfDenormalizedRec.put((String)existingObjNormalized.get('DH_CallCenterDataSheet__c'),denormalizedObjectnew);
                                 //Remove this records from to b inserted list 
                                recordsToBeInsertedMap.remove(denormalizedObjectnew.id); 
                                break;     
                            }
                        }
                    }
                    //Check if the list of normalized records to B inserted is present in updated denormalized records
                    for(DH_Call_Center_Data_Sheet__c denormalizedObjectUpdated:mapDenormalizedRecVsListOfKeysToBUpdated.keySet()){
                        set<String>uniqueKeysToBInsertedForOldCCDS = mapDenormalizedRecVsListOfKeysToBUpdated.get(denormalizedObjectUpdated);
                         for(String otherObjNormalizedKey:uniqueKeysToBInsertedForOldCCDS){
                            if(ToBInsertedKey.equalsIgnoreCase(otherObjNormalizedKey)){
                                 duplicateErrorMapOfDenormalizedRec.put(denormalizedObjectUpdated.id,denormalizedObjectnew);
                                  //Remove this records from to b inserted list  
                                recordsToBeInsertedMap.remove(denormalizedObjectnew.id); 
                                 break;
                                    
                            }
                         }
                    }
                    //Check if the list of normalized records to B inserted is present in list of other normalized to B inserted
                    for(DH_Call_Center_Data_Sheet__c otherDenormalizedObjectInserted:mapDenormalizedRecVsListOfKeysToBInserted.keySet()){
                        if(otherDenormalizedObjectInserted.id !=denormalizedObjectnew.Id){
                            set<String>uniqueKeysToBInsertedForOldCCDS = mapDenormalizedRecVsListOfKeysToBInserted.get(otherDenormalizedObjectInserted);
                            for(String otherObjNormalizedKey:uniqueKeysToBInsertedForOldCCDS){
                                if(ToBInsertedKey.equalsIgnoreCase(otherObjNormalizedKey)){
                                    duplicateErrorMapOfDenormalizedRec.put(otherDenormalizedObjectInserted.id,denormalizedObjectnew);
                                       //Remove this records from to b inserted list  
                                    recordsToBeInsertedMap.remove(denormalizedObjectnew.id); 
                                    break;
                                      
                                }
                            } 
                        }
                        
                    }
                }
            }
        }
       //Check duplicates for updated CCDS records
        if(!mapDenormalizedRecVsListOfKeysToBUpdated.isEmpty()){
            for(DH_Call_Center_Data_Sheet__c denormalizedObjectnew:mapDenormalizedRecVsListOfKeysToBUpdated.keySet()){
                set<String>uniqueKeysToBInserted = mapDenormalizedRecVsListOfKeysToBUpdated.get(denormalizedObjectnew);
                for(String ToBInsertedKey:uniqueKeysToBInserted){
                    //Check if the list of normalized records to B inserted already exist in Database
                    if(!listOfExistingNormRecsWithSameKeys.isEmpty()){
                        for(sObject existingObjNormalized:listOfExistingNormRecsWithSameKeys){
                            if(ToBInsertedKey.equalsIgnoreCase((String)existingObjNormalized.get('DH_UniqueKey__c')) && !uniqueKeysToBDeletedAll.contains(ToBInsertedKey)
                              && (String)existingObjNormalized.get('DH_CallCenterDataSheet__c')!=denormalizedObjectnew.id){
                                duplicateErrorMapOfDenormalizedRec.put((String)existingObjNormalized.get('DH_CallCenterDataSheet__c'),denormalizedObjectnew);
                                //Remove this records from to b inserted list  
                                recordsToBeUpdatedMap.remove(denormalizedObjectnew.id);
                                break;
    
                            }
                        }
                    }
                    //Check if the list of normalized records to B inserted is present in updated denormalized records
                    for(DH_Call_Center_Data_Sheet__c denormalizedObjectInserted:mapDenormalizedRecVsListOfKeysToBInserted.keySet()){
                        set<String>uniqueKeysToBInsertedForNewCCDS = mapDenormalizedRecVsListOfKeysToBInserted.get(denormalizedObjectInserted);
                         for(String otherObjNormalizedKey:uniqueKeysToBInsertedForNewCCDS){
                            if(ToBInsertedKey.equalsIgnoreCase(otherObjNormalizedKey)){
                                 duplicateErrorMapOfDenormalizedRec.put(denormalizedObjectInserted.id,denormalizedObjectnew);
                                //Remove this records from to b inserted list  
                                recordsToBeUpdatedMap.remove(denormalizedObjectnew.id);
                                 break;   
                            }
                         }
                    }
                    //Check if the list of normalized records to B inserted is present in list of other normalized to B inserted denoralized records
                    for(DH_Call_Center_Data_Sheet__c otherDenormalizedObjectUpdated:mapDenormalizedRecVsListOfKeysToBUpdated.keySet()){
                        if(otherDenormalizedObjectUpdated.id !=denormalizedObjectnew.Id){
                            set<String>uniqueKeysToBInsertedForOldCCDS = mapDenormalizedRecVsListOfKeysToBUpdated.get(otherDenormalizedObjectUpdated);
                            for(String otherObjNormalizedKey:uniqueKeysToBInsertedForOldCCDS){
                                if(ToBInsertedKey.equalsIgnoreCase(otherObjNormalizedKey)){
                                    duplicateErrorMapOfDenormalizedRec.put(otherDenormalizedObjectUpdated.id,denormalizedObjectnew);
                                 //Remove this records from to b inserted list  
                                recordsToBeUpdatedMap.remove(denormalizedObjectnew.id);
                                break;    
                                }
                            } 
                        }
                        
                    }
                }
            }
        }
        
       for(Id denormalizedRecordToBeInsertedId: recordsToBeInsertedMap.keySet()){
           		idsOfObjectsForPreviousValueUpdate.add(denormalizedRecordToBeInsertedId);
               normalizedRecordsToBeInserted.addAll(recordsToBeInsertedMap.get(denormalizedRecordToBeInsertedId));
           }
              
        for(Id denormalizedObjectIdToBeOperated : recordsToBeUpdatedMap.keySet()){
            idsOfObjectsForPreviousValueUpdate.add(denormalizedObjectIdToBeOperated);
               normalizedRecordsToBeDeleted.addAll((recordsToBeUpdatedMap.get(denormalizedObjectIdToBeOperated).objectsToBeDeleted));
               normalizedRecordsToBeUpdated.addAll((recordsToBeUpdatedMap.get(denormalizedObjectIdToBeOperated).objectsToBeUpdated));
               normalizedRecordsToBeInserted.addAll((recordsToBeUpdatedMap.get(denormalizedObjectIdToBeOperated).objectsToBeCreated));
           }
        
        if(!duplicateErrorMapOfDenormalizedRec.isEmpty()){
             errorRecordTypeSelectorSet.add(recordtypeselector);
            for(String duplicateCCDSId : duplicateErrorMapOfDenormalizedRec.keySet()){
                DH_Call_Center_Data_Sheet__c ccdsToBeEnteredError = duplicateErrorMapOfDenormalizedRec.get(duplicateCCDSId);
                ccdsToBeEnteredError.DH_Error_Log__c = 'Duplicate combination exists in the denormalized record '+System.label.DH_Duplicate_record_url+duplicateCCDSId+'/view';
				ccdsToBeEnteredError.DH_isError__c = true;
            }          
            //UPDATE ccdsToBeEnteredError
            //Id of ccds to be error vs ccdsto be error
          Map<Id, DH_Call_Center_Data_Sheet__c> finalErrorCcdssUpdate = new Map<Id, DH_Call_Center_Data_Sheet__c>();
            for(DH_Call_Center_Data_Sheet__c ccds : duplicateErrorMapOfDenormalizedRec.values()){
                if(finalErrorCcdssUpdate.keySet().contains(ccds.Id)&& finalErrorCcdssUpdate.get(ccds.Id)!=null &&(finalErrorCcdssUpdate.get(ccds.Id).DH_Error_Log__c != ccds.DH_Error_Log__c)){
					finalErrorCcdssUpdate.get(ccds.Id).DH_Error_Log__c=finalErrorCcdssUpdate.get(ccds.Id).DH_Error_Log__c + ' & ' + ccds.DH_Error_Log__c;
                }
                else{
                    finalErrorCcdssUpdate.put(ccds.Id,ccds);
                }
            }
            
                update finalErrorCcdssUpdate.values();   
        }
        //Check if the list of normalized records to B updated already exist in Database    
        if((normalizedRecordsToBeDeleted.size()+ normalizedRecordsToBeUpdated.size()+ normalizedRecordsToBeInserted.size()>10000) && this.batchSize == 1){
            scope[0].DH_Error_Log__c = 'Combination size exceeds 10000.Please split this record into multiples and TRY publishing again';
            scope[0].DH_isError__c=true;
            try{
                update scope[0];
                errorRecordTypeSelectorSet.add(recordtypeselector);
            }
            catch(Exception e){
                System.debug('Final Error while updating last  object: ' + e);
            }
        }
        else if(normalizedRecordsToBeDeleted.size()+ normalizedRecordsToBeUpdated.size()+ normalizedRecordsToBeInserted.size()>10000 && batchSize > 1){
            failedCCDsToReprocess.addAll(recordsInserted);
            failedCCDsToReprocess.addAll(recordsUpdated);
        }
        else{
            List<SObject> combinedNormalizedRecordsBeforeDelete = new List<SObject>(combinedNormalizedRecordsToBeDeleted);
       		List<SObject> combinedNormalizedRecordsBeforeUpdate = new List<SObject>(combinedNormalizedRecordsToBeUpdated);
       		List<SObject> combinedNormalizedRecordsBeforeInsert = new List<SObject>(combinedNormalizedRecordsToBeInserted);   
       		try{
           		if(!normalizedRecordsToBeDeleted.isEmpty()){
               		combinedNormalizedRecordsToBeDeleted.addAll(normalizedRecordsToBeDeleted);
               		delete normalizedRecordsToBeDeleted;
               
          		 }
           		if(!normalizedRecordsToBeUpdated.isEmpty()){
               		combinedNormalizedRecordsToBeUpdated.addAll(normalizedRecordsToBeUpdated);
               		update normalizedRecordsToBeUpdated;
           		}
           
           		if(!normalizedRecordsToBeInserted.isEmpty()){
              		combinedNormalizedRecordsToBeInserted.addAll(normalizedRecordsToBeInserted);
               		insert normalizedRecordsToBeInserted;
           		}	
        		DH_ExclusionDenormalizeJsonConverter.updatePreviousValueCallCenterDataSheet(idsOfObjectsForPreviousValueUpdate);
       		}
       		catch(Exception e){
           		combinedNormalizedRecordsToBeDeleted = combinedNormalizedRecordsBeforeDelete;
           		combinedNormalizedRecordsToBeUpdated = combinedNormalizedRecordsBeforeUpdate;
           		combinedNormalizedRecordsToBeInserted = combinedNormalizedRecordsBeforeInsert;
                failedCCDsToReprocess.addAll(recordsInserted);
                failedCCDsToReprocess.addAll(recordsUpdated); 
           		Database.rollback(sp);
       		}
        }
    }
       
             /**
    * @param  Database.BatchableContext, 
    * @description finish method for batch
    **/
    global void finish(Database.BatchableContext bc) {
        String objectName;
           List<sObject> combinedInsertUpdateList = new List<sObject>();
           if(!combinedNormalizedRecordsToBeInserted.isEmpty()){
               combinedInsertUpdateList.addAll(combinedNormalizedRecordsToBeInserted);
           }
           if(!combinedNormalizedRecordsToBeUpdated.isEmpty()){
               combinedInsertUpdateList.addAll(combinedNormalizedRecordsToBeUpdated);
           }
        if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_NAME){
           objectName=System.label.DH_ExclusionAPIname;
           }
           if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_NAME){
             objectName=System.label.DH_ModalityPriorityAPIname;  
           }
           if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_NAME){
              objectName=System.label.DH_CallCenterMappingAPIname; 
           }
           if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_NAME){
              objectName=System.label.DH_CallCenterHoursAPIname; 
           } 
           //sending data to sfmc
        if((!combinedInsertUpdateList.isEmpty() || !combinedNormalizedRecordsToBeDeleted.isEmpty()) && !Test.isRunningTest())
        {
          System.enqueueJob(new DH_SendNormalizeDataQueue(0,combinedInsertUpdateList,combinedNormalizedRecordsToBeDeleted,null,objectName,null));   

        }
           //Calling batch for next record type by incrementing record type selector
        if((recordTypeSelector<4 && batchSize>1 && !Test.isRunningTest())){
            recordTypeSelector=recordTypeSelector+1;
            DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(recordTypeSelector,ccdsRecords,failedCCDsToReprocess);
            Database.executeBatch(batchInstanceNext,batchSize);
          }
          if((recordTypeSelector<4 && batchSize==1 && !Test.isRunningTest())){
            recordTypeSelector=recordTypeSelector+1;
            DH_BatchForNormalization batchInstanceNext = new DH_BatchForNormalization(recordTypeSelector,ccdsRecords,failedCCDsToReprocess);
            batchInstanceNext.batchSize=1;
            Database.executeBatch(batchInstanceNext,batchSize);
          }
          if(recordTypeSelector==4 && batchSize==1){
              if(!errorRecordTypeSelectorSet.isEmpty()){
                  sendEmailAlert(errorRecordTypeSelectorSet);
              }
            this.recordTypeSelector = 5;
       
          }
                
          if((recordTypeSelector==4 && !failedCCDsToReprocess.isEmpty() && this.batchSize>1 && !Test.isRunningTest())){
            DH_BatchForNormalization failedInstanceRun= new DH_BatchForNormalization(1,failedCCDsToReprocess);
            failedInstanceRun.failedCCDsToReprocess = new List<DH_Call_Center_Data_Sheet__c>();
            if(failedCCDsToReprocess.size()==1){
                failedInstanceRun.batchSize=1;
            }
            else{
                failedInstanceRun.batchSize = failedCCDsToReprocess.size()>this.batchSize? this.batchSize/2:failedCCDsToReprocess.size()/2;
            }
            Database.executeBatch(FailedInstanceRun,batchSize);
          }
        
         if(recordTypeSelector==4 && failedCCDsToReprocess.isEmpty() && !errorRecordTypeSelectorSet.isEmpty()){
            sendEmailAlert(errorRecordTypeSelectorSet);
            this.recordTypeSelector = 5;
          }
    }
    
    /**
    * @param  DH_Call_Center_Data_Sheet__c Object
    * @description Creates list of field for a particular denormalized object 
    **/
      public static List<String> createListForSmilarFields(DH_Call_Center_Data_Sheet__c denormalizedObjectnew){
       // here list of similar fields,denormalized objectId, recordtypename - code will be created  and will be sent to respective function
       //to send it for final creation by creation class along with all combination which will be build by rest of two functions;
       Id denormalizedObjectId = denormalizedObjectnew.Id;
       String recordTypeId = denormalizedObjectnew.RecordTypeId;
       String recordTypeName = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosById().get(recordTypeId).getName();
       List<String> listOfSimilarFields = new List<String>();
       if (recordTypeName == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_NAME) {
           String notes = denormalizedObjectnew.DH_Notes_1__c;
           listOfSimilarFields.add(notes);
       }
       if (recordTypeName == DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_NAME) {
           String description = denormalizedObjectnew.DH_Description__c;
           String portalProcedureCode = denormalizedObjectnew.DH_Portal_Procedure_Group_Modality_Code__c;
           String relativePriority = denormalizedObjectnew.DH_Relative_Priority__c;
           String notes = denormalizedObjectnew.DH_Notes_1__c;
           
           listOfSimilarFields.add(description);
           listOfSimilarFields.add(portalProcedureCode);
           listOfSimilarFields.add(relativePriority);
           listOfSimilarFields.add(notes);
       }
       if (recordTypeName == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_NAME) {
                     
           String phone1 = denormalizedObjectnew.DH_Phone_Number_1__c;
           String phone2 = denormalizedObjectnew.DH_Phone_Number_2__c;
           String phone3 = denormalizedObjectnew.DH_Phone_Number_3__c;
           String phone4 = denormalizedObjectnew.DH_Phone_Number_4__c;
           String phone5 = denormalizedObjectnew.DH_Phone_Number_5__c;
           String url1 = denormalizedObjectnew.DH_URL1_to_give_RADAR__c;
           String url2 = denormalizedObjectnew.DH_URL2_to_give_RADAR__c;
           String url3 = denormalizedObjectnew.DH_URL3_to_give_RADAR__c;
           String url4 = denormalizedObjectnew.DH_URL4_to_give_RADAR__c;
           String url5 = denormalizedObjectnew.DH_URL5_to_give_RADAR__c;
           String notes = denormalizedObjectnew.DH_Notes_1__c;
           /*String siteOrCallCenterCode;
           if(denormalizedObjectnew.DH_Site_Code_or_Call_Center_Code__c!=null){
               siteOrCallCenterCode = denormalizedObjectnew.DH_Site_Code_or_Call_Center_Code__c;
           }
           else{
               siteOrCallCenterCode = '';
           }*/
           String callCenterCode = denormalizedObjectnew.DH_Site_Code_or_Call_Center_Code__c;
           listOfSimilarFields.add(phone1);
           listOfSimilarFields.add(phone2);
           listOfSimilarFields.add(phone3);
           listOfSimilarFields.add(phone4);
           listOfSimilarFields.add(phone5);
           listOfSimilarFields.add(url1);
           listOfSimilarFields.add(url2);
           listOfSimilarFields.add(url3);
           listOfSimilarFields.add(url4);
           listOfSimilarFields.add(url5);
           listOfSimilarFields.add(notes);
           listOfSimilarFields.add(callCenterCode);
       }
       if (recordTypeName == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_NAME) {
           Time latestOutreachTime = denormalizedObjectnew.DH_Latest_Time_for_RADAR_Outreach__c;
           String latestOutreach;
           if (latestOutreachTime != null) {
               Datetime dt1 = Datetime.newInstance(Date.today(), latestOutreachTime);
               latestOutreach = dt1.format('HH:mm:ss');
           } else {
               latestOutreach = null;
           }
           Time earliestOutreachTime = denormalizedObjectnew.DH_Earliest_Time_for_RADAR_Outreach__c;
           String earliestOutreach;
           if (earliestOutreachTime != null) {
               Datetime dt2 = Datetime.newInstance(Date.today(), earliestOutreachTime);
               earliestOutreach = dt2.format('HH:mm:ss');
           } else {
               earliestOutreach = null;
           }
           String notes2 = denormalizedObjectnew.DH_Notes_2__c;
           string timeZone = denormalizedObjectnew.DH_timezone__c;
           String notes1 = denormalizedObjectnew.DH_Notes_1__c; //added for notes change
           listOfSimilarFields.add(latestOutreach);
           listOfSimilarFields.add(earliestOutreach);
           listOfSimilarFields.add(notes2);
           listOfSimilarFields.add(timeZone);
           listOfSimilarFields.add(notes1);
       }
       
       //remove all previous data from the lisf of list listof fields an list of similarfields as its sattic and may contain old data;
       return listOfSimilarFields;
    }
    
     public static void sendEmailAlert(Set<Integer> errorRecordTypeSelectorSet){
    			  //Send Email
    			List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String subject ='';
                String plainTextBody ='<body>';
                subject = 'Denormalized Records Publishing Error';
                plainTextBody = 'There is a failure while publishing records. Please click on the links below to review the errors';
				List<String> combineAddressesList =new List<String>();
				for (Denormalization_to_Normalization_Setting__mdt metadataRec : Denormalization_to_Normalization_Setting__mdt.getAll().values()) {
                    if(errorRecordTypeSelectorSet.contains(1)){
                        plainTextBody+='<br/><br/>For Exclusion <a href="'+metadataRec.DH_Exclusions_List_View__c+'">Click Here</a>';
                    }
                      if(errorRecordTypeSelectorSet.contains(2)){
                        plainTextBody+='<br/><br/>For Modality Priority <a href="'+metadataRec.DH_Modality_List_View_URL__c+'">Click Here</a>';
                    }
                      if(errorRecordTypeSelectorSet.contains(3)){
                        plainTextBody+='<br/><br/>For Call center mapping <a href="'+metadataRec.DH_CC_Mapping_List_View_URL__c+'">Click Here</a>';
                    }
                      if(errorRecordTypeSelectorSet.contains(4)){
                        plainTextBody+='<br/><br/>For Call center hours <a href="'+metadataRec.DH_CC_Hours_List_View_URL__c+'">Click Here</a>';
                    }
                    plainTextBody = plainTextBody+'</body>';
				String toAddress = metadataRec.DH_Email_address__c;
                List<String> toAddressesList = toAddress.split(',');
                combineAddressesList.addAll(toAddressesList);
		}
                mail.setToAddresses(combineAddressesList);
                mail.setSubject(subject);
                mail.setHTmlBody(plainTextBody);
                allMails.add(mail);  
            
        if(allMails!=null){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(allMails);   
        }
     }
    
    /**
    * @param  List <DH_Call_Center_Data_Sheet__c> 
    * @description Creates all the required maps for available lookups in the normalized objects and initializes the wrapper of maps
    **/
    
    public static string createRegionCode(String region, String rtName){
    return region + '_' + rtName;
    }
    
    public static string createPracticeCode(String region, String practiceCode, String rtName){
    return region + '_' + practiceCode + '_' + rtName;
    }
    
    public static string createSiteCode(String region, String siteCode, String rtName){
    return region + '_' + siteCode + '_' + rtName;
    }
    
    public static string createCarrierCode(String region, String carrierCode, String rtName){
    return region + '_' + carrierCode + '_' + rtName;
    }
    
    public static string createPhysicianKey(String region, String physicianKey, String rtName){
    return region + '_' + physicianKey;
    }
    
    public static string createReferringPractice(String region, String referringPracticeKey, String rtName){
    return region + '_' + referringPracticeKey + '_' + rtName;
    }
    
    public static string createHealthcareProcedureCode(String region, String healthcareProcedureCode){
    return region + '_' + healthcareProcedureCode;
    }
    
    public static string createCareSpecialtyCode(String region, String careSpecialtyCode){
    return region + '_' + careSpecialtyCode ;
    }
    public static DH_BatchForNormalization.BatchQueryWrapper createMapsFromList(List<DH_Call_Center_Data_Sheet__c> ccdsList){
       Set<String> stringsOfSystem = new Set<String>();
       Set<String> stringsOfPracticeCode =new Set<String>();
       Set<String> stringsOfSiteCode =new Set<String>();
       Set<String> stringsOfModalityProcGroupCode =new Set<String>();
       Set<String> stringsOfProcedureCode =new Set<String>();
       Set<String> stringsOfCarrierCode =new Set<String>();
       Set<String> stringsOfCallCenter =new Set<String>();
       Set<String> stringsOfRefGroupPracticeName=new Set<String>();        
       Set<String> stringsOfRefPracticeId=new Set<String>();
    
       List<String> stringsOfSystemlst= new List<String>();
       List<String> stringsOfPracticeCodelst =new List<String>();
       List<String> stringsOfSiteCodelst =new List<String>();
       List<String> stringsOfModalityProcGroupCodelst =new List<String>();
       List<String> stringsOfProcedureCodelst =new List<String>();
       List<String> stringsOfCarrierCodelst =new List<String>();
       List<String> stringsOfCallCenterlst =new List<String>();
       List<String> stringsOfRefGroupPracticeNamelst=new List<String>();        
       List<String> stringsOfRefPracticeIdlst=new List<String>();
       
       Set<String> stringsOfSystemUniqueCode = new Set<String>();
        Set<String> stringsOfPracticeCodeUniqueCode =new Set<String>();
        Set<String> stringsOfSiteCodeUniqueCode =new Set<String>();
        Set<String> stringsOfModalityProcGroupCodeUniqueCode =new Set<String>();
        Set<String> stringsOfProcedureCodeUniqueCode =new Set<String>();
        Set<String> stringsOfCarrierCodeUniqueCode =new Set<String>();
        Set<String> stringsOfCallCenterUniqueCode =new Set<String>();
        Set<String> stringsOfRefGroupPracticeNameUniqueCode=new Set<String>();        
        Set<String> stringsOfRefPracticeIdUniqueCode=new Set<String>();
    
       //CALL_CENTER_MAPPING_RECORD_TYPE_ID,CALL_CENTER_HOUR_RECORD_TYPE_ID,MODALITY_PRIORITY_RECORD_TYPE_ID,EXCLUSION_RECORD_TYPE_ID,DH_ExclusionDenormalizeGlobalConstants
       for(DH_Call_Center_Data_Sheet__c ccds: ccdsList){
           stringsOfSystemlst.addAll((ccds.DH_System__c != null) ? ccds.DH_System__c.split('[\\s]*,[\\s]*'):new List<String>{''} );
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_ID ||ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
               stringsOfPracticeCodelst.addAll((ccds.DH_Practice_Code__c != null) ? ccds.DH_Practice_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''});
           }
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_ID ||ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
               stringsOfSiteCodelst.addAll((ccds.DH_Site_Code__c != null) ? ccds.DH_Site_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''});
           }
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_ID ||ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID ){
               stringsOfModalityProcGroupCodelst.addAll(( ccds.DH_Modality_Code_aka_Proc_Group_Code__c != null) ? ccds.DH_Modality_Code_aka_Proc_Group_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''});
           }
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
               stringsOfProcedureCodelst.addAll((ccds.DH_Procedure_Code__c != null) ? ccds.DH_Procedure_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''} ); 
           }
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
               stringsOfCarrierCodelst.addAll((ccds.DH_Carrier_Code__c != null) ? ccds.DH_Carrier_Code__c.split('[\\s]*,[\\s]*') :new List<String>{''});
           }
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_ID){
               stringsOfCallCenterlst.addAll(( ccds.DH_Site_Code_or_Call_Center_Code__c != null) ? ccds.DH_Site_Code_or_Call_Center_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''});
           }
           
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID){
               stringsOfCallCenterlst.addAll(( ccds.DH_Fake_call_center_site_code__c != null) ? ccds.DH_Fake_call_center_site_code__c.split('[\\s]*,[\\s]*'):new List<String>{''});
           }                 
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID){
               stringsOfRefGroupPracticeNamelst.addAll((ccds.DH_Ref_Group_Code__c!=null)?ccds.DH_Ref_Group_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''});
           }
           
           if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
               stringsOfRefPracticeIdlst.addAll((ccds.DH_Ref_Dr__c!=null)?ccds.DH_Ref_Dr__c.split('[\\s]*,[\\s]*'):new List<String>{''});
           }
    
       }
        //Creating a set of unique attribute values to be used in queries
       stringsOfSystem.addAll(stringsOfSystemlst);
       stringsOfPracticeCode.addAll(stringsOfPracticeCodelst);
       stringsOfSiteCode.addAll(stringsOfSiteCodelst);
       stringsOfModalityProcGroupCode.addAll(stringsOfModalityProcGroupCodelst);
       stringsOfProcedureCode.addAll(stringsOfProcedureCodelst);
       stringsOfCarrierCode.addAll(stringsOfCarrierCodelst);
       stringsOfCallCenter.addAll(stringsOfCallCenterlst);
       stringsOfRefGroupPracticeName.addAll(stringsOfRefGroupPracticeNamelst); 
       stringsOfRefPracticeId.addAll(stringsOfRefPracticeIdlst);
       
        //Clean the set to remove empty values
       stringsOfSystem.remove('');
       stringsOfPracticeCode.remove('');
       stringsOfSiteCode.remove('');    
       stringsOfModalityProcGroupCode.remove('');
       stringsOfProcedureCode.remove('');
       stringsOfCarrierCode.remove('');
       stringsOfCallCenter.remove('');
       stringsOfRefGroupPracticeName.remove('');
       stringsOfRefPracticeId.remove('');
       
       
        for(String reg : stringsOfSystem){
           stringsOfSystemUniqueCode.add(createRegionCode(reg, DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME));
           for(String practice : stringsOfPracticeCode){
               stringsOfPracticeCodeUniqueCode.add(createPracticeCode(reg, practice, DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME));
           }
           for(String site : stringsOfSiteCode){
               stringsOfSiteCodeUniqueCode.add(createSiteCode(reg, site, DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME));
           }
           for(String carrierCode : stringsOfCarrierCode){
               stringsOfCarrierCodeUniqueCode.add(createCarrierCode(reg, carrierCode, DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_NAME));
           }
           for(String physicianKey : stringsOfRefPracticeId){
               stringsOfRefPracticeIdUniqueCode.add(createPhysicianKey(reg, physicianKey, DH_ExclusionDenormalizeGlobalConstants.REF_DR_PRACTICE_ID_NAME));
           }
           for(String referringPracticeKey : stringsOfRefGroupPracticeName){
               stringsOfRefGroupPracticeNameUniqueCode.add(createReferringPractice(reg, referringPracticeKey, DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME));
           }
           for(String healthcareProcedure : stringsOfProcedureCode){
               stringsOfProcedureCodeUniqueCode.add(createHealthcareProcedureCode(reg, healthcareProcedure));
           }
           for(String modalityCode : stringsOfModalityProcGroupCode){
               stringsOfModalityProcGroupCodeUniqueCode.add(createCareSpecialtyCode(reg, modalityCode));
           }
       }
       
       for(String callCenter : stringsOfCallCenter){
           stringsOfCallCenterUniqueCode.add(callCenter);
       }
       Map<Id,String> regionMapDelete=new Map<Id,String>();
       Map<Id,String> practiceMapDelete = new Map<Id,String>();
       Map<Id,String> siteMapDelete = new Map<Id,String>();
       Map<Id,String> carrierCodePayerAccountMapDelete = new Map<Id,String>();
       Map<Id, String> modalityCodeCareSpecialtyMapDelete= new Map<Id, String>();
       Map<Id,String> callCenterMapDelete = new Map<Id,String>();
       Map<Id,String> procedureCodeHealthCareProcedureMapDelete=new Map<Id,String>();
       Map<Id,String> RefPracticeOrGrpCodeNameDelete = new Map<Id,String>();
       Map<Id,String> RefDrIdDelete = new Map<Id,String>();
       Map<String,Id> regionMapCreation=new Map<String,Id>();
       Map<String,Id> practiceMapCreation = new Map<String,Id>();
       Map<String,Id> siteMapCreation = new Map<String,Id>();
       Map<String,Id> carrierCodePayerAccountMapCreation = new Map<String,Id>();
       Map<String,Id> modalityCodeCareSpecialtyMapCreation= new Map<String,Id>();
       Map<String,Id> callCenterMapCreation = new Map<String,Id>();
       Map<String,Id> procedureCodeHealthCareProcedureMapCreation=new Map<String,Id>();
       Map<String,Id>  RefPracticeOrGrpCodeNameCreation = new Map<String,Id>();
       Map<String,Id>  RefDrIdCreation = new Map<String,Id>();
       for(Account acc : [SELECT Id,RecordType.Name, DH_RIS_Unique_Code__c, Region__c, Site_Code__c, Practice_code__c,Carrier_Code_in_RIS__c ,DH_Referring_Practice_Key__c,DH_Physician_Key__c,DH_Physician_Id__c,DH_Physician_Formula_Id__c
                          FROM Account 
                          WHERE (RecordType.Name=:DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME AND DH_RIS_Unique_Code__c IN :stringsOfSystemUniqueCode) 
                          OR 
                          (RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME AND DH_RIS_Unique_Code__c IN :stringsOfSiteCodeUniqueCode ) 
                          OR
                          (RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_NAME AND DH_RIS_Unique_Code__c IN :stringsOfCarrierCodeUniqueCode)
                          OR
                          (RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME AND DH_RIS_Unique_Code__C IN :stringsOfPracticeCodeUniqueCode)
                          OR
                          (RecordType.Name=:DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME AND DH_RIS_Unique_Code__C IN :stringsOfRefGroupPracticeNameUniqueCode)
                          OR
                          (RecordType.Name=:DH_ExclusionDenormalizeGlobalConstants.REF_DR_PRACTICE_ID_NAME AND DH_Physician_Formula_Id__c IN :stringsOfRefPracticeIdUniqueCode)
                         ])
       {
           Id risRec = DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_ID;
           Id siteRec = DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_ID;
           Id practiceRec = DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_ID;
           Id payerRec = DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_ID;   
           Id refPracticeName=DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_ID;
           Id refDrId=DH_ExclusionDenormalizeGlobalConstants.REF_DR_PRACTICE_ID_ID;
           
           if(acc.DH_RIS_Unique_Code__c!=null && acc.RecordTypeId == risRec ){
               regionMapDelete.put(acc.Id,acc.Region__c);
               regionMapCreation.put(acc.DH_RIS_Unique_Code__c,acc.Id);
           }if(acc.DH_RIS_Unique_Code__c!=null && acc.RecordTypeId == practiceRec){
               practiceMapDelete.put(acc.Id,acc.Practice_code__c);
               practiceMapCreation.put(acc.DH_RIS_Unique_Code__c,acc.Id);
           }if(acc.DH_RIS_Unique_Code__c!=null && acc.RecordTypeId == siteRec ){
               siteMapDelete.put(acc.Id,acc.Site_Code__c);
               siteMapCreation.put(acc.DH_RIS_Unique_Code__c, acc.Id);
           } if(acc.DH_RIS_Unique_Code__c != null && acc.RecordTypeId == payerRec){
               carrierCodePayerAccountMapDelete.put(acc.Id,acc.Carrier_Code_in_RIS__c);
               carrierCodePayerAccountMapCreation.put(acc.DH_RIS_Unique_Code__c,acc.Id);
           }if( acc.DH_RIS_Unique_Code__c !=null && acc.RecordTypeId ==refPracticeName){
               RefPracticeOrGrpCodeNameDelete.put(acc.Id,acc.DH_Referring_Practice_Key__c);
               RefPracticeOrGrpCodeNameCreation.put(acc.DH_RIS_Unique_Code__c,acc.Id);
           }if(acc.DH_Physician_Formula_Id__c!=null && acc.RecordTypeId ==refDrId){
               RefDrIdDelete.put(acc.Id,acc.DH_Physician_Id__c);
               RefDrIdCreation.put(acc.DH_Physician_Formula_Id__c,acc.Id);
           }
       }
       for(CareSpecialty cs: [select Id,DH_SFMC_Speciality_Code__c, SpecialtyCode,CareSpecialty_External_ID__c  from CareSpecialty where RecordType.Name= :DH_ExclusionDenormalizeGlobalConstants.CARE_SPECIALITY_MARKETING_RECORD_TYPE_NAME AND SpecialtyCode IN :stringsOfModalityProcGroupCodeUniqueCode]){
           if(cs.SpecialtyCode!=null){
               modalityCodeCareSpecialtyMapDelete.put(cs.Id,cs.DH_SFMC_Speciality_Code__c );
               modalityCodeCareSpecialtyMapCreation.put(cs.CareSpecialty_External_ID__c , cs.Id);
           }
       }
       for(HealthCareProcedure hp:[select id, Code,DH_RIS_Healthcare_Procedure__c from HealthCareProcedure WHERE DH_RIS_Healthcare_Procedure__c IN :stringsOfProcedureCodeUniqueCode AND RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.HEALTHCARE_PROCEDURE_MARKETING_RECORD_TYPE_NAME]){
           if(hp.DH_RIS_Healthcare_Procedure__c!=null){
               procedureCodeHealthCareProcedureMapDelete.put(hp.Id,hp.Code);
               procedureCodeHealthCareProcedureMapCreation.put(hp.DH_RIS_Healthcare_Procedure__c,hp.Id);
           }
       }
       for(DH_Call_Center__c cc :  [select Name, DH_Call_Center_Code__c from DH_Call_Center__c WHERE DH_Call_Center_Code__c IN :stringsOfCallCenterUniqueCode]){
           if(cc.DH_Call_Center_Code__c!=null){
               callCenterMapDelete.put(cc.Id,cc.DH_Call_Center_Code__c);
               callCenterMapCreation.put(cc.DH_Call_Center_Code__c,cc.Id);
           }
       }
        
       DH_BatchForNormalization.BatchQueryWrapper MapData = new DH_BatchForNormalization.BatchQueryWrapper();
       if(siteMapDelete!=null){
           Mapdata.siteMapDelete = siteMapDelete;
       } if(regionMapDelete!=null){
           Mapdata.regionMapDelete = regionMapDelete;
       } if(practiceMapDelete!=null){
           Mapdata.practiceMapDelete = practiceMapDelete; 
       } if(carrierCodePayerAccountMapDelete!=null){
           Mapdata.carrierCodePayerAccountMapDelete = carrierCodePayerAccountMapDelete;
       } if(modalityCodeCareSpecialtyMapDelete!=null){
           Mapdata.modalityCodeCareSpecialtyMapDelete = modalityCodeCareSpecialtyMapDelete;
       }if(procedureCodeHealthCareProcedureMapDelete!=null){
           Mapdata.procedureCodeHealthCareProcedureMapDelete = procedureCodeHealthCareProcedureMapDelete;
       }if(callCenterMapDelete!=null){
           Mapdata.callCenterMapDelete = callCenterMapDelete;
       }if(RefPracticeOrGrpCodeNameDelete!=null){
           Mapdata.RefPracticeOrGrpCodeNameDelete=RefPracticeOrGrpCodeNameDelete;
       }if(RefDrIdDelete!=null){
           Mapdata.RefDrIdDelete=RefDrIdDelete;
       }
       
        if(siteMapCreation!=null){
           Mapdata.siteMapCreation = siteMapCreation;
       } if(regionMapCreation!=null){
           Mapdata.regionMapCreation = regionMapCreation;
       } if(practiceMapCreation!=null){
               Mapdata.practiceMapCreation = practiceMapCreation;
       } if(carrierCodePayerAccountMapCreation!=null){
           Mapdata.carrierCodePayerAccountMapCreation = carrierCodePayerAccountMapCreation;
       } if(modalityCodeCareSpecialtyMapCreation!=null){
               Mapdata.modalityCodeCareSpecialtyMapCreation = modalityCodeCareSpecialtyMapCreation;
       }if(procedureCodeHealthCareProcedureMapCreation!=null){
              Mapdata.procedureCodeHealthCareProcedureMapCreation = procedureCodeHealthCareProcedureMapCreation;
       }if(callCenterMapCreation!=null){
           Mapdata.callCenterMapCreation = callCenterMapCreation;
       }if(RefPracticeOrGrpCodeNameCreation!=null){
           Mapdata.RefPracticeOrGrpCodeNameCreation=RefPracticeOrGrpCodeNameCreation;
       } 
       if(RefDrIdCreation!=null){
           Mapdata.RefDrIdCreation=RefDrIdCreation;
       }
       return MapData;
    }  
    
    
    
    /**
    * @author Prasanna Anjankar | 20-Jun-2024 
    * @param  DH_Call_Center_Data_Sheet__c Object
    * @description Wrapper for all the required maps for available lookups in the normalized objects
    **/
    global class BatchQueryWrapper {
      global Map<String,Id>  regionMapCreation{get;set;}
      global Map<String,Id>  practiceMapCreation {get;set;}
      global Map<String,Id>  siteMapCreation {get;set;}
      global Map<String,Id>  carrierCodePayerAccountMapCreation {get;set;}
      global Map<String,Id>  modalityCodeCareSpecialtyMapCreation{get;set;}
      global Map<String,Id>  callCenterMapCreation{get;set;}
      global Map<String,Id>  procedureCodeHealthCareProcedureMapCreation{get;set;}
      global Map<String,Id>  RefPracticeOrGrpCodeNameCreation{get;set;}
      global Map<String,Id>  RefDrIdCreation{get;set;}
    
    
      global Map<Id,String>  regionMapDelete{get;set;}
      global Map<Id,String>  practiceMapDelete {get;set;}
      global Map<Id,String>  siteMapDelete {get;set;} 
      global Map<Id,String>  carrierCodePayerAccountMapDelete {get;set;}
      global Map<Id,String>  modalityCodeCareSpecialtyMapDelete{get;set;}
      global Map<Id,String>  callCenterMapDelete{get;set;}
      global Map<Id,String>  procedureCodeHealthCareProcedureMapDelete{get;set;}
      global Map<Id,String>  RefPracticeOrGrpCodeNameDelete{get;set;}
      global Map<Id,String>  RefDrIdDelete{get;set;}
    }
    
    global class normalizedDataWrapper{
      global List<DH_Exclusions__c> exclusionList {get;set;}
      global List<DH_Modality_Priority__c> modalityPriorityList {get;set;}
      global List<DH_Call_Center_Mapping__c> callCenterMappingList {get;set;}
      global List<DH_Call_Center_Hours__c> callCenterHourList {get;set;}
    }
}