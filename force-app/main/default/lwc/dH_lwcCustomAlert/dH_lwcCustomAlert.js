import { LightningElement, api, wire } from 'lwc';
import getAlertValue from '@salesforce/apex/DH_CustomAlertController.getAlertValue';

export default class LwcCustomAlert extends LightningElement {
    @api recordId;
    alertData;

    // fetches recordId from url for guest user
    connectedCallback() {
        const origin = window.location.origin;
        if (origin.endsWith('site.com')) {
            const url = window.location.href;
            const regex = /\/account\/([a-zA-Z0-9]{18}|[a-zA-Z0-9]{15})\//;
            const matches = url.match(regex);
            if (matches && matches.length > 1) {
                this.recordId = matches[1];
            }
        }

        // gets alert value for the account record id
        getAlertValue({ recId: this.recordId })
            .then(data => {
                this.alertData = data;
            })
            .catch(error => {
                console.log('ERROR : ' + JSON.stringify(error));
            })

    }
}