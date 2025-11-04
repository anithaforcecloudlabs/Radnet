/*

*********************************************************

Apex Class         : DH_HealthcarePayerNetworkTrigger

Created Date       : July 03, 2024

@description       : Trigger on HealthcarePayerNetwork (Special Bills) object to delete undelete DH_HealthcarePayerNetwork clone object records

@jiraid            : 

*********************************************************

*/
trigger DH_HealthcarePayerNetworkTrigger on HealthcarePayerNetwork ( after delete, after undelete) {
    if(trigger.isAfter){   // After delete/Undelete
        // method to delete cloned objects records
        if(trigger.isDelete){
            DH_HealthcarePayerNetworkTrigger_Handler.handleAfterDelete(trigger.old);
        }
        if(trigger.isUndelete){
            DH_HealthcarePayerNetworkTrigger_Handler.handleAfterUndelete(trigger.new);
        }
    }

}