/*
* ***************************************************************************************************************************
* Apex Class Name - Five9BaseIntegrationTest
* Version - 0.1
* Created Date - 21-Jan-2024
* @description       : Test class for Five9BaseIntegration
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1501                   21-Jan-2025         Added multiple test methods to cover Five9BaseIntegration.
* ************************************************************************************************************************************
*/
@IsTest
public class Five9BaseIntegrationTest {
    private class Five9TestIntegration extends Five9BaseIntegration {
        public Five9TestIntegration() {
            super(Five9BaseIntegration.ClientType.SUPERVISOR);
        }

        public Five9TestIntegration(Five9BaseIntegration.ClientType clientType) {
            super(clientType);
        }
    }

    static Five9TestIntegration getAuthenticatedFive9Client() {
        Five9TestIntegration five9integration = new Five9TestIntegration();
        String data = '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}';
        Five9BaseIntegration.LoginResponse loginResponse = (Five9BaseIntegration.LoginResponse) JSON.deserialize(data, Five9BaseIntegration.LoginResponse.class);
        five9integration.setSession(loginResponse);
        return five9integration;
    }

    @IsTest
    static void testBaseUrls() {
        Test.startTest();

        String userId = '888';

        Five9TestIntegration five9Agentintegration = new Five9TestIntegration(Five9BaseIntegration.ClientType.AGENT);
        Assert.areEqual(System.label.Five9Url + '/appsvcs/rs/svc', five9Agentintegration.getBaseUrl(), 'base url must match');
        Assert.areEqual(System.label.Five9Url + '/appsvcs/rs/svc/agents/888', five9Agentintegration.getLoginBaseUrl(userId), 'login base url must match');

        Five9TestIntegration five9Supervisorintegration = new Five9TestIntegration(Five9BaseIntegration.ClientType.SUPERVISOR);
        Assert.areEqual(System.label.Five9Url + '/supsvcs/rs/svc', five9Supervisorintegration.getBaseUrl(), 'base url must match');
        Assert.areEqual(System.label.Five9Url + '/supsvcs/rs/svc/supervisors/888', five9Supervisorintegration.getLoginBaseUrl(userId), 'login base url must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetCachePartition() {
        Test.startTest();

        Five9TestIntegration five9integration = new Five9TestIntegration();
        Cache.OrgPartition cachePartition = five9integration.getCachePartition();

        Assert.areEqual('local.five9analytics', cachePartition.getName(), 'cache partition name must match');
        Assert.areEqual(true, cachePartition.isAvailable(), 'cache partition must be available');

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

        Five9TestIntegration five9integration = new Five9TestIntegration();
        Five9BaseIntegration.LoginResponse response = five9integration.login('test_username', 'test_password', false);

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

        Five9TestIntegration five9integration = new Five9TestIntegration();
        Five9BaseIntegration.LoginResponse response = five9integration.login('test_username', 'test_password', false);

        Assert.areEqual(null, response, 'response must be null');

        Test.stopTest();
    }

    @IsTest
    static void testLoginInvalidResponse() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('POST', '/auth/login', 200, '{}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9TestIntegration five9integration = new Five9TestIntegration();
        Five9BaseIntegration.LoginResponse response = five9integration.login('test_username', 'test_password', false);

        Assert.areEqual(null, response, 'response must be null');

        Test.stopTest();
    }

    @IsTest
    static void testLoginState() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/login_state', 200, '"WORKING"');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
        List<Five9BaseIntegration.MaintenanceNoticeInfo> response = five9integration.getMaintenanceNotices('4961188');
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
        List<Five9BaseIntegration.MaintenanceNoticeInfo> response = five9integration.getMaintenanceNotices('4961188');
        Assert.areEqual(0, response.size(), 'size must match');

        Test.stopTest();
    }

    @IsTest
    static void testAcceptMaintenanceNotice() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('PUT', '/maintenance_notices', 200, '{"id":9448,"annotation":null,"text":null,"accepted":true}]');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
        Five9BaseIntegration.MaintenanceNoticeInfo response = five9integration.acceptMaintenanceNotice('4961188', '9448');

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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
        Five9BaseIntegration.MaintenanceNoticeInfo response = five9integration.acceptMaintenanceNotice('4961188', '9448');

        Assert.areEqual(null, response, 'must be null');

        Test.stopTest();
    }

    @IsTest
    static void testSelectStation() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('PUT', '/session_start', 204, '');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
        Boolean response = five9integration.selectStation('4961188', '', 'EMPTY');

        Assert.areEqual(false, response, 'must be false');

        Test.stopTest();
    }

    @IsTest
    static void testCreateSession() {
        Test.startTest();

        Five9TestIntegration five9integration = new Five9TestIntegration();
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

        Five9TestIntegration five9integration = new Five9TestIntegration();
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

        Five9TestIntegration five9integration = new Five9TestIntegration();

        CacheLock sessionLock = new CacheLock(five9integration.getCachePartitionName(), Five9BaseIntegration.CACHE_LOCK_LOGIN_CALL);
        sessionLock.lock();

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

        Five9TestIntegration five9integration = new Five9TestIntegration();
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

        Five9TestIntegration five9integration = new Five9TestIntegration();
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

        Five9TestIntegration five9integration = new Five9TestIntegration();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();

        CacheLock workingStateLock = new CacheLock(five9integration.getCachePartitionName(), Five9BaseIntegration.CACHE_LOCK_INIT_WORKING_STATE);
        workingStateLock.lock();

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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = new Five9TestIntegration();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
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

        Five9TestIntegration five9integration = getAuthenticatedFive9Client();
        Boolean response = five9integration.selectStation('4961188', '', 'EMPTY');
        Assert.areEqual(false, response, 'response must be false');

        Test.stopTest();
    }
}