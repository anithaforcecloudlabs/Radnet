/*
 
*********************************************************
 
Apex Class         : DH_NormalizedRecordsCreation
 
Created Date       : June , 2024

Updated Date       : 20-June-2024

Code Coverage      : 0%
 
@description       :  Class to create a list of Normalized object records to be created..
 
@jiraid            : CC-283
 
*********************************************************
 
*/
public class DH_NormalizedRecordsCreation {
	  
/**
    * @param Object,String ,List<String> ,List<String>, DH_BatchForNormalization.BatchQueryWrapper Wrapper
    * @description Returns a list of normalized Sobject to be created.
    **/
    public static List<Sobject> createListsOfNormalizedRecordsTobeCreated(DH_Call_Center_Data_Sheet__c denormalizedObject,String recordTypeName,List<String> allComboRecords,List<String> listOfSimilarFields, DH_BatchForNormalization.BatchQueryWrapper mapWrapper) {
        List<Sobject> resultList = new List<Sobject>();
    	Id denormalizedObjectId = denormalizedObject.Id;
        
        Map<String,Id> regionMap=mapWrapper.regionMapCreation;
 		Map<String,Id> practiceMap = mapWrapper.practiceMapCreation;
        Map<String,Id> siteMap = mapWrapper.siteMapCreation;
        Map<String,Id> carrierCodePayerAccountMap =mapWrapper.carrierCodePayerAccountMapCreation;
        
        Map<String,Id> modalityCodeCareSpecialtyMap= mapWrapper.modalityCodeCareSpecialtyMapCreation;
        Map<String,Id> callCenterMap = mapWrapper.callCenterMapCreation;
        Map<String,Id> procedureCodeHealthCareProcedureMap=mapWrapper.procedureCodeHealthCareProcedureMapCreation; 
        
        Map<String,Id> RefPracticeOrGrpCodeNameMap  =mapWrapper.RefPracticeOrGrpCodeNameCreation;
        Map<String,Id> RefDrIdMap =mapWrapper.refDrIdCreation;   
    
    	System.debug('regionMapMap in the Creation class '+ regionMap);
    	System.debug('practiceMap in the Creation class '+ practiceMap);
    	System.debug('siteMap in the Creation class '+ siteMap);
        System.debug('carrierCodePayerAccountMap in the Creation class '+ carrierCodePayerAccountMap);
    	System.debug('modalityCodeCareSpecialtyMap in the Creation class '+ modalityCodeCareSpecialtyMap);
    	System.debug('procedureCodeHealthCareProcedureMap in the Creation class '+ procedureCodeHealthCareProcedureMap);
        System.debug('RefPracticeOrGrpCodeNameMap in the RefPracticeOrGrpCodeNameMap class '+ regionMap);
    	System.debug('RefDrIdMap in the Creation class '+ RefDrIdMap);
    	System.debug('callCenterMap in the Creation class '+ callCenterMap);
        
        if(recordTypeName == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_NAME){
 	    List<DH_Exclusions__c> listOfExclusions= new List<DH_Exclusions__c>();
            for(String combinationRecord: allComboRecords ){
                DH_Exclusions__c exclusion = new DH_Exclusions__c();
                List<String> fieldValueStringList = combinationRecord.split(',');
                System.debug('fieldvaluestring' + fieldValueStringList);
                if(fieldValueStringList[0].length()!=0){
                   // System.debug('System valluleV ' +fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME);
                    if(regionMap.get(fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME)!=null){
                        exclusion.DH_System__c = regionMap.get(fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME);
                    }
                }
                else{
                    exclusion.DH_System__c =null;
                }
                if(fieldValueStringList[1].length()!=0){
                   // System.debug('PRACTICE vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME);
                    if(practiceMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME)!=null){
                        exclusion.DH_Practice_Code__c = practiceMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME);
                    }
                }
                else{
                    exclusion.DH_Practice_Code__c =null;
                }
                if(fieldValueStringList[2].length()!=0){
                   // System.debug('SITE vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[2]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME);
                    if(siteMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[2]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME)!=null){
                        exclusion.DH_Site_Code__c = siteMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[2]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME);
                    }
                }
                else{
                    exclusion.DH_Site_Code__c=null;
                }
                if(fieldValueStringList[3].length()!=0){
                    //System.debug('modalityCodeCareSpecialt value '+ fieldValueStringList[0]+'_'+fieldValueStringList[3]);
                    if(modalityCodeCareSpecialtyMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[3])!=null){
                        exclusion.DH_procedure_group_code__c = modalityCodeCareSpecialtyMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[3]);
                    }
                }
                else{
                    exclusion.DH_procedure_group_code__c=null;  
                }
                if(fieldValueStringList[4].length()!=0){
                    //System.debug('procedureCodeHealthCareProcedure value '+ fieldValueStringList[0]+'_'+fieldValueStringList[4]);
                    if(procedureCodeHealthCareProcedureMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[4])!=null){
                        exclusion.DH_Procedure_Code__c = procedureCodeHealthCareProcedureMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[4]);
                    }
                }
                else{
                    exclusion.DH_Procedure_Code__c=null;
                }
                if(fieldValueStringList[5].length()!=0){
                    //System.debug('carrierCodePayer '+ fieldValueStringList[0]+'_'+fieldValueStringList[5]+'_'+DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_NAME);
                    if(carrierCodePayerAccountMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[5]+'_'+DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_NAME)!=null){
                        exclusion.DH_Carrier_Code__c = carrierCodePayerAccountMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[5]+'_'+DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_NAME);
                    }
                }
                else{
                    exclusion.DH_Carrier_Code__c = null;
                }
				if(fieldValueStringList[6].length()!=0){
                    //System.debug('RefPracticeOrGrpCodeNameMap '+ fieldValueStringList[0]+'_'+fieldValueStringList[6]+'_'+DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME);
                    if(RefPracticeOrGrpCodeNameMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[6]+'_'+DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME)!=null){
                        exclusion.DH_Referring_Group_Code__c = RefPracticeOrGrpCodeNameMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[6]+'_'+DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME);
                    }
                }
                else{
                    exclusion.DH_Referring_Group_Code__c = null;
                }
				if(fieldValueStringList[7].length()!=0){
                    // System.debug('RefDrId '+ fieldValueStringList[0]+'_'+fieldValueStringList[7]+'_'+DH_ExclusionDenormalizeGlobalConstants.REF_DR_PRACTICE_ID_NAME);
                    if(RefDrIdMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[7])!=null){
                        exclusion.DH_referring_id__c = RefDrIdMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[7]);
                    }
                }
                else{
                    exclusion.DH_referring_id__c = null;
                }                
                exclusion.DH_Order_Nrf__c = fieldValueStringList[8];
                exclusion.DH_CallCenterDataSheet__c = denormalizedObjectId;
                exclusion.DH_Notes__c = listOfSimilarFields[0];
