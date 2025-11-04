import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import LATITUDE from '@salesforce/schema/Account.Latitude__c';
import LONGITUDE from '@salesforce/schema/Account.Longitude__c';
import RIS_SERVER from '@salesforce/schema/Account.RIS_Server__c';
import PRACTICE_OVERVIEW from '@salesforce/schema/Account.Practice_Overview__c';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import ID_FIELD from '@salesforce/schema/Account.Id';
import STREET_FIELD from '@salesforce/schema/Account.ShippingStreet';
import CITY_FIELD from '@salesforce/schema/Account.ShippingCity';
import POST_CODE_FIELD from '@salesforce/schema/Account.ShippingPostalCode';
import STATE_FIELD from '@salesforce/schema/Account.ShippingState';
import RIS_REQUESTS__OBJECT from "@salesforce/schema/RIS_Requests__c";
import ACCOUNT_NAME_FIELD from "@salesforce/schema/RIS_Requests__c.Account_Name__c";
import DESCRIPTION_FIELD from "@salesforce/schema/RIS_Requests__c.Description__c";
import SUBJECT_FIELD from "@salesforce/schema/RIS_Requests__c.Subject__c";
import TYPE_FIELD from "@salesforce/schema/RIS_Requests__c.Type__c";
import STATUS_FIELD from "@salesforce/schema/RIS_Requests__c.Status__c";
import fetchRecords from '@salesforce/apex/LwcRenamePracticeLocationController.fetchPracticeOverviewAccounts';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import RIS_DATA_MANAGER from '@salesforce/schema/User.RIS_Data_Manager__c';
import { getPracticeLocationsByPractice_helper1 } from './lwcRenameMergeLocation_helper1'; 
import { getAccountsForMerge_helper2, handleMergeSubmit_helper2, validRequired_helper2 } from './lwcRenameMergeLocation_helper2';
import {handleRenameAccounts_helper3 } from './lwcRenameMergeLocation_helper3';

const DELAY = 500;
const fields = [
	ID_FIELD,
	NAME_FIELD,
	LATITUDE,
	LONGITUDE,
	RIS_SERVER,
	PRACTICE_OVERVIEW,
	STREET_FIELD,
	CITY_FIELD,
	POST_CODE_FIELD,
	STATE_FIELD
];
const columns = [
	{
		label: 'Practice Location Name',
		fieldName: 'accountLink',
		type: 'url',
		sortable: 'true',
		initialWidth: 240,
		typeAttributes: {
			label: {
				fieldName: 'practiceName'
			},
			target: '_blank'
		}
	},
	{
		label: 'Street',
		fieldName: 'ShippingStreet',
		type: 'text',
		editable: false,
		initialWidth: 240,
	},
	{
		label: 'City',
		fieldName: 'ShippingCity',
		type: 'text',
		editable: false,
	},
	{
		label: 'ZIP code',
		fieldName: 'ShippingPostalCode',
		type: 'text',
		editable: false,
	},
];

export default class LwcRenameMergeLocation extends LightningElement {
	@track showRecentRecords;
	@track showNoRecentRecords;
	columns = columns;
	showForm = true;

	practiceLocation;
	error;
	@track long;
	@track lat;
	@track locationStreet;
	@track locationCity;
	@track practiceLocationName;
	@track matchingAccountList;
	@track showMergeKeepCmp;

	@api objectApiName;
	@api recordId;
	@api isScreenAction;
	@track showProcess = true;
	@track selectedRows = [];

	fieldApiName = "Name";
	searchString = "";
	selectedRecordId = "";
	helpText = "Select Practice Overview";
	labelSearchSelect = "Indicate a Practice Overview to associate the Practice Location with";
	selectedIconName = "standard:account";
	objectLabel = "Account";
	selectedRecordName;
	practiceOverviewList = [];
	isValueSelected;
	renameToAccount;
	selectedPracticeOverviewId;

	@track showMatchingLocations;
	@track showMessageForSelectedLocation;

	preventClosingOfSerachPanel = false;

	@track mergeAccount = [];
	@track selectedAccountIds = [];
	@track showMergeButton;
	@track showRename;
	@track showRenameProcess = true;
	@track isCreateNewPractice = true;
	@track isSaveNewPractice;
	@track isNewPracticeName;
	
	fldsItemValues = [];
	draftValues = [];
	@track mode;
	@track variant;
	@track message;
	@track arrFaxExist;
	@track arrPhoneExist;
	@track arrName = [];
	@track arrAddress = [];
	@track arrOwner = [];
	@track arrPhone = [];
	@track arrFax = [];
	@track arrAccountIds = [];
	@track showErrorMessage = false;
	@track showSaveButton = false;
	@track countMergeRecords = false;
	@track messageRecordTypesRecords = false;
	@track messageProfileUsers = false;
	@track showMessage = false;
	accessProfileToMerge = ['System Administrator', 'Sales Rep', 'RIS Data Manager', 'RIS Profile', 'Manager Profile', 'VP&Director Profile'];
	nameValue = '';
	addressValue = '';
	ownerValue = '';
	phoneValue = '';
	faxValue = '';
	textCommentValue = '';
	renameInput='';
	userManager;
	a_Record_URL;
	isShowMergeModal = false;
	@track messageString;
	@track messageExistsData = [];
	newRisRequest = {};

