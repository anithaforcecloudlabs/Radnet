import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContacts from '@salesforce/apex/RelatedContactController.getContacts';

import BUDGET_SPENT_FIELD from '@salesforce/schema/Contact.Budget_Spent__c';

export default class LwcPhysiciansBudgetWarning extends LightningElement {
    @api recordId;

    connectedCallback() {
        const { recordId } = this;
        getContacts({recordId}).then((result) => {
            let showWarning = false;
            let showError = false;

            (result || []).forEach((item) => {
                const { Contact } = item;

                if (Contact) {

                    if (Contact[BUDGET_SPENT_FIELD.fieldApiName] > 450) {
                        showError = true;
                    }

                    if (Contact[BUDGET_SPENT_FIELD.fieldApiName] >=350 &&  Contact[BUDGET_SPENT_FIELD.fieldApiName] <=450) {
                        showWarning = true;
                    }
                }
            });

            if (showWarning || showError) {
                const message = showError && 'One or more physicians has a budget spent of over $450+.' || showWarning && 'One or more physicians has a budget spent of over $350.';

                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: message,
                    variant: showError && 'error' || showWarning && 'warning',
                    mode: 'sticky'
                });
    
                this.dispatchEvent(event);
            }
        });
    }
}