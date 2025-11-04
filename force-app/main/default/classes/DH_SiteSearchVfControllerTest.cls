/*
 
*********************************************************
 
Apex Class         : DH_SiteSearchVfControllerTest
 
Created Date       : July 19, 2024
 
@description       : Test class for Controller class for site search vfpage(dH_siteSearchVfpage) to send lexorigin and access token from metadata
 
@jiraid            : CC-233
 
 
*********************************************************
 
*/
@isTest (SeeAllData=false)
private class DH_SiteSearchVfControllerTest {
    @isTest
    static void testLexOrigin() {
        // Create a new instance of the controller
        DH_SiteSearchVfController controller = new DH_SiteSearchVfController();     
        Test.startTest();
        // Verify that the lexOrigin property returns the expected value
		String expectedLexOrigin = URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
        System.assertEquals(expectedLexOrigin, controller.lexOrigin, 'lexOrigin should be correctly calculated');
        // Verify that the Access token returns the expected value
        Test.stopTest();
    }
    @isTest
    public static void testParameters(){
        DH_SiteSearchVfController controller = new DH_SiteSearchVfController();     
        Test.startTest();
        // Verify that the lexOrigin property returns the expected value
		System.assertEquals('functionDirection', controller.functionNameDirection, 'functionNameDirection should be correctly calculated');
        System.assertEquals('RemoveMarker', controller.functionNameRemoveMarker, 'functionNameRemoveMarker should be correctly calculated');
        System.assertEquals('AddMarkerForInputAddress', controller.functionNameAddMarker, 'functionNameAddMarker should be correctly calculated');
        System.assertEquals('removeAllMarkers', controller.functionNameRemoveAllMarker, 'functionNameRemoveAllMarker should be correctly calculated');
        System.assertEquals('/lightning/r/Account/', controller.lightningAccountURL, 'lightningAccountURL should be correctly calculated');
        System.assertEquals('<strong>Name:</strong> <a id="vfMessage" ', controller.popupContentName, 'popupContentName should be correctly calculated');
        System.assertEquals(' style="cursor:pointer;" onclick="handleNameClick()" value="', controller.popupContentTarget, 'popupContentTarget should be correctly calculated');
        System.assertEquals('">', controller.closeAnchorTag, 'closeAnchorTag should be correctly calculated');
        System.assertEquals('<strong>Address: </strong>', controller.popupContentAddress, 'popupContentAddress should be correctly calculated');
        System.assertEquals('InputAddressValue', controller.inputAddressValue, 'inputAddressValue should be correctly calculated');
        System.assertEquals('MapId1', controller.mapIdFirst, 'mapIdFirst should be correctly calculated');
        System.assertEquals('MapId2', controller.mapIdSecond, 'mapIdSecond should be correctly calculated');
        System.assertEquals('?api=1&origin=', controller.googleParameterName, 'googleParameterName should be correctly calculated');
        System.assertEquals('&destination=', controller.googleParameterDestination, 'googleParameterDestination should be correctly calculated');
        System.assertEquals(true, controller.siteDotCom.length() > 0, 'siteDotCom should be correctly calculated');
        System.assertEquals(true, controller.radnetCommPortalDetail.length() > 0, 'radnetCommPortalDetail should be correctly calculated');
        System.assertEquals(true, controller.getApiKeyForHelper != null, 'token found');
        Test.stopTest();
    }
}