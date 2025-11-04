/**
 * @description    : Class used for OSRM API callouts
 *
 * Created Date    : 15/05/2024
 *
 * @JIRA Id        : CC-232, CC-233
 **/
public class MapOsrmHelper implements MapHelper {

    private static final String BASE_URL = 'http://router.project-osrm.org/';
    private static final String PATH_DISTANCES = 'table/v1/driving/';
    private static final String PATH_DIRECTION = 'route/v1/driving/';

    /**
    * @description Wrapper class to handle DistancesResult
    **/
    public class DistancesResult {
        public Double[][] distances;
        public Double[][] durations;
    }

    /**
    * @description Wrapper class to handle Route
    **/
    public class Route {
        public MapApi.GeoJSON geometry;
        public Double distance;
        public Double duration;
    }

    /**
    * @description Wrapper class to handle DirectionResult
    **/
    public class DirectionResult {
        public Route[] routes;
    }

    public List<MapApi.Place> searchPlaces(String sessionID, String query) {
        throw new MapApiException('not implemented');
    }

    public MapApi.Place getPlaceByID(String sessionID, String locationID) {
        throw new MapApiException('not implemented');
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

        String url = String.format('{0}{1}{2}?annotations=distance,duration&sources=0', new List<Object>{
            BASE_URL, PATH_DISTANCES, String.join(locations, ';')
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

        String url = String.format('{0}{1}{2}?geometries=geojson', new List<Object>{
            BASE_URL, PATH_DIRECTION, String.join(locations, ';')
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
}