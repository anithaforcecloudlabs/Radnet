/* eslint-disable @lwc/lwc/no-async-operation */
/*
* ***************************************************************************************************************************
* LWC Component Name - dH_knowledgeSearchBaseLWC.js
* Version - 0.2
* Created Date - 17-May-2024
* Function - JS class of Knowledge Articles LWC component.
* Modification Log :
* --------------------------------------------------------------------------------
* Date                 Description
* --------------       ----------------------------------
* 20-May-2024          Initial version CC-328
* 05-June-2024         Changes related to CC-330
* 31-May-2024          Changes of CC-486 , CC-446, CC-506
* 30-Jul-2024          Changes of CC-964
* 09-Oct-2024          Created openTabHandlerRecord function and changes related to CC-1418
* *****************************************************************************************************************************
*/
import { LightningElement, track, wire, api } from 'lwc';
import {IsConsoleNavigation, openSubtab ,getFocusedTabInfo} from 'lightning/platformWorkspaceApi';
import getCategoryList from '@salesforce/apex/DH_knowledgeSearchController.getCategoryList';
import getArticleList from '@salesforce/apex/DH_knowledgeSearchController.getArticleList';
import getCategoryVsIconNames from '@salesforce/apex/DH_KMUtility.getCategoryVsIconNames';
import TABLE_IMAGE from "@salesforce/resourceUrl/goingcamping";
import { NavigationMixin } from 'lightning/navigation';
//knowledge search import
import getCategoryName from '@salesforce/apex/DH_knowledgeSearchFuncController.getCategoryName';
import { loadScript } from "lightning/platformResourceLoader";
import fuselib from "@salesforce/resourceUrl/fusejs";
import markjs from "@salesforce/resourceUrl/markjs";
import articleViewCountUpdate from '@salesforce/apex/DH_KMQueryManager.articleViewCountUpdate';
import { refreshApex } from '@salesforce/apex';
import KnowledgeArticleLabel from '@salesforce/label/c.DH_KnowldegeArticleLabel';
import createLogRecord from '@salesforce/apex/DH_DexLoggingUtility.createLogRecord';
import {getAllTabInfo,setTabLabel,setTabIcon,focusTab} from 'lightning/platformWorkspaceApi';

export default class DH_knowledgeSearchBaseLWC extends NavigationMixin(LightningElement) {
  @wire(IsConsoleNavigation)
  isConsoleNavigation
  @track loggerParam = null;
  @track catgOptions = [];
  @track subOptionsSliced = [];
  wiredcatgoption = new Map();
  originalData = new Map();

  @track labelVsNamesubCtg = new Map();
  @track labelVsNameCtg = new Map();
  @track dataCtgGrpNameVsCtgName = new Map();
  @track coastLabelList = [];

  @track count = [];
  @track catgCount = 0;
  @track subcCount = [];
  @track ctgIcon = '';
  @track ctgIconList = [];

  @track showArticle = false;
  @track subctgLabel = '';
  @track articleList = [];
  @track mainArticleList = [];//sorted by index from controller
  @track articleCount = 0;

  @track scId = '';
  @track countZero = [];
  @track showViewMore = [];
  @track showViewLess = [];
  @track showLessCatOptions = []
  @track searchTextValue = '';

  @track showError = false;
  @track noArticleError;

  tableImage = TABLE_IMAGE;

  @track sortedColumn = 'Index__c';
  @track sortValue;
  @track disableSortOrder = false;
  sortedDirection = 'asc';

  //knowledge search variables starts
  @track row;

  @track data = [];
  @track recordsData = [];
  @track showModal = false;
  @track isLoading = false;
  @track noData = false;
  @track hasNoRecords = false;
  @api selectedRecordId;
  @api selectedValue;
  @track showAll = true;
  @track records = [];
  @track description = [];
  fuseSearchKey;

  @track category;
  @track resultOnSearch;
  @track showResultOnHandleEnter = false;
  @track recordIdForCatg = [];
  @track showCatgData = false;
  @track allSubCategory = [];
  @track subCategorySelected = [];
  @track buttonVariant = 'brand-outline';
  allArticlesCount = 0;
  showAllLabel = '';
  @track hasLoaded = false;
  kArecordId;
  // @api isChecked; //CC-1386
  @api recordforSort = []; //CC-1386
  //knowledge search variables ends
  
