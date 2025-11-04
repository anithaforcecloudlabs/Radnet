import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import fuselib from '@salesforce/resourceUrl/fusejs';
import markjs from '@salesforce/resourceUrl/markjs';
import getUserType from '@salesforce/apex/DH_ModalityBasedPracticeController.getUserType';
import getNotes from '@salesforce/apex/DH_ModalityBasedPracticeController.getNotes';
import getRecordsBasedOnPractice from '@salesforce/apex/DH_ModalityBasedPracticeController.getRecordsBasedOnPractice';
import { NavigationMixin } from 'lightning/navigation';
export default class DH_modalityProcedureSearch extends NavigationMixin(LightningElement) {
  practiceOptions = [];
  modalitiesOptions = [];
  selectedPracticeValue = [];
  selectedModalitiesValue = [];
  searchData = [];
  initialSearchRecords = [];
  notesData = [];
  initialNotesSearchRecords = [];
  searchKey;
  descId = '';
  notesId = '';
  dataVisible = [];
  dataCount;
  dataCountVisible = false;

  notesCount;
  notesCountVisible = false;
  notesDataVisible = [];
  isPracticeSort = false;
  isPicModalitySort = false;
  isPDSort = false;
  isCodeSort = false;
  isBodyPartSort = false;

  isPracticeSP = false;
  isModalitySP = false;
  sortedColumn = '';
  sortedDirection = '';
  sortedColumnSP = '';
  sortedDirectionSP = '';
  formattedCode = '';
  isAsc = false;
  isDsc = false;
  isAscSP = false;
  isDscSP = false;
  hasModality = true;
  fuseInitialized = false;
  fuseSearchKey = '';
  showMPSpinner = false;
  showNotesSpinner = false;
  practiceAllSelected = false;
  showNoData = false;
  showNoDataSpec = false;
  isGuestUser;
  isChecked = false;
  isChekedSKey = '';
  timeoutID;

  connectedCallback() {
    if (this.fuseInitialized) {
      return;
    }
    this.fuseInitialized = true;
    this.getUserTypeFun();
    Promise.all([loadScript(this, fuselib), loadScript(this, markjs)])
      .then(
        () => {
          // this.initializeFuse();
        })
      .catch((error) => {
        console.log('ERR : ' + error);
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


  // Fetch data for Modality Procedure Table
  getPracticeSearchData() {
    this.showMPSpinner = true;
    getRecordsBasedOnPractice({ practice: this.selectedPracticeValue, modalities: this.selectedModalitiesValue })
      .then((result) => {
        let tempdata = result.map(v => ({ ...v }));
        for (let i = 0; i < tempdata.length; i++) {
          if (tempdata[i].procedureCode && tempdata[i].procedureCode.includes(';')) {
            tempdata[i].procedureCode = tempdata[i].procedureCode.split(';').join('\n');
          }
          if (tempdata[i].bodyParts && tempdata[i].bodyParts.includes(';')) {
            tempdata[i].bodyParts = tempdata[i].bodyParts.split(';').join('\n');
          }
        }
        this.searchData = tempdata;
        this.initialSearchRecords = tempdata;
        this.error = undefined;
        this.showMPSpinner = false;
        this.resetDefaultSortColumn();
      })
      .catch((error) => {
        this.error = error;
        this.searchData = undefined;
      });
  }

  // Fetch data for Special Instructions Table
  getNotesSearchData() {
    if (this.selectedPracticeValue !== '' && this.selectedModalitiesValue !== '') {
      this.showNotesSpinner = true;
      getNotes({ practice: this.selectedPracticeValue, modalities: this.selectedModalitiesValue })
        .then((result) => {
          for (let i = 0; i < result.length; i++) {
            if (!result[i].modalityCodes) {
              result[i].modalityCodes = 'For all modalities';
            }
          }
          let tempdata = result.map(v => ({ ...v }));
          this.initialNotesSearchRecords = tempdata;
          this.notesData = tempdata;
          this.hasModality = true;

          this.sortedDirectionSP = 'desc';
          this.isPracticeSP = true;
          this.isAscSP = false;
          this.isDscSP = true;
          this.sortSpecialInstData('practiceCodes');
          this.error = undefined;
          this.showNotesSpinner = false;
        })
        .catch((error) => {
          this.error = error;
          this.notesData = undefined;
        });
    }
    else {
      this.initialNotesSearchRecords = [];
      this.notesData = [];
    }
  }

  // Navigate to Record Page on click of Procedure Description
  handleDescClick(event) {
    this.descId = event.currentTarget.dataset.descid;
    this.navigateToViewRecordPage(this.descId);
  }

  // Handle actual Navigation to View Record Page
  navigateToViewRecordPage(rcId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: { recordId: rcId, objectApiName: 'HealthCareProcedure', actionName: 'view' },
      state: {
        c__source: 'ModalitySearch'  
      }
    });
  }



  // Clear all selected practice options
  handlePracticeClear() {
    this.dataVisible = [];
    this.searchData = [];
    this.searchKey = '';
    this.isChecked = false;
    //CC-649-To clear the checkbox on Clear All
    const checkbox = this.template.querySelector('lightning-input[data-id="exactMatchCheckbox"]');
    if (checkbox) {
      checkbox.checked = false;
    }
    this.template.querySelector('c-d-h_practice-options').clearAllPractices();
  }

  // Clear all selected modality options
  handleModalityClear() {
    this.notesData = [];
    this.notesDataVisible = [];
    this.dataVisible = [];
    this.searchData = [];
    this.searchKey = '';
    this.isChecked = false;
    //CC-649-To clear the checkbox on Clear All
    const checkbox = this.template.querySelector('lightning-input[data-id="exactMatchCheckbox"]');
    if (checkbox) {
      checkbox.checked = false;
    }
    this.template.querySelector('c-d-h_modality-options').clearAllModalities();
  }

  //reset sort order for procedure column
  resetDefaultSortColumn() {
    this.resetModalityTableSortColumn();
    this.sortedDirection = 'desc';
    this.isPracticeSort = true;
    this.isAsc = false;
    this.sortModalityTableData('practice');
  }

  // Initiate Search inside table
  handleSearchChange(event) {
    this.unmarkKeywords();
    clearTimeout(this.timeoutID);
    this.searchKey = event.target.value;
    this.timeoutID = setTimeout(() => {
      if (this.searchKey) {
        this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey.trim());
        this.resetModalityTableSortColumn();
        this.handleSearchProcedureData();
      } else {
        this.searchData = this.initialSearchRecords;
        this.resetDefaultSortColumn();
      }
    }, 200);
  }

