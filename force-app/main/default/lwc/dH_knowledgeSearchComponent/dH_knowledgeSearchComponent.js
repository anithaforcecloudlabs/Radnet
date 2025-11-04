/*
* ***************************************************************************************************************************
* LWC Component Name - dH_KnowledgeSearchComponent.js
* Version - 0.1
* Created Date - 20-May-2024
* Function - JS USED FOR SEARCH FUNCTIONALITY FOR KNOWLEDGE ARTICLES TAB..
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                     Date                 Description
* ----------------         --------------       ---------------------
* CC-331,490               20-May-2024          Added onRecordSelection,handleKeyChange,handleEnter,onLeave,removeRecordOnLookup,
                                                setPlaceholderName,getLookupResult,getAllKnowledgeArticles,clearSelectedRecord,
                                                removeDropDown,onSeletedRecordUpdate,onAllRecordUpdate,onRemoveEmptyErrorPage,
                                                onShowTilesParentBaseLWCComponent,handleSearch,handleIconClick,
                                                showRecentlyViewedArticleshandleSearchFuseDatabuildSearchKeyForFuse methods.
* *****************************************************************************************************************************
*/
import { LightningElement, track, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import fuselib from "@salesforce/resourceUrl/fusejs";//static resource
import getTrackingDetails from "@salesforce/apex/DH_knowledgeSearchFuncController.getTrackingDetails";//apex methods callout
import getAllTrackingDetails from "@salesforce/apex/DH_knowledgeSearchFuncController.getAllTrackingDetails";
import getRecentlyViewedKnowledgeArticles from "@salesforce/apex/DH_knowledgeSearchFuncController.getRecentlyViewedKnowledgeArticles";
import RemoveSelectedRecord from '@salesforce/label/c.DH_RemoveSelectedRecord';//CustomLabel
import RecentlyViewedArticles from '@salesforce/label/c.DH_RecentlyViewedArticles';
import MostViewedArticles from '@salesforce/label/c.DH_MostViewedArticles';
import SearchAnArticleHere from '@salesforce/label/c.DH_SearchAnArticleHere';
import SessionSearchKey from '@salesforce/label/c.DH_SearchKeyForSessionStorage';
import getUserType from "@salesforce/apex/DH_KMUtility.getUserType";

export default class DH_KnowledgeSearchComponent extends LightningElement {
  @track recordsList = [];
  @api searchKey = "";
  @api selectedValue;
  @api selectedRecordId;
  @api objectApiName;
  @api iconName;
  @api lookupLabel;
  @api selectedcoast = '';
  @track message;
  @track showAll = false;
  @track hasRecords = false;
  @track showcross = false;
  @track allKnowledgeArticleRecords = [];
  @track debounceTimeout;
  @track recentlyViewedArticlesList = [];
  @track showRecentArticles = false;
  @track showDropdown = true;
  @track showDropdownForRectlyView = true;
  @track fuseInitialized = false;
  @track fuseSearchKey;
  label = {
        RemoveSelectedRecord,
        RecentlyViewedArticles,
        MostViewedArticles,
        SearchAnArticleHere
    };

  connectedCallback() {
    if (this.fuseInitialized) {
      return;
    }
    this.fuseInitialized = true;
    Promise.all([loadScript(this, fuselib)])
      .then(() => {
        console.log("Loaded in child");
      })
      .catch((error) => {
        console.log("ERR : " + error);
      });
    // changed by raj ranjan (CC-490)
    this.searchKey = window.sessionStorage.getItem(SessionSearchKey);
    if (this.searchKey !== null || this.searchKey !== "") {
      this.handleIconClick();
    }
    // changed by raj ranjan (CC-490)
    window.sessionStorage.setItem(SessionSearchKey, "");
  }

  //Sends the selected record Id to the parent component
  onRecordSelection(event) {
    this.selectedRecordId = event.target.dataset.key;

    this.selectedValue = event.target.dataset.name;

    this.searchKey = " ";
    this.onSeletedRecordUpdate();
  }

  //populates the dropdown for type ahead on change of entered search Key value
  handleKeyChange(event) {
    this.searchKey = event.target.value;
    if (this.searchKey.length === 0) {
      this.showcross = false;
    }
    if (event.keyCode !== 13) {
      this.showDropdown = true;
      if (this.debounceTimeout) {
        clearTimeout(this.debounceTimeout);
      }

      if (this.searchKey.length === 0) {
        this.onShowTilesParentBaseLWCComponent();
        this.clearSelectedRecord();
      } else {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.debounceTimeout = setTimeout(() => {
          this.getLookupResult();
        }, 400);
      }
    } else {
      this.showDropdown = false;
    }
  }

  //populates all the knowledge articles containing the entered search key on press of Enter button
  handleEnter(event) {
    this.searchKey = event.target.value;
    if (event.keyCode === 13 && this.searchKey && this.searchKey.length > 0) {
      this.showDropdown = false;
      this.handleSearch();
    }
  }

  //clears all dropdown values when clicked outside search box
  onLeave() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.recordsList = null;
      this.allKnowledgeArticleRecords = [];
      this.hasRecords = false;
      this.selectedValue = "";
      this.selectedRecordId = undefined;
      this.showRecentArticles = false;
      this.recentlyViewedArticles = [];
    }, 300);
  }

  //on click of cross on searchbox this method resets all values
  @api
  removeRecordOnLookup() {
    this.searchKey = "";
    this.hasRecords = true;
    this.showcross = false;
    this.onRemoveEmptyErrorPage(false);
    this.onShowTilesParentBaseLWCComponent();
    this.clearSelectedRecord();
  }

  //sets the placeholder value
  @api
  setPlaceholderName() {
    this.template.querySelector(".inputbox").placeholder =
      "Search an article here";
  }

  
  //called from parent to reset the search key to blank when coast is changed
  @api
  resetSearchKey(){
    this.searchKey = "";
    this.selectedValue = "";
    this.setPlaceholderName()
    this.showcross = false;
    this.removeDropDown();
  }

  //retrieves the title of knowledge articles for drop down for type ahead functionality
  getLookupResult() {
    if (this.searchKey && this.searchKey.length > 0) {
      getTrackingDetails({ trackingNumber: this.searchKey, selectedCoast : this.selectedcoast })
        .then((result) => {
          if (result && result.length > 0) {
            this.hasRecords = true;
            this.showRecentArticles = false;
            this.recordsList = result;
            this.onRemoveEmptyErrorPage(false);

            // filtering using fuse
            this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey);
            this.handleSearchFuseData();

            //sort recordsList
            this.recordsList.sort(function (a, b) {
              if (a.totalViewCount === b.totalViewCount) {
                return a.title < b.title ? -1 : 1;
              }
              return b.totalViewCount - a.totalViewCount;
            });

            this.recordsList = this.recordsList.slice(0, 5);
          } else {
            this.recordsList = [];
            this.hasRecords = false;
          }

          if (this.recordsList.length === 0) {
            this.showDropdownForRectlyView = false;
            this.showDropdown = false;
          }
        })
        .catch((error) => {
          console.log(
            "error in getTrackingDetails => " + JSON.stringify(error)
          );
        });
    } else {
      this.onRemoveEmptyErrorPage(false);
      this.hasRecords = false;
      this.showcross = false;
    }
  }

  //retrieves the wrapper of knowledge articles to be displayed on enter pressed or click of search icon
  getAllKnowledgeArticles() {
    this.showDropdown = false;
    getAllTrackingDetails({ searchKey: this.searchKey,selectedCoast : this.selectedcoast })
      .then((result) => {
        
        if (result && result.length > 0) {
          this.allKnowledgeArticleRecords = result;
        } else {
          this.allKnowledgeArticleRecords = [];
        }
        this.onAllRecordUpdate();
      })
      .catch((error) => {
        console.log(
          "error during fetching getAllTrackingDetails => " +
            JSON.stringify(error)
        );
      });
  }

  //search key is null then sets the value to empty
  @api
  clearSelectedRecord() {
    this.selectedRecordId = undefined;
    this.searchKey = "";
    this.selectedValue = "";
    this.recordsList = null;
    this.allKnowledgeArticleRecords = [];
    this.hasRecords = false;
  }

  //called from parent to remove the dropdown
  @api
  removeDropDown() {
    this.recordsList = null;
    this.hasRecords = false;
  }

  //custom event to pass the selected record Id to parent
  onSeletedRecordUpdate() {
    const passEventr = new CustomEvent("recordselection", {
      detail: {
        selectedRecordId: this.selectedRecordId,
        selectedValue: this.selectedValue,
        data: this.allKnowledgeArticleRecords
      }
    });
    this.dispatchEvent(passEventr);
  }

  //custom event to pass search Key and all knowledge articles to be displayed on enter or search icon click
  onAllRecordUpdate() {
    this.hasRecords = false;
    this.selectedValue = "";
    this.selectedRecordId = undefined;
    const passEventNew = new CustomEvent("allrecord", {
      detail: {
        searchKey: this.searchKey,
        recordsData: this.allKnowledgeArticleRecords
      }
    });
    this.dispatchEvent(passEventNew);
  }

  //custom event to remove the error page message
  onRemoveEmptyErrorPage(flag) {
    const passEventNew = new CustomEvent("removeemptyerrorpage", {
      detail: { flag: flag }
    });
    this.dispatchEvent(passEventNew);
  }

  //custom event to show tiles when search key is empty or cross is clicked
  onShowTilesParentBaseLWCComponent() {
    const passEventNew = new CustomEvent("showtilesparentbaselwccomponent", {});
    this.dispatchEvent(passEventNew);
  }

  //populates all the knowledge articles on click of search icon
  handleSearch() {
    this.recordsList = null;
    this.hasRecords = false;
    this.getAllKnowledgeArticles();
    if (
      this.searchKey &&
      this.searchKey.length > 0 &&
      this.hasRecords === false
    ) {
      this.showcross = true;
    }
  }
  //method to handle search icon click
  handleIconClick() {
    if (this.searchKey && this.searchKey.length > 0) {
      this.handleSearch();
    }
  }

  // checks if the user is guest user or not
  getUserType(){
    getUserType({})
    .then((result)=> {
     
      if(result=== true){
        this.showRecentArticles = false;
        this.showDropdownForRectlyView = false;
      }
      else {
        this.showRecentArticles=true;
        this.showDropdownForRectlyView = true;
        this.getRecentlyViewedArticles();
      }
    })
    .catch((error) => {
      console.log(
        "Error fetching user type for UCC" + JSON.stringify(error)
      );
    });
  }
  //Populates the recently viewed knowledge articles dropdown
  showRecentlyViewedArticles() {
  
    if (this.searchKey.length === 0) {
     this.getUserType();
    }
  }

  //fetches the recently viewed article
  getRecentlyViewedArticles(){
    getRecentlyViewedKnowledgeArticles({})
        .then((result) => {
          this.recentlyViewedArticlesList = result;
        })
        .catch((error) => {
          console.log(
            "Error fetching recently viewed articles" + JSON.stringify(error)
          );
        });
  }

  //Use Fuse Lib to perform search and scoring inside Knowledge Articles
  handleSearchFuseData() {
    var recs = this.recordsList;
    const options = {
      includeScore: true,
      includeMatches: true,
      shouldSort: true,
      useExtendedSearch: true,
      minMatchCharLength: 2,
      threshold: 0.1,
      ignoreLocation: true,
      keys: ["title", "strippedDetails"]
    };
    const fuse = new Fuse(recs, options);
    this.recordsList = fuse.search(this.fuseSearchKey);
    this.recordsList = this.recordsList.map((a) => a.item);
    this.recordsList = [...this.recordsList];
  }

  //build fuse search key
  buildSearchKeyForFuse(sKey) {
    var skeyArr = [];
    var sKeyOR = "";
    var sKeyAnd = "";
    var returnSKey = "";
    skeyArr = sKey.split(" ");
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