	connectedCallback() {
		this.a_Record_URL = window.location.origin;
		if (this.recordId && this.recordId != '') {
			this.showProcess = true;
		}
	}

	async handleChange(event) {
		const selectedOption = event.detail.value;
		this.searchString = event.target.value;

		if (!this.isValueSelected) {
			this.fetchSobjectRecords(false);
		} else {
			this.isValueSelected = true;
			await getPracticeLocationsByPractice_helper1(this);
		}
	}

	async handleSelect(event) {
		event.preventDefault();
		let objId = event.target.getAttribute('data-recid');		
		let selectedRecordObj = this.practiceOverviewList.find(data => data.id === objId);
		this.selectedPracticeOverviewId = selectedRecordObj.id;
		this.selectedRecordName = selectedRecordObj.mainField;
		this.renameToAccount = objId;
		this.showRecentRecords = false;
		this.isValueSelected = true;
		await getPracticeLocationsByPractice_helper1(this);
	}

	get methodPrcticeLocationInput() {
		return {
			matchingLatitude: this.lat.split('.')[0],
			matchingLongitude: this.long.slice(1).split('.')[0],
			selectedPracticeOverviewId: this.selectedPracticeOverviewId
		}
	}

	handleCommit() {
		this.moveToAccount = "";
		this.selectedRecordName = "";
		this.isValueSelected = false;
		this.searchString = '';
		this.showNoRecentRecords = false;
		this.selectedRows =[];
		this.matchingAccountList = [];
		this.showMatchingLocations = false;
		this.showMessageForSelectedLocation = true;
	}


	fetchSobjectRecords(loadEvent) {
		fetchRecords({
			inputWrapper: this.methodInput
		}).then(result => {
			this.showRecentRecords = true;
			if (loadEvent && result) {
				this.selectedRecordName = result[0].mainField;
			} else if (result) {
				this.practiceOverviewList = JSON.parse(JSON.stringify(result));
			} else {
				this.practiceOverviewList = [];
				this.showNoRecentRecords = true;
			}
		}).catch(error => {
			console.log(error);
		})
	}

	get methodInput() {
		return {
			objectApiName: this.objectApiName,
			fieldApiName: this.fieldApiName,
			searchString: this.searchString,
			selectedRecordId: this.recordId
		};
	}

	getSelectedRecords(event) {
		const selectedRows = event.detail.selectedRows;
		this.mergeAccount = [];
		this.selectedAccountIds = [];
		for (let i = 0; i < selectedRows.length; i++) {
			this.mergeAccount.push(selectedRows[i].Id);
			this.selectedAccountIds.push(selectedRows[i].Id);
		}
		this.selectedAccountIds = [...this.selectedAccountIds, this.recordId];
		this.showMergeButton = (this.selectedAccountIds.length > 1) ? true : false;
		this.showRename = (this.selectedAccountIds.length > 1) ? false : true;
	}

	async handleRenameAccounts() {
		await handleRenameAccounts_helper3(this);
	}

	async handleMergeAccounts() {
		this.showRenameProcess = false;
		this.showMergeKeepCmp = true;
		await getAccountsForMerge_helper2(this);
		this.showMergeButton = false;
	}

	async returnToPrevious() {
		this.showRenameProcess = true;
		this.showMergeKeepCmp = false;
		await getPracticeLocationsByPractice_helper1(this);
		this.showMergeButton = true;
		this.showErrorMessage = false;
		this.showRename = true;
	}

	async handleChangeName(event) {
		const selectedOption = event.detail.value;
		this.nameValue = selectedOption;
		await validRequired_helper2(this);
	}

	async handleChangeAddress(event) {
		const selectedOption = event.detail.value;
		this.addressValue = selectedOption;
		await validRequired_helper2(this);
	}

	async handleChangeOwner(event) {
		const selectedOption = event.detail.value;
		this.ownerValue = selectedOption;
		await validRequired_helper2(this);
	}

	handleChangePhone(event) {
		const selectedOption = event.detail.value;
		this.phoneValue = selectedOption;
	}

	handleChangeFax(event) {
		const selectedOption = event.detail.value;
		this.faxValue = selectedOption;
	}

	handleInputChange(event) {
		this.textCommentValue = event.detail.value;
	}

	handleNewNameChange(event){
		this.renameInput = event.detail.value;
	}

	async handleMergeSubmit() {
		await handleMergeSubmit_helper2(this);
	}

