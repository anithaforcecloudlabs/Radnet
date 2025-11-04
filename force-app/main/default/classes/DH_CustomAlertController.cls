/*
 
*********************************************************
 
Apex Class         : DH_CustomAlertController
 
Created Date       : 19-07-2024
 
@description       : This class returns Alert__c value for given account recordId
 
@jiraid            : CC-949
 
 
*********************************************************
 
*/
public with sharing class DH_CustomAlertController {
    /**************************************************************************************************************************************************
     * 
     * @description : This method is used to get the Alert__ value
     * 
     * @param       recId    		Record Id of Account Id
     * @return      String          Alert value of given Account recordId                        
     * 
     * */ 
    @AuraEnabled
    public static string getAlertValue(Id recId){
        return [Select Id, Alert__c from Account where Id =: recId WITH SECURITY_ENFORCED].Alert__c;
    }
}