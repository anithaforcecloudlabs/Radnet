@isTest
public with sharing class MapBoxHelperTest {
    static String SESSION_ID = '9021c8e0-2dbc-4d38-a5c0-b048a79d89a3';

    static MapboxHelper getMapHelper() {
        return new MapboxHelper('test-api-key');
    }

    // searchPlaces related tests
    @isTest
    static void testSearchItemDisplayNameAndID() {
        Test.startTest();

        List<String> searchResults = new List<String>{
            '{"name":"2306 Nebraska Avenue","mapbox_id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","feature_type":"address","address":"2306 Nebraska Avenue","full_address":"2306 Nebraska Avenue, Flint, Michigan 48506, United States","place_formatted":"Flint, Michigan 48506, United States","context":{"country":{"id":"dXJuOm1ieHBsYzpJdXc","name":"United States","country_code":"US","country_code_alpha_3":"USA"},"region":{"id":"dXJuOm1ieHBsYzpKT3c","name":"Michigan","region_code":"MI","region_code_full":"US-MI"},"postcode":{"id":"dXJuOm1ieHBsYzpDZGZ1N0E","name":"48506"},"district":{"id":"dXJuOm1ieHBsYzpnTWJz","name":"Genesee County"},"place":{"id":"dXJuOm1ieHBsYzpCcWpvN0E","name":"Flint"},"address":{"id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","name":"2306 Nebraska Avenue","address_number":"2306","street_name":"Nebraska Avenue"},"street":{"id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","name":"Nebraska Avenue"}},"language":"en","maki":"marker","metadata":{}}'
        };
        List<String> expectedDisplayNames = new List<String>{
            '2306 Nebraska Avenue, Flint, Michigan 48506, United States'
        };
        List<String> expectedIDs = new List<String>{
            'MAPBOX_dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY'
        };
        for (Integer index = 0; index < searchResults.size(); index++) {
            MapBoxHelper.SearchItem sr = (MapBoxHelper.SearchItem) JSON.deserialize(searchResults[index], MapBoxHelper.SearchItem.class);
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
            'suggest',
            200,
            '{"suggestions":[{"name":"2306 Nebraska Avenue","mapbox_id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","feature_type":"address","address":"2306 Nebraska Avenue","full_address":"2306 Nebraska Avenue, Flint, Michigan 48506, United States","place_formatted":"Flint, Michigan 48506, United States","context":{"country":{"id":"dXJuOm1ieHBsYzpJdXc","name":"United States","country_code":"US","country_code_alpha_3":"USA"},"region":{"id":"dXJuOm1ieHBsYzpKT3c","name":"Michigan","region_code":"MI","region_code_full":"US-MI"},"postcode":{"id":"dXJuOm1ieHBsYzpDZGZ1N0E","name":"48506"},"district":{"id":"dXJuOm1ieHBsYzpnTWJz","name":"Genesee County"},"place":{"id":"dXJuOm1ieHBsYzpCcWpvN0E","name":"Flint"},"address":{"id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","name":"2306 Nebraska Avenue","address_number":"2306","street_name":"Nebraska Avenue"},"street":{"id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","name":"Nebraska Avenue"}},"language":"en","maki":"marker","metadata":{}},{"name":"2306 Nebraska Avenue East","name_preferred":"2306 Nebraska Avenue","mapbox_id":"dXJuOm1ieGFkcjo2MWZkZTJjMy00OWYwLTQxMzgtOTYyYy0xMzA0YzVmZDBmYmQ","feature_type":"address","address":"2306 Nebraska Avenue","full_address":"2306 Nebraska Avenue, Maplewood, Minnesota 55119, United States","place_formatted":"Maplewood, Minnesota 55119, United States","context":{"country":{"id":"dXJuOm1ieHBsYzpJdXc","name":"United States","country_code":"US","country_code_alpha_3":"USA"},"region":{"id":"dXJuOm1ieHBsYzpBNFRz","name":"Minnesota","region_code":"MN","region_code_full":"US-MN"},"postcode":{"id":"dXJuOm1ieHBsYzpDem11N0E","name":"55119"},"district":{"id":"dXJuOm1ieHBsYzpBU2ttN0E","name":"Ramsey County"},"place":{"id":"dXJuOm1ieHBsYzpDL0tvN0E","name":"Maplewood"},"neighborhood":{"id":"dXJuOm1ieHBsYzpFWVRzN0E","name":"Hillside"},"address":{"id":"dXJuOm1ieGFkcjo2MWZkZTJjMy00OWYwLTQxMzgtOTYyYy0xMzA0YzVmZDBmYmQ","name":"2306 Nebraska Avenue","address_number":"2306","street_name":"Nebraska Avenue"},"street":{"id":"dXJuOm1ieGFkcjo2MWZkZTJjMy00OWYwLTQxMzgtOTYyYy0xMzA0YzVmZDBmYmQ","name":"Nebraska Avenue"}},"language":"en","maki":"marker","metadata":{}},{"name":"2306 Nebraska Avenue","mapbox_id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUToy","feature_type":"address","address":"2306 Nebraska Avenue","full_address":"2306 Nebraska Avenue, Toledo, Ohio 43607, United States","place_formatted":"Toledo, Ohio 43607, United States","context":{"country":{"id":"dXJuOm1ieHBsYzpJdXc","name":"United States","country_code":"US","country_code_alpha_3":"USA"},"region":{"id":"dXJuOm1ieHBsYzpBaVRz","name":"Ohio","region_code":"OH","region_code_full":"US-OH"},"postcode":{"id":"dXJuOm1ieHBsYzpDS3FPN0E","name":"43607"},"district":{"id":"dXJuOm1ieHBsYzoxK2Jz","name":"Lucas County"},"place":{"id":"dXJuOm1ieHBsYzpFNUJvN0E","name":"Toledo"},"neighborhood":{"id":"dXJuOm1ieHBsYzpJZmZzN0E","name":"Scott Park"},"address":{"id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUToy","name":"2306 Nebraska Avenue","address_number":"2306","street_name":"Nebraska Avenue"},"street":{"id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUToy","name":"Nebraska Avenue"}},"language":"en","maki":"marker","metadata":{}},{"name":"2306 Nebraska Avenue","mapbox_id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUToz","feature_type":"address","address":"2306 Nebraska Avenue","full_address":"2306 Nebraska Avenue, Saginaw, Michigan 48601, United States","place_formatted":"Saginaw, Michigan 48601, United States","context":{"country":{"id":"dXJuOm1ieHBsYzpJdXc","name":"United States","country_code":"US","country_code_alpha_3":"USA"},"region":{"id":"dXJuOm1ieHBsYzpKT3c","name":"Michigan","region_code":"MI","region_code_full":"US-MI"},"postcode":{"id":"dXJuOm1ieHBsYzpDZG5PN0E","name":"48601"},"district":{"id":"dXJuOm1ieHBsYzpBVGNHN0E","name":"Saginaw County"},"place":{"id":"dXJuOm1ieHBsYzpFU2lJN0E","name":"Saginaw"},"address":{"id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUToz","name":"2306 Nebraska Avenue","address_number":"2306","street_name":"Nebraska Avenue"},"street":{"id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUToz","name":"Nebraska Avenue"}},"language":"en","maki":"marker","metadata":{}},{"name":"2306 Nebraska Street","mapbox_id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUTo0","feature_type":"address","address":"2306 Nebraska Street","full_address":"2306 Nebraska Street, Oshkosh, Wisconsin 54902, United States","place_formatted":"Oshkosh, Wisconsin 54902, United States","context":{"country":{"id":"dXJuOm1ieHBsYzpJdXc","name":"United States","country_code":"US","country_code_alpha_3":"USA"},"region":{"id":"dXJuOm1ieHBsYzpBNlRz","name":"Wisconsin","region_code":"WI","region_code_full":"US-WI"},"postcode":{"id":"dXJuOm1ieHBsYzpDeVp1N0E","name":"54902"},"district":{"id":"dXJuOm1ieHBsYzpBWURtN0E","name":"Winnebago County"},"place":{"id":"dXJuOm1ieHBsYzpEcnBvN0E","name":"Oshkosh"},"address":{"id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUTo0","name":"2306 Nebraska Street","address_number":"2306","street_name":"Nebraska Street"},"street":{"id":"dXJuOm1ieGFkci1pdHA6ZXlKaGRYUnZZMjl0Y0d4bGRHVWlPaUowY25WbElpd2lablY2ZW5sTllYUmphQ0k2SW5SeWRXVWlMQ0pzWVc1bmRXRm5aU0k2SW1WdUlpd2liR2x0YVhRaU9pSXpNQ0lzSW5KdmRYUnBibWNpT2lKMGNuVmxJaXdpZEhsd1pYTWlPaUpoWkdSeVpYTnpMR0ZrWkhKbGMzTXNZMjkxYm5SeWVTeHlaV2RwYjI0c2NHOXpkR052WkdVc1pHbHpkSEpwWTNRc2NHeGhZMlVzYkc5allXeHBkSGtzYm1WcFoyaGliM0pvYjI5a0lpd2laWGh3YjNObFVISnZiV2x1Wlc1alpTSTZJblJ5ZFdVaUxDSjJaWEp6YVc5dUlqbzFMQ0pqWVd4c1ltRmpheUk2Ym5Wc2JDd2ljU0k2SWpJek1EWWdUbVZpY21GemEyRWlmUTo0","name":"Nebraska Street"}},"language":"en","maki":"marker","metadata":{}}],"attribution":"© 2024 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service. (https://www.mapbox.com/about/maps/)"}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapBoxHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '2306 Nebraska');
        Assert.areEqual(5, places.size(), '5 records must be returned');

        Assert.areEqual('2306 Nebraska Avenue, Flint, Michigan 48506, United States', places[0].display_name, 'display name must match the format');
        Assert.areEqual(null, places[0].location, 'location must be null');

        Test.stopTest();
    }

    @isTest
    static void testSearchPlacesError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'suggest',
            500,
            ''
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapBoxHelper helper = getMapHelper();
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
            'suggest'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapBoxHelper helper = getMapHelper();
        List<MapApi.Place> places = helper.searchPlaces(SESSION_ID, '');
        Assert.areEqual(0, places.size(), '0 records must be returned');

        Test.stopTest();
    }

    // getPlaceByID related tests
    @isTest
    static void testGetPlaceByID() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'retrieve',
            200,
            '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"coordinates":[-83.6602385,43.0269415],"type":"Point"},"properties":{"name":"2306 Nebraska Avenue","name_preferred":"2306 Nebraska Avenue","mapbox_id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","feature_type":"address","address":"2306 Nebraska Avenue","full_address":"2306 Nebraska Avenue, Flint, Michigan 48506, United States","place_formatted":"Flint, Michigan 48506, United States","context":{"country":{"id":"dXJuOm1ieHBsYzpJdXc","name":"United States","country_code":"US","country_code_alpha_3":"USA"},"region":{"id":"dXJuOm1ieHBsYzpKT3c","name":"Michigan","region_code":"MI","region_code_full":"US-MI"},"postcode":{"id":"postcode.1854607494266170","name":"48506"},"district":{"id":"dXJuOm1ieHBsYzpnTWJz","name":"Genesee County"},"place":{"id":"dXJuOm1ieHBsYzpCcWpvN0E","name":"Flint"},"address":{"id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","name":"2306 Nebraska Avenue","address_number":"2306","street_name":"Nebraska Avenue"},"street":{"id":"dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY","name":"Nebraska Avenue"}},"coordinates":{"latitude":43.0269415,"longitude":-83.6602385,"accuracy":"point","routable_points":[{"name":"default","latitude":43.02732,"longitude":-83.660257}]},"language":"en","maki":"marker","metadata":{}}}],"attribution":"© 2024 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service. (https://www.mapbox.com/about/maps/)"}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapBoxHelper helper = getMapHelper();
        MapApi.Place place = helper.getPlaceByID(SESSION_ID, 'dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY');

        Assert.areEqual('2306 Nebraska Avenue, Flint, Michigan 48506, United States', place.display_name, 'display name must match the format');
        Assert.areEqual(43.0269415, place.location.latitude, 'latitude must match');
        Assert.areEqual(-83.6602385, place.location.longitude, 'longitude must match');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDEmptyFeatures() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'retrieve',
            200,
            '{"type":"FeatureCollection","features":[],"attribution":"© 2024 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service. (https://www.mapbox.com/about/maps/)"}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapBoxHelper helper = getMapHelper();
        MapApi.Place place = helper.getPlaceByID(SESSION_ID, 'dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY');
        Assert.areEqual(null, place, 'place must be null');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'retrieve',
            500,
            ''
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapBoxHelper helper = getMapHelper();
        MapApi.Place place = helper.getPlaceByID(SESSION_ID, 'dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY');
        Assert.areEqual(null, place, 'place must be null');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDEmptySessionID() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addNotToRequest(
            'GET',
            'retrieve'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapBoxHelper helper = getMapHelper();
        MapApi.Place place = helper.getPlaceByID('', 'dXJuOm1ieGFkcjo3NjdjYWMzYS03ZDE0LTQyYjItYTQzYS1jYzNhMDFkZWY0OGY');
        Assert.areEqual(null, place, 'place must be null');

        Test.stopTest();
    }

    @isTest
    static void testGetPlaceByIDEmptyQuery() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addNotToRequest(
            'GET',
            'retrieve'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapBoxHelper helper = getMapHelper();
        MapApi.Place place = helper.getPlaceByID(SESSION_ID, '');
        Assert.areEqual(null, place, 'place must be null');

        Test.stopTest();
    }

    // getDistances related tests
    @isTest
    public static void testGetDistances() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'directions-matrix',
            200,
            '{"distances":[[0,64022.4,4005854.4]],"durations":[[0,2617,135573.9]]}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        List<MapApi.Location> destinations = new List<MapApi.Location>{
            new MapApi.Location(33.3787930, -111.7259020),
            new MapApi.Location(40.6558550, -73.59835100)
        };
        List<MapApi.LocationDistance> distances = getMapHelper().getDistances(MapApi.Mode.DRIVE, source, destinations);

        Assert.areEqual(64022.4, distances[0].distance, 'distance must match');
        Assert.areEqual(2617, distances[0].duration, 'duration must match');

        Assert.areEqual(4005854.4, distances[1].distance, 'distance must match');
        Assert.areEqual(135573.9, distances[1].duration, 'duration must match');

        Test.stopTest();
    }

    @isTest
    public static void testGetDistancesError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            'directions-matrix',
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
            'directions',
            200,
            '{"routes":[{"weight_name":"auto","weight":3104.684,"duration":2167.205,"distance":49850.133,"legs":[{"notifications":[{"details":{"message":"The road may not be accessible."},"subtype":"noAccess","type":"violation","geometry_index_end":724,"geometry_index_start":710}],"via_waypoints":[],"admins":[{"iso_3166_1_alpha3":"USA","iso_3166_1":"US"}],"weight":3104.684,"duration":2167.205,"steps":[],"distance":49850.133,"summary":"I 17, US 60"}],"geometry":{"coordinates":[[-112.132335,33.636544],[-112.130069,33.638359],[-112.129975,33.639592],[-112.118238,33.639781],[-112.117025,33.638928],[-112.117441,33.567815],[-112.112576,33.55513],[-112.113255,33.475676],[-112.110757,33.467561],[-112.108184,33.459703],[-112.108209,33.432557],[-112.105567,33.429371],[-112.028641,33.426165],[-112.009162,33.411332],[-111.973681,33.409261],[-111.968519,33.404376],[-111.967681,33.397497],[-111.972357,33.326607],[-111.973519,33.319995],[-111.986202,33.319918],[-111.986207,33.320512],[-111.986222,33.320714]],"type":"LineString"}}],"waypoints":[{"distance":21.182,"name":"North 34th Avenue","location":[-112.132335,33.636544]},{"distance":18.281,"name":"","location":[-111.986222,33.320714]}],"code":"Ok","uuid":"fgBC2f_RPR6ucOewYXQpcZDNB_lICgYvlqlO5IBEGlSflYEhkm46YQ=="}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        MapApi.Location source = new MapApi.Location(33.63650345, -112.13255847);
        MapApi.Location destination = new MapApi.Location(33.3208760, -111.9862530);
        MapApi.Direction direction = getMapHelper().getDirection(MapApi.Mode.DRIVE, source, destination);

        Assert.areEqual(1, direction.routes.size(), 'must return 1 route');
        Assert.areEqual(49850.133, direction.routes[0].distance, 'distance must match');
        Assert.areEqual(2167.205, direction.routes[0].duration, 'duration must match');

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

    @isTest
    public static void testGetMode() {
        Test.startTest();

        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.DRIVE), 'driving', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.TRANSIT), 'driving', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.MOTORBIKE), 'driving', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.BICYCLE), 'cycling', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(MapApi.Mode.WALK), 'walking', 'mode must match');
        Assert.areEqual(getMapHelper().getMode(null), 'driving', 'mode must match');

        Test.stopTest();
    }
}