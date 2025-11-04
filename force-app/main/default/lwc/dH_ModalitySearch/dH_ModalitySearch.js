/*
* ***************************************************************************************************************************
* LWC Component Name - dH_ModalitySearch.js
* Created Date - 14-July-2024
* Function - JS class to provide the Modality Search functionality in the P360 view.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                     Date                 Description
* ----------------         --------------       ---------------------
* CC-488                   14-July-2024        Added handleClick method
* *****************************************************************************************************************************
*/
import { LightningElement, wire } from 'lwc';
import {IsConsoleNavigation, openSubtab, EnclosingTabId ,closeTab ,getFocusedTabInfo ,getTabInfo} from 'lightning/platformWorkspaceApi'
import ModalitySearchURL from '@salesforce/label/c.DH_ModalitySearchURL';
import ModalitySearch from '@salesforce/label/c.DH_ModalitySearch';
import KnowledgeTimeOut from '@salesforce/label/c.DH_KnowledgeTimeOutP360';

export default class DH_ModalitySearch extends LightningElement{
    label ={
        ModalitySearch,
        ModalitySearchURL
    };   
    @wire(IsConsoleNavigation)
    isConsoleNavigation
    @wire(EnclosingTabId)
    enclosingParentTabId 
    //method which is called when the button is clicked to open the Modality Search. 
    async handleClick(){
        if(this.isConsoleNavigation){
            await this.closeSubTab();
            setTimeout(() => {
            this.openSubTab();
            },KnowledgeTimeOut.valueOf());   
        }
    }
    //To get the parent tab of the tab to close and pass it to close the subtab with the title this.label.ModalitySearch
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
    //To close the sub tab if the sub tab title is same as with the title this.label.ModalitySearch.
    closeTabHandler(parenttab){
        if(parenttab.subtabs){
            parenttab.subtabs.forEach(subtab=>{
                if(subtab.customTitle===this.label.ModalitySearch){
                    closeTab(subtab.tabId);
                }
            });
        }
    }
    //checks if the tab is a tab or a subtab and will pass it to open the new subtab as its child
    openSubTab(){
        getFocusedTabInfo().then((result)=>{
            this.openTabHandler((result.isSubtab)?result.parentTabId:this.enclosingParentTabId,this.label.ModalitySearch,this.label.ModalitySearchURL);
        }).catch((error)=>{
            console.log('error in the openSubTab: ' + JSON.stringify(error));
        });
    }
    //function to opens the Modality search in a new sub tab.
    openTabHandler(parentid,labelName,urlName){
        openSubtab(parentid, {
            url:urlName,
            label:labelName,
            focus:true,
            icon:"utility:search"
        }).catch(error=>{
            console.error("Error in opening tab: ",JSON.stringify(error));
        });
    }
}