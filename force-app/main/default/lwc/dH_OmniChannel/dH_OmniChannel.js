/*
* **************************************************************************************************************************************************************************************
* LWC Component Name - DH_OmniChannel.js
* Created Date - 06-Aug-2024
* Function - JS class of contact center verify caller screen to close tab when call is disconnected.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       ---------------------
* CC-691                     09-Aug-2024          Added closeTabs,handlegetAllTabInfo,messageCallback,disconnectedCallback,handleUnSubscribe,handleSubscribe,connectedCallback methods
* **************************************************************************************************************************************************************************************
*/
import { LightningElement,track,api ,wire } from 'lwc';
import {subscribe, unsubscribe} from 'lightning/empApi';
import { EnclosingTabId, getTabInfo , closeTab, getAllTabInfo} from 'lightning/platformWorkspaceApi';
import getMyGroupNumber from '@salesforce/apex/DH_VoiceCallTriggerHepler.getGroupNumberForUser';
import userId from '@salesforce/user/Id';
import IS_MULTI_CHANNEL from '@salesforce/label/c.DH_IsMultipleChannel';

export default class DH_OmniChannel extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track idToClose;
    @wire(EnclosingTabId) tabId;
    isSubTab;
    channelName;
    subscription={};
    @track allTabList=[];
    isMultiChannel = IS_MULTI_CHANNEL;

    connectedCallback() {
        if(this.isMultiChannel.toLowerCase() === 'true'){
            getMyGroupNumber({userId : userId})
            .then(groupNum => {
                this.channelName = `/event/CloseVC_Group${groupNum}__e`;
                console.log('channelName'+this.channelName);
                this.handleSubscribe();
                this.handlegetAllTabInfo();
            })
            .catch(error => {
                console.error('Failed to get group number', error);
            });
        }else{
            this.channelName = '/event/DH_EventLog__e';
            console.log('channelName'+this.channelName);
            this.handleSubscribe();
            this.handlegetAllTabInfo(); 
        }
    }
    handleSubscribe(){
        console.log('Inside handleSubscribe of DH_OmniChannel');
        subscribe(this.channelName, -1,this.messageCallback).then(response=>{
            console.log('this.channelName inside handleSubscribe',this.channelName);
            //console.log('this.messageCallBack inside handleSubscribe',this.messageCallback);
            this.subscription=response;
            console.log('response',response);
            console.log('this.subscription',this.subscription);
        }).catch(error=>{
            console.log('error '+error);
        })
    }
    handleUnSubscribe(){
        console.log('Inside unSubscribe of DH_OmniChannel');
        unsubscribe(this.subscription, response=>{
            console.log('unsubscribe from  : ' + JSON.stringify(response));
        })
    }
    disconnectedCallback() {
        this.handleUnSubscribe();
    }
    messageCallback=(response)=>{
        console.log('Inside messageCallback of DH_OmniChannel');
        let actName = response.data.payload.DH_SObjectId__c;
        let serviceName = response.data.payload.DH_ServiceName__c;
        this.idToClose = actName;
       if(this.serviceName='CallEndEvent'){
            console.log('Closing tabs');
            this.closeTabs();
            console.log('after Closing tabs');
       }
    }
    handlegetAllTabInfo(){
        console.log('Inside handlegetAllTabInfo');
        getAllTabInfo().then((allTabInfo)=>{
            this.allTabList = allTabInfo;
        }).catch(function(error){
            console.log(error);
        });
    }
     closeTabs(){
        console.log('Inside close Tabs method level 1');
        if(this.allTabList){
            console.log('Inside close Tabs level 2');
            this.allTabList.forEach(tab=>{
                if(tab.title===this.idToClose){
                    console.log('Inside close Tab level 3');
                    closeTab(tab.tabId);
                }
            });
        }
    }   
}