public class DH_GeneralCaseQueueableMS implements Queueable{
    Id accountId;
    String messagingSessionId;

    // Overloaded Constructor for Messaging Session
    public DH_GeneralCaseQueueableMS(Id accountId, Id messagingSessionId) {
        this.accountId = accountId;
        this.messagingSessionId = messagingSessionId;
    }

    public void execute(QueueableContext context) {
        if (accountId != null && messagingSessionId != null) {
            DH_MessagingSessionTriggerHelper.createContactCenterCaseForMessaging(accountId,messagingSessionId);
        
    }
}
}