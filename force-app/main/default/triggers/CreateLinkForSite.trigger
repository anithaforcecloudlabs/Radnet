/* *****************************************************************************************************************************************************
 *
 * @Created Date      :  March 2024
 *
 * @description       : Trigger on Content Document Link on HealthcareProvider object if new attachement added on related account
 *
 * @JIRA Id           :  CC-758
 * */
trigger CreateLinkForSite on ContentDocumentLink (after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        CreateLinkForSiteHandler handler = new CreateLinkForSiteHandler();
        handler.createCDLForHealthcareProvider(trigger.new);
        CreateLinkForSiteHandler.handleAfterInsertGolive(trigger.new);
    }
}