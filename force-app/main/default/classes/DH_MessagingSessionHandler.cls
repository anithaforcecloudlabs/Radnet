/**
 * @File Name : DH_MessagingSessionHandler.cls
 * @Description : Trigger Handler for Messaging Session object.
 * @Author : Punith N S
 * @Last Modified By :
 * @Last Modified On : October 1, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | October 1, 2025 |   | Initial Version
 **/

/*
 * ***************************************************************************************************************************
 * Jira#                    Date                 Description
 * ----------------         --------------       ------------------------------
 *
 * ***********************************************************************************************************************************************
 */


public class DH_MessagingSessionHandler {
    
    public static void beforeInsert(List<MessagingSession> newList) {
        // placeholder for any validations or defaults
    }
    
    public static void beforeUpdate(List<MessagingSession> newList, Map<Id, MessagingSession> oldMap) {

    }
    
    public static void afterInsert(List<MessagingSession> newList) {

    }
    
    public static void afterUpdate(List<MessagingSession> newList, Map<Id, MessagingSession> oldMap) {
        List<MessagingSession> ownerChangedSessions = new List<MessagingSession>();
        
        for (MessagingSession ms : newList) {
            
            if (ms.CaseId != null && ms.OwnerId != null) {
                ownerChangedSessions.add(ms);
            }
        }
        
        if (!ownerChangedSessions.isEmpty()) {
            updateCaseOwners(ownerChangedSessions);
        }
    }
    
  private static void updateCaseOwners(List<MessagingSession> sessions) {
        List<Case> casesToUpdate = new List<Case>();
        
        for (MessagingSession ms : sessions) {
            if (ms.CaseId != null && ms.OwnerId != null) {
                casesToUpdate.add(new Case(
                    Id = ms.CaseId,
                    OwnerId = ms.OwnerId
                ));
            }
        }
        
        if (!casesToUpdate.isEmpty()) {
            try {
                update casesToUpdate;
            } catch (DmlException e) {
            }
        }
    }
   
}