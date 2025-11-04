import { LightningElement, wire } from 'lwc';
import getRegion from '@salesforce/apex/DH_KMUtility.getRegion';

export default class DH_regionOptions extends LightningElement {
  regionOptions = [];
  selectedRegionValue = [];
  regionAllSelected = false;
  selectedRGVal = [];

  //get region options
  @wire(getRegion)
  wiredregion({ error, data }) {
    if (data) {
      this.regionOptions = data.map((region) => {
        return { 'label': region, 'value': region };
      });
      this.regionOptions.push({ 'label': 'All', 'value': 'All' });
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.regionOptions = undefined;
    }
  }

  //cleare selected regions
  handleClear() {
    this.selectedRGVal = [];
    this.selectedRegionValue = [];
    this.regionAllSelected=false;
    this.regionCustomevent();
  }
  
  //handle region option selection
  handleRegionsChange(event) {
    let rgval = event.detail.value;
    if (this.regionAllSelected === true) {
      rgval = this.removeOptionFromArray(rgval, 'All');
    }
    this.selectedRegionValue = [];
    if (rgval.includes('All')) {
      this.regionAllSelected = true;
      this.selectedRGVal = [];
      this.selectedRGVal.push('All');
      this.selectedRegionValue = [];
      this.regionOptions.forEach(opt => {
        // if (opt.value !== 'All') {
          this.selectedRegionValue.push(opt.value);
        // }
      });
      
    } else {
      this.selectedRegionValue = rgval;
      this.selectedRGVal = rgval;
      this.regionAllSelected = false;
    }
    this.regionCustomevent();

  }

  //remove element from array
  removeOptionFromArray(arr, option) {
    arr = arr.filter(function (item) {
      return item !== option
    });
    return arr;
  }

  //send selected region value to parent
  regionCustomevent() {
    this.dispatchEvent(new CustomEvent('regionchange', { detail: { selectedregionvalue: this.selectedRegionValue } }));
  }
}