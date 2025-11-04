/**
 * @description    : Interface used to MapApi class
 *
 * Created Date    : 15/05/2024
 *
 * @JIRA Id        : CC-232, CC-233
 **/
public interface MapHelper {
    
    List<MapApi.Place> searchPlaces(String sessionID, String query);
    
    MapApi.Place getPlaceByID(String sessionID, String locationID);
    
    List<MapApi.LocationDistance> getDistances(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations);
    
    MapApi.Direction getDirection(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination);
}