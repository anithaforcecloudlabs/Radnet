import { LightningElement, wire, api } from 'lwc';
import getPracticeforModalitySearch from '@salesforce/apex/DH_KMUtility.getPracticeforModalitySearch';
import { loadStyle } from 'lightning/platformResourceLoader';
import horizontalCheckbox from '@salesforce/resourceUrl/horizontalCheckbox';
export default class DH_practiceOptions extends LightningElement {
  practiceOptions = [];
  selectedPracticeValue = [];
  practiceAllSelected = false;
  wiredPracticeList = [];
  practiceOptionsAll = [];
  selectedPRVal = [];

  //get practice options
  @wire(getPracticeforModalitySearch)
  wiredpractice(result) {
    this.wiredPracticeList = result;
    if (result.data) {
      this.practiceOptions = result.data.map((practice) => {
        return { 'label': practice.Practice__c, 'value': practice.Practice__c, 'region': practice.Region__c };
      });
      this.practiceOptions.push({ 'label': 'All', 'value': 'All', 'region': 'All' });
      this.practiceOptionsAll = [...this.practiceOptions];
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.practiceOptions = undefined;
    }
  }

  // load custom css static resource
  connectedCallback() {
    if (this.isCssLoaded) return
    this.isCssLoaded = true;
    loadStyle(this, horizontalCheckbox).then(() => {
      console.log('loaded');
    })
      .catch(error => {
        console.log('error to load ' + error);
      });
  }

  //reset selected practios options
  @api
  clearAllPractices() {
    this.selectedPRVal = [];
    this.selectedPracticeValue = [];
    this.practiceAllSelected = false;
    this.practiceChange();
  }

  //filter practice option based on selected regions
  @api
  regionsFilters(regionVal) {
    this.practiceOptions = this.practiceOptionsAll.filter(function (item) {
      return regionVal.indexOf(item.region) !== -1;
    });
  }

  //handle practis option selection
  handlePracticheChange(event) {
    let prval = event.detail.value;
    if (this.practiceAllSelected === true) {
      prval = this.removeOptionFromArray(prval, 'All');
    }
    this.selectedPracticeValue = [];
    if (prval.includes('All')) {
      this.practiceAllSelected = true;
      this.selectedPRVal = [];
      this.selectedPRVal.push('All');
      this.selectedPracticeValue = [];
      this.practiceOptions.forEach(opt => {
        if (opt.value !== 'All') {
          this.selectedPracticeValue.push(opt.value);
        }
      });
    } else {
      this.selectedPracticeValue = prval;
      this.selectedPRVal = prval;
      this.practiceAllSelected = false;
    }
    this.practiceChange();
  }

  //remove element from array
  removeOptionFromArray(arr, option) {
    arr = arr.filter(function (item) {
      return item !== option
    });
    return arr;
  }

  //reset all practice options
  resetPracticeAll() {
    this.selectedPracticeValue = [];
  }

  //reset practice options other that "All"
  resetPracticeOther() {
    for (let i = 0; i < this.selectedPracticeValue.length; i++) {
      if (this.selectedPracticeValue[i] !== 'All') {
        this.selectedPracticeValue.splice(i, 1);
      }
    }
  }

  //send selected practice value to parent
  practiceChange() {
    this.dispatchEvent(new CustomEvent('practicechange', { detail: { selectedpracticevalue: this.selectedPracticeValue } }));
  }
}