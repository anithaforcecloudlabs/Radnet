/**
* @description    : Helper class for LocationIQ API
*
* Created Date    : 15/05/2024
*
* @JIRA Id        : CC-232, CC-233
**/
public class MapLocationIQHelper implements MapHelper {

    private static final String BASE_URL = 'https://us1.locationiq.com/v1/';
    private static final String PATH_SEARCH = 'autocomplete';
    private static final String PATH_DISTANCES = 'matrix/driving/';
    private static final String PATH_DIRECTION = 'directions/driving/';
    private static final String PATH_GEOCODE = 'search';

    private static final Double RADIUS_OF_EARTH = 6371; // in kms
    private static final Double DISTANCE_THRESHOLD = 250; // in kms
    private static final Double AVERAGE_SPEED_OF_VEHICLE = 15; // in m/s
    private static final Integer SEARCH_RESULTS_LIMIT = 5;

    /**
    * @description Wrapper class for SearchAddress
    **/
    public class SearchAddress {
        public String house_number;
        public String name;
        public String road;
        public String hamlet;
        public String suburb;
        public String village;
        public String town;
        public String city;
        public String city_district;
        public String region;
        public String county;
        public String state_district;
        public String state;
        public String state_code;
        public String postcode;
        public String country;
        public String country_code;
    }
	
    /**
     * @description Wrapper class for SearchResult
     **/
    public class SearchResult {
        public String place_id;
        public String lat;
        public String lon;
        public String display_name;
        public SearchAddress address;

        public String getID() {
            return MapApi.HelperType.LOCATIONIQ.name() + '_' + this.place_id;
        }

        public String getDisplayName() {
            List<String> fieldsToDisplay = new List<String>();
            if (this.address == null) {
                return this.display_name;
            }

            if (!String.isEmpty(this.address.name)) {
                fieldsToDisplay.add(this.address.name);
            }

            if (!String.isEmpty(this.address.house_number)) {
                fieldsToDisplay.add(this.address.house_number);
            }

            if (!String.isEmpty(this.address.road)) {
                fieldsToDisplay.add(this.address.road);
            }

            if (!String.isEmpty(this.address.village)) {
                fieldsToDisplay.add(this.address.village);
            }

            if (!String.isEmpty(this.address.town)) {
                fieldsToDisplay.add(this.address.town);
            }

            if (!String.isEmpty(this.address.city)) {
                fieldsToDisplay.add(this.address.city);
            }

            if (!String.isEmpty(this.address.county)) {
                fieldsToDisplay.add(this.address.county);
            }
            
            if (!String.isEmpty(this.address.state)) {
                fieldsToDisplay.add(this.address.state);
            }

            if (!String.isEmpty(this.address.postcode)) {
                fieldsToDisplay.add(this.address.postcode);
            }

            return String.join(fieldsToDisplay, ', ');
        }
    }
	
    /**
     * @description Wrapper class for DistancesResult
     **/
    public class DistancesResult {
        public Double[][] distances;
        public Double[][] durations;
    }

    /**
    * @description Wrapper class for Route
    **/
    public class Route {
        public MapApi.GeoJSON geometry;
        public Double distance;
        public Double duration;
    }

    /**
    * @description Wrapper class for DirectionResult
    **/
    public class DirectionResult {
        public Route[] routes;
    }

    private String apiKey;

    public MapLocationIQHelper(String apiKey) {
        this.apiKey = apiKey;
    }