	updateAccount() {
		const fields = {};
		fields[ID_FIELD.fieldApiName] = this.recordId;
		fields[PRACTICE_OVERVIEW.fieldApiName] = this.selectedPracticeOverviewId;

		const recordInput = { fields };

		updateRecord(recordInput)
			.then(() => {
				this.closeModal();
				this.showToast('Success', 'Account updated', 'success', 'dismissable');
			})
			.catch(error => {
				this.closeModal();
				this.showToast('Error updating record', error.body.message, 'error', 'dismissable');
			});
	}

	handleCreateNewPractice() {
		this.showMergeKeepCmp = false;
		this.showRenameProcess = false;
		this.isNewPracticeName = true;
		this.isSaveNewPractice = true;
		this.isCreateNewPractice = false;
		this.showMessage = false;
		this.showRename = true;
	}

	async handleSaveNewPractice() {
		const fields = {};
		fields[STATUS_FIELD.fieldApiName] = 'New';
		fields[TYPE_FIELD.fieldApiName] = 'Renaming an account';
		fields[SUBJECT_FIELD.fieldApiName] = 'New Practice Group';
		fields[ACCOUNT_NAME_FIELD.fieldApiName] = this.recordId;
		const text = 'Practice location ' + this.practiceLocationName + ' is being renamed to <strong style="color: rgb(8, 39, 131);">' + this.renameInput +'</strong>';
		fields[DESCRIPTION_FIELD.fieldApiName] = text;
		const recordInput = { apiName: RIS_REQUESTS__OBJECT.objectApiName, fields };

		try {
			const account = await createRecord(recordInput);
			console.log('account ', account);
			let message = 'New Request Type was created ' + account.fields.Name.value + '!';
			this.showToast('Success', message, 'success', 'dismissable');
			this.closeModal();
		} catch (error) {
			let message = error.body.message;
			this.showToast('Error', message, 'Error', 'dismissable');
			this.closeModal();
		}
	}

	handleDivClick() {
		this.preventClosingOfSerachPanel = true;
	}

	handleBlur() {
		this.practiceOvverviewList = [];
		this.preventClosingOfSerachPanel = false;
	}

	handleInputBlur() {
		window.clearTimeout(this.delayTimeout);
		this.delayTimeout = setTimeout(() => {
			if (!this.preventClosingOfSerachPanel) {
				this.practiceOvverviewList = [];
			}
			this.preventClosingOfSerachPanel = false;
		}, DELAY);
	}


	@wire(getRecord, { recordId: '$recordId', fields: fields })
	wiredRecord({ error, data }) {
		if (error) {
			let message = 'Unknown error';
			if (Array.isArray(error.body)) {
				message = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				message = error.body.message;
			}
			this.showToast('Error', message, 'error', 'dismissable');
		} else if (data) {
			this.practiceLocation = data;
			this.long = this.practiceLocation.fields.Longitude__c.value;
			this.lat = this.practiceLocation.fields.Latitude__c.value;
			this.practiceLocationName = this.practiceLocation.fields.Name.value;
			let postal = (this.practiceLocation.fields.ShippingPostalCode.value === 'undefined' || this.practiceLocation.fields.ShippingPostalCode.value === 'null' || !this.practiceLocation.fields.ShippingPostalCode.value) ? '' : this.practiceLocation.fields.ShippingPostalCode.value;
			let street = (this.practiceLocation.fields.ShippingStreet.value === 'null' || !this.practiceLocation.fields.ShippingStreet.value) ? '' : this.practiceLocation.fields.ShippingStreet.value;
			let city = (this.practiceLocation.fields.ShippingCity.value === 'null' || !this.practiceLocation.fields.ShippingCity.value) ? '' : this.practiceLocation.fields.ShippingCity.value ;
			let state = (this.practiceLocation.fields.ShippingState.value === 'null' || !this.practiceLocation.fields.ShippingState.value) ? '' : this.practiceLocation.fields.ShippingState.value ;
			this.locationStreet= street;
			this.locationCity = city + ', ' + postal + ', ' + state;
		}
	}

	@wire(getRecord, { recordId: Id, fields: [Name, RIS_DATA_MANAGER, PROFILE_NAME_FIELD] })
	userDetails({ error, data }) {
		if (error) {
			this.error = error;
		} else if (data) {
			if (data.fields.RIS_Data_Manager__c.value != null) {
				this.userManager = data.fields.RIS_Data_Manager__c.value;
			}
			let profileName = data.fields.Profile.value.fields.Name.value;
			if (this.accessProfileToMerge.includes(profileName)) {
				this.messageProfileUsers = false;
			} else {
				this.messageProfileUsers = true;
			}
		}
	}

	closeModal() {
		this.clearValues();
		const closeEvent = new CustomEvent('close');
		this.dispatchEvent(closeEvent);
		if (this.isScreenAction) {
			let actionRename = this.template.querySelector('c-lwc-rename-practice-location');
			if (actionRename) {
				actionRename.closeModal();
			}
		}

	}

	async clearValues() {
		this.recordId = '';
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