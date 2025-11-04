/*
* ***************************************************************************************************************************
* LWC Component Name - dH_Knowledge.js
* Version - 0.1
* Created Date - 13-Jun-2024
* Function - JS class to provide the knowledge functionality in the P360 view.
* Modification Log :
* --------------------------------------------------------------------------------
* Developer                Date                 Description
* ----------------         --------------       ---------------------
* Raj Ranjan                20-May-2024          Initial version.
* *****************************************************************************************************************************
*/
import { LightningElement,track,api,wire } from 'lwc';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import {IsConsoleNavigation, openSubtab, EnclosingTabId ,closeTab ,getFocusedTabInfo ,getTabInfo} from 'lightning/platformWorkspaceApi';
import getRecentlyViewedKnowledgeArticles from '@salesforce/apex/DH_knowledgeSearchFuncController.getRecentlyViewedKnowledgeArticles';
import getTrackingDetails from '@salesforce/apex/DH_knowledgeSearchFuncController.getTrackingDetails';
import KnowledgeUrl from '@salesforce/label/c.DH_KnowledgeArticleUrl';
import KnowledgeTimeOut from '@salesforce/label/c.DH_KnowledgeTimeOutP360';
import KnowledgeSearchLabel from '@salesforce/label/c.DH_KnowledgeSearchLabel';
import KnowledgeArticleLabel from '@salesforce/label/c.DH_KnowldegeArticleLabel';
import RemoveSelectedRecord from '@salesforce/label/c.DH_RemoveSelectedRecord';
import RecentlyViewedArticles from '@salesforce/label/c.DH_RecentlyViewedArticles';
import MostViewedArticles from '@salesforce/label/c.DH_MostViewedArticles';
import SearchAnArticleHere from '@salesforce/label/c.DH_SearchAnArticleHere';
import SessionSearchKey from '@salesforce/label/c.DH_SearchKeyForSessionStorage';
import KnowledgeLabel from '@salesforce/label/c.DH_KnowledgeLabel';

import fuselib from "@salesforce/resourceUrl/fusejs";

export default class DH_Knowledge extends LightningElement {

    @wire(IsConsoleNavigation)
    isConsoleNavigation
    @wire(EnclosingTabId)
    enclosingParentTabID
    @track recordsList=[];  
    @api searchKey = "";  
    @api selectedValue;  
    @api selectedRecordId;  
    @track hasRecords=false;
    @track showcross=false;
    @track debounceTimeout;
    @track recentlyViewedArticlesList = [];
    @track showRecentArticles = false;
    @track showDropdown = true;
    @track showDropdownForRectlyView=true;
    @track fuseInitialized = false;
    @track fuseSearchKey;
    label = {
        RemoveSelectedRecord,
        RecentlyViewedArticles,
        MostViewedArticles,
        SearchAnArticleHere,
        KnowledgeLabel
    };
      
    connectedCallback(){
        if (this.fuseInitialized) {
            return;
        }
        this.fuseInitialized = true;
        Promise.all([loadScript(this, fuselib)])
        .then(() => {
            console.log('Loaded in child');
        })
        .catch((error) => {
            console.log('ERR : '+error);
        });
    }

