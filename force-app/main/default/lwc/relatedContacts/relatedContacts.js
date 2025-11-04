import {LightningElement, api, track, wire}from 'lwc';
import {updateRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {encodeDefaultFieldValues} from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name'; //this scoped module imports the current user profile name
import isRisManagerUser from '@salesforce/schema/User.RIS_Data_Manager__c';
import { getRecord, getFieldValue} from "lightning/uiRecordApi";
import {handleRelatedContacts_helper1,handleSave_helper1} from './relatedContacts_helper1';
import {handleRenameContacts_helper2, handleSaveRename_helper2, handleContactsForRemove_helper2, handleRemove_helper2} from './relatedContacts_helper2';
import {handleAcrsToMove_helper3, handleToMove_helper3} from './relatedContacts_helper3';
import {handleSaveEditNotes_helper4} from './relatedContacts_helper4';
import COUNTRY_FIELD from "@salesforce/schema/Account.ShippingCountry";
import CITY_FIELD from "@salesforce/schema/Account.ShippingCity";
import STREET_FIELD from "@salesforce/schema/Account.ShippingStreet";
import STATE_FIELD from "@salesforce/schema/Account.ShippingState";
import POSTALCODE_FIELD from "@salesforce/schema/Account.ShippingPostalCode";
import fetchRecords from '@salesforce/apex/RelatedContactController.fetchRecords';
/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 500;

const FIELDS = [
	COUNTRY_FIELD,
	CITY_FIELD,
	STREET_FIELD,
	STATE_FIELD,
	POSTALCODE_FIELD
];

const actions = [
	{ label: 'View Relationship', name: 'view' },
	{ label: 'Edit Relationship', name: 'edit' }
];
const westactions = [{
	label: 'View Relationship',	name: 'view'}
];

const columns = [
	{
		label: 'Contact Name',
		fieldName: 'contactLink',
		type: 'url',
		sortable: 'true',
		initialWidth: 140,
		typeAttributes: {
			label: {
				fieldName: 'contactName'
			},
			target: '_blank'
		}
	},
	{
		label: 'Physician NPI',
		fieldName: 'physicianNPI',
		type: 'text',
		editable: false,
		initialWidth: 120,
	},
	{
		label: 'Budget Spent',
		fieldName: 'contactBudgetSpent',
		type: 'currency',
		editable: false,
		initialWidth: 80,
	},
	{
		label: 'Contact Phone',
		fieldName: 'Phone__c',
		type: 'phone',
		editable: true,
		initialWidth: 120,
	},
	{
		label: 'Contact FAX',
		fieldName: 'FAX__c',
		type: 'phone',
		editable: true,
	}, 
	{
		label: 'Contact Email',
		fieldName: 'Contact_Email__c',
		type: 'email',
		editable: true,
	}, 
	{
		label: 'PAP',
		fieldName: 'physicianPAP',
		type: 'boolean',
		editable: false,
		initialWidth: 80,
	},
	{
		label: 'Imaging Notes',
		fieldName: 'imagePreference',
		type: 'text',
		wrapText:true,
		initialWidth: 120,
		editable: false
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

const westcolumns = [
	{
		label: 'Contact Name',
		fieldName: 'contactLink',
		type: 'url',
		sortable: 'true',
		initialWidth: 140,
		typeAttributes: {
			label: {
				fieldName: 'contactName'
			},
			target: '_blank'
		}
	},
	{
		label: 'Physician NPI',
		fieldName: 'physicianNPI',
		type: 'text',
		editable: false,
		initialWidth: 120,
	},
	{
		label: 'Budget Spent',
		fieldName: 'contactBudgetSpent',
		type: 'currency',
		editable: false,
		initialWidth: 80,
	},
	{
		label: 'Contact Phone',
		fieldName: 'Phone__c',
		type: 'phone',
		editable: false,
		initialWidth: 120,
	},
	{
		label: 'Contact FAX',
		fieldName: 'FAX__c',
		type: 'phone',
		editable: false,
	},
	{
		label: 'Contact Email',
		fieldName: 'Contact_Email__c',
		type: 'email',
		editable: false,
	},
	{
		label: 'PAP',
		fieldName: 'physicianPAP',
		type: 'boolean',
		editable: false,
		initialWidth: 80,
	},
	{
		label: 'Imaging Notes',
		fieldName: 'imagePreference',
		type: 'text',
		wrapText: true,
		initialWidth: 120,
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
			rowActions: westactions
		},
	},
];

export default class RelatedContacts extends NavigationMixin(LightningElement) {
	@api recordId;
	@api tabName;

	columns = columns;
	westcolumns = westcolumns;
	
	@track contacts;
	@track isLoading = false;
	@track sortBy;
	@track sortDirection;
	@track removeList = [];
	@track moveACRList = [];
	@track selectedContactIds = [];
	@track selectedRenameList = [];
	@track isShowFormModal;
	@track isShowRemoveModal;
	@track isShowMoveModal;
	@track removePhysList = [];
	@track movePhysList = [];
	@track caseNumber;
	@track showComp;
	@track showRecentRecords;
	@track showNoRecentRecords;
	@track relatedRisUpdates = [];
	@track relatedRisMoveUpdates = [];
	@track showMoveConfirm;
	@track selectedEditNotesList = [];
	@track isWestSalesRepUser;

	error;
	activeSections = 'A';
	rowOffset = 0;
	draftValues = [];
	draftMoveValues = [];
	contactLabel;
	setSelectedRows = [];
	physiciansUpdates;
	physiciansMoveUpdates;
	physiciansFields;
	changeReason = '';
	commentValue = '';
	value = '';
	physRemoveData = [];
	isRisDataManager;
	userProfileName;
	userId = Id;
	isValueSelected;
	helpText = "select new practice location";
	labelSearchSelect = "Future practice location";
	required;
	selectedIconName = "standard:account";
	objectLabel = "Account";
	recordsList = [];
	selectedRecordName;
	objectApiName = "Account";
	fieldApiName = "Name";
	moveToAccount;
	searchString = "";
	selectedRecordId = "";
	parentRecordId;
	parentFieldApiName;
	preventClosingOfSerachPanel = false;
	messageData = [];
	messageNewData = [];
	isShowExistRisRequestModal;
	existShow;
	newShow;
	isShowEditNotes;
	westUsersReps = ['West Sales Rep', 'West Coast Sales Reps'];

	get options() {
		return [
			{ label: 'No Longer with Practice', value: 'No Longer with Practice' },
			{ label: 'Retired', value: 'Retired' },
			{ label: 'Deceased', value: 'Deceased' },
			{ label: 'Other', value: 'Other' },
		];
	}

	@wire(getRecord, { recordId:'$recordId', fields: FIELDS})
	accountData;

	connectedCallback() {
		this.a_Record_URL = window.location.origin;
		this.handleLoadContacts();
	}

	async handleLoadContacts() {
		await handleRelatedContacts_helper1(this); 
	}

   handleRowAction = (event) => {
		const actionName = event.detail.action.name;
		const row = event.detail.row;
		if (actionName === 'view' || actionName === 'edit') {
			this.navigateToRecordAcionPage(actionName, row.Id);
		}
	};

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
	
	getSelectedRecords(event) {
		const selectedRows = event.detail.selectedRows;
		this.removeList = [];
		this.moveACRList = [];
		this.selectedContactIds = [];
		selectedRows.forEach(row => {
			this.removeList.push(row.Id);
			this.moveACRList.push(row.Id);
			this.selectedContactIds.push(row.ContactId);
		});
	}

	handleRename() {
		this.asyncRename();	
	}

	async asyncRename() { 
		await handleRenameContacts_helper2(this);
	}
	
	handleSaveRename() {		
		this.asyncSaveRename();	
	}

	async asyncSaveRename() {
		await handleSaveRename_helper2(this);
	}

	async handleSaveEditNotes() {
		await handleSaveEditNotes_helper4(this);
	}

	handleMove() {
		if (this.moveACRList.length) { 
			this.isShowMoveModal = true;
			handleAcrsToMove_helper3(this);
		} else {
			this.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
			this.isShowMoveModal = false;
		}
	}

	handleAddRelation(event) {
		const defaultValues = encodeDefaultFieldValues({
			AccountId: this.recordId,
		});
		let url = '/lightning/r/Account/' + this.recordId + '/view';
		event.preventDefault();

		this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {
				objectApiName: 'AccountContactRelation',
				actionName: 'new'
			},
			state: {
				defaultFieldValues: defaultValues,
				nooverride: 1,
				useRecordTypeCheck: 1,
				navigationLocation: 'DETAIL',
				backgroundContext: url
			}
		}).then(() => {
			this.handleIsLoading(true);
			handleRelatedContacts_helper1(this);
		}).finally(() => {
			this.handleIsLoading(false);
		});
	}

	handleRemove() {
		this.isShowRemoveModal = true;
		this.getPhysicians();
	}

	async getPhysicians() { 
		await handleContactsForRemove_helper2(this);
	}

	handleRemoveButton() {
		let formDivs = this.template.querySelectorAll(`form[data-id='form-physician-remove-reason'] div[data-id]`);
		for (let element of formDivs) {
			let contactId = element.dataset.id;
			let physRemoveDataObj = { phyAccId: contactId };
			let contactReason = this.template.querySelector(`lightning-radio-group[data-id='${contactId}']`).value;
			let contactComment = this.template.querySelector(`lightning-textarea[data-id='${contactId}']`).value;
			physRemoveDataObj.phyReason = 'What is a reason for removing this physician? ' + '\n' + contactReason + '\n';
			physRemoveDataObj.phyComment = '\n' + 'Comment  '+ contactComment;
			this.physRemoveData = [...this.physRemoveData, physRemoveDataObj];
		}
		this.asyncRemove();
	}

	async asyncRemove() { 
		await handleRemove_helper2(this);
	}
	
	async handleSave(event) {
		const records = event.detail.draftValues.slice().map((draftValue) => {
			const fields = Object.assign({}, draftValue);
			return {
				fields
			};
		});
		this.physiciansUpdates = event.detail.draftValues;

		if (!this.isRisDataManager) {
			await handleSave_helper1(this);
		}
		this.draftValues = [];

		try {
			if (this.isRisDataManager) {
				await Promise.all(records.map(record => updateRecord(record)));
				await handleRelatedContacts_helper1(this);
				setTimeout(() => {
					this.showToast('Success', `Contacts updated.`, 'success', 'dismissable');
				}, 100);
			}
		} catch (error) {
			const { errors, fieldErrors } = error.body.output;
			if (errors) {
				errors.forEach(err =>
					this.showToast('Error updating or reloading contacts', `${err.errorCode}- ${err.message}`, 'Error', 'dismissable')
				);
			}
			if (fieldErrors) {
				Object.values(fieldErrors).forEach(val =>
					this.showToast('Error updating or reloading contacts', val[0]["message"], 'Error', 'dismissable')
				);
			} else {
				this.showToast('Error updating or reloading contacts', error.body.message, 'Error', 'dismissable');
			}
			await handleRelatedContacts_helper1(this);
		}
	}
	
	async moveSave(event) {
		this.physiciansMoveUpdates = event.detail.draftValues;
	}
	
	@wire(getRecord, { recordId: Id, fields: [isRisManagerUser, ProfileName] })
	userDetails({ error, data }) {
		if (error) {
			this.error = error;
		} else if (data) {
			this.isRisDataManager = data.fields.RIS_Data_Manager__c.value;
			if (data.fields.Profile.value != null) {
				this.userProfileName = data.fields.Profile.value.fields.Name.value;
				this.isWestSalesRepUser = this.westUsersReps.includes(this.userProfileName);;
			}
		}
	}

	showToast(title, message, variant, mode) {
		this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode }));
	}

	showToastLink(title, message, messageTitle, linkUrl, linkLabel) {
		const event = new ShowToastEvent({
			"title": title,
			"message": message,
			"messageData": [
				messageTitle,
				{
					url: linkUrl,
					label: linkLabel
				}
			]
		});
		
		this.dispatchEvent(event);
	}

	updateColumnSorting(event) {
		const { fieldName, sortDirection } = event.detail;
		this.sortedBy = fieldName;
		this.sortedDirection = sortDirection;
		this.data = this.sortData(fieldName, sortDirection);
	}

	closeModal() {
		this.isShowFormModal = false;
		this.isShowRemoveModal = false;
		this.isShowMoveModal = false;
		this.setSelectedRows = [];
		this.removeList = [];
		this.selectedContactIds = [];
		this.moveACRList = [];
		this.moveToAccount = "";
		this.selectedRecordName = "";
		this.isValueSelected = false;
		this.searchString ='';
		this.physiciansMoveUpdates = [];
		this.showMoveConfirm = false;
		this.isShowExistRisRequestModal = false;
		this.template.querySelector('lightning-datatable').selectedRows = [];
		this.existShow = false;
		this.newShow = false;
		this.isShowEditNotes = false;
	}

	handleSortData(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		this.sortData(event.detail.fieldName, event.detail.sortDirection);
	}

	sortData(fieldname, direction) {
		let parseData = JSON.parse(JSON.stringify(this.contacts));
		let keyValue = (a) => {
			return a[fieldname];
		};
		let isReverse = direction === 'asc' ? 1 : -1;
		parseData.sort((x, y) => {
			x = keyValue(x) ? keyValue(x) : '';
			y = keyValue(y) ? keyValue(y) : '';

			return isReverse * ((x > y) - (y > x));
		});
		this.contacts = parseData;
	}

	handleIsLoading(isLoading) {
		this.isLoading = isLoading;
	}

	get methodInput() {
		return {
			objectApiName: this.objectApiName,
			fieldApiName: this.fieldApiName,
			searchString: this.searchString,
			selectedRecordId: this.recordId
		};
	}

	handleChange(event) {
		this.searchString = event.target.value;
		if (!this.isValueSelected) {
			this.fetchSobjectRecords(false);
		} else {
			this.isValueSelected = true;
		}
	   
	}

	fetchSobjectRecords(loadEvent) {
		fetchRecords({
			inputWrapper: this.methodInput
		}).then(result => {			
			this.showRecentRecords = true;
			if (loadEvent && result) {
				this.selectedRecordName = result[0].mainField;
			} else if (result) {
				this.recordsList = JSON.parse(JSON.stringify(result));
			} else {
				this.recordsList = [];
				this.showNoRecentRecords = true;
			}
		}).catch(error => {
			console.log(error);
		})
	}

	handleSelect (event){
		event.preventDefault();
		var objId = event.target.getAttribute('data-recid');	
		let selectedRecordObj = this.recordsList.find(data => data.id === objId);
		this.selectedRecordName = selectedRecordObj.mainField; 
		this.moveToAccount = objId;
		this.showRecentRecords = false;
		this.isValueSelected = true;		
	}

	handleCommit() {
		this.moveToAccount = "";
		this.selectedRecordName = "";
		this.isValueSelected = false;
		this.searchString ='';
		this.showNoRecentRecords = false;
	}

	async handleMoveButton() {		
		if (!this.moveToAccount) {
			this.showToast('Please select Future practice location', 'Please select Future practice location', 'warning', 'dismissable');
		} 
		else {			
			this.showMoveConfirm = true;
		}
	}
	
	async handleMoveOk() {	
		await handleToMove_helper3(this);
		await handleRelatedContacts_helper1(this);
	}

	handleDivClick() {
		this.preventClosingOfSerachPanel = true;
	}

	handleBlur() {
		this.recordsList = [];
		this.preventClosingOfSerachPanel = false;
	}

	handleInputBlur(event) {
		window.clearTimeout(this.delayTimeout);
		this.delayTimeout = setTimeout(() => {
			if (!this.preventClosingOfSerachPanel) {
				this.recordsList = [];
			}
			this.preventClosingOfSerachPanel = false;
		}, DELAY);
	}

	get street() {
		return getFieldValue(this.accountData.data, STREET_FIELD);
	}
	
	get city() {
		return getFieldValue(this.accountData.data, CITY_FIELD);
	}

	get country() {
		return getFieldValue(this.accountData.data, COUNTRY_FIELD);
	}

	get state() {
		return getFieldValue(this.accountData.data, STATE_FIELD);
	}

	get postalcode() {
		return getFieldValue(this.accountData.data, POSTALCODE_FIELD);
	}
}