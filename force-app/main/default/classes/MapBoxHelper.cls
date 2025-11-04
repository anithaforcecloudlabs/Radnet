/**
 * @description    : Class used to call Mapbox API
 *
 * Created Date    : 15/05/2024
 *
 * @JIRA Id        : CC-232, CC-233
 **/
public class MapBoxHelper implements MapHelper {

    private static final String BASE_URL = 'https://api.mapbox.com/';
    private static final String PATH_SEARCH = 'search/searchbox/v1/suggest';
    private static final String PATH_RETRIEVE = 'search/searchbox/v1/retrieve/';
    private static final String PATH_DISTANCES = 'directions-matrix/v1/mapbox/';
    private static final String PATH_DIRECTION = 'directions/v5/mapbox/';
	
    /**
    * @description Wrapper class to handle Coordinates
    **/
    public class Coordinate {
        public String latitude;
        public String longitude;
    }

    /**
    * @description Wrapper class to handle SearchItem
    **/
    public class SearchItem {
        public String mapbox_id;
        public String name;
        public String address;
        public String full_address;
        public Coordinate coordinates;

        public String getID() {
            return MapApi.HelperType.MAPBOX.name() + '_' + this.mapbox_id;
        }

        public String getDisplayName() {
            return this.full_address;
        }
    }

    public class SearchResult {
        public SearchItem[] suggestions;
    }

    public class RetrieveFeature {
        public SearchItem properties;
    }

    public class RetrieveResult {
        public RetrieveFeature[] features;
    }

    public class DistancesResult {
        public Double[][] distances;
        public Double[][] durations;
    }

    public class Route {
        public MapApi.GeoJSON geometry;
        public Double distance;
        public Double duration;
    }

    public class DirectionResult {
        public Route[] routes;
    }

    private String apiKey;

    public MapBoxHelper(String apiKey) {
        this.apiKey = apiKey;
    }

    /**
    * @description (Autocomplete API)Method used to take string address as parameter and return list of aaddresses that matches input text using Autocomplete API
    * @param sessionID
    * @param query (Address string)
    * @return List<Place> Wrapper
    **/
    public List<MapApi.Place> searchPlaces(String sessionID, String query) {
        if (String.isEmpty(sessionID) || String.isEmpty(query)) {
            return new List<MapApi.Place>();
        }

        String url = String.format('{0}{1}?access_token={2}&country=US&session_token={3}&q={4}', new List<Object>{
            BASE_URL, PATH_SEARCH, this.apiKey, sessionID, EncodingUtil.urlEncode(query, 'UTF-8')
        });

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
        SearchResult searchResult = (SearchResult) JSON.deserialize(response.getBody(), SearchResult.class);
        for (SearchItem searchItem : searchResult.suggestions) {
            MapApi.Place location = new MapApi.Place(
                searchItem.getID(),
                searchItem.getDisplayName(),
                null
            );
            results.add(location);
        }
        return results;
    }

    /**
    * @description (Autocomplete API) Method used to take locationId as parameter and return place that matches locationID using Autocomplete API
    * @param sessionID
    * @param locationID
    * @return Place Wrapper
    **/
    public MapApi.Place getPlaceByID(String sessionID, String locationID) {
        if (String.isEmpty(sessionID) || String.isEmpty(locationID)) {
            return null;
        }

        String url = String.format('{0}{1}{2}?access_token={3}&session_token={4}', new List<Object>{
            BASE_URL, PATH_RETRIEVE, locationID, this.apiKey, sessionID
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

        RetrieveResult retrieveResult = (RetrieveResult) JSON.deserialize(response.getBody(), RetrieveResult.class);
        if (retrieveResult.features == null || retrieveResult.features.size() == 0) {
            return null;
        }
        SearchItem searchItem = retrieveResult.features[0].properties;
        return new MapApi.Place(
            searchItem.getID(),
            searchItem.getDisplayName(),
            new MapApi.Location(searchItem.coordinates.latitude, searchItem.coordinates.longitude)
        );
    }

    /**
    * @description (Matrix API) Method to take source and destinations coordinates and return distance and duration list from single source to multiple destinations using Matrix API
    * @param source
    * @param destinations
    * @return List<LocationDistance>
    **/
    public List<MapApi.LocationDistance> getDistances(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations) {
        List<String> locations = new List<String>{source.toString()};
        for (MapApi.Location location : destinations) {
            locations.add(location.toString());
        }

        String url = String.format('{0}{1}{2}/{3}?access_token={4}&annotations=distance,duration&sources=0', new List<Object>{
            BASE_URL, PATH_DISTANCES, this.getMode(mode), String.join(locations, ';'), this.apiKey
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

        List<MapApi.LocationDistance> results = new List<MapApi.LocationDistance>();
        DistancesResult distancesResult = (DistancesResult) JSON.deserialize(response.getBody(), DistancesResult.class);
        if (distancesResult.distances.size() > 0 && distancesResult.durations.size() > 0) {
            for (Integer index = 1; index < distancesResult.distances[0].size(); index++) {
                MapApi.LocationDistance locationDistance = new MapApi.LocationDistance(
                    source,
                    destinations[index-1],
                    distancesResult.distances[0][index],
                    distancesResult.durations[0][index]
                );
                results.add(locationDistance);
            }
        }
        return results;
    }

    /**
    * @description (Direction API) Method used to take source and destination coordinates as parameter and return coordinates list to show direction on the map using Direction API
    * @param source
    * @param destination
    * @return Direction Wrapper
    **/
    public MapApi.Direction getDirection(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination) {
        List<String> locations = new List<String>{source.toString(), destination.toString()};

        String url = String.format('{0}{1}{2}/{3}?access_token={4}&geometries=geojson', new List<Object>{
            BASE_URL, PATH_DIRECTION, this.getMode(mode), String.join(locations, ';'), this.apiKey
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

    @TestVisible
    public String getMode(MapApi.Mode mode) {
        switch on mode {
            when DRIVE {
                return 'driving';
            }
            when TRANSIT {
                return 'driving';
            }
            when MOTORBIKE {
                return 'driving';
            }
            when BICYCLE {
                return 'cycling';
            }
            when WALK {
                return 'walking';
            }
        }
        return 'driving';
    }
}