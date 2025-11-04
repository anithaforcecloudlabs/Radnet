import { LightningElement, api, wire } from 'lwc';
import getRecordsForLL from '@salesforce/apex/DH_SearchSiteDirectory.getRecordsForLL';

export default class DH_searchSiteDirectoryLL extends LightningElement {
    showModal = false;
    accounts;
    error;
    

  @api show() {
    this.showModal = true;
  }
  handleDialogClose() {
   this.dispatchEvent(new CustomEvent('closemodal'));
  }

  @wire(getRecordsForLL)
   wiredAccounts({ error, data }) {
       if (data) {
           this.accounts = data;
           this.error = undefined;
       } else if (error) {
           this.error = error;
           this.accounts = undefined;
       }
   }
}