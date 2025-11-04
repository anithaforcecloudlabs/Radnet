/*

*********************************************************

Apex Class         : DH_siteModalityTriggerHandler

Created Date       : May 15, 2024

@description       : Trigger on Site modality object to avoid duplicates and to auto-populate name of site modality 

@jiraid            : CC-104

*********************************************************

*/
trigger DH_SiteModalityTrigger on CareProviderFacilitySpecialty (before insert, before update, after delete, after undelete) {    
    if(trigger.isBefore){
        if(trigger.isInsert){   //beforeInsert
            //method used for duplicate check and updating name field
            DH_siteModalityTriggerHandler.handleBeforeInsert(trigger.new); 
        }
        if(trigger.isUpdate){   // before update 
            // method used for duplicate check
            DH_siteModalityTriggerHandler.handleBeforeUpdate(trigger.new, trigger.oldMap); 
        }
    }
    
    if(trigger.isAfter){   // After delete/Undelete
        // method to delete cloned objects records
        if(trigger.isDelete){
            DH_siteModalityTriggerHandler.handleAfterDelete(trigger.old);
        }
        if(trigger.isUndelete){
            DH_siteModalityTriggerHandler.handleAfterUndelete(trigger.new);
        }
    }
}