//not consideering notes for unique key
                exclusion.DH_UniqueKey__c=combinationRecord;
                    
                listOfExclusions.add(exclusion);
            }
			resultList.addAll(listOfExclusions) ;           
        }
        if(recordTypeName == DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_NAME){
            List<DH_Modality_Priority__c> listOfModalityPriority= new List<DH_Modality_Priority__c>();

            for(String combinationRecord: allComboRecords ){
                DH_Modality_Priority__c modalityPriority = new DH_Modality_Priority__c();
                List<String> fieldValueStringList = combinationRecord.split(',');
                if(fieldValueStringList[0].length()!=0){
                   // System.debug('System valluleV ' +fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME);
                    if(regionMap.get(fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME)!=null){
                        modalityPriority.DH_System__c= regionMap.get(fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME);
                    }
                }
                else{
                    modalityPriority.DH_System__c= null;
                }
                if(fieldValueStringList[1].length()!=0){
                   // System.debug('carespeciality ' +fieldValueStringList[0]+'_'+fieldValueStringList[1]);
                    if(modalityCodeCareSpecialtyMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[1])!=null){
                        modalityPriority.DH_procedure_group_code__c=modalityCodeCareSpecialtyMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[1]);
                    }
                }
                else{
                    modalityPriority.DH_procedure_group_code__c=null;
                }
                
                modalityPriority.DH_CallCenterDataSheet__c = denormalizedObjectId;
                modalityPriority.DH_Description__c=listOfSimilarFields[0];
                modalityPriority.DH_Portal_Procedure_Group_Modality_Code__c=listOfSimilarFields[1];
                if(listOfSimilarFields[2]!=null){
                    modalityPriority.DH_Relative_Priority__c=integer.valueof(listOfSimilarFields[2]);
                }
                else {
                    modalityPriority.DH_Relative_Priority__c=null;
                }
                modalityPriority.DH_Notes__c=listOfSimilarFields[3];
   
                //not considering description and notes for the unique key
                if((combinationRecord).length()>255){
                          modalityPriority.DH_UniqueKey__c = (combinationRecord).substring(0,255);
                    }
                    else{ 
                        modalityPriority.DH_UniqueKey__c = combinationRecord;
                    }
                
            //    modalityPriority.DH_UniqueKey__c = combinationRecord + uniqueKey;
                listOfModalityPriority.add(modalityPriority);
            }
            resultList.addAll(listOfModalityPriority);

            }
        if(recordTypeName == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_NAME){
		  List<DH_Call_Center_Mapping__c> listOfCallCenterMapping= new List<DH_Call_Center_Mapping__c>();
            for(String combinationRecord: allComboRecords ){
                DH_Call_Center_Mapping__c callCenterMapping = new DH_Call_Center_Mapping__c();
                List<String> fieldValueStringList = combinationRecord.split(',');
                if(fieldValueStringList[0].length()!=0){
                    //System.debug('System valluleV ' +fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME);
                    if(regionMap.get(fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME)!=null){
                        callCenterMapping.DH_System__c= regionMap.get(fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME);
                    }
                }
                else{
                    callCenterMapping.DH_System__c= null;
                }
                if(fieldValueStringList[1].length()!=0){
                    // System.debug('PRACTICE vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME);
                    if(practiceMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME)!=null){
                        callCenterMapping.DH_Practice_Code__c=practiceMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME);
                    }
                }
                else {
                    callCenterMapping.DH_Practice_Code__c=null;
                }
                if(fieldValueStringList[2].length()!=0){
                    //System.debug('SITE vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[2]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME);
                    if(siteMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[2]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME)!=null){
                        callCenterMapping.DH_Site_Code__c=siteMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[2]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME);
                    }
                }
                else{
                    callCenterMapping.DH_Site_Code__c=null;
                }
                callCenterMapping.DH_ZIP__c=fieldValueStringList[3];
                if(fieldValueStringList[4].length()!=0){
                    //System.debug('modalityCodeCareSpecialty vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[4]);
                    if(modalityCodeCareSpecialtyMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[4])!=null){
                        callCenterMapping.DH_Modality_Code__c=modalityCodeCareSpecialtyMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[4]);
                    }
                }
                else{
                    callCenterMapping.DH_Modality_Code__c=null;
                }
                if(fieldValueStringList[5].length()!=0){
                    //System.debug('procedureCodeHealthCareProcedure vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[5]);
                    if(procedureCodeHealthCareProcedureMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[5])!=null){
                        callCenterMapping.DH_Procedure_Code__c=procedureCodeHealthCareProcedureMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[5]);
                    }
                }
                else{
                    callCenterMapping.DH_Procedure_Code__c=null;
                }
                if(fieldValueStringList[6].length()!=0){
                    if(callCenterMap.get(fieldValueStringList[6])!=null){
                        callCenterMapping.DH_Fake_call_center_site_code_Lookup__c = callCenterMap.get(fieldValueStringList[6]);
                    }
                }
                else{
                    callCenterMapping.DH_Fake_call_center_site_code_Lookup__c = null;
                }
		
                if(fieldValueStringList[7].length()!=0){
                    //System.debug('RefPracticeOrGrpCode vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[7]+'_'+DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME);
                    if(RefPracticeOrGrpCodeNameMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[7]+'_'+DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME)!=null){
                        callCenterMapping.DH_Referring_Group_Code__c=RefPracticeOrGrpCodeNameMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[7]+'_'+DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME);
                    }
                }
                else{
                    callCenterMapping.DH_Referring_Group_Code__c=null;
                }
                
                callCenterMapping.DH_CallCenterDataSheet__c = denormalizedObjectId;
                callCenterMapping.DH_Phone_Number_1__c=listOfSimilarFields[0];
                callCenterMapping.DH_Phone_Number_2__c=listOfSimilarFields[1];
                callCenterMapping.DH_Phone_Number_3__c=listOfSimilarFields[2];
                callCenterMapping.DH_Phone_Number_4__c=listOfSimilarFields[3];
                callCenterMapping.DH_Phone_Number_5__c=listOfSimilarFields[4];
                callCenterMapping.DH_URL1_to_give_RADAR__c=listOfSimilarFields[5];
                callCenterMapping.DH_URL2_to_give_RADAR__c=listOfSimilarFields[6];
                callCenterMapping.DH_URL3_to_give_RADAR__c=listOfSimilarFields[7];
                callCenterMapping.DH_URL4_to_give_RADAR__c=listOfSimilarFields[8];
                callCenterMapping.DH_URL5_to_give_RADAR__c=listOfSimilarFields[9];
                callCenterMapping.DH_Notes__c=listOfSimilarFields[10];
                callCenterMapping.DH_Site_Code_or_Call_Center_Code__c=listOfSimilarFields[11];
                
                if((combinationRecord).length()>255){
                       callCenterMapping.DH_UniqueKey__c = (combinationRecord).substring(0,255);
                    }
                else{
                	callCenterMapping.DH_UniqueKey__c = combinationRecord;
                }
                listOfCallCenterMapping.add(callCenterMapping);
            }
             resultList.addAll(listOfCallCenterMapping);  
        }
        if(recordTypeName == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_NAME) {
		  List<DH_Call_Center_Hours__c> listOfCallCenterHour = new List<DH_Call_Center_Hours__c>();
            List<DH_Call_Center_Hours__c> recordsToInsert = new List<DH_Call_Center_Hours__c>(); // Bulk insert records
            for(String combinationRecord : allComboRecords) {
                DH_Call_Center_Hours__c callCenterHour = new DH_Call_Center_Hours__c();
                List<String> fieldValueStringList = combinationRecord.split(',');
                if(fieldValueStringList.size() >= 9) {
                    if(regionMap != null && regionMap.containsKey(fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME)) {
                        //System.debug('System valluleV ' +fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME);
                        callCenterHour.DH_System__c = regionMap.get(fieldValueStringList[0]+'_'+DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME);
                    }
                    if(practiceMap != null && practiceMap.containsKey(fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME)) {
                       // System.debug('PRACTICE vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME);
                        callCenterHour.DH_Practice_Code__c = practiceMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[1]+'_'+DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME);
                    }
                    if(callCenterMap != null && callCenterMap.containsKey(fieldValueStringList[2])) {
                        callCenterHour.DH_Call_Center_Code_Lookup__c = callCenterMap.get(fieldValueStringList[2]);
                    }
                    if(siteMap != null && siteMap.containsKey(fieldValueStringList[0]+'_'+fieldValueStringList[3]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME)) {
                       //System.debug('SITE vallule ' +fieldValueStringList[0]+'_'+fieldValueStringList[3]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME);
                       callCenterHour.DH_Site_Code__c = siteMap.get(fieldValueStringList[0]+'_'+fieldValueStringList[3]+'_'+DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME);
                    }
                    callCenterHour.DH_Day_of_Week__c = fieldValueStringList[4];
                    callCenterHour.DH_Specific_Date__c = (fieldValueStringList[5].length() > 0) ? convertDateMMDDYYYtoYYYMMDD(fieldValueStringList[5]) : null;
    //removed for notes changes//                  callCenterHour.DH_Notes1__c = fieldValueStringList[6];
                    callCenterHour.DH_Contact_Method__c = fieldValueStringList[6];
                    callCenterHour.DH_iCode__c = fieldValueStringList[7];
                    callCenterHour.DH_CallCenterDataSheet__c = denormalizedObjectId;
                    callCenterHour.DH_Latest_Time_for_RADAR_Outreach__c = (listOfSimilarFields.size() > 0 && listOfSimilarFields[0] != null) ? stringToTime(listOfSimilarFields[0]) : null;
                    callCenterHour.DH_Earliest_Time_for_RADAR_Outreach__c = (listOfSimilarFields.size() > 1 && listOfSimilarFields[1] != null) ? stringToTime(listOfSimilarFields[1]) : null;
                    callCenterHour.DH_Notes2__c = (listOfSimilarFields.size() > 2 && listOfSimilarFields[2] != null) ? listOfSimilarFields[2] : null;
                    callCenterHour.DH_timezone__c = (listOfSimilarFields.size() > 3 && listOfSimilarFields[3] != null) ? listOfSimilarFields[3] : null;
                    callCenterHour.DH_Notes1__c = (listOfSimilarFields.size() > 4 && listOfSimilarFields[4] != null) ? listOfSimilarFields[4] : null;

                   /* if((combinationRecord +'#-#'+ listOfSimilarFields[0]+listOfSimilarFields[1]+listOfSimilarFields[3]).length()>255){
                         callCenterHour.DH_UniqueKey__c = (combinationRecord +'#-#'+ listOfSimilarFields[0]+listOfSimilarFields[1]+listOfSimilarFields[3]).substring(0,255);
                    }
                    else{
                        callCenterHour.DH_UniqueKey__c = combinationRecord +'#-#'+ listOfSimilarFields[0]+listOfSimilarFields[1]+listOfSimilarFields[3];
                    }*/
                    
                      if((combinationRecord).length()>255){
                         callCenterHour.DH_UniqueKey__c = (combinationRecord).substring(0,255);
                    }
                    else{
                        callCenterHour.DH_UniqueKey__c = combinationRecord;
                    }
                    listOfCallCenterHour.add(callCenterHour);
                }
            }
			resultList.addAll(listOfCallCenterHour);  
        }
        return resultList;
        
    }
    
    	  /**
    * @param String 
    * @description Convet String to time
    **/
    public static Time stringToTime(String timeString){
        List<String> timeParts = timeString.split(':');
        Integer hours= Integer.valueOf(timeParts[0]);
        Integer minutes= Integer.valueOf(timeParts[1]);
        Integer seconds= Integer.valueOf(timeParts[2]);
        return Time.newInstance(hours, minutes, seconds, 0);
    }

    	  /**
    * @param String 
    * @description MM/DD/YYY to yyyy-MM-dd HH:mm:ss for date.parse.
    **/
   
    public static Date convertDateMMDDYYYtoYYYMMDD(String dateString){
        List<String> initialDateStr = dateString.split('/');
        String finalDate = initialDateStr[2] +'-'+ initialDateStr[0] +'-'+ initialDateStr[1] ;
        return Date.valueOf(finalDate);
    }



}