@isTest
public with sharing class MapOsrmHelperTest {
    static String SESSION_ID = '9021c8e0-2dbc-4d38-a5c0-b048a79d89a3';

    static MapOsrmHelper getMapHelper() {
        return new MapOsrmHelper();
    }

    // searchPlaces related tests
    @isTest
    public static void testSearchPlaces() {
        Test.startTest();

        MapApiException error;
        try {
            List<MapApi.Place> places = getMapHelper().searchPlaces(SESSION_ID, 'test');
        } catch (MapApiException e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');
        Assert.areEqual('not implemented', error.getMessage(), 'not implemented exception');

        Test.stopTest();
    }

    // getPlaceByID related tests
    @isTest
    public static void testGetPlaceByID() {
        Test.startTest();

        MapApiException error;
        try {
            String locationID = '322743601779';
            MapApi.Place place = getMapHelper().getPlaceByID(SESSION_ID, locationID);
        } catch (MapApiException e) {
            error = e;
        }
        Assert.areNotEqual(null, error, 'error should not be null');
        Assert.areEqual('not implemented', error.getMessage(), 'not implemented exception');

        Test.stopTest();
    }

    // getDistances related tests
    @isTest
    public static void testGetDistancesForNotAllDestinationsNearSource() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'table',
            200,
            '{"distances":[[0,64481,4016302]],"durations":[[0,2981.5,160715]]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        List<MapApi.LocationDistance> distances = getMapHelper().getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(64481, distances[0].distance, 'distance must match');
        Assert.areEqual(2981.5, distances[0].duration, 'duration must match');

        Assert.areEqual(4016302, distances[1].distance, 'distance must match');
        Assert.areEqual(160715, distances[1].duration, 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDistancesError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'table',
            500,
            ''
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3208760, -111.9862530),
            new MapApi.Location(33.3787930, -111.7259020)
        };
        List<MapApi.LocationDistance> distances = getMapHelper().getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(null, distances, 'distances must be null');

        Test.stopTest();
    }

    // getDirection related tests
    @isTest
    public static void testGetDirection() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'route',
            200,
            '{"code":"Ok","routes":[{"geometry":{"coordinates":[[-112.132335,33.636544],[-112.129975,33.639592],[-112.117335,33.639781],[-112.116058,33.636376],[-112.117442,33.567815],[-112.112576,33.55513],[-112.113247,33.475289],[-112.108349,33.461418],[-112.107815,33.431519],[-112.103035,33.428648],[-112.062489,33.42897],[-112.030015,33.426452],[-112.022865,33.423402],[-112.009162,33.411332],[-111.979216,33.410709],[-111.971071,33.407672],[-111.967606,33.400308],[-111.972642,33.3237],[-111.973519,33.319995],[-111.986222,33.320714]],"type":"LineString"},"legs":[{"steps":[],"summary":"","weight":2340.2,"duration":2315.3,"distance":49756.9}],"weight_name":"routability","weight":2340.2,"duration":2315.3,"distance":49756.9}],"waypoints":[{"hint":"e-sXgIC6G4AGAAAABAAAAEAAAAAVAAAATh7EQOIvPUCWdmRCGMSWQQYAAAAEAAAAQAAAABUAAACWYgAAEf9Q-cBAAQIy_lD5l0ABAgIAvxUQ1hbN","distance":21.185718061,"name":"North 34th Avenue","location":[-112.132335,33.636544]},{"hint":"eVn-hP___38HAAAAEQAAAFEAAABCAAAAJ8rAPwXg_T_koohBIWhbQQMAAAAIAAAAKAAAACAAAACWYgAA0jlT-Qpv_AGzOVP5rG_8AQUATxAQ1hbN","distance":18.197825703,"name":"","location":[-111.986222,33.320714]}]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3208760, -111.9862530);
        MapApi.Direction direction = getMapHelper().getDirection(MapApi.Mode.DRIVE, source, destination);

        Assert.areEqual(1, direction.routes.size(), 'must return 1 route');
        Assert.areEqual(49756.9, direction.routes[0].distance, 'distance must match');
        Assert.areEqual(2315.3, direction.routes[0].duration, 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDirectionError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'route',
            500,
            ''
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3208760, -111.9862530);
        MapApi.Direction direction = getMapHelper().getDirection(MapApi.Mode.DRIVE, source, destination);

        Assert.areEqual(null, direction, 'direction must be null');

        Test.stopTest();
    }
}