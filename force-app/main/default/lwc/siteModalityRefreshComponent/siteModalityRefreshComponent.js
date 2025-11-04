import { LightningElement, api, wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
export default class SiteModalityRefreshComponent extends LightningElement {

    @api recordId;
    originalURL = location.href;
    hasChanged = false;
    intervalId;

    connectedCallback() {
        this.intervalId = setInterval(() => {
            // Stop when navigated away from the record page
            if(!location.href.includes(this.recordId)) {
                clearInterval(this.intervalId);
                return;
            }

            this.hasChanged = this.hasChanged || location.href !== this.originalURL;
            if(this.hasChanged && location.href === this.originalURL) {
                this.hasChanged = false;
                this.fireEvent();
            }
        }, 500);
    }

    disconnectedCallback() {
        if(this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }

    @wire(getRecord, {recordId : '$recordId', fields : ['Id']})
    wiredRecord(result) {
        result?.data && (this.fireEvent());
    }

    fireEvent() {
        this.dispatchEvent(new CustomEvent('forcerefresh',
            {bubbles : true, composed : true}
        ));
    }
}