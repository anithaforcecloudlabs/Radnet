/**
 * @description    : Class used for caching callout results for given duration
 *
 * Created Date    : 15/05/2024
 *
 * @JIRA Id        : CC-232, CC-233
 **/
public with sharing class MapCache implements MapHelper {
    
    private static final String CACHE_PARTITION = 'local.maps';
    private static final String CACHE_PREFIX_SEARCH = 'search_api_';
    private static final String CACHE_PREFIX_RETRIEVE = 'retrieve_api_';
    private static final String CACHE_PREFIX_DISTANCES = 'distances_api_';
    private static final String CACHE_PREFIX_DIRECTION = 'direction_api_';
    
    @TestVisible
    private static MapConfig cacheConfig = new MapConfigFromCustomMetadata();
    
    @TestVisible
    private Integer cacheTimeout;
    
    public MapCache() {
        this.cacheTimeout = cacheConfig.getCacheTimeout();
    }
    
    private String getHash(String v) {
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(v));
        return EncodingUtil.convertToHex(hash);
    }
    
    /**
     * @description Used to caching results for Autocomplete API
     * @param sessionID
     * @param query (Address string)
     * @return Place Wrapper
     **/
    public List<MapApi.Place> searchPlaces(String sessionID, String query) {
        if (String.isEmpty(query)) {
            return new List<MapApi.Place>();
        }
        try {
            String cacheKey = getHash(CACHE_PREFIX_SEARCH + query);
            Cache.OrgPartition cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
            
            if (cachePartition.contains(cacheKey)) {
                List<MapApi.Place> cacheValue = (List<MapApi.Place>) cachePartition.get(cacheKey);
                return cacheValue;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return null;
    }
    
    /**
     * @description Used to caching results for Autocomplete API
     * @param sessionID
     * @param query (Address string)
     * @param List<MapApi.Place> places
     * @return void
     **/
    public void setSearchPlaces(String sessionID, String query, List<MapApi.Place> places) {
        if (places == null || places.size() == 0) {
            return;
        }
        try {
            String cacheKey = getHash(CACHE_PREFIX_SEARCH + query);
            Cache.OrgPartition cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
            cachePartition.put(cacheKey, places, this.cacheTimeout, Cache.Visibility.ALL, true);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    
    /**
     * @description Used to get results from cache
     * @param sessionID
     * @param locationID
     * @return Place Wrapper
     **/
    public MapApi.Place getPlaceByID(String sessionID, String locationID) {
        if (String.isEmpty(locationID)) {
            return null;
        }
        try {
            String cacheKey = getHash(CACHE_PREFIX_RETRIEVE + locationID);
            Cache.OrgPartition cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
            
            if (cachePartition.contains(cacheKey)) {
                MapApi.Place cacheValue = (MapApi.Place) cachePartition.get(cacheKey);
                return cacheValue;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return null;
    }
    
    /**
     * @description Used to set results in cache
     * @param sessionID
     * @param locationID
     * @param place
     * @return Place Wrapper
     **/
    public void setPlaceByID(String sessionID, String locationID, MapApi.Place place) {
        if (place == null) {
            return;
        }
        try {
            String cacheKey = getHash(CACHE_PREFIX_RETRIEVE + locationID);
            Cache.OrgPartition cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
            cachePartition.put(cacheKey, place, this.cacheTimeout, Cache.Visibility.ALL, true);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    
    private String getDistancesCacheKey(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations) {
        List<String> locations = new List<String>{source.toString()};
        for (MapApi.Location location : destinations) {
            locations.add(location.toString());
        }
        return getHash(CACHE_PREFIX_DISTANCES + mode.name() + String.join(locations, ';'));
    }
    
    /**
     * @description Used to get results from cache
     * @param sessionID
     * @param locationID
     * @param place
     * @return Place Wrapper
     **/
    public List<MapApi.LocationDistance> getDistances(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations) {
        try {
            String cacheKey = getDistancesCacheKey(mode, source, destinations);
            Cache.OrgPartition cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
            
            if (cachePartition.contains(cacheKey)) {
                List<MapApi.LocationDistance> cacheValue = (List<MapApi.LocationDistance>) cachePartition.get(cacheKey);
                return cacheValue;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return null;
    }
    
    /**
     * @description Used to set distance results from cache
     * @param mode
     * @param source
     * @param destinations
     * @param distances
     **/
    public void setDistances(MapApi.Mode mode, MapApi.Location source, MapApi.Location[] destinations, List<MapApi.LocationDistance> distances) {
        if (distances == null || distances.size() == 0) {
            return;
        }
        try {
            String cacheKey = getDistancesCacheKey(mode, source, destinations);
            Cache.OrgPartition cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
            cachePartition.put(cacheKey, distances, this.cacheTimeout, Cache.Visibility.ALL, true);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
    
    /**
     * @description Used to get distance results from cache
     * @param mode
     * @param source
     * @param destination
     * @return String
     **/
    private String getDirectionCacheKey(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination) {
        List<String> locations = new List<String>{source.toString(), destination.toString()};
        return getHash(CACHE_PREFIX_DIRECTION + mode.name() + String.join(locations, ';'));
    }
    
    public MapApi.Direction getDirection(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination) {
        try {
            String cacheKey = getDirectionCacheKey(mode, source, destination);
            Cache.OrgPartition cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
            
            if (cachePartition.contains(cacheKey)) {
                MapApi.Direction cacheValue = (MapApi.Direction) cachePartition.get(cacheKey);
                return cacheValue;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
        return null;
    }
    
    /**
     * @description Used to set direction from cache
     * @param mode
     * @param source
     * @param destination
     * @param direction
     **/
    public void setDirection(MapApi.Mode mode, MapApi.Location source, MapApi.Location destination, MapApi.Direction direction) {
        if (direction == null) {
            return;
        }
        try {
            String cacheKey = getDirectionCacheKey(mode, source, destination);
            Cache.OrgPartition cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
            cachePartition.put(cacheKey, direction, this.cacheTimeout, Cache.Visibility.ALL, true);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
        }
    }
}