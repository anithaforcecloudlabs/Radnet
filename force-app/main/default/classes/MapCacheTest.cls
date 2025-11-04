@isTest
public with sharing class MapCacheTest {
    static String SESSION_ID = '9021c8e0-2dbc-4d38-a5c0-b048a79d89a3';

    private class MockCacheConfig implements MapConfig {
        Integer cacheTimeout;
        MockCacheConfig(Integer cacheTimeout) {
            this.cacheTimeout = cacheTimeout;
        }
        public Integer getCacheTimeout() { return this.cacheTimeout; }
        public List<MapApi.HelperType> getSearchHelpers() { return null; }
        public List<MapApi.HelperType> getDistancesHelpers() { return null; }
        public List<MapApi.HelperType> getDirectionHelpers() { return null; }
        public MapHelper getMapHelper(MapApi.HelperType helper) { return null; }
    }

    @isTest
    static void testCacheCreate() {
        Test.startTest();

        MapCache.cacheConfig = new MockCacheConfig(500);
        MapCache cache = new MapCache();
        Assert.areEqual(500, cache.cacheTimeout, 'cache timeout must be 500 ms');

        Test.stopTest();
    }

    // searchPlaces related tests
    @isTest
    static void testSearchPlacesCacheMiss() {
        Test.startTest();

        MapCache cache = new MapCache();
        List<MapApi.Place> results = cache.searchPlaces(SESSION_ID, '2306 Nebraska');

        Assert.areEqual(null, results, 'results should be null');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesCacheHit() {
        Test.startTest();

        List<MapApi.Place> valueToCache = new List<MapApi.Place>{
            new MapApi.Place('LOCATIONIQ_331123893114','2306, Nebraska Street, Muskogee, Muskogee County, Oklahoma, 74403', new MapApi.Location(35.727213, -95.341291)),
            new MapApi.Place('LOCATIONIQ_332119042728','2306, Nebraska Avenue, Flint, Genesee County, Michigan, 48506', new MapApi.Location(43.026943, -83.660237)),
            new MapApi.Place('LOCATIONIQ_331175656969','2306, Nebraska Avenue, Fort Pierce, St. Lucie County, Florida, 34950', new MapApi.Location(27.433203, -80.347385)),
            new MapApi.Place('LOCATIONIQ_333429841937','2306, Nebraska Avenue East, Maplewood, Ramsey County, Minnesota, 55119', new MapApi.Location(44.98586, -93.002834)),
            new MapApi.Place('LOCATIONIQ_332722018630','2306, North Nebraska Avenue, Tampa, Hillsborough County, Florida, 33602', new MapApi.Location(27.965701, -82.451485))
        };
        MapCache cache = new MapCache();
        cache.setSearchPlaces(SESSION_ID, '2306 Nebraska', valueToCache);
        List<MapApi.Place> results = cache.searchPlaces(SESSION_ID, '2306 Nebraska');

        Assert.areEqual(5, results.size(), '5 results should be returned');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesEmptyQuery() {
        Test.startTest();

        MapCache cache = new MapCache();
        List<MapApi.Place> results = cache.searchPlaces(SESSION_ID, '');

        Assert.areEqual(0, results.size(), '0 results should be returned');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesEmptySetSearchPlaces() {
        Test.startTest();

        MapCache cache = new MapCache();
        cache.setSearchPlaces(SESSION_ID, '2306 Nebraska', new List<MapApi.Place>());
        List<MapApi.Place> results = cache.searchPlaces(SESSION_ID, '2306 Nebraska');

        Assert.areEqual(null, results, 'results should be null');

        cache.setSearchPlaces(SESSION_ID, '2306 Nebraska', null);
        results = cache.searchPlaces(SESSION_ID, '2306 Nebraska');

        Assert.areEqual(null, results, 'results should be null');

        Test.stopTest();
    }

    // getPlaceByID related tests
    @isTest
    static void testGetPlaceByIDCacheMiss() {
        Test.startTest();

        MapCache cache = new MapCache();
        MapApi.Place result = cache.getPlaceByID(SESSION_ID, '331123893114');

        Assert.areEqual(null, result, 'result should be null');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDCacheHit() {
        Test.startTest();

        MapCache cache = new MapCache();
        cache.setPlaceByID(SESSION_ID,
            '331123893114',
            new MapApi.Place(
                'LOCATIONIQ_331123893114',
                '2306, Nebraska Street, Muskogee, Muskogee County, Oklahoma, 74403',
                new MapApi.Location(35.727213, -95.341291)
            )
        );
        MapApi.Place result = cache.getPlaceByID(SESSION_ID, '331123893114');

        Assert.areNotEqual(null, result, 'results should not be null');
        Assert.areEqual('LOCATIONIQ_331123893114', result.id, 'id should match');
        Assert.areEqual('2306, Nebraska Street, Muskogee, Muskogee County, Oklahoma, 74403', result.display_name, 'display_name should match');
        Assert.areEqual(35.727213, result.location.latitude, 'latitude should match');
        Assert.areEqual(-95.341291, result.location.longitude, 'longitude should match');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDEmptyID() {
        Test.startTest();

        MapCache cache = new MapCache();
        MapApi.Place result = cache.getPlaceByID(SESSION_ID, '');

        Assert.areEqual(null, result, 'result should be null');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDNullSetPlace() {
        Test.startTest();

        MapCache cache = new MapCache();
        cache.setPlaceByID(SESSION_ID, '331123893114', null);
        MapApi.Place result = cache.getPlaceByID(SESSION_ID, '331123893114');

        Assert.areEqual(null, result, 'result should be null');

        Test.stopTest();
    }

    // getDistances related tests
    @isTest
    static void testGetDistancesCacheMiss() {
        Test.startTest();

        MapCache cache = new MapCache();
        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };

        List<MapApi.LocationDistance> results = cache.getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(null, results, 'results should be null');

        Test.stopTest();
    }

    @isTest
    static void testGetDistancesCacheHit() {
        Test.startTest();

        MapCache cache = new MapCache();
        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        cache.setDistances(MapApi.Mode.DRIVE, source, destinations, new List<MapApi.LocationDistance>{
            new MapApi.LocationDistance(source, destinations[0], Double.valueOf(64489.1), Double.valueOf(2979.5)),
            new MapApi.LocationDistance(source, destinations[1], Double.valueOf(3474228.98), Double.valueOf(231615.27))
        });
        List<MapApi.LocationDistance> results = cache.getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(2, results.size(), '2 results should be returned');
        Assert.areEqual(source.toString(), results[0].source.toString(), 'source should match');
        Assert.areEqual(destinations[0].toString(), results[0].destination.toString(), 'destination should match');
        Assert.areEqual(64489.1, results[0].distance, 'distance should match');
        Assert.areEqual(2979.5, results[0].duration, 'duration should match');

        Assert.areEqual(source.toString(), results[1].source.toString(), 'source should match');
        Assert.areEqual(destinations[1].toString(), results[1].destination.toString(), 'destination should match');
        Assert.areEqual(3474228.98, results[1].distance, 'distance should match');
        Assert.areEqual(231615.27, results[1].duration, 'duration should match');

        Test.stopTest();
    }

    @isTest
    static void testGetDistancesEmptySetDistances() {
        Test.startTest();

        MapCache cache = new MapCache();
        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };

        cache.setDistances(MapApi.Mode.DRIVE, source, destinations, new List<MapApi.LocationDistance>());
        List<MapApi.LocationDistance> results = cache.getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(null, results, 'results should be null');

        cache.setDistances(MapApi.Mode.DRIVE, source, destinations, null);
        results = cache.getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(null, results, 'results should be null');

        Test.stopTest();
    }

    // getDirections related tests
    @isTest
    static void testGetDirectionCacheMiss() {
        Test.startTest();

        MapCache cache = new MapCache();
        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);

        MapApi.Direction result = cache.getDirection(MapApi.Mode.DRIVE, source, destination);

        Assert.areEqual(null, result, 'result should be null');

        Test.stopTest();
    }

    @isTest
    static void testGetDirectionCacheHit() {
        Test.startTest();

        MapCache cache = new MapCache();
        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);

        MapApi.Direction cacheValue = (MapApi.Direction) JSON.deserialize(
            '{"destination":{"latitude":33.378793,"longitude":-111.725902},"routes":[{"distance":64489.1,"duration":2979.5,"geometry":{"coordinates":[[-112.132335,33.636544],[-112.129975,33.639592],[-112.117335,33.639781],[-112.116058,33.636376],[-112.117467,33.568831],[-112.112539,33.554568],[-112.113247,33.475289],[-112.108349,33.461418],[-112.108279,33.433145],[-112.106022,33.429629],[-112.028302,33.426073],[-112.009162,33.411332],[-111.973186,33.409133],[-111.967795,33.402278],[-111.968914,33.389105],[-111.955124,33.385549],[-111.745553,33.386276],[-111.737478,33.384477],[-111.73974,33.379152],[-111.725903,33.378912]],"type":"LineString"}}],"source":{"latitude":33.63650345,"longitude":-112.13255847}}',
            MapApi.Direction.class
        );
        cache.setDirection(MapApi.Mode.DRIVE, source, destination, cacheValue);
        MapApi.Direction result = cache.getDirection(MapApi.Mode.DRIVE, source, destination);

        Assert.areEqual(source.toString(), result.source.toString(), 'source should match');
        Assert.areEqual(destination.toString(), result.destination.toString(), 'destination should match');
        Assert.areEqual(1, result.routes.size(), 'results should contain 1 route');
        Assert.areEqual(64489.1, result.routes[0].distance, 'distance should match');
        Assert.areEqual(2979.5, result.routes[0].duration, 'duration should match');
        Assert.areNotEqual(null, result.routes[0].geometry, 'geometry must exist');

        Test.stopTest();
    }

    @isTest
    static void testGetDirectionEmptySetDirection() {
        Test.startTest();

        MapCache cache = new MapCache();
        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3787930, -111.7259020);

        cache.setDirection(MapApi.Mode.DRIVE, source, destination, null);
        MapApi.Direction result = cache.getDirection(MapApi.Mode.DRIVE, source, destination);

        Assert.areEqual(null, result, 'result should be null');

        Test.stopTest();
    }
}