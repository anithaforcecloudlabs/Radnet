trigger DH_CallCenterDataSheetTrigger on DH_Call_Center_Data_Sheet__c (after insert,after update,before delete,before update, before insert) {
    
   /* if(Trigger.isBefore && Trigger.isDelete){
      DH_CallCenterDataSheetDenormalizeHandler.denormalizeObjectDeleteCase(Trigger.Old);
    }
    if(Trigger.isInsert || Trigger.isUpdate){
        System.debug('inside trigger');
        if(Trigger.isBefore){
            System.debug('inside before trigger');
            DH_ExclusionDenormalizeCheckDuplicates.exclusionDenormalizeCheckIfDuplicates(Trigger.New);
            DH_CallCenterDataSheetDenormalizeHandler.checkLookup(Trigger.New);
        } 
    }*/
    TriggerFactory.execute(DH_Call_Center_Data_Sheet__c.getSObjectType());    
}