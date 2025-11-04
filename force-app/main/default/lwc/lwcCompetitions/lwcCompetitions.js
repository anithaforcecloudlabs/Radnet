import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {updateRecord} from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from "lightning/uiRecordApi";
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import currentUserId from '@salesforce/user/Id';
import LightningConfirm from 'lightning/confirm';
import removeRelation from '@salesforce/apex/lwcCompetitionsAPX.removeRelation';
import { getRelatedCompetitions_helper1 } from './lwcCompetitons_helper1';

import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import ManagerName from '@salesforce/schema/User.Manager.Name';
import COMPETITION from '@salesforce/schema/Competition__c.Name';
import COMPETITION_ID from '@salesforce/schema/Competition__c.Id';

const fields = [
	COMPETITION,
	COMPETITION_ID
];

const actions = [
	{ label: 'Remove', name: 'delete'},
	{ label: 'Edit', name: 'edit'},
];

const columns = [
	{
		label: 'Competition',
		fieldName: 'competitionLink',
		type: 'url',
			typeAttributes: {
				label: {
					fieldName: 'name'
				},
				target: '_blank'
		},
		sortable: 'true',
		initialWidth: 90,
	},{
		label: 'Zip Code',
		fieldName: 'zipCode',
		type: 'text',
		sortable: 'true',
		initialWidth: 60,
	},{
		label: 'Status',
		fieldName: 'status',
		type: 'text',
		sortable: 'true',
		editable: false
	}, {
		label: 'MR',
		fieldName: 'mr',
		type: 'text',
		editable: false
	}, {
		label: 'CT',
		fieldName: 'ct',
		type: 'text',
		editable: false
	},{
		label: 'PETCT',
		fieldName: 'petct',
		type: 'text',
		editable: false
	},{
		label: 'PETMR',
		fieldName: 'petmr',
		type: 'text',
		editable: false
	},{
		label: 'Notes',
		fieldName: 'Notes__c',
		type: 'text',
		editable: true
	},{
		label: 'Preferred',
		fieldName: 'Preferred__c',
		type: 'boolean',
		editable: true
	}, {
		type: 'action',
		typeAttributes: {
			rowActions: actions
		},
	},
];
export default class LwcCompetitions extends NavigationMixin(LightningElement) {
	@api recordId;
	@api objectApiName;
	@api flexipageRegionWidth;
	@track competitions;
	@track lookupCompetitions;
	@track selectedValue;
	@track showComp;
	@track isLoading = false;

	@track sortBy;
	@track sortDirection;
	@track recordIdToDelete;

	columns = columns;
	draftValues = [];
	createdRecord = false;
	activeSections = 'A';
	error;
	loadComp;
	competitionsLabel;
	recordPageUrl;
	connected;
	competition;
	error;
	userId = Id;
	userName;
	userRoleName;
	userProfileName;
	userManagerName;
	reasonForDeletion ='';
	competitionName;

	subscription = {};
	isShowAlertDelete;

	CHANNEL_NAME = '/event/Refresh_Record_Event__e';
	
