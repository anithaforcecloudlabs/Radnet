/*
 
*********************************************************
 
Apex Class         : DH_CreateCombinationDenormalizedRecord
 
Created Date       : June , 2024

Updated Date       : 20-June-2024

Code Coverage      : 0%
 
@description       : Class to create a  list of combination for mult fields of denormalized objects.
 
@jiraid            : CC-283
 
*********************************************************
 
*/
public class DH_CreateCombinationDenormalizedRecord {     
    public static List<List<String>> listOfFields = new List<List<String>>();
        
        public static Integer lengthOfListOfFields;
    
                 /**
        * @param Object 
        * @description Compile all the values of mult fields of denormalized object and call a function to create combination
        **/
        public static List<String>  compileMultFieldsAndCreateCombination(DH_Call_Center_Data_Sheet__c denormalizedObject) {
            ID denormalizedObjectId = denormalizedObject.Id;
            String recordTypeId= denormalizedObject.RecordTypeId;
            String recordTypeName = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosById().get(recordTypeId).getName();
            
            if(recordTypeName == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_NAME){    
                List<String> stringsOfSystem =(denormalizedObject.DH_System__c!=null)?denormalizedObject.DH_System__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfPracticeCode =(denormalizedObject.DH_Practice_Code__c!=null)?denormalizedObject.DH_Practice_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfSiteCode =(denormalizedObject.DH_Site_Code__c!=null)?denormalizedObject.DH_Site_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfModalityProcGroupCode =(denormalizedObject.DH_Modality_Code_aka_Proc_Group_Code__c!=null)?denormalizedObject.DH_Modality_Code_aka_Proc_Group_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfProcedureCode  =(denormalizedObject.DH_Procedure_Code__c!=null)?denormalizedObject.DH_Procedure_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfCarrierCode =(denormalizedObject.DH_Carrier_Code__c!=null)?denormalizedObject.DH_Carrier_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfRefGroupCode =(denormalizedObject.DH_Ref_Group_Code__c!=null)?denormalizedObject.DH_Ref_Group_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfRefDr =(denormalizedObject.DH_Ref_Dr__c!=null)?denormalizedObject.DH_Ref_Dr__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfNewOrRes =(denormalizedObject.DH_New_or_Re_Schedule__c!=null)?denormalizedObject.DH_New_or_Re_Schedule__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringOfName = new List<String>{'end'};
                /*if(denormalizedObject.Name!=null){
                    stringOfName.add(denormalizedObject.Name);
                }*/
                
                listOfFields.add(stringsOfSystem);
                listOfFields.add(stringsOfPracticeCode);
                listOfFields.add(stringsOfSiteCode);
                listOfFields.add(stringsOfModalityProcGroupCode);
                listOfFields.add(stringsOfProcedureCode);
                listOfFields.add(stringsOfCarrierCode);
                listOfFields.add(stringsOfRefGroupCode);
                listOfFields.add(stringsOfRefDr);
                listOfFields.add(stringsOfNewOrRes);
                listOfFields.add(stringOfName);            
            }
    
            if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_NAME){           
                List<String> stringsOfSystem =(denormalizedObject.DH_System__c!=null)?denormalizedObject.DH_System__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfModalityProcGroupCode =(denormalizedObject.DH_Modality_Code_aka_Proc_Group_Code__c!=null)?denormalizedObject.DH_Modality_Code_aka_Proc_Group_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringOfName = new List<String>{'end'};
              /*  if(denormalizedObject.Name!=null){
                    stringOfName.add(denormalizedObject.Name);
                }*/
                
                listOfFields.add(stringsOfSystem);
                listOfFields.add(stringsOfModalityProcGroupCode);
                listOfFields.add(stringOfName);            
            }
    
    
            if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_NAME){           
                List<String> stringsOfSystem =(denormalizedObject.DH_System__c!=null)?denormalizedObject.DH_System__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfPracticeCode =(denormalizedObject.DH_Practice_Code__c!=null)?denormalizedObject.DH_Practice_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfSiteCode =(denormalizedObject.DH_Site_Code__c!=null)?denormalizedObject.DH_Site_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfZipCode =(denormalizedObject.DH_ZIP__c!=null)?denormalizedObject.DH_ZIP__c.split('[\\s]*,[\\s]*'):new List<String>{''};//new Added
                List<String> stringsOfModalityCode =(denormalizedObject.DH_Modality_Code_aka_Proc_Group_Code__c!=null)?denormalizedObject.DH_Modality_Code_aka_Proc_Group_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfProcedureCode  =(denormalizedObject.DH_Procedure_Code__c!=null)?denormalizedObject.DH_Procedure_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfFakeCallCenter = (denormalizedObject.DH_Fake_call_center_site_code__c!=null)?denormalizedObject.DH_Fake_call_center_site_code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfRefPracticeName =(denormalizedObject.DH_Ref_Group_Code__c!=null)?denormalizedObject.DH_Ref_Group_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringOfName = new List<String>{'end'};
              /*  if(denormalizedObject.Name!=null){
                    stringOfName.add(denormalizedObject.Name);
                }*/
    
                listOfFields.add(stringsOfSystem);
                listOfFields.add(stringsOfPracticeCode);
                listOfFields.add(stringsOfSiteCode);
                listOfFields.add(stringsOfZipCode);
                listOfFields.add(stringsOfModalityCode);
                listOfFields.add(stringsOfProcedureCode);
                listOfFields.add(stringsOfFakeCallCenter);
                listOfFields.add(stringsOfRefPracticeName);
                listOfFields.add(stringOfName);
            }
    
    
    
            if(recordTypeName==DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_NAME){
                List<String> stringsOfSystem =(denormalizedObject.DH_System__c!=null)?denormalizedObject.DH_System__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfPracticeCode =(denormalizedObject.DH_Practice_Code__c!=null)?denormalizedObject.DH_Practice_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfCallCenterCode =(denormalizedObject.DH_Site_Code_or_Call_Center_Code__c!=null)?denormalizedObject.DH_Site_Code_or_Call_Center_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfSiteCode =(denormalizedObject.DH_Site_Code__c!=null)?denormalizedObject.DH_Site_Code__c.split('[\\s]*,[\\s]*'):new List<String>{''};
                List<String> stringsOfDaysOfWeek =(denormalizedObject.DH_Day_of_Week__c!=null)?denormalizedObject.DH_Day_of_Week__c.split(';'):new List<String>{''}; 
                List<String> stringsOfSpecificDate =(denormalizedObject.DH_Specific_Date__c!=null)?denormalizedObject.DH_Specific_Date__c.split('[\\s]*,[\\s]*'):new List<String>{''};            
  //Reoved for notes//              List<String> stringsOfNotes1 =(denormalizedObject.DH_Notes_1__c!=null)?denormalizedObject.DH_Notes_1__c.split('[\\s]*,[\\s]*'):new List<String>{''}; 
                List<String> stringsOfContactMethod =(denormalizedObject.DH_Contact_Method__c!=null)?denormalizedObject.DH_Contact_Method__c.split('[\\s]*,[\\s]*'):new List<String>{''}; 
                List<String> stringsOfIcodepPreference =(denormalizedObject.DH_iCode__c!=null)?denormalizedObject.DH_iCode__c.split('[\\s]*,[\\s]*'):new List<String>{''}; 
                List<String> stringOfName = new List<String>{'end'};
    
              /*  if(denormalizedObject.Name!=null){
                    stringOfName.add(denormalizedObject.Name);
                }*/
                
                listOfFields.add(stringsOfSystem);
                listOfFields.add(stringsOfPracticeCode);
                listOfFields.add(stringsOfCallCenterCode);
                listOfFields.add(stringsOfSiteCode);
                listOfFields.add(stringsOfDaysOfWeek);
                listOfFields.add(stringsOfSpecificDate);
              //  listOfFields.add(stringsOfNotes1);
                listOfFields.add(stringsOfContactMethod);
                listOfFields.add(stringsOfIcodepPreference);
                listOfFields.add(stringOfName);
            }
    
            lengthOfListOfFields = listOfFields.size()-1;
            List<String> allCombinationfinal = new List<String>();
            if(listOfFields.size()>1){
                allCombinationfinal = createCombination(listOfFields[0],listOfFields[1]);
            }
            //remove all previous data from the lisf of list listof fields an list of similarfields as its sattic and may contain old data;
            listOfFields.clear();
            Set<String> allCombinationSet= new Set<String>();
 			allCombinationSet.addAll(allCombinationfinal);
 			allCombinationfinal.clear();
 			allCombinationfinal.addAll(allCombinationSet);
            return allCombinationfinal;
        }
    
    
    
    
        public static Integer numberOfRecurciveCalls =1;
                 /**
        * @param  List<String>,List<String>
        * @description Recursive function to create all possible unique combinations of the mult fields and return final al combination list
        **/
        public static List<String> createCombination(List<String> list1, List<String> list2){
            List<String> allCombinationfinal =new List<String>();        
            //return the final combination list
            if(numberOfRecurciveCalls==lengthOfListOfFields+1){
                    numberOfRecurciveCalls=1;
                    return list1;
                }
            for(String s1 : list1){
                for(String s2 : list2){
                    allCombinationfinal.add(s1.trim() + ','+s2.trim());
                }
            }
            numberOfRecurciveCalls=numberOfRecurciveCalls+1;
            if(numberOfRecurciveCalls<=lengthOfListOfFields){
                return createCombination(allCombinationfinal,listOfFields[numberOfRecurciveCalls]);
            }
            else{
                return createCombination(allCombinationfinal,allCombinationfinal);
            }
        }
 }