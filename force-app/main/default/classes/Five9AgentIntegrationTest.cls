/*
* ***************************************************************************************************************************
* Apex Class Name - Five9AgentIntegrationTest
* Version - 0.1
* Created Date - 21-Jan-2024
* @description       : Test class for Five9AgentIntegration
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1501                   21-Jan-2025         Added multiple test methods to cover Five9AgentIntegration.
* ************************************************************************************************************************************
*/
@IsTest
public class Five9AgentIntegrationTest {
    static Five9AgentIntegration getAuthenticatedFive9Client() {
        Five9AgentIntegration five9integration = new Five9AgentIntegration();
        String data = '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}';
        Five9BaseIntegration.LoginResponse loginResponse = (Five9BaseIntegration.LoginResponse) JSON.deserialize(data, Five9BaseIntegration.LoginResponse.class);
        five9integration.setSession(loginResponse);
        return five9integration;
    }

    @IsTest
    static void testGetAllSpeedDials() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/speed_dials',
            200,
            '[{"id":"1","name":"001","description":"Radiologist","number":"8084812677"},{"id":"12","name":"002","description":"Front Desk","number":"8452134888"},{"id":"8","name":"888","description":"Radiology Technologist","number":"8888888888"}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AgentIntegration five9integration = getAuthenticatedFive9Client();
        List<Five9AgentIntegration.SpeedDialInfo> response = five9integration.getAllSpeedDials();

        Assert.areEqual(3, response.size(), 'size must match');
        Assert.areEqual('1', response.get(0).id, 'id must match');
        Assert.areEqual('001', response.get(0).name, 'name must match');
        Assert.areEqual('Radiologist', response.get(0).description, 'description must match');
        Assert.areEqual('8084812677', response.get(0).phoneNumber, 'phone number must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetAllSpeedDialsFailure() {
        Test.startTest();

        MockApi mock = new MockApi();
        mock.addResponse('GET', '/speed_dials', 500, '{"five9ExceptionDetail":{"timestamp":1726129453556,"errorCode":435,"message":"invalid state"}}');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AgentIntegration five9integration = getAuthenticatedFive9Client();
        List<Five9AgentIntegration.SpeedDialInfo> response = five9integration.getAllSpeedDials();
        Assert.areEqual(null, response, 'must be null');

        Test.stopTest();
    }

    private static Five9AgentIntegration.SpeedDialInfo getSpeedDialInfo(String id, String name, String phoneNumber) {
        Five9AgentIntegration.SpeedDialInfo speedDial = new Five9AgentIntegration.SpeedDialInfo();
        speedDial.id = id;
        speedDial.name = name;
        speedDial.description = String.format('Test {0} - {1}', new List<String>{ id, name });
        speedDial.phoneNumber = phoneNumber;
        return speedDial;
    }

