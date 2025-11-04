@isTest(seeAllData=false)
 public with sharing class DH_ExclusioModalityCallcenterTestDataFac{

      
public static DH_Call_Center_Data_Sheet__c createExclusionDenormaliseObject(){
    Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    DH_Call_Center_Data_Sheet__c exclusion = new DH_Call_Center_Data_Sheet__c();
    // exclusion.Name='TestExclusion';
    exclusion.DH_System__c ='TESTFL';
    exclusion.DH_Practice_Code__c ='TESTRIA'; 
    exclusion.DH_Site_Code__c ='TJAC,TKEW'; 
    exclusion.DH_Modality_Code_aka_Proc_Group_Code__c ='TESTANGIO,TESTENDO,TESTRADTHER,TESTRATHER,TESTOUMOU';
    exclusion.DH_Procedure_Code__c ='TEST74181EZRAWB,TEST77049EZRA,TEST949494HBDIE';
    exclusion.DH_Carrier_Code__c ='TEST8255';
    exclusion.DH_Ref_Group_Code__c ='2000050135';
    exclusion.DH_Ref_Dr__c ='2000050135';
    exclusion.DH_New_or_Re_Schedule__c ='N';
    // exclusion.DH_iCode__c ='iE,NiE,ABC,EIE,IEJ';
    exclusion.DH_Notes_1__c ='MR Procedure  to exclude';
    exclusion.RecordTypeId  =exclusionId;
    exclusion.Published__c=true;
    return exclusion;
}


public static DH_Call_Center_Data_Sheet__c createExclusionDenormaliseObjectEmpty(){
    Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    DH_Call_Center_Data_Sheet__c exclusion2 = new DH_Call_Center_Data_Sheet__c();
    // exclusion2.Name='TestExclusion2';
    exclusion2.DH_System__c='TESTFL';
    exclusion2.RecordTypeId  =exclusionId;
    exclusion2.Published__c=true;
    return exclusion2;
}
public static DH_Call_Center_Data_Sheet__c createModalityPriorityDenormaliseObject(){
    DH_Call_Center_Data_Sheet__c modalityPriority = new DH_Call_Center_Data_Sheet__c();
    Id mpId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Modality Priority').getRecordTypeId();
    // modalityPriority.Name='TestModalityPriotity';
    modalityPriority.DH_System__c='TESTFL,TESTMA';
    modalityPriority.DH_Modality_Code_aka_Proc_Group_Code__c='TESTRADTHER,TESTPanther';
    modalityPriority.DH_Description__c='Radiation Therapy';
    modalityPriority.DH_Portal_Procedure_Group_Modality_Code__c='*inactive* TESTRADTHER (Radiation Therapy)';
    modalityPriority.DH_Relative_Priority__c='990';
    modalityPriority.DH_Notes_1__c='Test Notes';
    modalityPriority.RecordTypeId = mpId;
    modalityPriority.Published__c=true;

    return modalityPriority;
}
public static DH_Call_Center_Data_Sheet__c createModalityPriorityDenormaliseObjectEmpty(){
    DH_Call_Center_Data_Sheet__c modalityPriority2 = new DH_Call_Center_Data_Sheet__c();
    Id mpId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Modality Priority').getRecordTypeId();
    // modalityPriority2.Name = 'TestModality2';
    modalityPriority2.DH_System__c='TESTCA';
	modalityPriority2.DH_Relative_Priority__c='990';
    modalityPriority2.recordTypeId=mpId;
    modalityPriority2.Published__c=true;
    return modalityPriority2;
}
public static DH_Call_Center_Data_Sheet__c createCallCenterMappingDenormaliseObject(){
    DH_Call_Center_Data_Sheet__c callCenterMapping = new DH_Call_Center_Data_Sheet__c();
    Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
   // callCenterMapping.Name='TestCallCenterMapping';
    callCenterMapping.DH_System__c='TESTCA';
    callCenterMapping.DH_Practice_Code__c='TESTBRS';
    callCenterMapping.DH_Site_Code__c='TPSL,TGIC,TLPN';
    callCenterMapping.DH_ZIP__c='123';
    callCenterMapping.DH_Modality_Code_aka_Proc_Group_Code__c='TESTNM,TESTPET';
    callCenterMapping.DH_Procedure_Code__c='TESTPET';
    callCenterMapping.DH_Fake_call_center_site_code__c='TESTADVNMPETCALLCTR';
    callCenterMapping.DH_URL1_to_give_RADAR__c='https://advrad.fyi/x-rays';
    callCenterMapping.DH_URL2_to_give_RADAR__c='https://advrad.fyi/x-rays';
    callCenterMapping.DH_URL3_to_give_RADAR__c='https://advrad.fyi/x-rays';
    callCenterMapping.DH_URL4_to_give_RADAR__c='https://advrad.fyi/x-rays';
    callCenterMapping.DH_URL5_to_give_RADAR__c='https://advrad.fyi/x-rays';
    callCenterMapping.DH_Notes_1__c='Test Note';
    callCenterMapping.DH_Site_Code_or_Call_Center_Code__c='TESTC';
    callCenterMapping.DH_Ref_Group_Code__c ='2000050135';
    callCenterMapping.RecordTypeId=ccmId;
    callCenterMapping.Published__c=true;

    return callCenterMapping;
}

public static DH_Call_Center_Data_Sheet__c createCallCenterMappingDenormaliseObjectEmpty(){
    DH_Call_Center_Data_Sheet__c callCenterMapping2 = new DH_Call_Center_Data_Sheet__c();
    Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
    // callCenterMapping2.Name='TestCallCenterMapping2';
    callCenterMapping2.DH_System__c='TESTCA';
	callCenterMapping2.DH_Fake_call_center_site_code__c ='TESTC';
    callCenterMapping2.DH_Site_Code_or_Call_Center_Code__c='TESTC';
    callCenterMapping2.RecordTypeId=ccmId;
    callCenterMapping2.Published__c=true;
    
    return callCenterMapping2;
}
public static DH_Call_Center_Data_Sheet__c createCallCenterHourDenormaliseObject(){
    DH_Call_Center_Data_Sheet__c callCenterHours = new DH_Call_Center_Data_Sheet__c();
    Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    // callCenterHours.Name='TestCallCenterHour';
    callCenterHours.DH_System__c='TESTAZ';
    callCenterHours.DH_Practice_Code__c='TESTAZDRG';
    callCenterHours.DH_Site_Code_or_Call_Center_Code__c='TESTAZCALLCTR';
    callCenterHours.DH_Site_Code__c='TLPN';
    callCenterHours.DH_Day_of_Week__c='Monday;Tuesday;Wednesday;Thursday;Friday';
   // callCenterHours.DH_Specific_Date__c='01/12/2024,01/12/2024';
    callCenterHours.DH_Notes_1__c='Note101,Note102';
    callCenterHours.DH_Contact_Method__c='Boom,AM,PM';
    callCenterHours.DH_iCode__c='iC';
    // callCenterHours.DH_RADAR_Outreach__c='N';
    callCenterHours.DH_Earliest_Time_for_RADAR_Outreach__c=stringToTime('09:00:12');
    callCenterHours.DH_Latest_Time_for_RADAR_Outreach__c=stringToTime('09:00:12');
    callCenterHours.DH_Notes_2__c='Per Jo Lynn Carmona, June 2, 2022.';
    callCenterHours.DH_timezone__c = 'Eastern Time';

    callCenterHours.RecordTypeId=cchId;
    callCenterHours.Published__c=true;

    return callCenterHours;
}
public static DH_Call_Center_Data_Sheet__c createCallCenterHourDenormaliseObjectEmpty(){
    DH_Call_Center_Data_Sheet__c callCenterHours2 = new DH_Call_Center_Data_Sheet__c();
    Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    // callCenterHours2.Name='TestCallCenterHour2';
    callCenterHours2.DH_System__c='TESTCA';
    callCenterHours2.RecordTypeId=cchId;
    callCenterHours2.Published__c=true;
    callCenterHours2.DH_Site_Code_or_Call_Center_Code__c='TESTAZCALLCTR';
    return callCenterHours2;
}

     public static List<DH_Call_Center_Data_Sheet__c> createFailedSDenormalisedObject(){    
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c exclusion = new DH_Call_Center_Data_Sheet__c();
        exclusion.DH_System__c ='TEST1FL';
        exclusion.RecordTypeId  =exclusionId;
 		exclusion.Published__c=true;
 
 		DH_Call_Center_Data_Sheet__c exclusion2 = new DH_Call_Center_Data_Sheet__c();
 		exclusion2.DH_System__c ='TEST1FL';
 		exclusion2.RecordTypeId  =exclusionId;
 		exclusion2.Published__c=true;
    
         
         ccdsList.add(exclusion);
    ccdsList.add(exclusion2);
         
         return ccdsList;
     }
     
      public static List<DH_Call_Center_Data_Sheet__c> failedSiteDenormalisedObject(){
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c exclusion3 = new DH_Call_Center_Data_Sheet__c();
        exclusion3.DH_System__c ='TESTCA,TESTFL';
        exclusion3.DH_Site_Code__c='TESTPSL,TGI1C';
        exclusion3.RecordTypeId  =exclusionId;
 		exclusion3.Published__c=true;
 
 		DH_Call_Center_Data_Sheet__c exclusion4 = new DH_Call_Center_Data_Sheet__c();
 		exclusion4.DH_System__c ='TESTFL';
		exclusion4.DH_Site_Code__c='TLPN,TGI1C';
 		exclusion4.RecordTypeId  =exclusionId;
 		exclusion4.Published__c=true;
        ccdsList.add(exclusion3);
    	ccdsList.add(exclusion4);
          return ccdsList;
     }
     
     
     
           public static List<DH_Call_Center_Data_Sheet__c> failedModalityDenormalisedObject(){
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c exclusion3 = new DH_Call_Center_Data_Sheet__c();
        exclusion3.DH_System__c ='TESTCA,TESTMA';
        exclusion3.DH_Modality_Code_aka_Proc_Group_Code__c ='TESTANGIO,STAlNGIO';
        exclusion3.RecordTypeId  =exclusionId;
 		exclusion3.Published__c=true;
 
 		DH_Call_Center_Data_Sheet__c exclusion4 = new DH_Call_Center_Data_Sheet__c();
 		exclusion4.DH_System__c ='TESTMA';
        exclusion4.DH_Modality_Code_aka_Proc_Group_Code__c ='TESTENDO,STAlNGIO';
 		exclusion4.RecordTypeId  =exclusionId;
 		exclusion4.Published__c=true;
        ccdsList.add(exclusion3);
    	ccdsList.add(exclusion4);
          return ccdsList;
     }
     
     
     
     
     
     
     
     
          
           public static List<DH_Call_Center_Data_Sheet__c> failedProcedureCodeDenormalisedObject(){
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c exclusion3 = new DH_Call_Center_Data_Sheet__c();
        exclusion3.DH_System__c ='TESTAZ,TESTNE';
 		exclusion3.DH_Procedure_Code__c ='TEST74181EZRAWB,T1EST949494HBDIE';
        exclusion3.RecordTypeId  =exclusionId;
 		exclusion3.Published__c=true;
 
 		DH_Call_Center_Data_Sheet__c exclusion4 = new DH_Call_Center_Data_Sheet__c();
 		exclusion4.DH_System__c ='TESTNE';
 		exclusion4.DH_Procedure_Code__c ='TEST77049EZRA,T1EST949494HBDIE';
 		exclusion4.RecordTypeId  =exclusionId;
 		exclusion4.Published__c=true;
        ccdsList.add(exclusion3);
    	ccdsList.add(exclusion4);
          return ccdsList;
     }

          
           public static List<DH_Call_Center_Data_Sheet__c> failedCarrierCodeDenormalisedObject(){
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c exclusion3 = new DH_Call_Center_Data_Sheet__c();
        exclusion3.DH_System__c ='TESTCA,TESTFL';
        exclusion3.DH_Carrier_Code__c ='TEST8255,TEST8l255';
        exclusion3.RecordTypeId  =exclusionId;
 		exclusion3.Published__c=true;
 
 		DH_Call_Center_Data_Sheet__c exclusion4 = new DH_Call_Center_Data_Sheet__c();
 		exclusion4.DH_System__c ='TESTFL';
        exclusion4.DH_Carrier_Code__c ='TEST8l255';
 		exclusion4.RecordTypeId  =exclusionId;
 		exclusion4.Published__c=true;
        ccdsList.add(exclusion3);
    	ccdsList.add(exclusion4);
          return ccdsList;
     }

     
     
          
           public static List<DH_Call_Center_Data_Sheet__c> failedCallCenterDenormalisedObject(){
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c callCenterHours = new DH_Call_Center_Data_Sheet__c();
 callCenterHours.DH_System__c='TESTAZ,TESTFL';
 callCenterHours.DH_Site_Code_or_Call_Center_Code__c='TESTAZCALLCTR,TES1TAZCALLCTR';
 callCenterHours.RecordTypeId=cchId;
 callCenterHours.Published__c=true;
 
 DH_Call_Center_Data_Sheet__c callCenterHours2 = new DH_Call_Center_Data_Sheet__c();
 callCenterHours2.DH_System__c='TESTAZ';
 callCenterHours2.DH_Site_Code_or_Call_Center_Code__c='TESTC,TES1TAZCALLCTR';
 callCenterHours2.RecordTypeId=cchId;
 callCenterHours2.Published__c=true;
               ccdsList.add(callCenterHours);
               ccdsList.add(callCenterHours2);
          return ccdsList;
     }

     
     
     
      
          
public static List<DH_Call_Center_Data_Sheet__c> failedFakeCallCenterDenormalisedObject(){
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        
 DH_Call_Center_Data_Sheet__c callCenterMapping = new DH_Call_Center_Data_Sheet__c();
 // callCenterMapping.Name='TestCallCenterMapping';
  callCenterMapping.DH_System__c='TESTCA,TESTFL';
  callCenterMapping.DH_Fake_call_center_site_code__c='T1ESTENDO';
    callCenterMapping.DH_Site_Code_or_Call_Center_Code__c='TESTC';
  callCenterMapping.RecordTypeId=ccmId;
  callCenterMapping.Published__c=true;
  
   DH_Call_Center_Data_Sheet__c callCenterMapping2 = new DH_Call_Center_Data_Sheet__c();
  callCenterMapping2.DH_System__c='TESTCA';
  callCenterMapping2.DH_Fake_call_center_site_code__c='T1ESTENDO';
  callCenterMapping2.DH_Site_Code_or_Call_Center_Code__c='TESTC';
  callCenterMapping2.RecordTypeId=ccmId;
  callCenterMapping2.Published__c=true; 
               ccdsList.add(callCenterMapping);
               ccdsList.add(callCenterMapping2);
          return ccdsList;
     }
    
     
          
          
           public static List<DH_Call_Center_Data_Sheet__c> failedRefPractDenormalisedObject(){
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
        DH_Call_Center_Data_Sheet__c exclusion = new DH_Call_Center_Data_Sheet__c();
 exclusion.DH_System__c ='TESTFL,TESTCA';
 exclusion.DH_Ref_Group_Code__c ='3000050135,21000050135';
 exclusion.RecordTypeId  =exclusionId;
 exclusion.Published__c=true;
DH_Call_Center_Data_Sheet__c exclusion2 = new DH_Call_Center_Data_Sheet__c();
 exclusion2.DH_System__c ='TESTCA';
 exclusion2.DH_Ref_Group_Code__c ='1000050135,21000050135';
 exclusion2.RecordTypeId  =exclusionId;
 exclusion2.Published__c=true;
  
               ccdsList.add(exclusion);
               ccdsList.add(exclusion2);
          return ccdsList;
     }
     
     
          
          
  public static List<DH_Call_Center_Data_Sheet__c> failedRefDrDenormalisedObject(){
         List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
               DH_Call_Center_Data_Sheet__c exclusion = new DH_Call_Center_Data_Sheet__c();
 exclusion.DH_System__c ='TESTFL,TESTCA';
 exclusion.DH_Ref_Dr__c ='1000050135,21000050135';
 exclusion.RecordTypeId  =exclusionId;
 exclusion.Published__c=true;
DH_Call_Center_Data_Sheet__c exclusion2 = new DH_Call_Center_Data_Sheet__c();
 exclusion2.DH_System__c ='TESTCA';
 exclusion.DH_Ref_Dr__c ='3000050135,21000050135';
      exclusion2.RecordTypeId  =exclusionId;
 exclusion2.Published__c=true;
  
               ccdsList.add(exclusion);
               ccdsList.add(exclusion2);
          return ccdsList;
     }


     
     
     
  public static List<DH_Call_Center_Data_Sheet__c> dataForCheckingExclusionDuplicate(){
  		List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    	Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    	Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    	Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
      	Id mpId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Modality Priority').getRecordTypeId();
       DH_Call_Center_Data_Sheet__c exclusion = new DH_Call_Center_Data_Sheet__c();
 exclusion.DH_System__c ='TESTMA';
 exclusion.DH_Practice_Code__c ='TESTAZDRG';
 exclusion.RecordTypeId  =exclusionId;
 
 DH_Call_Center_Data_Sheet__c callCenterHours = new DH_Call_Center_Data_Sheet__c();
 // callCenterHours.Name='TestCallCenterHour';
 callCenterHours.DH_System__c='TESTMA';
 callCenterHours.DH_Site_Code_or_Call_Center_Code__c='TESTAZCALLCTR';
 callCenterHours.RecordTypeId=cchId;
 callCenterHours.Published__c=true;
  DH_Call_Center_Data_Sheet__c callCenterMapping = new DH_Call_Center_Data_Sheet__c();
 callCenterMapping.DH_System__c='TESTMA';
 callCenterMapping.DH_Fake_call_center_site_code__c='TESTC';
 callCenterMapping.DH_Site_Code_or_Call_Center_Code__c='TESTC';
 callCenterMapping.RecordTypeId=ccmId;
 callCenterMapping.Published__c=true;
 
  DH_Call_Center_Data_Sheet__c modalityPriority = new DH_Call_Center_Data_Sheet__c();
 modalityPriority.DH_System__c='TESTMA';
 modalityPriority.DH_Relative_Priority__c='090';
 modalityPriority.RecordTypeId=mpId;
 modalityPriority.Published__c=true;   
      ccdsList.add(exclusion);
      ccdsList.add(callCenterHours);
      ccdsList.add(callCenterMapping);
      ccdsList.add(modalityPriority);
return ccdsList;
  }
  
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
public static List<DH_Call_Center_Data_Sheet__c> createDenormalisedObject(){
    List<DH_Call_Center_Data_Sheet__c> ccdsList = new List<DH_Call_Center_Data_Sheet__c>();
    Id exclusionId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Exclusions').getRecordTypeId();
    Id cchId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Hours').getRecordTypeId();
    Id ccmId = Schema.SObjectType.DH_Call_Center_Data_Sheet__c.getRecordTypeInfosByName().get('Call Center Mapping').getRecordTypeId();
     DH_Call_Center_Data_Sheet__c exclusion = new DH_Call_Center_Data_Sheet__c();
 exclusion.DH_System__c ='TESTFL';
 exclusion.DH_Carrier_Code__c ='TEST8255';
 exclusion.DH_New_or_Re_Schedule__c ='N';
 exclusion.RecordTypeId  =exclusionId;
 exclusion.DH_Ref_Dr__c ='2000050135';
 exclusion.Published__c=true;
 
 DH_Call_Center_Data_Sheet__c exclusion2 = new DH_Call_Center_Data_Sheet__c();
 exclusion2.DH_System__c ='TESTFL,TESTAZ';
 exclusion2.DH_Carrier_Code__c ='TEST8255';
 exclusion2.DH_New_or_Re_Schedule__c ='R';
 exclusion2.DH_Ref_Dr__c ='2000050135';
 exclusion2.RecordTypeId  =exclusionId;
 exclusion2.Published__c=true;
    
 DH_Call_Center_Data_Sheet__c callCenterHours = new DH_Call_Center_Data_Sheet__c();
 callCenterHours.DH_System__c='TESTAZ,TESTFL';
 callCenterHours.DH_Site_Code_or_Call_Center_Code__c='TESTAZCALLCTR';
 callCenterHours.RecordTypeId=cchId;
 callCenterHours.Published__c=true;
 
 DH_Call_Center_Data_Sheet__c callCenterHours2 = new DH_Call_Center_Data_Sheet__c();
 callCenterHours2.DH_System__c='TESTAZ';
 callCenterHours2.DH_Site_Code_or_Call_Center_Code__c='TESTAZCALLCTR,TESTC';
 callCenterHours2.RecordTypeId=cchId;
 callCenterHours2.Published__c=true;
    
     DH_Call_Center_Data_Sheet__c callCenterMapping = new DH_Call_Center_Data_Sheet__c();
 // callCenterMapping.Name='TestCallCenterMapping';
  callCenterMapping.DH_System__c='TESTCA,TESTFL';
  callCenterMapping.DH_Fake_call_center_site_code__c='TESTADVNMPETCALLCTR,';
  callCenterMapping.DH_Site_Code_or_Call_Center_Code__c='TESTC';
  callCenterMapping.DH_Practice_Code__c='TlESTBRS,TESTRIA';
  callCenterMapping.DH_Site_Code__c='TESTPSL,TESTGIC,TESTLPN';
  callCenterMapping.DH_ZIP__c='123';
  callCenterMapping.DH_Modality_Code_aka_Proc_Group_Code__c='TlESTNM,TlESTPET,TESTPET';
  callCenterMapping.DH_Procedure_Code__c='TlESTPET,TEST77049EZRA';
  callCenterMapping.DH_Ref_Group_Code__c ='2000050135';
  callCenterMapping.RecordTypeId=ccmId;
  callCenterMapping.Published__c=true;
  
   DH_Call_Center_Data_Sheet__c callCenterMapping2 = new DH_Call_Center_Data_Sheet__c();
  callCenterMapping2.DH_System__c='TESTCA';
  callCenterMapping2.DH_Fake_call_center_site_code__c='TESTADVNMPETCALLCTR';
  callCenterMapping2.DH_Site_Code_or_Call_Center_Code__c='TESTC';
  callCenterMapping2.DH_Practice_Code__c='TESTBRS,TESTAZDRG,TESTBRS';
  callCenterMapping2.DH_Site_Code__c='TESTPSL,TGIC,TLPN';
  callCenterMapping2.DH_ZIP__c='123';
  callCenterMapping2.DH_Modality_Code_aka_Proc_Group_Code__c='TESTNM,TESTPET,TlESTPET';
  callCenterMapping2.DH_Procedure_Code__c='TESTPET,TEST77049EZRA,TlESTPET';
  callCenterMapping2.DH_Ref_Group_Code__c ='2000050135';
  callCenterMapping2.RecordTypeId=ccmId;
  callCenterMapping2.Published__c=true; 
    

    ccdsList.add(exclusion);
    ccdsList.add(exclusion2);
    ccdsList.add(callCenterHours);
    ccdsList.add(callCenterHours2);
    ccdsList.add(callCenterMapping);
    ccdsList.add(callCenterMapping2);
    return ccdsList;
    
}





    public static List<Account> createRegionAccounts(){
    List<Account> accList= new List<Account>();
    Id regionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RIS Instance / RIS System').getRecordTypeId();
   
    Account region1 = new Account(RecordTypeId=regionRecordTypeId,Name ='TESTFL' ,Region__c='TESTFL',DH_RIS_Unique_Code__c='TESTFL_RIS Instance / RIS System');  
    Account region2 = new Account(RecordTypeId=regionRecordTypeId,Name ='TESTMA' ,Region__c='TESTMA',DH_RIS_Unique_Code__c='TESTMA_RIS Instance / RIS System'); 
    Account region3 = new Account(RecordTypeId=regionRecordTypeId,Name ='TESTCA' ,Region__c='TESTCA',DH_RIS_Unique_Code__c='TESTCA_RIS Instance / RIS System'); 
    Account region4 = new Account(RecordTypeId=regionRecordTypeId,Name ='TESTAZ' ,Region__c='TESTAZ',DH_RIS_Unique_Code__c='TESTAZ_RIS Instance / RIS System'); 

   
    acclist.add(region1);
    acclist.add(region2);
    acclist.add(region3);
    acclist.add(region4);
    return accList;

}
public static List<Account> createOtherAccounts(String regionRecordID, String regionName){
    List<Account> accList= new List<Account>();
    Id practiveRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice').getRecordTypeId();
    Id siteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
    Id payerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();

    Id srefGroupCodeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referring Practice').getRecordTypeId();
    Id refDrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
    

    Account practice1 = new Account(RecordTypeId=practiveRecordTypeId,Name='(TESTAZDRG) Azar Door Rate Gang', Practice_Code__c='TESTAZDRG', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TESTAZDRG_Practice');
    Account practice2 = new Account(RecordTypeId=practiveRecordTypeId,Name='(TESTBRS) Band Review System', Practice_Code__c='TESTBRS', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TESTBRS_Practice');
    Account practice3 = new Account(RecordTypeId=practiveRecordTypeId,Name='(TESTRIA) Rate Is Action', Practice_Code__c='TESTRIA', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TESTRIA_Practice');



    Account site1 =new Account(RecordTypeId=siteRecordTypeId,Name='TLPN', Site_Code__c='TLPN', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TLPN_Site');
    Account site2 =new Account(RecordTypeId=siteRecordTypeId,Name='TPSL,,', Site_Code__c='TPSL', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TPSL_Site');
    Account site3 =new Account(RecordTypeId=siteRecordTypeId,Name='TJAC,', Site_Code__c='TJAC', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TJAC_Site');
    Account site4 =new Account(RecordTypeId=siteRecordTypeId,Name='TKEW', Site_Code__c='TKEW', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TKEW_Site');
    Account site5 =new Account(RecordTypeId=siteRecordTypeId,Name='TGIC', Site_Code__c='TGIC', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TGIC_Site');


    Account payer1 =  new Account(RecordTypeId=payerRecordTypeId,Name='Test Payer',Carrier_Code_in_RIS__c='TEST8255', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TEST8255_Payer');
    Account payer2 =  new Account(RecordTypeId=payerRecordTypeId,Name='Test Payer',Carrier_Code_in_RIS__c='TEST8266', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_TEST8266_Payer');

    Account refPracGroupName1=new Account(RecordTypeId=srefGroupCodeRecordTypeId,Name='Test Ref Practice',DH_Referring_Practice_Key__c='2000050135', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_2000050135_Referring Practice');
        Account refPracGroupName2=new Account(RecordTypeId=srefGroupCodeRecordTypeId,Name='Test Ref Practice2',DH_Referring_Practice_Key__c='1000050135', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_1000050135_Referring Practice');
    Account refPracGroupName3=new Account(RecordTypeId=srefGroupCodeRecordTypeId,Name='Test Ref Practice4',DH_Referring_Practice_Key__c='3000050135', Region__C=regionName,AccountRegion__c=regionRecordID, DH_RIS_Unique_Code__c=regionName+'_3000050135_Referring Practice');

    Account refDR1=new Account(RecordTypeId=refDrRecordTypeId,Name='Test Dr',DH_Physician_Key__c='2000050135' ,Region__C=regionName,AccountRegion__c=regionRecordID,DH_Physician_Id__c='2000050135', DH_RIS_Unique_Code__c=regionName+'_2000050135_Physician');
    Account refDR2=new Account(RecordTypeId=refDrRecordTypeId,Name='Test Dr2',DH_Physician_Key__c='1000050135' ,Region__C=regionName,AccountRegion__c=regionRecordID,DH_Physician_Id__c='1000050135', DH_RIS_Unique_Code__c=regionName+'_1000050135_Physician');
    Account refDR3=new Account(RecordTypeId=refDrRecordTypeId,Name='Test Dr3',DH_Physician_Key__c='3000050135' ,Region__C=regionName,AccountRegion__c=regionRecordID,DH_Physician_Id__c='3000050135', DH_RIS_Unique_Code__c=regionName+'_3000050135_Physician');


    acclist.add(practice1);
    acclist.add(practice2);
    acclist.add(practice3);
    acclist.add(site1);
    acclist.add(site2);
    acclist.add(site3);
    acclist.add(site4);
    acclist.add(site5);
    acclist.add(payer1);
    acclist.add(payer2);
    acclist.add(refPracGroupName1);
    acclist.add(refPracGroupName2);
    acclist.add(refPracGroupName3);
    accList.add(refDR1);
    accList.add(refDR2);
    accList.add(refDR3);
    return accList;

}
public static List<CareSpecialty> createCareSpeciality(String regionRecordId,String regionName){
    List<CareSpecialty> csList =  new List<CareSpecialty>();
    Id carespecialityRecordTypeId = Schema.SObjectType.CareSpecialty.getRecordTypeInfosByName().get('Marketing Carespeciality').getRecordTypeId(); 
    CareSpecialty cs1 = new CareSpecialty(RecordTypeId=carespecialityRecordTypeId, Name='TESTNM',DH_SFMC_Speciality_Code__c='TESTNM', DH_Region_Instance__c =regionRecordId,SpecialtyCode=regionName+'_TESTNM',CareSpecialty_External_ID__c=regionName+'_TESTNM');
 CareSpecialty cs2 = new CareSpecialty(RecordTypeId=carespecialityRecordTypeId, Name='TESTENDO',DH_SFMC_Speciality_Code__c='TESTENDO', DH_Region_Instance__c =regionRecordId,SpecialtyCode=regionName+'_TESTENDO',CareSpecialty_External_ID__c=regionName+'_TESTENDO');
 CareSpecialty cs3 = new CareSpecialty(RecordTypeId=carespecialityRecordTypeId, Name='TESTOUMOU',DH_SFMC_Speciality_Code__c='TESTOUMOU', DH_Region_Instance__c =regionRecordId,SpecialtyCode=regionName+'_TESTOUMOU',CareSpecialty_External_ID__c=regionName+'_TESTOUMOU');
 CareSpecialty cs4 = new CareSpecialty(RecordTypeId=carespecialityRecordTypeId, Name='TESTRATHER',DH_SFMC_Speciality_Code__c='TESTRATHER', DH_Region_Instance__c =regionRecordId,SpecialtyCode=regionName+'_TESTRATHER',CareSpecialty_External_ID__c=regionName+'_TESTRATHER');
 CareSpecialty cs5 = new CareSpecialty(RecordTypeId=carespecialityRecordTypeId, Name='TESTRADTHER',DH_SFMC_Speciality_Code__c='TESTRADTHER', DH_Region_Instance__c =regionRecordId,SpecialtyCode=regionName+'_TESTRADTHER',CareSpecialty_External_ID__c=regionName+'_TESTRADTHER');
 CareSpecialty cs6 = new CareSpecialty(RecordTypeId=carespecialityRecordTypeId, Name='TESTANGIO',DH_SFMC_Speciality_Code__c='TESTANGIO', DH_Region_Instance__c =regionRecordId,SpecialtyCode=regionName+'_TESTANGIO',CareSpecialty_External_ID__c=regionName+'_TESTANGIO');
 CareSpecialty cs7 = new CareSpecialty(RecordTypeId=carespecialityRecordTypeId, Name='TESTPanther',DH_SFMC_Speciality_Code__c='TESTPanther', DH_Region_Instance__c =regionRecordId,SpecialtyCode=regionName+'_TESTPanther',CareSpecialty_External_ID__c=regionName+'_TESTPanther');
 CareSpecialty cs8 = new CareSpecialty(RecordTypeId=carespecialityRecordTypeId, Name='TESTPET',DH_SFMC_Speciality_Code__c='TESTPET', DH_Region_Instance__c =regionRecordId,SpecialtyCode=regionName+'_TESTPET',CareSpecialty_External_ID__c=regionName+'_TESTPET');
    
    csList.add(cs1);
    csList.add(cs2);
    csList.add(cs3);
    csList.add(cs4);
    csList.add(cs5);
    csList.add(cs6);
    csList.add(cs7);
    csList.add(cs8);
    return csList;
}
public static List<HealthCareProcedure> createHealthCareProcedure(String regionRecordId, String regionName){
    List<HealthCareProcedure> hcList = new List<HealthCareProcedure>();
    Id healthCareProcedureRecordTypeId = Schema.SObjectType.HealthCareProcedure.getRecordTypeInfosByName().get('Marketing Healthcare Procedure').getRecordTypeId();
    HealthCareProcedure hc1 = new HealthCareProcedure(RecordTypeId=healthCareProcedureRecordTypeId,Name ='TESTPET',Code='TESTPET',DH_Region_Instance__c =regionRecordId,Region__c=regionName,DH_RIS_Healthcare_Procedure__c=regionName +'_TESTPET');
    HealthCareProcedure hc2 = new HealthCareProcedure(RecordTypeId=healthCareProcedureRecordTypeId,Name ='TEST74181EZRAWB',Code='TEST74181EZRAWB',DH_Region_Instance__c =regionRecordId,Region__c=regionName,DH_RIS_Healthcare_Procedure__c=regionName +'_TEST74181EZRAWB');
    HealthCareProcedure hc3 = new HealthCareProcedure(RecordTypeId=healthCareProcedureRecordTypeId,Name ='TEST77049EZRA',Code='TEST77049EZRA',DH_Region_Instance__c =regionRecordId,Region__c=regionName,DH_RIS_Healthcare_Procedure__c=regionName +'_TEST77049EZRA');
    HealthCareProcedure hc4 = new HealthCareProcedure(RecordTypeId=healthCareProcedureRecordTypeId,Name ='TEST949494HBDIE',Code='TEST949494HBDIE',DH_Region_Instance__c =regionRecordId,Region__c=regionName,DH_RIS_Healthcare_Procedure__c=regionName +'_TEST949494HBDIE');
    hcList.add(hc1);
    hcList.add(hc2);
    hcList.add(hc3);
    hcList.add(hc4);
    return hcList;
}


public static List<DH_Call_Center__c> createCallCenter(){
    List<DH_Call_Center__c> callCenterList = new List<DH_Call_Center__c>();
    DH_Call_Center__c cc1 = new DH_Call_Center__c(Name='TESTC',DH_Call_Center_Code__c='TESTC');
    DH_Call_Center__c cc2 = new DH_Call_Center__c(Name='TESTADVNMPETCALLCTR',DH_Call_Center_Code__c='TESTADVNMPETCALLCTR');
    DH_Call_Center__c cc3 = new DH_Call_Center__c(Name='TESTAZCALLCTR',DH_Call_Center_Code__c='TESTAZCALLCTR');
    callCenterList.add(cc1);
    callCenterList.add(cc2);
    callCenterList.add(cc3);
    return callCenterList;
}






public static User createUser(){
    User user1 = new User(
       FirstName = 'Prasanna',
       LastName = 'Anjankar',
       Email = 'prasanna@example.com',
       Username = 'prasanna@example.com' + System.currentTimeMillis(),
       Alias = 'sysAdmin',
       ProfileId = [SELECT Id FROM Profile WHERE Name = 'Radnet Manager East'].Id,
       TimeZoneSidKey = 'America/New_York',
       LocaleSidKey = 'en_US',
       EmailEncodingKey = 'UTF-8',
       LanguageLocaleKey = 'en_US'
   );
   return user1;
}
     

public static Time stringToTime(String timeString){
    List<String> timeParts = timeString.split(':');
    Integer hours= Integer.valueOf(timeParts[0]);
    Integer minutes= Integer.valueOf(timeParts[1]);
    Integer seconds= Integer.valueOf(timeParts[2]);
    return Time.newInstance(hours, minutes, seconds, 0);
}
    
 }