    showRecentlyViewedArticles(event){
        if(this.searchKey.length === 0){
            this.showRecentArticles = true;
            this.showDropdownForRectlyView=true;
            getRecentlyViewedKnowledgeArticles({})
            .then((result => {
                this.recentlyViewedArticlesList = result;
            }))
            .catch((error) => {
                console.log('Error fetching recently viewed articles' + JSON.stringify(error));
            })
        }
    }
     /*
    Definition : To segregate the tab and subtab and open the result as the subtab
     */
    async onRecordSelection(event) {  
        this.selectedRecordId = event.target.dataset.key;  
        this.selectedValue = event.target.dataset.name;  
        this.searchKey = event.target.dataset.name;  
        this.showcross = true;
        if(this.isConsoleNavigation){
            getFocusedTabInfo().then((result)=>{
            {
                this.openTabHandlerRecord((result.isSubtab)?(result.parentTabId):(this.enclosingParentTabID),KnowledgeArticleLabel,this.selectedRecordId);
            }
            }).catch((error)=>{
                console.log('error' + error);
                });
            }
    }  
    /*
    Definition : To open Knowledge Article on the selection 
     */
    openTabHandlerRecord(parentid,labelName,recordIdtoOpen){
        openSubtab(parentid, {
            recordId:recordIdtoOpen,
            label:labelName,
            focus:true,
            icon:"standard:knowledge"
        }).catch(error=>{
            console.error("Error in opening tab",error);
        });
    } 
    handleKeyChange(event) {  
        this.searchKey = event.target.value;
        if (this.searchKey.length === 0) {
          this.showcross = false;
          this.removeDropDown();
          this.showRecentlyViewedArticles();
        }
        if (event.keyCode !== 13) {
          this.showcross=true;
          this.showDropdown = true;
          if (this.debounceTimeout) {
            clearTimeout(this.debounceTimeout);
          }
    
          if (this.searchKey.length === 0) {
            this.clearSelectedRecord();
            this.showcross=false;
          } else {
            this.debounceTimeout = setTimeout(() => {
              this.getLookupResult();
            }, 400);
          }
        } else {
          this.showDropdown = false;
        }
    } 
    handleEnter(event){
        this.searchKey = event.target.value; 
        if(event.keyCode === 13 && this.searchKey && this.searchKey.length > 0){
            this.showDropdown=false;
            this.handleIconClick();
        }
    }
    onLeave(event) {  
         setTimeout(() => {  
         this.recordsList = null; 
         this.hasRecords=false; 
         this.selectedValue = '';
         this.selectedRecordId = undefined;
         this.showRecentArticles = false;
         this.recentlyViewedArticles = [];
         }, 300);  
       }        
    @api
    removeRecordOnLookup(event) {  
     this.searchKey = ''; 
     this.hasRecords=true; 
     this.showcross=false;     
     this.onRemoveEmptyErrorPage(false); 
     this.clearSelectedRecord();
   } 
    @api
    setPlaceholderName(){
    this.template.querySelector('.inputbox').placeholder=SearchAnArticleHere;
    } 
    getLookupResult() {
        if (this.searchKey && this.searchKey.length > 0) {
          getTrackingDetails({ trackingNumber: this.searchKey })
            .then((result) => {
              if (result && result.length > 0) {
                this.hasRecords = true;
                this.showRecentArticles = false;
                this.recordsList = result;
                this.onRemoveEmptyErrorPage(false);
    
                // filtering using fuse
                this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey);
                this.handleSearchFuseData();
    
                // sort recordsList
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
      @api
      clearSelectedRecord() {
        this.selectedRecordId = undefined;
        this.searchKey = "";
        this.selectedValue = "";
        this.recordsList = null;
        this.hasRecords = false;
      }
    @api
    removeDropDown() {
        this.recordsList=null;
        this.hasRecords=false;
    }   
     /*
    Definition : To get the parent tab of the tab to close and pass it to close the subtab with the title KnowledgeSearchLabel
     */
    async closeSubTab(){
        try{
            if(this.isConsoleNavigation){
            const focusedTabInfo =await getFocusedTabInfo();
            if(focusedTabInfo.isSubtab){
                const parenttab = await getTabInfo(focusedTabInfo.parentTabId);
                this.closeTabHandler(parenttab);
            }
            else{
                this.closeTabHandler(focusedTabInfo);
         }
        }
        }
        catch(error){
            console.log('error in closing subtab '+error);
        }
    }
    closeTabHandler(parenttab){
        if(parenttab.subtabs){
            parenttab.subtabs.forEach(subtab=>{
            if(subtab.customTitle===KnowledgeSearchLabel){
                closeTab(subtab.tabId);
            }
    });
    }
    }   
    /*
    Definition : It checks the tab if it is a tab or a subtab and pass it to open the new subtab as its child
     */
    openSubTab(){
        getFocusedTabInfo().then((result)=>{         
            if(this.searchKey && this.searchKey.length > 0) {
                window.sessionStorage.setItem(SessionSearchKey,this.searchKey);
                this.openTabHandler((result.isSubtab)?result.parentTabId:this.enclosingParentTabID,KnowledgeSearchLabel,KnowledgeUrl);
        }
        }).catch((error)=>{
            console.log('error' + error);
        });
    }
    openTabHandler(parentid,labelName,urlName){
        openSubtab(parentid, {
            url:urlName,
            label:labelName,
            focus:true,
            icon:"standard:knowledge"
        }).catch(error=>{
            console.error("Error in opening tab",error);
        });
    }
    async handleIconClick(event){
        if(this.searchKey.length>0){
            if(this.isConsoleNavigation){
                            await this.closeSubTab();
                            setTimeout(() => {
                            this.openSubTab();
                            },KnowledgeTimeOut.valueOf() );
                            
                        }
                    }
        }
    onRemoveEmptyErrorPage(flag){
        const passEventNew = new CustomEvent('removeemptyerrorpage', {  
            detail: {flag: flag}  
        });  
        this.dispatchEvent(passEventNew); 
    }
    handleSearchFuseData() {
        var recs = this.recordsList; 
        const options = {
            includeScore: true,
            includeMatches:true,            
            shouldSort:true,
            useExtendedSearch: true,
            minMatchCharLength: 2,
            threshold:0.1,
            ignoreLocation:true,
            keys: ['title','strippedDetails']
        };
        const fuse = new Fuse(recs, options);
        this.recordsList = fuse.search(this.fuseSearchKey);
        this.recordsList = this.recordsList.map(a => a.item);
        this.recordsList = [...this.recordsList];
    }
    buildSearchKeyForFuse(sKey){
        var skeyArr=[];
        var sKeyOR='';
        var sKeyAnd='';
        var returnSKey='';
        skeyArr = sKey.split(' ');
        if(skeyArr.length === 1){
        returnSKey = "'"+sKey;
        }
        else if(skeyArr.length>1){
            for(let i=0; i<skeyArr.length; i++){
                sKeyAnd+=" '"+skeyArr[i];
                sKeyOR+=" | "+skeyArr[i];
            }
            returnSKey = sKeyAnd+sKeyOR;
        }
        else{
            returnSKey = "'"+sKey;
        }
        return returnSKey;
    }
}