  @api selectedcoast = '';
  @track sortArticleOptions = [];
  wiredCategResult = [];

 @track isChecked; // Automatically tracks changes for reactivity   CC-1502
// CC-1502
    constructor() {  
        super();  
        this.isChecked = true; // Set default value here  
    }  
// END CC-1502
  // gets CategoryVsIconName metadata records
  @wire(getCategoryVsIconNames)
  wiredCtgIcons({ error, data }) {

    if (data) {
      this.ctgIconList = data;
    }
    else if (error) {
      this.error = error;
      this.ctgIconList = undefined;
    }
  }

  // gets category and subcategory maps and coast list based on user permission
  @wire(getCategoryList, { searchKnowledgeDataCategorySelection: null, isSearchFunction: false , selectedCoast : '$selectedcoast' })
  wiredCateg(result) {

    this.resetKATab();
    this.wiredCategResult = result;

    if (result.data) {
      this.wiredcatgoption = JSON.parse(JSON.stringify(result.data.categVsSubcategMap));
      this.originalData = JSON.parse(JSON.stringify(result.data.categVsSubcategMap));
      this.dataCtgGrpNameVsCtgName = result.data.dataCategGrpNameVsDataCategNames;
      this.labelVsNamesubCtg = result.data.subcategLabelVsNames;
      this.labelVsNameCtg = result.data.categLabelVsNames;
      this.coastLabelList = result.data.usrCoastLabels;

      if (this.coastLabelList.length === 2) {

        this.sortArticleOptions = [{
          id: 'menu-item-1',
          label: 'Alphabetical',
          value: 'Alphabetical',
        },
        {
          id: 'menu-item-3',
          label: 'Index - East',
          value: 'Index_East',
        },
        {
          id: 'menu-item-4',
          label: 'Index - West',
          value: 'Index_West',
        }];
        this.sortValue = 'Index - East';
      }
      else if (this.coastLabelList.length === 1) {
        this.sortArticleOptions = [{
          id: 'menu-item-1',
          label: 'Alphabetical',
          value: 'Alphabetical',
        },
        {
          id: 'menu-item-2',
          label: 'Index',
          value: 'Index',
        }];
        this.sortValue = 'Index';

      }

      // Loops on CategoryVsSubcategory Map to get category Options list displayed on UI
      for (let key in this.wiredcatgoption) {
      if (this.wiredcatgoption.hasOwnProperty(key)) {
      
        this.subcCount[key] = this.wiredcatgoption[key].length;
        this.showViewLess[key] = false;

        if (this.subcCount[key] !== 0) {
          if (this.subcCount[key] > 2) {
            this.showViewMore[key] = true;
            this.wiredcatgoption[key] = this.wiredcatgoption[key].slice(0, 2);
          }
          else {
            this.showViewMore[key] = false;
          }
        } else {
          this.countZero[key] = true;
        }

        for (let i = 0; i < this.ctgIconList.length; i++) {
          if (this.ctgIconList[i].Data_Category_Label__c === key) {
            this.ctgIcon = this.ctgIconList[i].Category_Icon_Name__c;
          }

        // pushes category and subcategory fields in catgOptions list
        }
        this.catgOptions.push({ "label": key, "labelIcon": this.ctgIcon, "values": this.wiredcatgoption[key], "valLen": this.subcCount[key], "zeroFlag": this.countZero[key], "viewMoreFlg": this.showViewMore[key], "viewLessFlg": this.showViewLess[key] });
      }
    }
      this.catgCount = this.catgOptions.length;
      this.error = undefined;
    
    } else if (result.error) {
      this.error = result.error;
      this.catgOptions = undefined;
    }
  }

  @api refreshCategoryResult(){
    refreshApex(this.wiredCategResult);
  }

