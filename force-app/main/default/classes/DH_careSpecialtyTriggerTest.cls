/*

*********************************************************

Apex Class         : DH_careSpecialtyTriggerTest

Created Date       : May 15, 2024

@description       : test class for trigger handler DH_CareSpecialtyTriggerController on care specialty to set order number

@jiraid            : CC-104, CC-759

*********************************************************

*/
@isTest(SeeAllData=false)
public class DH_careSpecialtyTriggerTest {
    /**
     * @description : Method used to create modality data
     **/
    @testSetup
    static void createData(){
        CareSpecialty cs = new CareSpecialty(Name = 'Test Modality new',CareSpecialty_External_ID__c='TestModalitynewExt'); //scenario for no existing modality records
        cs.IsActive=true;
        insert cs;
    }
    
   	/**
     * @description : create new care Modalities to run trigger and check order number
     **/
	@isTest
    static void testOrderNumber() {
        CareSpecialty cs =[SELECT Id, Name, Order__c from CareSpecialty where Name = 'Test Modality new'];
        System.assertEquals(1,cs.Order__c,'Order number should be 1'); //check order 
        
        List<CareSpecialty> testMod = new List<CareSpecialty>();
        for(Integer i = 0; i < 5; i++) {
            CareSpecialty c = new CareSpecialty(Name = 'Test Modality' + i,CareSpecialty_External_ID__c='TestModalityExt');
            c.IsActive=true;
            testMod.add(c);
        }
        Test.startTest();
       	insert testMod;    // test scenario for existing modality records and bulk insert
        Test.stopTest();        
        System.assertEquals(5,testMod.size(),'Care Speciality records are created'); //check order 
    }
    
    /**
     * @description : Method used to test delete and undelete scenarios
     **/
    @isTest
    static void handleAfterDeleteUndeleteTest() {
        CareSpecialty careSpeciality = [SELECT Id, Name from CareSpecialty where Name = 'Test Modality new' LIMIT 1];
        DH_CareSpecialty__c cloneCareSpeciality = [SELECT Id, Name from DH_CareSpecialty__c where Name = 'Test Modality new' LIMIT 1];
        Test.startTest();
            delete careSpeciality;
			undelete careSpeciality;
            System.assertEquals('Test Modality new', careSpeciality.Name, 'careSpeciality record restored');
            System.assertEquals('Test Modality new', cloneCareSpeciality.Name, 'cloneCareSpeciality record restored');
        Test.stopTest();
    }
   
}