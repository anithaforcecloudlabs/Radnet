/*
* ***************************************************************************************************************************
* Apex Class Name - Five9SupervisorIntegrationTest
* Version - 0.1
* Created Date - 21-Jan-2024
* @description       : Test class for Five9SupervisorIntegration
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1501                   21-Jan-2025         Added multiple test methods to cover Five9SupervisorIntegration.
* ************************************************************************************************************************************
*/
@IsTest
public class Five9SupervisorIntegrationTest {
    static Five9SupervisorIntegration getAuthenticatedFive9Client() {
        Five9SupervisorIntegration five9integration = new Five9SupervisorIntegration();
        String data = '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}';
        Five9BaseIntegration.LoginResponse loginResponse = (Five9BaseIntegration.LoginResponse) JSON.deserialize(data, Five9BaseIntegration.LoginResponse.class);
        five9integration.setSession(loginResponse);
        return five9integration;
    }

    @IsTest
    static void testGetAgentById() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/agents',
            200,
            '{"id":"4892647","userName":"nishant.shelar@radnet.com","firstName":"Nishant","lastName":"Shelar","fullName":"Nishant Shelar","email":"nishant.shelar@radnet.com","hasUserProfile":false,"canReceiveTransfer":true,"skills":[{"id":"12","name":"jav_skills_set","level":1,"active":true}],"availableChannels":["VOICE_MAIL","CALL"],"enabledChannels":{"VOICE_MAIL":{"capacity":1,"acdMode":true},"CALL":{"capacity":1,"acdMode":false}}}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        Five9SupervisorIntegration.AgentInfo response = five9integration.getAgentById('4892647');

