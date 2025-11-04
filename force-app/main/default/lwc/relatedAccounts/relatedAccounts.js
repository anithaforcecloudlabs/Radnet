import { LightningElement, api, track, wire } from 'lwc';
import {updateRecord} from 'lightning/uiRecordApi';
import mergeAcrs from '@salesforce/apex/RelatedAccountsAPX.mergeAcrs';
import getDuplicateRecordsAfterMerged from '@salesforce/apex/RelatedAccountsAPX.getDuplicateRecordsAfterMerged';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {encodeDefaultFieldValues} from 'lightning/pageReferenceUtils';
import { getRecord } from 'lightning/uiRecordApi';

import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

import USER_ID from '@salesforce/user/Id';
import RIS_MANAGER_USER_FIELD from '@salesforce/schema/User.RIS_Data_Manager__c';

import {create_RIS_Request_helper2} from './relatedAccounts_helper2';
import {createRISReqOnPhysRemove_helper5} from './relatedAccounts_helper5';
import {createRISReqOnLocationRename_helper7} from './relatedAccounts_helper7';
import {checkNumberOfAccsSelected_helper8} from './relatedAccounts_helper8';
import {getAccountsForMerge_helper9} from './relatedAccounts_helper9';
import {buildMergeNotes_helper10} from './relatedAccounts_helper10';

import {
	relatedGetAccounts_helper1,
	relatedRenameAccounts_helper1,
	relatedSaveRenameAccounts_helper1,
	getAccountForMerge_helper1,
	relatedRemove_helper1
} from './relatedAccounts_helper1';
const actions = [{
	label: 'View Relationship',
	name: 'view'
}, {
	label: 'Edit Relationship',
	name: 'edit'
}];

const westActions = [{
	label: 'View Relationship',
	name: 'view'
}];

const columns = [
	{
		label: 'Practice Location',
		fieldName: 'accountLink',
		type: 'url',
			typeAttributes: {
				label: {
					fieldName: 'AccountName'
				},
				target: '_blank'
			},
		sortable: 'true',
		initialWidth: 120,
	},
	{
		label: 'Street',
		fieldName: 'street',
		type: 'text',
	},
	{
		label: 'Zip/Postal Code',
		columnKey: 'AccountPostal',
		fieldName: 'postalCode',
		type: 'text',
	}, 
	{
		label: 'Contact Phone',
		fieldName: 'Phone__c',
		type: 'phone',
		editable: true
	}, 
	{
		label: 'Contact FAX',
		fieldName: 'FAX__c',
		type: 'phone',
		editable: true
	}, 
	{
		label: 'Contact Email',
		fieldName: 'Contact_Email__c',
		type: 'email',
		editable: true
	},
	{
		label: 'Preferred Reader',
		fieldName: 'Preferred_Reader__c',
		type: 'text',
		editable: true
	}, 
	{
		type: 'action',
		typeAttributes: {
			rowActions: actions
		},
	},
];

const westRepscolumns = [
	{
		label: 'Practice Location',
		fieldName: 'accountLink',
		type: 'url',
		typeAttributes: {
			label: {
				fieldName: 'AccountName'
			},
			target: '_blank'
		},
		sortable: 'true',
		initialWidth: 120,
	},
	{
		label: 'Street',
		fieldName: 'street',
		type: 'text',
	},
	{
		label: 'Zip/Postal Code',
		columnKey: 'AccountPostal',
		fieldName: 'postalCode',
		type: 'text',
	},
	{
		label: 'Contact Phone',
		fieldName: 'Phone__c',
		type: 'phone',
		editable: false
	},
	{
		label: 'Contact FAX',
		fieldName: 'FAX__c',
		type: 'phone',
		editable: false
	},
	{
		label: 'Contact Email',
		fieldName: 'Contact_Email__c',
		type: 'email',
		editable: false
	},
	{
		label: 'Preferred Reader',
		fieldName: 'Preferred_Reader__c',
		type: 'text',
		editable: false
	},
	{
		type: 'action',
		typeAttributes: {
			rowActions: westActions
		},
	},
];

export default class RelatedAccounts extends NavigationMixin(LightningElement) {
	@api recordId;
	@track accountObjData;
	columns = columns;
	westRepscolumns = westRepscolumns;
	error;
	draftValues = [];
	loadComp;
	@track showComp;
	setSelectedRows = [];
	@track isShowFormModal;
	@api isShowMergeModal;
	@track isLoading = false;
	selectedAccounts = [];	
	@track arrFaxExist;
	@track arrPhoneExist;
	@track arrName = [];
	@track arrAddress = [];
	@track arrOwner = [];
	@track arrPhone = [];
	@track arrFax = [];
	@track arrAccountIds = [];
	@track sortBy;
	@track sortDirection;
	@track listForRemove = [];
	@track selectedAccountsForRename = [];
	
