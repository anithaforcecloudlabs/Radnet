/*

 *********************************************************

Apex Class         : DH_CareSpecialtyTriggerController
    
Created Date       : May 15, 2024
    
@description       : Trigger handler on care specialty to set order number used to show modalities in sequence given

@jiraid            : CC-104, CC-792, CC-759

 *********************************************************

 */
public without sharing class DH_CareSpecialtyTriggerController {
    
    /**
     * @description : Method used to auto-index modalities which are inserted
     * @param List<CareSpecialty> trigger.new
     **/
    public static void updateOrderNumber(List<CareSpecialty> newCareSpecialty){
        try{
            List<CareSpecialty> existingRecords = new List<CareSpecialty>([SELECT id, Order__c 
                                                                       FROM CareSpecialty
                                                                       where Order__c != NULL 
                                                                        ORDER BY Order__c DESC LIMIT 1]);
            Decimal highestOrderNumber = 0;
            if(!existingRecords.isEmpty()){
                highestOrderNumber = existingRecords[0].Order__c;
            }
            for(CareSpecialty c: newCareSpecialty){
                if(c.Order__c == NULL){
                    highestOrderNumber++;
                    c.Order__c = highestOrderNumber; //This order field is used to show Modalities in given order on Site search record page
                }
            }
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error while Updating modality record'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    /**
     * @description Method used to auto-delete DH modalities related to deleted Modality
     * * @param List<CareSpecialty> trigger.old
     **/
    public static void handleAfterDelete(List<CareSpecialty> oldModalities){
        try{
            Set<String> carespecialityExternalIds = new Set<String>();
            if(!oldModalities.isEmpty()){
                for(CareSpecialty mod: oldModalities){
                    carespecialityExternalIds.add(mod.CareSpecialty_External_ID__c) ;
                }
            }
            List<DH_CareSpecialty__c> clonedRecordsToDelete = [SELECT Id, Name, DH_CareSpecialty_External_ID__c from DH_CareSpecialty__c  WHERE DH_CareSpecialty_External_ID__c IN: carespecialityExternalIds];
            if(!clonedRecordsToDelete.isEmpty()){
                delete clonedRecordsToDelete; //havent checked CRUD as records need to delete even if user dont have access
            }
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error while deleting modality record'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    /**
     * @description Method used to auto-undelete DH modalities related to deleted Modality
     * * @param List<CareSpecialty> trigger.new
     **/
    public static void handleAfterUndelete(List<CareSpecialty> newModalities){
        try{
            Set<String> carespecialityExternalIds = new Set<String>();
            if(!newModalities.isEmpty()){
                for(CareSpecialty mod: newModalities){
                    carespecialityExternalIds.add(mod.CareSpecialty_External_ID__c) ;
                }
            }
            List<DH_CareSpecialty__c> clonedRecordsToUndelete = [SELECT Id, Name, DH_CareSpecialty_External_ID__c from DH_CareSpecialty__c  WHERE DH_CareSpecialty_External_ID__c IN: carespecialityExternalIds AND IsDeleted = TRUE ALL ROWS];
            if(!clonedRecordsToUndelete.isEmpty()){
                undelete clonedRecordsToUndelete; //havent checked CRUD as records need to restored even if user dont have access
            }
            
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR,'Error while undeleting record'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
}