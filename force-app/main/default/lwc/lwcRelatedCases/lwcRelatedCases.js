import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import AccountId from '@salesforce/schema/Case.AccountId';
import Subject from '@salesforce/schema/Case.Subject';
const fields = [AccountId, Subject];
import getRelatedRisRequest from '@salesforce/apex/LwcRelatedCasesAPX.getRelatedRisRequestAPX';
import handleCloseRisRequest from '@salesforce/apex/LwcRelatedCasesAPX.handleCloseRisRequestAPX';
import handleInReviewRisRequest from '@salesforce/apex/LwcRelatedCasesAPX.handleInReviewRisRequestAPX';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';
const columns = [
    {
        label: 'Ris Request',
        fieldName: 'caseLink',
        type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'number'
                },
                target: '_blank'
        },
        sortable: 'true',
        
    },{
        label: 'Status',
        fieldName: 'status',
        type: 'text',
        sortable: 'true',
        //initialWidth: 60,
    },{
        label: 'Type',
        fieldName: 'typeCase',
        type: 'text',
        sortable: 'true',
        editable: false,
        //initialWidth: 60,
    },
];
export default class LwcRelatedCases extends LightningElement {
    @api recordId;
    caseRecord;
    @api accountRecord;
    @track displayColumns;
    @track listUpdateRisRequest = [];
    setSelectedRows = [];
    a_Record_URL;
    columns = columns;
    @track isLoading = false;
    @track showData = false;
    connectedCallback() {
        this.a_Record_URL = window.location.origin;
        //console.log('data connectedCallback' , this.accountRecord);
    }
    getSelectedRecords(event) {
		const selRows = event.detail.selectedRows;		
		this.listUpdateRisRequest = [];
		this.selectedRisRequest = [];
		for (let i = 0; i < selRows.length; i++) {
			this.listUpdateRisRequest.push(selRows[i].Id);
		}
        //console.log('data listUpdateRisRequest' , this.listUpdateRisRequest);
    }

    handleClosed() {
		this.asyncHandleClosed();
	}
    handleInReview(){
        this.asyncHandleInReview();
    }

	async asyncHandleClosed() {
        this.isLoading = true;
		if (this.listUpdateRisRequest.length) {
            handleCloseRisRequest({
                caseIds: this.listUpdateRisRequest
            }).then((result) => {
               console.log('result ', result);
               this.isLoading = false;
               this.setSelectedRows=[];
               this.template.querySelector('lightning-datatable').selectedRows = [];
               this.showToast('Ris Requests closed.', '', 'Success', 'dismissable');
            }).catch(error => {                             
                this.showToast(
                    'Error updating or reloading contacts', 
                    error.body,
                    'Error', 
                    'dismissable');                 			
            }).finally(() => {
                console.log('finally ');
                this.getRelatedCases(this.accountRecord);
                this.listUpdateRisRequest = [];
                this.setSelectedRows=[];
                this.template.querySelector('lightning-datatable').selectedRows = [];
            });
        } else {
            
        }
	}

    async asyncHandleInReview() {
        this.isLoading = true;
		if (this.listUpdateRisRequest.length) {
            handleInReviewRisRequest({
                caseIds: this.listUpdateRisRequest
            }).then((result) => {               
               this.isLoading = false;
               this.selectedRisRequest = [];
               this.setSelectedRows=[];
               this.template.querySelector('lightning-datatable').selectedRows = [];
               this.showToast('Ris Requests set to In Review.', '', 'Success', 'dismissable');
            }).catch(error => {                             
                this.showToast(
                    'Error updating or reloading contacts', 
                    error.body,
                    'Error', 
                    'dismissable');                 			
            }).finally(() => {
                console.log('finally ');
                this.getRelatedCases(this.accountRecord);
                this.listUpdateRisRequest = [];
                this.setSelectedRows=[];
                
            });
        } else {
            
        }
	}

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [AccountId, Subject]
    })
    wireTypeElements({ error, data }) { 
        if (data) {
            this.error = undefined;
            this.caseRecord = data;
            
            //this.accountRecord = this.caseRecord.AccountId;
            if (data.fields.AccountId.value != null) {
                this.accountRecord = data.fields.AccountId.value;
            }
            this.getRelatedCases(this.accountRecord);
            console.log('data wireTypeElements' , this.caseRecord);
            console.log('data wireTypeElements' , this.accountRecord);
            console.log('data  data.fields.AccountId.value' ,  data.fields.AccountId.value);
        } else if (error) {
            console.log('error', error);
            this.error = error;
        };
    }
   
    async getRelatedCases(accountId){
        console.log('getRelatedRisRequest', this.accountRecord);
        getRelatedRisRequest({ accountId: accountId, caseId : this.recordId})
        .then(data => {
                this.showData = true;           
                console.log('data getRelatedRisRequest' , data);               
                let resp = JSON.parse(JSON.stringify(data));
                resp.forEach(item => {
                    console.log('item ', item);
                    item['caseLink'] = this.a_Record_URL + '/lightning/r/Case/' + item['Id'] + '/view';
                    
                    item['name'] = item.Account.Name;
                    item['number'] = item['CaseNumber'];
                    item['status'] = item['Status'];
                    item['typeCase'] = item['Type'];            
                    
                });
              
                this.displayColumns = resp;
                console.log('this.displayColumns ', JSON.stringify(this.displayColumns));
            
        })
        .catch(error => {
            console.log('error displayColumns ', error.body);
            this.error = error;
        })
	}
    handleIsLoading(isLoading) {
		this.isLoading = isLoading;
    }

    showToast(title, message, variant, mode) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
    }
}