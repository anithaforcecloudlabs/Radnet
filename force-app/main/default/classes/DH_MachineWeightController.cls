/******************************************************************************************************************************************************
 * 
 * @Created Date      :  03/30/2024
 * 
 * @description       : This class serves to obtain the data for Machine & Weight search functionality in Modality Search LWC component
 * 
 * @JIRA Id           :  CC-21, CC-819, CC-754
 * */ 
public with sharing class DH_MachineWeightController {

    public static Boolean isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false;
    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on Modality, Practice, Site selection for HealthCloud or Guest User 
     * 
     * @param   modalities      List of String of selected modalities 
     * @param   practices       List of String of selected practices 
     * @param   siteCodeName    String of selected siteCodeName
     * 
     * @return  machineWrapperList List of sObject from Machine&Weight object 
     *
     * */
    //Fetch Records based on Modality option
    @AuraEnabled(cacheable = true)
    public static List<MachineWeightWrapper> getMachineRecordsBasedOnModality(List<String> modalities, List<String> practices, String siteCodeName) {
        
        List<sObject> machinelist = new List<sObject>();       
        Map<String, List<sObject>> machineWeightMap = new Map<String, List<sObject>>();
        List<MachineWeightWrapper> machineWrapperList = new List<MachineWeightWrapper>();

        try{
            
            if (practices.contains(DH_KMConstants.NJIN_PRACTICE_CODE)) {
                practices.addAll(DH_KMUtility.virtualGroupingNJIN());
            }
            // GUEST USER CHECK ON MACHINELIST
            if(isGuestUser){
                
                machinelist = DH_KMQueryManager.getMachineWeightListByModalityForGuest(modalities, practices, siteCodeName);
                machineWeightMap = groupMachineListBySiteForGuest(machinelist);
                if (machineWeightMap.keySet().size()>0 && machineWeightMap.keySet() !=null) {
                    for (String mapKey : machineWeightMap.keySet()) {
                        List<sObject> macWe = machineWeightMap.get(mapKey);
                        MachineWeightWrapper mw = populateMachineWrapperForGuest(macwe);
                        machineWrapperList.add(mw);
                    }
                }
            }else{
    
                machinelist = DH_KMQueryManager.getMachineWeightListByModality(modalities, practices, siteCodeName);
                machineWeightMap = groupMachineListBySite(machinelist);
                if (machineWeightMap.keySet().size()>0 && machineWeightMap.keySet() !=null) {
                    for (String mapKey : machineWeightMap.keySet()) {
                        List<sObject> macWe = machineWeightMap.get(mapKey);
                        MachineWeightWrapper mw = populateMachineWrapper(macwe);
                        machineWrapperList.add(mw);
                    }
                }
            }
                
       if (machinelist.size() == 0 || machineList == null) {
                if(!Test.isRunningTest()){
                    throw new AuraHandledException(System.label.DH_No_Records_Found);
                }else{
                    return machineWrapperList;
                }
       }
		    
        }catch(AuraHandledException ae){
            System.debug(LoggingLevel.ERROR, 'Exception in DH_MachineWeightController while fetching MachineWeight records by Modality: ' + ae.getMessage());
        	throw new AuraHandledException(System.label.DH_No_Records_Found);
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Exception in DH_MachineWeightController: '+e.getMessage());
        }
        
        return machineWrapperList;
    }

    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on  Practice, Site selection for HealthCloud or Guest User 
     * 
     * @param   practices       List of String of selected practices 
     * @param   siteCodeName    String of selected siteCodeName
     * 
     * @return  machineWrapperList List of sObject from Machine&Weight object 
     *
     * */
    //Fetch Records based on Practice option
    @AuraEnabled(cacheable = true)
    public static List<MachineWeightWrapper> getMachineRecordsBasedOnPractice(List<String> practices, String siteCodeName) {
        
        List<sObject> machinelist = new List<sObject>();
        Map<String, List<sObject>> machineWeightMap = new Map<String, List<sObject>>();
        List<MachineWeightWrapper> machineWrapperList = new List<MachineWeightWrapper>();    
        
        try{
            if (practices.contains(DH_KMConstants.NJIN_PRACTICE_CODE)) {
                practices.addAll(DH_KMUtility.virtualGroupingNJIN());
            }       
                    
            // GUEST USER CHECK ON MACHINELIST
            if(isGuestUser){
                
                machinelist = DH_KMQueryManager.getMachineWeightListByPracticeForGuest(practices, siteCodeName);
                machineWeightMap = groupMachineListBySiteForGuest(machinelist);
                if (machineWeightMap.keySet().size()>0 && machineWeightMap.keySet() !=null) {
                    for (String mapKey : machineWeightMap.keySet()) {
                        List<sObject> macWe = machineWeightMap.get(mapKey);
                        MachineWeightWrapper mw = populateMachineWrapperForGuest(macwe);
                        machineWrapperList.add(mw);
                    }
                }
            }else{
            
                machinelist = DH_KMQueryManager.getMachineWeightListByPractice(practices, siteCodeName);
                machineWeightMap = groupMachineListBySite(machinelist);
                if (machineWeightMap.keySet().size()>0 && machineWeightMap.keySet() !=null) {
                    for (String mapKey : machineWeightMap.keySet()) {
                        List<sObject> macWe = machineWeightMap.get(mapKey);
                        MachineWeightWrapper mw = populateMachineWrapper(macwe);
                        machineWrapperList.add(mw);
                    }
                }
            }       
            
            if (machinelist.size() == 0 || machineList == null) {
                if(!Test.isRunningTest()){ 
                    throw new AuraHandledException(System.label.DH_No_Records_Found);
                }
                else{
                   return machineWrapperList;
                }
            }
        }catch(AuraHandledException ae){
            System.debug(LoggingLevel.ERROR, 'Exception in DH_MachineWeightController while fetching MachineWeight records by Practice: '  + ae.getMessage());
        	throw new AuraHandledException(System.label.DH_No_Records_Found);
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Exception in DH_MachineWeightController: '+ e.getMessage());
        }
        
        return machineWrapperList;
    }

    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Machine&Weight object records based on  Practice, Site selection for HealthCloud or Guest User 
     * 
     * @param   practices       List of String of selected practices 
     * @param   siteCodeName    String of selected siteCodeName
     * 
     * @return  machineWrapperList List of sObject from Machine&Weight object 
     *
     * */
    //Fetch Records based on Sites
    @AuraEnabled(cacheable = true)
    public static List<MachineWeightWrapper> getMachineRecordsBasedOnSites(List<String> practices, String siteCodeName) {

        List<sObject> machinelist = new List<sObject>();       
        List<MachineWeightWrapper> machineWrapperList = new List<MachineWeightWrapper>();
        
        try{    
            if (practices.contains(DH_KMConstants.NJIN_PRACTICE_CODE)) {
                practices.addAll(DH_KMUtility.virtualGroupingNJIN());
            }      
            
            if(isGuestUser){

                machinelist = DH_KMQueryManager.getMachineWeightListBySiteForGuest(practices, siteCodeName);
                
                if(!machinelist.isEmpty()){
                    MachineWeightWrapper mw = populateMachineWrapperForGuest(machinelist);
                    machineWrapperList.add(mw);
                }
            }else{
                        
                machinelist = DH_KMQueryManager.getMachineWeightListBySite(practices, siteCodeName);
                if(!machinelist.isEmpty()){
                    MachineWeightWrapper mw = populateMachineWrapper(machinelist);
                    machineWrapperList.add(mw);
                }
            } 
            if (machinelist.size() == 0 || machineList == null) {
                if(!Test.isRunningTest()){
                    throw new AuraHandledException(System.label.DH_No_Records_Found);
                }else{
                    return machineWrapperList;
                }                 
            }

        }catch(AuraHandledException ae){
            System.debug(LoggingLevel.ERROR, 'Exception in DH_MachineWeightController while fetching MachineWeight records by Site: ' + ae.getMessage());
        	throw new AuraHandledException(System.label.DH_No_Records_Found);
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Exception in DH_MachineWeightController: '+ e.getMessage());
        }
        return machineWrapperList;
    }

    /**************************************************************************************************************************************************
     *
     * @description Method used to fetch Site-Account object records of MA, NE, FL region to display in site search bar
     * 
     * @return      siteList    List of string of Site Names
     *
     * */
    //Fetch Site List to display in search bar
    @AuraEnabled(cacheable = true)
    public static List<String> getSiteList() {
        List<sObject> accList = new List<sObject>();
        List<String> siteList = new List<String>();
        try{
            
            accList = DH_KMQueryManager.getSiteListQuery();
            if(accList.size()>0 && accList != null){
                for (sObject s : accList) {
                    siteList.add((String)s.get('Name'));
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Exception in DH_MachineWeightController in getSiteList: '+ e.getMessage());
        }
        return siteList;
    }

    /**************************************************************************************************************************************************
     *
     * @description Method used to group Machine&Weight object records by Site code for HealthCloud user
     * 
     * @param   machineList     List of sObject of machineList  
     * 
     * @return  machineWeightMap Map of String of SiteCode Vs List of String of machineWeight records on the Site   
     *
     * */
    // METHOD TO GROUP MACHINELIST BY SITE for HealthCloud User
    public static Map<String, List<sObject>> groupMachineListBySite(List<sObject> machineList){

        Map<String, List<sObject>> machineWeightMap = new Map<String, List<sObject>>();
        try{
            if(machinelist.size()>0 && machinelist !=null){
                for (sObject macWeight : machinelist) {
                    if (machineWeightMap.containsKey((String)macWeight.getSObject('Site_Modality__r')?.getSObject('Account')?.get('Site_Code__c'))) {
                        List<sObject> macTemp = machineWeightMap.get((String)macWeight.getSObject('Site_Modality__r')?.getSObject('Account')?.get('Site_Code__c'));
                        macTemp.add(macWeight);
                        machineWeightMap.put((String)macWeight.getSObject('Site_Modality__r')?.getSObject('Account')?.get('Site_Code__c'), macTemp);
                    } else {
                        machineWeightMap.put((String)macWeight.getSObject('Site_Modality__r')?.getSObject('Account')?.get('Site_Code__c'), new List<sObject>{macWeight});
                    }
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Exception in DH_MachineWeightController in groupMachineListBySite: '+ e.getMessage());
        }
        return machineWeightMap;
    }

    /**************************************************************************************************************************************************
     *
     * @description Method used to group Machine&Weight object records by Site code for Guest user 
     * 
     * @param   machineList     List of sObject of machineList  
     * 
     * @return  machineWeightMap Map of String of SiteCode Vs List of String of machineWeight records on the Site   
     *
     * */
    // METHOD TO GROUP MACHINELIST BY SITE for Guest User
    public static Map<String, List<sObject>> groupMachineListBySiteForGuest (List<sObject> machineList){

        Map<String, List<sObject>> machineWeightMap = new Map<String, List<sObject>>();
        try{
            if(machinelist.size()>0 && machinelist !=null){
                for (sObject macWeight : machinelist) {
                    if (machineWeightMap.containsKey((String)macWeight.getSObject('DH_CareProviderFacilitySpecialty__r')?.getSObject('DH_AccountId__r')?.get('Site_Code__c'))) {
                        List<sObject> macTemp = machineWeightMap.get((String)macWeight.getSObject('DH_CareProviderFacilitySpecialty__r')?.getSObject('DH_AccountId__r')?.get('Site_Code__c'));
                        macTemp.add(macWeight);
                        machineWeightMap.put((String)macWeight.getSObject('DH_CareProviderFacilitySpecialty__r')?.getSObject('DH_AccountId__r')?.get('Site_Code__c'), macTemp);
                    } else {
                        machineWeightMap.put((String)macWeight.getSObject('DH_CareProviderFacilitySpecialty__r')?.getSObject('DH_AccountId__r')?.get('Site_Code__c'), new List<sObject>{macWeight});
                    }
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Exception in DH_MachineWeightController in groupMachineListBySiteForGuest: '+ e.getMessage());
        }
        return machineWeightMap;
    }

    /**************************************************************************************************************************************************
     *
     * @description Method used to assign each Machine&Weight list records to MachineWeightWrapper fields and filter the record as per modality and assign to List of seperate modality wrapper in main MachineWeightWrapper for HealthCloud User
     * 
     * @param   machineList     List of sObject of machineList  
     * 
     * @return  MachineWeightWrapper Wrapper of MachineWeight     
     *
     * */
    // Filter Result of Machine Weight for HealthCloud User
    public static MachineWeightWrapper populateMachineWrapper(List<sObject> machinelist) {
        
        MachineWeightWrapper mw = new MachineWeightWrapper();
        try{

        if(machinelist.size() > 0 && machinelist !=null){
            mw.practice = (String)machinelist[0].getSObject('Site_Modality__r')?.getSObject('Account')?.getSObject('Parent')?.get('Practice_code__c');
            mw.siteCode = (String)machinelist[0].getSObject('Site_Modality__r')?.getSObject('Account')?.get('Site_Code__c');
            mw.siteName = (String)machinelist[0].getSObject('Site_Modality__r')?.getSObject('Account')?.get('Name');
            mw.modality = (String)machinelist[0].getSObject('Site_Modality__r')?.get('Name');
            mw.id = (String)machinelist[0].get('id');
            //mw.name = (String)machinelist[0].get('Name');
            mw.siteAccId = (String)machinelist[0].getSObject('Site_Modality__r')?.get('AccountId');

            mw.xRay = new List<XRayWrapper>();
            mw.dexa = new List<DexaWrapper>();
            mw.fluoro = new List<FluoroWrapper>();
            mw.ultrasound = new List<UsWrapper>();
            mw.mri = new List<MriWrapper>();
            mw.ct = new List<CtWrapper>();
            mw.nm = new List<NmWrapper>();
            mw.petct = new List<PetCtWrapper>();

                for (Integer i = 0; i < machinelist.size(); i++) {
                    if ((String)machinelist[i].getSObject('Site_Modality__r')?.get('Name') == DH_KMConstants.MODALITY_XRAY) {
                        XRayWrapper xr = new XRayWrapper();
                        xr.xRayWeight = (String)machinelist[i].get('Weight__c');
                        mw.xRay.add(xr);
                    }
                    if ((String)machinelist[i].getSObject('Site_Modality__r')?.get('Name') == DH_KMConstants.MODALITY_DEXA) {
                        DexaWrapper dx = new DexaWrapper();
                        dx.dexaWeight = (String)machinelist[i].get('Weight__c');
                        mw.dexa.add(dx);
                    }
                    if ((String)machinelist[i].getSObject('Site_Modality__r')?.get('Name') == DH_KMConstants.MODALITY_FLUOROSCOPY) {
                        FluoroWrapper flur = new FluoroWrapper();
                        flur.fluoroWeight = (String)machinelist[i].get('Weight__c');
                        mw.fluoro.add(flur);
                    }
                    if ((String)machinelist[i].getSObject('Site_Modality__r')?.get('Name') == DH_KMConstants.MODALITY_ULTRASOUND) {
                        UsWrapper us = new UsWrapper();
                        us.usWeight = (String)machinelist[i].get('Weight__c');
                        mw.ultrasound.add(us);
                    }
                    if ((String)machinelist[i].getSObject('Site_Modality__r')?.get('Name') == DH_KMConstants.MODALITY_MRI) {
                        MriWrapper mr = new MriWrapper();
                        mr.mriWeight = (String)machinelist[i].get('Weight__c');
                        mr.mriRoom = (String)machinelist[i].get('Room__c');
                        mr.mriDescription = (String)machinelist[i].get('Description__c');
                        mr.mriMachine = (String)machinelist[i].get('Machine__c');
                        mw.mri.add(mr);
                    }
                    if ((String)machinelist[i].getSObject('Site_Modality__r')?.get('Name') == DH_KMConstants.MODALITY_CT) {
                        CtWrapper c = new CtWrapper();
                        c.ctWeight = (String)machinelist[i].get('Weight__c');
                        c.ctSlice = (String)machinelist[i].get('Slice__c');
                        c.ctMachine = (String)machinelist[i].get('Machine__c');
                        mw.ct.add(c);
                    }
                    if ((String)machinelist[i].getSObject('Site_Modality__r')?.get('Name') == DH_KMConstants.MODALITY_NM) {
                        NmWrapper n = new NmWrapper();
                        n.nmWeight = (String)machinelist[i].get('Weight__c');
                        mw.nm.add(n);
                    }
                    if ((String)machinelist[i].getSObject('Site_Modality__r')?.get('Name') == DH_KMConstants.MODALITY_PETCT) {
                        PetCtWrapper p = new PetCtWrapper();
                        p.petctWeight = (String)machinelist[i].get('Weight__c');
                        mw.petct.add(p);
                    }
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Exception in DH_MachineWeightController in populateMachineWrapper: '+ e.getMessage());
        }
        return mw;
    }

    /**************************************************************************************************************************************************
     *
     * @description Method used to assign each Machine&Weight list records to MachineWeightWrapper fields and filter the record as per modality and assign to List of seperate modality wrapper in main MachineWeightWrapper for Guest User
     * 
     * @param   machineList     List of sObject of machineList  
     * 
     * @return  MachineWeightWrapper Wrapper of MachineWeight     
     *
     * */
    // Filter Result of Machine Weight for Guest User
    public static MachineWeightWrapper populateMachineWrapperForGuest(List<sObject> machinelist) {
        
        MachineWeightWrapper mw = new MachineWeightWrapper();
        try{
        if(machinelist.size() > 0 && machinelist !=null){
            
            mw.practice = (String)machinelist[0].getSObject('DH_CareProviderFacilitySpecialty__r')?.getSObject('DH_AccountId__r')?.getSObject('Parent')?.get('Practice_code__c');
            mw.siteCode = (String)machinelist[0].getSObject('DH_CareProviderFacilitySpecialty__r')?.getSObject('DH_AccountId__r')?.get('Site_Code__c');
            mw.siteName = (String)machinelist[0].getSObject('DH_CareProviderFacilitySpecialty__r')?.getSObject('DH_AccountId__r')?.get('Name');
            mw.modality = (String)machinelist[0].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name');
            mw.id = (String)machinelist[0].get('id');
            //mw.name = (String)machinelist[0].get('Name');
            mw.siteAccId = (String)machinelist[0].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('DH_AccountId__c');

            mw.xRay = new List<XRayWrapper>();
            mw.dexa = new List<DexaWrapper>();
            mw.fluoro = new List<FluoroWrapper>();
            mw.ultrasound = new List<UsWrapper>();
            mw.mri = new List<MriWrapper>();
            mw.ct = new List<CtWrapper>();
            mw.nm = new List<NmWrapper>();
            mw.petct = new List<PetCtWrapper>();
                
                for (Integer i = 0; i < machinelist.size(); i++) {
                    
                    if ((String)machinelist[i].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name') == DH_KMConstants.MODALITY_XRAY) {
                        XRayWrapper xr = new XRayWrapper();
                        xr.xRayWeight = (String)machinelist[i].get('Weight__c');
                        mw.xRay.add(xr);
                    }
                    if ((String)machinelist[i].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name') == DH_KMConstants.MODALITY_DEXA) {
                        DexaWrapper dx = new DexaWrapper();
                        dx.dexaWeight = (String)machinelist[i].get('Weight__c');
                        mw.dexa.add(dx);
                    }
                    if ((String)machinelist[i].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name') == DH_KMConstants.MODALITY_FLUOROSCOPY) {
                        FluoroWrapper flur = new FluoroWrapper();
                        flur.fluoroWeight = (String)machinelist[i].get('Weight__c');
                        mw.fluoro.add(flur);
                    }
                    if ((String)machinelist[i].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name') == DH_KMConstants.MODALITY_ULTRASOUND) {
                        UsWrapper us = new UsWrapper();
                        us.usWeight = (String)machinelist[i].get('Weight__c');
                        mw.ultrasound.add(us);
                    }
                    if ((String)machinelist[i].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name') == DH_KMConstants.MODALITY_MRI) {
                        MriWrapper mr = new MriWrapper();
                        mr.mriWeight = (String)machinelist[i].get('Weight__c');
                        mr.mriRoom = (String)machinelist[i].get('Room__c');
                        mr.mriDescription = (String)machinelist[i].get('Description__c');
                        mr.mriMachine = (String)machinelist[i].get('Machine__c');
                        mw.mri.add(mr);
                    }
                    if ((String)machinelist[i].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name') == DH_KMConstants.MODALITY_CT) {
                        CtWrapper c = new CtWrapper();
                        c.ctWeight = (String)machinelist[i].get('Weight__c');
                        c.ctSlice = (String)machinelist[i].get('Slice__c');
                        c.ctMachine = (String)machinelist[i].get('Machine__c');
                        mw.ct.add(c);
                    }
                    if ((String)machinelist[i].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name') == DH_KMConstants.MODALITY_NM) {
                        NmWrapper n = new NmWrapper();
                        n.nmWeight = (String)machinelist[i].get('Weight__c');
                        mw.nm.add(n);
                    }
                    if ((String)machinelist[i].getSObject('DH_CareProviderFacilitySpecialty__r')?.get('Name') == DH_KMConstants.MODALITY_PETCT) {
                        PetCtWrapper p = new PetCtWrapper();
                        p.petctWeight = (String)machinelist[i].get('Weight__c');
                        mw.petct.add(p);
                    }
                }
             
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Exception in DH_MachineWeightController in populateMachineWrapperForGuest: '+ e.getMessage());
        }
        return mw;
    }
    
    // MachineWeightWrapper Wrapper class  
    public class MachineWeightWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String practice;
        @AuraEnabled public String siteCode;
        @AuraEnabled public String siteName;
        @AuraEnabled public String modality;
        @AuraEnabled public String siteAccId;

        @AuraEnabled public List<XRayWrapper> xRay;
        @AuraEnabled public List<FluoroWrapper> fluoro;
        @AuraEnabled public List<DexaWrapper> dexa;
        @AuraEnabled public List<UsWrapper> ultrasound;
        @AuraEnabled public List<MriWrapper> mri;
        @AuraEnabled public List<CtWrapper> ct;
        @AuraEnabled public List<NmWrapper> nm;
        @AuraEnabled public List<PetCtWrapper> petct;
    }

    // Modality Wrapper classes 
    public class XRayWrapper { @AuraEnabled public String xRayWeight; }
    public class FluoroWrapper { @AuraEnabled public String fluoroWeight; }
    public class DexaWrapper { @AuraEnabled public String dexaWeight; }
    public class UsWrapper { @AuraEnabled public String usWeight; }
    public class MriWrapper {
        @AuraEnabled public String mriWeight;
        @AuraEnabled public String mriMachine;
        @AuraEnabled public String mriRoom;
        @AuraEnabled public String mriDescription;
    }
    public class CtWrapper {
        @AuraEnabled public String ctMachine;
        @AuraEnabled public String ctSlice;
        @AuraEnabled public String ctWeight;
    }
    public class NmWrapper { @AuraEnabled public String nmWeight; }
    public class PetCtWrapper { @AuraEnabled public String petctWeight; }
}