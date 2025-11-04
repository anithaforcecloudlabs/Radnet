/*
* ***************************************************************************************************************************
* LWC Component Name - dH_siteSearchBar.js
* Version - 0.1
* Created Date - 13-June-2024
* Function - JS class to provide the knowledge functionality in the P360 view.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                     Date                 Description
* ----------------         --------------       ---------------------
* CC-489                    13-June-2024        Added onRecordSelection,closeSubTab,closeTabHandler,openSubTab,openTabHandler,
                                                handleKeyChange,removeRecordOnLookup,getLookupResult and handleIconClick methods.
* *****************************************************************************************************************************
*/
import { LightningElement, track, wire, api } from "lwc";
import {IsConsoleNavigation, openSubtab, EnclosingTabId ,closeTab ,getFocusedTabInfo ,getTabInfo} from 'lightning/platformWorkspaceApi'
//imported apex methods
import findRecords from "@salesforce/apex/DH_SiteSearchOptions.findRecords";
//imported custom labels
import DH_SiteCodeTimeOut from '@salesforce/label/c.DH_SiteCodeTimeOut';
import KnowledgeTimeOut from '@salesforce/label/c.DH_KnowledgeTimeOutP360';
import SiteSearchUrl from '@salesforce/label/c.DH_SiteSearchUrl';
import SiteSearch from '@salesforce/label/c.DH_SiteSearch';
import RemoveSelectedRecord from '@salesforce/label/c.DH_RemoveSelectedRecord';
import SelectAnOption from '@salesforce/label/c.DH_SelectAnOption';
import SearchSiteCodeSiteName from '@salesforce/label/c.DH_SearchSiteCodeSiteName';

export default class DH_siteSearchBar extends LightningElement {
    @track recordsList;
    @track searchKey = "";
    @api selectedValue;
    @api selectedRecordId;
    @track objectApiName = 'Account';
    @track message;
    hasRecords = false;
    label ={
        SiteSearchUrl,
        SiteSearch,
        RemoveSelectedRecord,
        SelectAnOption,
        SearchSiteCodeSiteName
    };

    @wire(IsConsoleNavigation)
    isConsoleNavigation

    @wire(EnclosingTabId)
    enclosingParentTabId

    //handle focus leave
    onLeave(event) {
        setTimeout(() => {
        this.searchKey = "";
        this.recordsList = [];
        this.hasRecords = false;
        }, 300);
    }

    //handle record selection
    async onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        this.handleIconClick();
    }
    //To get the parent tab of the tab to close and pass it to close the subtab with the title this.label.SiteSearch
    async closeSubTab(){
        try{
            if(this.isConsoleNavigation){
                const focusedTabInfo =await getFocusedTabInfo();
                this.closeTabHandler((focusedTabInfo.isSubtab)?(this.closeTabHandler(await getTabInfo(focusedTabInfo.parentTabId))):this.closeTabHandler(focusedTabInfo));
            }
        }
        catch(error){
            console.log('error in closing subtab: '+JSON.stringify(error));
        }
    }
    closeTabHandler(parenttab){
        if(parenttab.subtabs){
            parenttab.subtabs.forEach(subtab=>{
                if(subtab.customTitle===this.label.SiteSearch){
                    closeTab(subtab.tabId);
                }
            });
        }
    }
    //checks if the tab is a tab or a subtab and will pass it to open the new subtab as its child
    openSubTab(){
        getFocusedTabInfo().then((result)=>{    
            //storing the values of selectedValue and selectedRecordId which will be used in the Site Search component.
            window.sessionStorage.setItem('selectedValue',this.selectedValue);
            window.sessionStorage.setItem('selectedRecordId',this.selectedRecordId);
            this.openTabHandler((result.isSubtab)?result.parentTabId:this.enclosingParentTabId,this.label.SiteSearch,this.label.SiteSearchUrl);
        }).catch((error)=>{
            console.log('error in the openSubTab: ' + JSON.stringify(error));
        });
    }
    openTabHandler(parentid,labelName,urlName){
        openSubtab(parentid, {
            url:urlName,
            label:labelName,
            focus:true,
            icon:"utility:feed"
        }).catch(error=>{
            console.error("Error in opening tab: ",JSON.stringify(error));
        });
    }
    async handleIconClick(event){        
        if(this.isConsoleNavigation){
            await this.closeSubTab();
            setTimeout(() => {
            this.openSubTab();
            },KnowledgeTimeOut.valueOf());   
        }
    }
    timeout;
    //handle search key change
    handleKeyChange(event) {       
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        window.clearTimeout(this.timeout);     
        this.timeout = setTimeout(() => {
            this.getLookupResult();
        }, DH_SiteCodeTimeOut);
    }
    removeRecordOnLookup(event) {
        this.searchKey = "";
        this.selectedValue = '';
        this.selectedRecordId = '';
        this.recordsList = [];
        this.hasRecords = false;
    }
    //Get all sites matches search key
    getLookupResult() {
        findRecords({ searchKey: this.searchKey, objectName: this.objectApiName})
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
}