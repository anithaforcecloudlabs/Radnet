/* eslint-disable @lwc/lwc/no-async-operation */
/******************************************************************************************************************************************************
 * 
 * LWC Component Name : DH_specialAccomodationAndBillSearch
 * 
 * Created Date    :   3/30/2024
 * 
 * @description    : This class serves to provide the functionality for Special Accommodation and Bill search in Modality Search LWC component
 * 
 * @JIRA Id        : CC-22
 * 
 * */
import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import getPractice from '@salesforce/apex/DH_KMUtility.getPractice';
import fuselib from "@salesforce/resourceUrl/fusejs";
import markjs from "@salesforce/resourceUrl/markjs";
import getUserType from '@salesforce/apex/DH_KMUtility.getUserType';
import getHealthcarePayerNetwork from '@salesforce/apex/DH_specialAccomodationAndBillController.getHealthcarePayerNetwork';
import getSpecialAccomodationBills from '@salesforce/apex/DH_specialAccomodationAndBillController.getSpecialAccomodationBills';
export default class DH_specialAccomodationAndBillSearch extends NavigationMixin(LightningElement) {
  @track practiceOptions = [];
  @track selectedPracticeValue = [];
  @track searchDataSpecial = [];
  @track AccData = [];
  @track regionOptions = [];
  @track selectedRegionValue = [];
  @track activeSection = [];
  searchKey;
  initialSearchRecordsSpecial = [];
  initialAccSearchRecords = [];
  @track showTable = '';
  @track showAccTable = '';
  specialaccid = '';
  descid = '';

  isBillNameSort = false;
  isRegionSort = false;
  isCarrierCodeSort = false;
  isModalitySort = false;
  isPracticeSort = false;
  isProtocolDescSort = false;
  sortedColumn = '';
  sortedDirection = '';
  sortedColumnSP = '';
  sortedDirectionSP = '';

  isAsc = false;
  isDsc = false;

  isAscSP = false;
  isDscSP = false;
  showPractice = false;
  @track currentPage = 1;
  totalPages = 1;

  dataVisible;
  dataCount;
  dataCountVisible = false;
  dataVisible1;
  dataCount1;
  dataCountVisible1 = false;
  fuseInitialized = false;
  regionAllSelected = false;
  showSpinner = false;
  showNoDataSpecialBill = false;
  fuseSearchKey = '';
  showNoDataSpeAcc = false;
  fuseSearchKey = '';
  isGuestUser;
  isChecked = false; // CC-650
  isChekedSKey = ''; // CC-650
  timeoutID;

