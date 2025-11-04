/******************************************************************************************************************************************************
 * 
 * @Created Date      :  3/30/2024
 * 
 * @description       : Test Class to cover DH_MachineWeightController apex class
 * 
 * @JIRA Id           :  CC-21, CC-819, CC-754
 * */ 
@isTest(SeeAllData=false)
private class DH_MachineWeightController_Test {
    @TestSetup 
    static void dataSetup(){
 
        String testUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name=: DH_KMConstants.RADNET_SCHEDULER LIMIT 1];
        User u = new User(
            Alias = 'rsTest', 
            Email='radSchTest@testorg.com',
            EmailEncodingKey='UTF-8', 
            LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=testUserName);

        insert u;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.MODALITY_SEARCH_PERMISSION_SET];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        
        insert psa;
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: DH_KMConstants.HEALTHCLOUD_FOUNDATION_PERMISSION_SET];
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        psa1.AssigneeId = u.Id;
        psa1.PermissionSetId = ps1.Id;
        
        insert psa1;

        String guestUserName = 'guestuser' + DateTime.now().getTime() + '@testorg.com';
        Profile guestProfile = [SELECT Id, name FROM Profile WHERE Name =: DH_KMConstants.RADNET_COMMUNITY_PROFILE LIMIT 1];
        User guestUser = new User(
            Alias = 'guestT', 
            Email='guestuser@test.com', 
            FirstName = 'Guest', LastName = 'User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = guestProfile.Id,
            EmailEncodingKey='UTF-8',
            TimeZoneSidKey='America/Los_Angeles',
            UserName=guestUserName
        );
    
        insert guestUser;
        
        Id practiceRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.PRACTICE_RECORD_TYPE).getRecordTypeId();
        Id siteRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.ACCOUNT_RECORDTYPE_SITE).getRecordTypeId();
        Id regionRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM).getRecordTypeId();
	
        // TEST DATA CREATE FOR HEALTHCLOUD USER
        System.runAs(u){
        List<Account> reg = new List<Account>();
        reg.add(new Account(Name= DH_KMConstants.REGION_MA,
                            Region__c = 'MA',
                            isActive = true,
                            RecordTypeId=regionRecordTypeID
                           ));
        reg.add(new Account(Name= DH_KMConstants.REGION_NE,
                            Region__c = 'NE',
                            isActive = true,
                            RecordTypeId=regionRecordTypeID
                           ));
       
        insert reg;

        List<Account> prac = new List<Account>();
        prac.add(new Account(Name='CRA', 
                        Region__c=reg[0].Id,
                        ParentId=reg[0].Id,
                        Practice_code__c='CRA',
                        RecordTypeId=practiceRecordTypeID ));  
        prac.add(new Account(Name='BII',
                        Region__c=reg[0].Id,
                        ParentId=reg[0].Id,
                        Practice_code__c='BII',
                        RecordTypeId=practiceRecordTypeID ));
        prac.add(new Account(Name='NJIN',
                        Region__c=reg[0].Id,
                        ParentId=reg[0].Id,
                        Practice_code__c='NJIN',
                        RecordTypeId=practiceRecordTypeID ));
        insert prac;

           
        List<Account> site = new List<Account>();
        site.add(new Account(Name='(GRB) Greenbelt Imaging Center', 
                        Site_Code__c='GRB',
                        ParentId = prac[0].Id,
                        AccountRegion__c=reg[0].Id,
                        Account_Practice__c=prac[0].Id,
                        Coast__c='East coast',
                        RecordTypeId=siteRecordTypeID ));
        site.add(new Account(Name='(WS) White Spruce (wite sproos)',
                        Site_Code__c='WS',
                        ParentId = prac[1].Id,
                        AccountRegion__c=reg[1].Id,
                        Account_Practice__c=prac[1].Id,
                        Coast__c='East coast',
                        RecordTypeId=siteRecordTypeID ));
        site.add(new Account(Name='(PIB) Belleville (bel-vil)',
                        Site_Code__c='PIB',
                        ParentId = prac[2].Id,
                        AccountRegion__c=reg[0].Id,
                        Account_Practice__c=prac[2].Id,
                        Coast__c='East coast',
                        RecordTypeId=siteRecordTypeID ));

        insert site;

        List<CareSpecialty> careSpec = new List<CareSpecialty>();
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_DEXA,CareSpecialty_External_ID__c='MODDEXA'));  
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_MRI,CareSpecialty_External_ID__c='MODDMRI' ));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_CT,CareSpecialty_External_ID__c='MODCT' ));   	
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_XRAY,CareSpecialty_External_ID__c='MODXRAY' )); 
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_ULTRASOUND,CareSpecialty_External_ID__c='MODUS' ));   
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_NM,CareSpecialty_External_ID__c='MODNM'));
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_PETCT,CareSpecialty_External_ID__c='MODPETCT' ));    
        careSpec.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_FLUOROSCOPY,CareSpecialty_External_ID__c='MODFL' ));      	
        insert careSpec;
                                                             
        List<CareProviderFacilitySpecialty> siteModality = new List<CareProviderFacilitySpecialty>();
        	
        	 for(integer i=0;i<3;i++) {
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_DEXA, AccountId = site[i].Id, SpecialtyId = careSpec[0].Id  ));
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_MRI, AccountId = site[i].Id, SpecialtyId = careSpec[1].Id ));
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_CT, AccountId = site[i].Id , SpecialtyId = careSpec[2].Id));   
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_XRAY, AccountId = site[i].Id , SpecialtyId = careSpec[3].Id)); 
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_ULTRASOUND, AccountId = site[i].Id , SpecialtyId = careSpec[4].Id)); 
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_NM, AccountId = site[i].Id, SpecialtyId = careSpec[5].Id));
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_PETCT, AccountId = site[i].Id , SpecialtyId = careSpec[6].Id));   
                siteModality.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_FLUOROSCOPY, AccountId = site[i].Id , SpecialtyId = careSpec[7].Id));
             }
        insert siteModality;

        // DH_CareSpecialty__c lookup
        List<DH_CareSpecialty__c> careSpecClone1 = new List<DH_CareSpecialty__c>(); 
            
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_DEXA));  
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_MRI ));
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_CT ));   	
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_XRAY )); 
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_ULTRASOUND )); 
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_NM));
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_PETCT ));    
        careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_FLUOROSCOPY ));   	

        insert careSpecClone1;
        
    // DH_CareProviderFacilitySpecialty__c lookup
    List<DH_CareProviderFacilitySpecialty__c> siteModClone1 = new List<DH_CareProviderFacilitySpecialty__c>();
                    
    for(integer i=0;i<site.size();i++) {

        siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_DEXA, DH_AccountId__c = site[i].Id, DH_SpecialtyId__c = careSpecClone1[0].Id  ));
        siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_MRI, DH_AccountId__c = site[i].Id, DH_SpecialtyId__c = careSpecClone1[1].Id ));
        siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_CT, DH_AccountId__c = site[i].Id , DH_SpecialtyId__c = careSpecClone1[2].Id));   
        siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_XRAY, DH_AccountId__c = site[i].Id , DH_SpecialtyId__c = careSpecClone1[3].Id)); 
        siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_ULTRASOUND, DH_AccountId__c = site[i].Id , DH_SpecialtyId__c = careSpecClone1[4].Id)); 
        siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_NM, DH_AccountId__c = site[i].Id, DH_SpecialtyId__c = careSpecClone1[5].Id));
        siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_PETCT, DH_AccountId__c = site[i].Id , DH_SpecialtyId__c = careSpecClone1[6].Id));   
        siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_FLUOROSCOPY, DH_AccountId__c = site[i].Id , DH_SpecialtyId__c = careSpecClone1[7].Id));   
    }
    insert siteModClone1;

        List<HL_Machine_and_Weight__c> mwList = new List<HL_Machine_and_Weight__c>();

        for(integer i=0;i<siteModality.size();i++) {
        	mwList.add(new HL_Machine_and_Weight__c( Name = 'Test machine'+i,
       		Site_Modality__c = siteModality[i].Id,
            DH_CareProviderFacilitySpecialty__c = siteModClone1[i].Id
               ));
        }
        insert mwList;
        
        }

        // TEST DATA CREATE FOR GUEST USER
        System.runAs(guestUser){
            List<Account> reg1 = new List<Account>();
            reg1.add(new Account(Name= DH_KMConstants.REGION_FL,
                                Region__c = 'FL',
                                isActive = true,
                                RecordTypeId=regionRecordTypeID
                               ));
            upsert reg1;
    
            List<Account> prac1 = new List<Account>();
            prac1.add(new Account(Name='RIA', 
                            Region__c=reg1[0].Id,
                            ParentId=reg1[0].Id,
                            Practice_code__c='RIA',
                            RecordTypeId=practiceRecordTypeID ));  
            
            upsert prac1;
            
            List<Account> site1 = new List<Account>();
            site1.add(new Account(Name='(TRA) Tradition Center', 
                            Site_Code__c='TRA',
                            AccountRegion__c=reg1[0].Id,
                            Account_Practice__c=prac1[0].Id,
                            Coast__c='East coast',
                            ParentId = prac1[0].Id,
                            RecordTypeId=siteRecordTypeID ));
            
            insert site1;
            
            // CareSpecialty lookup
	    List<CareSpecialty> careSpec1 = new List<CareSpecialty>();
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_DEXA,CareSpecialty_External_ID__c='MODDEXA'));  
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_MRI,CareSpecialty_External_ID__c='MODDMRI' ));
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_CT,CareSpecialty_External_ID__c='MODCT' ));   	
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_XRAY,CareSpecialty_External_ID__c='MODXRAY' )); 
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_ULTRASOUND,CareSpecialty_External_ID__c='MODUS' ));   
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_NM,CareSpecialty_External_ID__c='MODNM'));
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_PETCT,CareSpecialty_External_ID__c='MODPETCT' ));    
        careSpec1.add(new CareSpecialty(Name = DH_KMConstants.MODALITY_FLUOROSCOPY,CareSpecialty_External_ID__c='MODFL' ));      	
        insert careSpec1;
            // DH_CareSpecialty__c lookup
            List<DH_CareSpecialty__c> careSpecClone1 = new List<DH_CareSpecialty__c>(); 
            
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_DEXA));  
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_MRI ));
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_CT ));   	
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_XRAY )); 
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_ULTRASOUND )); 
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_NM));
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_PETCT ));    
            careSpecClone1.add(new DH_CareSpecialty__c(Name = DH_KMConstants.MODALITY_FLUOROSCOPY ));   	

            insert careSpecClone1;

            // CareProviderFacilitySpecialty lookup
            List<CareProviderFacilitySpecialty> siteModality1 = new List<CareProviderFacilitySpecialty>();
                
            for(integer i=0;i<site1.size();i++) {
               
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_DEXA, AccountId = site1[i].Id, SpecialtyId = careSpec1[0].Id  ));
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_MRI, AccountId = site1[i].Id, SpecialtyId = careSpec1[1].Id ));
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_CT, AccountId = site1[i].Id , SpecialtyId = careSpec1[2].Id));   
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_XRAY, AccountId = site1[i].Id , SpecialtyId = careSpec1[3].Id)); 
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_ULTRASOUND, AccountId = site1[i].Id , SpecialtyId = careSpec1[4].Id)); 
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_NM, AccountId = site1[i].Id, SpecialtyId = careSpec1[5].Id));
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_PETCT, AccountId = site1[i].Id , SpecialtyId = careSpec1[6].Id));   
                siteModality1.add(new CareProviderFacilitySpecialty(Name = DH_KMConstants.MODALITY_FLUOROSCOPY, AccountId = site1[i].Id , SpecialtyId = careSpec1[7].Id));
            
            }
            insert siteModality1;
            
            // DH_CareProviderFacilitySpecialty__c lookup
            List<DH_CareProviderFacilitySpecialty__c> siteModClone1 = new List<DH_CareProviderFacilitySpecialty__c>();
                
            for(integer i=0;i<site1.size();i++) {

                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_DEXA, DH_AccountId__c = site1[i].Id, DH_SpecialtyId__c = careSpecClone1[0].Id  ));
                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_MRI, DH_AccountId__c = site1[i].Id, DH_SpecialtyId__c = careSpecClone1[1].Id ));
                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_CT, DH_AccountId__c = site1[i].Id , DH_SpecialtyId__c = careSpecClone1[2].Id));   
                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_XRAY, DH_AccountId__c = site1[i].Id , DH_SpecialtyId__c = careSpecClone1[3].Id)); 
                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_ULTRASOUND, DH_AccountId__c = site1[i].Id , DH_SpecialtyId__c = careSpecClone1[4].Id)); 
                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_NM, DH_AccountId__c = site1[i].Id, DH_SpecialtyId__c = careSpecClone1[5].Id));
                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_PETCT, DH_AccountId__c = site1[i].Id , DH_SpecialtyId__c = careSpecClone1[6].Id));   
                siteModClone1.add(new DH_CareProviderFacilitySpecialty__c(Name = DH_KMConstants.MODALITY_FLUOROSCOPY, DH_AccountId__c = site1[i].Id , DH_SpecialtyId__c = careSpecClone1[7].Id));   
            }
            insert siteModClone1;
            
            List<HL_Machine_and_Weight__c> mwList1 = new List<HL_Machine_and_Weight__c>();
    
            for(integer i=0;i<8;i++) {
                mwList1.add(new HL_Machine_and_Weight__c( Name = 'Test machinee'+i,
                    DH_CareProviderFacilitySpecialty__c = siteModClone1[i].Id,
                    Site_Modality__c = siteModality1[i].Id
                ));
            }
            upsert mwList1;
            
            }

    }

    // test fetch machine weight recrd methods by modality, practice, site when no record found 
    @isTest
    public static void testNoRecordFound() {
       	User u = [SELECT Id FROM User WHERE Email='radSchTest@testorg.com' LIMIT 1];
        System.runAs(u){

        List<String> m = new List<String>();
        List<String> p = new List<String>();
        String s = '';
 
        Test.startTest();
        List<DH_MachineWeightController.MachineWeightWrapper> results = DH_MachineWeightController.getMachineRecordsBasedOnModality(m, p, s);
        List<DH_MachineWeightController.MachineWeightWrapper> results1 = DH_MachineWeightController.getMachineRecordsBasedOnPractice(p, s);
        List<DH_MachineWeightController.MachineWeightWrapper> results2 = DH_MachineWeightController.getMachineRecordsBasedOnSites( p, s);

        Test.stopTest();
        system.assert(results.isEmpty(), 'Exception should be thrown when no records are found for modality based.');
        system.assert(results1.isEmpty(), 'Exception should be thrown when no records are found for practice based.');
        system.assert(results2.isEmpty(), 'Exception should be thrown when no records are found for site based.');
        }
    }

    // test getMachineRecordsBasedOnModality for HealthCloud User
    @isTest
    public static void testgetMachineRecordsBasedOnModality() {
        
        User u = [SELECT Id FROM User WHERE Email='radSchTest@testorg.com' LIMIT 1];
        System.runAs(u){
            
        List<String> m = new List<String>();
        m.add('X Ray');
        List<String> p = new List<String>();
        p.add('CRA');
        String s = '(GRB) Greenbelt Imaging Center';
                
        List<String> m1 = new List<String>();
        List<String> p1 = new List<String>();
        String s1 = '';
		
        List<String> p2 = new List<String>();
        p2.add('NJIN');
        String s2 = '(PIB) Belleville (bel-vil)';     
     
         Test.startTest();
        	List<DH_MachineWeightController.MachineWeightWrapper> results = DH_MachineWeightController.getMachineRecordsBasedOnModality(m, p, s);
        	List<DH_MachineWeightController.MachineWeightWrapper> results1 = DH_MachineWeightController.getMachineRecordsBasedOnModality(m1, p1, s);
        	List<DH_MachineWeightController.MachineWeightWrapper> results2 = DH_MachineWeightController.getMachineRecordsBasedOnModality(m1, p, s);
     	    List<DH_MachineWeightController.MachineWeightWrapper> results3 = DH_MachineWeightController.getMachineRecordsBasedOnModality(m, p, s1);
       		List<DH_MachineWeightController.MachineWeightWrapper> results4 = DH_MachineWeightController.getMachineRecordsBasedOnModality(m, p2, s2);

         
        Test.stopTest();

        system.assertEquals(true,results.size()>0, 'test success ');
       	system.assertEquals(true,results1.size()>0, 'test success ');
        }
    }  

    // test getMachineRecordsBasedOnPractice for HealthCloud User
    @isTest
    public static void testgetMachineRecordsBasedOnPractice() {
        
        User u = [SELECT Id FROM User WHERE Email='radSchTest@testorg.com' LIMIT 1];
        System.runAs(u){
        List<String> p = new List<String>();
        p.add('CRA');
        String s = '(GRB) Greenbelt Imaging Center';
        
        List<String> p1 = new List<String>();
        String s1 = '';
        
        List<String> p2 = new List<String>();
        p2.add('NJIN');
        String s2 = '(PIB) Belleville (bel-vil)';     
        
        Test.startTest();
        List<DH_MachineWeightController.MachineWeightWrapper> results = DH_MachineWeightController.getMachineRecordsBasedOnPractice(p, s);
        List<DH_MachineWeightController.MachineWeightWrapper> results1 = DH_MachineWeightController.getMachineRecordsBasedOnPractice(p1, s);
        List<DH_MachineWeightController.MachineWeightWrapper> results2 = DH_MachineWeightController.getMachineRecordsBasedOnPractice(p, s1);
        List<DH_MachineWeightController.MachineWeightWrapper> results3 = DH_MachineWeightController.getMachineRecordsBasedOnPractice(p2, s2);
        
        Test.stopTest();
       
        system.assertEquals(true,results1.size()>0, 'test success ');
        }
    }  

    // test GetRecordsBasedOnSite for HealthCloud User
    @isTest
    public static void testGetRecordsBasedOnSite() {
        
        User u = [SELECT Id FROM User WHERE Email='radSchTest@testorg.com' LIMIT 1];
        System.runAs(u){

        List<String> p = new List<String>();
        p.add('CRA');
        String s = '(GRB) Greenbelt Imaging Center';
        
        List<String> p1 = new List<String>();
        String s1 = '';
        
        List<String> p2 = new List<String>();
        p2.add('NJIN');
        String s2 = '(PIB) Belleville (bel-vil)';       
     
        Test.startTest();
        List<DH_MachineWeightController.MachineWeightWrapper> results = DH_MachineWeightController.getMachineRecordsBasedOnSites(p, s);
        List<DH_MachineWeightController.MachineWeightWrapper> results1 = DH_MachineWeightController.getMachineRecordsBasedOnSites(p1, s);
        List<DH_MachineWeightController.MachineWeightWrapper> results2 = DH_MachineWeightController.getMachineRecordsBasedOnSites(p, s1);
		List<DH_MachineWeightController.MachineWeightWrapper> results3 = DH_MachineWeightController.getMachineRecordsBasedOnSites(p2, s2);
        
        Test.stopTest();
        system.assertEquals(true,results1.size()>0, 'test success '); 
        }       
    }

    // test getMachineRecordsBasedOnModality For GuestUser
    @isTest
    public static void testgetMachineRecordsBasedOnModalityForGuest() {
        
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
            
        List<String> m = new List<String>();
        m.add('CT');
        List<String> p = new List<String>();
        p.add('RIA');
        String s = '(TRA) Tradition Center';

        Test.startTest();
        	List<DH_MachineWeightController.MachineWeightWrapper> results = DH_MachineWeightController.getMachineRecordsBasedOnModality(m, p, s);
        Test.stopTest();
        system.assertEquals(true, results.size()>=0, 'test success ');
        }
    }

    // test getMachineRecordsBasedOnPractice For GuestUser
    @isTest
    public static void testgetMachineRecordsBasedOnPracticeForGuest() {
        
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {

        String s = '(TRA) Tradition Center';
        List<String> p = new List<String>();
        //p.add('RIA');

        Test.startTest();
            List<DH_MachineWeightController.MachineWeightWrapper> results = DH_MachineWeightController.getMachineRecordsBasedOnPractice(p, s);
        Test.stopTest();
        system.assertEquals(true, results.size()>=0, 'test success ');
        }
    }

    // test GetRecordsBasedOnSite For GuestUser
    @isTest
    public static void testGetRecordsBasedOnSiteForGuest() {
        
        User guestUser = [SELECT Id FROM User WHERE Email = 'guestuser@test.com' LIMIT 1];
        System.runAs(guestUser) {
        
        List<String> p = new List<String>();
        String s = '(TRA) Tradition Center';

        Test.startTest();
        	List<DH_MachineWeightController.MachineWeightWrapper> results = DH_MachineWeightController.getMachineRecordsBasedOnSites(p, '(TRA) Tradition Center');
        Test.stopTest();
        system.assertEquals(true, results.size()>=0, 'test success ');
        }
    }

    @isTest
    public static void testGetSiteList() { 
        User u = [SELECT Id FROM User WHERE Email='radSchTest@testorg.com' LIMIT 1];
        System.runAs(u){
        Test.startTest();
        	List<String> results = DH_MachineWeightController.getSiteList();
        Test.stopTest();
        system.assertEquals(true, results.size()>0, 'test success ');
        }
    }

    // test CreateMachineWrapper for HealthCloud And Guest User
    @isTest
    public static void testCreateMachineWrapper() {
        
        User u = [SELECT Id FROM User WHERE Email='radSchTest@testorg.com' LIMIT 1];
        System.runAs(u){
        Test.startTest(); 
            
            List<sObject> mwlist = [SELECT id, Name, Machine__c, Weight__c, Room__c, Slice__c, DH_CareProviderFacilitySpecialty__r.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Site_Code__c,DH_CareProviderFacilitySpecialty__r.DH_AccountId__c, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c, Description__c FROM HL_Machine_and_Weight__c];
            DH_MachineWeightController.MachineWeightWrapper mwG = DH_MachineWeightController.populateMachineWrapperForGuest(mwlist);
            DH_MachineWeightController.MachineWeightWrapper mwH = DH_MachineWeightController.populateMachineWrapper(mwlist);
        Test.stopTest();
        
        system.assertEquals(true,mwG != null, 'test success '); 
        system.assertEquals(true,mwH != null, 'test success '); 

        }       
    }

    // test GroupMachineList for HealthCloud And Guest User
    @isTest
    public static void testGroupMachineList() {
        
        User u = [SELECT Id FROM User WHERE Email='radSchTest@testorg.com' LIMIT 1];
        System.runAs(u){
        Test.startTest(); 
            
            List<sObject> mwlist = [SELECT id, Name, Machine__c, Weight__c, Room__c, Slice__c, DH_CareProviderFacilitySpecialty__r.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Site_Code__c,DH_CareProviderFacilitySpecialty__r.DH_AccountId__c, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Name, DH_CareProviderFacilitySpecialty__r.DH_AccountId__r.Parent.Practice_code__c, Description__c FROM HL_Machine_and_Weight__c];
            Map<String, List<sObject>> mwMapG = DH_MachineWeightController.groupMachineListBySiteForGuest(mwlist);
            Map<String, List<sObject>> mwMapH = DH_MachineWeightController.groupMachineListBySite(mwlist);
        Test.stopTest();
        
        system.assertEquals(true,mwMapG != null, 'test success '); 
        system.assertEquals(true,mwMapH != null, 'test success '); 

        }       
    }
    
}