    /**
    * @description (Autocomplete API)Method used to take string address as parameter and return list of aaddresses that matches input text using Autocomplete API
    * @param query (String address)
    * @return List<MapApi.Place>
    **/
    @TestVisible
    private List<MapApi.Place> getPlacesFromGeocodeOrSearch(String query, Boolean geocode) {
        String url;
        if (geocode) {
            url = String.format('{0}{1}?key={2}&q={3}&addressdetails=1&countrycodes=us&format=json', new List<Object>{
                BASE_URL, PATH_GEOCODE, this.apiKey, EncodingUtil.urlEncode(query, 'UTF-8')
            });
        } else {
            url = String.format('{0}{1}?key={2}&q={3}&countrycodes=us', new List<Object>{
                BASE_URL, PATH_SEARCH, this.apiKey, EncodingUtil.urlEncode(query, 'UTF-8')
            });
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        Http http = new Http();
        HTTPResponse response = http.send(request);
        if (response.getStatusCode() != 200) {
            System.debug(response.getBody());
            return new List<MapApi.Place>();
        }

        List<MapApi.Place> results = new List<MapApi.Place>();
        List<SearchResult> searchResults = (List<SearchResult>) JSON.deserialize(response.getBody(), List<SearchResult>.class);
        for (SearchResult searchResult : searchResults) {
            MapApi.Place location = new MapApi.Place(
                searchResult.getID(),
                searchResult.getDisplayName(),
                new MapApi.Location(searchResult.lat, searchResult.lon)
            );
            results.add(location);
        }
        return results;
    }

    /**
    * @description (Autocomplete API)Method used to take string address as parameter and return list of aaddresses that matches input text using Autocomplete API
    * @param sessionID
    * @param query (String address)
    * @return List<MapApi.Place>
    **/
    public List<MapApi.Place> searchPlaces(String sessionID, String query) {
        if (String.isEmpty(query)) {
            return new List<MapApi.Place>();
        }

        Map<String, Boolean> duplicatesMap = new Map<String, Boolean>();

        List<MapApi.Place> results = new List<MapApi.Place>();
        for (MapApi.Place place : this.getPlacesFromGeocodeOrSearch(query, true)) {
            duplicatesMap.put(place.getHash(), true);
            results.add(place);
            if (results.size() == SEARCH_RESULTS_LIMIT) {
                return results;
            }
        }

        for (MapApi.Place place : this.getPlacesFromGeocodeOrSearch(query, false)) {
            String placeHash = place.getHash();
            if (duplicatesMap.containsKey(placeHash)) {
                continue;
            }

            duplicatesMap.put(placeHash, true);
            results.add(place);
            if (results.size() == SEARCH_RESULTS_LIMIT) {
                return results;
            }
        }
        return results;
    }

    public MapApi.Place getPlaceByID(String sessionID, String locationID) {
        throw new MapApiException('not implemented');
    }
	
    /**
    * @description (Matrix API) Method to take source and destinations coordinates and return distance and duration list from single source to multiple destinations using Matrix API
    * @param mode
    * @param source
    * @param destinations
    * @return List<MapApi.LocationDistance>
    **/
    public List<MapApi.LocationDistance> getDistances(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations) {
        Map<String,Double> haversineDistancesMap = new Map<String,Double>();
        List<MapApi.Location> requestDestinations = new List<MapApi.Location>();
        List<String> locations = new List<String>{source.toString()};
        for (MapApi.Location destination : destinations) {
            Double havesineDistance = getHaversineDistance(source, destination);
            haversineDistancesMap.put(destination.toString(), havesineDistance);
            if (havesineDistance < DISTANCE_THRESHOLD) {
                requestDestinations.add(destination);
                locations.add(destination.toString());
            }
        }

        Map<String,MapApi.LocationDistance> distancesMap = new Map<String,MapApi.LocationDistance>();
        if (requestDestinations.size() > 0) {
            String url = String.format('{0}{1}{2}?key={3}&annotations=distance,duration&sources=0', new List<Object>{
                BASE_URL, PATH_DISTANCES, String.join(locations, ';'), this.apiKey
            });

            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');

            Http http = new Http();
            HTTPResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                System.debug(response.getBody());
                return null;
            }

            DistancesResult distancesResult = (DistancesResult) JSON.deserialize(response.getBody(), DistancesResult.class);
            if (distancesResult.distances.size() > 0 && distancesResult.durations.size() > 0) {
                for (Integer index = 0; index < requestDestinations.size(); index++) {
                    MapApi.LocationDistance locationDistance = new MapApi.LocationDistance(
                        source,
                        requestDestinations[index],
                        distancesResult.distances[0][index+1],
                        distancesResult.durations[0][index+1]
                    );
                    distancesMap.put(requestDestinations[index].toString(), locationDistance);
                }
            }
        }

        List<MapApi.LocationDistance> results = new List<MapApi.LocationDistance>();
        for (MapApi.Location destination : destinations) {
            String destinationKey = destination.toString();
            if (distancesMap.containsKey(destinationKey)) {
                results.add(distancesMap.get(destinationKey));
                continue;
            }
            Double distance = haversineDistancesMap.get(destinationKey) * 1000;
            MapApi.LocationDistance locationDistance = new MapApi.LocationDistance(
                source,
                destination,
                Decimal.valueOf(distance).setScale(2).doubleValue(),
                Decimal.valueOf(distance / AVERAGE_SPEED_OF_VEHICLE).setScale(2).doubleValue()
            );
            results.add(locationDistance);
        }
        return results;
    }

    /**
    * @description (Direction API) Method used to take source and destination coordinates as parameter and return coordinates list to show direction on the map using Direction API
    * @param mode
    * @param source
    * @param destination
    * @return MapApi.Direction
    **/
    public MapApi.Direction getDirection(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination) {
        List<String> locations = new List<String>{source.toString(), destination.toString()};

        String url = String.format('{0}{1}{2}?key={3}&geometries=geojson', new List<Object>{
            BASE_URL, PATH_DIRECTION, String.join(locations, ';'), this.apiKey
        });

        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        Http http = new Http();
        HTTPResponse response = http.send(request);
        if (response.getStatusCode() != 200) {
            System.debug(response.getBody());
            return null;
        }

        DirectionResult directionResult = (DirectionResult) JSON.deserialize(response.getBody(), DirectionResult.class);
        List<MapApi.Route> routes = new List<MapApi.Route>();
        for (Route route : directionResult.routes) {
            routes.add(new MapApi.Route(route.geometry, route.distance, route.duration));
        }
        return new MapApi.Direction(source, destination, routes);
    }
	
    /**
    * @description Method used to get Haversine  Distance
    * @param mode
    * @param source
    * @param destination
    * @return MapApi.Direction
    **/
    @TestVisible
    private Double getHaversineDistance(MapApi.Location source, MapApi.Location destination) {
        Double deltalat = (destination.latitude - source.latitude) * Math.PI / 180;
        Double deltalon = (destination.longitude - source.longitude) * Math.PI / 180;
        Double slat = source.latitude * Math.PI / 180;
        Double dlat = destination.latitude * Math.PI / 180;
        Double a = Math.pow(Math.sin(deltalat/2),2) + Math.cos(slat) * Math.cos(dlat) * Math.pow(Math.sin(deltalon/2),2);
        return RADIUS_OF_EARTH * 2 * Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
    }
}