/*

*********************************************************

Apex Class         : DH_ContentDocumentLinkTrigger

Created Date       : July 19, 2024

@description       : Trigger on ContentDocumentLink object to change the visibility of image

@jiraid            : CC-949

*********************************************************

*/
trigger DH_ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){ // Before Insert
        DH_ContentDocumentLinkTriggerHandler.updateVisibility(Trigger.New);
    }
}