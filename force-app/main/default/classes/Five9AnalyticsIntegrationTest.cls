@IsTest
public class Five9AnalyticsIntegrationTest {
    static Five9AnalyticsIntegration getAuthenticatedFive9AnalyticsIntegration() {
        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        String data = '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}';
        Five9AnalyticsIntegration.LoginResponse loginResponse = (Five9AnalyticsIntegration.LoginResponse) JSON.deserialize(data, Five9AnalyticsIntegration.LoginResponse.class);
        five9integration.setSession(loginResponse);
        return five9integration;
    }

    @IsTest
    static void testCacheLock() {
        Test.startTest();

        Five9AnalyticsIntegration.CacheLock cacheLock = new Five9AnalyticsIntegration.CacheLock('test');
        cacheLock.lock();
        Assert.areEqual(true, cacheLock.isLocked(), 'cache lock must be locked');

        cacheLock.unlock();
        Assert.areEqual(false, cacheLock.isLocked(), 'cache lock must be unlocked');

        Long startTime = Datetime.now().getTime();
        cacheLock.lock();
        while (Datetime.now().getTime() < startTime + 6000) {
        }
        Assert.areEqual(false, cacheLock.isLocked(), 'cache lock must expire');

        Test.stopTest();
    }

    @IsTest
    static void testLogin() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        Five9AnalyticsIntegration.LoginResponse response = five9integration.login('test_username', 'test_password', false);

        Assert.areEqual('86208f47-6e94-11ef-4e15-f8f63aef94dd', response.tokenId, 'token must match');
        Assert.areEqual('139537', response.orgId, 'orgId must match');
        Assert.areEqual('4961188', response.userId, 'userId must match');
        Assert.areEqual('183', response.context.farmId, 'farmId must match');

