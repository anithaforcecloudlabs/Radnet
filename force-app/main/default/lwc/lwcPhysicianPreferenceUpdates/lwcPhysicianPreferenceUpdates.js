import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import TYPE_FIELD from '@salesforce/schema/RIS_Requests__c.Type__c';
import currentUserId from '@salesforce/user/Id';
import {
	getPhysicianPreferenceUpdates_helper1,
	handleApprove_helper1,
	handleReject_helper1
} from './lwcPhysicianPreferenceUpdates_helper1';

import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import ManagerName from '@salesforce/schema/User.Manager.Name';

const actions = [
	{ label: 'Approve', name: 'approve' },
	{ label: 'Reject', name: 'reject' },
];

const columns = [
	{
		label: 'Detail Record',
		fieldName: 'recordDetail',
		type: 'url',
		typeAttributes: {
			label: { fieldName: 'recordName' },
			target: '_blank'
		},
		sortable: 'true',
		initialWidth: 20,
	},
	{
		label: 'Physician',
		fieldName: 'contactLink',
		type: 'url',
		typeAttributes: {
			label: { fieldName: 'physicianName' },
			target: '_blank'
		},
		sortable: 'true',
		initialWidth: 120,
	},
	{
		label: 'NPI',
		fieldName: 'physicianNPI',
		type: 'text',
		editable: false
	},
	{
		label: 'Contact Phone New',
		fieldName: 'Contact_Phone_New__c',
		type: 'phone',
		editable: false
	},
	{
		label: 'Contact Fax New',
		fieldName: 'Contact_Fax_New__c',
		type: 'phone',
		editable: false
	},
	{
		label: 'Email Reports New',
		fieldName: 'Email_Reports_New__c',
		type: 'boolean',
		editable: false
	},
	{
		label: 'Preferred Reader New',
		fieldName: 'Preferred_Reader_New__c',
		type: 'text',
		editable: false
	},
	{
		label: 'Status',
		fieldName: 'Status__c',
		type: 'text',
		editable: false
	},
	// Uncomment if you want row actions
	// {
	//	  type: 'action',
	//	  typeAttributes: { rowActions: actions },
	// },
];

const removedColumns = [
	{
		label: 'Detail Record',
		fieldName: 'recordDetail',
		type: 'url',
		typeAttributes: {
			label: { fieldName: 'recordName' },
			target: '_blank'
		},
		sortable: 'true',
		initialWidth: 120,
	 },
	 {
		label: 'Physician',
		fieldName: 'contactLink',
		type: 'url',
		typeAttributes: {
			label: { fieldName: 'physicianName' },
			target: '_blank'
		},
		sortable: 'true',
		initialWidth: 280,
	 },
	 {
		label: 'NPI',
		fieldName: 'physicianNPI',
		type: 'text',
		editable: false
	 },
];

export default class LwcPhysicianPreferenceUpdates extends NavigationMixin(LightningElement) {
	@api recordId;
	@track showColumns;
	columns = columns;
	removedColumns = removedColumns;
	error;
	@track physicianUpdatesData;
	@track physicianUpdatesObjectData = [];
	@track hasPhysicianUpdates;
	@track physicianUpdatesLabel;
	@track selectedRelatedRequestIds = [];
	@track setSelectedRows = [];
	@track relatedRisRequestApproved = [];
	@track showComp;
	@track showViewAll;
	@track isLoading = false;

	@track sortBy;
	@track sortDirection;

	activeSections = 'A';
	errorMessage;

	userId = Id;
	userName;
	userRoleName;
	userProfileName;
	userManagerName;
	a_Record_URL;
	loadComp;
	CHANNEL_NAME = '/event/Refresh_Record_Event__e';
	createdRecord = false;
	subscription = {};
	viewAllLink;

	@wire(getRecord, { recordId: '$recordId', fields: [TYPE_FIELD] })
	risRequest({ error, data }) {
		if (data) {
			const requestType = data.fields.Type__c.value;
			if (requestType === 'Physician removed') {
				this.showColumns = this.removedColumns;
			} else {
				this.showColumns = this.columns;
			}
		} else if (error) {
			this.error = error;
		}
	}

	 connectedCallback() {
		this.a_Record_URL = window.location.origin;
		this.viewAllLink = this.a_Record_URL + '/lightning/r/RIS_Requests__c/' + this.recordId + '/related/Related_Requests1__r/view';
		this.loadComp = true;
		this.handleLoad();
		subscribe(this.CHANNEL_NAME, -1, this.manageEvent).then(response => {
			this.subscription = response;
		});
		onError(error => {
			console.log('Server Error--->' + error);
		});
	 }

	 @wire(getRecord, { recordId: Id, fields: [Name, RoleName, ProfileName, ManagerName] })
	 userDetails({ error, data }) {
		if (error) {
			this.error = error;
		} else if (data) {
			if (data.fields.Name.value != null) {
					this.userName = data.fields.Name.value;
			}
			if (data.fields.UserRole.value != null) {
				this.userRoleName = data.fields.UserRole.value.fields.Name.value;
			}
			if (data.fields.Profile.value != null) {
				this.userProfileName = data.fields.Profile.value.fields.Name.value;
			}
			if (data.fields.Manager.value != null) {
				this.userManagerName = data.fields.Manager.value.fields.Name.value;
			}
		}
	 }

	 manageEvent = event => {
		const refreshRecordEvent = event.data.payload;
		if (!this.createdRecord && refreshRecordEvent.Record_Id__c === this.recordId && refreshRecordEvent.User_Id__c === currentUserId) {
			this.handleLoad();
		} else if (this.createdRecord && refreshRecordEvent.User_Id__c === currentUserId) {
			this.handleLoad();
		}
	}

	async handleLoad() {
		await getPhysicianPreferenceUpdates_helper1(this);
	}

	getSelectedRecords(event) {
		const selectedRows = event.detail.selectedRows;
		this.selectedRelatedRequestIds = [];
		for (let i = 0; i < selectedRows.length; i++) {
			this.selectedRelatedRequestIds.push(selectedRows[i].Id);
		}
	}

	handleApprove() {
		this.asyncApprove();
	}

	async asyncApprove() {
		await handleApprove_helper1(this);
	}

	handleReject() {
		this.asyncReject();
	}

	async asyncReject() {
		await handleReject_helper1(this);
	}

	handleViiewAll() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordRelationshipPage',
			attributes: {
				recordId: this.recordId,
				objectApiName: 'Related_Request__c',
				relationshipApiName: 'Related_Requests1',
				actionName: 'view'
			},
		});
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
	
	handleSortData(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		this.sortData(event.detail.fieldName, event.detail.sortDirection);
	}
	
	sortData(fieldname, direction) {
		let parseData = JSON.parse(JSON.stringify(this.physicianUpdatesData));
		let keyValue = (a) => {
				return a[fieldname];
		};
		let isReverse = direction === 'asc' ? 1 : -1;
		parseData.sort((x, y) => {
			x = keyValue(x) ? keyValue(x) : '';
			y = keyValue(y) ? keyValue(y) : '';
			return isReverse * ((x > y) - (y > x));
		});
		this.physicianUpdatesData = parseData;
	}
}