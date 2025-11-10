public class DH_MessagingSessionFileHandler {
 public static void afterInsert(List<ContentDocumentLink> newLinks) {
        Set<Id> messagingSessionIds = new Set<Id>();

        // Collect MessagingSession Ids
        for (ContentDocumentLink cdl : newLinks) {
            if (cdl.LinkedEntityId != null &&
                cdl.LinkedEntityId.getSObjectType() == MessagingSession.sObjectType) {
                messagingSessionIds.add(cdl.LinkedEntityId);
            }
        }

        if (messagingSessionIds.isEmpty()) {
            return;
        }

        // Query MessagingSessions to get related CaseIds
        Map<Id, MessagingSession> msMap = new Map<Id, MessagingSession>(
            [SELECT Id, CaseId 
             FROM MessagingSession 
             WHERE Id IN :messagingSessionIds 
             AND CaseId != null]
        );

        List<ContentDocumentLink> caseLinks = new List<ContentDocumentLink>();

        // Create a new ContentDocumentLink for each Case
        for (ContentDocumentLink cdl : newLinks) {
            MessagingSession ms = msMap.get(cdl.LinkedEntityId);
            if (ms != null && ms.CaseId != null) {
                caseLinks.add(new ContentDocumentLink(
                    ContentDocumentId = cdl.ContentDocumentId,
                    LinkedEntityId = ms.CaseId,
                    ShareType = 'V',     // V = Viewer
                    Visibility = 'AllUsers'
                ));
            }
        }

        if (!caseLinks.isEmpty()) {
            try {
                insert caseLinks;
            } catch (DmlException e) {
                System.debug('Error inserting Case file links: ' + e.getMessage());
            }
        }
    }
}