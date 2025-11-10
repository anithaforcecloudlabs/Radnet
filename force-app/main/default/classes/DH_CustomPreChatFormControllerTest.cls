@IsTest
private class DH_CustomPreChatFormControllerTest {


    @IsTest
    static void testGetConfigsForUrl() {
        Test.startTest();
        List<DH_Pre_Chat_Config__mdt> configs = DH_CustomPreChatFormController.getMetadataForSite('https://eastxrayhours.com');
        Test.stopTest();
    }

    @IsTest
    static void testisBusinessHoursOpen() {
        Test.startTest();
        Boolean isOpen = DH_CustomPreChatFormController.isBusinessHoursOpen();
        Test.stopTest();
    }
}