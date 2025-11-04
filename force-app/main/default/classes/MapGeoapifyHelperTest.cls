@isTest
public with sharing class MapGeoapifyHelperTest {
    static String SESSION_ID = '9021c8e0-2dbc-4d38-a5c0-b048a79d89a3';

    static MapGeoapifyHelper getMapHelper() {
        return new MapGeoapifyHelper('test-api-key');
    }

    // searchPlaces related tests
    @isTest
    static void testSearchItemDisplayNameAndID() {
        Test.startTest();

        List<String> searchResults = new List<String>{
            '{"country_code":"us","housenumber":"2306","street":"Nebraska Avenue","country":"United States","county":"St. Lucie County","datasource":{"sourcename":"openaddresses","attribution":"© OpenAddresses contributors","license":"BSD-3-Clause License"},"postcode":"34950","state":"Florida","city":"Fort Pierce","state_code":"FL","lon":-80.347555,"lat":27.433646,"result_type":"building","formatted":"2306 Nebraska Avenue, Fort Pierce, FL 34950, United States of America","address_line1":"2306 Nebraska Avenue","address_line2":"Fort Pierce, FL 34950, United States of America","timezone":{"name":"America/New_York","offset_STD":"-05:00","offset_STD_seconds":-18000,"offset_DST":"-04:00","offset_DST_seconds":-14400,"abbreviation_STD":"EST","abbreviation_DST":"EDT"},"plus_code":"76VXCMM2+FX","plus_code_short":"CMM2+FX Fort Pierce, St. Lucie County, United States","rank":{"confidence":1,"match_type":"full_match"},"place_id":"51eca353573e1654c0598d0a9c6c036f3b40c00203e2034a6f70656e6164647265737365733a616464726573733a75732f666c2f73742d6c756369652d6164647265737365732d636f756e74792e6373763a31323061343637353534316535353630"}'
        };
        List<String> expectedDisplayNames = new List<String>{
            '2306 Nebraska Avenue, Fort Pierce, FL 34950, United States of America'
        };
        List<String> expectedIDs = new List<String>{
            'GEOAPIFY_51eca353573e1654c0598d0a9c6c036f3b40c00203e2034a6f70656e6164647265737365733a616464726573733a75732f666c2f73742d6c756369652d6164647265737365732d636f756e74792e6373763a31323061343637353534316535353630'
        };
        for (Integer index = 0; index < searchResults.size(); index++) {
            MapGeoapifyHelper.SearchResult sr = (MapGeoapifyHelper.SearchResult) JSON.deserialize(searchResults[index], MapGeoapifyHelper.SearchResult.class);
            Assert.areEqual(expectedDisplayNames[index], sr.getDisplayName(), 'display name must match');
            Assert.areEqual(expectedIDs[index], sr.getID(), 'id must match');
        }

        Test.stopTest();
    }

    @isTest
    static void testSearchPlaces() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'autocomplete',
            200,
            '{"results":[{"country_code":"us","housenumber":"2306","street":"Nebraska Avenue","country":"United States","county":"St. Lucie County","datasource":{"sourcename":"openaddresses","attribution":"© OpenAddresses contributors","license":"BSD-3-Clause License"},"postcode":"34950","state":"Florida","city":"Fort Pierce","state_code":"FL","lon":-80.347555,"lat":27.433646,"result_type":"building","formatted":"2306 Nebraska Avenue, Fort Pierce, FL 34950, United States of America","address_line1":"2306 Nebraska Avenue","address_line2":"Fort Pierce, FL 34950, United States of America","timezone":{"name":"America/New_York","offset_STD":"-05:00","offset_STD_seconds":-18000,"offset_DST":"-04:00","offset_DST_seconds":-14400,"abbreviation_STD":"EST","abbreviation_DST":"EDT"},"plus_code":"76VXCMM2+FX","plus_code_short":"CMM2+FX Fort Pierce, St. Lucie County, United States","rank":{"confidence":1,"match_type":"full_match"},"place_id":"51eca353573e1654c0598d0a9c6c036f3b40c00203e2034a6f70656e6164647265737365733a616464726573733a75732f666c2f73742d6c756369652d6164647265737365732d636f756e74792e6373763a31323061343637353534316535353630"},{"country_code":"us","housenumber":"2306","street":"Nebraska Avenue","country":"United States","county":"Genesee County","datasource":{"sourcename":"openaddresses","attribution":"© OpenAddresses contributors","license":"BSD-3-Clause License"},"postcode":"48506","state":"Michigan","district":"Flint","city":"Flint","state_code":"MI","lon":-83.660237,"lat":43.026943,"result_type":"building","formatted":"2306 Nebraska Avenue, Flint, MI 48506, United States of America","address_line1":"2306 Nebraska Avenue","address_line2":"Flint, MI 48506, United States of America","timezone":{"name":"America/Detroit","offset_STD":"-05:00","offset_STD_seconds":-18000,"offset_DST":"-04:00","offset_DST_seconds":-14400,"abbreviation_STD":"EST","abbreviation_DST":"EDT"},"plus_code":"86MR28GQ+QW","plus_code_short":"28GQ+QW Flint, Genesee County, United States","rank":{"confidence":1,"match_type":"full_match"},"place_id":"51fca6b05241ea54c05996ed43de72834540c00203e203496f70656e6164647265737365733a616464726573733a75732f6d692f67656e657365652d6164647265737365732d636f756e74792e6373763a36656663303336626366393039343634"},{"country_code":"us","housenumber":"2306","street":"Nebraska Street","country":"United States","county":"Muskogee County","datasource":{"sourcename":"openaddresses","attribution":"© OpenAddresses contributors","license":"BSD-3-Clause License"},"state":"Oklahoma","city":"Muskogee","state_code":"OK","lon":-95.341291,"lat":35.727213,"result_type":"building","formatted":"2306 Nebraska Street, Muskogee, OK, United States of America","address_line1":"2306 Nebraska Street","address_line2":"Muskogee, OK, United States of America","timezone":{"name":"America/Chicago","offset_STD":"-06:00","offset_STD_seconds":-21600,"offset_DST":"-05:00","offset_DST_seconds":-18000,"abbreviation_STD":"CST","abbreviation_DST":"CDT"},"plus_code":"8676PMG5+VF","plus_code_short":"PMG5+VF Muskogee, Muskogee County, United States","rank":{"confidence":1,"match_type":"full_match"},"place_id":"51d3da34b6d7d557c059ef1cca5015dd4140c00203e203506f70656e6164647265737365733a616464726573733a75732f6f6b2f636974795f6f665f6d75736b6f6765652d6164647265737365732d636974792e6373763a38386366653831623831643463333166"}]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapGeoapifyHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '2306 Nebraska');
        Assert.areEqual(3, places.size(), '3 records must be returned');

        Assert.areEqual('2306 Nebraska Avenue, Fort Pierce, FL 34950, United States of America', places[0].display_name, 'display name must match the format');
        Assert.areEqual(27.433646, places[0].location.latitude, 'latitude must match');
        Assert.areEqual(-80.347555, places[0].location.longitude, 'longitude must match');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'autocomplete',
            500,
            ''
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapGeoapifyHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '2306 Nebraska');
        Assert.areEqual(0, places.size(), '0 records must be returned');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesEmptyQuery() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addNotToRequest(
            'GET',
            'autocomplete'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapGeoapifyHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '');
        Assert.areEqual(0, places.size(), '0 records must be returned');

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
    public static void testGetDistances() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            'routematrix',
            200,
            '{"sources_to_targets":[[{"distance":64090,"time":2374,"source_index":0,"target_index":0},{"distance":3995887,"time":128265,"source_index":0,"target_index":1}]]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        List<MapApi.LocationDistance> distances = getMapHelper().getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(64090.0, distances[0].distance, 'distance must match');
        Assert.areEqual(2374.0, distances[0].duration, 'duration must match');

        Assert.areEqual(3995887.0, distances[1].distance, 'distance must match');
        Assert.areEqual(128265.0, distances[1].duration, 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDistancesTargetIndexMismatch() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            'routematrix',
            200,
            '{"sources_to_targets":[[{"distance":3995887,"time":128265,"source_index":0,"target_index":1},{"distance":64090,"time":2374,"source_index":0,"target_index":0}]]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        List<MapApi.LocationDistance> distances = getMapHelper().getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(null, distances, 'distances must be null');

        Test.stopTest();
    }

    @isTest
    public static void testGetDistancesError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            'routematrix',
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
            'routing',
            200,
            '{"features":[{"type":"Feature","properties":{"mode":"drive","waypoints":[{"location":[-112.132558,33.636503],"original_index":0},{"location":[-111.986253,33.320876],"original_index":1}],"units":"metric","traffic":"approximated","distance":49861,"distance_units":"meters","time":5505.384,"legs":[{"distance":49861,"time":5505.384,"steps":[{"from_index":0,"to_index":21,"distance":339,"time":91.135,"instruction":{"text":"Drive north on North 34th Avenue."}},{"from_index":21,"to_index":26,"distance":138,"time":48.174,"instruction":{"text":"Turn left onto North 33rd Drive."}},{"from_index":26,"to_index":51,"distance":1060,"time":182.035,"instruction":{"text":"Turn right onto West Bell Road."}},{"from_index":51,"to_index":65,"distance":193,"time":28.37,"instruction":{"text":"Continue on North Black Canyon Highway."}},{"from_index":65,"to_index":235,"distance":19219,"time":2173.664,"instruction":{"text":"Take the I 17 South ramp on the left toward Tucson."}},{"from_index":235,"to_index":506,"distance":18950,"time":1875.581,"instruction":{"text":"Keep left to take US 60."}},{"from_index":506,"to_index":576,"distance":7923,"time":706.941,"instruction":{"text":"Keep left to take I 10/Maricopa Freeway."}},{"from_index":576,"to_index":593,"distance":750,"time":74.442,"instruction":{"text":"Take exit 159 toward Ray Road."}},{"from_index":593,"to_index":632,"distance":1183,"time":232.401,"instruction":{"text":"Turn right onto East Ray Road."}},{"from_index":632,"to_index":634,"distance":67,"time":62.457,"instruction":{"text":"Turn right."}},{"from_index":634,"to_index":647,"distance":37,"time":30.178,"instruction":{"text":"Enter the roundabout and take the 2nd exit."}},{"from_index":647,"to_index":647,"distance":0,"time":0,"instruction":{"text":"Your destination is on the right."}}]}]},"geometry":{"type":"MultiLineString","coordinates":[[[-112.132335,33.636544],[-112.132342,33.63657],[-112.132363,33.636739],[-112.13236,33.636821],[-112.132356,33.636906],[-112.13234,33.637026],[-112.132308,33.63716],[-112.132263,33.637286],[-112.132189,33.637445],[-112.132099,33.637593],[-112.132003,33.637713],[-112.131895,33.637829],[-112.13174,33.637966],[-112.131565,33.638079],[-112.131466,33.638136],[-112.131319,33.638201],[-112.131155,33.638265],[-112.13099,33.638314],[-112.130797,33.638351],[-112.130566,33.638372],[-112.130196,33.638367],[-112.130069,33.638359],[-112.130053,33.638458],[-112.130004,33.638781],[-112.129976,33.639124],[-112.129975,33.639517],[-112.129975,33.639592],[-112.129879,33.639594],[-112.129545,33.639601],[-112.12874,33.639619],[-112.128138,33.639633],[-112.127489,33.639647],[-112.127039,33.639656],[-112.125829,33.639668],[-112.12533,33.639674],[-112.124982,33.639677],[-112.124603,33.639685],[-112.124075,33.639697],[-112.123597,33.639708],[-112.123018,33.639711],[-112.122492,33.639714],[-112.122157,33.639716],[-112.121602,33.63972],[-112.121504,33.639722],[-112.121358,33.639727],[-112.121252,33.639731],[-112.120781,33.63974],[-112.120604,33.639743],[-112.119978,33.639757],[-112.119487,33.639766],[-112.119242,33.63977],[-112.118539,33.639777],[-112.118238,33.639781],[-112.11799,33.63971],[-112.117687,33.639711],[-112.117586,33.639704],[-112.117524,33.639685],[-112.117475,33.639661],[-112.117434,33.639624],[-112.117399,33.639591],[-112.117372,33.63955],[-112.117341,33.639493],[-112.117319,33.639447],[-112.117235,33.639339],[-112.117114,33.639111],[-112.117025,33.638928],[-112.116887,33.638772],[-112.116672,33.638449],[-112.11657,33.638268],[-112.116498,33.638128],[-112.116406,33.637918],[-112.11635,33.637767],[-112.116318,33.637685],[-112.116293,33.6376],[-112.116218,33.637335],[-112.116168,33.637063],[-112.116133,33.636836],[-112.116123,33.636519],[-112.116058,33.636376],[-112.116187,33.634702],[-112.11628,33.633517],[-112.116325,33.632948],[-112.116343,33.632729],[-112.116376,33.632359],[-112.11649,33.630853],[-112.116602,33.629235],[-112.116693,33.627078],[-112.116717,33.62552],[-112.116726,33.62507],[-112.116745,33.620681],[-112.116753,33.6195],[-112.116783,33.616075],[-112.116785,33.61567],[-112.116816,33.611044],[-112.116817,33.610618],[-112.116841,33.60902],[-112.116859,33.607783],[-112.116871,33.607031],[-112.116873,33.60698],[-112.116889,33.605595],[-112.116913,33.603629],[-112.116916,33.603249],[-112.116931,33.601639],[-112.116949,33.600529],[-112.116955,33.600063],[-112.116955,33.599519],[-112.116959,33.599251],[-112.116998,33.596684],[-112.117003,33.596156],[-112.117036,33.592485],[-112.117049,33.591434],[-112.117056,33.5911],[-112.117077,33.588192],[-112.117072,33.58781],[-112.117083,33.58664],[-112.117084,33.585915],[-112.117094,33.585429],[-112.117102,33.583782],[-112.11711,33.582208],[-112.117112,33.581758],[-112.117119,33.580619],[-112.117126,33.57956],[-112.11714,33.578138],[-112.117139,33.578013],[-112.117137,33.577776],[-112.117145,33.577483],[-112.117146,33.577319],[-112.117167,33.575793],[-112.117184,33.575098],[-112.117193,33.574762],[-112.117207,33.57414],[-112.117239,33.573297],[-112.117311,33.571776],[-112.117345,33.571047],[-112.117377,33.570443],[-112.11743,33.569492],[-112.117467,33.568831],[-112.117445,33.568244],[-112.117442,33.567815],[-112.117403,33.567222],[-112.117359,33.566792],[-112.117286,33.566332],[-112.117221,33.565998],[-112.117162,33.56568],[-112.117099,33.565436],[-112.116998,33.565002],[-112.116909,33.564696],[-112.11681,33.564364],[-112.1167,33.564037],[-112.116594,33.563772],[-112.116456,33.5634],[-112.116338,33.563083],[-112.116114,33.562581],[-112.115857,33.562094],[-112.115361,33.561223],[-112.114462,33.559765],[-112.113583,33.558286],[-112.113362,33.557938],[-112.112991,33.557022],[-112.112791,33.556353],[-112.11264,33.55566],[-112.112576,33.55513],[-112.112539,33.554568],[-112.112506,33.553614],[-112.112501,33.550599],[-112.112505,33.550191],[-112.112503,33.549851],[-112.112514,33.549528],[-112.112505,33.548107],[-112.112499,33.546985],[-112.112489,33.54586],[-112.112487,33.54502],[-112.112472,33.54382],[-112.112475,33.542271],[-112.112465,33.541394],[-112.112464,33.540971],[-112.112454,33.538258],[-112.112482,33.535327],[-112.112449,33.528475],[-112.112445,33.527592],[-112.112414,33.527064],[-112.112411,33.526786],[-112.112406,33.526385],[-112.112399,33.52556],[-112.112389,33.524446],[-112.11239,33.524309],[-112.112414,33.521283],[-112.112419,33.520667],[-112.112421,33.520331],[-112.112487,33.513666],[-112.112462,33.51315],[-112.112465,33.512968],[-112.112468,33.512753],[-112.112473,33.512461],[-112.11248,33.512008],[-112.112488,33.511534],[-112.112502,33.509754],[-112.112724,33.505995],[-112.1128,33.50476],[-112.112984,33.501596],[-112.113058,33.499284],[-112.113061,33.498623],[-112.113058,33.498072],[-112.113074,33.497612],[-112.113078,33.497298],[-112.113086,33.49681],[-112.113131,33.493832],[-112.113136,33.49351],[-112.113141,33.493068],[-112.113146,33.492626],[-112.113154,33.491688],[-112.113156,33.49126],[-112.113164,33.490162],[-112.113165,33.490038],[-112.113168,33.488839],[-112.113201,33.485076],[-112.113204,33.483914],[-112.113207,33.48248],[-112.113209,33.481902],[-112.113214,33.4796],[-112.113232,33.478605],[-112.113256,33.47809],[-112.113259,33.477638],[-112.113262,33.477404],[-112.113255,33.475676],[-112.113247,33.475289],[-112.113208,33.474872],[-112.113146,33.474169],[-112.113098,33.473814],[-112.112995,33.473297],[-112.112845,33.472646],[-112.112677,33.472028],[-112.112459,33.471391],[-112.111705,33.469718],[-112.111618,33.469524],[-112.110757,33.467561],[-112.11048,33.467007],[-112.110195,33.466362],[-112.110067,33.466097],[-112.10985,33.465656],[-112.109576,33.465053],[-112.109331,33.464526],[-112.109122,33.464009],[-112.108961,33.46359],[-112.108819,33.463163],[-112.10875,33.462956],[-112.108642,33.462626],[-112.108499,33.462129],[-112.108419,33.461794],[-112.108349,33.461418],[-112.10829,33.460847],[-112.108236,33.460354],[-112.108184,33.459703],[-112.108186,33.458932],[-112.108187,33.458648],[-112.108197,33.458113],[-112.108209,33.455527],[-112.108212,33.454803],[-112.108234,33.454409],[-112.108271,33.454121],[-112.108277,33.453583],[-112.108277,33.453456],[-112.108297,33.451613],[-112.108298,33.451347],[-112.108302,33.45106],[-112.108308,33.450569],[-112.108322,33.45012],[-112.108311,33.449489],[-112.108309,33.448839],[-112.108308,33.448608],[-112.108308,33.448492],[-112.108301,33.446668],[-112.108292,33.444303],[-112.108291,33.444015],[-112.108291,33.443833],[-112.108287,33.442639],[-112.108286,33.442057],[-112.108285,33.441976],[-112.108283,33.440995],[-112.108263,33.437625],[-112.108262,33.437318],[-112.108264,33.435835],[-112.108265,33.435647],[-112.108265,33.435328],[-112.108281,33.434878],[-112.108286,33.43451],[-112.108284,33.434342],[-112.108281,33.434074],[-112.108288,33.433779],[-112.10829,33.433529],[-112.108279,33.433145],[-112.108209,33.432557],[-112.108082,33.4321],[-112.107815,33.431519],[-112.107636,33.431226],[-112.107421,33.430911],[-112.107146,33.43056],[-112.106769,33.430195],[-112.106451,33.429923],[-112.106022,33.429629],[-112.105567,33.429371],[-112.105095,33.429156],[-112.104589,33.428963],[-112.104134,33.428834],[-112.103862,33.428774],[-112.103542,33.428712],[-112.103035,33.428648],[-112.102655,33.428634],[-112.102193,33.428643],[-112.100138,33.428763],[-112.099658,33.428799],[-112.099494,33.428812],[-112.094756,33.429185],[-112.093744,33.429282],[-112.091446,33.429507],[-112.090937,33.429558],[-112.089691,33.429617],[-112.089495,33.429626],[-112.089155,33.429642],[-112.088626,33.429645],[-112.087982,33.429648],[-112.087053,33.429623],[-112.086558,33.429589],[-112.085567,33.429502],[-112.082699,33.429247],[-112.082516,33.42923],[-112.082167,33.429198],[-112.082082,33.42919],[-112.081093,33.429098],[-112.080489,33.429041],[-112.0798,33.428977],[-112.078557,33.428871],[-112.078124,33.428833],[-112.07696,33.428725],[-112.075758,33.428613],[-112.074069,33.428457],[-112.073462,33.4284],[-112.072792,33.42834],[-112.070851,33.428184],[-112.070108,33.428184],[-112.069675,33.428192],[-112.06906,33.428226],[-112.068656,33.428261],[-112.067757,33.428381],[-112.065964,33.428736],[-112.06551,33.428809],[-112.064831,33.428889],[-112.064465,33.428926],[-112.063981,33.428961],[-112.063421,33.428979],[-112.062489,33.42897],[-112.061684,33.428904],[-112.061357,33.428863],[-112.061145,33.428837],[-112.060916,33.428807],[-112.058832,33.428496],[-112.056658,33.428172],[-112.052867,33.427609],[-112.052269,33.427528],[-112.051434,33.427416],[-112.050356,33.427311],[-112.049273,33.427248],[-112.048458,33.427238],[-112.048087,33.427237],[-112.047507,33.42724],[-112.042839,33.427265],[-112.041985,33.427272],[-112.04093,33.427265],[-112.03972,33.427208],[-112.038549,33.427101],[-112.037198,33.426947],[-112.035657,33.426777],[-112.035084,33.426728],[-112.034516,33.426706],[-112.03367,33.426713],[-112.033344,33.426716],[-112.03289,33.426704],[-112.032606,33.426697],[-112.0314,33.426649],[-112.030849,33.426564],[-112.030015,33.426452],[-112.029493,33.426357],[-112.028982,33.426236],[-112.028641,33.426165],[-112.028302,33.426073],[-112.027636,33.425855],[-112.027053,33.425651],[-112.026528,33.425456],[-112.026136,33.425286],[-112.025835,33.425128],[-112.025302,33.424827],[-112.023728,33.423939],[-112.022865,33.423402],[-112.022177,33.422859],[-112.022054,33.422762],[-112.021008,33.421893],[-112.020505,33.42139],[-112.020348,33.421238],[-112.01962,33.420379],[-112.017432,33.417789],[-112.016098,33.416211],[-112.015108,33.415054],[-112.01484,33.414809],[-112.014153,33.414108],[-112.01395,33.413945],[-112.013394,33.413496],[-112.012904,33.413143],[-112.012449,33.412815],[-112.011436,33.412249],[-112.009987,33.411605],[-112.009162,33.411332],[-112.008184,33.411074],[-112.007257,33.410888],[-112.006494,33.410802],[-112.005765,33.410742],[-112.005129,33.410707],[-112.003861,33.410705],[-112.00349,33.410705],[-112.001567,33.410731],[-112.001335,33.410732],[-111.99466,33.410757],[-111.990849,33.410771],[-111.990197,33.410762],[-111.98795,33.41078],[-111.985692,33.410798],[-111.984732,33.410808],[-111.980002,33.410815],[-111.979746,33.410812],[-111.979477,33.410807],[-111.979214,33.410796],[-111.978947,33.410781],[-111.978693,33.410761],[-111.97841,33.410735],[-111.978061,33.410695],[-111.97778,33.410656],[-111.977528,33.410615],[-111.977269,33.41057],[-111.977012,33.41052],[-111.976764,33.410467],[-111.976501,33.410406],[-111.976257,33.410346],[-111.97601,33.410279],[-111.975763,33.410205],[-111.975505,33.410127],[-111.975263,33.410047],[-111.975026,33.409964],[-111.974794,33.409878],[-111.974553,33.409782],[-111.97432,33.409685],[-111.974083,33.409579],[-111.973857,33.409474],[-111.973631,33.409368],[-111.973408,33.409254],[-111.973186,33.409133],[-111.972969,33.409013],[-111.972752,33.408887],[-111.972522,33.408747],[-111.972254,33.40857],[-111.972028,33.408418],[-111.971833,33.408279],[-111.971739,33.408208],[-111.97163,33.408128],[-111.971435,33.407975],[-111.971255,33.407827],[-111.971071,33.407672],[-111.971014,33.40762],[-111.970893,33.407506],[-111.970716,33.407331],[-111.970549,33.407168],[-111.970378,33.406997],[-111.97022,33.406831],[-111.970065,33.406662],[-111.969909,33.406484],[-111.969762,33.406306],[-111.969613,33.406118],[-111.969473,33.405938],[-111.969337,33.405748],[-111.969207,33.40556],[-111.969079,33.405369],[-111.968952,33.405168],[-111.968841,33.404976],[-111.968731,33.404782],[-111.968623,33.404578],[-111.968519,33.404376],[-111.968426,33.40418],[-111.968334,33.403971],[-111.968246,33.403762],[-111.968165,33.403554],[-111.968092,33.403346],[-111.96802,33.40313],[-111.967953,33.402919],[-111.967897,33.402708],[-111.967843,33.402493],[-111.967795,33.402278],[-111.967753,33.40206],[-111.967717,33.401843],[-111.967682,33.401626],[-111.967655,33.401406],[-111.967634,33.401188],[-111.96762,33.400966],[-111.967609,33.400747],[-111.967605,33.400528],[-111.967606,33.400308],[-111.96761,33.400089],[-111.967615,33.399865],[-111.967676,33.397991],[-111.967681,33.397497],[-111.967689,33.396665],[-111.967707,33.395915],[-111.967742,33.395122],[-111.967785,33.394279],[-111.967822,33.393166],[-111.967842,33.3925],[-111.967843,33.392281],[-111.967866,33.390104],[-111.96787,33.388888],[-111.967874,33.387704],[-111.967956,33.385315],[-111.967974,33.384248],[-111.967978,33.383401],[-111.967996,33.382933],[-111.96808,33.380322],[-111.968131,33.378451],[-111.968135,33.378048],[-111.968127,33.375303],[-111.968131,33.37464],[-111.968141,33.37321],[-111.968146,33.372502],[-111.968167,33.37166],[-111.968201,33.370265],[-111.968561,33.366229],[-111.968607,33.365924],[-111.968937,33.363784],[-111.969051,33.363135],[-111.969173,33.36248],[-111.969375,33.361512],[-111.969521,33.360866],[-111.969845,33.359577],[-111.97007,33.358717],[-111.970279,33.357922],[-111.970499,33.357113],[-111.97073,33.356232],[-111.970934,33.355419],[-111.971115,33.354627],[-111.971247,33.353977],[-111.971341,33.353572],[-111.971394,33.353251],[-111.971489,33.352809],[-111.971649,33.351895],[-111.971997,33.349498],[-111.97209,33.348737],[-111.972202,33.347527],[-111.972236,33.347124],[-111.972268,33.346736],[-111.972286,33.346451],[-111.972307,33.346081],[-111.972329,33.345702],[-111.972351,33.345199],[-111.972374,33.344669],[-111.972398,33.342975],[-111.972367,33.340447],[-111.972385,33.339347],[-111.972382,33.338405],[-111.972373,33.337798],[-111.972379,33.33726],[-111.972376,33.336669],[-111.972364,33.33626],[-111.972363,33.33526],[-111.972361,33.334512],[-111.972361,33.334235],[-111.972361,33.333688],[-111.972364,33.332863],[-111.972364,33.332109],[-111.972377,33.331035],[-111.972369,33.329896],[-111.972376,33.32895],[-111.972357,33.326607],[-111.972424,33.326431],[-111.972476,33.326299],[-111.972479,33.325662],[-111.972518,33.325031],[-111.972549,33.324432],[-111.972642,33.3237],[-111.972784,33.323169],[-111.972977,33.322665],[-111.9732,33.322125],[-111.97337,33.321804],[-111.973444,33.321592],[-111.973495,33.321209],[-111.973513,33.320748],[-111.973519,33.320374],[-111.973517,33.320267],[-111.973521,33.320107],[-111.973519,33.319995],[-111.97369,33.319991],[-111.974232,33.319982],[-111.97467,33.31997],[-111.974888,33.319961],[-111.975114,33.319957],[-111.975358,33.319953],[-111.976016,33.319954],[-111.976149,33.319955],[-111.9763,33.319954],[-111.976652,33.319954],[-111.976836,33.319953],[-111.977036,33.319952],[-111.977649,33.31995],[-111.97812,33.319948],[-111.978295,33.319947],[-111.978976,33.319938],[-111.979265,33.319934],[-111.979284,33.319933],[-111.979357,33.319932],[-111.980243,33.319919],[-111.980457,33.319915],[-111.980653,33.319913],[-111.981102,33.319909],[-111.981928,33.319904],[-111.981995,33.319904],[-111.982067,33.319903],[-111.982521,33.319901],[-111.983423,33.319894],[-111.983635,33.319893],[-111.983731,33.319891],[-111.984137,33.319885],[-111.984256,33.319883],[-111.984385,33.319883],[-111.984964,33.319883],[-111.985619,33.319883],[-111.985726,33.319887],[-111.985872,33.319892],[-111.986068,33.319905],[-111.986203,33.319918],[-111.986205,33.320283],[-111.986207,33.320512],[-111.986178,33.320515],[-111.986151,33.320522],[-111.986126,33.320536],[-111.986106,33.320553],[-111.986092,33.320574],[-111.986083,33.320597],[-111.986082,33.320622],[-111.98609,33.320652],[-111.986109,33.320678],[-111.986136,33.320699],[-111.98617,33.320712],[-111.986206,33.320716],[-111.986222,33.320714]]]}}],"properties":{"mode":"drive","waypoints":[{"lon":-112.13255847,"lat":33.63650345},{"lon":-111.986253,"lat":33.320876}],"units":"metric","traffic":"approximated"},"type":"FeatureCollection"}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3208760, -111.9862530);
        MapApi.Direction direction = getMapHelper().getDirection(MapApi.Mode.DRIVE, source, destination);

        Assert.areEqual(1, direction.routes.size(), 'must return 1 route');
        Assert.areEqual(49861.0, direction.routes[0].distance, 'distance must match');
        Assert.areEqual(5505.384, direction.routes[0].duration, 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDirectionError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'routing',
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

    @isTest
    public static void testGetMode() {
        Test.startTest();

        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.DRIVE), 'drive', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.TRANSIT), 'transit', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.MOTORBIKE), 'motorcycle', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.BICYCLE), 'bicycle', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.WALK), 'walk', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(null), 'drive', 'mode must match');

        Test.stopTest();
    }
}