  // subcategory click handler - gets list of knowledge articarticleListles assigned to selected subcategory 
  handleSubctgClick(event) {
    this.showArticle = true;
    this.subctgLabel = event.target.dataset.subctg;

    getArticleList({ selectedSubCtg: this.subctgLabel, categLableVsApiNames: [], subcategLableVsApiNames: this.labelVsNamesubCtg, groupVsCategNames: this.dataCtgGrpNameVsCtgName, coastLabels: this.coastLabelList })
      .then(result => {
        this.articleList = JSON.parse(JSON.stringify(result));
        this.mainArticleList = JSON.parse(JSON.stringify(result));
        this.articleCount = this.articleList.length;
        this.articleFlagSet();

      })
      .catch(error => {
        console.log('error' + JSON.stringify(error));
      })
  }

  // view all article click handler - gets list of knowledge articles assigned to category
  handleViewArticleClick(event) {
    this.showArticle = true;
    this.subctgLabel = event.target.dataset.subctg;

    getArticleList({ selectedSubCtg: this.subctgLabel, categLableVsApiNames: this.labelVsNameCtg, subcategLableVsApiNames: [], groupVsCategNames: this.dataCtgGrpNameVsCtgName, coastLabels: this.coastLabelList })
      .then(result => {
        
        this.articleList = JSON.parse(JSON.stringify(result));
        this.mainArticleList = JSON.parse(JSON.stringify(result));
        this.articleCount = this.articleList.length;
        this.articleFlagSet();

      })
      .catch(error => {
        console.log('error' + JSON.stringify(error));
      })
  }

  // Article Click handler - directs to Knowledge article record page 
  handleArticleClick(event) {
    this.scid = event.currentTarget.dataset.scid;
    this.navigateToViewRecordPage(this.scid);
  }

  // sets disableSortOrder and noArticleError flags as per articleList count 
  articleFlagSet() {
    if (this.articleCount === 0) {
      this.noArticleError = true;
      this.disableSortOrder = true;
    }
    else {
      this.noArticleError = false;
      this.disableSortOrder = false;
    }
  }

  // viewAll click handler - displays all subcategories with viewLess button under category
  //CC-891
  handleViewAllClick(event) {

    const ctgVal = event.currentTarget.dataset.descid;
    const qselect = this.template.querySelector(`[data-scid="${ctgVal}"]`);
    qselect.classList.add('stack-top');

    for (let i = 0; i < this.catgOptions.length; i++) {

      if (this.catgOptions[i].label === ctgVal) {
        this.catgOptions[i].viewMoreFlg = false;
        this.catgOptions[i].viewLessFlg = true;
        this.catgOptions[i].values = [...this.originalData[ctgVal]];
      }
      else{
        if (this.catgOptions[i].valLen > 2)
        this.catgOptions[i].viewMoreFlg = true;
        this.catgOptions[i].viewLessFlg = false;
        this.catgOptions[i].values = [...this.catgOptions[i].values.slice(0, 2)];
        const notSelected = this.template.querySelector(`[data-scid="${this.catgOptions[i].label}"]`);
        notSelected.classList.remove('stack-top');
      }
    }
  }

  // viewLess click handler - displays only 2 subcategories with viewAll button under category 
  handleViewLessClick(event) {

    const ctgVal = event.currentTarget.dataset.descid;
    const qselect = this.template.querySelector(`[data-scid="${ctgVal}"]`);
    qselect.classList.remove('stack-top');

    for (let i = 0; i < this.catgOptions.length; i++) {

      if (this.catgOptions[i].label === ctgVal) {
        this.catgOptions[i].viewMoreFlg = true;
        this.catgOptions[i].viewLessFlg = false;
        this.catgOptions[i].values = [...this.catgOptions[i].values.slice(0, 2)];

      }
    }
  }

  // Back buton on Article List page resets all flags and variables
  handleBack() {

    if (this.coastLabelList.length === 2) {
      this.sortValue = 'Index - East';
    } else {
      this.sortValue = 'Index';
    }
    this.subctgLabel = '';
    this.resetTiles();
    this.showArticle = false;
    this.articleFlagSet();
    this.articleList = [];
    this.articleCount = 0;

  }