	disabled = false;
	activeSections = 'A';	
	url;
	nameValue = '';
	addressValue = '';
	ownerValue = '';
	phoneValue = '';
	faxValue = '';
	textCommentValue = '';
	showSaveButton = false;
	errorMessage;
	isRisRequestManager = false;
	@track isWestSalesRepUser;

	@wire(getRecord, { recordId: USER_ID, fields: [RIS_MANAGER_USER_FIELD, PROFILE_NAME_FIELD] })
	userDetails({ error, data }) {
		if (error) {
			this.error = error;
		} else if (data) {
		   this.isRisRequestManager = data.fields[RIS_MANAGER_USER_FIELD.fieldApiName].value;
			let userProfileName = data.fields.Profile.value.fields.Name.value;
			this.isWestSalesRepUser = (userProfileName == 'West Sales Rep' || userProfileName == 'West Coast Sales Reps') ? true : false;
		}
	}

	connectedCallback() {
		this.a_Record_URL = window.location.origin;
		this.loadComp = true;
		this.handleLoad();
	}
	
	handleMerge() {
		// if (this.selectedAccounts.length) {
		// 	let resp = JSON.parse(JSON.stringify(this.selectedAccounts));			
		// 	if (resp.length == 1) {
		// 		setTimeout(() => {
		// 			this.showToast('Error', 'Please add account, it is not possible to merge 1 account', 'Error', 'dismissable');
		// 		}, 120);				
		// 		this.setSelectedListToNull();
		// 	}
		// 	if (resp.length > 3) {
		// 		setTimeout(() => {
		// 			this.showToast('Error', 'It is not possible to merge more than 3 accounts', 'Error', 'dismissable');
		// 		}, 120);
		// 		this.setSelectedListToNull();				
				
		// 	}
		// 	if (resp.length == 3 || resp.length == 2) {				
		// 		this.setSelectedRows = this.template.querySelector("lightning-datatable").getSelectedRows();				
		// 		let recordsType = this.setSelectedRows.filter(item => item.Account.RecordType.DeveloperName == "Practice_Location");
				
		// 		if (recordsType.length === resp.length) {					
		// 			this.isShowMergeModal = true;					
		// 			this.handleMergeAccounts();
		// 			this.selectedAccounts = [];
					
		// 		} else {
		// 			this.showToast(
		// 				'SuDifferent record typesccess',
		// 				'It is not possible to merge these accounts due to because of different record types',
		// 				'warning',
		// 				'dismissable'
		// 			);
		// 			this.setSelectedListToNull();
		// 			this.selectedAccounts = [];
		// 		}
		// 	}
		// } else {
		// 	this.showToast('Accounts not selected','Please select accounts', 'Error', 'warning');
		// }

		this.showToast(`ERROR`,`This functionality is not available right now. Please contact system administrator`,`error`,`dismissible`);
	}

	async handleMergeAccounts() { 
		await getAccountForMerge_helper1(this);
	}

	handleChangeName(event) { 
		const selectedOption = event.detail.value;		
		this.nameValue = selectedOption;
		this.validRequired();
	}

	handleChangeAddress(event) { 
		const selectedOption = event.detail.value;		
		this.addressValue = selectedOption;
		this.validRequired();
	}

	handleChangeOwner(event) { 
		const selectedOption = event.detail.value;		
		this.ownerValue = selectedOption;
		this.validRequired();
	}

	handleChangePhone(event) { 
		const selectedOption = event.detail.value;		
		this.phoneValue  = selectedOption;
	}

	handleChangeFax(event) { 
		const selectedOption = event.detail.value;		
		this.faxValue  = selectedOption;
	}

	handleInputChange(event) {
		this.textCommentValue = event.detail.value;	
		
	}

	validRequired() {
		if (this.nameValue  && this.addressValue && this.ownerValue) { 
			this.showSaveButton = true;
		};
	}

