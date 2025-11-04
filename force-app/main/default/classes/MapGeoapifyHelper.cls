/**
 * @description    : Class used for Geo API Helper
 *
 * Created Date    : 15/05/2024
 *
 * @JIRA Id        : CC-232, CC-233
 **/
public with sharing class MapGeoapifyHelper implements MapHelper {

    private static final String BASE_URL = 'https://api.geoapify.com/';
    private static final String PATH_SEARCH = 'v1/geocode/autocomplete';
    private static final String PATH_DISTANCES = 'v1/routematrix';
    private static final String PATH_DIRECTION = 'v1/routing';

    /**
    * @description Wrapper class for SearchResult
    **/
    public class SearchResult {
        public String place_id;
        public String formatted;
        public String address_line1;
        public String address_line2;
        public Double lon;
        public Double lat;

        public String getID() {
            return MapApi.HelperType.GEOAPIFY.name() + '_' + this.place_id;
        }

        public String getDisplayName() {
            return this.formatted;
        }
    }

    /**
    * @description Wrapper class for SearchResults
    **/
    public class SearchResults {
        public List<SearchResult> results;
    }

    /**
    * @description Wrapper class for DistanceItem
    **/
    public class DistanceItem {
        public Double distance;
        public Double duration;
        public Integer source_index;
        public Integer target_index;
    }

    public class DistancesResult {
        public DistanceItem[][] sources_to_targets;
    }

    public class DistancesRequest {
        public String mode;
        public DistanceLocation[] sources;
        public DistanceLocation[] targets;

        public DistancesRequest(String mode, DistanceLocation[] sources, DistanceLocation[] targets) {
            this.mode = mode;
            this.sources = sources;
            this.targets = targets;
        }
    }

    public class DistanceLocation {
        public Double[] location;

        public DistanceLocation(MapApi.Location location) {
            this.location = new Double[]{location.longitude, location.latitude};
        }
    }

    /**
    * @description Wrapper class for RouteProperties Distance/Duration
    **/
    public class RouteProperties {
        public Double distance;
        public Double duration;
    }

    public class GeoJSON {
        public List<Double[][]> coordinates;
        public String type;

        public MapApi.GeoJSON getLineString() {
            List<Double[]> lineStringCoordinates = new List<Double[]>();
            for (Double[][] leg : coordinates) {
                for (Double[] point : leg) {
                    lineStringCoordinates.add(point);
                }
            }
            MapApi.GeoJSON lineStringGeoJson = new MapApi.GeoJSON();
            lineStringGeoJson.coordinates = lineStringCoordinates;
            lineStringGeoJson.type = 'LineString';
            return lineStringGeoJson;
        }
    }

    public class Route {
        public GeoJSON geometry;
        public RouteProperties properties;
    }

    public class DirectionResult {
        public Route[] features;
    }

    private String apiKey;

    public MapGeoapifyHelper(String apiKey) {
        this.apiKey = apiKey;
    }

    /**
    * @description Method to search places by autocomplete
    * @param query
    * @return List<MapApi.Place>
    **/
    public List<MapApi.Place> searchPlaces(String sessionID, String query) {
        if (String.isEmpty(query)) {
            return new List<MapApi.Place>();
        }

        String url = String.format('{0}{1}?apiKey={2}&limit=10&filter=countrycode:us&bias=countrycode:us&format=json&text={3}', new List<Object>{
            BASE_URL, PATH_SEARCH, this.apiKey, EncodingUtil.urlEncode(query, 'UTF-8')
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
        SearchResults searchResults = (SearchResults) JSON.deserialize(response.getBody(), SearchResults.class);
        for (SearchResult searchResult : searchResults.results) {
            MapApi.Place location = new MapApi.Place(
                searchResult.getID(),
                searchResult.getDisplayName(),
                new MapApi.Location(searchResult.lat, searchResult.lon)
            );
            results.add(location);
        }
        return results;
    }

    public MapApi.Place getPlaceByID(String sessionID, String locationID) {
        throw new MapApiException('not implemented');
    }
	
    /**
    * @description Method to get distance matrix
    * @param Source and destinations
    * @return List<MapApi.LocationDistance>
    **/
    public List<MapApi.LocationDistance> getDistances(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations) {
        List<DistanceLocation> sources = new List<DistanceLocation>{new DistanceLocation(source)};
        List<DistanceLocation> targets = new List<DistanceLocation>();
        for (MapApi.Location location : destinations) {
            targets.add(new DistanceLocation(location));
        }

        String url = String.format('{0}{1}?apiKey={2}', new List<Object>{
            BASE_URL, PATH_DISTANCES, this.apiKey
        });

        String requestBody = JSON.serialize(new DistancesRequest(this.getMode(mode), sources, targets));

        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);

        Http http = new Http();
        HTTPResponse response = http.send(request);
        if (response.getStatusCode() != 200) {
            System.debug(response.getBody());
            return null;
        }

        List<MapApi.LocationDistance> results = new List<MapApi.LocationDistance>();
        DistancesResult distancesResult = (DistancesResult) JSON.deserialize(response.getBody().replace('\"time\"', '\"duration\"'), DistancesResult.class);
        if (distancesResult.sources_to_targets.size() > 0) {
            for (Integer index = 0; index < distancesResult.sources_to_targets[0].size(); index++) {
                MapApi.LocationDistance locationDistance = new MapApi.LocationDistance(
                    source,
                    destinations[index],
                    distancesResult.sources_to_targets[0][index].distance,
                    distancesResult.sources_to_targets[0][index].duration
                );
                if (distancesResult.sources_to_targets[0][index].target_index != index) {
                    System.debug('index mismatch');
                    return null;
                }
                results.add(locationDistance);
            }
        }
        return results;
    }

    /**
    * @description Method used to get direction
    **/
    public MapApi.Direction getDirection(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination) {
        List<String> locations = new List<String>{source.toString(), destination.toString()};

        String url = String.format('{0}{1}?apiKey={2}&waypoints=lonlat:{3}&mode={4}&traffic=approximated&format=geojson', new List<Object>{
            BASE_URL, PATH_DIRECTION, this.apiKey, String.join(locations, '|lonlat:'), this.getMode(mode)
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

        DirectionResult directionResult = (DirectionResult) JSON.deserialize(response.getBody().replace('\"time\"', '\"duration\"'), DirectionResult.class);
        List<MapApi.Route> routes = new List<MapApi.Route>();
        for (Route route : directionResult.features) {
            routes.add(new MapApi.Route(route.geometry.getLineString(), route.properties.distance, route.properties.duration));
        }
        return new MapApi.Direction(source, destination, routes);
    }

    public String getMode(MapApi.Mode mode) {
        switch on mode {
            when DRIVE {
                return 'drive';
            }
            when TRANSIT {
                return 'transit';
            }
            when MOTORBIKE {
                return 'motorcycle';
            }
            when BICYCLE {
                return 'bicycle';
            }
            when WALK {
                return 'walk';
            }
        }
        return 'drive';
    }
}