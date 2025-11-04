/*
* ***************************************************************************************************************************
* Apex Class Name - Five9AgentIntegration
* Version - 0.1
* Created Date - 21-Jan-2024
* @description       : Agent Integration class for all Five9 BYOT functions. Child of Five9BaseIntegration class
*                       with client type as AGENT
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1501                   21-Jan-2025         Enhancements for all Five9 BYOT functions
* ************************************************************************************************************************************
*/
public class Five9AgentIntegration extends Five9BaseIntegration {
    public static final String CACHE_LOCK_SPEED_DIALS = 'lock_speed_dials_agent';

    public static final String CACHE_SPEED_DIALS = 'speed_dials_agent';

    private static final Integer CACHE_EXPIRY_SPEED_DIALS = 3600;
    private static final Integer CACHE_EXPIRY_SPEED_DIALS_DEFAULT = 7200;

    public class SpeedDialInfo {
        public String id;
        public String name;
        public String description;
        public String phoneNumber;
    }

    public Five9AgentIntegration() {
        super(Five9BaseIntegration.ClientType.AGENT);
    }

    @TestVisible
    private List<SpeedDialInfo> getAllSpeedDials() {
        String url = String.format('{0}/orgs/{1}/speed_dials', new List<String>{ getBaseUrl(), this.getSession().orgId });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return null;
        }
        responseBody = responseBody.replaceAll('number', 'phoneNumber');
        List<SpeedDialInfo> speedDials = (List<SpeedDialInfo>) JSON.deserialize(responseBody, List<SpeedDialInfo>.class);
        return speedDials;
    }

    public List<SpeedDialInfo> getSpeedDials() {
        System.debug('In getSpeedDials');
        List<SpeedDialInfo> speedDials = new List<SpeedDialInfo>();
        try {
            String cacheKey = getHash(CACHE_SPEED_DIALS);
            if (getCachePartition().contains(cacheKey)) {
                speedDials = (List<SpeedDialInfo>) getCachePartition().get(cacheKey);
                return speedDials;
            }

            if (this.getSession() == null) {
                System.debug('before ini');
                initializeWorkingState();
                return speedDials;
            }

            CacheLock cacheLock = new CacheLock(getCachePartitionName(), CACHE_LOCK_SPEED_DIALS);
            if (cacheLock.isLocked()) {
                return speedDials;
            }
            cacheLock.lock();
			System.debug('before getAllSpeedDials');
            List<SpeedDialInfo> allSpeedDials = getAllSpeedDials();
            if (allSpeedDials != null) {
                speedDials = allSpeedDials;
                getCachePartition().put(cacheKey, allSpeedDials, CACHE_EXPIRY_SPEED_DIALS, Cache.Visibility.ALL, false);
            }

            cacheLock.unlock();
        } catch (Exception e) {
            System.debug('Error in fetching speed dials: ' + e.getMessage());
        }
        return speedDials;
    }
}