	handleMergeSubmit(event) {
		// this.isLoading = true;	
		// this.validRequired();		
		// let noteMerge = 'Name: ' + this.nameValue + '\n' + 'Address: ' + this.addressValue + '\n'+'Owner: ' + this.ownerValue;
		// noteMerge = (this.phoneValue) ? noteMerge + '\n' + 'Phone: ' + this.phoneValue : noteMerge;
		// noteMerge = (this.faxValue) ? noteMerge +'\n' +'Fax: ' +this.faxValue : noteMerge;
		
		// noteMerge = (this.textCommentValue) ? noteMerge + '\n' + 'Comment: ' + this.textCommentValue : noteMerge;
		// this.isShowMergeModal = false;
		
		// mergeAcrs({
		// 	accountIds:this.arrAccountIds,
		// 	noteMerge: noteMerge
		// }).then(result => {			
		// 	this.textCommentValue = '';
		// 	if (result === 'error') {				
		// 		this.showToast('These accounts have the same related contact.', 'Open the related contact and remove the redundant account–contact relationship. Then try merging again.', 'Error', 'dismissable');
		// 	} else {
		// 		setTimeout(() => {
		// 			this.getDuplicateRecordId(this.arrAccountIds);
		// 		}, 150);
		// 	}
		// 	this.setSelectedListToNull();
		// }).catch(error => {
		// 	this.setSelectedListToNull();
		// 	this.showToast('Error', error.body.message, 'Error', 'dismissable');
		// });
	}
	
	getDuplicateRecordId(accounts) {		
		this.setSelectedListToNull();
		this.isLoading = false;
		getDuplicateRecordsAfterMerged({
			recordIds: accounts
		}).then(result => {
			if (result !== 'error') {
				this.showToast('Success', 'A RIS request has been created for this merge request', 'Success', 'dismissable');				
				this.setSelectedListToNull();			
			} else {
				this.setSelectedListToNull();			
				this.showToast('Error', 'It is not possible to merge this records', 'Error', 'dismissable');
			}
		}).catch(error => {
			this.setSelectedListToNull();
		});
	}
	
	handleSaveRename() {
		this.asyncSaveRename();
	}

	async asyncSaveRename() { 
		// await relatedSaveRenameAccounts_helper1(this);
		await createRISReqOnLocationRename_helper7(this);
	}

	handleRename() {
		this.asyncRename();
	}
	async asyncRename() { 
		await relatedRenameAccounts_helper1(this);
	}

