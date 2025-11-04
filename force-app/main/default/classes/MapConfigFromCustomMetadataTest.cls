@isTest
public with sharing class MapConfigFromCustomMetadataTest {

    @isTest
    static void testGetHelpers() {
        MapConfigFromCustomMetadata mapConfig = new MapConfigFromCustomMetadata();
        Assert.isTrue(mapConfig.getSearchHelpers().size() > 0, 'config has search helpers');
        Assert.isTrue(mapConfig.getDistancesHelpers().size() > 0, 'config has distances helpers');
        Assert.isTrue(mapConfig.getDirectionHelpers().size() > 0, 'config has direction helpers');
    }

    @isTest
    static void testGetMapHelper() {
        Test.startTest();

        MapConfigFromCustomMetadata mapConfig = new MapConfigFromCustomMetadata();
        MapHelper helper = mapConfig.getMapHelper(MapApi.HelperType.CACHE);
        Assert.isInstanceOfType(helper, MapCache.class, 'helper class must match');

        helper = mapConfig.getMapHelper(MapApi.HelperType.LOCATIONIQ);
        Assert.isInstanceOfType(helper, MapLocationIQHelper.class, 'helper class must match');

        helper = mapConfig.getMapHelper(MapApi.HelperType.MAPBOX);
        Assert.isInstanceOfType(helper, MapboxHelper.class, 'helper class must match');

        helper = mapConfig.getMapHelper(MapApi.HelperType.OSRM);
        Assert.isInstanceOfType(helper, MapOsrmHelper.class, 'helper class must match');

        helper = mapConfig.getMapHelper(MapApi.HelperType.GEOAPIFY);
        Assert.isInstanceOfType(helper, MapGeoapifyHelper.class, 'helper class must match');

        Exception error;
        try {
            helper = mapConfig.getMapHelper(null);
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }

    @isTest
    static void testConvertToHelpers() {
        Test.startTest();

        MapConfigFromCustomMetadata mapConfig = new MapConfigFromCustomMetadata();
        List<MapApi.HelperType> helpersUpperCase = mapConfig.convertToHelpers(new List<String>{'CACHE', 'LOCATIONIQ', 'MAPBOX', 'OSRM', 'GEOAPIFY'});
        
        Assert.areEqual(MapApi.HelperType.CACHE, helpersUpperCase[0], 'helper type must match');
        Assert.areEqual(MapApi.HelperType.LOCATIONIQ, helpersUpperCase[1], 'helper type must match');
        Assert.areEqual(MapApi.HelperType.MAPBOX, helpersUpperCase[2], 'helper type must match');
        Assert.areEqual(MapApi.HelperType.OSRM, helpersUpperCase[3], 'helper type must match');
        Assert.areEqual(MapApi.HelperType.GEOAPIFY, helpersUpperCase[4], 'helper type must match');

        List<MapApi.HelperType> helpersLowerCase = mapConfig.convertToHelpers(new List<String>{'cache', 'locationiq', 'mapbox', 'osrm', 'geoapify'});
        
        Assert.areEqual(MapApi.HelperType.CACHE, helpersLowerCase[0], 'helper type must match');
        Assert.areEqual(MapApi.HelperType.LOCATIONIQ, helpersLowerCase[1], 'helper type must match');
        Assert.areEqual(MapApi.HelperType.MAPBOX, helpersLowerCase[2], 'helper type must match');
        Assert.areEqual(MapApi.HelperType.OSRM, helpersLowerCase[3], 'helper type must match');
        Assert.areEqual(MapApi.HelperType.GEOAPIFY, helpersLowerCase[4], 'helper type must match');

        Test.stopTest();
    }
}