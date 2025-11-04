/*
 
*********************************************************
 
Apex Class         : DH_CallCenterDataSheetDenormalizeHandler
 
Created Date       : June , 2024

Updated Date       : 21-June-2024
 
@description       :  * Function - This is an apex class to check wether the input values in call center data sheet records are available to use as lookup or  not
 
@jiraid            : CC-283

*********************************************************
 
*/

public without sharing class DH_CallCenterDataSheetDenormalizeHandler extends TriggerHandler {
 	private DH_Call_Center_Data_Sheet__c[] newCCDS;
	private DH_Call_Center_Data_Sheet__c[] oldCCDS;
	private Map<Id, DH_Call_Center_Data_Sheet__c> oldCCDSMap;
	private Map<Id, DH_Call_Center_Data_Sheet__c> newCCDSMap;
    
    protected override void populateTriggerData(
		List<SObject> oldSObjectsList, 
		List<SObject> newSObjectsList,
		Map<Id, SObject> oldSObjectsMap, 
		Map<Id, SObject> newSObjectsMap
	) {
		this.newCCDS = (DH_Call_Center_Data_Sheet__c[]) newSObjectsList;
		this.oldCCDS = (DH_Call_Center_Data_Sheet__c[]) oldSObjectsList;
		this.newCCDSMap = (Map<Id, DH_Call_Center_Data_Sheet__c >) newSObjectsMap;
		this.oldCCDSMap = (Map<Id, DH_Call_Center_Data_Sheet__c >) oldSObjectsMap;
	}
	
    protected override void onBeforeInsert() {
         DH_ExclusionDenormalizeCheckDuplicates.exclusionDenormalizeCheckIfDuplicates(newCCDS);
         checkLookup(newCCDS);
    }
    
    protected override void onBeforeUpdate() {
         DH_ExclusionDenormalizeCheckDuplicates.exclusionDenormalizeCheckIfDuplicates(newCCDS);
         checkLookup(newCCDS);
    }

public class ExclusionLookupWrapper{
    public DH_Call_Center_Data_Sheet__c ccds;
    public Id ccdsId;
    public Map<String, Set<String>> errorMap;
    
    public ExclusionLookupWrapper(DH_Call_Center_Data_Sheet__c ccds, Id ccdsId, Map<String, Set<String>> errorMap){
        this.ccds = ccds;
        this.ccdsId = ccdsId;
        this.errorMap = errorMap;
    }
}

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



public static void checkLookup(List<DH_Call_Center_Data_Sheet__c> triggerNew){
    
    Id risRec =DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_ID ;
    Id siteRec = DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_ID;
    Id practiceRec = DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_ID;
    Id payerRec = DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_ID;
     Id refPracticeName=DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_ID;
    Id refDrIdId=DH_ExclusionDenormalizeGlobalConstants.REF_DR_PRACTICE_ID_ID;



    Set<String> regionUniqueCode = new Set<String>();
    Set<String> practiceUniqueCode = new Set<String>();
    Set<String> siteUniqueCode = new Set<String>();
    Set<String> modalityUniqueCode = new Set<String>();
    Set<String> procedureUniqueCode = new Set<String>();
    Set<String> carrierUniqueCode = new Set<String>();
    Set<String> callCenterUniqueCode = new Set<String>();
    Set<String> fakeCallCenterUniqueCode = new Set<String>();
    Set<String> refGroupPracticeUniqueCode = new Set<String>();
    Set<String> refDrIdUniqueCode = new Set<String>();

    Map<String, List<DH_Call_Center_Data_Sheet__c>> regionUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> practiceUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> siteUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> modalityUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> procedureUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> carrierUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> callCenterUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> fakeCallCenterUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> refGroupPracticeUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();
    Map<String, List<DH_Call_Center_Data_Sheet__c>> refDrIdUniqueCodeVsCCDS = new Map<String, List<DH_Call_Center_Data_Sheet__c>>();

    for(DH_Call_Center_Data_Sheet__c ccds : triggerNew){
        List<String> stringsOfSystem = New List<String>();
        List<String> stringsOfPracticeCode = New List<String>();
        List<String> stringsOfSiteCode = New List<String>();
        List<String> stringsOfModalityProcGroupCode = New List<String>();
        List<String> stringsOfProcedureCode = New List<String>();
        List<String> stringsOfCarrierCode =New List<String>();
        List<String> stringsOfCallCenter = New List<String>();
        List<String> stringsOfFakeCallCenter = New List<String>();
        List<String> stringOfRefGroupPractice=New List<String>();
        List<String> stringOfRefDrId= New List<String>();
        
Set<String> objectSpecificRegionUniqueCode = new Set<String>();
Set<String> objectSpecificPracticeUniqueCode = new Set<String>();
Set<String> objectSpecificSiteUniqueCode = new Set<String>();
Set<String> objectSpecificModalityUniqueCode = new Set<String>();			
Set<String> objectSpecificProcedureUniqueCode = new Set<String>();
Set<String> objectSpecificCarrierUniqueCode = new Set<String>();
Set<String> objectSpecificCallCenterUniqueCode = new Set<String>();
Set<String> objectSpecificFakeCallCenterUniqueCode = new Set<String>();
Set<String> objectSpecificRefGroupPracticeUniqueCode = new Set<String>();
Set<String> objectSpecificRefDrIdUniqueCode = new Set<String>();
        
        stringsOfSystem.addAll((ccds.DH_System__c != null) ? ccds.DH_System__c.split('[\\s]*,[\\s]*'):new List<String>{''} );
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_ID ||ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
                if(ccds.DH_Practice_Code__c != null){
                    stringsOfPracticeCode.addAll(ccds.DH_Practice_Code__c.split('[\\s]*,[\\s]*'));
                }
            }
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_ID ||ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
                if(ccds.DH_Site_Code__c != null){
                    stringsOfSiteCode.addAll(ccds.DH_Site_Code__c.split('[\\s]*,[\\s]*'));
                }
            }
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.MODALITY_PRIORITY_RECORD_TYPE_ID ||ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID ){
                if(ccds.DH_Modality_Code_aka_Proc_Group_Code__c != null){
                    stringsOfModalityProcGroupCode.addAll(ccds.DH_Modality_Code_aka_Proc_Group_Code__c.split('[\\s]*,[\\s]*'));
                }
            }
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
                if(ccds.DH_Procedure_Code__c != null){
                    stringsOfProcedureCode.addAll(ccds.DH_Procedure_Code__c.split('[\\s]*,[\\s]*'));
                }
            }
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
                if(ccds.DH_Carrier_Code__c != null){
                    stringsOfCarrierCode.addAll(ccds.DH_Carrier_Code__c.split('[\\s]*,[\\s]*'));
                }                    
            }
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_HOUR_RECORD_TYPE_ID){
                if(ccds.DH_Site_Code_or_Call_Center_Code__c != null){
                    stringsOfCallCenter.addAll(ccds.DH_Site_Code_or_Call_Center_Code__c.split('[\\s]*,[\\s]*'));
                }
            }
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID){
                if(ccds.DH_Fake_call_center_site_code__c != null){
                    stringsOfFakeCallCenter.addAll(ccds.DH_Fake_call_center_site_code__c.split('[\\s]*,[\\s]*'));
                }
            } 
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID || ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.CALL_CENTER_MAPPING_RECORD_TYPE_ID){
                if(ccds.DH_Ref_Group_Code__c!=null){
                    stringOfRefGroupPractice.addAll(ccds.DH_Ref_Group_Code__c.split('[\\s]*,[\\s]*'));
                }
            }
            if(ccds.RecordTypeId == DH_ExclusionDenormalizeGlobalConstants.EXCLUSION_RECORD_TYPE_ID){
                if(ccds.DH_Ref_Dr__c!=null){
                    stringOfRefDrId.addAll(ccds.DH_Ref_Dr__c.split('[\\s]*,[\\s]*'));
                }
            }
       
        
        for(String reg : stringsOfSystem){
            regionUniqueCode.add(createRegionCode(reg, DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME));
            objectSpecificRegionUniqueCode.add(createRegionCode(reg, DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME));
            for(String practice : stringsOfPracticeCode){
                practiceUniqueCode.add(createPracticeCode(reg, practice, DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME));
                objectSpecificPracticeUniqueCode.add(createPracticeCode(reg, practice, DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME));
            }
            for(String site : stringsOfSiteCode){
                siteUniqueCode.add(createSiteCode(reg, site, DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME));
                objectSpecificSiteUniqueCode.add(createSiteCode(reg, site, DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME));
            }
            for(String carrierCode : stringsOfCarrierCode){
                carrierUniqueCode.add(createCarrierCode(reg, carrierCode, DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_NAME));
                objectSpecificCarrierUniqueCode.add(createCarrierCode(reg, carrierCode, DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_NAME));
            }
            for(String physicianKey : stringOfRefDrId){
                refDrIdUniqueCode.add(createPhysicianKey(reg, physicianKey, DH_ExclusionDenormalizeGlobalConstants.REF_DR_PRACTICE_ID_NAME));
                objectSpecificRefDrIdUniqueCode.add(createPhysicianKey(reg, physicianKey, DH_ExclusionDenormalizeGlobalConstants.REF_DR_PRACTICE_ID_NAME));
            }
            for(String referringPracticeKey : stringOfRefGroupPractice){
                refGroupPracticeUniqueCode.add(createReferringPractice(reg, referringPracticeKey, DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME));
                objectSpecificRefGroupPracticeUniqueCode.add(createReferringPractice(reg, referringPracticeKey, DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME));
            }
            for(String healthcareProcedure : stringsOfProcedureCode){
                procedureUniqueCode.add(createHealthcareProcedureCode(reg, healthcareProcedure));
                objectSpecificProcedureUniqueCode.add(createHealthcareProcedureCode(reg, healthcareProcedure));
            }
            for(String modalityCode : stringsOfModalityProcGroupCode){
                modalityUniqueCode.add(createCareSpecialtyCode(reg, modalityCode));
                objectSpecificModalityUniqueCode.add(createCareSpecialtyCode(reg, modalityCode));
            }
        }
        
        for(String callCenter : stringsOfCallCenter){
            callCenterUniqueCode.add(callCenter);
            objectSpecificCallCenterUniqueCode.add(callCenter);
        }
        for(String fakecallCenter : stringsOfFakeCallCenter){
            fakeCallCenterUniqueCode.add(fakecallCenter);
            objectSpecificFakeCallCenterUniqueCode.add(fakecallCenter);
        }
        System.debug('regionuc ' + regionUniqueCode);
        System.debug('practiceuc ' + practiceUniqueCode);
        System.debug('siteuc ' + siteUniqueCode);
        System.debug('modalityuc ' + modalityUniqueCode);
        System.debug('procedureuc ' + procedureUniqueCode);
        System.debug('carrieruc ' + carrierUniqueCode);
        System.debug('callcenteruc ' + callCenterUniqueCode);
        System.debug('fakeCallCenterUniqueCode ' + fakeCallCenterUniqueCode);
        System.debug('refgroupuc ' + refGroupPracticeUniqueCode);
        System.debug('refdriduc ' + refDrIdUniqueCode);
        System.debug('==========================================');
        
        for(String regionUC : objectSpecificRegionUniqueCode){
            if(regionUniqueCodeVsCCDS.containsKey(regionUC)){
                List<DH_Call_Center_Data_Sheet__c> regionIds = regionUniqueCodeVsCCDS.get(regionUC);
                regionIds.add(ccds);
                regionUniqueCodeVsCCDS.put(regionUC, regionIds);
            }
            else{
                regionUniqueCodeVsCCDS.put(regionUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        
        for(String practiceUC : objectSpecificPracticeUniqueCode){
            if(practiceUniqueCodeVsCCDS.containsKey(practiceUC)){
                List<DH_Call_Center_Data_Sheet__c> practiceIds = practiceUniqueCodeVsCCDS.get(practiceUC);
                practiceIds.add(ccds);
                practiceUniqueCodeVsCCDS.put(practiceUC, practiceIds);
            }
            else{
                practiceUniqueCodeVsCCDS.put(practiceUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        
        for(String siteUC : objectSpecificSiteUniqueCode){
            if(siteUniqueCodeVsCCDS.containsKey(siteUC)){
                List<DH_Call_Center_Data_Sheet__c> siteIds = siteUniqueCodeVsCCDS.get(siteUC);
                siteIds.add(ccds);
                siteUniqueCodeVsCCDS.put(siteUC, siteIds);
            }
            else{
                siteUniqueCodeVsCCDS.put(siteUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        System.debug('MOdality coe : ' + objectSpecificModalityUniqueCode );
        System.debug('MOdality coevs : ' + modalityUniqueCodeVsCCDS );
        for(String modalityUC : objectSpecificModalityUniqueCode){
            if(modalityUniqueCodeVsCCDS.containsKey(modalityUC)){
                List<DH_Call_Center_Data_Sheet__c> modalityIds = modalityUniqueCodeVsCCDS.get(modalityUC);
                modalityIds.add(ccds);
                modalityUniqueCodeVsCCDS.put(modalityUC, modalityIds);
            }
            else{
                modalityUniqueCodeVsCCDS.put(modalityUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        
        for(String procedureUC : objectSpecificProcedureUniqueCode){
            if(procedureUniqueCodeVsCCDS.containsKey(procedureUC)){
                List<DH_Call_Center_Data_Sheet__c> procedureIDs = procedureUniqueCodeVsCCDS.get(procedureUC);
                procedureIDs.add(ccds);
                procedureUniqueCodeVsCCDS.put(procedureUC, procedureIDs);
            }
            else{
                procedureUniqueCodeVsCCDS.put(procedureUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        
        for(String carrierUC : objectSpecificCarrierUniqueCode){
            if(carrierUniqueCodeVsCCDS.containsKey(carrierUC)){
                List<DH_Call_Center_Data_Sheet__c> carrierIds = carrierUniqueCodeVsCCDS.get(carrierUC);
                carrierIds.add(ccds);
                carrierUniqueCodeVsCCDS.put(carrierUC, carrierIds);
            }
            else{
                carrierUniqueCodeVsCCDS.put(carrierUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        System.debug('cc coe : ' + objectSpecificCallCenterUniqueCode );
        System.debug('cc coevs : ' + callCenterUniqueCodeVsCCDS );
        for(String callCenterUC : objectSpecificCallCenterUniqueCode){
            if(callCenterUniqueCodeVsCCDS.containsKey(callCenterUC)){
                List<DH_Call_Center_Data_Sheet__c> callCenterIds = callCenterUniqueCodeVsCCDS.get(callCenterUC);
                callCenterIds.add(ccds);
                callCenterUniqueCodeVsCCDS.put(callCenterUC, callCenterIds);
            }
            else{
                callCenterUniqueCodeVsCCDS.put(callCenterUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        
        for(String fakeCallCenterUC : objectSpecificFakeCallCenterUniqueCode){
            if(fakeCallCenterUniqueCodeVsCCDS.containsKey(fakeCallCenterUC)){
                List<DH_Call_Center_Data_Sheet__c> fakeCallCenterIds = fakeCallCenterUniqueCodeVsCCDS.get(fakeCallCenterUC);
                fakeCallCenterIds.add(ccds);
                fakeCallCenterUniqueCodeVsCCDS.put(fakeCallCenterUC, fakeCallCenterIds);
            }
            else{
                fakeCallCenterUniqueCodeVsCCDS.put(fakeCallCenterUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        
        for(String refGroupUC : objectSpecificRefGroupPracticeUniqueCode){
            if(refGroupPracticeUniqueCodeVsCCDS.containsKey(refGroupUC)){
                List<DH_Call_Center_Data_Sheet__c> refGroupsIDs = refGroupPracticeUniqueCodeVsCCDS.get(refGroupUC);
                refGroupsIDs.add(ccds);
                refGroupPracticeUniqueCodeVsCCDS.put(refGroupUC, refGroupsIDs);
            }
            else{
                refGroupPracticeUniqueCodeVsCCDS.put(refGroupUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        
        for(String refDrUC : objectSpecificRefDrIdUniqueCode){
            if(refDrIdUniqueCodeVsCCDS.containsKey(refDrUC)){
                List<DH_Call_Center_Data_Sheet__c> refDrIds = refDrIdUniqueCodeVsCCDS.get(refDrUC);
                refDrIds.add(ccds);
                refDrIdUniqueCodeVsCCDS.put(refDrUC, refDrIds);
            }
            else{
                refDrIdUniqueCodeVsCCDS.put(refDrUC, new List<DH_Call_Center_Data_Sheet__c>{ccds});
            }
        }
        
        System.debug('regionmp ' + regionUniqueCodeVsCCDS);
        System.debug('practicemp ' + practiceUniqueCodeVsCCDS);
        System.debug('sitemp ' + siteUniqueCodeVsCCDS);
        System.debug('modalitymp ' + modalityUniqueCodeVsCCDS);
        System.debug('proceduremp ' + procedureUniqueCodeVsCCDS);
        System.debug('carriermp ' + carrierUniqueCodeVsCCDS);
        System.debug('callcentermp ' + callCenterUniqueCodeVsCCDS);
        System.debug('fakeCallcentermp ' + fakeCallCenterUniqueCodeVsCCDS);
        System.debug('refgroupmp ' + refGroupPracticeUniqueCodeVsCCDS);
        System.debug('refdridmp ' + refDrIdUniqueCodeVsCCDS);
        System.debug('=========================================='); 
} // big for loop ends here
    
Map<String,ID> regionMap=new Map<String,ID>();
Map<String,ID> practiceMap = new Map<String,ID>();
Map<String,ID> siteMap = new Map<String,ID>();
Map<String,ID> carrierCodePayerAccountMap = new Map<String, ID>();

Map<String,ID> modalityCodeCareSpecialtyMap= new Map<String, ID>();
Map<String,ID> callCenterMap = new Map<String,ID>();
Map<String,ID> fakeCallCenterMap = new Map<String,ID>();
Map<String,ID> procedureCodeHealthCareProcedureMap=new Map<String,ID>();
Map<String,ID> refGroupPracticeMap=new Map<String,ID>();
Map<String,ID> refDrIdMap=new Map<String,ID>();

List<Account> listOfAccounts = [SELECT Id, Name, RecordType.Name, DH_RIS_Unique_Code__c,DH_Physician_Formula_Id__c,DH_Physician_Id__c
                       FROM Account
                       WHERE (RecordType.Name=:DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME AND DH_RIS_Unique_Code__c IN :regionUniqueCode) 
                       OR 
                       (RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.SITE_RECORD_TYPE_NAME AND DH_RIS_Unique_Code__c IN :siteUniqueCode ) 
                       OR
                       (RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.PAYER_RECORD_TYPE_NAME AND DH_RIS_Unique_Code__c IN :carrierUniqueCode)
                       OR
                       (RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.PRACTICE_RECORD_TYPE_NAME AND DH_RIS_Unique_Code__c IN :practiceUniqueCode)
                       OR
                       (RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.REF_GROUP_PRACTICE_NAME_NAME AND DH_RIS_Unique_Code__c IN :refGroupPracticeUniqueCode)
                       OR
                       (RecordType.Name = :DH_ExclusionDenormalizeGlobalConstants.REF_DR_PRACTICE_ID_NAME AND DH_Physician_Formula_Id__c IN :refDrIdUniqueCode)                        
                      ];
System.debug('LOA => ' + listOfAccounts);
for(Account acc : listOfAccounts){
    System.debug('Prasanna account ' + acc.RecordTypeId +' '+refDrIdId + ' for' +acc.DH_Physician_Formula_Id__c  );
    if(acc.DH_RIS_Unique_Code__c != null && acc.RecordTypeId == risRec ){
        regionMap.put(acc.DH_RIS_Unique_Code__c, acc.Id);
    }
    if(acc.DH_RIS_Unique_Code__c != null && acc.RecordTypeId == practiceRec){
        practiceMap.put(acc.DH_RIS_Unique_Code__c, acc.Id);        
    }
    if(acc.DH_RIS_Unique_Code__c != null && acc.RecordTypeId == siteRec ){
        siteMap.put(acc.DH_RIS_Unique_Code__c, acc.Id);
    } 
    if(acc.DH_RIS_Unique_Code__c != null && acc.RecordTypeId == payerRec){
        carrierCodePayerAccountMap.put(acc.DH_RIS_Unique_Code__c,acc.Id);
        
    }
    if( acc.DH_RIS_Unique_Code__c !=null && acc.RecordTypeId == refPracticeName){
        refGroupPracticeMap.put(acc.DH_RIS_Unique_Code__c,acc.Id);
    }
    if(acc.DH_Physician_Formula_Id__c!= null && acc.RecordTypeId == refDrIdId){
        System.debug('Prasanna refdr map ' + acc.DH_Physician_Formula_Id__c);
        refDrIdMap.put(acc.DH_Physician_Formula_Id__c,acc.Id);
    }
}
                     
   for(CareSpecialty cs: [select Id, SpecialtyCode,CareSpecialty_External_ID__c  from CareSpecialty where RecordType.Name= :DH_ExclusionDenormalizeGlobalConstants.CARE_SPECIALITY_MARKETING_RECORD_TYPE_NAME AND SpecialtyCode IN :modalityUniqueCode  ]){
       if(cs.CareSpecialty_External_ID__c !=null){
           modalityCodeCareSpecialtyMap.put(cs.CareSpecialty_External_ID__c , cs.Id);
       }
   }
   for(HealthCareProcedure hp:[Select id, DH_RIS_Healthcare_Procedure__c from HealthCareProcedure WHERE RecordType.Name= :DH_ExclusionDenormalizeGlobalConstants.HEALTHCARE_PROCEDURE_MARKETING_RECORD_TYPE_NAME AND DH_RIS_Healthcare_Procedure__c IN :procedureUniqueCode  ]){
       if(hp.DH_RIS_Healthcare_Procedure__c!=null){
           procedureCodeHealthCareProcedureMap.put(hp.DH_RIS_Healthcare_Procedure__c,hp.Id);
       }
   }
   
   for(DH_Call_Center__c cc :  [select Name, DH_Call_Center_Code__c from DH_Call_Center__c WHERE DH_Call_Center_Code__c IN :callCenterUniqueCode  ]){
       if(cc.DH_Call_Center_Code__c!=null){
           callCenterMap.put(cc.DH_Call_Center_Code__c,cc.Id);
       }
   }
    for(DH_Call_Center__c cc :  [select Name, DH_Call_Center_Code__c from DH_Call_Center__c WHERE DH_Call_Center_Code__c IN :fakeCallCenterUniqueCode  ]){
       if(cc.DH_Call_Center_Code__c!=null){
           fakeCallCenterMap.put(cc.DH_Call_Center_Code__c,cc.Id);
       }
   }

   
    Map<Id, ExclusionLookupWrapper> ccdsIdVsWrapperMap = new Map<Id, ExclusionLookupWrapper>();
    List<String> invalidRegionUCs = new List<String>();

    for(String s:regionUniqueCode){
        if(regionMap.get(s)==null){
            System.debug('inside null condition in regionMap');
            invalidRegionUCs.add(s);
            for(DH_Call_Center_Data_Sheet__c rec : regionUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> regionErrors = errorMap.get('region');
                    regionErrors.add(s.split('_')[0]);
                    errorMap.put('region', regionErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>{s.split('_')[0]});
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
        }
    }
   
    for(String s: practiceUniqueCode){
        if(invalidRegionUCs.contains(createRegionCode(s.split('_')[0], DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME))){
            continue;
        }
        if(practiceMap.get(s)==null){
            System.debug('inside null condition in practiceMap');
            for(DH_Call_Center_Data_Sheet__c rec : practiceUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> practiceErrors = errorMap.get('practice');
                    practiceErrors.add(s.split('_')[1]);
                    errorMap.put('practice', practiceErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>{s.split('_')[1]});
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
            //System.debug('ccdsIdVsWrapperMap inside practiceuc loop '+ccdsIdVsWrapperMap);
        }
    }

    for(String s: siteUniqueCode){
        if(invalidRegionUCs.contains(createRegionCode(s.split('_')[0], DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME))){
            continue;
        }
        if(siteMap.get(s)==null){
            System.debug('inside null condition in siteMap');
            for(DH_Call_Center_Data_Sheet__c rec : siteUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> siteErrors = errorMap.get('site');
                    siteErrors.add(s.split('_')[1]);
                    errorMap.put('site', siteErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>{s.split('_')[1]});
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
        }
    }

    for(String s: modalityUniqueCode){
        if(invalidRegionUCs.contains(createRegionCode(s.split('_')[0], DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME))){
            continue;
        }
        if(modalityCodeCareSpecialtyMap.get(s)==null){
            System.debug('inside null condition in modalityMap');
            for(DH_Call_Center_Data_Sheet__c rec : modalityUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> modalityErrors = errorMap.get('modality');
                    modalityErrors.add(s.split('_')[1]);
                    errorMap.put('modality', modalityErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>{s.split('_')[1]});
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
        }
    }
    
    for(String s:procedureUniqueCode){
        if(invalidRegionUCs.contains(createRegionCode(s.split('_')[0], DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME))){
            continue;
        }
        if(s != null && procedureCodeHealthCareProcedureMap.get(s)==null){
            System.debug('inside null condition in procedureMap');
            for(DH_Call_Center_Data_Sheet__c rec : procedureUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> procedureErrors = errorMap.get('procedure');
                    procedureErrors.add(s.split('_')[1]);
                    errorMap.put('procedure', procedureErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>{s.split('_')[1]});
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
        }
    }
    
    for(String s:carrierUniqueCode){
        if(invalidRegionUCs.contains(createRegionCode(s.split('_')[0], DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME))){
            continue;
        }
        if(carrierCodePayerAccountMap.get(s)==null){
            System.debug('inside null condition in carrierMap');
            for(DH_Call_Center_Data_Sheet__c rec : carrierUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> carrierErrors = errorMap.get('carrier');
                    carrierErrors.add(s.split('_')[1]);
                    errorMap.put('carrier', carrierErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>{s.split('_')[1]});
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
        }
    }
    
    for(String s:callCenterUniqueCode){
        if(callCenterMap.get(s)==null){
            System.debug('inside null condition in callCenterMap');
            for(DH_Call_Center_Data_Sheet__c rec : callCenterUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> callCenterErrors = errorMap.get('callCenter');
                    callCenterErrors.add(s);
                    errorMap.put('callCenter', callCenterErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>{s});
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
       }
    }
    
    for(String s:fakeCallCenterUniqueCode){
        if(fakeCallCenterMap.get(s)==null){
            System.debug('inside null condition in fakeCallCenterMap');
            for(DH_Call_Center_Data_Sheet__c rec : fakeCallCenterUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> fakeCallCenterErrors = errorMap.get('fakeCallCenter');
                    fakeCallCenterErrors.add(s);
                    errorMap.put('fakeCallCenter', fakeCallCenterErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>{s});
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
       }
    }

    for(String s:refGroupPracticeUniqueCode){
        if(invalidRegionUCs.contains(createRegionCode(s.split('_')[0], DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME))){
            continue;
        }
        if(RefGroupPracticeMap.get(s)==null){
            System.debug('inside null condition in refgroupmap');
            for(DH_Call_Center_Data_Sheet__c rec : refGroupPracticeUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> refGroupErrors = errorMap.get('refGroupPractice');
                    refGroupErrors.add(s.split('_')[1]);
                    errorMap.put('refGroupPractice', refGroupErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>{s.split('_')[1]});
                    errorMap.put('refDrId', new Set<String>());
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
        }
    }

    for(String s:refDrIdUniqueCode){
        if(invalidRegionUCs.contains(createRegionCode(s.split('_')[0], DH_ExclusionDenormalizeGlobalConstants.REGION_RECORD_TYPE_NAME))){
            continue;
        }
        
        if(refDrIdMap.get(s)==null){
            System.debug('inside null condition in refDrIdmap');
            for(DH_Call_Center_Data_Sheet__c rec : refDrIdUniqueCodeVsCCDS.get(s)){
                if(ccdsIdVsWrapperMap.containsKey(rec.Id)){
                    ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(rec.Id);
                    Map<String, Set<String>> errorMap = elw.errorMap;

                    Set<String> refDrErrors = errorMap.get('refDrId');
                    refDrErrors.add(s.split('_')[1]);
                    errorMap.put('refDrId', refDrErrors);

                    elw.errorMap = errorMap;
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
                else{
                    Map<String, Set<String>> errorMap = new Map<String, Set<String>>();
                    errorMap.put('region', new Set<String>());
                    errorMap.put('practice', new Set<String>());
                    errorMap.put('site', new Set<String>());
                    errorMap.put('modality', new Set<String>());
                    errorMap.put('procedure', new Set<String>());
                    errorMap.put('carrier', new Set<String>());
                    errorMap.put('callCenter', new Set<String>());
                    errorMap.put('fakeCallCenter', new Set<String>());
                    errorMap.put('refGroupPractice', new Set<String>());
                    errorMap.put('refDrId', new Set<String>{s.split('_')[1]});
                    ExclusionLookupWrapper elw = new ExclusionLookupWrapper(rec, rec.Id, errorMap);
                    ccdsIdVsWrapperMap.put(rec.Id, elw);
                }
            }
        }
    }

    //System.debug('ccdsIdVsWrapperMap '+ccdsIdVsWrapperMap);
    // System.debug(ccdsIdVsWrapperMap.get('a0TVa000004IqFZMA0').ccdsId);
    // System.debug(ccdsIdVsWrapperMap.get('a0TVa000004Ue90MAC').ccdsId);
    // System.debug('ccdsIdVsWrapperMap '+ccdsIdVsWrapperMap.get('a0TVa000004IqFZMA0').errorMap);
    // System.debug('ccdsIdVsWrapperMap '+ccdsIdVsWrapperMap.get('a0TVa000004Ue90MAC').errorMap);
    
    
    for(Id recId : ccdsIdVsWrapperMap.keySet()){
        ExclusionLookupWrapper elw = ccdsIdVsWrapperMap.get(recId);
        Map<String, Set<String>> errorMap = elw.errorMap;
        String finalErrorString = '';
        for(String uniqueCode : errorMap.keySet()){
            Set<String> errors = errorMap.get(uniqueCode);
            if(uniqueCode == 'region' && errors.size() > 0){
                finalErrorString += ('Region - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'practice' && errors.size() > 0){
                finalErrorString += ('Practice - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'site' && errors.size() > 0){
                finalErrorString += ('Site - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'modality' && errors.size() > 0){
                finalErrorString += ('Modality - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'procedure' && errors.size() > 0){
                finalErrorString += ('Procedure - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'carrier' && errors.size() > 0){
                finalErrorString += ('Carrier - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'callCenter' && errors.size() > 0){
                finalErrorString += ('Call Center - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'fakeCallCenter' && errors.size()>0){
                finalErrorString +=('Fake Call Center - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'refGroupPractice' && errors.size() > 0){
                finalErrorString += ('Referring Group Practice - ' + String.join(errors, ',') + ' not present. ');
            }
            else if(uniqueCode == 'refDrId' && errors.size() > 0){
                finalErrorString += ('Referring Dr Id - ' + String.join(errors, ',') + ' not present. ');
            }
        }
        if(finalErrorString.length() > 0){
            elw.ccds.addError(finalErrorString);
        }
    }
}
}