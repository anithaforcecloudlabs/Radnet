public class Five9AnalyticsIntegration {
    public static final String CACHE_PARTITION = 'local.five9analytics';

    public static final String CACHE_LOCK_LOGIN_CALL = 'lock_login';
    public static final String CACHE_LOCK_INIT_WORKING_STATE = 'lock_working_state';
    public static final String CACHE_LOCK_SKILL_STAT_PREFIX = 'lock_skill_stat_';
    public static final String CACHE_LOCK_AGENT_SKILLS_PREFIX = 'lock_agent_skills_';
    public static final String CACHE_LOCK_GET_AGENTS = 'lock_get_agents';

    private static final String CACHE_LOGIN_SESSION = 'login_session';
    public static final String CACHE_STATISTIC_SKILL_PREFIX = 'stat_skill_';
    public static final String CACHE_AGENT_SKILLS_PREFIX = 'agent_skills_';
    public static final String CACHE_AGENT_ID_PREFIX = 'agent_id_';

    private static final String LOGIN_STATE_ACCEPT_NOTICE = 'ACCEPT_NOTICE';
    private static final String LOGIN_STATE_RELOGIN = 'RELOGIN';
    private static final String LOGIN_STATE_SELECT_SKILLS = 'SELECT_SKILLS';
    private static final String LOGIN_STATE_SELECT_STATION = 'SELECT_STATION';
    private static final String LOGIN_STATE_WORKING = 'WORKING';

    private static final String LOGIN_POLICY_FORCE_IN = 'ForceIn';
    private static final String LOGIN_POLICY_ATTACH_EXISTING = 'AttachExisting';

    private static final String STATION_TYPE = 'EMPTY';

    private static final String BASE_URL = 'https://app.five9.com';
    private static final String AUTH_PATH = 'appsvcs/rs/svc/auth/login';
    private static final String SUPERVISOR_PATH = 'supsvcs/rs/svc';

    private static final Integer CACHE_EXPIRY_LOGIN_SESSION = 3600;
    private static final Integer CACHE_EXPIRY_AGENT_SKILLS = 300;
    private static final Integer CACHE_EXPIRY_AGENT_SKILLS_DEFAULT = 3600;
    private static final Integer CACHE_EXPIRY_STATS = 10;
    private static final Integer CACHE_EXPIRY_STATS_DEFAULT = 300;
    private static final Integer CACHE_EXPIRY_AGENTS = 1800;
    private static final Integer CACHE_EXPIRY_AGENTS_DEFAULT = 7200;
    private static final Integer CACHE_EXPIRY_LOCK = 5;
    private static final Integer CACHE_EXPIRY_LOCK_DEFAULT = 300;
    private static final Integer CACHE_EXPIRY_AGENT_ID = 3600;

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
        public Boolean accepted;
        public String annotation;
        public String text;
        public String id;
    }

    public class SkillInfo {
        public String id;
        public String name;
        public Integer level;
        public Boolean active;
    }

    public class ChannelInfo {
        public Integer capacity;
        public Boolean acdMode;
    }

    public class AgentInfo {
        public String id;
        public String userName;
        public String firstName;
        public String lastName;
        public String fullName;
        public String email;
        public Boolean hasUserProfile;
        public Boolean canReceiveTransfer;
        public List<SkillInfo> skills;
        public List<String> availableChannels;
        public Map<String, ChannelInfo> enabledChannels;
    }

    public class QueuedVoicemailInfo {
        public String customer;
        public String campaignId;
        public Long audioDuration; // Voicemail audio record duration in milliseconds
        public Long queueDuration; // Voicemail queue waiting time in milliseconds
    }

    public class QueuedCallInfo {
        public String customer;
        public String customerName;
        public String campaignId;
        public String callType;
        public Integer priority;
        public Long queueDuration; // Voicemail queue waiting time in milliseconds
        public Boolean callback;
    }

    public class DetailedSnapshotInfo {
        public List<String> activeAgentsIds;
        public List<QueuedVoicemailInfo> inAcdQueueVoicemails;
        public List<QueuedVoicemailInfo> inProgressVoicemails;
        public Integer inQueueCallbackCount;
        public List<QueuedCallInfo> inQueueCalls;
        public List<String> loggedInAgentsIds;
        public Long maxQueueDuration;
        public List<String> notReadyForCallAgentsIds;
        public List<String> readyForCallAgentsIds;
        public List<String> onCallAgentsIds;
        public List<String> readyForChatAgentsIds;
        public List<String> readyForEmailAgentsIds;
        public List<String> readyForVoicemailAgentsIds;
        public Integer vivrCallbackCount;
        public Integer voicemailCount;
    }

    public class CacheLock {
        private Cache.OrgPartition cachePartition;
        private String cacheLockKey;

        public CacheLock(String key) {
            this.cachePartition = Cache.Org.getPartition(CACHE_PARTITION);

            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(key));
            this.cacheLockKey = EncodingUtil.convertToHex(hash);
        }

        public Boolean isLocked() {
            if (this.cachePartition.contains(cacheLockKey)) {
                Long lockSetTime = (Long) this.cachePartition.get(cacheLockKey);
                if (Datetime.now().getTime() - lockSetTime < CACHE_EXPIRY_LOCK * 1000) {
                    return true;
                }
                unlock();
            }
            return false;
        }

        public void lock() {
            this.cachePartition.put(cacheLockKey, Datetime.now().getTime(), CACHE_EXPIRY_LOCK_DEFAULT, Cache.Visibility.ALL, false);
        }

        public void unlock() {
            this.cachePartition.remove(cacheLockKey);
        }
    }

    private LoginResponse loginSession;
    private Cache.OrgPartition cachePartition;

    public Five9AnalyticsIntegration() {
        this.cachePartition = Cache.Org.getPartition(CACHE_PARTITION);
    }

    @TestVisible
    private String getHash(String v) {
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(v));
        return EncodingUtil.convertToHex(hash);
    }

    @TestVisible
    private void setSession(LoginResponse session) {
        this.loginSession = session;
    }

    @TestVisible
    private LoginResponse getSession() {
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
        CacheLock sessionLock = new CacheLock(CACHE_LOCK_LOGIN_CALL);
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
        if (
            loginResponse == null ||
            loginResponse.tokenId == null ||
            loginResponse.context == null ||
            loginResponse.context.farmId == null ||
            loginResponse.metadata == null ||
            loginResponse.metadata.dataCenters == null ||
            loginResponse.metadata.dataCenters.isEmpty() ||
            loginResponse.metadata.dataCenters[0].apiUrls == null ||
            loginResponse.metadata.dataCenters[0].apiUrls.isEmpty()
        ) {
            return null;
        }
        return loginResponse;
    }

    private String makeHttpRequest(String method, String endpoint, String body) {
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
    private String getLoginState(String userId) {
        String url = String.format('{0}/{1}/supervisors/{2}/login_state', new List<String>{ BASE_URL, SUPERVISOR_PATH, userId });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return null;
        }
        return responseBody.replaceAll('"', '');
    }

    @TestVisible
    private List<MaintenanceNoticeInfo> getMaintenanceNotices(String userId) {
        String url = String.format('{0}/{1}/supervisors/{2}/maintenance_notices', new List<String>{ BASE_URL, SUPERVISOR_PATH, userId });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return new List<MaintenanceNoticeInfo>();
        }
        List<MaintenanceNoticeInfo> notices = (List<MaintenanceNoticeInfo>) JSON.deserialize(responseBody, List<MaintenanceNoticeInfo>.class);
        return notices;
    }

    @TestVisible
    private MaintenanceNoticeInfo acceptMaintenanceNotice(String userId, String noticeId) {
        String url = String.format('{0}/{1}/supervisors/{2}/maintenance_notices/{3}/accept', new List<String>{ BASE_URL, SUPERVISOR_PATH, userId, noticeId });
        String responseBody = makeHttpRequest('PUT', url, null);
        if (responseBody == null) {
            return null;
        }
        MaintenanceNoticeInfo notice = (MaintenanceNoticeInfo) JSON.deserialize(responseBody, MaintenanceNoticeInfo.class);
        return notice;
    }

    @TestVisible
    private Boolean selectStation(String userId, String stationId, String stationType) {
        String url = String.format('{0}/{1}/supervisors/{2}/session_start?force=true', new List<String>{ BASE_URL, SUPERVISOR_PATH, userId });

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
    private void initializeWorkingState() {
        Integer retries = 10;
        while (retries > 0) {
            retries--;

            if (this.getSession() == null) {
                createSession(false);
                continue;
            }
            CacheLock workingStateLock = new CacheLock(CACHE_LOCK_INIT_WORKING_STATE);
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

    @TestVisible
    private AgentInfo getAgentById(String agentId) {
        String url = String.format('{0}/{1}/supervisors/{2}/agents/{3}?include=skills', new List<String>{ BASE_URL, SUPERVISOR_PATH, this.getSession().userId, agentId });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return null;
        }
        AgentInfo agent = (AgentInfo) JSON.deserialize(responseBody, AgentInfo.class);
        return agent;
    }

    @TestVisible
    private List<AgentInfo> getAllAgents() {
        String url = String.format('{0}/{1}/supervisors/{2}/agents', new List<String>{ BASE_URL, SUPERVISOR_PATH, this.getSession().userId });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return null;
        }
        List<AgentInfo> agent = (List<AgentInfo>) JSON.deserialize(responseBody, List<AgentInfo>.class);
        return agent;
    }

    @TestVisible
    private DetailedSnapshotInfo getDetailedSnapshotInfo(String skillId) {
        String url = String.format('{0}/{1}/supervisors/{2}/skills/{3}/snapshot', new List<String>{ BASE_URL, SUPERVISOR_PATH, this.getSession().userId, skillId });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return null;
        }
        DetailedSnapshotInfo snapshot = (DetailedSnapshotInfo) JSON.deserialize(responseBody, DetailedSnapshotInfo.class);
        return snapshot;
    }

    public class Stat {
        public Integer totalCalls;
        public Long longestWaitingCall;
        public Long updatedAt;

        public Stat() {
            this.totalCalls = 0;
            this.longestWaitingCall = 0;
            this.updatedAt = Datetime.now().getTime();
        }

        public Stat(Integer totalCalls, Long longestWaitingCall) {
            this.totalCalls = totalCalls;
            this.longestWaitingCall = longestWaitingCall;
            this.updatedAt = Datetime.now().getTime();
        }

        public void aggregate(Stat other) {
            this.totalCalls += other.totalCalls;
            this.longestWaitingCall = Math.max(this.longestWaitingCall, other.longestWaitingCall);
        }
    }

    @TestVisible
    private Stat getSkillStat(String skillId) {
        String cacheKey = getHash(CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Stat stat;
        if (cachePartition.contains(cacheKey)) {
            stat = (Stat) cachePartition.get(cacheKey);
        }

        if (stat == null || (Datetime.now().getTime() - stat.updatedAt) > CACHE_EXPIRY_STATS * 1000) {
            CacheLock cacheLock = new CacheLock(CACHE_LOCK_SKILL_STAT_PREFIX + skillId);
            if (cacheLock.isLocked()) {
                if (stat != null) {
                    return stat;
                }
                return new Stat();
            }
            cacheLock.lock();

            DetailedSnapshotInfo info = getDetailedSnapshotInfo(skillId);
            Integer totalCalls = info.inQueueCalls.size();
            Long longestWaitingCall = info.maxQueueDuration;
            stat = new Stat(totalCalls, longestWaitingCall);
            cachePartition.put(cacheKey, stat, CACHE_EXPIRY_STATS_DEFAULT, Cache.Visibility.ALL, false);

            cacheLock.unlock();
        }
        return stat;
    }

    public class AgentSkills {
        public List<SkillInfo> skills;
        public Long updatedAt;

        public AgentSkills() {
            this.skills = new List<SkillInfo>();
            this.updatedAt = Datetime.now().getTime();
        }

        public AgentSkills(List<SkillInfo> skills) {
            this.skills = skills;
            this.updatedAt = Datetime.now().getTime();
        }
    }

    @TestVisible
    private AgentSkills getAgentSkills(String agentId) {
        String cacheKey = getHash(CACHE_AGENT_SKILLS_PREFIX + agentId);
        AgentSkills skills;
        if (cachePartition.contains(cacheKey)) {
            skills = (AgentSkills) cachePartition.get(cacheKey);
        }

        if (skills == null || (Datetime.now().getTime() - skills.updatedAt) > CACHE_EXPIRY_AGENT_SKILLS * 1000) {
            CacheLock cacheLock = new CacheLock(CACHE_LOCK_AGENT_SKILLS_PREFIX + agentId);
            if (cacheLock.isLocked()) {
                if (skills != null) {
                    return skills;
                }
                return new AgentSkills();
            }
            cacheLock.lock();

            AgentInfo info = getAgentById(agentId);
            skills = new AgentSkills(info.skills);
            cachePartition.put(cacheKey, skills, CACHE_EXPIRY_AGENT_SKILLS_DEFAULT, Cache.Visibility.ALL, false);

            cacheLock.unlock();
        }
        return skills;
    }

    public Map<String, Stat> getAgentStat(String agentId) {
        Map<String, Stat> agentStats = new Map<String, Stat>();
        Stat agentAggregateStat = new Stat();
        try {
            if (this.getSession() == null) {
                initializeWorkingState();
                agentStats.put('combined', agentAggregateStat);
                return agentStats;
            }
            AgentSkills skills = getAgentSkills(agentId);
            for (SkillInfo skill : skills.skills) {
                Stat stat = getSkillStat(skill.id);
                agentStats.put(skill.name, stat);
                agentAggregateStat.aggregate(stat);
            }
        } catch (Exception e) {
            System.debug('Error in fetching agent stats: ' + e.getMessage());
        }
        agentStats.put('combined', agentAggregateStat);
        return agentStats;
    }

    public String getAgentIDForEmail(String email) {
        String agentID;
        try {
            String cacheKey = getHash(CACHE_AGENT_ID_PREFIX + email);
            if (cachePartition.contains(cacheKey)) {
                agentID = (String) cachePartition.get(cacheKey);
                return agentID;
            }

            if (this.getSession() == null) {
                initializeWorkingState();
                return agentID;
            }

            CacheLock cacheLock = new CacheLock(CACHE_LOCK_GET_AGENTS);
            if (cacheLock.isLocked()) {
                return null;
            }
            cacheLock.lock();

            List<AgentInfo> agents = getAllAgents();
            for (AgentInfo agent : agents) {
                String agentCacheKey = getHash(CACHE_AGENT_ID_PREFIX + agent.email);
                if (agent.id != null) {
                    cachePartition.put(agentCacheKey, agent.id, CACHE_EXPIRY_AGENT_ID, Cache.Visibility.ALL, false);
                }

                if (agent.email.equalsIgnoreCase(email)) {
                    agentID = agent.id;
                }
            }

            cacheLock.unlock();
        } catch (Exception e) {
            System.debug('Error in fetching agent id: ' + e.getMessage());
        }
        return agentID;
    }
}