import { LightningElement,api,wire,track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_FIELD from '@salesforce/schema/RIS_Requests__c.Account_Name__c';
import getContacts from '@salesforce/apex/LwcRelatedPhysiciansAPX.getContacts';
import getContactsCount from '@salesforce/apex/LwcRelatedPhysiciansAPX.getContactsCount';

const columns = [{
	label: 'Contact Name',
	fieldName: 'contactLink',
	type: 'url',
	typeAttributes: {
		label: {
			fieldName: 'contactName'
		},
		target: '_blank'
	},
	    sortable: 'true',
	    initialWidth: 140,
    },{
        label:'Physiсian NPI',
        fieldName: 'npi',
        type: 'text',
        editable: false
	}, {
        label: 'Contact Email',
        fieldName: 'Contact_Email__c',
        type: 'email',
        editable: false
    },{
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
        editable: true,
    }, {
        label: 'PAP',
        fieldName: 'pap',
        type: 'boolean',
        editable: false,
        initialWidth: 80,
    },{
        label: 'FAX',
        fieldName: 'Fax_Reports__c',
        type: 'boolean',
        editable: true
    },
];
export default class LwcRelatedPhysicians extends LightningElement {
    @api recordId;
    columns = columns;
    activeSections = 'A';
    @track contacts =[];
    @track contactLabel;
    @track showComp = false;
    @track showWarningMessage;
    @track error;
    a_Record_URL;
    risRequest;
    @track sortBy;
	@track sortDirection;
    loadMoreStatus;
    @api totalNumberOfRows;    
    showBar=true;
    contactsCount = 0;

    connectedCallback() {
        this.a_Record_URL = window.location.origin;
        this.getRelatedContacts();
    }

    getRelatedContacts() {
        const { recordId } = this;

        getContactsCount({ recordId }).then(result => {
            if (result > 50) {
                this.contactsCount = result;
                this.showWarningMessage = true;
            }
        });

        getContacts({ recordId }).then(data => {  
            //console.log('getContacts',  JSON.stringify(data));
            //console.log('getContacts',  JSON.parse(JSON.stringify(data)));
            if(data) {
            this.contacts = data;
            console.log('this.contacts',  this.contacts);
            let resp = JSON.parse(JSON.stringify(data));
            console.log('resp',  resp);
            if (resp.length>0){
            resp.forEach(item => {
                //console.log('reitemsp', item.Contact.Name);
                item['contactName'] = item.Contact.Name;
                item['npi'] = item.Contact.Physician_NPI__c;
                item['pap'] = item.Contact.PAP__c;
                item['contactLink'] = this.a_Record_URL + '/lightning/r/Contact/' + item['ContactId'] + '/view';
            });
            this.showComp = true;
            }
            //console.log('end',  resp);
            this.contacts = resp;
            //console.log('end',  this.contacts);
            this.contactLabel = 'Physicians (' + resp.length + ')';
        }
        }).catch(error => {
            this.error = error;
            console.log('error',  JSON.stringify(error));
        });
    }

    loadMoreData(event) {
        console.log('end',  event);
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
}