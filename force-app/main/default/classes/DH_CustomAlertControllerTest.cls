/*
 
*********************************************************
 
Apex Class         : DH_CustomAlertControllerTest
 
Created Date       : 19-07-2024
 
@description       : This class tests the functionality of DH_CustomAlertController 
 
@jiraid            : CC-949.

  
*********************************************************
 
*/
@isTest
public class DH_CustomAlertControllerTest {
    // This method is used to test the correctness of the alert value
	@isTest
    public static void getAlertValueTestMethod(){
        Account acc = new Account(Name = 'Test Account', Alert__c = 'Test Alert');
        insert acc;
        
        Test.startTest();
        String alert = DH_CustomAlertController.getAlertValue(acc.Id);
        Test.stopTest();
        
        System.assertEquals('Test Alert', alert, 'Success');
    }
}