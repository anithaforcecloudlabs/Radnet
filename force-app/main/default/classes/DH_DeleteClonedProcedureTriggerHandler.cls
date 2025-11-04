/*

*********************************************************

Apex Class         : DH_DeleteClonedProcedureTriggerHandler

Created Date       : July 3, 2024

@description       : Trigger handler on HealthCareProcedure object for delete/undelete operation on records of cloned object DH_HealthcareProcedure 

@jiraid            : CC-792

*********************************************************

*/

public class DH_DeleteClonedProcedureTriggerHandler {
    /**************************************************************************************************************************************************
     * 
     * @description this method handles after delete functionality of the trigger
     * 
     * @param hcpList List of healthcare procedure records
     * 
     * */
    public static void handleAfterDelete(List<HealthCareProcedure> hcpList){
        try{
            Set<String> procExternalIds = new Set<String>();
                if(hcpList.size() == 1){
                    for(HealthCareProcedure proc: hcpList){
                        procExternalIds.add(proc.Id) ;
                    }
                    List<DH_HealthcareProcedure__c> clonedRecordsToDelete = [SELECT Id, name, DH_Healthcare_Procedure_External_Id__c from DH_HealthcareProcedure__c  WHERE DH_Healthcare_Procedure_External_Id__c IN: procExternalIds];
                    if(clonedRecordsToDelete != null && !clonedRecordsToDelete.isEmpty()){
                    	delete clonedRecordsToDelete; //havent checked CRUD as records need to delete even if user dont have access
                	}           
             	}
        }
        catch(DmlException e){
        	System.debug(LoggingLevel.ERROR, 'Error : '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }   
    
    /**************************************************************************************************************************************************
     * 
     * @description this method handles after undelete functionality of the trigger
     * 
     * @param hcpList List of healthcare procedure records
     * 
     * */
    public static void handleAfterUndelete(List<HealthCareProcedure> hcpList){
        try{
            Set<String> procExternalIds = new Set<String>();
            if(!hcpList.isEmpty()){
                for(HealthCareProcedure proc: hcpList){
                    procExternalIds.add(proc.Id) ;
                } 
            }
            List<DH_HealthcareProcedure__c> clonedRecordsToUndelete = [SELECT Id, name, DH_Healthcare_Procedure_External_Id__c from DH_HealthcareProcedure__c  WHERE DH_Healthcare_Procedure_External_Id__c IN: procExternalIds AND IsDeleted = TRUE ALL ROWS] ;  
            if(clonedRecordsToUndelete != null && !clonedRecordsToUndelete.isEmpty()){   
                   undelete clonedRecordsToUndelete; //havent checked CRUD as records need to restored even if user dont have access
             }  
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, 'Error : '+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }

}