  // resets the category tiles by setting ViewMore and ViewLess flags to initial values
  resetTiles() {

    for (let i = 0; i < this.catgOptions.length; i++) {
      if (this.catgOptions[i].valLen !== 0) {
        if (this.catgOptions[i].valLen > 2) {
          this.catgOptions[i].viewMoreFlg = true;
          this.catgOptions[i].viewLessFlg = false;

          this.catgOptions[i].values = [...this.catgOptions[i].values.slice(0, 2)];
        } else {
          this.catgOptions[i].viewMoreFlg = false;
          this.catgOptions[i].viewLessFlg = false;
        }
      } else {
        this.catgOptions[i].zeroFlag = true;
      }
    }
  }

  // article list sort handler 
  handleSortArticles(event) {

    if (event.detail.value === 'Alphabetical') {
      this.articleList = [...this.sortArticleByTitle(this.articleList)];
      this.sortValue = 'Alphabetical';
    }
    else if (event.detail.value === 'Index') {
      this.articleList = [...this.mainArticleList];
      this.sortValue = 'Index';
    }
    else if (event.detail.value === 'Index_East') {
      this.articleList = [...this.sortArticleByEastIndex(this.articleList)];
      this.sortValue = 'Index - East';
    }
    else if (event.detail.value === 'Index_West') {
      this.articleList = [...this.sortArticleByWestIndex(this.articleList)];
      this.sortValue = 'Index - West';
    }
  }

  // sorts Articles By Title when sort option Alphabetical selected
  sortArticleByTitle(articleData) {

    let sortedData = articleData.sort(function (a, b) {
      let x = a.title.toLowerCase();
      let y = b.title.toLowerCase();

      if (x > y) { return 1; }
      if (x < y) { return -1; }
      return 0;
    });
    return sortedData;
  }

  // sorts Articles By East Index when sort option Index - East selected
  sortArticleByEastIndex(articleData) {

    articleData.sort((a, b) => {
      return a.eastIndex - b.eastIndex;
    });
    return articleData;
  }

  // sorts Articles By West Index when sort option Index - West selected
  sortArticleByWestIndex(articleData) {

    articleData.sort((a, b) => {
      return a.westIndex - b.westIndex;
    });
    return articleData;
  }

  // resets Knowledge Articles Tab 
  resetKATab(){

    // result data maps
    this.wiredCategResult = [];
    this.wiredcatgoption = [];
    this.originalData = [];
    this.dataCtgGrpNameVsCtgName = [];
    this.labelVsNamesubCtg = [];
    this.labelVsNameCtg = [];
    this.coastLabelList = [];
    
    // array of categoryOptions
    this.catgOptions = [];
    this.ctgIcon = [];
    this.subcCount = [];
    this.countZero = [];
    this.showViewMore = [];
    this.showViewLess = [];
    //reset search bar
    this.showResultOnHandleEnter = false;
    this.showError = false;
    this.showArticle = false;
    this.category = [];
    this.records = [];
    this.subCategorySelected = [];
    this.allSubCategory = [];
    this.searchTextValue=" ";
    this.fuseSearchKey=" ";
    // handle back method
    this.handleBack();

  }
  //////////////// Knowledge Search starts here ///////////////////
  
  connectedCallback() {
    setTimeout(() => {
            this.setCustomTabUI();
    }, 500);
    if (this.fuseInitialized) {
      return;
    }
    this.fuseInitialized = true;
   
    Promise.all([loadScript(this, fuselib), loadScript(this, markjs)])
      .then(() => {
        console.log('Loaded');
      })
      .catch((error) => {
        console.log('ERR : ' + error);
      });
  }

    async setCustomTabUI() {
      try {
          const allTabs = await getAllTabInfo();
          const matchingTab = allTabs.find(t =>
              t.url && (t.url.includes('Knowledge_Articles'))
          );

          if (matchingTab && matchingTab.tabId) {
          await setTabLabel(matchingTab.tabId, 'Knowledge Articles');
          await setTabIcon(matchingTab.tabId, 'standard:search', {
              iconAlt: 'Knowledge Articles'
          });
          await focusTab(matchingTab.tabId);
          } else {
          console.warn('Tab not found for Knowledge_Articles');
          }
      } catch (error) {
          console.error('Tab customization failed:', error);
      }
    }

