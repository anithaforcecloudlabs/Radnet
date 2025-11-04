/*
* ***************************************************************************************************************************
* Apex Class Name - Five9BaseIntegration
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
public abstract class Five9BaseIntegration {
    private static final String CACHE_PARTITION = 'local.five9analytics';

    public static final String CACHE_LOCK_LOGIN_CALL = 'lock_login';
    public static final String CACHE_LOCK_INIT_WORKING_STATE = 'lock_working_state';

    private static final String CACHE_LOGIN_SESSION = 'login_session';
    private static final Integer CACHE_EXPIRY_LOGIN_SESSION = 3600;

    private static final String LOGIN_STATE_ACCEPT_NOTICE = 'ACCEPT_NOTICE';
    private static final String LOGIN_STATE_RELOGIN = 'RELOGIN';
    private static final String LOGIN_STATE_SELECT_SKILLS = 'SELECT_SKILLS';
    private static final String LOGIN_STATE_SELECT_STATION = 'SELECT_STATION';
    private static final String LOGIN_STATE_WORKING = 'WORKING';

    private static final String LOGIN_POLICY_FORCE_IN = 'ForceIn';
    private static final String LOGIN_POLICY_ATTACH_EXISTING = 'AttachExisting';

    private static final String STATION_TYPE = 'EMPTY';

    private static final String BASE_URL = System.label.Five9Url;
    private static final String AUTH_PATH = 'appsvcs/rs/svc/auth/login';
    private static final String SUPERVISOR_PATH = 'supsvcs/rs/svc';
    private static final String AGENT_PATH = 'appsvcs/rs/svc';

    public enum ClientType {
        AGENT,
        SUPERVISOR
    }

    public class PasswordCredentials {
        public String username;
        public String password;

        public PasswordCredentials(String username, String password) {
            this.username = username;
            this.password = password;
        }
    }

    public class LoginRequest {
        PasswordCredentials passwordCredentials;
        String policy;

        public LoginRequest(PasswordCredentials passwordCredentials, String policy) {
            this.passwordCredentials = passwordCredentials;
            this.policy = policy;
        }
    }

    public class LoginResponse {
        public String tokenId;
        public String sessionId;
        public String orgId;
        public String userId;
        public Context context;
        public Metadata metadata;
    }

    public class Context {
        public String cloudClientUrl;
        public String cloudTokenUrl;
        public String farmId;
    }

    public class DataCenter {
        public String name;
        public List<UrlInfo> uiUrls;
        public List<UrlInfo> apiUrls;
        public List<UrlInfo> loginUrls;
        public Boolean active;
    }

    public class UrlInfo {
        public String host;
        public String port;
        public String routeKey;
        public String version;
    }

    public class Metadata {
        public String freedomUrl;
        public List<DataCenter> dataCenters;
    }

    public class SelectStationRequest {
        public String stationId;
        public String stationType;

        public SelectStationRequest(String stationId, String stationType) {
            this.stationId = stationId;
            this.stationType = stationType;
        }
    }

    public class MaintenanceNoticeInfo {
        public String id;
        public String text;
        public String annotation;
        public Boolean accepted;
    }

    private Cache.OrgPartition cachePartition;
    private ClientType clientType;
    private LoginResponse loginSession;

    public Five9BaseIntegration(ClientType clientType) {
        this.cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
        this.clientType = clientType;
    }

    @TestVisible
    protected Cache.OrgPartition getCachePartition() {
        return cachePartition;
    }

    @TestVisible
    protected String getCachePartitionName() {
        return CACHE_PARTITION;
    }

    @TestVisible
    protected String getBaseUrl() {
        switch on clientType {
            when AGENT {
                return String.format('{0}/{1}', new List<String>{ BASE_URL, AGENT_PATH });
            }
            when else {
                return String.format('{0}/{1}', new List<String>{ BASE_URL, SUPERVISOR_PATH });
            }
        }
    }

    @TestVisible
    protected String getHash(String v) {
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(v));
        return EncodingUtil.convertToHex(hash);
    }

    @TestVisible
    private void setSession(LoginResponse session) {
        this.loginSession = session;
    }

    @TestVisible
    protected LoginResponse getSession() {
        if (this.loginSession != null) {
            return loginSession;
        }

        String cacheKey = getHash(CACHE_LOGIN_SESSION);
        if (cachePartition.contains(cacheKey)) {
            LoginResponse cachedSession = (LoginResponse) cachePartition.get(cacheKey);
            return cachedSession;
        }
        return null;
    }

    @TestVisible
    private void createSession(Boolean force) {
        CacheLock sessionLock = new CacheLock(CACHE_PARTITION, CACHE_LOCK_LOGIN_CALL);
        if (sessionLock.isLocked()) {
            return;
        }
        sessionLock.lock();

        Five9_Settings__mdt credentials = Five9_Settings__mdt.getInstance('Default');
        try {
            LoginResponse loginResponse = login(credentials.Username__c, credentials.Password__c, force);
            if (loginResponse != null) {
                String cacheKey = getHash(CACHE_LOGIN_SESSION);
                cachePartition.put(cacheKey, loginResponse, CACHE_EXPIRY_LOGIN_SESSION, Cache.Visibility.ALL, false);
                this.loginSession = loginResponse;
            }
        } catch (Exception e) {
            System.debug('Error in create_session: ' + e.getMessage());
        }

        sessionLock.unlock();
    }

    @TestVisible
    private LoginResponse login(String username, String password, Boolean force) {
        String url = String.format('{0}/{1}', new List<String>{ BASE_URL, AUTH_PATH });
        System.debug('five9_api: ' + url);

        PasswordCredentials credentials = new PasswordCredentials(username, password);
        LoginRequest loginRequest = new LoginRequest(credentials, force ? LOGIN_POLICY_FORCE_IN : LOGIN_POLICY_ATTACH_EXISTING);

        String requestBody = JSON.serialize(loginRequest);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);

        HttpResponse response = http.send(request);
        System.debug('five_api_response: ' + response.getBody());

        if (response.getStatusCode() != 200) {
            return null;
        }

        LoginResponse loginResponse = (LoginResponse) JSON.deserialize(response.getBody(), LoginResponse.class);
        if (loginResponse == null || loginResponse.tokenId == null || loginResponse.context == null || loginResponse.context.farmId == null || loginResponse.metadata == null) {
            return null;
        }
        return loginResponse;
    }

    protected String makeHttpRequest(String method, String endpoint, String body) {
        if (this.getSession() == null) {
            return null;
        }

        System.debug('five9_api: ' + endpoint);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Authorization', String.format('Bearer-{0}', new List<String>{ this.getSession().tokenId }));
        request.setHeader('farmId', this.getSession().context.farmId);

        if (body != null) {
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
        }

        HttpResponse response = http.send(request);
        System.debug('five_api_response: ' + response.getBody());

        if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
            return response.getBody();
        }
        if (response.getStatusCode() == 401) {
            createSession(false);
            return null;
        }
        if (response.getStatusCode() == 435) {
            initializeWorkingState();
            return null;
        }
        return null;
    }

    @TestVisible
    private String getLoginBaseUrl(String userId) {
        switch on clientType {
            when AGENT {
                return String.format('{0}/{1}/agents/{2}', new List<String>{ BASE_URL, AGENT_PATH, userId });
            }
            when else {
                return String.format('{0}/{1}/supervisors/{2}', new List<String>{ BASE_URL, SUPERVISOR_PATH, userId });
            }
        }
    }

    @TestVisible
    private String getLoginState(String userId) {
        String url = String.format('{0}/login_state', new List<String>{ getLoginBaseUrl(userId) });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return null;
        }
        return responseBody.replaceAll('"', '');
    }

    @TestVisible
    private List<MaintenanceNoticeInfo> getMaintenanceNotices(String userId) {
        String url = String.format('{0}/maintenance_notices', new List<String>{ getLoginBaseUrl(userId) });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return new List<MaintenanceNoticeInfo>();
        }
        List<MaintenanceNoticeInfo> notices = (List<MaintenanceNoticeInfo>) JSON.deserialize(responseBody, List<MaintenanceNoticeInfo>.class);
        return notices;
    }

    @TestVisible
    private MaintenanceNoticeInfo acceptMaintenanceNotice(String userId, String noticeId) {
        String url = String.format('{0}/maintenance_notices/{3}/accept', new List<String>{ getLoginBaseUrl(userId), noticeId });
        String responseBody = makeHttpRequest('PUT', url, null);
        if (responseBody == null) {
            return null;
        }
        MaintenanceNoticeInfo notice = (MaintenanceNoticeInfo) JSON.deserialize(responseBody, MaintenanceNoticeInfo.class);
        return notice;
    }

    @TestVisible
    private Boolean selectStation(String userId, String stationId, String stationType) {
        String url = String.format('{0}/session_start?force=true', new List<String>{ getLoginBaseUrl(userId) });

        SelectStationRequest selectStationRequest = new SelectStationRequest(stationId, stationType);

        String requestBody = JSON.serialize(selectStationRequest);
        String responseBody = makeHttpRequest('PUT', url, requestBody);
        if (responseBody == null) {
            return false;
        }
        return true;
    }

    @TestVisible
    private Boolean checkWorkingState() {
        try {
            String loginState = getLoginState(this.getSession().userId);
            if (loginState == null) {
                return false;
            }
            if (loginState == LOGIN_STATE_RELOGIN) {
                createSession(true);
                return false;
            }
            if (loginState == LOGIN_STATE_SELECT_STATION) {
                selectStation(this.getSession().userId, '', STATION_TYPE);
                return false;
            }
            if (loginState == LOGIN_STATE_ACCEPT_NOTICE) {
                List<MaintenanceNoticeInfo> notices = getMaintenanceNotices(this.getSession().userId);
                for (MaintenanceNoticeInfo notice : notices) {
                    if (!notice.accepted) {
                        acceptMaintenanceNotice(this.getSession().userId, notice.id);
                    }
                }
                return false;
            }
            if (loginState == LOGIN_STATE_WORKING) {
                return true;
            }
        } catch (Exception e) {
            System.debug('Error in check_working_state: ' + e.getMessage());
        }
        return false;
    }

    @TestVisible
    protected void initializeWorkingState() {
        Integer retries = 10;
        while (retries > 0) {
            retries--;

            if (this.getSession() == null) {
                createSession(false);
                continue;
            }
            CacheLock workingStateLock = new CacheLock(CACHE_PARTITION, CACHE_LOCK_INIT_WORKING_STATE);
            if (workingStateLock.isLocked()) {
                continue;
            }
            workingStateLock.lock();
            Boolean isWorkingState = checkWorkingState();
            workingStateLock.unlock();

            if (isWorkingState) {
                break;
            }
        }
    }
}