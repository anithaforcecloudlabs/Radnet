/*
* ***************************************************************************************************************************
* Apex Class Name - Five9SupervisorIntegration
* Version - 0.1
* Created Date - 21-Jan-2024
* @description       : Supervisor Integration class for all Five9 BYOT functions. Child of Five9BaseIntegration class
*                       with client type as SUPERVISOR
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1501                   21-Jan-2025         Enhancements for all Five9 BYOT functions
* ************************************************************************************************************************************
*/
public class Five9SupervisorIntegration extends Five9BaseIntegration {
    public static final String CACHE_LOCK_SKILL_STAT_PREFIX = 'lock_skill_stat_';
    public static final String CACHE_LOCK_AGENT_SKILLS_PREFIX = 'lock_agent_skills_';
    public static final String CACHE_LOCK_GET_AGENTS = 'lock_get_agents';

    public static final String CACHE_STATISTIC_SKILL_PREFIX = 'stat_skill_';
    public static final String CACHE_AGENT_SKILLS_PREFIX = 'agent_skills_';
    public static final String CACHE_AGENT_ID_PREFIX = 'agent_id_';

    private static final Integer CACHE_EXPIRY_AGENT_SKILLS = 300;
    private static final Integer CACHE_EXPIRY_AGENT_SKILLS_DEFAULT = 3600;
    private static final Integer CACHE_EXPIRY_STATS = 10;
    private static final Integer CACHE_EXPIRY_STATS_DEFAULT = 300;
    private static final Integer CACHE_EXPIRY_AGENTS = 1800;
    private static final Integer CACHE_EXPIRY_AGENTS_DEFAULT = 7200;
    private static final Integer CACHE_EXPIRY_AGENT_ID = 3600;

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

    public Five9SupervisorIntegration() {
        super(Five9BaseIntegration.ClientType.SUPERVISOR);
    }

    @TestVisible
    private AgentInfo getAgentById(String agentId) {
        String url = String.format('{0}/supervisors/{1}/agents/{2}?include=skills', new List<String>{ getBaseUrl(), this.getSession().userId, agentId });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return null;
        }
        AgentInfo agent = (AgentInfo) JSON.deserialize(responseBody, AgentInfo.class);
        return agent;
    }

    @TestVisible
    private List<AgentInfo> getAllAgents() {
        String url = String.format('{0}/supervisors/{1}/agents', new List<String>{ getBaseUrl(), this.getSession().userId });
        String responseBody = makeHttpRequest('GET', url, null);
        if (responseBody == null) {
            return null;
        }
        List<AgentInfo> agent = (List<AgentInfo>) JSON.deserialize(responseBody, List<AgentInfo>.class);
        return agent;
    }

    @TestVisible
    private DetailedSnapshotInfo getDetailedSnapshotInfo(String skillId) {
        String url = String.format('{0}/supervisors/{1}/skills/{2}/snapshot', new List<String>{ getBaseUrl(), this.getSession().userId, skillId });
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
        if (getCachePartition().contains(cacheKey)) {
            stat = (Stat) getCachePartition().get(cacheKey);
        }

        if (stat == null || (Datetime.now().getTime() - stat.updatedAt) > CACHE_EXPIRY_STATS * 1000) {
            CacheLock cacheLock = new CacheLock(getCachePartitionName(), CACHE_LOCK_SKILL_STAT_PREFIX + skillId);
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
            getCachePartition().put(cacheKey, stat, CACHE_EXPIRY_STATS_DEFAULT, Cache.Visibility.ALL, false);

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
        if (getCachePartition().contains(cacheKey)) {
            skills = (AgentSkills) getCachePartition().get(cacheKey);
        }

        if (skills == null || (Datetime.now().getTime() - skills.updatedAt) > CACHE_EXPIRY_AGENT_SKILLS * 1000) {
            CacheLock cacheLock = new CacheLock(getCachePartitionName(), CACHE_LOCK_AGENT_SKILLS_PREFIX + agentId);
            if (cacheLock.isLocked()) {
                if (skills != null) {
                    return skills;
                }
                return new AgentSkills();
            }
            cacheLock.lock();

            AgentInfo info = getAgentById(agentId);
            skills = new AgentSkills(info.skills);
            getCachePartition().put(cacheKey, skills, CACHE_EXPIRY_AGENT_SKILLS_DEFAULT, Cache.Visibility.ALL, false);

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
            Integer iterator = 0;
            for (SkillInfo skill : skills.skills) {
                Stat stat = getSkillStat(skill.id);
                agentStats.put(skill.name, stat);
                agentAggregateStat.aggregate(stat);
                iterator += 1;
                if(iterator==90){
                    break;
                }
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
            if (getCachePartition().contains(cacheKey)) {
                agentID = (String) getCachePartition().get(cacheKey);
                return agentID;
            }
            if (this.getSession() == null) {
                initializeWorkingState();
                return agentID;
            }
            CacheLock cacheLock = new CacheLock(getCachePartitionName(), CACHE_LOCK_GET_AGENTS);
            if (cacheLock.isLocked()) {
                return null;
            }
            cacheLock.lock();
            List<AgentInfo> agents = getAllAgents();
            for (AgentInfo agent : agents) {
                String agentCacheKey = getHash(CACHE_AGENT_ID_PREFIX + agent.email);
                if (agent.id != null) {
                    getCachePartition().put(agentCacheKey, agent.id, CACHE_EXPIRY_AGENT_ID, Cache.Visibility.ALL, false);
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