/**
 * @description    : Class used for map confriguration from custom metadata
 *
 * Created Date    : 15/05/2024
 *
 * @JIRA Id        : CC-232, CC-233
 **/
public with sharing class MapConfigFromCustomMetadata implements MapConfig {

    private static final Integer DEFAULT_CACHE_TIMEOUT = 300;
	/**
    * @description Method used to return Map_Setting__mdt
    * @return Map_Setting__mdt
    **/
    private Map_Setting__mdt getMapSettings() {
        List<Map_Setting__mdt> settings = [SELECT CacheTimeout__c, SearchHelpers__c, DistancesHelpers__c, DirectionHelpers__c FROM Map_Setting__mdt WHERE Label = 'Default'];
        if (settings.size() > 0) {
            return settings[0];
        }
        return null;
    }

    /**
    * @description Method used for Cache timeout
    **/
    public Integer getCacheTimeout() {
        try {
            List<Map_Setting__mdt> settings = [SELECT CacheTimeout__c FROM Map_Setting__mdt WHERE Label = 'Default'];
            if (settings.size() > 0) {
                return settings[0].CacheTimeout__c.intValue();
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return DEFAULT_CACHE_TIMEOUT;
    }

    /**
    * @description Method used to get API token
    * @return String
    **/
    private String getApiKeyForHelper(MapApi.HelperType helper) {
        List<Map_Helper_Setting__mdt> settings = [SELECT Token__c FROM Map_Helper_Setting__mdt WHERE Label = :helper.name()];
        if (settings.size() > 0) {
            return settings[0].Token__c;
        }
        return '';
    }

    @TestVisible
    private List<MapApi.HelperType> convertToHelpers(String[] helperSettings) {
        List<MapApi.HelperType> helpers = new List<MapApi.HelperType>();
        for (String helperSetting : helperSettings) {
            helpers.add(MapApi.HelperType.valueOf(helperSetting));
        }
        return helpers;
    }

    /**
    * @description Method used to search helpers
    * @return List<MapApi.HelperType>
    **/
    public List<MapApi.HelperType> getSearchHelpers() {
        Map_Setting__mdt mapSettings = getMapSettings();
        try {
            if (mapSettings != null) {
                return convertToHelpers(mapSettings.SearchHelpers__c.split(','));
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return new List<MapApi.HelperType>();
    }

    /**
    * @description Method used to Distance helpers
    * @return List<MapApi.HelperType>
    **/
    public List<MapApi.HelperType> getDistancesHelpers() {
        Map_Setting__mdt mapSettings = getMapSettings();
        try {
            if (mapSettings != null) {
                return convertToHelpers(mapSettings.DistancesHelpers__c.split(','));
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return new List<MapApi.HelperType>();
    }

    /**
    * @description Method used to direction helpers
    * @return List<MapApi.HelperType>
    **/
    public List<MapApi.HelperType> getDirectionHelpers() {
        Map_Setting__mdt mapSettings = getMapSettings();
        try {
            if (mapSettings != null) {
                return convertToHelpers(mapSettings.DirectionHelpers__c.split(','));
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return new List<MapApi.HelperType>();
    }

    public MapHelper getMapHelper(MapApi.HelperType helper) {
        String apiKey = getApiKeyForHelper(helper);
        switch on helper {
            when CACHE {
                return new MapCache();
            }
            when LOCATIONIQ {
                return new MapLocationIQHelper(apiKey);
            }
            when MAPBOX {
                return new MapBoxHelper(apiKey);
            }
            when OSRM {
                return new MapOsrmHelper();
            }
            when GEOAPIFY {
                return new MapGeoapifyHelper(apiKey);
            }
        }
        throw new MapApiException('invalid helper');
    }
}