  //load fuse and markjs library
  connectedCallback() {
    if (this.fuseInitialized) {
      return;
    }
    this.fuseInitialized = true;
    this.getUserTypeFun();
    Promise.all([loadScript(this, fuselib), loadScript(this, markjs)])
      .then(
        () => {
          console.log('Loaded');
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
  // To handle change in regions Options
  handleRegionsChangeEvent(event) {
    const selectedRegions = event.detail.selectedregionvalue;
    this.selectedRegionValue = selectedRegions;
    this.showPractice = this.selectedRegionValue.length > 0 ? true : false;
    //CC-650-To clear the checkbox on Clear All
    this.isChecked = false;
    if (this.showPractice === false) {
      this.searchKey = '';
      const checkbox = this.template.querySelector('lightning-input[data-id="exactMatchCheckbox"]');
      if (checkbox) {
        checkbox.checked = false;
      }
    }
    if (this.selectedRegionValue.length <= 0) {
      this.selectedPracticeValue = [];
      this.AccData = [];
      this.initialAccSearchRecords = [];
    }
    this.getRegionsearchDataSpecial();
    this.getPracticeSearchDataAcc();
    setTimeout(() => {
      this.template.querySelector('c-d-h_practice-options').regionsFilters(this.selectedRegionValue);
    }, '200');
  }

  //handle practice selection
  handlePractticheChange(event) {
    const prval = event.detail.selectedpracticevalue;
    this.selectedPracticeValue = prval;
    getPractice({ region: this.selectedRegionValue })
      .then((result) => {
        this.practiceOptions = result;
      })
      .catch((error) => {
        this.error = error;
        this.practiceOptions = undefined;
      });
    this.getPracticeSearchDataAcc();
  }

  //fetch special bill data
  getRegionsearchDataSpecial() {
    this.showSpinner = true;
    getHealthcarePayerNetwork({ region: this.selectedRegionValue })
      .then((result) => {
        let tempdata = result.map(
          v => ({ ...v }));
        this.searchDataSpecial = tempdata;
        this.initialSearchRecordsSpecial = tempdata;
        this.error = undefined;
        if (this.searchKey) {
          this.handleSearchSpecBill();
        }

        this.resetSortColumnBills();
        this.showSpinner = false;
      })
      .catch((error) => {
        this.error = error;
        this.searchDataSpecial = undefined;
      });

  }
  //fetch special Accomodation data
  getPracticeSearchDataAcc() {
    this.showSpinner = true;
    getSpecialAccomodationBills({ region: this.selectedRegionValue, practice: this.selectedPracticeValue })
      .then((result) => {
        let tempdata = result.map(v => ({ ...v, practice: v.Practice__r.Practice_code__c, accprotocol: v.Special_Accomodation_and_Protocols__r.Name }));
        this.AccData = tempdata;
        this.initialAccSearchRecords = tempdata;
        this.error = undefined;

        if (this.searchKey) {
          this.handleSearchSpecAcc();
        }

        this.resetSortColumnAccomodation();
        this.showSpinner = false;
      })
      .catch((error) => {
        this.error = error;
        this.AccData = undefined;
      });

  }

  //get record id for NavigationMixin
  handleDescClick(event) {
    this.descid = event.currentTarget.dataset.descid;
    this.navigateToViewRecordPage(this.descid);
  }

  // Navigate to View Special Bills Page
  navigateToViewRecordPage(rcId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: { recordId: rcId, objectApiName: 'HealthcarePayerNetwork', actionName: 'view' },
      state: {
        c__source: 'SpecialAccomodation'
      }
      })
      .catch(error => {
        console.log('Error generating Url:', JSON.stringify(error));
      });
  }

  //get record id for NavigationMixin
  handleSpecialAccClick(event) {
    this.specialaccid = event.currentTarget.dataset.specialaccid;
    this.navigateToViewSpecAccRecordPage(this.specialaccid);
  }

  // Navigate to View Special Accomodation Page
  navigateToViewSpecAccRecordPage(rcId) {
    this[NavigationMixin.GenerateUrl]({
      type: 'standard__recordPage',
      attributes: { recordId: rcId, objectApiName: 'Special_accomodation_practice__c', actionName: 'view' },
    }).then(generatedUrl => {
      window.open(generatedUrl);
    });
  }

  //reset sort order for special bills
  resetSortColumnBills() {
    this.resetModalityTableSortColumn();
    this.sortedDirection = 'desc';
    this.isBillNameSort = true;
    this.isAsc = false;
    this.sortspecialBillsData('payer');
  }

  //reset sort order for special accomodation
  resetSortColumnAccomodation() {
    this.resetSpecialInstleSortColumn();
    this.sortedDirectionSP = 'desc';
    this.isPracticeSort = true;
    this.isAscSP = false;
    this.sortSpecialInstData('practice');
  }

  //build fuse search key
  // CC-650
  buildSearchKeyForFuse(sKey) {
    var skeyArr = [];
    var sKeyOR = '';
    var sKeyAnd = '';
    var returnSKey = '';
    this.isChekedSKey = sKey;
    skeyArr = sKey.split(' ');
    if (skeyArr.length === 1 && skeyArr != null) {
      returnSKey = "'" + sKey;
    }
    else if (skeyArr.length > 1) {
      for (let i = 0; i < skeyArr.length; i++) {
        sKeyOR += " | '" + skeyArr[i];
        sKeyAnd += " '" + skeyArr[i];
      }
      returnSKey = sKeyAnd + sKeyOR;
    }
    else if (skeyArr.length > 1) {
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


  //CC-650-Highlight Exact match searched text inside tables 
  handleHighlightSentence(sKey) {
    let selected = this.template.querySelectorAll('.content');
    selected.forEach(element => {
      var ob = new Mark(element);
      ob.mark(sKey, {
        separateWordSearch: false,
        className: 'a0',
        //caseSensitive: true
      });
    });

  }

  //Initiate Search for exact match search text inside tables
  handleCheckboxChange(event) {
    this.isChecked = event.target.checked;
    if (this.searchKey) {
      this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey.trim());
      this.handleSearchSpecBill();
      this.handleSearchSpecAcc();
    }
  }

  //fuse search across the columns for special accomodation table
  //  CC-650
  handleSearchSpecBill() {
    this.showSpinner = true;
    let recs = this.initialSearchRecordsSpecial;
    const options = {
      includeScore: true,
      includeMatches: true,
      useExtendedSearch: true,
      matchAllTokens: true,
      shouldSort: true,
      //isCaseSensitive: this.isChecked ? true : false,
      threshold: this.isChecked ? -0.1 : 0.1,
      keys: ['payerName', 'regionName', 'carrierCode', 'examCovered', 'modalityDescription']
    };
    const fuse = new Fuse(recs, options);
    this.searchDataSpecial = fuse.search(this.fuseSearchKey);
    this.searchDataSpecial = this.searchDataSpecial.map(a => a.item);
    if (this.isChecked) {
      this.searchDataSpecial = this.searchDataSpecial.filter(a => JSON.stringify(a).toLowerCase().includes(this.searchKey.toLowerCase()));

    }
    this.searchDataSpecial = [...this.searchDataSpecial];
    this.showSpinner = false;
  }

  //fuse search across the columns for special bills table
  //CC-650
  handleSearchSpecAcc() {
    this.showSpinner = true;
    let recs1 = this.initialAccSearchRecords;
    const options1 = {
      includeScore: true,
      includeMatches: true,
      useExtendedSearch: true,
      matchAllTokens: true,
      shouldSort: true,
      //isCaseSensitive: this.isChecked ? true : false,
      threshold: this.isChecked ? -0.1 : 0.1,
      keys: [
        'practice',
        'accprotocol',
        'Notes__c',
      ]
    };
    const fuse1 = new Fuse(recs1, options1);
    this.AccData = fuse1.search(this.fuseSearchKey);
    this.AccData = this.AccData.map(a => a.item);
    if (this.isChecked) {
      this.AccData = this.AccData.filter(a => JSON.stringify(a).toLowerCase().includes(this.searchKey.toLowerCase()));
    }
    this.AccData = [...this.AccData];
    this.showSpinner = false;
  }

  // search within tables 
  //CC-650  
  handleSearchSPAP(event) {
    this.unmarkKeywords();
    clearTimeout(this.timeoutID);
    this.searchKey = event.target.value;
    this.timeoutID = setTimeout(() => {      
      if (this.searchKey) {
        this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey.trim());
        this.resetModalityTableSortColumn();
        this.resetSpecialInstleSortColumn();
        this.handleSearchSpecBill();
        this.handleSearchSpecAcc();
      } else {
        this.searchDataSpecial = this.initialSearchRecordsSpecial;
        this.AccData = this.initialAccSearchRecords;
        this.resetSortColumnBills();
        this.resetSortColumnAccomodation();
      }
    }, 200);
  }

  handlePageChange(event) {
    this.currentPage = event.detail.currentPage;
  }

  // handle data recieved from pagination component - special bills
  //CC-650
  updateRecordsHandler(event) {
    this.dataVisible = [...event.detail.records];
    this.dataCount = event.detail.rccount;
    this.dataCountVisible = this.dataCount > 0 ? true : false;
    if (this.selectedRegionValue.length > 0 && (!this.dataCountVisible)) {
      this.showNoDataSpecialBill = true;
    }
    else {
      this.showNoDataSpecialBill = false;
    }
    if (this.dataCountVisible) {
      this.unmarkKeywords();
      if (!this.isChecked) {
        setTimeout(() => {
          this.handleHighlight(this.searchKey);
        }, 200);
      } else {
        setTimeout(() => {
          this.handleHighlightSentence(this.searchKey);
        }, 200);
      }
    }
  }

  // handle data recieved from pagination component - special accomodation
  //CC-650
  updateRecordsHandlerAcc(event) {
    this.dataVisible1 = [...event.detail.records];
    this.dataCount1 = event.detail.rccount;
    this.dataCountVisible1 = this.dataCount1 > 0 ? true : false;
    if (this.selectedRegionValue.length > 0 && this.selectedPracticeValue.length > 0 && (!this.dataCountVisible1)) {
      this.showNoDataSpeAcc = true;
    }
    else {
      this.showNoDataSpeAcc = false;
    }
    if (this.dataCountVisible1) {
      this.unmarkKeywords();
      if (!this.isChecked) {
        setTimeout(() => {
          this.handleHighlight(this.searchKey);
        }, 200);
      } else {
        setTimeout(() => {
          this.handleHighlightSentence(this.searchKey);
        }, 200);
      }
    }
  }

  // HIGHLIGHT TABLE SEARCH
  handleHighlight(sKey) {
    var selected = this.template.querySelectorAll('.content');
    for (let i = 0; i <= selected.length; i++) {
      var ob = new Mark(selected[i]);
      ob.mark(sKey);
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

  // clear practice options 
  handleClearPractices() {
    this.searchKey = '';
    this.AccData = [];
    this.dataVisible1 = [];
    this.template.querySelector('c-d-h_practice-options').clearAllPractices();
    this.isChecked = false;
    //CC-650-To clear the checkbox on Clear All
    const checkbox = this.template.querySelector('lightning-input[data-id="exactMatchCheckbox"]');
    if (checkbox) {
      checkbox.checked = false;
    }
  }

  // Reset Sort table Special Bills
  resetModalityTableSortColumn() {
    this.isBillNameSort = false;
    this.isRegionSort = false;
    this.isCarrierCodeSort = false;
    this.isModalitySort = false;
  }

  // set sort order and column name Special Bills
  sortBillName(event) {
    const sortcolumnNm = event.currentTarget.dataset.name;
    this.resetModalityTableSortColumn();
    if (sortcolumnNm === 'payerName') {
      this.isBillNameSort = true;
    } else if (sortcolumnNm === 'regionName') {
      this.isRegionSort = true;
    } else if (sortcolumnNm === 'carrierCode') {
      this.isCarrierCodeSort = true;
    } else if (sortcolumnNm === 'modalityDescription') {
      this.isModalitySort = true;
    }
    this.sortspecialBillsData(sortcolumnNm);
  }


  sortspecialBillsData(sortColumnName) {
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
    this.searchDataSpecial = JSON.parse(JSON.stringify(this.searchDataSpecial)).sort((a, b) => {
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

  // Reset Sort table Special Accomodation
  resetSpecialInstleSortColumn() {
    this.isPracticeSort = false;
    this.isProtocolDescSort = false;
  }

  // set sort order and column name  Special Accomodation
  sortPractice(event) {
    const sortcolumnNm = event.currentTarget.dataset.name;
    this.resetSpecialInstleSortColumn();
    if (sortcolumnNm === 'practice') {
      this.isPracticeSort = true;
    } else if (sortcolumnNm === 'accprotocol') {
      this.isProtocolDescSort = true;
    }
    this.sortSpecialInstData(sortcolumnNm);
  }

  // Sort table by columns Special Accomodation
  sortSpecialInstData(sortColumnName) {
    // check previous column and direction
    if (this.sortedColumnSP === sortColumnName) {
      this.sortedDirectionSP = this.sortedDirectionSP === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortedDirectionSP = 'asc';
    }
    // check arrow direction
    if (this.sortedDirectionSP === 'asc') {
      this.isAscSP = true;
      this.isDscSP = false;
    } else {
      this.isAscSP = false;
      this.isDscSP = true;
    }

    // check reverse direction
    let isReverse = this.sortedDirectionSP === 'asc' ? 1 : -1;
    this.sortedColumnSP = sortColumnName;
    // sort the data
    this.AccData = JSON.parse(JSON.stringify(this.AccData)).sort((a, b) => {
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
}