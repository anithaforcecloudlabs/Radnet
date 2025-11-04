/******************************************************************************************************************************************************
 * 
 * Apex Controller : DH_ExclusionDenormalizeCheckDuplicates
 * 
 * Created Date    : 20/06/2024
 * 
 * @description    : This method checks duplicacy of the denormalized records before inserting
 * 
 * @JIRA Id        : CC-283
 * 
 * */

public without sharing class DH_ExclusionDenormalizeCheckDuplicates {
    
    // This method is used to create a String so as to check all the fields
    public static String createString(SObject ccds, List<String> fieldList){
        String finalStr = '';
        try{
            if(fieldList.size() > 0){
                for(String fieldName : fieldList){
                    Object fieldValue = ccds.get(fieldName);
                    if(fieldValue != null){
                        finalStr += String.valueOf(fieldValue).removeEnd(',') + ',';
                    }
                }
                finalStr = finalStr.removeEnd(',');
            }
        }
        catch(Exception e){
            finalStr = e.getMessage();
        }
        return finalStr;
    }

    // This methods creates call center data sheet to be used in check duplicates method
    public static List<DH_Call_Center_Data_Sheet__c> createCallCenterDataSheetList(List<DH_Call_Center_Data_Sheet__c> allCallCenterDataSheet, String recordTypeName, String denormalizedObjectId){
        List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
        for(DH_Call_Center_Data_Sheet__c rec : allCallCenterDataSheet){
            if(rec.RecordType.Name == recordTypeName && rec.Id != denormalizedObjectId){
                ccdsList.add(rec);
            }
        }
        return ccdsList;
    }

    // This method is just a helper method which loops over the data sheet list and checks if there is a string equal to newObjectString
    public static Boolean duplicateCheckHelper(List<DH_Call_Center_Data_Sheet__c> ccdsList, DH_Call_Center_Data_Sheet__c ccds, String newObjectString, List<String> fieldList){
        System.debug('newObjectString'+newObjectString);
		for(DH_Call_Center_Data_Sheet__c ccdsObj: ccdsList){
            String tempString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccdsObj, fieldList);
            System.debug('oldObjectString'+tempString);
            System.debug(newObjectString.equals(tempString));
            if(newObjectString.equals(tempString)){
                ccds.addError('Duplicate record Exists');
                return false;
            }
        }
        return true;
    }

    // this methods returns a boolean depending on whether there is a duplicate or not 
	public static Boolean exclusionDenormalizeCheckIfDuplicates(List<DH_Call_Center_Data_Sheet__c> triggerNew) {
        List<DH_Call_Center_Data_Sheet__c> allCallCenterDataSheet = [SELECT DH_Carrier_Code__c,DH_Contact_Method__c,
                            DH_Day_of_Week__c,DH_Description__c, DH_Earliest_Time_for_RADAR_Outreach__c,
                            DH_Fake_call_center_site_code__c, DH_Latest_Time_for_RADAR_Outreach__c,
                            DH_Modality_Code_aka_Proc_Group_Code__c,DH_Notes_1__c,DH_Notes_2__c,DH_iCode__c,
                            DH_Phone_Number_1__c,DH_Phone_Number_2__c, DH_Phone_Number_3__c,DH_Phone_Number_4__c,DH_Ref_Dr__c,
                            DH_Phone_Number_5__c, DH_Portal_Procedure_Group_Modality_Code__c,DH_Practice_Code__c,
                            DH_Procedure_Code__c, DH_Ref_Group_Code__c,DH_Relative_Priority__c, DH_New_or_Re_Schedule__c,
                            DH_Site_Code_or_Call_Center_Code__c,DH_Site_Code__c, DH_Specific_Date__c,DH_System__c,
                            DH_timezone__c, DH_URL1_to_give_RADAR__c,DH_URL2_to_give_RADAR__c, DH_URL3_to_give_RADAR__c,
                            DH_URL4_to_give_RADAR__c, DH_URL5_to_give_RADAR__c, DH_ZIP__c, Id, Name, RecordTypeId, RecordType.Name
                            FROM DH_Call_Center_Data_Sheet__c];
    	for(DH_Call_Center_Data_Sheet__c ccds : triggerNew){
    		ID denormalizedObjectId = ccds.Id;
     		String recordTypeName = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosById().get(ccds.RecordTypeId).getName();
     		if(recordTypeName != '' && recordTypeName != null){
                if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_NAME){
                    try{
                        List<DH_Call_Center_Data_Sheet__c> ccdsList = DH_ExclusionDenormalizeCheckDuplicates.createCallCenterDataSheetList(allCallCenterDataSheet, recordTypeName, denormalizedObjectId);
                        
                        List<String> fieldList = new List<String>{'DH_Ref_Group_Code__c','DH_Carrier_Code__c','DH_System__c','DH_Site_Code__c','DH_Practice_Code__c','DH_Procedure_Code__c','DH_Modality_Code_aka_Proc_Group_Code__c','DH_Ref_Dr__c','DH_New_or_Re_Schedule__c','DH_Notes_1__c'};
                        String newObjectString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccds, fieldList);
                        if(duplicateCheckHelper(ccdsList, ccds, newObjectString, fieldList) == false){
                            return false;
                        }
                        // for(DH_Call_Center_Data_Sheet__c ccdsObj: ccdsList){
                        //     String tempString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccdsObj, new List<String>{'DH_Relative_Priority__c', 'DH_Notes_1__c', 'DH_System__c', 'DH_Portal_Procedure_Group_Modality_Code__c', 'DH_Modality_Code_aka_Proc_Group_Code__c', 'DH_Description__c'});
                        //     if(newObjectString.equals(tempString)){
                        //         ccds.addError('Duplicate record Exists');
                        //         return false;
                        //     }
                        // }
                    }
                    catch(DMLException e){
                        System.debug('Duplicate Record Found Cant create new record');
                    }
                }
                else if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_NAME){
                    try{
                        List<DH_Call_Center_Data_Sheet__c> ccdsList = DH_ExclusionDenormalizeCheckDuplicates.createCallCenterDataSheetList(allCallCenterDataSheet, recordTypeName, denormalizedObjectId);
                     
                        List<String> fieldList = new List<String>{'DH_Relative_Priority__c', 'DH_Notes_1__c', 'DH_System__c', 'DH_Portal_Procedure_Group_Modality_Code__c', 'DH_Modality_Code_aka_Proc_Group_Code__c', 'DH_Description__c'};
                        String newObjectString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccds, fieldList);
                        if(duplicateCheckHelper(ccdsList, ccds, newObjectString, fieldList) == false){
                            return false;
                        }
                        // for(DH_Call_Center_Data_Sheet__c ccdsObj: ccdsList){
                        //     String tempString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccdsObj, new List<String>{'DH_Relative_Priority__c', 'DH_Notes_1__c', 'DH_System__c', 'DH_Portal_Procedure_Group_Modality_Code__c', 'DH_Modality_Code_aka_Proc_Group_Code__c', 'DH_Description__c'});
                        //     if(newObjectString.equals(tempString)){
                        //         ccds.addError('Duplicate record Exists');
                        //         return false;
                        //     }
                        // }
                    }
                    catch(DMLException e){
                        System.debug('Duplicate Record Found Cant create new record');
                    }
                 
                }
                else if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_NAME){
                    try{
                        List<DH_Call_Center_Data_Sheet__c> ccdsList = DH_ExclusionDenormalizeCheckDuplicates.createCallCenterDataSheetList(allCallCenterDataSheet, recordTypeName, denormalizedObjectId);
                        
                        List<String> fieldList = new List<String>{'DH_Notes_1__c','DH_Modality_Code_aka_Proc_Group_Code__c', 'DH_ZIP__c', 'DH_System__c', 'DH_Practice_Code__c', 'DH_Procedure_Code__c', 'DH_Site_Code__c', 'DH_Site_Code_or_Call_Center_Code__c', 'DH_Fake_call_center_site_code__c', 'DH_Ref_Group_Code__c', 'DH_Phone_Number_1__c', 'DH_Phone_Number_2__c', 'DH_Phone_Number_3__c', 'DH_Phone_Number_4__c', 'DH_Phone_Number_5__c', 'DH_URL1_to_give_RADAR__c', 'DH_URL2_to_give_RADAR__c', 'DH_URL3_to_give_RADAR__c', 'DH_URL4_to_give_RADAR__c', 'DH_URL5_to_give_RADAR__c'};
                        String newObjectString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccds, fieldList);   
                        if(duplicateCheckHelper(ccdsList, ccds, newObjectString, fieldList) == false){
                            return false;
                        }
                        // for(DH_Call_Center_Data_Sheet__c ccdsObj: ccdsList){
                        //     String tempString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccdsObj, new List<String>{'DH_Modality_Code_aka_Proc_Group_Code__c', 'DH_Notes_1__c', 'DH_ZIP__c', 'DH_System__c', 'DH_Practice_Code__c', 'DH_Procedure_Code__c', 'DH_Site_Code__c', 'DH_Site_Code_or_Call_Center_Code__c', 'DH_Fake_call_center_site_code__c', 'DH_Ref_Group_Code__c', 'DH_Phone_Number_1__c', 'DH_Phone_Number_2__c', 'DH_Phone_Number_3__c', 'DH_Phone_Number_4__c', 'DH_Phone_Number_5__c', 'DH_URL1_to_give_RADAR__c', 'DH_URL2_to_give_RADAR__c', 'DH_URL3_to_give_RADAR__c', 'DH_URL4_to_give_RADAR__c', 'DH_URL5_to_give_RADAR__c'});   
                        //     if(newObjectString.equals(tempString)){
                        //         ccds.addError('Duplicate record Exists');
                        //         return false;
                        //     }
                        // }
                    }
                    catch(DMLException e){
                        System.debug('Duplicate Record Found Cant create new record');
                    }
                }
                else if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_NAME){
                    try{
                        List<DH_Call_Center_Data_Sheet__c> ccdsList = DH_ExclusionDenormalizeCheckDuplicates.createCallCenterDataSheetList(allCallCenterDataSheet, recordTypeName, denormalizedObjectId);
                        
                        List<String> fieldList = new List<String>{'DH_Notes_1__c','DH_iCode__c','DH_Earliest_Time_for_RADAR_Outreach__c', 'DH_Specific_Date__c', 'DH_Site_Code_or_Call_Center_Code__c', 'DH_System__c', 'DH_Day_of_Week__c', 'DH_timezone__c', 'DH_Notes_2__c', 'DH_Latest_Time_for_RADAR_Outreach__c', 'DH_Contact_Method__c', 'DH_Practice_Code__c', 'DH_Site_Code__c'};
                        String newObjectString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccds, fieldList);
                        if(duplicateCheckHelper(ccdsList, ccds, newObjectString, fieldList) == false){
                            return false;
                        }
                        // for(DH_Call_Center_Data_Sheet__c ccdsObj: ccdsList){
                        //     String tempString = DH_ExclusionDenormalizeCheckDuplicates.createString(ccdsObj, new List<String>{'DH_Notes_1__c', 'DH_Earliest_Time_for_RADAR_Outreach__c', 'DH_Specific_Date__c', 'DH_Site_Code_or_Call_Center_Code__c', 'DH_System__c', 'DH_Day_of_Week__c', 'DH_Notes_2__c', 'DH_Latest_Time_for_RADAR_Outreach__c', 'DH_Contact_Method__c', 'DH_Practice_Code__c', 'DH_timezone__c', 'DH_Site_Code__c'});
                        //     if(newObjectString.equals(tempString)){
                        //         ccds.addError('Duplicate record Exists');
                        //         return false;
                        //     }
                        // }
                    }
                    catch(DMLException e){
                        System.debug('Duplicate Record Found Cant create new record');
                    }
                    
                }
            }
            
        }
        return true;
    }

}