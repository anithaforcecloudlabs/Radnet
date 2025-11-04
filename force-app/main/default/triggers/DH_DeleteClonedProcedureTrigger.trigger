/*

*********************************************************

Apex Trigger         : DH_DeleteClonedProcedureTrigger

Created Date       : July 3, 2024

@description       : Trigger on HealthCareProcedure for object for delete/undelete operation on records of cloned object DH_HealthcareProcedure 

@jiraid            : CC-792

*********************************************************

*/

trigger DH_DeleteClonedProcedureTrigger on HealthCareProcedure (after delete, after undelete) {
    
    // After delete/Undelete
    if(trigger.isAfter){   
        // method to delete cloned objects records
        if(trigger.isDelete){
            DH_DeleteClonedProcedureTriggerHandler.handleAfterDelete(trigger.old);
        }
        if(trigger.isUndelete){
            DH_DeleteClonedProcedureTriggerHandler.handleAfterUndelete(trigger.new);
        }
    }
    
    
}