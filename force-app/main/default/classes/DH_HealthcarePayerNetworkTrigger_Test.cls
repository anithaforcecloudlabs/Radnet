/**
*********************************************************

Apex Class         : DH_HealthcarePayerNetworkTrigger_Test

Created Date       : July 04, 2024

@description       : Handler class for trigger on HealthcarePayerNetwork object 

@jiraid            : 

*********************************************************
**/
@isTest (SeeAllData=false)
public class DH_HealthcarePayerNetworkTrigger_Test {

    @testSetup
    static void createData(){
        Id regionRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.RIS_INSTANCE_RIS_SYSTEM).getRecordTypeId();
        Id practiceRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.PRACTICE_RECORD_TYPE).getRecordTypeId();
        Id payerAccountRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DH_KMConstants.PAYER_RECORD_TYPE).getRecordTypeId();

        Account reg = new Account(Name = 'MA', 
                                 RecordTypeId = regionRecordTypeID );

        upsert reg;
        system.debug('reg '+reg);
        Account prac = new Account(Name='ADV',
                                    Region__c = reg.Id,
                                    ParentId = reg.Id,
                                    Practice_code__c = 'ADV',
                                    RecordTypeId = practiceRecordTypeID);
        upsert prac;
        system.debug('prac '+prac);
        Account payeracc = new Account(Name = 'Test Acc1', 
                                        Carrier_Code_in_RIS__c = '001',
                                        RecordTypeId = payerAccountRecordTypeID);
        upsert payeracc;
        system.debug('payeracc '+payeracc);
        HealthcarePayerNetwork payerntw = new HealthcarePayerNetwork(Name = 'test1',
                                                                    PayerId = payeracc.Id,
                                                                    Region__c = reg.Id,
                                                                    IsActive = true);
        upsert payerntw; 
        system.debug('payerntw '+payerntw);
    }

    @isTest
    static void handleAfterDeleteUndeleteTest() {
        //HealthcarePayerNetwork DH_HealthcarePayerNetwork__c
    HealthcarePayerNetwork healthcarePayerNetwork = [SELECT Id, Name from HealthcarePayerNetwork where Name ='Test Acc1' LIMIT 1];
    DH_HealthcarePayerNetwork__c healthcarePayerNetworkClone = [SELECT Id, Name from DH_HealthcarePayerNetwork__c where Name ='Test Acc1' LIMIT 1];

    delete healthcarePayerNetwork;
	undelete healthcarePayerNetwork;
    System.assertEquals('Test Acc1', healthcarePayerNetwork.Name, 'HealthcarePayerNetwork record restored');
    System.assertEquals('Test Acc1', healthcarePayerNetworkClone.Name, 'DH_HealthcarePayerNetwork__c record restored');

    }
}