        Assert.areEqual('4892647', response.id, 'id must match');
        Assert.areEqual('nishant.shelar@radnet.com', response.email, 'email must match');
        Assert.areNotEqual(null, response.skills, 'must return skills');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentByIdFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/agents', 500, '{"five9ExceptionDetail":{"timestamp":1726129453556,"errorCode":435,"message":"invalid state"}}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        Five9SupervisorIntegration.AgentInfo response = five9integration.getAgentById('4892647');
        Assert.areEqual(null, response, 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetDetailedSnapshotInfo() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/snapshot',
            200,
            '{"loggedInAgentsIds":["4892647"],"activeAgentsIds":["4892647"],"onCallAgentsIds":[],"readyForCallAgentsIds":[],"notReadyForCallAgentsIds":["4892647"],"readyForVoicemailAgentsIds":[],"readyForChatAgentsIds":[],"readyForEmailAgentsIds":[],"inQueueCalls":[{"customer":"7185506374","customerName":"","campaignId":"22","callType":"INBOUND","priority":70,"queueDuration":8425,"callback":false}],"inAcdQueueVoicemails":[],"inProgressVoicemails":[],"inQueueCallbackCount":0,"vivrCallbackCount":0,"maxQueueDuration":8000,"voicemailCount":0}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        Five9SupervisorIntegration.DetailedSnapshotInfo response = five9integration.getDetailedSnapshotInfo('12');

        Assert.areEqual(1, response.inQueueCalls.size(), 'in-queue calls must match');
        Assert.areEqual(8000, response.maxQueueDuration, 'max queue duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetDetailedSnapshotInfoFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/snapshot', 500, '{"five9ExceptionDetail":{"timestamp":1726129453556,"errorCode":435,"message":"invalid state"}}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        Five9SupervisorIntegration.DetailedSnapshotInfo response = five9integration.getDetailedSnapshotInfo('12');
        Assert.areEqual(null, response, 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetAllAgents() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/agents',
            200,
            '[{"id":"4892647","userName":"nishant.shelar@radnet.com","firstName":"Nishant","lastName":"Shelar","fullName":"Nishant Shelar","email":"nishant.shelar@radnet.com","hasUserProfile":false,"canReceiveTransfer":true,"skills":[{"id":"12","name":"jav_skills_set","level":1,"active":true}],"availableChannels":["VOICE_MAIL","CALL"],"enabledChannels":{"VOICE_MAIL":{"capacity":1,"acdMode":true},"CALL":{"capacity":1,"acdMode":false}}}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        List<Five9SupervisorIntegration.AgentInfo> response = five9integration.getAllAgents();
        Assert.areEqual(1, response.size(), 'total agents must match');
        Assert.areEqual('4892647', response.get(0).id, 'id must match');
        Assert.areEqual('nishant.shelar@radnet.com', response.get(0).username, 'username must match');
        Assert.areEqual('nishant.shelar@radnet.com', response.get(0).email, 'email must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAllAgentsFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/agents', 500, '{"five9ExceptionDetail":{"timestamp":1726129453556,"errorCode":435,"message":"invalid state"}}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        List<Five9SupervisorIntegration.AgentInfo> response = five9integration.getAllAgents();
        Assert.areEqual(null, response, 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatFromCache() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String skillId = '12';
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();
        String cacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Five9SupervisorIntegration.Stat stat = new Five9SupervisorIntegration.Stat(8, 26000);
        cachePartition.put(cacheKey, stat, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/snapshot');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration.Stat response = five9integration.getSkillStat(skillId);
        Assert.areEqual(8, response.totalCalls, 'total calls must match');
        Assert.areEqual(26000, response.longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatFromExpiredCache() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String skillId = '12';
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();
        String cacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Five9SupervisorIntegration.Stat stat = new Five9SupervisorIntegration.Stat(8, 26000);
        stat.updatedAt = Datetime.now().getTime() - 20000;
        cachePartition.put(cacheKey, stat, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/snapshot',
            200,
            '{"loggedInAgentsIds":["4892647"],"activeAgentsIds":["4892647"],"onCallAgentsIds":[],"readyForCallAgentsIds":[],"notReadyForCallAgentsIds":["4892647"],"readyForVoicemailAgentsIds":[],"readyForChatAgentsIds":[],"readyForEmailAgentsIds":[],"inQueueCalls":[{"customer":"7185506374","customerName":"","campaignId":"22","callType":"INBOUND","priority":70,"queueDuration":8425,"callback":false}],"inAcdQueueVoicemails":[],"inProgressVoicemails":[],"inQueueCallbackCount":0,"vivrCallbackCount":0,"maxQueueDuration":8000,"voicemailCount":0}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration.Stat response = five9integration.getSkillStat(skillId);
        Assert.areEqual(1, response.totalCalls, 'total calls must match');
        Assert.areEqual(8000, response.longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatFromApi() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/snapshot',
            200,
            '{"loggedInAgentsIds":["4892647"],"activeAgentsIds":["4892647"],"onCallAgentsIds":[],"readyForCallAgentsIds":[],"notReadyForCallAgentsIds":["4892647"],"readyForVoicemailAgentsIds":[],"readyForChatAgentsIds":[],"readyForEmailAgentsIds":[],"inQueueCalls":[{"customer":"7185506374","customerName":"","campaignId":"22","callType":"INBOUND","priority":70,"queueDuration":8425,"callback":false}],"inAcdQueueVoicemails":[],"inProgressVoicemails":[],"inQueueCallbackCount":0,"vivrCallbackCount":0,"maxQueueDuration":8000,"voicemailCount":0}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        Five9SupervisorIntegration.Stat response = five9integration.getSkillStat('12');
        Assert.areEqual(1, response.totalCalls, 'total calls must match');
        Assert.areEqual(8000, response.longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatFromExpiredCacheWithLock() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String skillId = '12';
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();
        String cacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Five9SupervisorIntegration.Stat stat = new Five9SupervisorIntegration.Stat(8, 26000);
        stat.updatedAt = Datetime.now().getTime() - 20000;
        cachePartition.put(cacheKey, stat, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/snapshot');
        Test.setMock(HttpCalloutMock.class, mock);

        CacheLock cacheLock = new CacheLock(five9integration.getCachePartitionName(), Five9SupervisorIntegration.CACHE_LOCK_SKILL_STAT_PREFIX + skillId);
        cacheLock.lock();

        Five9SupervisorIntegration.Stat response = five9integration.getSkillStat(skillId);
        Assert.areEqual(8, response.totalCalls, 'total calls must match');
        Assert.areEqual(26000, response.longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatNoCacheWithLock() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        String skillId = '12';

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/snapshot');
        Test.setMock(HttpCalloutMock.class, mock);

        CacheLock cacheLock = new CacheLock(five9integration.getCachePartitionName(), Five9SupervisorIntegration.CACHE_LOCK_SKILL_STAT_PREFIX + skillId);
        cacheLock.lock();

        Five9SupervisorIntegration.Stat response = five9integration.getSkillStat(skillId);
        Assert.areEqual(0, response.totalCalls, 'total calls must be zero');
        Assert.areEqual(0, response.longestWaitingCall, 'longest waiting call duration must be zero');

        Test.stopTest();
    }

    static Five9SupervisorIntegration.SkillInfo getSkillInfo(String id, String name) {
        Five9SupervisorIntegration.SkillInfo skill = new Five9SupervisorIntegration.SkillInfo();
        skill.id = id;
        skill.name = name;
        skill.level = 1;
        skill.active = true;
        return skill;
    }

    @IsTest
    static void testGetAgentSkillsFromCache() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String agentId = '4892647';
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();
        String cacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9SupervisorIntegration.AgentSkills agentSkills = new Five9SupervisorIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('8', 'test_skills_set'));
        cachePartition.put(cacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/agents');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration.AgentSkills response = five9integration.getAgentSkills(agentId);
        Assert.areEqual(1, response.skills.size(), 'total skills must match');
        Assert.areEqual('8', response.skills.get(0).id, 'skill id must match');
        Assert.areEqual('test_skills_set', response.skills.get(0).name, 'skill name must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentSkillsFromExpiredCache() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String agentId = '4892647';
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();
        String cacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9SupervisorIntegration.AgentSkills agentSkills = new Five9SupervisorIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('8', 'test_skills_set'));
        agentSkills.updatedAt = Datetime.now().getTime() - 400000;
        cachePartition.put(cacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/agents',
            200,
            '{"id":"4892647","userName":"nishant.shelar@radnet.com","firstName":"Nishant","lastName":"Shelar","fullName":"Nishant Shelar","email":"nishant.shelar@radnet.com","hasUserProfile":false,"canReceiveTransfer":true,"skills":[{"id":"12","name":"jav_skills_set","level":1,"active":true}],"availableChannels":["VOICE_MAIL","CALL"],"enabledChannels":{"VOICE_MAIL":{"capacity":1,"acdMode":true},"CALL":{"capacity":1,"acdMode":false}}}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration.AgentSkills response = five9integration.getAgentSkills(agentId);
        Assert.areEqual(1, response.skills.size(), 'total skills must match');
        Assert.areEqual('12', response.skills.get(0).id, 'skill id must match');
        Assert.areEqual('jav_skills_set', response.skills.get(0).name, 'skill name must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentSkillsFromApi() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/agents',
            200,
            '{"id":"4892647","userName":"nishant.shelar@radnet.com","firstName":"Nishant","lastName":"Shelar","fullName":"Nishant Shelar","email":"nishant.shelar@radnet.com","hasUserProfile":false,"canReceiveTransfer":true,"skills":[{"id":"12","name":"jav_skills_set","level":1,"active":true}],"availableChannels":["VOICE_MAIL","CALL"],"enabledChannels":{"VOICE_MAIL":{"capacity":1,"acdMode":true},"CALL":{"capacity":1,"acdMode":false}}}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        Five9SupervisorIntegration.AgentSkills response = five9integration.getAgentSkills('4892647');
        Assert.areEqual(1, response.skills.size(), 'total skills must match');
        Assert.areEqual('12', response.skills.get(0).id, 'skill id must match');
        Assert.areEqual('jav_skills_set', response.skills.get(0).name, 'skill name must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentSkillsFromExpiredCacheWithLock() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String agentId = '4892647';
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();
        String cacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9SupervisorIntegration.AgentSkills agentSkills = new Five9SupervisorIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('8', 'test_skills_set'));
        agentSkills.updatedAt = Datetime.now().getTime() - 400000;
        cachePartition.put(cacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/agents');
        Test.setMock(HttpCalloutMock.class, mock);

        CacheLock cacheLock = new CacheLock(five9integration.getCachePartitionName(), Five9SupervisorIntegration.CACHE_LOCK_AGENT_SKILLS_PREFIX + agentId);
        cacheLock.lock();

        Five9SupervisorIntegration.AgentSkills response = five9integration.getAgentSkills(agentId);
        Assert.areEqual(1, response.skills.size(), 'total skills must match');
        Assert.areEqual('8', response.skills.get(0).id, 'skill id must match');
        Assert.areEqual('test_skills_set', response.skills.get(0).name, 'skill name must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentSkillsNoCacheWithLock() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        String agentId = '4892647';

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/agents');
        Test.setMock(HttpCalloutMock.class, mock);

        CacheLock cacheLock = new CacheLock(five9integration.getCachePartitionName(), Five9SupervisorIntegration.CACHE_LOCK_AGENT_SKILLS_PREFIX + agentId);
        cacheLock.lock();

        Five9SupervisorIntegration.AgentSkills response = five9integration.getAgentSkills(agentId);
        Assert.areEqual(0, response.skills.size(), 'total skills must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentIDForEmailWithCache() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String email = 'test@radnet.com';
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();
        String cacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_AGENT_ID_PREFIX + email);
        cachePartition.put(cacheKey, '8', 300, Cache.Visibility.ALL, false);

        String agentID = five9integration.getAgentIDForEmail(email);
        Assert.areEqual('8', agentID, 'agent id must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentIDForEmailNoCache() {
        Test.startTest();
        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/agents',
            200,
            '[{"id":"4892647","userName":"nishant.shelar@radnet.com","firstName":"Nishant","lastName":"Shelar","fullName":"Nishant Shelar","email":"nishant.shelar@radnet.com","hasUserProfile":false,"canReceiveTransfer":true,"skills":[{"id":"12","name":"jav_skills_set","level":1,"active":true}],"availableChannels":["VOICE_MAIL","CALL"],"enabledChannels":{"VOICE_MAIL":{"capacity":1,"acdMode":true},"CALL":{"capacity":1,"acdMode":false}}},{"id":"4900106","userName":"az_test","firstName":"AZ","lastName":"Test","fullName":"AZ Test","email":"arizona.testing@radnet.com","hasUserProfile":false,"canReceiveTransfer":true,"availableChannels":["VOICE_MAIL","CALL"],"enabledChannels":{"VOICE_MAIL":{"capacity":1,"acdMode":true},"CALL":{"capacity":1,"acdMode":false}}}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String agentID = five9integration.getAgentIDForEmail('nishant.shelar@radnet.com');
        Assert.areEqual('4892647', agentID, 'agent id must match');

        agentID = five9integration.getAgentIDForEmail('arizona.testing@radnet.com');
        Assert.areEqual('4900106', agentID, 'agent id must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentIDForEmailNoCacheInvalidResponse() {
        Test.startTest();
        MockApi mock = new MockApi();
        mock.addResponse('GET', '/agents', 200, '{"test"');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        String agentID = five9integration.getAgentIDForEmail('nishant.shelar@radnet.com');
        Assert.areEqual(null, agentID, 'agent id must be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentIDForEmailNoCacheWithLock() {
        Test.startTest();
        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/agents');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();

        CacheLock cacheLock = new CacheLock(five9integration.getCachePartitionName(), Five9SupervisorIntegration.CACHE_LOCK_GET_AGENTS);
        cacheLock.lock();

        String agentID = five9integration.getAgentIDForEmail('nishant.shelar@radnet.com');
        Assert.areEqual(null, agentID, 'agent id must be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentIDForEmailNoCacheNoSession() {
        Test.startTest();
        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        mock.addResponse('GET', '/login_state', 200, '"WORKING"');
        mock.addNotToRequest('GET', '/agents');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = new Five9SupervisorIntegration();

        String agentID = five9integration.getAgentIDForEmail('test@radnet.com');
        Assert.areNotEqual(null, five9integration.getSession(), 'session must not be null');
        Assert.areEqual(null, agentID, 'agent id must be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentStat() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();

        String agentId = '12345678';
        String agentSkillsCacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9SupervisorIntegration.AgentSkills agentSkills = new Five9SupervisorIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('12', 'test_skills_set'));
        agentSkills.skills.add(getSkillInfo('17', 'test_skills_set_1'));
        cachePartition.put(agentSkillsCacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        String skillId = '12';
        String skillStatsCacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Five9SupervisorIntegration.Stat stat = new Five9SupervisorIntegration.Stat(6, 10000);
        cachePartition.put(skillStatsCacheKey, stat, 300, Cache.Visibility.ALL, false);

        skillId = '17';
        skillStatsCacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        stat = new Five9SupervisorIntegration.Stat(2, 26000);
        cachePartition.put(skillStatsCacheKey, stat, 300, Cache.Visibility.ALL, false);

        Map<String, Five9SupervisorIntegration.Stat> response = five9integration.getAgentStat(agentId);
        Assert.areEqual(6, response.get('test_skills_set').totalCalls, 'total calls must match');
        Assert.areEqual(2, response.get('test_skills_set_1').totalCalls, 'total calls must match');
        Assert.areEqual(8, response.get('combined').totalCalls, 'total calls must match');
        Assert.areEqual(10000, response.get('test_skills_set').longestWaitingCall, 'longest waiting call duration must match');
        Assert.areEqual(26000, response.get('test_skills_set_1').longestWaitingCall, 'longest waiting call duration must match');
        Assert.areEqual(26000, response.get('combined').longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentStatNoSession() {
        Test.startTest();

        Five9SupervisorIntegration five9integration = new Five9SupervisorIntegration();
        Map<String, Five9SupervisorIntegration.Stat> response = five9integration.getAgentStat('12345678');
        Assert.areEqual(0, response.get('combined').totalCalls, 'total calls must match');
        Assert.areEqual(0, response.get('combined').longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentStatWithInvalidResponse() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/snapshot', 200, '{"test"');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9SupervisorIntegration five9integration = getAuthenticatedFive9Client();
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();

        String agentId = '12345678';
        String agentSkillsCacheKey = five9integration.getHash(Five9SupervisorIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9SupervisorIntegration.AgentSkills agentSkills = new Five9SupervisorIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('17', 'test_skills_set'));
        cachePartition.put(agentSkillsCacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        Map<String, Five9SupervisorIntegration.Stat> response = five9integration.getAgentStat(agentId);
        Assert.areEqual(0, response.get('combined').totalCalls, 'total calls must match');
        Assert.areEqual(0, response.get('combined').longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }
}