  //method to reset search key when coast is changed
  @api
  resetSearchKey(){
    this.template.querySelector('c-d-h_knowledge-search-component').resetSearchKey();
  }


  // this method is used to list of wrapper containing subcategories and corresponding Knowledge Articles 
  getCategoryListSearch() {
    getCategoryName({ searchKey: this.searchTextValue, selectedCoast : this.selectedcoast})
      .then(result => {
        this.hasLoaded = true;
        if (result && result.length > 0) {
          this.resultOnSearch = result;
          this.noData = false;
          this.isLoading = true;
          this.allSubCategory = []; /* All buttons/subcategory after search(enter) */

          // filtering records using fuse
          this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchTextValue);
          this.handleSearchFuseDataCategory();

          // after filtering sorting according to totalViewCount
          this.resultOnSearch.forEach(item => {
            item.knowledgeSearchWrapper.sort((a, b) => {
              if (a.totalViewCount === b.totalViewCount) {
                return a.title < b.title ? -1 : 1;
              }
              return b.totalViewCount - a.totalViewCount;
            });
          })

          // adding seeLess key in the object
          this.resultOnSearch.forEach(obj => {
            obj.knowledgeSearchWrapper.forEach(item => {
              item.seeLess = true;
            });
          });

          this.category = [...this.resultOnSearch];

          for (let i = 0; i < this.resultOnSearch.length; i++) {
            this.allSubCategory.push({ displayName: this.resultOnSearch[i].catgName + ' (' + this.resultOnSearch[i].knowledgeSearchWrapper.length + ')', name: this.resultOnSearch[i].catgName, length: this.resultOnSearch[i].knowledgeSearchWrapper.length });
          }
          this.template.querySelector('.showAllButton').variant = 'brand-outline';
          this.handleShowAll();
        }
        else {
          this.category = [];
          this.noData = true;
          this.isLoading = false;
        }
        if (!this.isChecked) {
        setTimeout(() => {
          this.handleHighlight(this.searchTextValue);
        }, '200');
      } else {
        setTimeout(() => {
          this.handleHighlightSentence(this.searchTextValue);
        }, '200');
      }

      })
      .catch(error => {
        console.log('error in getCategoryName' + JSON.stringify(error));

      });
  }
 
