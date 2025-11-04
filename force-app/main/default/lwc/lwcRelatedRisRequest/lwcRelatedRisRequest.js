import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import AccountId from '@salesforce/schema/RIS_Requests__c.Account_Name__c';
import Subject from '@salesforce/schema/RIS_Requests__c.Subject__c';

import getRelatedRisRequest from '@salesforce/apex/LwcRelatedRisRequestApx.getRelatedRisRequestAPX';
import handleCloseRisRequest from '@salesforce/apex/LwcRelatedRisRequestApx.handleCloseRisRequestAPX';
import handleInReviewRisRequest from '@salesforce/apex/LwcRelatedRisRequestApx.handleInReviewRisRequestAPX';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const fields = [AccountId, Subject];

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
 
export default class LwcRelatedRisRequest extends LightningElement {
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
                if (data.fields.Account_Name__c.value != null) {
                    this.accountRecord = data.fields.Account_Name__c.value;
                }
                this.getRelatedCases(this.accountRecord);              
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
                    //console.log('data getRelatedRisRequest' , data);               
                    let resp = JSON.parse(JSON.stringify(data));
                    resp.forEach(item => {
                        //console.log('item ', item);
                        item['caseLink'] = this.a_Record_URL + '/lightning/r/RIS_Requests__c/' + item['Id'] + '/view';
                        
                        item['name'] = item.Account_Name__r.Name;
                        item['number'] = item['Name'];
                        item['status'] = item['Status__c'];
                        item['typeCase'] = item['Type__c'];            
                        
                    });
                  
                    this.displayColumns = resp;
                   // console.log('this.displayColumns ', JSON.stringify(this.displayColumns));
                
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