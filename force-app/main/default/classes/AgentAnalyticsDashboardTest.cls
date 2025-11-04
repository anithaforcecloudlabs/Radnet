/*
 * ***************************************************************************************************************************
 * Apex Class Name : AgentAnalyticsDashboardTest
 * Created Date : 23-Sep-2024
 * @description : Test class for AgentAnalyticsDashboard
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-603                   23-Sep-2024          Original Version
 * CC-1371                  15-Sep-2024          Updated testGetTiledMetrics method
 * CC-1392                  01-Oct-2024          Updated testGetTiledMetrics method
 * CC-603                   10-Oct-2024          Added runTestCountMetric, runTestPercentageMetric,runTestDurationMetric and runTestGetTiledMetrics and did changes related to code optimization and total code coverage
 * *****************************************************************************************************************************
 */
@IsTest
public class AgentAnalyticsDashboardTest {
    /**
     * @Jira CC-603
     * @description - Creates reusable test data that can be used across multiple test methods within the same class
     **/
    @testSetup
    public static void setup() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
		User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
    }
    /**
     * @Jira CC-603
     * @description - Tests metric type COUNT
     * @param - User
     * @return - AgentAnalyticsDashboard.Metric
     **/
    static AgentAnalyticsDashboard.Metric runTestCountMetric(User scheduler) {
        AgentAnalyticsDashboard.Metric metric;
        System.runAs(scheduler) {
            metric = new AgentAnalyticsDashboard.Metric('test', 8, AgentAnalyticsDashboard.MetricType.COUNT);
        }
        return metric;
    }
    @IsTest
    static void testCountMetric() {
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        Test.startTest();
        AgentAnalyticsDashboard.Metric metricEast = runTestCountMetric(radnetSchedulerEast);
        Assert.areEqual('8', metricEast.value, 'metric value must match');
        AgentAnalyticsDashboard.Metric metricWest = runTestCountMetric(radnetSchedulerWest);
        Assert.areEqual('8', metricWest.value, 'metric value must match');
        Test.stopTest();
    }
    
    /**
     * @Jira CC-603
     * @description - Tests metric type PERCENTAGE
     * @param - User
     * @return AgentAnalyticsDashboard.Metric
     **/
    static AgentAnalyticsDashboard.Metric runTestPercentageMetric(User scheduler) {
        AgentAnalyticsDashboard.Metric metric;
        System.runAs(scheduler) {
            metric = new AgentAnalyticsDashboard.Metric('test', 8, AgentAnalyticsDashboard.MetricType.PERCENTAGE);
        }
        return metric;
    }
    @IsTest
    static void testPercentageMetric() {
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        Test.startTest();
		AgentAnalyticsDashboard.Metric metricEast = runTestPercentageMetric(radnetSchedulerEast);
        Assert.areEqual('8%', metricEast.value, 'metric value must match');
        AgentAnalyticsDashboard.Metric metricWest = runTestPercentageMetric(radnetSchedulerWest);
        Assert.areEqual('8%', metricWest.value, 'metric value must match');
        Test.stopTest();
    }

    /**
     * @Jira CC-603
     * @description - Tests metric type DURATION
     * @param - User
     * @return - AgentAnalyticsDashboard.Metric
     **/
    static AgentAnalyticsDashboard.Metric runTestDurationMetric(User scheduler) {
        AgentAnalyticsDashboard.Metric metric;
        System.runAs(scheduler) {
            metric = new AgentAnalyticsDashboard.Metric('test', 8, AgentAnalyticsDashboard.MetricType.DURATION);

            AgentAnalyticsDashboard.Metric metricMinutes = new AgentAnalyticsDashboard.Metric('test', 60, AgentAnalyticsDashboard.MetricType.DURATION);
            Assert.areEqual('1m 0s', metricMinutes.value, 'metric value must match');

            AgentAnalyticsDashboard.Metric metricMinutesAndSeconds = new AgentAnalyticsDashboard.Metric('test', 125, AgentAnalyticsDashboard.MetricType.DURATION);
            Assert.areEqual('2m 5s', metricMinutesAndSeconds.value, 'metric value must match');

            AgentAnalyticsDashboard.Metric metricHours = new AgentAnalyticsDashboard.Metric('test', 7200, AgentAnalyticsDashboard.MetricType.DURATION);
            Assert.areEqual('2h 0m 0s', metricHours.value, 'metric value must match');

            AgentAnalyticsDashboard.Metric metricHoursAndMinutes = new AgentAnalyticsDashboard.Metric('test', 7272, AgentAnalyticsDashboard.MetricType.DURATION);
            Assert.areEqual('2h 1m 12s', metricHoursAndMinutes.value, 'metric value must match');
        }
        return metric;
    }
    @IsTest
    static void testDurationMetric() {
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        Test.startTest();
        AgentAnalyticsDashboard.Metric metricEast = runTestDurationMetric(radnetSchedulerEast);
        Assert.areEqual('8s', metricEast.value, 'metric value must match');
        AgentAnalyticsDashboard.Metric metricWest = runTestDurationMetric(radnetSchedulerWest);
        Assert.areEqual('8s', metricWest.value, 'metric value must match');
        Test.stopTest();
    }

    /**
     * @Jira CC-603
     * @description - Tests the method getTiledMetrics
     * @param - User
     * @return - List<AgentAnalyticsDashboard.MetricComponent>
     **/
    static List<AgentAnalyticsDashboard.MetricComponent> runTestGetTiledMetrics(User scheduler) {
        List<AgentAnalyticsDashboard.MetricComponent> metricComponents;
        System.runAs(scheduler){
            metricComponents = AgentAnalyticsDashboard.getTiledMetrics();
            
            List<String> componentTitles = new List<String>{ 'Idle Time by Status','Calls Handled', 'Time in Current Status', 'Average Handle Time', 'Occupancy', 'Calls in Queue', 'Longest Wait Time in Queue' };

            List<String> componentTypes = new List<String>{ 'DISPLAY_LIST', 'DISPLAY_NUMBER', 'DISPLAY_LIST','DISPLAY_NUMBER', 'DISPLAY_NUMBER', 'DISPLAY_LIST', 'DISPLAY_LIST' };

            for (Integer i = 0; i < 7; i++) {
                Assert.areEqual(componentTitles[i], metricComponents[i].title, 'title must match');
                Assert.areEqual(componentTypes[i], metricComponents[i].componentType, 'component type must match');
                Assert.areNotEqual(null, metricComponents[0].metrics, 'metrics must not be null');
            }
        }
        return metricComponents;
    }
    @IsTest(SeeAllData=false)
    static void testGetTiledMetrics() {
        User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        Test.startTest();
        List<AgentAnalyticsDashboard.MetricComponent> metricComponentsEast = runTestGetTiledMetrics(radnetSchedulerEast);
        Assert.areEqual(7, metricComponentsEast.size(), 'list size must match');
        List<AgentAnalyticsDashboard.MetricComponent> metricComponentsWest = runTestGetTiledMetrics(radnetSchedulerWest);
        Assert.areEqual(7, metricComponentsWest.size(), 'list size must match');
        Test.stopTest();
    }
}