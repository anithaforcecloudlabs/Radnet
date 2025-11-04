import { LightningElement, api } from 'lwc';
import NOTES_FIELD from '@salesforce/schema/Account.Notes__c';

export default class AccountNotesComponent extends LightningElement {
    // Expose a field to make it available in the template
    fields = [NOTES_FIELD];
    
    // Flexipage provides recordId and objectApiName
    @api recordId;
    @api objectApiName;
}