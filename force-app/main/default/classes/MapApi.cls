/**
 * @description    : Class used to call LocationIQ API for Site search and send values to DH_SiteSearch lwc component
 *
 * Created Date    : 15/05/2024
 *
 * @JIRA Id        : CC-232, CC-233
 **/
public with sharing class MapApi {

    public enum HelperType {
        CACHE,
        LOCATIONIQ,
        MAPBOX,
        OSRM,
        GEOAPIFY
    }

    public enum Mode {
        DRIVE,
        TRANSIT,
        MOTORBIKE,
        BICYCLE,
        WALK
    }
	/**
     * @description Class to handle Locations
     **/
    public class Location {
        @AuraEnabled public Double latitude { get; set; }
        @AuraEnabled public Double longitude { get; set; }

        public override String toString() {
            return String.format('{0},{1}', new List<Object>{longitude, latitude});
        }
		public Location() {}
        public Location(Double latitude, Double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }

        public Location(Decimal latitude, Decimal longitude) {
            this.latitude = Double.valueOf(latitude);
            this.longitude = Double.valueOf(longitude);
        }

        public Location(String latitude, String longitude) {
            this.latitude = Double.valueOf(latitude);
            this.longitude = Double.valueOf(longitude);
        }
    }
	/**
    * @description Class to handle Places
    **/
    public class Place {
        @AuraEnabled public String id;
        @AuraEnabled public String display_name;
        @AuraEnabled public Location location;
        
		public Place(String id, String display_name, Location location) {
            this.id = id;
            this.display_name = display_name;
            this.location = location;
		}

        public Place(String id, String display_name) {
            this.id = id;
            this.display_name = display_name;
		}

        public String getHash() {
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(this.id + '__' + this.display_name));
            return EncodingUtil.convertToHex(hash);
        }
    }
	/**
    * @description Wrapper class to handle Location distances
    **/
    public class LocationDistance {
        @AuraEnabled public Location source;
        @AuraEnabled public Location destination;
        @AuraEnabled public Double distance;
        @AuraEnabled public Double duration;

        public LocationDistance(Location source, Location destination, Double distance, Double duration) {
            this.source = source;
            this.destination = destination;
			this.distance = distance;
            this.duration = duration;
		}
    }
	/**
    * @description Wrapper class to handle GeoJSON
   	**/
    public class GeoJSON {
        @AuraEnabled public List<Double[]> coordinates;
        @AuraEnabled public String type;
    }
	/**
    * @description Wrapper class to handle Route
    **/
    public class Route {
        @AuraEnabled public GeoJSON geometry;
        @AuraEnabled public Double distance;
        @AuraEnabled public Double duration;

        public Route(GeoJSON geometry, Double distance, Double duration) {
            this.geometry = geometry;
            this.distance = distance;
            this.duration = duration;
        }
    }
	/**
    * @description Wrapper class to handle Direction
    **/
    public class Direction {
        @AuraEnabled public Location source;
        @AuraEnabled public Location destination;
        @AuraEnabled public List<Route> routes;

        public Direction(Location source, Location destination, List<Route> routes) {
			this.source = source;
            this.destination = destination;
            this.routes = routes;
		}
    }

    @TestVisible
    private static MapConfig mapConfig = new MapConfigFromCustomMetadata();

    /**
    * @description (Autocomplete API)Method used to take string address as parameter and return list of aaddresses that matches input text using Autocomplete API
    * @param sessionID
    * @param query (Address string)
    * @return List<Place> Wrapper
    **/
    @AuraEnabled
    public static List<Place> searchPlaces(String sessionID, String query) {
        try {
            sessionID = (sessionID=='')?UserInfo.getSessionId():sessionID;
            List<Place> result = null;
            for (HelperType helper : mapConfig.getSearchHelpers()) {
                try {
                    result = mapConfig.getMapHelper(helper).searchPlaces(sessionID, query);
                    if (result != null && helper != HelperType.CACHE) {
                        MapCache cache = new MapCache();
                        cache.setSearchPlaces(sessionID, query, result);
                    }
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
                }
                if (result != null) {
                    return result;
                }
            }
            throw new MapApiException('no result');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description (Autocomplete API) Method used to take locationId as parameter and return place that matches locationID using Autocomplete API
    * @param sessionID
    * @param locationID
    * @return Place Wrapper
    **/
    @AuraEnabled
    public static Place getPlaceByID(String sessionID, String locationID) {
        try {
            Place result = null;
            String[] locations = locationID.split('_', 2);
            String helperLocationID = locations[1];
            String helperName = locations[0];

            HelperType[] helpers = new HelperType[]{HelperType.CACHE, HelperType.valueOf(helperName)};
            if (!mapConfig.getSearchHelpers().contains(HelperType.CACHE)) {
                helpers = new HelperType[]{HelperType.valueOf(helperName)};
            }

            for (HelperType helper : helpers) {
                try {
                    result = mapConfig.getMapHelper(helper).getPlaceByID(sessionID, helperLocationID);
                    if (result != null && helper != HelperType.CACHE) {
                        MapCache cache = new MapCache();
                        cache.setPlaceByID(sessionID, helperLocationID, result);
                    }
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
                }
                if (result != null) {
                    return result;
                }
            }
            throw new MapApiException('no result');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description (Matrix API) Method to take source and destinations coordinates and return distance and duration list from single source to multiple destinations using Matrix API
    * @param source
    * @param destinations
    * @return List<LocationDistance>
    **/
    @AuraEnabled
    public static List<LocationDistance> getDistances(Location source, Location[] destinations) {
        Mode mode = Mode.DRIVE;
        try {
            List<LocationDistance> result = null;
            for (HelperType helper : mapConfig.getDistancesHelpers()) {
                try {
                    result = mapConfig.getMapHelper(helper).getDistances(mode, source, destinations);
                    if (result != null && helper != HelperType.CACHE) {
                        MapCache cache = new MapCache();
                        cache.setDistances(mode, source, destinations, result);
                    }
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
                }
                if (result != null) {
                    return result;
                }
            }
            throw new MapApiException('no result');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description (Direction API) Method used to take source and destination coordinates as parameter and return coordinates list to show direction on the map using Direction API
    * @param source
    * @param destination
    * @return Direction Wrapper
    **/
    @AuraEnabled
    public static Direction getDirection(Location source, Location destination) {
        Mode mode = Mode.DRIVE;
        try {
            Direction result = null;
            for (HelperType helper : mapConfig.getDirectionHelpers()) {
                try {
                    result = mapConfig.getMapHelper(helper).getDirection(mode, source, destination);
                    if (result != null && helper != HelperType.CACHE) {
                        MapCache cache = new MapCache();
                        cache.setDirection(mode, source, destination, result);
                    }
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error'+ e.getMessage()+' at line no: '+e.getLineNumber());
                }
                if (result != null) {
                    return result;
                }
            }
            throw new MapApiException('no result');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}