	@wire(getRecord, { recordId: '$recordId', fields: fields})
	competitiveDetails({ error, data }) {
		if (error) {
			this.error = error;
		} else if (data && data.fields.Name.value) {
			this.competitionName = data.fields.Name.value;
		}
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

	connectedCallback() {
		this.a_Record_URL = window.location.origin;
		this.loadComp = true;
		this.handleLoad();
		subscribe(this.CHANNEL_NAME, -1, this.manageEvent).then(response => {
			this.subscription = response;
		});
		onError(error => {
			console.error('Server Error--->'+error);
		});
		
	}

	manageEvent = event => {
		const refreshRecordEvent = event.data.payload;
		if (
			(!this.createdRecord && refreshRecordEvent.Record_Id__c === this.recordId && refreshRecordEvent.User_Id__c === currentUserId) ||
			(this.createdRecord && refreshRecordEvent.User_Id__c === currentUserId)
		) {
			this.handleLoad();
		}
	};

	async handleLoad() {
		await getRelatedCompetitions_helper1(this);
	}

	async handleAddCompetition(event) {		
		
		const defaultValues = encodeDefaultFieldValues({
			Related_Account__c: this.recordId,
		});
		
		event.preventDefault();
		await this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {
				objectApiName: 'Account_Competition_Relationship__c',
				actionName: 'new'
			},
			state: {
				defaultFieldValues: defaultValues,
				nooverride: 1,
				navigationLocation: 'RELATED_LIST',
				backgroundContext: '/lightning/r/Account/' + this.recordId + '/view'
			}
		});
		this.createdRecord = true;
	}

	handleIsLoading(isLoading) {
		this.isLoading = isLoading;
	}

	get accountname() {
		return this.account.data.fields.Name.value;
	}

	async handleSave(event) {
		const records = event.detail.draftValues.slice().map((draftValue) => {			
			const fields = Object.assign({}, draftValue);
			return {
				fields
			};
		});

		this.draftValues = [];

		try {
			const recordUpdatePromises = records.map((record) =>
				updateRecord(record)
			);
			await Promise.all(recordUpdatePromises);			
			await getRelatedCompetitions_helper1(this);
			setTimeout(() => {
				this.showToast('Success', 'Related Competitions updated', 'Success', 'dismissable');
			}, 100);
		} catch (error) {			
			this.showToast('Error updating or reloading Competitions', error.body.message, 'Error', 'dismissable');
			await getRelatedCompetitions_helper1(this);
		}
	}
	
	showToast(title, message, variant, mode) {
		this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode }));
	}

	showNotification() {
		const evt = new ShowToastEvent({
		  title: this._title,
		  message: this.message,
		  variant: this.variant,
		});
		this.dispatchEvent(evt);
	}

	disconnectedCallback() {
		unsubscribe(this.subscription, () => {
			console.log('Unsubscribed Channel');
		});
	}

	handleRowAction(event) {
		this.actionName = event.detail.action.name;
		const row = event.detail.row;
		switch (this.actionName) {
			case 'delete':
				this.handleDeleteRow(row.Id);
				break;
			case 'edit':
				this.handleEditRow(row.Id);
			break;
		}
	}
	
	async handleEditRow(recordIdToEdit) {
	 
		await this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {
				recordId: recordIdToEdit,
				objectApiName: 'Account_Competition_Relationship__c',
				actionName: 'edit'
			},
			state: {
				nooverride: 1,
				navigationLocation: 'RELATED_LIST',
				backgroundContext: '/lightning/r/Account/' + this.recordId + '/view'
			}
		});
		this.createdRecord = true;
	}

	async handleDeleteRow(recordIdToDelete) {
		const result = await LightningConfirm.open({
			message: 'Are you sure you want to remove this competition from this account?',
			label: 'Remove Competition Relationship',
		});
		if (result) {
			removeRelation({ recordIdToDelete: recordIdToDelete })
				.then(() => {
					this.handleLoad();
					this.showToast('Success', 'Related Competitions deleted', 'Success', 'dismissable');
				})
				.catch(error => {
					this.error = error;
					this.showToast('Error', 'Failed to delete related competitions', 'error', 'dismissable');

				});
			}
	}

	handleSortData(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		this.sortData(event.detail.fieldName, event.detail.sortDirection);
	}

	sortData(fieldname, direction) {
		let parseData = JSON.parse(JSON.stringify(this.competitions));
		let keyValue = (a) => {
			return a[fieldname];
		};
		let isReverse = direction === 'asc' ? 1 : -1;
		parseData.sort((x, y) => {
			x = keyValue(x) ? keyValue(x) : '';
			y = keyValue(y) ? keyValue(y) : '';

			return isReverse * ((x > y) - (y > x));
		});
		this.competitions = parseData;
	}
}