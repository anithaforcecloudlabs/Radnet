/*
 * ***************************************************************************************************************************
 * Apex Class Name : AgentAnalyticsDashboard
 * Created Date : 16-Sep-2024
 * @description : Agent Analytics Dashboard
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ---------------------
 * CC-603                   16-Sep-2024          Modified getTiledMetrics method
 * CC-1371                  25-Sep-2024          Updated getTiledMetrics method
 * CC-1392                  01-Oct-2024          Updated getOccupancy method to add null checks and repositioning of tiles
 * CC-1501                  21-Jan-2025          Enhancements for all Five9 BYOT functions
 * *****************************************************************************************************************************
 */
public with sharing class AgentAnalyticsDashboard {
    public enum ComponentType {
        DISPLAY_NUMBER,
        DISPLAY_LIST
    }

    public enum MetricType {
        COUNT,
        DURATION,
        PERCENTAGE
    }

    public class Metric {
        @AuraEnabled
        public String label;

        @AuraEnabled
        public String value;

        public Metric(String label, Integer value, MetricType metricType) {
            this.label = label;
            if (value == null) {
                this.value = '-';
                return;
            }
            switch on metricType {
                when COUNT {
                    this.value = String.valueOf(value);
                }
                when DURATION {
                    Integer seconds = value;
                    if (seconds < 60) {
                        this.value = seconds + 's';
                    } else if (seconds >= 60 && seconds < 3600) {
                        Integer minutes = seconds / 60;
                        Integer remainingSeconds = Math.mod(seconds, 60);
                        this.value = minutes + 'm ' + remainingSeconds + 's';
                    } else if (seconds >= 3600) {
                        Integer hours = seconds / 3600;
                        Integer remainingMinutes = Math.mod(seconds, 3600) / 60;
                        Integer remainingSeconds = Math.mod(Math.mod(seconds, 3600), 60);
                        this.value = hours + 'h ' + remainingMinutes + 'm ' + remainingSeconds + 's';
                    }
                }
                when PERCENTAGE {
                    this.value = String.valueOf(value) + '%';
                }
            }
        }
    }

    public class MetricComponent {
        @AuraEnabled
        public String title;

        @AuraEnabled
        public String icon;

        @AuraEnabled
        public String componentType;

        @AuraEnabled
        public List<Metric> metrics;

        public MetricComponent(String icon, Metric metric) {
            this.title = metric.label;
            this.icon = icon;
            this.metrics = new List<Metric>();
            this.metrics.add(metric);
            this.componentType = AgentAnalyticsDashboard.ComponentType.DISPLAY_NUMBER.name();
        }

        public MetricComponent(String icon, String title, List<Metric> metrics) {
            this.title = title;
            this.icon = icon;
            this.metrics = metrics;
            this.componentType = AgentAnalyticsDashboard.ComponentType.DISPLAY_LIST.name();
        }
    }

    private static Integer getAverageHandleTime(String userId) {
        AggregateResult[] results = [SELECT AVG(CallDurationInSeconds) avgHandleTime FROM VoiceCall WHERE CallAcceptDateTime >= TODAY AND OwnerId = :userId];
        if (results.size() == 0 || results[0].get('avgHandleTime') == null) {
            return 0;
        }
        Decimal avgHandleTime = (Decimal) results[0].get('avgHandleTime');
        return avgHandleTime.intValue();
    }

    private static List<Metric> getTimeInCurrentStatus(String userId) {
        List<Metric> metrics = new List<Metric>();
        UserServicePresence[] results = [SELECT StatusStartDate, ServicePresenceStatusId, ServicePresenceStatus.MasterLabel FROM UserServicePresence WHERE UserId = :userId AND IsCurrentState = TRUE];
        if (results.size() == 0) {
            metrics.add(new Metric('Offline', null, MetricType.DURATION));
            return metrics;
        }
        Datetime startDate = results[0].StatusStartDate;
        String currentStatus = results[0].ServicePresenceStatus.MasterLabel;
        Long timeInCurrentStatus = (Datetime.now().getTime() - startDate.getTime()) / 1000;
        metrics.add(new Metric(currentStatus, timeInCurrentStatus.intValue(), MetricType.DURATION));
        return metrics;
    }

    private static Integer getCallsHandled(String userId) {
        AggregateResult[] results = [SELECT COUNT(Id) callCount FROM VoiceCall WHERE CallAcceptDateTime >= TODAY AND OwnerId = :userId];
        if (results.size() == 0) {
            return 0;
        }
        Integer callCount = (Integer) results[0].get('callCount');
        return callCount;
    }

    private static Integer getOccupancy(String userId) {
        Decimal totalAvailableTimeInSeconds = 0;
        Decimal totalOnCallTimeInSeconds = 0;
        
        AggregateResult[] results = [
            SELECT SUM(StatusDuration) timeInSeconds
            FROM UserServicePresence
            WHERE UserId = :userId AND StatusStartDate >= TODAY AND ServicePresenceStatus.DeveloperName='DH_AvailableForVoice' AND IsAway = FALSE
        ];
        
        if (results.size() > 0) {
            totalAvailableTimeInSeconds = (Decimal) results[0].get('timeInSeconds');
        }
        
        AggregateResult[] results1 = [
            SELECT SUM(CallDurationInSeconds) callTimeInSeconds
            FROM VoiceCall
            WHERE Owner.Id=:userId AND CallStartDateTime >= TODAY
        ];
        
        if (results1.size() > 0) {
            totalOnCallTimeInSeconds = (Decimal) results1[0].get('callTimeInSeconds');
        }
        
        if (totalAvailableTimeInSeconds == null || totalOnCallTimeInSeconds == null || totalAvailableTimeInSeconds == 0) {
            return 0;
        }
        
        Decimal occupancyPercentage = (totalOnCallTimeInSeconds / totalAvailableTimeInSeconds) * 100;
        return occupancyPercentage.intValue();
    }

    private static List<Metric> getIdleTimeByStatus(String userId) {
        List<Metric> data = new List<Metric>();
        AggregateResult[] results = [
            SELECT SUM(StatusDuration) timeInSeconds, ServicePresenceStatus.MasterLabel statusName
            FROM UserServicePresence
            WHERE UserId = :userId AND StatusStartDate >= TODAY AND IsAway = TRUE AND IsCurrentState = FALSE
            GROUP BY ServicePresenceStatus.MasterLabel
        ];
        if (results.size() == 0) {
            return data;
        }
        for (AggregateResult result : results) {
            Metric metric = new Metric((String) result.get('statusName'), ((Decimal) result.get('timeInSeconds')).intValue(), MetricType.DURATION);
            data.add(metric);
        }
        return data;
    }
    /**
     * @Jira CC-603
     * @description   - This method returns the List of MetricComponents to be displayed on Analytics Dashboard
     * @return        - List<MetricComponent>
     **/
    @AuraEnabled
    public static List<MetricComponent> getTiledMetrics() {
        String userId = UserInfo.getUserId();

        List<MetricComponent> metrics = new List<MetricComponent>();

        /*Five9SupervisorIntegration five9client = new Five9SupervisorIntegration();
        String agentId = five9client.getAgentIDForEmail(UserInfo.getUserEmail());
        Map<String, Five9SupervisorIntegration.Stat> stat = five9client.getAgentStat(agentId);*/

        List<Metric> callsInQueue = new List<Metric>();
        List<Metric> longestWaitTimeInQueue = new List<Metric>();
        
        /*
        for (String queueName : stat.keySet()) {
            callsInQueue.add(new Metric(queueName, stat.get(queueName).totalCalls, MetricType.COUNT));
            longestWaitTimeInQueue.add(new Metric(queueName, (Integer) stat.get(queueName).longestWaitingCall / 1000, MetricType.DURATION));
        }*/

        MetricComponent mcIdleTimeByStatus = new MetricComponent('utility:chart', 'Idle Time by Status', getIdleTimeByStatus(userId));
        metrics.add(mcIdleTimeByStatus);

        MetricComponent mcCallsHandled = new MetricComponent('utility:call', new Metric('Calls Handled', getCallsHandled(userId), MetricType.COUNT));
        metrics.add(mcCallsHandled);

        MetricComponent mcTimeInCurrentStatus = new MetricComponent('utility:clock', 'Time in Current Status', getTimeInCurrentStatus(userId));
        metrics.add(mcTimeInCurrentStatus);

        MetricComponent mcAverageHandledTime = new MetricComponent('utility:clock', new Metric('Average Handle Time', getAverageHandleTime(userId), MetricType.DURATION));
        metrics.add(mcAverageHandledTime);

        MetricComponent mcOccupancy = new MetricComponent('utility:chart', new Metric('Occupancy', getOccupancy(userId), MetricType.PERCENTAGE));
        metrics.add(mcOccupancy);

        MetricComponent mcCallsInQueue = new MetricComponent('utility:queue', 'Calls in Queue', callsInQueue);
        metrics.add(mcCallsInQueue);

        MetricComponent mcLongestWaitTimeInQueue = new MetricComponent('utility:clock', 'Longest Wait Time in Queue', longestWaitTimeInQueue);
        metrics.add(mcLongestWaitTimeInQueue);

        return metrics;
    }
}