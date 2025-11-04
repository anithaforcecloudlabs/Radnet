/**
* @description    : Test class for MapLocationIQHelper
*
* Created Date    : 15/05/2024
*
* @JIRA Id        : CC-232, CC-233
**/
@isTest
public with sharing class MapLocationIQHelperTest {

    static String SESSION_ID = '9021c8e0-2dbc-4d38-a5c0-b048a79d89a3';

    static MapLocationIQHelper getMapHelper() {
        return new MapLocationIQHelper('test-api-key');
    }

    // searchPlaces related tests
    @isTest
    static void testSearchResultDisplayNameAndID() {
        Test.startTest();

        List<String> searchResults = new List<String>{
            '{"place_id":"370886050","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"28522893","boundingbox":["38.608248166554","38.608348166554","-90.229275314228","-90.229175314228"],"lat":"38.6082761","lon":"-90.229385","display_name":"2306, Nebraska Avenue, Fox Park, St. Louis, Missouri, 63104, USA","class":"place","type":"house","importance":0}',
            '{"place_id":"370886050","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"28522893","boundingbox":["38.608248166554","38.608348166554","-90.229275314228","-90.229175314228"],"lat":"38.6082761","lon":"-90.229385","display_name":"2306, Nebraska Avenue, Fox Park, St. Louis, Missouri, 63104, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","neighbourhood":"Fox Park","city":"St. Louis","state":"Missouri","postcode":"63104","country":"United States of America","country_code":"us"}}',
            '{"place_id":"361825323","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"205702389","boundingbox":["41.645522857143","41.645622857143","-83.599302571429","-83.599202571429"],"lat":"41.64557285714286","lon":"-83.59925257142858","display_name":"2306, Nebraska Avenue, Scott Park, Freemans Gardens, Toledo, Lucas County, Ohio, 43607, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","neighbourhood":"Scott Park","hamlet":"Freemans Gardens","city":"Toledo","county":"Lucas County","state":"Ohio","postcode":"43607","country":"United States of America","country_code":"us"}}',
            '{"place_id":"370629947","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"477416596","boundingbox":["40.865204809524","40.865304809524","-74.088646666667","-74.088546666667"],"lat":"40.8645947","lon":"-74.0891309","display_name":"296, Grove Street, Lodi, Bergen County, New Jersey, 07644, USA","class":"place","type":"house","importance":0,"address":{"house_number":"296","road":"Grove Street","town":"Lodi","county":"Bergen County","state":"New Jersey","postcode":"07644","country":"United States of America","country_code":"us"}}',
            '{"place_id":"370629947","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"477416596","boundingbox":["40.865204809524","40.865304809524","-74.088646666667","-74.088546666667"],"lat":"40.8645947","lon":"-74.0891309","display_name":"296, Grove Street, Lodi, Bergen County, New Jersey, 07644, USA","class":"place","type":"house","importance":0,"address":{"house_number":"296","road":"Grove Street","village":"Lodi","county":"Bergen County","state":"New Jersey","postcode":"07644","country":"United States of America","country_code":"us"}}'
        };
        List<String> expectedDisplayNames = new List<String>{
            '2306, Nebraska Avenue, Fox Park, St. Louis, Missouri, 63104, USA',
            '2306, Nebraska Avenue, St. Louis, Missouri, 63104',
            '2306, Nebraska Avenue, Toledo, Lucas County, Ohio, 43607',
            '296, Grove Street, Lodi, Bergen County, New Jersey, 07644',
            '296, Grove Street, Lodi, Bergen County, New Jersey, 07644'
        };
        List<String> expectedIDs = new List<String>{
            'LOCATIONIQ_370886050',
            'LOCATIONIQ_370886050',
            'LOCATIONIQ_361825323',
            'LOCATIONIQ_370629947',
            'LOCATIONIQ_370629947'
        };
        for (Integer index = 0; index < searchResults.size(); index++) {
            MapLocationIQHelper.SearchResult sr = (MapLocationIQHelper.SearchResult) JSON.deserialize(searchResults[index], MapLocationIQHelper.SearchResult.class);
            Assert.areEqual(expectedDisplayNames[index], sr.getDisplayName(), 'display name must match');
            Assert.areEqual(expectedIDs[index], sr.getID(), 'id must match');
        }

        Test.stopTest();
    }

    @isTest
    static void testGetPlacesFromSearchSuccess() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'search',
            200,
            '[{"place_id":"370886050","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"28522893","boundingbox":["38.608248166554","38.608348166554","-90.229275314228","-90.229175314228"],"lat":"38.6082761","lon":"-90.229385","display_name":"2306, Nebraska Avenue, Fox Park, St. Louis, Missouri, 63104, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","neighbourhood":"Fox Park","city":"St. Louis","state":"Missouri","postcode":"63104","country":"United States of America","country_code":"us"}},{"place_id":"361825323","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"205702389","boundingbox":["41.645522857143","41.645622857143","-83.599302571429","-83.599202571429"],"lat":"41.64557285714286","lon":"-83.59925257142858","display_name":"2306, Nebraska Avenue, Scott Park, Freemans Gardens, Toledo, Lucas County, Ohio, 43607, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","neighbourhood":"Scott Park","hamlet":"Freemans Gardens","city":"Toledo","county":"Lucas County","state":"Ohio","postcode":"43607","country":"United States of America","country_code":"us"}},{"place_id":"359537718","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"13414892","boundingbox":["39.117559323232","39.117659323232","-94.654972565657","-94.654872565657"],"lat":"39.11760932323232","lon":"-94.65492256565656","display_name":"2306, Nebraska Avenue, Westheight Manor, Westheight, Kansas City, Wyandotte County, Kansas, 66102, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","residential":"Westheight Manor","suburb":"Westheight","city":"Kansas City","county":"Wyandotte County","state":"Kansas","postcode":"66102","country":"United States of America","country_code":"us"}},{"place_id":"372798890","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"8660817","boundingbox":["43.027182949495","43.027282949495","-83.660481656566","-83.660381656566"],"lat":"43.02723294949495","lon":"-83.66043165656565","display_name":"2306, Nebraska Avenue, Flint, Genesee County, Michigan, 48506, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","city":"Flint","county":"Genesee County","state":"Michigan","postcode":"48506","country":"United States of America","country_code":"us"}},{"place_id":"367019384","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"18221168","boundingbox":["44.986043953338","44.986143953338","-93.002706523745","-93.002606523745"],"lat":"44.98609395333807","lon":"-93.00265652374513","display_name":"2306, Nebraska Avenue, Maplewood, Ramsey County, Minnesota, 55119, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","town":"Maplewood","county":"Ramsey County","state":"Minnesota","postcode":"55119","country":"United States of America","country_code":"us"}}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.getPlacesFromGeocodeOrSearch('2306 Nebraska Avenue', true);
        Assert.areEqual(5, places.size(), '5 records must be returned');

        Assert.areEqual('2306, Nebraska Avenue, St. Louis, Missouri, 63104', places[0].display_name, 'display name must match the format');
        Assert.areEqual(38.6082761, places[0].location.latitude, 'latitude must match');
        Assert.areEqual(-90.229385, places[0].location.longitude, 'longitude must match');

        Test.stopTest();
    }

    @isTest
    static void testGetPlacesFromSearchError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'search',
            500,
            ''
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.getPlacesFromGeocodeOrSearch('2306 Nebraska Avenue', true);
        Assert.areEqual(0, places.size(), '0 records must be returned');

        Test.stopTest();
    }

    @isTest
    static void testGetPlacesFromAutocompleteSuccess() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'autocomplete',
            200,
            '[{"place_id":"322743601779","osm_id":"712585375","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"40.6989871","lon":"-99.11044498","boundingbox":["40.6927089","40.7046315","-99.1136854","-99.0939418"],"class":"amenity","type":"university","display_name":"University of Nebraska at Kearney, 2504, 9th Avenue, Kearney, Buffalo County, Nebraska, 68845, USA","display_place":"University of Nebraska at Kearney","display_address":"2504, 9th Avenue, Kearney, Buffalo County, Nebraska, 68845, USA","address":{"name":"University of Nebraska at Kearney","house_number":"2504","road":"9th Avenue","city":"Kearney","county":"Buffalo County","state":"Nebraska","postcode":"68845","country":"United States of America","country_code":"us"}},{"place_id":"320570785875","osm_id":"702097370","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"40.83827205","lon":"-96.64793042","boundingbox":["40.8373096","40.8402179","-96.6516701","-96.64419"],"class":"amenity","type":"university","display_name":"Nebraska Wesleyan University, 5000, Saint Paul Avenue, University Place, Lincoln, Lancaster County, Nebraska, 68504, USA","display_place":"Nebraska Wesleyan University","display_address":"5000, Saint Paul Avenue, University Place, Lincoln, Lancaster County, Nebraska, 68504, USA","address":{"name":"Nebraska Wesleyan University","house_number":"5000","road":"Saint Paul Avenue","suburb":"University Place","city":"Lincoln","county":"Lancaster County","state":"Nebraska","postcode":"68504","country":"United States of America","country_code":"us"}},{"place_id":"323615419714","osm_id":"14077465","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"41.4667501","lon":"-96.499368","boundingbox":["41.4659367","41.4677417","-96.4993706","-96.4993658"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Fremont, Dodge County, Nebraska, 68025, USA","display_place":"Nebraska Avenue","display_address":"Fremont, Dodge County, Nebraska, 68025, USA","address":{"name":"Nebraska Avenue","city":"Fremont","county":"Dodge County","state":"Nebraska","postcode":"68025","country":"United States of America","country_code":"us"}},{"place_id":"324281969032","osm_id":"14164514","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"40.341811","lon":"-95.683305","boundingbox":["40.340844","40.341846","-95.685875","-95.680994"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Nemaha County, Nebraska, 68414, USA","display_place":"Nebraska Avenue","display_address":"Nemaha County, Nebraska, 68414, USA","address":{"name":"Nebraska Avenue","county":"Nemaha County","state":"Nebraska","postcode":"68414","country":"United States of America","country_code":"us"}},{"place_id":"322993570811","osm_id":"784969104","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"40.3065014","lon":"-99.8977874","boundingbox":["40.3062956","40.3066266","-99.8977874","-99.8977212"],"class":"highway","type":"primary","display_name":"Nebraska Avenue, Arapahoe, Furnas County, Nebraska, 68922, USA","display_place":"Nebraska Avenue","display_address":"Arapahoe, Furnas County, Nebraska, 68922, USA","address":{"name":"Nebraska Avenue","city":"Arapahoe","county":"Furnas County","state":"Nebraska","postcode":"68922","country":"United States of America","country_code":"us"}}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.getPlacesFromGeocodeOrSearch('2306 Nebraska Avenue', false);
        Assert.areEqual(5, places.size(), '5 records must be returned');

        Assert.areEqual('University of Nebraska at Kearney, 2504, 9th Avenue, Kearney, Buffalo County, Nebraska, 68845', places[0].display_name, 'display name must match the format');
        Assert.areEqual(40.6989871, places[0].location.latitude, 'latitude must match');
        Assert.areEqual(-99.11044498, places[0].location.longitude, 'longitude must match');

        Test.stopTest();
    }

    @isTest
    static void testGetPlacesFromAutocompleteError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'autocomplete',
            500,
            ''
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.getPlacesFromGeocodeOrSearch('2306 Nebraska Avenue', false);
        Assert.areEqual(0, places.size(), '0 records must be returned');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesDifferentResultsFromSubApis() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'search',
            200,
            '[{"place_id":"369662067","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"11300186","boundingbox":["27.433295978484","27.433395978484","-80.347576876947","-80.347476876947"],"lat":"27.4337002","lon":"-80.3476924","display_name":"2306, Nebraska Avenue, Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","hamlet":"Glidden Park","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34950","country":"United States of America","country_code":"us"}}]'
        );
        mock.addResponse(
            'GET',
            'autocomplete',
            200,
            '[{"place_id":"323591160054","osm_id":"11300187","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"27.4337015","lon":"-80.3575209","boundingbox":["27.4337015","27.4337015","-80.3575209","-80.3575209"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34947, USA","display_place":"Nebraska Avenue","display_address":"Fort Pierce, Saint Lucie County, Florida, 34947, USA","address":{"name":"Nebraska Avenue","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34947","country":"United States of America","country_code":"us"}},{"place_id":"322215174196","osm_id":"13538640","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"31.048545","lon":"-93.208152","boundingbox":["31.048469","31.04864","-93.208377","-93.207498"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Fort Polk, Fort Polk South, Vernon Parish, Louisiana, 71459, USA","display_place":"Nebraska Avenue","display_address":"Fort Polk, Fort Polk South, Vernon Parish, Louisiana, 71459, USA","address":{"name":"Nebraska Avenue","suburb":"Fort Polk","city":"Fort Polk South","county":"Vernon Parish","state":"Louisiana","postcode":"71459","country":"United States of America","country_code":"us"}},{"place_id":"320459502871","osm_id":"13065809","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"37.732767","lon":"-100.036261","boundingbox":["37.73275","37.732767","-100.036623","-100.034396"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Dodge City, Ford County, Kansas, 67801, USA","display_place":"Nebraska Avenue","display_address":"Dodge City, Ford County, Kansas, 67801, USA","address":{"name":"Nebraska Avenue","city":"Dodge City","county":"Ford County","state":"Kansas","postcode":"67801","country":"United States of America","country_code":"us"}},{"place_id":"321166013414","osm_id":"11300188","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"27.4332924","lon":"-80.3343063","boundingbox":["27.4332514","27.4332924","-80.3343063","-80.3329518"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","display_place":"Nebraska Avenue","display_address":"Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","address":{"name":"Nebraska Avenue","suburb":"Glidden Park","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34950","country":"United States of America","country_code":"us"}},{"place_id":"321166013414","osm_id":"11300186","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"27.4338398","lon":"-80.3439919","boundingbox":["27.4321861","27.434113","-80.3501509","-80.337114"],"class":"highway","type":"tertiary","display_name":"Nebraska Avenue, Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","display_place":"Nebraska Avenue","display_address":"Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","address":{"name":"Nebraska Avenue","suburb":"Glidden Park","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34950","country":"United States of America","country_code":"us"}}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '2306 Nebraska Avenue Fort');
        Assert.areEqual(5, places.size(), '5 records must be returned');

        Assert.areEqual('2306, Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34950', places[0].display_name, 'display name must match the format');
        Assert.areEqual(27.4337002, places[0].location.latitude, 'latitude must match');
        Assert.areEqual(-80.3476924, places[0].location.longitude, 'longitude must match');

        Assert.areEqual('Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34947', places[1].display_name, 'display name must match the format');
        Assert.areEqual(27.4337015, places[1].location.latitude, 'latitude must match');
        Assert.areEqual(-80.3575209, places[1].location.longitude, 'longitude must match');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesRepeatedResultsFromSubApis() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'search',
            200,
            '[{"place_id":"369662067","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"11300186","boundingbox":["27.433295978484","27.433395978484","-80.347576876947","-80.347476876947"],"lat":"27.4337002","lon":"-80.3476924","display_name":"2306, Nebraska Avenue, Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","hamlet":"Glidden Park","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34950","country":"United States of America","country_code":"us"}}]'
        );
        mock.addResponse(
            'GET',
            'autocomplete',
            200,
            '[{"place_id":"369662067","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"11300186","boundingbox":["27.433295978484","27.433395978484","-80.347576876947","-80.347476876947"],"lat":"27.4337002","lon":"-80.3476924","display_name":"2306, Nebraska Avenue, Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","hamlet":"Glidden Park","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34950","country":"United States of America","country_code":"us"}},{"place_id":"323591160054","osm_id":"11300187","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"27.4337015","lon":"-80.3575209","boundingbox":["27.4337015","27.4337015","-80.3575209","-80.3575209"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34947, USA","display_place":"Nebraska Avenue","display_address":"Fort Pierce, Saint Lucie County, Florida, 34947, USA","address":{"name":"Nebraska Avenue","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34947","country":"United States of America","country_code":"us"}},{"place_id":"322215174196","osm_id":"13538640","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"31.048545","lon":"-93.208152","boundingbox":["31.048469","31.04864","-93.208377","-93.207498"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Fort Polk, Fort Polk South, Vernon Parish, Louisiana, 71459, USA","display_place":"Nebraska Avenue","display_address":"Fort Polk, Fort Polk South, Vernon Parish, Louisiana, 71459, USA","address":{"name":"Nebraska Avenue","suburb":"Fort Polk","city":"Fort Polk South","county":"Vernon Parish","state":"Louisiana","postcode":"71459","country":"United States of America","country_code":"us"}},{"place_id":"320459502871","osm_id":"13065809","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"37.732767","lon":"-100.036261","boundingbox":["37.73275","37.732767","-100.036623","-100.034396"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Dodge City, Ford County, Kansas, 67801, USA","display_place":"Nebraska Avenue","display_address":"Dodge City, Ford County, Kansas, 67801, USA","address":{"name":"Nebraska Avenue","city":"Dodge City","county":"Ford County","state":"Kansas","postcode":"67801","country":"United States of America","country_code":"us"}},{"place_id":"321166013414","osm_id":"11300188","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"27.4332924","lon":"-80.3343063","boundingbox":["27.4332514","27.4332924","-80.3343063","-80.3329518"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","display_place":"Nebraska Avenue","display_address":"Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","address":{"name":"Nebraska Avenue","suburb":"Glidden Park","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34950","country":"United States of America","country_code":"us"}},{"place_id":"321166013414","osm_id":"11300186","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"27.4338398","lon":"-80.3439919","boundingbox":["27.4321861","27.434113","-80.3501509","-80.337114"],"class":"highway","type":"tertiary","display_name":"Nebraska Avenue, Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","display_place":"Nebraska Avenue","display_address":"Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","address":{"name":"Nebraska Avenue","suburb":"Glidden Park","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34950","country":"United States of America","country_code":"us"}}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '2306 Nebraska Avenue Fort');
        Assert.areEqual(5, places.size(), '5 records must be returned');

        Assert.areEqual('2306, Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34950', places[0].display_name, 'display name must match the format');
        Assert.areEqual(27.4337002, places[0].location.latitude, 'latitude must match');
        Assert.areEqual(-80.3476924, places[0].location.longitude, 'longitude must match');

        Assert.areEqual('Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34947', places[1].display_name, 'display name must match the format');
        Assert.areEqual(27.4337015, places[1].location.latitude, 'latitude must match');
        Assert.areEqual(-80.3575209, places[1].location.longitude, 'longitude must match');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesSearchApiGivesEnoughResults() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'search',
            200,
            '[{"place_id":"370886050","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"28522893","boundingbox":["38.608248166554","38.608348166554","-90.229275314228","-90.229175314228"],"lat":"38.6082761","lon":"-90.229385","display_name":"2306, Nebraska Avenue, Fox Park, St. Louis, Missouri, 63104, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","neighbourhood":"Fox Park","city":"St. Louis","state":"Missouri","postcode":"63104","country":"United States of America","country_code":"us"}},{"place_id":"361825323","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"205702389","boundingbox":["41.645522857143","41.645622857143","-83.599302571429","-83.599202571429"],"lat":"41.64557285714286","lon":"-83.59925257142858","display_name":"2306, Nebraska Avenue, Scott Park, Freemans Gardens, Toledo, Lucas County, Ohio, 43607, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","neighbourhood":"Scott Park","hamlet":"Freemans Gardens","city":"Toledo","county":"Lucas County","state":"Ohio","postcode":"43607","country":"United States of America","country_code":"us"}},{"place_id":"359537718","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"13414892","boundingbox":["39.117559323232","39.117659323232","-94.654972565657","-94.654872565657"],"lat":"39.11760932323232","lon":"-94.65492256565656","display_name":"2306, Nebraska Avenue, Westheight Manor, Westheight, Kansas City, Wyandotte County, Kansas, 66102, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","residential":"Westheight Manor","suburb":"Westheight","city":"Kansas City","county":"Wyandotte County","state":"Kansas","postcode":"66102","country":"United States of America","country_code":"us"}},{"place_id":"372798890","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"8660817","boundingbox":["43.027182949495","43.027282949495","-83.660481656566","-83.660381656566"],"lat":"43.02723294949495","lon":"-83.66043165656565","display_name":"2306, Nebraska Avenue, Flint, Genesee County, Michigan, 48506, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","city":"Flint","county":"Genesee County","state":"Michigan","postcode":"48506","country":"United States of America","country_code":"us"}},{"place_id":"367019384","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"18221168","boundingbox":["44.986043953338","44.986143953338","-93.002706523745","-93.002606523745"],"lat":"44.98609395333807","lon":"-93.00265652374513","display_name":"2306, Nebraska Avenue, Maplewood, Ramsey County, Minnesota, 55119, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","town":"Maplewood","county":"Ramsey County","state":"Minnesota","postcode":"55119","country":"United States of America","country_code":"us"}}]'
        );
        mock.addNotToRequest(
            'GET',
            'autocomplete'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '2306 Nebraska Avenue');
        Assert.areEqual(5, places.size(), '5 records must be returned');

        Assert.areEqual('2306, Nebraska Avenue, St. Louis, Missouri, 63104', places[0].display_name, 'display name must match the format');
        Assert.areEqual(38.6082761, places[0].location.latitude, 'latitude must match');
        Assert.areEqual(-90.229385, places[0].location.longitude, 'longitude must match');

        Assert.areEqual('2306, Nebraska Avenue, Toledo, Lucas County, Ohio, 43607', places[1].display_name, 'display name must match the format');
        Assert.areEqual(41.64557285714286, places[1].location.latitude, 'latitude must match');
        Assert.areEqual(-83.59925257142858, places[1].location.longitude, 'longitude must match');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesLessResultsFromSubApis() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'search',
            200,
            '[{"place_id":"369662067","licence":"https://locationiq.com/attribution","osm_type":"way","osm_id":"11300186","boundingbox":["27.433295978484","27.433395978484","-80.347576876947","-80.347476876947"],"lat":"27.4337002","lon":"-80.3476924","display_name":"2306, Nebraska Avenue, Glidden Park, Fort Pierce, Saint Lucie County, Florida, 34950, USA","class":"place","type":"house","importance":0,"address":{"house_number":"2306","road":"Nebraska Avenue","hamlet":"Glidden Park","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34950","country":"United States of America","country_code":"us"}}]'
        );
        mock.addResponse(
            'GET',
            'autocomplete',
            200,
            '[{"place_id":"323591160054","osm_id":"11300187","osm_type":"way","licence":"https://locationiq.com/attribution","lat":"27.4337015","lon":"-80.3575209","boundingbox":["27.4337015","27.4337015","-80.3575209","-80.3575209"],"class":"highway","type":"residential","display_name":"Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34947, USA","display_place":"Nebraska Avenue","display_address":"Fort Pierce, Saint Lucie County, Florida, 34947, USA","address":{"name":"Nebraska Avenue","city":"Fort Pierce","county":"Saint Lucie County","state":"Florida","postcode":"34947","country":"United States of America","country_code":"us"}}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '2306 Nebraska Avenue Fort');
        Assert.areEqual(2, places.size(), '2 records must be returned');

        Assert.areEqual('2306, Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34950', places[0].display_name, 'display name must match the format');
        Assert.areEqual(27.4337002, places[0].location.latitude, 'latitude must match');
        Assert.areEqual(-80.3476924, places[0].location.longitude, 'longitude must match');

        Assert.areEqual('Nebraska Avenue, Fort Pierce, Saint Lucie County, Florida, 34947', places[1].display_name, 'display name must match the format');
        Assert.areEqual(27.4337015, places[1].location.latitude, 'latitude must match');
        Assert.areEqual(-80.3575209, places[1].location.longitude, 'longitude must match');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesEmptyQuery() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addNotToRequest(
            'GET',
            'search'
        );
        mock.addNotToRequest(
            'GET',
            'autocomplete'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapLocationIQHelper helper = getMapHelper();
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
    public static void testGetDistancesForDestinationsNearSource() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'matrix',
            200,
            '{"distances":[[0,49765,64489.1]],"durations":[[0,2313.5,2979.5]]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3208760, -111.9862530),
            new MapApi.Location(33.3787930, -111.7259020)
        };
        List<MapApi.LocationDistance> distances = getMapHelper().getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(49765, distances[0].distance, 'distance must match');
        Assert.areEqual(2313.5, distances[0].duration, 'duration must match');

        Assert.areEqual(64489.1, distances[1].distance, 'distance must match');
        Assert.areEqual(2979.5, distances[1].duration, 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDistancesForNotAllDestinationsNearSource() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'matrix',
            200,
            '{"distances":[[0,64489.1]],"durations":[[0,2979.5]]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        List<MapApi.LocationDistance> distances = getMapHelper().getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(64489.1, distances[0].distance, 'distance must match');
        Assert.areEqual(2979.5, distances[0].duration, 'duration must match');

        Assert.areEqual((getMapHelper().getHaversineDistance(source, destinations[1]) * 1000).intValue(), distances[1].distance.intValue(), 'distance must match');
        Assert.areEqual((getMapHelper().getHaversineDistance(source, destinations[1]) * 1000 / 15).intValue(), distances[1].duration.intValue(), 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDistancesForAllDestinationsFarFromSource() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addNotToRequest(
            'GET',
            'matrix'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(40.6558550, -73.59835100),
            new MapApi.Location(40.6663160, -73.47866900)
        };
        List<MapApi.LocationDistance> distances = getMapHelper().getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual((getMapHelper().getHaversineDistance(source, destinations[0]) * 1000).intValue(), distances[0].distance.intValue(), 'distance must match');
        Assert.areEqual((getMapHelper().getHaversineDistance(source, destinations[0]) * 1000 / 15).intValue(), distances[0].duration.intValue(), 'duration must match');

        Assert.areEqual((getMapHelper().getHaversineDistance(source, destinations[1]) * 1000).intValue(), distances[1].distance.intValue(), 'distance must match');
        Assert.areEqual((getMapHelper().getHaversineDistance(source, destinations[1]) * 1000 / 15).intValue(), distances[1].duration.intValue(), 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDistancesError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'matrix',
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

    @isTest
    public static void testGetHaversineDistance() {
        Test.startTest();

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.63650345, -112.13255847),
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        List<Double> expectedDistances = new List<Double>{
            0,
            47.35729190280602,
            3474.2289820993747
        };
        for (Integer index = 0; index < destinations.size(); index++) {
            Double distance = getMapHelper().getHaversineDistance(source, destinations[index]);
            Assert.areEqual(expectedDistances[index], distance, 'distance must match for index ' + String.valueOf(index));
        }

        Test.stopTest();
    }

    // getDirection related tests
    @isTest
    public static void testGetDirection() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'directions',
            200,
            '{"code":"Ok","routes":[{"geometry":{"coordinates":[[-112.132335,33.636544],[-112.129975,33.639592],[-112.117335,33.639781],[-112.116058,33.636376],[-112.117442,33.567815],[-112.112576,33.55513],[-112.113247,33.475289],[-112.108349,33.461418],[-112.107815,33.431519],[-112.103035,33.428648],[-112.062489,33.42897],[-112.030015,33.426452],[-112.022865,33.423402],[-112.009162,33.411332],[-111.97841,33.410735],[-111.971071,33.407672],[-111.967606,33.400308],[-111.972642,33.3237],[-111.973519,33.319995],[-111.986222,33.320714]],"type":"LineString"},"legs":[{"steps":[],"summary":"","weight":2338.4,"duration":2313.5,"distance":49765}],"weight_name":"routability","weight":2338.4,"duration":2313.5,"distance":49765}],"waypoints":[{"hint":"Fk4-gFQgQoAGAAAABAAAAEAAAAAVAAAATh7EQOIvPUCWdmRCGMSWQQYAAAAEAAAAQAAAABUAAABolwEAEf9Q-cBAAQIy_lD5l0ABAgIAvxUhlyd6","distance":21.185718061,"name":"North 34th Avenue","location":[-112.132335,33.636544]},{"hint":"Rcxhi____38HAAAAEQAAAFEAAABCAAAAJ8rAPwXg_T_koohBIWhbQQMAAAAIAAAAKAAAACAAAABolwEA0jlT-Qpv_AGzOVP5rG_8AQUATxAhlyd6","distance":18.197825703,"name":"","location":[-111.986222,33.320714]}]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3208760, -111.9862530);
        MapApi.Direction direction = getMapHelper().getDirection(MapApi.Mode.DRIVE, source, destination);

        Assert.areEqual(1, direction.routes.size(), 'must return 1 route');
        Assert.areEqual(49765.0, direction.routes[0].distance, 'distance must match');
        Assert.areEqual(2313.5, direction.routes[0].duration, 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDirectionError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'directions',
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