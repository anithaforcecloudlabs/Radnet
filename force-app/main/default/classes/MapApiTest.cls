/**
 * @description    : Test class for MapApi
 *
 * Created Date    : 15/05/2024
 *
 * @JIRA Id        : CC-232, CC-233
**/
@isTest(SeeAllData=false)
public with sharing class MapApiTest {
    static String SESSION_ID = '9021c8e0-2dbc-4d38-a5c0-b048a79d89a3';

    private class MockMapHelper implements MapHelper {

        private String data;
        public Integer methodCalled;

        public MockMapHelper() {
            this.data = null;
            this.methodCalled = 0;
        }
        public MockMapHelper(String data) {
            this.data = data;
            this.methodCalled = 0;
        }

        public void reset() {
            this.methodCalled = 0;
        }

        public List<MapApi.Place> searchPlaces(String sessionID, String query) {
            this.methodCalled++;
            if (this.data == null) {
                return null;
            }
            List<MapApi.Place> result = (List<MapApi.Place>) JSON.deserialize(this.data, List<MapApi.Place>.class);
            System.debug(result);
            return result;
        }

        public MapApi.Place getPlaceByID(String sessionID, String locationID) {
            this.methodCalled++;
            if (this.data == null) {
                return null;
            }
            MapApi.Place result = (MapApi.Place) JSON.deserialize(this.data, MapApi.Place.class);
            return result;
        }

        public List<MapApi.LocationDistance> getDistances(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations) {
            this.methodCalled++;
            if (this.data == null) {
                return null;
            }
            List<MapApi.LocationDistance> result = (List<MapApi.LocationDistance>) JSON.deserialize(this.data, List<MapApi.LocationDistance>.class);
            return result;
        }

        public MapApi.Direction getDirection(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination) {
            this.methodCalled++;
            if (this.data == null) {
                return null;
            }
            MapApi.Direction result = (MapApi.Direction) JSON.deserialize(this.data, MapApi.Direction.class);
            return result;
        }
    }

    private class MockExceptionMapHelper implements MapHelper {

        public List<MapApi.Place> searchPlaces(String sessionID, String query) {
            throw new MapApiException('not implemented');
        }

        public MapApi.Place getPlaceByID(String sessionID, String locationID) {
            throw new MapApiException('not implemented');            
        }

        public List<MapApi.LocationDistance> getDistances(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations) {
            throw new MapApiException('not implemented');
        }

        public MapApi.Direction getDirection(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination) {
            throw new MapApiException('not implemented');            
        }
    }

    private class MockMapConfig implements MapConfig {
        Map<MapApi.HelperType, MapHelper> mapHelpers;
        List<MapApi.HelperType> helperTypes;

        MockMapConfig() {
            this.mapHelpers = new Map<MapApi.HelperType, MapHelper>();
            this.helperTypes = new List<MapApi.HelperType>();
        }

        public void addHelper(MapApi.HelperType helperType, MapHelper helper) {
            this.helperTypes.add(helperType);
            this.mapHelpers.put(helperType, helper);
        }

        public Integer getCacheTimeout() { return 0; }
        public List<MapApi.HelperType> getSearchHelpers() { return this.helperTypes; }
        public List<MapApi.HelperType> getDistancesHelpers() { return this.helperTypes; }
        public List<MapApi.HelperType> getDirectionHelpers() { return this.helperTypes; }
        public MapHelper getMapHelper(MapApi.HelperType helper) { return this.mapHelpers.get(helper); }
    }
    
    @isTest
    static void testLocationCreationAndToString() {
        Test.startTest();

        MapApi.Location location = new MapApi.Location(33.63650345, -112.13255847);
        Assert.areEqual('-112.13255847,33.63650345', location.toString(), 'location string conversion should match');

        location = new MapApi.Location(Double.valueOf(33.63650345), Double.valueOf(-112.13255847));
        Assert.areEqual('-112.13255847,33.63650345', location.toString(), 'location string conversion should match');

        location = new MapApi.Location('33.63650345', '-112.13255847');
        Assert.areEqual('-112.13255847,33.63650345', location.toString(), 'location string conversion should match');

        Test.stopTest();
    }

    @isTest
    static void testPlaceCreation() {
        String placeDisplayName = 'test_display_name';
        String placeID = '1';

        MapApi.Place place = new MapApi.Place(placeID, placeDisplayName);
        Assert.areEqual(placeID, place.id, 'place id must match');
        Assert.areEqual(placeDisplayName, place.display_name, 'place display name must match');
        Assert.areEqual(null, place.location, 'location must be null');

        place = new MapApi.Place(placeID, placeDisplayName, new MapApi.Location(33.63650345, -112.13255847));
        Assert.areEqual(placeID, place.id, 'place id must match');
        Assert.areEqual(placeDisplayName, place.display_name, 'place display name must match');
        Assert.areNotEqual(null, place.location, 'location must not be null');
        Assert.areEqual(33.63650345, place.location.latitude, 'latitude must match');
        Assert.areEqual(-112.13255847, place.location.longitude, 'longitude must match');

        MapApi.Place otherPlace = new MapApi.Place(placeID, placeDisplayName);
        Assert.areEqual(place.getHash(), otherPlace.getHash(), 'hash must match');

        otherPlace = new MapApi.Place(placeID, placeDisplayName + '_');
        Assert.areNotEqual(place.getHash(), otherPlace.getHash(), 'hash must not match');
    }

    @isTest
    static void testLocationDistanceCreation() {
        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);

        MapApi.LocationDistance locationDistance = new MapApi.LocationDistance(source, destination, Double.valueOf(64489.1), Double.valueOf(2979.5));
        Assert.areEqual(source.toString(), locationDistance.source.toString(), 'source must match');
        Assert.areEqual(destination.toString(), locationDistance.destination.toString(), 'destination must match');
        Assert.areEqual(64489.1, locationDistance.distance, 'distance must match');
        Assert.areEqual(2979.5, locationDistance.duration, 'duration must match');
    }

    @isTest
    static void testRouteCreation() {
        String geoJsonString = '{"coordinates":[[-112.132335,33.636544],[-112.129975,33.639592],[-112.117335,33.639781],[-112.116058,33.636376],[-112.117467,33.568831],[-112.112539,33.554568],[-112.113247,33.475289],[-112.108349,33.461418],[-112.108279,33.433145],[-112.106022,33.429629],[-112.028302,33.426073],[-112.009162,33.411332],[-111.973186,33.409133],[-111.967795,33.402278],[-111.968914,33.389105],[-111.955124,33.385549],[-111.745553,33.386276],[-111.737478,33.384477],[-111.73974,33.379152],[-111.725903,33.378912]],"type":"LineString"}';
        MapApi.GeoJSON geometry = (MapApi.GeoJSON) JSON.deserialize(geoJsonString, MapApi.GeoJSON.class);

        MapApi.Route route = new MapApi.Route(geometry, Double.valueOf(64489.1), Double.valueOf(2979.5));
        Assert.areEqual(geometry, route.geometry, 'destination must match');
        Assert.areEqual(64489.1, route.distance, 'distance must match');
        Assert.areEqual(2979.5, route.duration, 'duration must match');
    }

    @isTest
    static void testDirectionCreation() {
        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);

        String geoJsonString = '{"coordinates":[[-112.132335,33.636544],[-112.129975,33.639592],[-112.117335,33.639781],[-112.116058,33.636376],[-112.117467,33.568831],[-112.112539,33.554568],[-112.113247,33.475289],[-112.108349,33.461418],[-112.108279,33.433145],[-112.106022,33.429629],[-112.028302,33.426073],[-112.009162,33.411332],[-111.973186,33.409133],[-111.967795,33.402278],[-111.968914,33.389105],[-111.955124,33.385549],[-111.745553,33.386276],[-111.737478,33.384477],[-111.73974,33.379152],[-111.725903,33.378912]],"type":"LineString"}';
        MapApi.GeoJSON geometry = (MapApi.GeoJSON) JSON.deserialize(geoJsonString, MapApi.GeoJSON.class);
        MapApi.Route route = new MapApi.Route(geometry, Double.valueOf(64489.1), Double.valueOf(2979.5));

        MapApi.Direction direction = new MapApi.Direction(source, destination, new List<MapApi.Route>{route});
        Assert.areEqual(source.toString(), direction.source.toString(), 'source must match');
        Assert.areEqual(destination.toString(), direction.destination.toString(), 'destination must match');
        Assert.areEqual(1, direction.routes.size(), 'must return 1 route');
        Assert.areEqual(route, direction.routes[0], 'route must match');
    }

    // searchPlaces related tests
    @isTest
    static void testSearchPlaces() {
        Test.startTest();

        MockMapHelper mockHelper = new MockMapHelper(
            '[{"display_name":"2306, Nebraska Avenue, St. Louis, Missouri, 63104","id":"LOCATIONIQ_376978747","location":{"latitude":38.6082761,"longitude":-90.229385}},{"display_name":"2306, Nebraska Avenue, Toledo, Lucas County, Ohio, 43607","id":"LOCATIONIQ_367918022","location":{"latitude":41.64557285714286,"longitude":-83.59925257142858}},{"display_name":"2306, Nebraska Avenue, Kansas City, Wyandotte County, Kansas, 66102","id":"LOCATIONIQ_365630417","location":{"latitude":39.11760932323232,"longitude":-94.65492256565656}},{"display_name":"2306, Nebraska Avenue, Flint, Genesee County, Michigan, 48506","id":"LOCATIONIQ_378891582","location":{"latitude":43.02723294949495,"longitude":-83.66043165656565}},{"display_name":"2306, Nebraska Avenue, Ramsey County, Minnesota, 55119","id":"LOCATIONIQ_373112079","location":{"latitude":44.98609395333807,"longitude":-93.00265652374513}}]'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        List<MapApi.Place> results = MapApi.searchPlaces(SESSION_ID, '2306 Nebraska Avenue');
        Assert.areEqual(5, results.size(), '5 results should be returned');
        Assert.areEqual(1, mockHelper.methodCalled, 'mock should be called');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesWithCaching() {
        Test.startTest();

        MockMapHelper mockHelper = new MockMapHelper(
            '[{"display_name":"2306, Nebraska Avenue, St. Louis, Missouri, 63104","id":"LOCATIONIQ_376978747","location":{"latitude":38.6082761,"longitude":-90.229385}},{"display_name":"2306, Nebraska Avenue, Toledo, Lucas County, Ohio, 43607","id":"LOCATIONIQ_367918022","location":{"latitude":41.64557285714286,"longitude":-83.59925257142858}},{"display_name":"2306, Nebraska Avenue, Kansas City, Wyandotte County, Kansas, 66102","id":"LOCATIONIQ_365630417","location":{"latitude":39.11760932323232,"longitude":-94.65492256565656}},{"display_name":"2306, Nebraska Avenue, Flint, Genesee County, Michigan, 48506","id":"LOCATIONIQ_378891582","location":{"latitude":43.02723294949495,"longitude":-83.66043165656565}},{"display_name":"2306, Nebraska Avenue, Ramsey County, Minnesota, 55119","id":"LOCATIONIQ_373112079","location":{"latitude":44.98609395333807,"longitude":-93.00265652374513}}]'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.CACHE, new MapCache());
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        List<MapApi.Place> results = MapApi.searchPlaces(SESSION_ID, '2306 Nebraska Avenue');
        Assert.areEqual(5, results.size(), '5 results should be returned');
        Assert.areEqual(1, mockHelper.methodCalled, 'method should be called');
        mockHelper.reset();

        results = MapApi.searchPlaces(SESSION_ID, '2306 Nebraska Avenue');
        Assert.areEqual(5, results.size(), '5 results should be returned');
        Assert.areEqual(0, mockHelper.methodCalled, 'mock should not be called');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesFallback() {
        Test.startTest();

        MockMapHelper mockHelperNullResponse = new MockMapHelper();
        MockMapHelper mockHelper = new MockMapHelper(
            '[{"display_name":"2306, Nebraska Avenue, St. Louis, Missouri, 63104","id":"LOCATIONIQ_376978747","location":{"latitude":38.6082761,"longitude":-90.229385}},{"display_name":"2306, Nebraska Avenue, Toledo, Lucas County, Ohio, 43607","id":"LOCATIONIQ_367918022","location":{"latitude":41.64557285714286,"longitude":-83.59925257142858}},{"display_name":"2306, Nebraska Avenue, Kansas City, Wyandotte County, Kansas, 66102","id":"LOCATIONIQ_365630417","location":{"latitude":39.11760932323232,"longitude":-94.65492256565656}},{"display_name":"2306, Nebraska Avenue, Flint, Genesee County, Michigan, 48506","id":"LOCATIONIQ_378891582","location":{"latitude":43.02723294949495,"longitude":-83.66043165656565}},{"display_name":"2306, Nebraska Avenue, Ramsey County, Minnesota, 55119","id":"LOCATIONIQ_373112079","location":{"latitude":44.98609395333807,"longitude":-93.00265652374513}}]'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.MAPBOX, mockHelperNullResponse);
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        List<MapApi.Place> results = MapApi.searchPlaces(SESSION_ID, '2306 Nebraska Avenue');
        Assert.areEqual(5, results.size(), '5 results should be returned');
        Assert.areEqual(1, mockHelperNullResponse.methodCalled, 'mock with null response should be called');
        Assert.areEqual(1, mockHelper.methodCalled, 'mock should be called');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesNoResult() {
        Test.startTest();

        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, new MockMapHelper());
        MapApi.mapConfig = mockConfig;

        Exception error;
        try {
            List<MapApi.Place> results = MapApi.searchPlaces(SESSION_ID, '2306 Nebraska Avenue');
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesError() {
        Test.startTest();

        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, new MockExceptionMapHelper());
        MapApi.mapConfig = mockConfig;

        Exception error;
        try {
            List<MapApi.Place> results = MapApi.searchPlaces(SESSION_ID, '2306 Nebraska Avenue');
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }

    // getPlaceByID related tests
    @isTest
    static void testGetPlaceByID() {
        Test.startTest();

        MockMapHelper mockHelper = new MockMapHelper(
            '{"display_name":"2306, Nebraska Avenue, St. Louis, Missouri, 63104","id":"LOCATIONIQ_376978747","location":{"latitude":38.6082761,"longitude":-90.229385}}'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        MapApi.Place result = MapApi.getPlaceByID(SESSION_ID, 'LOCATIONIQ_376978747');
        Assert.areNotEqual(null, result, 'result should not be null');
        Assert.areEqual(1, mockHelper.methodCalled, 'mock should be called');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDWithCaching() {
        Test.startTest();

        MockMapHelper mockHelper = new MockMapHelper(
            '{"display_name":"2306, Nebraska Avenue, St. Louis, Missouri, 63104","id":"LOCATIONIQ_376978747","location":{"latitude":38.6082761,"longitude":-90.229385}}'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.CACHE, new MapCache());
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        MapApi.Place result = MapApi.getPlaceByID(SESSION_ID, 'LOCATIONIQ_376978747');
        Assert.areNotEqual(null, result, 'result should not be null');
        Assert.areEqual(1, mockHelper.methodCalled, 'method should be called');
        mockHelper.reset();

        result = MapApi.getPlaceByID(SESSION_ID, 'LOCATIONIQ_376978747');
        Assert.areNotEqual(null, result, 'result should not be null');
        Assert.areEqual(0, mockHelper.methodCalled, 'mock should not be called');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDNoResult() {
        Test.startTest();

        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, new MockMapHelper());
        MapApi.mapConfig = mockConfig;

        Exception error;
        try {
            MapApi.Place result = MapApi.getPlaceByID(SESSION_ID, 'LOCATIONIQ_376978747');
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDError() {
        Test.startTest();

        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, new MockExceptionMapHelper());
        MapApi.mapConfig = mockConfig;

        Exception error;
        try {
            MapApi.Place result = MapApi.getPlaceByID(SESSION_ID, 'LOCATIONIQ_376978747');
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }

    // getDistances related tests
    @isTest
    static void testGetDistances() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };

        MockMapHelper mockHelper = new MockMapHelper(
            '[{"destination":{"latitude":33.378793,"longitude":-111.725902},"distance":64489.1,"duration":2979.5,"source":{"latitude":33.63650345,"longitude":-112.13255847}},{"destination":{"latitude":40.655855,"longitude":-73.598351},"distance":3474228.98,"duration":231615.27,"source":{"latitude":33.63650345,"longitude":-112.13255847}}]'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        List<MapApi.LocationDistance> results = MapApi.getDistances(source, destinations);
        Assert.areEqual(2, results.size(), '2 results should be returned');
        Assert.areEqual(source.toString(), results[0].source.toString(), 'source should match');
        Assert.areEqual(destinations[0].toString(), results[0].destination.toString(), 'destination should match');
        Assert.areEqual(source.toString(), results[1].source.toString(), 'source should match');
        Assert.areEqual(destinations[1].toString(), results[1].destination.toString(), 'destination should match');
        Assert.areEqual(1, mockHelper.methodCalled, 'mock should be called');

        Test.stopTest();
    }

    @isTest
    static void testGetDistancesWithCaching() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        MockMapHelper mockHelper = new MockMapHelper(
            '[{"destination":{"latitude":33.378793,"longitude":-111.725902},"distance":64489.1,"duration":2979.5,"source":{"latitude":33.63650345,"longitude":-112.13255847}},{"destination":{"latitude":40.655855,"longitude":-73.598351},"distance":3474228.98,"duration":231615.27,"source":{"latitude":33.63650345,"longitude":-112.13255847}}]'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.CACHE, new MapCache());
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        List<MapApi.LocationDistance> results = MapApi.getDistances(source, destinations);
        Assert.areEqual(2, results.size(), '2 results should be returned');
        Assert.areEqual(source.toString(), results[0].source.toString(), 'source should match');
        Assert.areEqual(destinations[0].toString(), results[0].destination.toString(), 'destination should match');
        Assert.areEqual(source.toString(), results[1].source.toString(), 'source should match');
        Assert.areEqual(destinations[1].toString(), results[1].destination.toString(), 'destination should match');
        Assert.areEqual(1, mockHelper.methodCalled, 'mock should be called');
        mockHelper.reset();

        results = MapApi.getDistances(source, destinations);
        Assert.areEqual(2, results.size(), '2 results should be returned');
        Assert.areEqual(source.toString(), results[0].source.toString(), 'source should match');
        Assert.areEqual(destinations[0].toString(), results[0].destination.toString(), 'destination should match');
        Assert.areEqual(source.toString(), results[1].source.toString(), 'source should match');
        Assert.areEqual(destinations[1].toString(), results[1].destination.toString(), 'destination should match');
        Assert.areEqual(0, mockHelper.methodCalled, 'mock should not be called');

        Test.stopTest();
    }

    @isTest
    static void testGetDistancesFallback() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        MockMapHelper mockHelperNullResponse = new MockMapHelper();
        MockMapHelper mockHelper = new MockMapHelper(
            '[{"destination":{"latitude":33.378793,"longitude":-111.725902},"distance":64489.1,"duration":2979.5,"source":{"latitude":33.63650345,"longitude":-112.13255847}},{"destination":{"latitude":40.655855,"longitude":-73.598351},"distance":3474228.98,"duration":231615.27,"source":{"latitude":33.63650345,"longitude":-112.13255847}}]'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.MAPBOX, mockHelperNullResponse);
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        List<MapApi.LocationDistance> results = MapApi.getDistances(source, destinations);
        Assert.areEqual(2, results.size(), '2 results should be returned');
        Assert.areEqual(source.toString(), results[0].source.toString(), 'source should match');
        Assert.areEqual(destinations[0].toString(), results[0].destination.toString(), 'destination should match');
        Assert.areEqual(source.toString(), results[1].source.toString(), 'source should match');
        Assert.areEqual(destinations[1].toString(), results[1].destination.toString(), 'destination should match');
        Assert.areEqual(1, mockHelperNullResponse.methodCalled, 'mock with null response should be called');
        Assert.areEqual(1, mockHelper.methodCalled, 'mock should be called');

        Test.stopTest();
    }

    @isTest
    static void testGetDistancesNoResult() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, new MockMapHelper());
        MapApi.mapConfig = mockConfig;

        Exception error;
        try {
            List<MapApi.LocationDistance> results = MapApi.getDistances(source, destinations);
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }

    @isTest
    static void testGetDistancesError() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, new MockExceptionMapHelper());
        MapApi.mapConfig = mockConfig;

        Exception error;
        try {
            List<MapApi.LocationDistance> results = MapApi.getDistances(source, destinations);
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }

    // getDirection related tests
    @isTest
    static void testGetDirection() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);
        MockMapHelper mockHelper = new MockMapHelper(
            '{"destination":{"latitude":33.378793,"longitude":-111.725902},"routes":[{"distance":64489.1,"duration":2979.5,"geometry":{"coordinates":[[-112.132335,33.636544],[-112.129975,33.639592],[-112.117335,33.639781],[-112.116058,33.636376],[-112.117467,33.568831],[-112.112539,33.554568],[-112.113247,33.475289],[-112.108349,33.461418],[-112.108279,33.433145],[-112.106022,33.429629],[-112.028302,33.426073],[-112.009162,33.411332],[-111.973186,33.409133],[-111.967795,33.402278],[-111.968914,33.389105],[-111.955124,33.385549],[-111.745553,33.386276],[-111.737478,33.384477],[-111.73974,33.379152],[-111.725903,33.378912]],"type":"LineString"}}],"source":{"latitude":33.63650345,"longitude":-112.13255847}}'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        MapApi.Direction result = MapApi.getDirection(source, destination);
        Assert.areNotEqual(null, result, 'result should not be null');
        Assert.areEqual(1, result.routes.size(), '1 route should exist');
        Assert.areEqual(1, mockHelper.methodCalled, 'mock should be called');

        Test.stopTest();
    }

    @isTest
    static void testGetDirectionWithCaching() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);
        MockMapHelper mockHelper = new MockMapHelper(
            '{"destination":{"latitude":33.378793,"longitude":-111.725902},"routes":[{"distance":64489.1,"duration":2979.5,"geometry":{"coordinates":[[-112.132335,33.636544],[-112.129975,33.639592],[-112.117335,33.639781],[-112.116058,33.636376],[-112.117467,33.568831],[-112.112539,33.554568],[-112.113247,33.475289],[-112.108349,33.461418],[-112.108279,33.433145],[-112.106022,33.429629],[-112.028302,33.426073],[-112.009162,33.411332],[-111.973186,33.409133],[-111.967795,33.402278],[-111.968914,33.389105],[-111.955124,33.385549],[-111.745553,33.386276],[-111.737478,33.384477],[-111.73974,33.379152],[-111.725903,33.378912]],"type":"LineString"}}],"source":{"latitude":33.63650345,"longitude":-112.13255847}}'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.CACHE, new MapCache());
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        MapApi.Direction result = MapApi.getDirection(source, destination);
        Assert.areNotEqual(null, result, 'result should not be null');
        Assert.areEqual(1, result.routes.size(), '1 route should exist');
        Assert.areEqual(1, mockHelper.methodCalled, 'method should be called');
        mockHelper.reset();

        result = MapApi.getDirection(source, destination);
        Assert.areNotEqual(null, result, 'result should not be null');
        Assert.areEqual(1, result.routes.size(), '1 route should exist');
        Assert.areEqual(0, mockHelper.methodCalled, 'mock should not be called');

        Test.stopTest();
    }

    @isTest
    static void testGetDirectionFallback() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);
        MockMapHelper mockHelperNullResponse = new MockMapHelper();
        MockMapHelper mockHelper = new MockMapHelper(
            '{"destination":{"latitude":33.378793,"longitude":-111.725902},"routes":[{"distance":64489.1,"duration":2979.5,"geometry":{"coordinates":[[-112.132335,33.636544],[-112.129975,33.639592],[-112.117335,33.639781],[-112.116058,33.636376],[-112.117467,33.568831],[-112.112539,33.554568],[-112.113247,33.475289],[-112.108349,33.461418],[-112.108279,33.433145],[-112.106022,33.429629],[-112.028302,33.426073],[-112.009162,33.411332],[-111.973186,33.409133],[-111.967795,33.402278],[-111.968914,33.389105],[-111.955124,33.385549],[-111.745553,33.386276],[-111.737478,33.384477],[-111.73974,33.379152],[-111.725903,33.378912]],"type":"LineString"}}],"source":{"latitude":33.63650345,"longitude":-112.13255847}}'
        );
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.MAPBOX, mockHelperNullResponse);
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, mockHelper);
        MapApi.mapConfig = mockConfig;

        MapApi.Direction result = MapApi.getDirection(source, destination);
        Assert.areNotEqual(null, result, 'result should not be null');
        Assert.areEqual(1, result.routes.size(), '1 route should exist');
        Assert.areEqual(1, mockHelperNullResponse.methodCalled, 'mock with null response should be called');
        Assert.areEqual(1, mockHelper.methodCalled, 'mock should be called');

        Test.stopTest();
    }

    @isTest
    static void testGetDirectionNoResult() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, new MockMapHelper());
        MapApi.mapConfig = mockConfig;

        Exception error;
        try {
            MapApi.Direction result = MapApi.getDirection(source, destination);
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }

    @isTest
    static void testGetDirectionError() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);
        MockMapConfig mockConfig = new MockMapConfig();
        mockConfig.addHelper(MapApi.HelperType.LOCATIONIQ, new MockExceptionMapHelper());
        MapApi.mapConfig = mockConfig;

        Exception error;
        try {
            MapApi.Direction result = MapApi.getDirection(source, destination);
        } catch (Exception e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');

        Test.stopTest();
    }
}