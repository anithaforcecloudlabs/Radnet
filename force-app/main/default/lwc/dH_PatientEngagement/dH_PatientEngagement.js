/*
* ************************************************************************************************************************************************************************
* LWC Component Name - dH_PatientEngagement.js
* Created Date - 30-Aug-2024
* Function - JS class of Patient Engagement screen.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       ---------------------
* CC-702,534,527            30-Aug-2024          Added connectedCallback method.
* CC-1154                   26-Aug-2024          Added showInboundDropdown method
* CC-1483                   09-Jan-2025          Added See More link for PE history items
* **************************************************************************************************************************************************************************
*/
import { LightningElement, api, track, wire } from 'lwc';
import getPatientEngagementList from '@salesforce/apex/DH_PatientEngagementController.getPatientEngagementList';
import noEngagementHistory from '@salesforce/label/c.DH_NoEngagementHistory';

export default class DH_PatientEngagement extends LightningElement {
    @api recordId;
    @track queueName;
    @track engagementDataList = [];
    @track showEngagementData = false;
    @track noEngagementHistory=noEngagementHistory;

    connectedCallback() {
        getPatientEngagementList({ patId: this.recordId }).then((result) => {
            const dataList = JSON.parse(result);
            this.engagementDataList = dataList.map((item) => {
                return {
                    ...item,
                    isExpanded: false, // To handle "see more/see less"
                    showSeeMore: this.isTextLong(item.subject) // To determine if "see more" is needed
                };
            });
            this.showEngagementData = this.engagementDataList.length > 0;
        });
    }

    showInboundDropdown(event){
        const inboundId = event.target.dataset.id;
        this.engagementDataList.forEach(item=>{
            if(item.displayResponseList && inboundId == item.uniqueID){
                item.inboundFlag = !item.inboundFlag;
            }
        });
    }

    // Check if the text is too long for two lines
    isTextLong(text) {
        const MAX_CHAR_COUNT = 100; // Adjusted to handle longer texts
        return text && text.length > MAX_CHAR_COUNT;
    }
    
    // Toggle the "see more" and "see less" functionality
    toggleSeeMore(event) {
        const recordId = event.target.dataset.id;
        this.engagementDataList = this.engagementDataList.map((item) => {
            if (item.uniqueID === recordId) {
                return { ...item, isExpanded: !item.isExpanded };
            }
            return item;
        });
    }
}