    @IsTest
    static void testGetSpeedDialsWithCache() {
        Test.startTest();

        Five9AgentIntegration five9integration = getAuthenticatedFive9Client();

        List<Five9AgentIntegration.SpeedDialInfo> speedDials = new List<Five9AgentIntegration.SpeedDialInfo>();
        speedDials.add(getSpeedDialInfo('1', '001', '8084812677'));
        speedDials.add(getSpeedDialInfo('2', '002', '8452134888'));
        speedDials.add(getSpeedDialInfo('8', '008', '8888888888'));

        Cache.OrgPartition cachePartition = five9integration.getCachePartition();
        String cacheKey = five9integration.getHash(Five9AgentIntegration.CACHE_SPEED_DIALS);
        cachePartition.put(cacheKey, speedDials, 300, Cache.Visibility.ALL, false);

        List<Five9AgentIntegration.SpeedDialInfo> response = five9integration.getSpeedDials();
        Assert.areEqual(3, response.size(), 'size must match');
        Assert.areEqual('1', response.get(0).id, 'id must match');
        Assert.areEqual('001', response.get(0).name, 'name must match');
        Assert.areEqual('Test 1 - 001', response.get(0).description, 'description must match');
        Assert.areEqual('8084812677', response.get(0).phoneNumber, 'phone number must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSpeedDialsWithNoCache() {
        Test.startTest();
        MockApi mock = new MockApi();
        mock.addResponse(
            'GET',
            '/speed_dials',
            200,
            '[{"id":"1","name":"001","description":"Radiologist","number":"8084812677"},{"id":"12","name":"002","description":"Front Desk","number":"8452134888"},{"id":"8","name":"888","description":"Radiology Technologist","number":"8888888888"}]'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AgentIntegration five9integration = getAuthenticatedFive9Client();
        List<Five9AgentIntegration.SpeedDialInfo> response = five9integration.getSpeedDials();

        Assert.areEqual(3, response.size(), 'size must match');
        Assert.areEqual('1', response.get(0).id, 'id must match');
        Assert.areEqual('001', response.get(0).name, 'name must match');
        Assert.areEqual('Radiologist', response.get(0).description, 'description must match');
        Assert.areEqual('8084812677', response.get(0).phoneNumber, 'phone number must match');

        Test.stopTest();
    }

    @IsTest
    static void testGetSpeedDialsNoCacheInvalidResponse() {
        Test.startTest();
        MockApi mock = new MockApi();
        mock.addResponse('GET', '/speed_dials', 200, '{"test"');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AgentIntegration five9integration = getAuthenticatedFive9Client();
        List<Five9AgentIntegration.SpeedDialInfo> response = five9integration.getSpeedDials();

        Assert.areEqual(0, response.size(), 'size must be zero');

        Test.stopTest();
    }

    @IsTest
    static void testGetSpeedDialsNoCacheNoSession() {
        Test.startTest();
        MockApi mock = new MockApi();
        mock.addResponse(
            'POST',
            '/auth/login',
            200,
            '{"tokenId":"86208f47-6e94-11ef-4e15-f8f63aef94dd","sessionId":"3107b5efa7ddea65448eaa3472933de67ae72bae3d2cf3165132d7c129f85ec4","orgId":"139537","userId":"4961188","context":{"cloudClientUrl":"https://api.prod.us.five9.net/","cloudTokenUrl":"https://api.prod.us.five9.net/","farmId":"183"},"metadata":{"freedomUrl":"https://app.five9.com","dataCenters":[{"name":"Santa Clara Data Center","uiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoUI00c7","version":"13.0.326"}],"apiUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLoAPI9ac","version":"13.0.326"}],"loginUrls":[{"host":"app-scl.five9.com","port":"443","routeKey":"SCLLGNYoI4","version":"13.0.326"}],"active":true}]}}'
        );
        mock.addResponse('GET', '/login_state', 200, '"WORKING"');
        mock.addNotToRequest('GET', '/speed_dials');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AgentIntegration five9integration = new Five9AgentIntegration();

        List<Five9AgentIntegration.SpeedDialInfo> response = five9integration.getSpeedDials();
        Assert.areEqual(0, response.size(), 'size must be zero');

        Test.stopTest();
    }

    @IsTest
    static void testGetSpeedDialsNoCacheWithLock() {
        Test.startTest();
        MockApi mock = new MockApi();
        mock.addNotToRequest('GET', '/speed_dials');
        Test.setMock(HttpCalloutMock.class, mock);

        Five9AgentIntegration five9integration = getAuthenticatedFive9Client();

        CacheLock cacheLock = new CacheLock(five9integration.getCachePartitionName(), Five9AgentIntegration.CACHE_LOCK_SPEED_DIALS);
        cacheLock.lock();

        List<Five9AgentIntegration.SpeedDialInfo> response = five9integration.getSpeedDials();
        Assert.areEqual(0, response.size(), 'size must be zero');

        Test.stopTest();
    }
}