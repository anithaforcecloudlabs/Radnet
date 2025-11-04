/*

*********************************************************

Apex Class         : DH_CareSpecialtyTrigger

Created Date       : May 15, 2024

@description       : Trigger on care specialty(modality) object to set maximum order number before insert

@jiraid            : CC-104

*********************************************************

*/
trigger DH_CareSpecialtyTrigger on CareSpecialty (before insert, after insert, after update, after delete, after undelete) {   
    //before insert assign maximum order number
    if(trigger.isBefore){
        if(trigger.isInsert){
            DH_CareSpecialtyTriggerController.updateOrderNumber(trigger.new);
        }
    }	
	if(trigger.isAfter){   // After delete/Undelete
        // method to delete cloned objects records
        if(trigger.isDelete){
            DH_CareSpecialtyTriggerController.handleAfterDelete(trigger.old);
        }
        if(trigger.isUndelete){
            DH_CareSpecialtyTriggerController.handleAfterUndelete(trigger.new);
        }
    }
}