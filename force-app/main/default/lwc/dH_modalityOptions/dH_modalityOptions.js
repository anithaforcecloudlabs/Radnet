import { LightningElement, wire, api } from 'lwc';
import getModalities from '@salesforce/apex/DH_KMUtility.getModalities';
import { loadStyle } from 'lightning/platformResourceLoader';
import horizontalCheckbox from '@salesforce/resourceUrl/horizontalCheckbox';

export default class DH_modalityOptions extends LightningElement {
  modalitiesOptions = [];
  selectedModalitiesValue = [];
  modalityeAllSelected = false;
  qselectAllaa = [];
  selectedMDVal = [];

  renderedCallback() {
    if (this.isCssLoaded) return
    this.isCssLoaded = true;
    loadStyle(this, horizontalCheckbox).then(() => {
      console.log('loaded');
    })
      .catch(error => {
        console.log('error to load ' + error);
      });
  }

  // Get Modalities Options
  @wire(getModalities)
  wiredmodality({ error, data }) {
    if (data) {
      this.modalitiesOptions = data.map((modality) => {
        if (modality.Modality__c === 'NP') {
          return { 'label': 'Other', 'value': modality.Modality__c };
        }
          return { 'label': modality.Modality__c, 'value': modality.Modality__c };
      });
      this.modalitiesOptions.push({ 'label': 'All', 'value': 'All' });
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.modalitiesOptions = undefined;
    }
  }

  // clear all selected modality options
  @api
  clearAllModalities() {
    this.selectedMDVal = [];
    this.selectedModalitiesValue = [];
    this.modalityeAllSelected=false;
    this.modalityChange();
  }
  
  //handle modality selection change
  handleModalityheChange(event) {
    let modval = event.detail.value;
    if (this.modalityeAllSelected === true) {
      modval = this.removeOptionFromArray(modval, 'All');
    }
    this.selectedModalitiesValue = [];
    if (modval.includes('All')) {
      this.modalityeAllSelected = true;
      this.selectedMDVal = [];
      this.selectedMDVal.push('All');
      this.selectedModalitiesValue = [];
      this.modalitiesOptions.forEach(opt => {
        if (opt.value !== 'All') {
          this.selectedModalitiesValue.push(opt.value);
        }
      });
    } else {
      this.selectedModalitiesValue = modval;
      this.selectedMDVal = modval;
      this.modalityeAllSelected = false;
    }
    this.modalityChange();
  }

  //remove element from array
  removeOptionFromArray(arr, option) {
    arr = arr.filter(function (item) {
      return item !== option
    });
    return arr;
  }
  //Send Selected values to parent component
  modalityChange() {
    this.dispatchEvent(new CustomEvent('modalitychange', { detail: { selectedmodalityvalue: this.selectedModalitiesValue } }));
  }
}