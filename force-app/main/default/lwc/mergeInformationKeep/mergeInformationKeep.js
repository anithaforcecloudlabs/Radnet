import { LightningElement, api, track, wire} from 'lwc';
import mergeAcrs from '@salesforce/apex/RelatedAccountsAPX.mergeAcrs';
import getDuplicateRecordsAfterMerged from '@salesforce/apex/RelatedAccountsAPX.getDuplicateRecordsAfterMerged';
import getAccountsForUpdate from '@salesforce/apex/RelatedAccountsAPX.getAccountsForUpdate';
import {NavigationMixin} from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import Id from '@salesforce/user/Id'; 
import Name from '@salesforce/schema/User.Name';
import PROFILE_NAME_FIELD  from '@salesforce/schema/User.Profile.Name';
import RIS_DATA_MANAGER from '@salesforce/schema/User.RIS_Data_Manager__c'; 
import { getRecord } from "lightning/uiRecordApi";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class MergeInformationKeep extends NavigationMixin(LightningElement) {
	isShowMergeModal = false;
	@api selectedAccounts = [];
	@api recordId;
	@api accountObjData;
	error;
	fldsItemValues = [];
	draftValues = [];
	@api mode;
    @api variant;    
    @api message;
	@api isLoading = false;
	@api arrFaxExist;
	@api arrPhoneExist;
	@api arrName = [];
	@api arrAddress = [];
	@api arrOwner = [];
	@api arrPhone = [];
	@track arrFax = [];
	@track arrAccountIds = [];
	@api showErrorMessage = false;
	@api showSaveButton = false;
	@api countMergeRecords = false;
	@api messageRecordTypesRecords = false;
	@api messageProfileUsers = false;
	@api showMessage = false;
	accessProfileToMerge =['System Administrator', 'Sales Rep', 'RIS Data Manager', 'RIS Profile', 'Manager Profile', 'VP&Director Profile'];
	disabled = false;
	activeSections = 'A';
	nameValue = '';
	addressValue = '';
	ownerValue = '';
	phoneValue = '';
	faxValue = '';
	textCommentValue = '';
	userManager;
	@api a_Record_URL;


	@wire(getRecord, { recordId: Id, fields: [Name, RIS_DATA_MANAGER, PROFILE_NAME_FIELD ] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
		} else if (data) {
			console.log('data ', data);
            if (data.fields.RIS_Data_Manager__c.value != null) {
                this.userManager = data.fields.RIS_Data_Manager__c.value;
			}
			let profileName = data.fields.Profile.value.fields.Name.value; 
			if (this.accessProfileToMerge.includes(profileName)) {
                this.messageProfileUsers = false;
			} else {
				this.messageProfileUsers = true;
			}
			console.log('this.userManager ', this.userManager);
			console.log('this.messageProfileUsers ', this.messageProfileUsers);
        }
    }


	connectedCallback() {
	if (!this.messageProfileUsers) {
		this.isLoading = true;
		this.a_Record_URL = window.location.origin;
		console.log('this.da_Record_URL ', JSON.stringify(this.a_Record_URL));
		getAccountsForUpdate({
			accounIds: this.selectedAccounts
		}).then((result) => {
			this.isLoading = false;
			let resultObj = JSON.parse(JSON.stringify(result));	
			console.log('resultObj', resultObj);
			if (this.messageProfileUsers){
				this.showErrorMessage = true;
				this.countMergeRecords = false;
				this.isShowMergeModal = false;
			} else {
			if (resultObj.length == 2 || resultObj.length == 3) {
				this.validateRecordType(resultObj);				
				if (this.messageRecordTypesRecords) {					
					this.showErrorMessage = true;
					this.countMergeRecords = false;
					this.isShowMergeModal = false;
				} else {
					resultObj.forEach(item => {
						item['accountMergeName'] = item['Name'];					
            			item['id'] = item['Id'];
						item['ownerName'] = item.Owner.Name;
						item['id'] = item['Id'];
						if (item.ShippingAddress) {
							let postal = (item.ShippingAddress.postalCode === 'undefined' || item.ShippingAddress.postalCode === 'null' || !item.ShippingAddress.postalCode) ? '' : item.ShippingAddress.postalCode;
							let street = (item.ShippingAddress.street === 'null' || !item.ShippingAddress.street) ? '' : item.ShippingAddress.street;
							let city = (item.ShippingAddress.city === 'null' || !item.ShippingAddress.city) ? '' : item.ShippingAddress.city;
							let state = (item.ShippingAddress.state === 'null' || !item.ShippingAddress.state) ? '' : item.ShippingAddress.state;
							let country = (item.ShippingAddress.country === 'null' || !item.ShippingAddress.country) ? '' : item.ShippingAddress.country;
					
							item['address'] = street + ', ' + city + ', ' + state + ', ' + postal + ', ' + country;
						}
						item['owner'] = item.Owner.Name;
						item['phoneNumber'] = item['Phone'];
						item['faxNumber'] = item['Fax'];
					});					
			
					resultObj.forEach(x => {
						this.arrName.push({ label: x.accountMergeName, value: x.accountMergeName });
						this.arrAddress.push({ label: x.address, value: x.address });
						this.arrOwner.push({ label: x.owner, value: x.owner });
						this.arrAccountIds.push(x.Id);							
						if (String(x.phoneNumber) === 'undefined') {
							this.arrPhoneExist = false;
							this.arrPhone.push({ label: 'unknown', value: 'unknown' });
						} else {
							this.arrPhoneExist = true;
							this.arrPhone.push({ label: String(x.phoneNumber), value: String(x.phoneNumber) });
						}
			
						if (String(x.faxNumber) === 'undefined') {
							this.arrFaxExist = false;
							this.arrFax.push({ label: 'unknown', value: 'unknown' });
						} else {
							this.arrFaxExist = true;
							this.arrFax.push({ label: String(x.faxNumber), value: String(x.faxNumber) });
						}
					})
					
					if (this.userManager) {
						console.log('if this.userManager ', this.userManager);
						this.isShowMergeModal = false;
						this.showErrorMessage = false;
						this.isLoading = true;					
						this.closeAction();
						mergeAcrs({
							accountIds: this.arrAccountIds,
							noteMerge: ''
						}).then(result => {
							this.isLoading = false;
							console.log('mergeAcrs result ', result);
							getDuplicateRecordsAfterMerged({
								recordIds: this.arrAccountIds
							}).then(duplicateResult => {
								console.log('getDuplicateRecordId result ', duplicateResult);
								this.resultDuplicateRecordId = duplicateResult;
								//this.navigateToDuplicateRecordPage(result);
								console.log('resultDuplicateRecordId result ', this.resultDuplicateRecordId );
							}).catch(error => {			
								console.info('error getDuplicateRecordId', error);
							});							
							
							this.textCommentValue = '';
							this.navigateToRecord(this.arrAccountIds);
						}).catch(error => {
							this.isLoading = false;
							this.navigateToRecord();						
							console.log('catch error result ', JSON.stringify(error));
						});
	
					} else { 
						this.countMergeRecords = false;
						this.isShowMergeModal = true;					
						this.showErrorMessage = false;
					}
					
			}
			} else {
				this.showErrorMessage = true;
				this.countMergeRecords = true;
				this.isShowMergeModal = false;
			}
		}
		})
	} else {
		this.countMergeRecords = false;
		this.isShowMergeModal = true;
		this.showErrorMessage = false;
	}
	}

	validateRecordType(resultObj) { 
		resultObj.find(item => {			
			if (item.RecordType.DeveloperName !== 'Practice_Location'){ 
				this.messageRecordTypesRecords = true;				
			}
		})
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
	
	async handleMergeSubmit(event) {
		this.isLoading = true;
		console.log('handleMergeSubmit ');
		this.validRequired();
		let noteMerge = 'Name: ' + this.nameValue + '\n' + 'Address: ' + this.addressValue + '\n'+'Owner: ' + this.ownerValue;
		noteMerge = (this.phoneValue) ? noteMerge + '\n' + 'Phone: ' + this.phoneValue : noteMerge;
		noteMerge = (this.faxValue) ? noteMerge +'\n' +'Fax: ' +this.faxValue : noteMerge;
		noteMerge = (this.textCommentValue) ? noteMerge + '\n' + 'Comment: ' + this.textCommentValue : noteMerge;
		this.isShowMergeModal = false;
		try {
			this.isLoading = false;		
			let checkDuplicates = await getDuplicateRecordsAfterMerged({
				recordIds: this.arrAccountIds
			})			
			let parseResult = JSON.parse(JSON.stringify(checkDuplicates));
			console.log('getDuplicateRecordId parseResult ', parseResult);
			this.showMessage = true;
			if (parseResult && parseResult.length > 0) {
				console.log('getDuplicateRecordId parseResult.length ', parseResult.length);
				
				this.messageResults ='There is already a pending RIS request for merge that is open';		
			} else {
				this.messageResults ='RIS request for merge was opened';	
			}
			let updateAccount = await mergeAcrs({
				accountIds: this.arrAccountIds,
				noteMerge: noteMerge
			})
			if (updateAccount) {
				this.closeModal();
			}
			
			//await Promise.all([updateAccount, checkDuplicates]);
		} catch (e) {
			// deal with any errors
		}
	}

	validRequired() {
		if (this.nameValue  && this.addressValue && this.ownerValue) { 
			this.showSaveButton = true;
		};
	}

	closeModal() {
		let url = window.location.href;
        window.history.back();
	}

	navigateToRecord(accounts) {
		console.log('this.a_Record_URL', this.a_Record_URL);
		let url = this.a_Record_URL +'Account/'+ accounts[0]+'/view';
		console.log('this.a_Record_URL', url);
		window.location.href =  '/lightning/r/Account/'+ accounts[0] +'/view'; 
        //window.history.back();
	}
	
	closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
	}

	handleNavigation(event) {
		console.log('event ', event);
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId:  this.arrAccountIds[0],
				objectApiName: 'Account',
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
	
}