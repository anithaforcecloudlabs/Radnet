/*
* ***************************************************************************************************************************
* LWC Component Name - AgentAnalytics.js
* Created Date - 13-Sep-2024
* Function - JS class of Agent Analytics dashboard on home page of Radnet Contact Center app.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       --------------------------------------------
* CC-1371                   25-Sep-2024         Updated fetchMetrics method
* CC-1392                   01-Oct-2024         Updated fetchMetrics method
* *****************************************************************************************************************************
*/
import { LightningElement, track } from 'lwc';
import getTiledMetrics from '@salesforce/apex/AgentAnalyticsDashboard.getTiledMetrics';

export default class AgentAnalytics extends LightningElement {
    @track metrics;
    @track element;
    @track error;

    connectedCallback() {
        this.fetchMetrics();

        // Auto-refresh every 10 seconds
        this.intervalId = setInterval(() => {
            this.fetchMetrics();
        }, 10000);
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

    fetchMetrics() {
        console.log('actAgentDashboard fetching metrics...');
        getTiledMetrics()
            .then(result => {
                console.log('actAgentDashboard API response:', result);
                this.element = result.shift();
                this.metrics = result;
            })
            .catch(error => {
                console.error('actAgentDashboard API Error:', error)
                this.error = error && error.body ? error.body.message : 'Unknown error';
                this.metrics = undefined;
            });
    }
}