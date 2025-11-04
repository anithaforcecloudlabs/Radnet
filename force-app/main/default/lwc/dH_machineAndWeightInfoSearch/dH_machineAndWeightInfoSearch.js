/******************************************************************************************************************************************************
 * 
 * @Created Date      :  03/30/2024
 * 
 * @description       :  This component serves to obtain and display the data for Machine & Weight info search functionality in Modality Search LWC component
 * 
 * @JIRA Id           :  CC-21, CC-819
 * */ 
import { LightningElement, track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import horizontalCheckbox from '@salesforce/resourceUrl/horizontalCheckbox';
import fuselib from "@salesforce/resourceUrl/fusejs";
import markjs from "@salesforce/resourceUrl/markjs";
import { NavigationMixin } from 'lightning/navigation';
// APEX METHOD IMPORTS
import getSiteList from '@salesforce/apex/DH_MachineWeightController.getSiteList';
import getMachineRecordsBasedOnModality from '@salesforce/apex/DH_MachineWeightController.getMachineRecordsBasedOnModality';
import getMachineRecordsBasedOnPractice from '@salesforce/apex/DH_MachineWeightController.getMachineRecordsBasedOnPractice';
import getMachineRecordsBasedOnSites from '@salesforce/apex/DH_MachineWeightController.getMachineRecordsBasedOnSites';
import getUserType from '@salesforce/apex/DH_KMUtility.getUserType';
// CUSTOM LABEL IMPORTS
import DH_No_Records_Found from '@salesforce/label/c.DH_No_Records_Found';

export default class DH_machineAndWeightInfoSearch extends NavigationMixin(LightningElement) {

  @track isGuestUser;
  @track searchData = [];
  @track originalData = [];
  initialSearchRecords = [];
  
  @track modalitiesOptions = [];
  @track practiceOptions = [];
  @track Modality = '';

  @track selectedModalitiesValue = [];
  @track selectedPracticeValue = [];
  @track selectedSiteSearchValue = '';
  @track selectedValues = { Practice: '', Modalities: '', Sites: '' };
  @track isConnected = false;
  @track showModality = false;
  @track showSearchedValues = false;
  @track siteC = '';
  @track siteList;
  @track searchKey = '';

  // TABLE SORT 
  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  sortedBy;
  sortedColumn = '';
  sortedDirection = '';

  // TABLE SORT FLAGS
  isSiteCodeSort = false;
  isSiteNameSort = false;
  isPracticeSort = false;
  isAsc = false;
  isDsc = false; 

  // MODALITY COLUMN FLAGS
  @track showMRI = true;
  @track showCT = true;
  @track showXray = true;
  @track showDexa = true;
  @track showFluoro = true;
  @track showUs = true;
  @track showNm = true;
  @track showPet = true;
 
  @track dataVisible;
  @track dataCount;
  @track dataCountVisible = false;
  
  // SITE SEARCH BAR
  fuseInitialized = false;
  @track searchKeySite = '';
  selectedValue;
  message = '';
  picklistOrdered;
  selectedSearchResult;
  @track scId = '';
  showSpinner = false;
  fuseSearchKey = '';

  // FOR ERROR MESSAGE 
  @track error;
  errorMessage = '';
  hideResult = true;
  @track apexExceptionMsg = DH_No_Records_Found;

  //MARKUP TEXT
  clearAll = 'Clear All';
  siteOptTitle = 'Site Code / Name:';
  modalityOptTitle = 'Modalities :';
  pracOptTitle = 'Practices :';
  tableTitle = 'Machine and Weight Info Details';
  isChecked = false; // CC-651
  isChekedSKey = ''; // CC-651
  timeoutID;

  connectedCallback() {
    if (this.fuseInitialized) {
      return;
    }
    this.fuseInitialized = true;
    this.getUserTypeFun();
    Promise.all([loadScript(this, fuselib), loadScript(this, markjs), loadStyle(this, horizontalCheckbox)])
      .then(
        () => {
          getSiteList().then((result) => {
            this.picklistOrdered = result.map((option) => ({ label: option, value: option }));
            this.picklistOrdered = this.picklistOrdered.sort((a, b) => {
              if (a.label < b.label) {
                return -1
              }
            })
          })
        })
      .catch((error) => {
        console.log('ERR : ' + JSON.stringify(error));
      });
  }

  async getUserTypeFun() {
    try {
      this.isGuestUser = await getUserType();
      this.error = undefined;
    } catch (error) {
      this.isGuestUser = undefined;
      this.error = error;
    }
  }

  // MODALITY HANDLER
  handleModalityChange(event) {
    this.selectedModalitiesValue = event.detail.selectedmodalityvalue;
    if (!this.selectedModalitiesValue.includes('CT')) {
      this.showCT = false;
    } else {
      this.showCT = true;
    }

    if (!this.selectedModalitiesValue.includes('MRI')) {
      this.showMRI = false;
    } else {
      this.showMRI = true;
    }

    if (!this.selectedModalitiesValue.includes('X Ray')) {
      this.showXray = false;
    } else {
      this.showXray = true;
    }

    if (!this.selectedModalitiesValue.includes('Dexa')) {
      this.showDexa = false;
    } else {
      this.showDexa = true;
    }

    if (!this.selectedModalitiesValue.includes('Fluoroscopy')) {
      this.showFluoro = false;
    } else {
      this.showFluoro = true;
    }

    if (!this.selectedModalitiesValue.includes('Ultrasound')) {
      this.showUs = false;
    } else {
      this.showUs = true;
    }

    if (!this.selectedModalitiesValue.includes('Nuclear Medicine')) {
      this.showNm = false;
    } else {
      this.showNm = true;
    }

    if (!this.selectedModalitiesValue.includes('PET / CT')) {
      this.showPet = false;
    } else {
      this.showPet = true;
    }

    if (this.selectedModalitiesValue.length === 0) {
      this.resetModalitiesFlags();
    }
    this.getModalitiesSearchData();
  }

  // MODALITY SEARCH RESULT
  getModalitiesSearchData() {
    
    this.errorMessage = '';
    this.showSpinner = true;
    getMachineRecordsBasedOnModality(
      { modalities: this.selectedModalitiesValue, practices: this.selectedPracticeValue, siteCodeName: this.selectedSiteSearchValue })
      .then(result => {
        this.selectedValues = { Modalities: '' };
        if (this.selectedSiteSearchValue !== '') {
          result = result.filter(res => res.siteName.toLowerCase() === this.selectedSiteSearchValue.toLowerCase())
        }
        this.searchData = result;
        this.initialSearchRecords = result;
        this.originalData = this.searchData;

        if (this.searchData.length === 0) {
          this.hideResult = true;
          this.isConnected = false;
        } else {
          this.hideResult = false;
          this.isConnected = true;
        }
        if(this.searchKey.length > 0){
          this.handleSearchCData();
        }
        this.resetSortColumn();
      })
      .catch(error => {
       
        let selectedModalitiesValueErrorMsg = [...this.selectedModalitiesValue];
        if (this.selectedModalitiesValue.length > 0) {
          let index = selectedModalitiesValueErrorMsg.indexOf('NP');
          selectedModalitiesValueErrorMsg[index] = 'Other';
        }
        if (this.selectedModalitiesValue.length > 0 && this.selectedPracticeValue.length > 0 && error.body.message === this.apexExceptionMsg) {
          this.errorMessage = 'No record found for ' + selectedModalitiesValueErrorMsg.join(', ') + ' in Practice ' + this.selectedPracticeValue.join(', ') + '.';
        }
        else if (this.selectedModalitiesValue.length > 0 && this.selectedSiteSearchValue.length > 0 && error.body.message === this.apexExceptionMsg) {
          this.errorMessage = 'No record found for ' + selectedModalitiesValueErrorMsg.join(', ') + ' in Site ' + this.selectedSiteSearchValue + '.';
        }
        this.setValuesForErrorDisplay();
      })
    this.showSpinner = false;
  }

  // RESETS MODALITIES FLAG TRUE TO SHOW ALL MODALITIES
  resetModalitiesFlags() {
    this.showMRI = true;
    this.showCT = true;
    this.showXray = true;
    this.showDexa = true;
    this.showFluoro = true;
    this.showUs = true;
    this.showNm = true;
    this.showPet = true;
  }

  // PRACTICE HANDLER
  handlePracticheChange(event) {
    this.selectedPracticeValue = event.detail.selectedpracticevalue;
    this.getPracticeSearchData();
    this.showModality = true;
    if (this.selectedPracticeValue.length === 0 && this.selectedSiteSearchValue.length === 0) {
      this.showModality = false;
      this.resetModalitiesFlags();
    }
  }

  // PRACTICE SEARCH RESULT
  getPracticeSearchData() {
    this.errorMessage = '';
    this.showSpinner = true;
    getMachineRecordsBasedOnPractice({ practices: this.selectedPracticeValue, siteCodeName: this.selectedSiteSearchValue })
      .then(result => {
        this.selectedValues = { Practice: '' };
        if (this.selectedSiteSearchValue.length !== 0) {
          result = result.filter(res => res.siteName.toLowerCase() === this.selectedSiteSearchValue.toLowerCase())
        }
        this.searchData = result;
        this.originalData = this.searchData;
        this.initialSearchRecords = result;

        if (this.searchData.length === 0) {
          this.hideResult = true;
          this.isConnected = false;
        } else {
          this.hideResult = false;
          this.isConnected = true;
        }

        if(this.searchKey.length>0){
          this.handleSearchCData();
        }
        this.resetSortColumn();
      })
      .catch(error => {

        if (this.selectedSiteSearchValue.length > 0 && error.body.message === this.apexExceptionMsg) {
          this.errorMessage = 'Please select correct Practice options.'
        }
        this.setValuesForErrorDisplay();
      })
    this.showSpinner = false;
  }

  // SHOW SITES IN SEARCH
  handleKeyChange(event) {
    event.preventDefault()
    const input = event.target.value.toLowerCase();
    this.searchKeySite = event.target.value;
    this.siteList = this.picklistOrdered.filter((picklistOption) => picklistOption.label.toLowerCase().includes(input));
    if (this.siteList.length === 0) {
      this.message = 'No Records Found';
    } else {
      this.message = '';
    }
  }

  // CLEAR SITE OPTIONS LIST WHEN NOT IN FOCUS
  onLeave() {
    setTimeout(() => {
      this.siteList = null;
    }, 300);
  }

  // REMOVES SELECTED SITE OPTION
  removeRecordOnLookup() {
    this.searchKeySite = '';
    this.selectedValue = '';
    this.siteList = null;
    this.selectedSiteSearchValue = '';
    if (this.selectedPracticeValue.length === 0 && this.selectedSiteSearchValue.length === 0) {
      this.showModality = false;
      this.resetModalitiesFlags();
    }
    this.getPracticeSearchData()
  }

  // SITE SEARCH HANDLER
  handleSiteSearchKeyword(event) {
    event.preventDefault();
    this.selectedSiteSearchValue = event.currentTarget.dataset.name;
    this.selectedValues.Sites = this.selectedSiteSearchValue;
    this.selectedValue = this.selectedSiteSearchValue
    event.preventDefault();
    this.siteList = null;
    this.getSitesSearchData();
    this.showModality = true;
    if (this.selectedPracticeValue.length === 0 && this.selectedSiteSearchValue.length === 0) {
      this.showModality = false;
      this.resetModalitiesFlags();
    }
    this.dispatchEvent(event);
    this.showSearchedValues = false;
  }

  // SITE SEARCH RESULT
  getSitesSearchData() {
    this.errorMessage = '';
    this.showSpinner = true;
    getMachineRecordsBasedOnSites({ practices: this.selectedPracticeValue, siteCodeName: this.selectedSiteSearchValue })
      .then(result => {
        this.selectedValues = { Sites: '' };
        this.originalData = this.searchData;
        this.initialSearchRecords = result;
        this.searchData = result;
        if (this.searchData.length === 0) {
          this.hideResult = true;
          this.isConnected = false;
        } else {
          this.hideResult = false;
          this.isConnected = true;
        }
        if(this.searchKey){
          this.handleSearchCData();
        }
        this.resetSortColumn();
      })
      .catch(error => {

        if (this.selectedPracticeValue.length > 0 && error.body.message === this.apexExceptionMsg) {
          this.errorMessage = 'Please select correct Site option.'
        }
        else if (this.selectedPracticeValue.length === 0 && error.body.message === this.apexExceptionMsg) {
          this.errorMessage = 'No Record Found.'
        }
        this.setValuesForErrorDisplay();
      });
    this.showSpinner = false;
  }

  // RESETS COLUMN SORT IN TABLE
  resetSortColumn() {
    this.resetModalityTableSortColumn();
    this.sortedDirection = 'desc';
    this.isSiteCodeSort = true;
    this.isAsc = false;
    this.sortModalityTableData('siteCode');
  }
  
  removeOptionFromArray(arr, option) {
    arr = arr.filter(function (item) {
      return item !== option
    });
    return arr;
  }

  // SEARCH IN RESULTS TABLE 
 // CC-651
  handleSearchCData() {
    this.showSpinner = true;
    let recs = this.initialSearchRecords;
    const options = {
      includeScore: true,
      includeMatches: true,
      useExtendedSearch:true,
      matchAllTokens: true,
      shouldSort:true,
      threshold: this.isChecked ? -0.1:0.1,
      keys: [
        'siteCode', 'siteName', 'practice', 'xRay.xRayWeight', 'fluoro.fluoroWeight', 'dexa.dexaWeight',
        'ultrasound.usWeight', 'mri.mriRoom', 'mri.mriDescription', 'mri.mriWeight', 'mri.mriMachine',
        'ct.ctWeight', 'ct.ctMachine', 'ct.ctSlice', 'nm.nmWeight', 'petct.petctWeight'
      ]
    };
    const fuse = new Fuse(recs, options);
    this.searchData = fuse.search(this.fuseSearchKey);
    this.searchData = this.searchData.map(a => a.item);
    if(this.isChecked)
    {
      this.searchData =  this.searchData.filter(a => JSON.stringify(a).toLowerCase().includes(this.searchKey.toLowerCase()));
      
    }
    this.searchData = [...this.searchData];
    this.showSpinner = false;
  }

  // BUILD SEARCHKEY FOR FUSE
  // CC-651
  buildSearchKeyForFuse(sKey) {
    var skeyArr = [];
    var sKeyOR = '';
    var sKeyAnd = '';
    var returnSKey = '';
    this.isChekedSKey = sKey; // Add by Mohit
    skeyArr = sKey.split(' ');
    if (skeyArr.length === 1 && skeyArr!=null) {
      returnSKey = "'" + sKey;
    } 
    else if (skeyArr.length > 1 && !this.isChecked) {
      for (let i = 0; i < skeyArr.length; i++) {
          sKeyOR += " | '" + skeyArr[i];
        sKeyAnd += " '" + skeyArr[i];
      }
      returnSKey = sKeyAnd + sKeyOR;
    } 
     else if (skeyArr.length > 1 &&  this.isChecked) {
      for (let i = 0; i < skeyArr.length; i++) {
        sKeyAnd += " '" + skeyArr[i];
      }
      returnSKey = sKeyAnd;
    } 
    else {
     returnSKey = "'" + sKey;
    } 
    return returnSKey;
  } 
  
  // TABLE SEARCH HANDLER
  // CC-651
  handleSearch(event) {
    this.unmarkKeywords();
    clearTimeout(this.timeoutID);
    this.searchKey = event.target.value;
    this.timeoutID = setTimeout(() => {      
      if (this.searchKey) {
        this.resetModalityTableSortColumn();
        this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey.trim()); // CC-651
        this.handleSearchCData();
      } else {
        this.searchData = this.initialSearchRecords;
        this.resetSortColumn();
      }
    }, 200);
  }

  // HIGHLIGHT TABLE SEARCH
  handleHighlight(sKey) {
    this.unmarkKeywords();
    let selected = this.template.querySelectorAll('.content');
    for (let i = 0; i <= selected.length; i++) {
      let ob = new Mark(selected[i]);
      ob.mark(sKey);
    }
  }

   // CC-651-Highlight Exact match searched text inside tables 
  handleHighlightSentence(sKey) {
       let selected = this.template.querySelectorAll('.content');
        selected.forEach(element => {
      var ob = new Mark(element);
      ob.mark(sKey, {
        separateWordSearch: false, 
        className: 'a0',
        });
    });
      
  }

  // CC-651 Initiate Search for exact match search text inside tables
  handleCheckboxChange(event){
    this.isChecked = event.target.checked;
    this.unmarkKeywords();
      if(this.searchKey){
       this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey.trim());
      this.handleSearchCData();
      }
    }

  //Unmark previously highlighted keywords
  unmarkKeywords() {
    let selectedElem = this.template.querySelectorAll('.content');
    for (let i = 0; i <= selectedElem.length; i++) {
      let ob = new Mark(selectedElem[i]);
      ob.unmark();
    }
  }

  // TABLE SEARCH RELATED
  // CC-651
  updateRecordsHandler(event) {
    this.dataVisible = [...event.detail.records];
    this.dataCount = event.detail.rccount;
    this.dataCountVisible = this.dataCount > 0 ? true : false;
      if(this.dataCountVisible){
      this.unmarkKeywords();
        if(!this.isChecked){
      setTimeout(() => {
        this.handleHighlight(this.searchKey);
      }, '200');
    } else {
       setTimeout(() => {
        this.handleHighlightSentence(this.searchKey);
      }, '200');
    } 
    }
  }

  // RESET SORT TABLE MODALITY PROCEDURE
  resetModalityTableSortColumn() {
    this.isSiteCodeSort = false;
    this.isSiteNameSort = false;
    this.isPracticeSort = false;
  }

  // TABLE SORT HANDLER 
  sortPractice(event) {
    const sortcolumnNm = event.currentTarget.dataset.name;
    this.resetModalityTableSortColumn();
    if (sortcolumnNm === 'siteCode') {
      this.isSiteCodeSort = true;
    } else if (sortcolumnNm === 'siteName') {
      this.isSiteNameSort = true;
    } else if (sortcolumnNm === 'practice') {
      this.isPracticeSort = true;
    } else {
      this.isSiteCodeSort = true;
    }
    this.sortModalityTableData(sortcolumnNm);
  }

  // SORT SEARCH RESULT TABLE
  sortModalityTableData(sortColumnName) {
    // check previous column and direction
    if (this.sortedColumn === sortColumnName) {
      this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortedDirection = 'asc';
    }

    // check arrow direction
    if (this.sortedDirection === 'asc') {
      this.isAsc = true;
      this.isDsc = false;
    } else {
      this.isAsc = false;
      this.isDsc = true;
    }

    // check reverse direction
    let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
    this.sortedColumn = sortColumnName;

    // sort the data
    this.searchData = JSON.parse(JSON.stringify(this.searchData)).sort((a, b) => {
      if (typeof a[sortColumnName] === 'number') {
        a = a[sortColumnName] ? a[sortColumnName] : 0;  // Handle null values
      } else {
        a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : '';  // Handle null values
      }

      if (typeof b[sortColumnName] === 'number') {
        b = b[sortColumnName] ? b[sortColumnName] : 0;  // Handle null values
      } else {
        b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';  // Handle null values
      }
      return a > b ? 1 * isReverse : -1 * isReverse;
    });
  }


  // PRACTICE OPTIONS CLEAR
  handlePracticeClear() {
    this.dataVisible = [];
    this.searchData = [];
    this.template.querySelector('c-d-h_practice-options').clearAllPractices();
    if (this.selectedPracticeValue.length === 0 && this.selectedSiteSearchValue.length === 0) {
      this.handleModalityClear();
      this.showModality = false;
      this.resetModalitiesFlags();

    }
  }

  // MODALITY OPTIONS CLEAR
  handleModalityClear() {
    this.template.querySelector('c-d-h_modality-options').clearAllModalities();
    this.resetModalitiesFlags();

  }

  // HANDLE CLEAR ALL FOR COMBINE SEARCH
  handleClear() {
    this.isConnected = false;
    this.searchData = [];
    this.dataVisible = [];  
    this.initialSearchRecords = [];
    this.selectedModalitiesValue = [];
    this.selectedPracticeValue = [];
    this.selectedSiteSearchValue = '';
    this.searchResults = null;
    this.siteList = null;
    this.hideResult = true;
    this.showModality = false;
    this.resetModalitiesFlags();
    this.resetModalityTableSortColumn();
    this.searchKeySite = '';
    this.selectedValue = '';
    this.searchKey = '';
    //CC-651-To clear the checkbox on Clear All
    this.isChecked=false;
    const checkbox = this.template.querySelector('lightning-input[data-id="exactMatchCheckbox"]');
    if (checkbox) {
        checkbox.checked = false;
    }
    this.template.querySelector('c-d-h_practice-options').clearAllPractices();
    this.template.querySelector('c-d-h_modality-options').clearAllModalities();
  }

  clearOptions(evt) {
    evt.preventDefault();
    const qselectAllBackground = this.template.querySelectorAll('.selectbg');
    for (let i = 0; i <= qselectAllBackground.length; i++) {
      qselectAllBackground[i].style.backgroundColor = 'white';
    }
    const qselectAll = this.template.querySelectorAll('.selectsvg');
    for (let j = 0; j <= qselectAll.length; j++) {
      if (qselectAll[j].classList.contains('slds-show')) {
        qselectAll[j].classList.add('slds-hide');
        qselectAll[j].classList.remove('slds-show');
      }
    }
  }

  // HANDLE SITE CODE CLICK
  handleSiteCodeClick(event) {
    this.scId = event.currentTarget.dataset.scid;
    this.navigateToViewRecordPage(this.scId);
  }

  // HANDLE NAVIGATION TO VIEW SITE RECORD PAGE
  navigateToViewRecordPage(rcId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: { recordId: rcId, objectApiName: 'Account', actionName: 'view' },
   state: {
    c__source: 'MachineWeight'
   }
    });
  }

  // SET FLAGS AND VALUES FOR ERROR DISPLAY
  setValuesForErrorDisplay(){
    this.searchData = null;
    this.hideResult = true;
    this.dataCount = '';
    this.dataCountVisible = false;  
  }
  
}