/**********************************************************

Apex Class         : DH_DeleteClonedProcedureTriggerTest 

Created Date       : July 3, 2024

@description       : Test class for DH_DeleteClonedProcedureTriggerHandler and DH_DeleteClonedProcedureTrigger

@jiraid            : CC-792

*********************************************************

*/



@isTest
public class DH_DeleteClonedProcedureTriggerTest {
 	/*
     * @description  this method creates test data to be used in other test methods
     * 
     * */
    @testSetup 
    static void setup() {
        // Create Account and CareSpecialty records for lookups
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        CareSpecialty careSpec = new CareSpecialty(Name='Test Specialty3');
        insert careSpec;
        
        
        // Create HealthcareProcedure records
        List<HealthCareProcedure> hcProcedures = new List<HealthCareProcedure>();
        for(Integer i=0; i<1; i++) {
            HealthCareProcedure proc = new HealthCareProcedure(
                Name = 'Proc ' + i,
                Reason_For_Exam__c = 'Reason ' + i,
                Special_Instructions__c = 'Instructions ' + i,
                Code = 'Code ' + i,
                Practice_Codes__c = acc.Id,
                Modality_Codes__c = careSpec.Id,
                Healthcare_Procedure_External_Id__c = 'ExternalID_' + i
            );
            hcProcedures.add(proc);
        }
        insert hcProcedures;
        
        // Create corresponding DH_HealthcareProcedure records
        List<DH_HealthcareProcedure__c> dhProcedures = new List<DH_HealthcareProcedure__c>();
        for(HealthcareProcedure proc : hcProcedures) {
            DH_HealthcareProcedure__c dhProc = new DH_HealthcareProcedure__c(
                Name = proc.Name,
                DH_Reason_for_Exam__c = proc.Reason_For_Exam__c,
                DH_Special_Instructions__c = proc.Special_Instructions__c,
                DH_Procedure_Codes__c = proc.Code,
                DH_Practice_Code_s__c = proc.Practice_Codes__c,
                DH_Modality_codes__c = proc.Modality_Codes__c,
                DH_Healthcare_Procedure_External_Id__c = proc.Id
            );
            dhProcedures.add(dhProc);
        }
        insert dhProcedures;
    }
 
    /*
     * @description  this method tests after delete functionality of the trigger
     * 
     * */
    @isTest
    static void testHandleAfterDelete() {
        // Query HealthcareProcedure records
        List<HealthCareProcedure> hcProcedures = [SELECT Id, Healthcare_Procedure_External_Id__c FROM HealthCareProcedure];
        
        //Collect the external Ids
        Set<String> hcProcExternalIds = new Set<String>();
        for(HealthCareProcedure hcProc : hcProcedures) {
            hcProcExternalIds.add(hcProc.Id);
        }
        
        // Delete HealthcareProcedure records
        delete hcProcedures;
        
        // Verify corresponding DH_HealthcareProcedure records are deleted
        List<DH_HealthcareProcedure__c> deletedDhProcedures = [
            SELECT Id, DH_Healthcare_Procedure_External_Id__c FROM DH_HealthcareProcedure__c WHERE DH_Healthcare_Procedure_External_Id__c IN :hcProcExternalIds AND IsDeleted = TRUE ALL ROWS];
        
        System.assertEquals(true, deletedDhProcedures.size()>0, 'Cloned record also got deleted');
    }
 
    /*
     * @description  this method tests the after undelete functionality of the trigger
     * 
     * */
    @isTest
    static void testHandleAfterUndelete() {
        // Query HealthcareProcedure records
        List<HealthCareProcedure> hcProcedures = [SELECT Id, Healthcare_Procedure_External_Id__c FROM HealthCareProcedure];
        
        //Collect the external Ids
        Set<String> hcProcExternalIds = new Set<String>();
        for(HealthCareProcedure hcProc : hcProcedures) {
            hcProcExternalIds.add(hcProc.Id);
        }
        
        // Delete and then undelete HealthcareProcedure records
        delete hcProcedures;
        undelete hcProcedures;
        
        // Verify corresponding DH_HealthcareProcedure records are restored
        List<DH_HealthcareProcedure__c> restoredDhProcedures = [SELECT Id, DH_Healthcare_Procedure_External_Id__c FROM DH_HealthcareProcedure__c WHERE DH_Healthcare_Procedure_External_Id__c IN :hcProcExternalIds AND IsDeleted = FALSE];
        
        System.assertEquals(true, restoredDhProcedures.size()>0, 'Cloned record also got undeleted');
    }
}