	handleAddRelation(event) {
		const defaultValues = encodeDefaultFieldValues({
			ContactId: this.recordId,
		});
		event.preventDefault();
		this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {
				objectApiName: 'AccountContactRelation',
				actionName: 'new'
			},
			state: {
				defaultFieldValues: defaultValues,
			},
		}).then(generatedUrl => {
			window.open(generatedUrl);
		});
	}

	// handleRemove() {
	// 	this.asyncRemoveAcrs();
	// }

	// async asyncRemoveAcrs() { 
	// 	await relatedRemove_helper1(this);
	// }

	onRemoveBtnClick(event){
		if(event){
			this.handleOnRemoveBtnClick();
		}
	}

	async handleOnRemoveBtnClick(){
		await createRISReqOnPhysRemove_helper5(this);
	}

	async handleLoad() {
		await relatedGetAccounts_helper1(this);
	}

	onSaveTableVals(event) {
		if(event){
			this.draftValues = event.detail.draftValues;
			this.handleOnSaveTableVals();
		}
	}

	async handleOnSaveTableVals() {
		if (PROFILE_NAME_FIELD == 'System Administrator'){
			await create_RIS_Request_helper2(this, this.draftValues, true);
		} else{
			await create_RIS_Request_helper2(this, this.draftValues, true);
		}

		this.draftValues = [];
	}
	
	// async handleSave(event) {
	// 	// Convert datatable draft values into record objects
	// 	const records = event.detail.draftValues.slice().map((draftValue) => {			
	// 		const fields = Object.assign({}, draftValue);
	// 		return {
	// 			fields
	// 		};
	// 	});
		
	// 	// Clear all datatable draft values
	// 	this.draftValues = [];

	// 	try {
	// 		// Update all records in parallel thanks to the UI API
	// 		const recordUpdatePromises = records.map((record) =>
	// 			updateRecord(record)
	// 		);
	// 		await Promise.all(recordUpdatePromises);
			
	// 		await relatedGetAccounts_helper1(this);
	// 		setTimeout(() => {
	// 			this.showToast('Success', 'Accounts relations updated', 'Success', 'dismissable');
	// 		}, 100);
	// 	} catch (error) {
	// 		var errors = error.body.output.errors;
	// 		var fieldErrors = error.body.output.fieldErrors;			
	// 		console.log('error.body. ', JSON.stringify(error.body));
	// 		if (error.body.output.errors != null) {
	// 			console.log('Displaying Errors')
	// 			// Loop & Display Errors
	// 			for (let index = 0; index < error.body.output.errors.length; index++) {
	// 				console.log('Displaying Errors');
	// 				this.showToast(
	// 					'Error updating or reloading contacts', 
	// 					error.body.output.errors[index].errorCode + '- ' + error.body.output.errors[index].message,
	// 					'Error', 
	// 					'dismissable');
	// 			}
	// 		}

	// 		if (error.body.output.fieldErrors != null) {
	// 			for (var prop in fieldErrors) {
	// 				console.log(Object.keys(fieldErrors));
	// 				console.log('prop', prop);
	// 				var val = Object.values(fieldErrors);
	// 				this.showToast(
	// 					'Error updating or reloading contacts', 
	// 					val[0][0]["message"], 
	// 					'Error', 
	// 					'dismissable');
	// 			}
	// 		} else {
	// 			console.log('Displaying Generic Errors')
	// 			this.showToast(
	// 				'Error updating or reloading contacts', 
	// 				error.body.message,
	// 				'Error', 
	// 				'dismissable');
	// 		}		
	// 		//this.showToast('Error updating or reloading contacts', error.body.message, 'Error', 'dismissable');
	// 		await relatedGetAccounts_helper1(this);
	// 	}
	// }
	
	setSelectedListToNull() {
		this.template.querySelector('lightning-datatable').listForRemove = [];
		this.template.querySelector('lightning-datatable').setSelectedRows = [];
		this.template.querySelector('lightning-datatable').selectedAccounts = [];
		this.listForRemove = [];
		this.selectedAccounts = [];
		this.setSelectedRows = [];
		this.arrName = [];
		this.arrAddress = [];
		this.arrOwner = [];
		this.arrPhone = [];
		this.arrFax = [];
	}
	
	closeModal() {
		// to close modal set isModalOpen tarck value as false
		this.isShowFormModal = false;
		this.isShowMergeModal = false;
		this.setSelectedRows = [];
		this.listForRemove = [];
		this.selectedAccounts = [];		
		this.arrName = [];
		this.arrAddress = [];
		this.arrOwner = [];
		this.arrPhone = [];
		this.arrFax = [];
		this.template.querySelector('lightning-datatable').listForRemove = [];
		this.template.querySelector('lightning-datatable').setSelectedRows = [];
		this.template.querySelector('lightning-datatable').selectedAccounts = [];
	}
	getSelectedRecords(event) {
		const selRows = event.detail.selectedRows;		
		this.listForRemove = [];
		this.selectedAccounts = [];
		for (let i = 0; i < selRows.length; i++) {
			this.listForRemove.push(selRows[i].Id);
			this.selectedAccounts.push(selRows[i].AccountId);
		}
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
	
	handleRowAction(event) {
		this.actionName = event.detail.action.name;
		const row = event.detail.row;
		switch (this.actionName) {
			case 'view':
				this.navigateToRecordAcionPage('view', row.Id);
				break;
			case 'edit':
				this.navigateToRecordAcionPage('edit', row.Id);
				break;
			default:
		}
	}

	navigateToRecordAcionPage(event, recordValue) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordValue,
				objectApiName: 'AccountContactRelation',
				actionName: event
			},
		})
	}
	
	handleIsLoading(isLoading) {
		this.isLoading = isLoading;
	}
	
	handleSortData(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		this.sortData(event.detail.fieldName, event.detail.sortDirection);
	}
	
	sortData(fieldname, direction) {
		let parseData = JSON.parse(JSON.stringify(this.accountObjData));
		let keyValue = (a) => {
			return a[fieldname];
		};
		let isReverse = direction === 'asc' ? 1 : -1;
		parseData.sort((x, y) => {
			x = keyValue(x) ? keyValue(x) : '';
			y = keyValue(y) ? keyValue(y) : '';
			return isReverse * ((x > y) - (y > x));
		});
		this.accountObjData = parseData;
	}

	onMergeBtnClick(event){
		if(event){
			this.handleMergeBtnClick();
		}
	}

	async handleMergeBtnClick(){
		// Check how many records are selected
		let proceedToNextStep = await checkNumberOfAccsSelected_helper8(this);
		if(proceedToNextStep){
			this.isShowMergeModal = true;
			await getAccountsForMerge_helper9(this);
		}
	}


	onMergeSubmitBtnClick(event){
		if(event){
			this.handleMergeSubmitBtnClick();
		}
	}

	async handleMergeSubmitBtnClick(){
		this.isLoading = true;
		await buildMergeNotes_helper10(this);
	}

}