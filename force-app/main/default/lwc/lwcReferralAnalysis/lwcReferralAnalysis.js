import { LightningElement, api, track } from 'lwc';
import {
    handleSetParams_helper1, setInitialDateValues_helper1, getPhysicianNPI_helper1
} from './lwcReferralAnalysis_helper1';

import {
    getReferrals_helper2
} from './lwcReferralAnalysis_helper2';

import {
    deselectPhysiciansInList_helper3, setPhysicianReferralList_helper3, filterDeselectedSites_helper3, showColumnsObject_helper3
} from './lwcReferralAnalysis_helper3';

import {
    handleSetParams_helper4,getReferrals_helper4, setLocationReferralList_helper4, showColumnsObject_helper4,deselectPhysiciansInList_helper4
} from './lwcReferralAnalysis_helper4';

export default class LwcReferralAnalysis extends LightningElement {

    @api recordId;
    @api objectApiName;
    isLoading = false;
    //CURRENTLY USING
    @track startDate;
    @track endDate;
    payloadToPOST;
    contactObj = false;
    accountObj = false;
    listReferralTableColumns;
    listReferralTableDataSelected;
    listReferralAllTableData;
    listPhysicians=[];
    listSites =[];
    listLocations=[];
    //WILL USE WHEN REQUIRED
    listModalities;
    physIdToModalityData;
    setPhysicians;

    setSites;
    listReferralFilteredTableData = [];
    listReferralTableData = [];
    numberOfSelectedSites =0;
    numberOfSelectedSitesLabel;
    numberOfSelectedReferrals =0;
    numberOfSelectedReferralsLabel;

    listSelectedPhysicians;
    showTable = false;

    connectedCallback() {
        this.handleInitialLoad();        
    }

    async handleInitialLoad() {
        if (this.objectApiName === 'Contact') {
            this.contactObj = true;
            await handleSetParams_helper1(this);
            await setInitialDateValues_helper1(this);           
            await getPhysicianNPI_helper1(this);
            await getReferrals_helper2(this);
            await setPhysicianReferralList_helper3(this);
            await showColumnsObject_helper3(this);
        }
        else if (this.objectApiName === 'Account') {            
            this.accountObj = true;           
            await handleSetParams_helper4(this);
            await getReferrals_helper4(this);
            await setLocationReferralList_helper4(this);
            await showColumnsObject_helper4(this);
        }

    } 
    
    async handleComboboxButtonClick(event) {
        if (event) {
            let buttonType = event.currentTarget.dataset.buttonType;          
            if (buttonType != null && buttonType != '') {
                let divComboboxCompSlds = this.template.querySelector(`div[data-selection-type="${buttonType}"]`);
                if (divComboboxCompSlds) {
                    if (divComboboxCompSlds.classList.contains('slds-is-open')) {                        
                        this.template.querySelector(`div[data-selection-type="${buttonType}"]`).classList.add('slds-is-close');
                        this.template.querySelector(`div[data-selection-type="${buttonType}"]`).classList.remove('slds-is-open');
                    }
                    else if (divComboboxCompSlds.classList.contains('slds-is-close')) {                       
                        this.template.querySelector(`div[data-selection-type="${buttonType}"]`).classList.add('slds-is-open');
                        this.template.querySelector(`div[data-selection-type="${buttonType}"]`).classList.remove('slds-is-close');
                    }
                }
            }
        }
    }
    
    async handlePhysicianFilterSelection(event){
        if (event) {
            if (this.objectApiName === 'Account') {
                await deselectPhysiciansInList_helper4(this); 
            } else if (this.objectApiName === 'Contact') {
                await deselectPhysiciansInList_helper3(this); 
            }
                     
        }
    }

    async handleSiteRecFilterSection(event){
        if (event) {
            if (this.objectApiName === 'Account') {
                await deselectPhysiciansInList_helper4(this); 
            } else if (this.objectApiName === 'Contact') {
                await filterDeselectedSites_helper3(this); 
            }
                      
        }
    }
    
    async handleShowClick() { 
        this.showTable = true;
        this.listReferralTableDataSelected = this.listReferralAllTableData;
        if (this.objectApiName === 'Account') {
            await setLocationReferralList_helper4(this); 
        } else if (this.objectApiName === 'Contact') {
            await setPhysicianReferralList_helper3(this);
        }
        
    }
 
    handleFilterChanges(event){
        if (event) {            
            this.findPhysicians();
        }
     }

    async findPhysicians(){
        await this.getStartDate();
        await this.getEndDate();
        if (this.startDate && this.endDate) {
            if (this.objectApiName === 'Contact') {
                await getPhysicianNPI_helper1(this);
                await getReferrals_helper2(this);
                await setPhysicianReferralList_helper3(this); 
                await showColumnsObject_helper3(this);
            } else if (this.objectApiName === 'Account') {
                await getReferrals_helper4(this);
                await setLocationReferralList_helper4(this);
                await showColumnsObject_helper4(this);
            }            
        }
    }

    async getStartDate() {
        this.showTable = false;
        let startDateCmp = await this.template.querySelector('lightning-input[data-input-id="startDateInput"]');
        if(startDateCmp) {       
            this.startDate = startDateCmp.value;
        }
    }

    async getEndDate() {
        this.showTable = false;
        let endDateCmp = await this.template.querySelector('lightning-input[data-input-id="endDateInput"]');
        if(endDateCmp) {       
            this.endDate = endDateCmp.value;
        }
    }
}