  //build fuse search key
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
    else if (skeyArr.length > 1 && !this.isChecked) {
      for (let i = 0; i < skeyArr.length; i++) {
        sKeyOR += " | '" + skeyArr[i];
        sKeyAnd += " '" + skeyArr[i];
      }
      returnSKey = sKeyAnd + sKeyOR;
    }
    else if (skeyArr.length > 1 && this.isChecked) {
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


  // Use Fuse Lib to perform search and scoring inside Modality Procedure table
  handleSearchProcedureData() {
    this.showMPSpinner = true;
    let recs = this.initialSearchRecords;
    const options = {
      includeScore: true,
      includeMatches: true,
      useExtendedSearch: true,
      matchAllTokens: true,
      threshold: this.isChecked ? -0.1 : 0.1,
      keys: [
        'name',
        'modality',
        'practice',
        'procedureCode',
        'bodyParts',
        'specialInstructions',
        'reasonForExam',
      ]
    };

    const fuse = new Fuse(recs, options);
    this.searchData = fuse.search(this.fuseSearchKey);
    this.searchData = this.searchData.map(a => a.item);
    if (this.isChecked) {
      this.searchData = this.searchData.filter(a => JSON.stringify(a).toLowerCase().includes(this.searchKey.toLowerCase()));
    }
    this.searchData = [...this.searchData];
    // if(this.notesCountVisible){
    //   this.notesDataVisible = this.notesDataVisible.map(a => a.item);
    //   this.notesDataVisible = [...this.notesDataVisible];
    // }
    this.showMPSpinner = false;
  }

  // Hilight searched text inside tables
  handleHighlight(sKey) {
    this.unmarkKeywords();
    let selected = this.template.querySelectorAll('.content');
    for (let i = 0; i <= selected.length; i++) {
      var ob = new Mark(selected[i]);
      ob.mark(sKey, { className: 'a0' });
    }
  }

  //CC-649-Highlight Exact match searched text inside tables 
  handleHighlightSentence(sKey) {
    this.unmarkKeywords();
    let selected = this.template.querySelectorAll('.content');
    selected.forEach(element => {
      var ob = new Mark(element);
      ob.mark(sKey, {
        separateWordSearch: false,
        className: 'a0',
      });
    });

  }

  //Initiate Search for exact match search text inside tables
  handleCheckboxChange(event) {
    this.isChecked = event.target.checked;
    this.unmarkKeywords();
    if (this.searchKey) {
      this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey.trim());
      this.handleSearchProcedureData();
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

  // Handle data to be displayed in modality procedure table along with pagination    
  updateRecordsHandler(event) {
    this.dataVisible = [...event.detail.records];
    this.dataCount = event.detail.rccount;
    this.dataCountVisible = this.dataCount > 0 ? true : false;
    if (this.selectedModalitiesValue.length > 0 && this.selectedPracticeValue.length > 0 && (!this.dataCountVisible)) {
      this.showNoData = true;
    }
    else {
      this.showNoData = false;
    }
    if (this.dataCountVisible) {
      this.unmarkKeywords();
      if (!this.isChecked) {
        setTimeout(() => {
          this.handleHighlight(this.searchKey);
        }, '200');
      } else {
        setTimeout(() => {
          this.handleHighlightSentence(this.searchKey);
        }, '200');
      }
    } else {
      if (this.notesCountVisible) {
        this.unmarkKeywords();
        if (!this.isChecked) {
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
  }

  // Handle data to be displayed in special inst table along with pagination    
  updateNotesRecordsHandler(event) {
    this.notesDataVisible = [...event.detail.records];
    this.notesCount = event.detail.rccount;
    this.notesCountVisible = this.notesCount > 0 ? true : false;
    if (this.selectedModalitiesValue.length > 0 && this.selectedPracticeValue.length > 0 && (!this.notesCountVisible)) {
      this.showNoDataSpec = true;
    }
    else {
      this.showNoDataSpec = false;
    }

    if (this.notesCountVisible) {
      this.unmarkKeywords();
      if (!this.isChecked) {
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

  // Reset Sort on table modality procedure
  resetModalityTableSortColumn() {
    this.isPracticeSort = false;
    this.isPicModalitySort = false;
    this.isPDSort = false;
    this.isCodeSort = false;
    this.isBodyPartSort = false;
  }

  // Set column name for modality procedure table sort
  sortPractice(event) {
    this.unmarkKeywords();
    const sortcolumnNm = event.currentTarget.dataset.name;
    this.resetModalityTableSortColumn();
    if (sortcolumnNm === 'practice') {
      this.isPracticeSort = true;
    } else if (sortcolumnNm === 'modality') {
      this.isPicModalitySort = true;
    } else if (sortcolumnNm === 'name') {
      this.isPDSort = true;
    } else if (sortcolumnNm === 'procedureCode') {
      this.isCodeSort = true;
    } else if (sortcolumnNm === 'bodyParts') {
      this.isBodyPartSort = true;
    }
    this.sortModalityTableData(sortcolumnNm);
  }

  // Sorting on modality procedure table
  sortModalityTableData(sortColumnName) {
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

  // Reset Sort on special inst table
  resetSpecialInstleSortColumn() {
    this.isPracticeSP = false;
    this.isModalitySP = false;
  }

  // Set column name for special inst table sort
  sortSpecialInst(event) {
    const sortcolumnNm = event.currentTarget.dataset.name;
    this.resetSpecialInstleSortColumn();
    if (sortcolumnNm === 'practiceCodes') {
      this.isPracticeSP = true;
    } else if (sortcolumnNm === 'modalityCodes') {
      this.isModalitySP = true;
    }
    this.sortSpecialInstData(sortcolumnNm);
  }

  // Sorting on special inst table
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
    this.notesData = JSON.parse(JSON.stringify(this.notesData)).sort((a, b) => {
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

  // handle modality option selection
  handleModalityChange(event) {
    this.selectedModalitiesValue = event.detail.selectedmodalityvalue;
    setTimeout(() => {
      this.getPracticeSearchData();
      this.getNotesSearchData();
    }, '100');
  }

  // handle practice option selection
  handlePracticheChange(event) {
    this.selectedPracticeValue = event.detail.selectedpracticevalue;
    setTimeout(() => {
      this.getPracticeSearchData();
      this.getNotesSearchData();
    }, '100');
  }

  handleModalityClearAll() {
    this.dataVisible = [];
    this.searchData = [];
    this.searchKey = '';
    this.notesData = [];
    this.notesDataVisible = [];
    this.template.querySelector('c-d-h_practice-options').clearAllPractices();
    this.template.querySelector('c-d-h_modality-options').clearAllModalities();
    this.isChecked = false;
    //CC-649-To clear the checkbox on Clear All
    const checkbox = this.template.querySelector('lightning-input[data-id="exactMatchCheckbox"]');
    if (checkbox) {
      checkbox.checked = false;
    }
  }
}