        Test.stopTest();
    }

    @IsTest
    static void testLoginFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('POST', '/auth/login', 435, '{"five9ExceptionDetail": {"timestamp": 1726129453556,"errorCode": 401,"message": "Invalid credentials"}}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        Five9AnalyticsIntegration.LoginResponse response = five9integration.login('test_username', 'test_password', false);

        Assert.areEqual(null, response, 'response must be null');

        Test.stopTest();
    }

    @IsTest
    static void testLoginInvalidResponse() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('POST', '/auth/login', 200, '{}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        Five9AnalyticsIntegration.LoginResponse response = five9integration.login('test_username', 'test_password', false);

        Assert.areEqual(null, response, 'response must be null');

        Test.stopTest();
    }

    @IsTest
    static void testLoginState() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/login_state', 200, '"WORKING"');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        String response = five9integration.getLoginState('4961188');

        Assert.areEqual('WORKING', response, 'response must match');

        Test.stopTest();
    }

    @IsTest
    static void testLoginStateFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/login_state', 400, '');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        String response = five9integration.getLoginState('4961188');

        Assert.areEqual(null, response, 'response must be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetMaintenanceNotices() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/maintenance_notices', 200, '[{"id":9448,"annotation":"Service Update","text":"<table></table>","accepted":false}]');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        List<Five9AnalyticsIntegration.MaintenanceNoticeInfo> response = five9integration.getMaintenanceNotices('4961188');
        Assert.areEqual(1, response.size(), 'size must match');

        Assert.areEqual('9448', response.get(0).id, 'id must match');
        Assert.areEqual('Service Update', response.get(0).annotation, 'id must match');
        Assert.areEqual(false, response.get(0).accepted, 'accepted must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetMaintenanceNoticesFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/maintenance_notices', 500, '{"five9ExceptionDetail":{"timestamp":1726129453556,"errorCode":435,"message":"invalid state"}}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        List<Five9AnalyticsIntegration.MaintenanceNoticeInfo> response = five9integration.getMaintenanceNotices('4961188');
        Assert.areEqual(0, response.size(), 'size must match');

        Test.stopTest();
    }

    @IsTest
    static void testAcceptMaintenanceNotice() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('PUT', '/maintenance_notices', 200, '{"id":9448,"annotation":null,"text":null,"accepted":true}]');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Five9AnalyticsIntegration.MaintenanceNoticeInfo response = five9integration.acceptMaintenanceNotice('4961188', '9448');

        Assert.areEqual('9448', response.id, 'id must match');
        Assert.areEqual(true, response.accepted, 'accepted must match');

        Test.stopTest();
    }

    @IsTest
    static void testAcceptMaintenanceNoticeFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('PUT', '/maintenance_notices', 500, '{"five9ExceptionDetail":{"timestamp":1726129453556,"errorCode":435,"message":"invalid state"}}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Five9AnalyticsIntegration.MaintenanceNoticeInfo response = five9integration.acceptMaintenanceNotice('4961188', '9448');

        Assert.areEqual(null, response, 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testSelectStation() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('PUT', '/session_start', 204, '');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Boolean response = five9integration.selectStation('4961188', '', 'EMPTY');

        Assert.areEqual(true, response, 'must be true');

        Test.stopTest();
    }

    @IsTest
    static void testSelectStationFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('PUT', '/session_start', 500, '');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Boolean response = five9integration.selectStation('4961188', '', 'EMPTY');

        Assert.areEqual(false, response, 'must be false');

        Test.stopTest();
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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Five9AnalyticsIntegration.AgentInfo response = five9integration.getAgentById('4892647');

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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Five9AnalyticsIntegration.AgentInfo response = five9integration.getAgentById('4892647');
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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Five9AnalyticsIntegration.DetailedSnapshotInfo response = five9integration.getDetailedSnapshotInfo('12');

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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Five9AnalyticsIntegration.DetailedSnapshotInfo response = five9integration.getDetailedSnapshotInfo('12');
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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        List<Five9AnalyticsIntegration.AgentInfo> response = five9integration.getAllAgents();
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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        List<Five9AnalyticsIntegration.AgentInfo> response = five9integration.getAllAgents();
        Assert.areEqual(null, response, 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testCreateSession() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        Assert.areEqual(null, five9integration.getSession(), 'must be null');

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        five9integration.createSession(false);
        five9integration.setSession(null);

        Assert.areNotEqual(null, five9integration.getSession(), 'must not be null');

        Test.stopTest();
    }

    @IsTest
    static void testCreateSessionForce() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        Assert.areEqual(null, five9integration.getSession(), 'must be null');

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        five9integration.createSession(true);
        five9integration.setSession(null);

        Assert.areNotEqual(null, five9integration.getSession(), 'must not be null');

        Test.stopTest();
    }

    @IsTest
    static void testCreateSessionWithLock() {
        Test.startTest();

        Five9AnalyticsIntegration.CacheLock sessionLock = new Five9AnalyticsIntegration.CacheLock(Five9AnalyticsIntegration.CACHE_LOCK_LOGIN_CALL);
        sessionLock.lock();

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();

        MockApi mock = new MockApi();
        mock.addNotToRequest('POST', '/auth/login');
        Test.setMock(HttpCalloutMock.class, mock);

        five9integration.createSession(false);
        Assert.areEqual(null, five9integration.getSession(), 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testCreateSessionFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('POST', '/auth/login', 500, '{}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        five9integration.createSession(false);

        Assert.areEqual(null, five9integration.getSession(), 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testCreateSessionInvalidResponse() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('POST', '/auth/login', 200, '{"test":');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        five9integration.createSession(false);

        Assert.areEqual(null, five9integration.getSession(), 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testInitializeWorkingStateWithNoSession() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        mock.addResponse('GET', '/login_state', 200, '"WORKING"');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        five9integration.initializeWorkingState();

        Assert.areNotEqual(null, five9integration.getSession(), 'must not be null');

        Test.stopTest();
    }

    @IsTest
    static void testInitializeWorkingStateWithLock() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addNotToRequest('POST', '/auth/login');
        mock.addNotToRequest('GET', '/login_state');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration.CacheLock workingStateLock = new Five9AnalyticsIntegration.CacheLock(Five9AnalyticsIntegration.CACHE_LOCK_INIT_WORKING_STATE);
        workingStateLock.lock();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        five9integration.initializeWorkingState();

        Test.stopTest();
    }

    @IsTest
    static void testCheckWorkingStateLoginStateError() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/login_state', 500, '');
        mock.addNotToRequest('POST', '/auth/login');
        mock.addNotToRequest('PUT', '/session_start');
        mock.addNotToRequest('GET', '/maintenance_notices');
        mock.addNotToRequest('PUT', '/maintenance_notices');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Boolean success = five9integration.checkWorkingState();

        Assert.areEqual(false, success, 'check for working state must return false');

        Test.stopTest();
    }

    @IsTest
    static void testCheckWorkingStateLoginStateRelogin() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/login_state', 200, '"RELOGIN"');
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        mock.addNotToRequest('PUT', '/session_start');
        mock.addNotToRequest('GET', '/maintenance_notices');
        mock.addNotToRequest('PUT', '/maintenance_notices');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Boolean success = five9integration.checkWorkingState();

        Assert.areEqual(false, success, 'check for working state must return false');

        Test.stopTest();
    }

    @IsTest
    static void testCheckWorkingStateLoginStateSelectStation() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/login_state', 200, '"SELECT_STATION"');
        mock.addNotToRequest('POST', '/auth/login');
        mock.addResponse('PUT', '/session_start', 204, '');
        mock.addNotToRequest('GET', '/maintenance_notices');
        mock.addNotToRequest('PUT', '/maintenance_notices');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Boolean success = five9integration.checkWorkingState();

        Assert.areEqual(false, success, 'check for working state must return false');

        Test.stopTest();
    }

    @IsTest
    static void testCheckWorkingStateLoginStateAcceptNotice() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/login_state', 200, '"ACCEPT_NOTICE"');
        mock.addNotToRequest('POST', '/auth/login');
        mock.addNotToRequest('PUT', '/session_start');
        mock.addResponse('GET', '/maintenance_notices', 200, '[{"id":9448,"annotation":"Service Update","text":"<table></table>","accepted":false}]');
        mock.addResponse('PUT', '/maintenance_notices', 200, '{"id":9448,"annotation":null,"text":null,"accepted":true}]');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Boolean success = five9integration.checkWorkingState();

        Assert.areEqual(false, success, 'check for working state must return false');

        Test.stopTest();
    }

    @IsTest
    static void testCheckWorkingStateLoginStateAcceptNoticeWithInvalidResponse() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/login_state', 200, '"ACCEPT_NOTICE"');
        mock.addNotToRequest('POST', '/auth/login');
        mock.addNotToRequest('PUT', '/session_start');
        mock.addResponse('GET', '/maintenance_notices', 200, '{"test"');
        mock.addNotToRequest('PUT', '/maintenance_notices');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Boolean success = five9integration.checkWorkingState();

        Assert.areEqual(false, success, 'check for working state must return false');

        Test.stopTest();
    }

    @IsTest
    static void testMakeHttpRequestWithNoSession() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/login_state');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        String response = five9integration.getLoginState('4961188');
        Assert.areEqual(null, response, 'response must be null');

        Test.stopTest();
    }

    @IsTest
    static void testMakeHttpRequestWithUnauthorizedResponse() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        mock.addResponse('GET', '/login_state', 401, '{}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        String response = five9integration.getLoginState('4961188');
        Assert.areEqual(null, response, 'response must be null');
        Assert.areNotEqual(null, five9integration.getSession(), 'must not be null');

        Test.stopTest();
    }

    @IsTest
    static void testMakeHttpRequestWith435Response() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        mock.addResponse('GET', '/login_state', 200, '"WORKING"');
        mock.addResponse(
            'PUT',
            '/session_start',
            435,
            '{"five9ExceptionDetail":{"timestamp":1726138790056,"errorCode":3,"message":"Improper agent login state WORKING while calling sessionStart. Allowed is SELECT_STATION","context":{"contextCode":"LOGIN"}};'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Boolean response = five9integration.selectStation('4961188', '', 'EMPTY');
        Assert.areEqual(false, response, 'response must be false');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatFromCache() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

        String skillId = '12';
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);
        String cacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Five9AnalyticsIntegration.Stat stat = new Five9AnalyticsIntegration.Stat(8, 26000);
        cachePartition.put(cacheKey, stat, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/snapshot');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration.Stat response = five9integration.getSkillStat(skillId);
        Assert.areEqual(8, response.totalCalls, 'total calls must match');
        Assert.areEqual(26000, response.longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatFromExpiredCache() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

        String skillId = '12';
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);
        String cacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Five9AnalyticsIntegration.Stat stat = new Five9AnalyticsIntegration.Stat(8, 26000);
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

        Five9AnalyticsIntegration.Stat response = five9integration.getSkillStat(skillId);
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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Five9AnalyticsIntegration.Stat response = five9integration.getSkillStat('12');
        Assert.areEqual(1, response.totalCalls, 'total calls must match');
        Assert.areEqual(8000, response.longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatFromExpiredCacheWithLock() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

        String skillId = '12';
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);
        String cacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Five9AnalyticsIntegration.Stat stat = new Five9AnalyticsIntegration.Stat(8, 26000);
        stat.updatedAt = Datetime.now().getTime() - 20000;
        cachePartition.put(cacheKey, stat, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/snapshot');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration.CacheLock cacheLock = new Five9AnalyticsIntegration.CacheLock(Five9AnalyticsIntegration.CACHE_LOCK_SKILL_STAT_PREFIX + skillId);
        cacheLock.lock();

        Five9AnalyticsIntegration.Stat response = five9integration.getSkillStat(skillId);
        Assert.areEqual(8, response.totalCalls, 'total calls must match');
        Assert.areEqual(26000, response.longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSkillStatNoCacheWithLock() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        String skillId = '12';

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/snapshot');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration.CacheLock cacheLock = new Five9AnalyticsIntegration.CacheLock(Five9AnalyticsIntegration.CACHE_LOCK_SKILL_STAT_PREFIX + skillId);
        cacheLock.lock();

        Five9AnalyticsIntegration.Stat response = five9integration.getSkillStat(skillId);
        Assert.areEqual(0, response.totalCalls, 'total calls must be zero');
        Assert.areEqual(0, response.longestWaitingCall, 'longest waiting call duration must be zero');

        Test.stopTest();
    }

    static Five9AnalyticsIntegration.SkillInfo getSkillInfo(String id, String name) {
        Five9AnalyticsIntegration.SkillInfo skill = new Five9AnalyticsIntegration.SkillInfo();
        skill.id = id;
        skill.name = name;
        skill.level = 1;
        skill.active = true;
        return skill;
    }

    @IsTest
    static void testGetAgentSkillsFromCache() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

        String agentId = '4892647';
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);
        String cacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9AnalyticsIntegration.AgentSkills agentSkills = new Five9AnalyticsIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('8', 'test_skills_set'));
        cachePartition.put(cacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/agents');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration.AgentSkills response = five9integration.getAgentSkills(agentId);
        Assert.areEqual(1, response.skills.size(), 'total skills must match');
        Assert.areEqual('8', response.skills.get(0).id, 'skill id must match');
        Assert.areEqual('test_skills_set', response.skills.get(0).name, 'skill name must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentSkillsFromExpiredCache() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

        String agentId = '4892647';
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);
        String cacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9AnalyticsIntegration.AgentSkills agentSkills = new Five9AnalyticsIntegration.AgentSkills();
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

        Five9AnalyticsIntegration.AgentSkills response = five9integration.getAgentSkills(agentId);
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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Five9AnalyticsIntegration.AgentSkills response = five9integration.getAgentSkills('4892647');
        Assert.areEqual(1, response.skills.size(), 'total skills must match');
        Assert.areEqual('12', response.skills.get(0).id, 'skill id must match');
        Assert.areEqual('jav_skills_set', response.skills.get(0).name, 'skill name must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentSkillsFromExpiredCacheWithLock() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

        String agentId = '4892647';
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);
        String cacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9AnalyticsIntegration.AgentSkills agentSkills = new Five9AnalyticsIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('8', 'test_skills_set'));
        agentSkills.updatedAt = Datetime.now().getTime() - 400000;
        cachePartition.put(cacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/agents');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration.CacheLock cacheLock = new Five9AnalyticsIntegration.CacheLock(Five9AnalyticsIntegration.CACHE_LOCK_AGENT_SKILLS_PREFIX + agentId);
        cacheLock.lock();

        Five9AnalyticsIntegration.AgentSkills response = five9integration.getAgentSkills(agentId);
        Assert.areEqual(1, response.skills.size(), 'total skills must match');
        Assert.areEqual('8', response.skills.get(0).id, 'skill id must match');
        Assert.areEqual('test_skills_set', response.skills.get(0).name, 'skill name must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentSkillsNoCacheWithLock() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        String agentId = '4892647';

        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/agents');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AnalyticsIntegration.CacheLock cacheLock = new Five9AnalyticsIntegration.CacheLock(Five9AnalyticsIntegration.CACHE_LOCK_AGENT_SKILLS_PREFIX + agentId);
        cacheLock.lock();

        Five9AnalyticsIntegration.AgentSkills response = five9integration.getAgentSkills(agentId);
        Assert.areEqual(0, response.skills.size(), 'total skills must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentIDForEmailWithCache() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

        String email = 'test@radnet.com';
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);
        String cacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_AGENT_ID_PREFIX + email);
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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();

        Five9AnalyticsIntegration.CacheLock cacheLock = new Five9AnalyticsIntegration.CacheLock(Five9AnalyticsIntegration.CACHE_LOCK_GET_AGENTS);
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

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();

        String agentID = five9integration.getAgentIDForEmail('test@radnet.com');
        Assert.areNotEqual(null, five9integration.getSession(), 'session must not be null');
        Assert.areEqual(null, agentID, 'agent id must be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetAgentStat() {
        Test.startTest();

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);

        String agentId = '12345678';
        String agentSkillsCacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9AnalyticsIntegration.AgentSkills agentSkills = new Five9AnalyticsIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('12', 'test_skills_set'));
        agentSkills.skills.add(getSkillInfo('17', 'test_skills_set_1'));
        cachePartition.put(agentSkillsCacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        String skillId = '12';
        String skillStatsCacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        Five9AnalyticsIntegration.Stat stat = new Five9AnalyticsIntegration.Stat(6, 10000);
        cachePartition.put(skillStatsCacheKey, stat, 300, Cache.Visibility.ALL, false);

        skillId = '17';
        skillStatsCacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_STATISTIC_SKILL_PREFIX + skillId);
        stat = new Five9AnalyticsIntegration.Stat(2, 26000);
        cachePartition.put(skillStatsCacheKey, stat, 300, Cache.Visibility.ALL, false);

        Map<String, Five9AnalyticsIntegration.Stat> response = five9integration.getAgentStat(agentId);
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

        Five9AnalyticsIntegration five9integration = new Five9AnalyticsIntegration();
        Map<String, Five9AnalyticsIntegration.Stat> response = five9integration.getAgentStat('12345678');
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

        Five9AnalyticsIntegration five9integration = getAuthenticatedFive9AnalyticsIntegration();
        Cache.OrgPartition cachePartition = Cache.Org.getPartition(Five9AnalyticsIntegration.CACHE_PARTITION);

        String agentId = '12345678';
        String agentSkillsCacheKey = five9integration.getHash(Five9AnalyticsIntegration.CACHE_AGENT_SKILLS_PREFIX + agentId);
        Five9AnalyticsIntegration.AgentSkills agentSkills = new Five9AnalyticsIntegration.AgentSkills();
        agentSkills.skills.add(getSkillInfo('17', 'test_skills_set'));
        cachePartition.put(agentSkillsCacheKey, agentSkills, 300, Cache.Visibility.ALL, false);

        Map<String, Five9AnalyticsIntegration.Stat> response = five9integration.getAgentStat(agentId);
        Assert.areEqual(0, response.get('combined').totalCalls, 'total calls must match');
        Assert.areEqual(0, response.get('combined').longestWaitingCall, 'longest waiting call duration must match');

        Test.stopTest();
    }
}