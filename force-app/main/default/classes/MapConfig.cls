public interface MapConfig {
    Integer getCacheTimeout();
    
    List<MapApi.HelperType> getSearchHelpers();

    List<MapApi.HelperType> getDistancesHelpers();

    List<MapApi.HelperType> getDirectionHelpers();

    MapHelper getMapHelper(MapApi.HelperType helper);
}