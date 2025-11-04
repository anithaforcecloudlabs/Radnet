import { LightningElement, track, wire, api } from "lwc";
import findRecords from "@salesforce/apex/DH_SiteSearchOptions.findRecords";
import DH_SiteCodeTimeOut from '@salesforce/label/c.DH_SiteCodeTimeOut';
export default class DH_siteSearchCustomLookup extends LightningElement {

  //component used to get site results to show in dropdown if user searches with site code
  @track recordsList;
  @track searchKey = "";
  @api selectedValue;
  @api selectedRecordId;
  @api objectApiName;
  @api iconName;
  @api lookupLabel;
  @api selectedCoast;
  @track message;
  hasRecords = false;
  timeout;

  //handle focus leave
  onLeave() {
    setTimeout(() => {
      this.searchKey = "";
      this.recordsList = [];
      this.hasRecords = false;
    }, 300);
  }

  //handle record selection
  onRecordSelection(event) {
    this.selectedRecordId = event.target.dataset.key;
    this.selectedValue = event.target.dataset.name;
    this.searchKey = "";
    this.onSeletedRecordUpdate();
  }

  //handle search key change
  handleKeyChange(event) {       
    const searchKey = event.target.value;
    this.searchKey = searchKey;
      window.clearTimeout(this.timeout);     
      this.timeout = setTimeout(() => {
        this.getLookupResult();
      }, DH_SiteCodeTimeOut);
  }

  //remove selected record
  @api
  removeRecordOnLookup(event) {
    this.searchKey = "";
    this.selectedValue = '';
    this.selectedRecordId = '';
    this.recordsList = [];
    this.hasRecords = false;
    this.onSeletedRecordUpdate();
  }

  //Get all sites matches search key
  getLookupResult() {
    findRecords({ searchKey: this.searchKey, objectName: this.objectApiName, selectedCoast: this.selectedCoast })
      .then((result) => {
        if (result.length === 0 || this.searchKey.length==0) {
          this.recordsList = [];
          this.hasRecords = false;
          this.message = "No Records Found";
        } else {
          this.recordsList = result;
          this.hasRecords = true;
          this.message = "";
        }
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.recordsList = undefined;
        this.hasRecords = false;
      });
  }

  //send selected value to parent component
  onSeletedRecordUpdate() {
    const passEventr = new CustomEvent('recordselection', {
      detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
    });
    this.dispatchEvent(passEventr);
  }
}