// Opens record detail page
navigateToViewRecordPage(rcId) {
  this[NavigationMixin.GenerateUrl]({
    type: 'standard__recordPage',
    attributes: {
      recordId: rcId,
      objectApiName: 'Knowledge__kav',
      actionName: 'view'
    },
  })
    .then(generatedUrl => {
      if (this.isConsoleNavigation) {
        getFocusedTabInfo()
          .then(result => {
            this.openTabHandlerRecord(
              result.isSubtab ? result.parentTabId : result.tabId,
              KnowledgeArticleLabel,
              generatedUrl,
              rcId
            );
          })
          .catch(error => {
            console.log('Error in getFocusedTabInfo: '+JSON.stringify(error));
            this.loggerParam = {
              ErrorMessage: error.message,
              ClassName: 'dh_knowledgeSearchBaseLWC-navigateToViewRecordPage',
              RelatedTo: rcId,
            };
            createLogRecord({ log: this.loggerParam });
          });
      } else {
            window.open(generatedUrl);
            this.kArecordId = rcId;
            this.getKnowledgeArticleUpdatedViewCount();
      }
    })
    .catch(error => {
      console.log('Error generating Url:', JSON.stringify(error));
    });
}
 
  //Opens knowledge article in subtab for the selected record if navigation type is console navigation
  openTabHandlerRecord(parentid,labelName,urlName,recId){
    openSubtab(parentid, {
        url:urlName,
        label:labelName,
        focus:true,
        icon:"standard:knowledge"
    }).catch((error)=>{
        console.log('Error in openSubtab catch: '+JSON.stringify(error));
        console.log('parent id: '+parentid);
        console.log('label name: '+labelName);
        console.log('url name: '+urlName);
        this.loggerParam = 
        {
          ErrorMessage:error.message,
          ClassName:'dh_knowledgeSearchBaseLWC-openTabHandlerRecord',
          RelatedTo:recId,
        };
        createLogRecord({log : this.loggerParam})
    });
} 

  // update the view count of navigated knowledge article in UCC
  async getKnowledgeArticleUpdatedViewCount(){
    try{
      await articleViewCountUpdate({knowledgeArticleId : this.kArecordId});
    } catch(error){
      console.log('Error generating Url:', JSON.stringify(error));
    }
    
  }
    

  // Navigates to Knowledge Article Record Page
  onArticleSelection(event) {

    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.selectedValue = event.detail.selectedValue;
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.selectedRecordId = event.detail.selectedRecordId;
    const recordsData = event.detail.recordsData;
    if (!(recordsData && recordsData.length > 0)) {
      this.showError = true;
      this.subCategorySelected = [];
      this.showResultOnHandleEnter = false;
      this.resetTiles();
    }

    if (this.selectedRecordId) {
      this.navigateToViewRecordPage(this.selectedRecordId);
      this.searchTextValue = '';
      this.showTilesParentBaseLWCComponent();
    }
    this.searchTextValue = '';
    this.template.querySelector('c-d-h_knowledge-search-component ').clearSelectedRecord();
    this.template.querySelector('c-d-h_knowledge-search-component ').setPlaceholderName();
  }

  // this method handles see more category
  handleSeeMoreCategory(event) {
    const id = event.target.dataset.id;
    this.unmarkKeywords();
    for (let i = 0; i < this.category.length; i++) {
      let found = false;
      for (let j = 0; j < this.category[i].knowledgeSearchWrapper.length; j++) {
        if (this.category[i].knowledgeSearchWrapper[j].id === id) {
          if (this.category[i].knowledgeSearchWrapper[j].seeLess) {
            this.category[i].knowledgeSearchWrapper[j].seeLess = false;
          }
          else {
            this.category[i].knowledgeSearchWrapper[j].seeLess = true;
          }
          found = true;
          break;
        }
      }
      if (found) {
        break;
      }
    }
if (!this.isChecked) {
    setTimeout(() => {
      this.handleHighlight(this.searchTextValue);
    }, '200');
      } else {
        setTimeout(() => {
          this.handleHighlightSentence(this.searchTextValue);
        }, '200');
  }
  }

  // handles click of seeMore and seeLess for knowledge articles
  handleSeeMoreRecords(event) {
    const id = event.target.dataset.id
    this.unmarkKeywords();
    for (let i = 0; i < this.records.length; i++) {
      if (this.records[i].id === id) {        
        if (this.records[i].seeLess) {
          this.records[i].seeLess = false;
        }
        else {
          this.records[i].seeLess = true;
        }
        break;
      }
    }
 if (!this.isChecked) {
    setTimeout(() => {
      this.handleHighlight(this.searchTextValue);
    }, '200');
      } else {
        setTimeout(() => {
          this.handleHighlightSentence(this.searchTextValue);
        }, '200');
  }

  }

  //displays all the data on press of enter
  onEnterHandle(event) {
    this.records = [];
    this.records = event.detail.recordsData; // list of all DH_knowledgeSearchWrapper - currently unfiltered
    this.searchTextValue = event.detail.searchKey.toLowerCase().trim();
    this.unmarkKeywords();
    this.resetTiles();
    this.hasLoaded = false;
    this.template.querySelector('c-d-h_knowledge-search-component').removeDropDown();

    //filtering records using fuse 
    this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchTextValue);
    this.handleSearchFuseData();

 if(!this.isChecked){
    // after filtering sorting according view count
      this.records.sort(function (a, b) {
      if (a.totalViewCount === b.totalViewCount) {
        return a.title < b.title ? -1 : 1;
      }
      return b.totalViewCount - a.totalViewCount;
    })
 }
 else {
    this.records.sort((a, b) => {  
    const aIndex = a.title.toLowerCase().indexOf(this.searchTextValue);  
    const bIndex = b.title.toLowerCase().indexOf(this.searchTextValue);  

    // First, handle cases where the index is -1 (i.e., search key not found)  
    if (aIndex === -1 && bIndex === -1) return 0; // both do not contain the search text  
    if (aIndex === -1) return 1; // a does not contain search text, b does, so a comes after b  
    if (bIndex === -1) return -1; // b does not contain search text, a does, so a comes before b  

    // If both contain the search text, sort by their index  
    return aIndex - bIndex; // Earlier matches come first  
});  

 }
  
    // CC-810,CC-843
    let exactMatch=this.records.filter(item=>item.title.toLowerCase()=== this.searchTextValue.toLowerCase());
    let notMatch=this.records.filter(item=>item.title.toLowerCase()!== this.searchTextValue.toLowerCase());
    this.records=[...exactMatch,...notMatch];

    this.records = this.records.map(item => ({ ...item, seeLess: true }));
    if (this.records && this.records.length > 0) {
      this.showResultOnHandleEnter = true;
    }

    this.allArticlesCount = this.records.length;
    this.showAllLabel = 'Show All (' + this.allArticlesCount + ')';
    if (this.records.length > 0) {
      this.allSubCategory = [];
      this.getCategoryListSearch();
    }
    else {
      this.showError = true;
      this.subCategorySelected = [];
      this.showResultOnHandleEnter = false;
      this.resetTiles();
    }
  }
  
 // CC-1386
  handleCheckboxChange(event) {
    this.isChecked = event.target.checked;
    this.recordforSort = this.records;
    this.unmarkKeywords();
   if(this.isChecked){
    this.fuseSearchKey = this.searchTextValue;
    this.handleSearchFuseData();
    this.recordforSort.sort((a, b) => {  
    const aIndex = a.title.toLowerCase().indexOf(this.searchTextValue);  
    const bIndex = b.title.toLowerCase().indexOf(this.searchTextValue);  

    // First, handle cases where the index is -1 (i.e., search key not found)  
    if (aIndex === -1 && bIndex === -1) return 0; // both do not contain the search text  
    if (aIndex === -1) return 1; // a does not contain search text, b does, so a comes after b  
    if (bIndex === -1) return -1; // b does not contain search text, a does, so a comes before b  

    // If both contain the search text, sort by their index  
    return aIndex - bIndex; // Earlier matches come first  
});  
this.records = this.recordforSort;
}

else {
 this.unmarkKeywords();
 // after filtering sorting according view count
      this.records.sort(function (a, b) {
      if (a.totalViewCount === b.totalViewCount) {
        return a.title < b.title ? -1 : 1;
      }
      return b.totalViewCount - a.totalViewCount;
    }) 
       setTimeout(() => {
          this.handleHighlight(this.searchTextValue);
        }, '200');
}   
  }

  buildSearchKeyForFuseForSort(sKey) {
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

  //handles sub-category buttons and filters data accordingly
  handleClick(event) {
    const label = event.target.name;
    this.showCatgData = true;
    this.unmarkKeywords();

    const btn = this.template.querySelector(`[data-id="${label}"]`);
    if (btn.variant === 'brand-outline') {
      btn.variant = 'brand';
      this.subCategorySelected.push(label);
      this.template.querySelector('.showAllButton').variant = 'brand-outline';
    }
    else {
      btn.variant = 'brand-outline';
      this.subCategorySelected.splice(this.subCategorySelected.indexOf(label), 1);
    }

    if (this.subCategorySelected.length === 0) {
      this.showCatgData = false;
      this.records = [...this.records];
    }
    this.category = [];
    
    for (let i = 0; i < this.resultOnSearch.length; i++) {
      if (this.subCategorySelected.includes(this.resultOnSearch[i].catgName)) {
        let obj = Object.assign({}, this.resultOnSearch[i]);
        this.category.push(obj);
      }
    }

    setTimeout(() => {
      this.handleHighlight(this.searchTextValue);
    }, '200');

  }

  //Shows all knowledge articles containing the search key
  handleShowAll() {
    this.showCatgData = false;
    this.records = [...this.records];
    this.category = [];
    this.subCategorySelected = [];
    this.unmarkKeywords();

if (!this.isChecked) {
    setTimeout(() => {
      this.handleHighlight(this.searchTextValue);
    }, '200');
      } else {
        setTimeout(() => {
          this.handleHighlightSentence(this.searchTextValue);
        }, '200');
      }

    const btn = this.template.querySelector('.showAllButton');
    if (btn.variant === 'brand-outline') {
      btn.variant = 'brand';
      this.template.querySelectorAll('.subCatgBtn').forEach(item => {
        item.variant = 'brand-outline';
      });
    }
    else {
      btn.variant = 'brand-outline';
    }
  }

  //on click of view more link navigates to detail page of knowledge article
  handleViewMoreClick(event) {
    const recId = event.currentTarget.dataset.knowledgearticleid;
    this.navigateToViewRecordPage(recId);
  }

  //clears the error page
  clearEmptyErrorPage() {
    this.showError = false;
    this.resetTiles();
  }

  //Shows tiles when search key is empty or navigated to the detail page
  showTilesParentBaseLWCComponent() {
    this.resetTiles();
    this.showResultOnHandleEnter = false;
    this.showError = false;
    this.showArticle = false;
    this.category = [];
    this.records = [];
    this.subCategorySelected = [];
    this.allSubCategory = [];
    this.template.querySelector('c-d-h_knowledge-search-component').removeDropDown();
  }

  //Use Fuse Lib to perform search and scoring inside Knowledge Articles
  handleSearchFuseDataCategory() {
    var recs = this.resultOnSearch;
    const options = {
      includeScore: true,
      includeMatches: true,
      shouldSort: true,
      useExtendedSearch: true,
      minMatchCharLength: 2,
      threshold: 0.1,
      ignoreLocation: true,
      keys: ['knowledgeSearchWrapper.title', 'knowledgeSearchWrapper.strippedDetails']
    };
    const fuse = new Fuse(recs, options);
    this.resultOnSearch = fuse.search(this.fuseSearchKey);
    this.resultOnSearch = this.resultOnSearch.map(a => a.item);
    this.resultOnSearch = [...this.resultOnSearch];
  }

// CC-1386
  //Use Fuse Lib to perform search and scoring inside Knowledge Articles 
  handleSearchFuseData() {
    var recs = this.records;
    const options = {
      includeScore: true,
      includeMatches: true,
      shouldSort: true,
      useExtendedSearch: true,
      minMatchCharLength: 2,
      threshold: 0.1,
      ignoreLocation: true,
      keys: ['title', 'strippedDetails']
    };
    const fuse = new Fuse(recs, options);
    this.records = fuse.search(this.fuseSearchKey);
    this.records = this.records.map(a => a.item);
    this.records = [...this.records];

    setTimeout(() => {
      this.handleHighlightSentence(this.searchTextValue);
    }, 200);
  }

  //highlights the entered search key
  handleHighlight(sKey) {
    var selected = this.template.querySelectorAll('.content');
    var ob;
    for (let i = 0; i < selected.length; i++) {
      ob = new Mark(selected[i]);
      ob.mark(sKey);
    }
  }
// CC-1386
  handleHighlightSentence(sKey) {
    this.unmarkKeywords();
    let selected = this.template.querySelectorAll('.content');
    selected.forEach(element => {
      var ob = new Mark(element);
      ob.mark(sKey, {
        separateWordSearch: false,
        className: 'a0',
      });
    }); }
  
  //Unmark previously highlighted keywords
  unmarkKeywords() {
    let selectedElem = this.template.querySelectorAll('.content');
    for (let i = 0; i <= selectedElem.length; i++) {
      let ob = new Mark(selectedElem[i]);
      ob.unmark();
    }
  }

  //build fuse search key
  buildSearchKeyForFuse(sKey) {
    var skeyArr = [];
    var sKeyOR = '';
    var sKeyAnd = '';
    var returnSKey = '';
    skeyArr = sKey.split(' ');
    if (skeyArr.length === 1) {
      returnSKey = "'" + sKey;
    } else if (skeyArr.length > 1) {
      for (let i = 0; i < skeyArr.length; i++) {
        sKeyAnd += " '" + skeyArr[i];
        sKeyOR += " | " + skeyArr[i];
      }
      returnSKey = sKeyAnd + sKeyOR;
    } else {
      returnSKey = "'" + sKey;
    }
    return returnSKey;
  }
}