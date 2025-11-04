import { LightningElement, api, wire, track } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {getRelatedContacts_helper1, getObjectivesValues_helper1, createTask_helper1} from './lwcMeals_helper1';
import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

export default class LwcMeals extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    subjectType = 'Meals';
    callTypeValue;
    @track objectiveOptions;
    @track selectedObjectives = [];
    taskDateValue;
    taskCommentValue;
    @track selectedContacts= [];
    @track contactOptions;
    @track contactsData = [];
    showComp;
    otherContact;
    @track spentCount;
    @track budjetSpentValue;
    @track costError;
    @track taskDateError;
    @track callTypeError;
    @track taskCommentError;
    @track contactError;
    @track showAmounts;
    @track isLoading;
    @track showErrorSpent = false;
    @track messageValue;
    @track costLabel = 'Cost';
    @track userIsSalesRep;

    userId = USER_ID;

    @wire(getRecord, { recordId: '$userId', fields: [PROFILE_NAME_FIELD] })
    userDetails({ error, data }) {
        if (data) {
            if (data.fields.Profile.value.fields.Name.value === 'Sales Rep') {
                this.userIsSalesRep = true;
                this.callTypeValue = 'Sales Call';
            } else {
                this.userIsSalesRep = false;
            }
        }
    }

    connectedCallback() {		
		this.loadAccountData();
	}
    @api loadAccountData(){
        this.handleLoadContacts();
        this.handleActivityObjectiveOptions();
    }
    async handleLoadContacts() {
		await getRelatedContacts_helper1(this); 
	}
    async handleActivityObjectiveOptions() {
		await getObjectivesValues_helper1(this); 
	}
    get callTypeOptions() {
        return [
            { label: 'Sales Call', value: 'Sales Call' },
            { label: 'Service Call', value: 'Service Call' },
        ];
    }

    handleTypeChange(event) {
        this.callTypeValue = event.detail.value;
        this.callTypeError = '';
        console.log("Todo:  this.callTypeValue " +   this.callTypeValue);
    }

    handleObjectiveChecked(event){
        this.value = event.target.value;        
        console.log("Todo: " + event.target.value);
               
            if (event.target.checked) {
                this.selectedObjectives.push(event.target.value);
            } else {
				let previousIndex = this.selectedObjectives.indexOf(event.target.value);                
				if (previousIndex > -1) { // only splice array when item is found
					this.selectedObjectives.splice(previousIndex, 1); // 2nd parameter means remove one item only
				}
                //this.selectedObjectives = this.selectedObjectives.filter(value => value !== event.target.value);
            }
            console.log("Todo:this.selectedObjectives " + this.selectedObjectives);
        
    }
    handleDate(event) {
        //event.preventDefault();
        this.taskDateValue =  event.target.value;
        this.taskDateError = '';
        console.log("Todo:  this.taskDateValue " +   this.taskDateValue);
        
        this.costLabel = (this.isToday(new Date( this.taskDateValue ))) ? 'Cost' : 'Estimated cost';
    }

    isToday = (someDate) => {
        console.log('isToday someDate ', someDate);
        const today = new Date();
        console.log('isToday today ', today);
        return someDate.getDate() == today.getDate() &&
        someDate.getMonth() == today.getMonth() &&
        someDate.getFullYear() == today.getFullYear()
    }

    
    handleComment(event) {
    //event.preventDefault();
       this.taskCommentValue =  event.target.value;
       this.taskCommentError = '';
       console.log("Todo:  this.taskCommentValue " +   this.taskCommentValue);
    }

    handleCostChange(event){       
        this.budjetSpentValue = event.target.value;
        this.costError = "";
        console.log("Todo:  this.handleCostChange " + event.target.value);
        
        if (this.budjetSpentValue && this.selectedContacts.length) {            
            this.showAmounts = true;
            this.spentCount = (this.budjetSpentValue / this.selectedContacts.length).toFixed(2);
            this.validateBudjetSpent();
        } else {
            this.showAmounts = false;
        }
        
    } 

    handleOtherContact(event){
        this.otherContact = event.target.value;
    }
    

    handleContactChecked(event) {       
        this.contactError = '';
        console.log("Todo:  this.handleCostChange " + event.target.checked);
        if (event.target.checked) {
            this.selectedContacts.push(event.target.value);                
            if (this.budjetSpentValue && this.selectedContacts.length) {               
                this.showAmounts = true;
                this.spentCount = (this.budjetSpentValue / this.selectedContacts.length).toFixed(2); 
                this.validateBudjetSpent();                        
            } else {
                this.showAmounts = false;               
            }
           
        } else {
            this.selectedContacts = this.selectedContacts.filter(value => value !== event.target.value);           
            if (this.budjetSpentValue && this.selectedContacts.length) {                
                this.showAmounts = true;
                this.spentCount = (this.budjetSpentValue / this.selectedContacts.length).toFixed(2);
                this.validateBudjetSpent();
            } else {
                this.showAmounts = false;
                for (let index = 0; index<this.contactOptions.length; index++ ){ 
                    this.contactOptions.find(x => x.contactId == this.contactOptions[index]).budgetErrorShow = false;
                    this.contactOptions.find(x => x.contactId == this.contactOptions[index]).budgetErrorSum = '';
                }
            }
        }
    }

    validateBudjetSpent() {
        console.log("validateBudjetSpent " +  this.spentCount);
        let spentCount = (this.budjetSpentValue / this.selectedContacts.length);
        for (let index = 0; index<this.selectedContacts.length; index++ ){
            let getcurrentBudget = this.contactOptions.find(x => x.contactId == this.selectedContacts[index]).budgetSpent;
            let budgetRemaining = this.contactOptions.find(x => x.contactId == this.selectedContacts[index]).budgetLimit;            
            if (budgetRemaining <= Number(getcurrentBudget) + Number(spentCount)) {
                this.showErrorSpent = true;                
                this.contactOptions.find(x => x.contactId == this.selectedContacts[index]).budgetErrorShow = true;
                this.contactOptions.find(x => x.contactId == this.selectedContacts[index]).budgetErrorSum = 'The cost ' + this.spentCount + ' exceeds budget';
            } else {
                this.showErrorSpent = false;
                this.contactOptions.find(x => x.contactId == this.selectedContacts[index]).budgetErrorShow = false;
                this.contactOptions.find(x => x.contactId == this.selectedContacts[index]).budgetErrorSum = '';
            }
        }
        //console.log("Todo:  this. ", JSON.stringify(this.contactOptions));
    }

    validationForm(){
        let validForm = false;
        if (!this.budjetSpentValue) {
            this.costError = 'Cost is required.';
        } else {
            this.costError = '';
        }

        if (!this.callTypeValue) {
            this.callTypeError = 'Call type is required.';
        } else {
            this.callTypeError = '';
        }

        if (!this.taskDateValue) {
            this.taskDateError = 'Date is required.';
        } else {
            this.taskDateError = '';
        }

        if (!this.selectedContacts.length) {
            this.contactError = 'Selected contact is required.';
        } else {
            this.contactError = '';
        }

        if (!this.taskCommentValue) {
            this.taskCommentError = 'Comment is required.';
        } else {
            this.taskCommentError = '';
        }

        if (!this.taskCommentError && !this.contactError && !this.callTypeError 
            && !this.costError && !this.taskDateError) {
            validForm =  true;
        }
        return validForm;

    }
    async handleCreateTask(){ 
        if (this.validationForm() ) {
        let moveToNextStep = true;
        if (moveToNextStep) {
            moveToNextStep = await createTask_helper1(this);           
            await getRelatedContacts_helper1(this);
        }
        }
    }

    navigateToRecordAcionPage(recordValue) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordValue,
				objectApiName: 'Account',
				actionName: 'view'
			},
		})
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

    async handleClear(){
        //event.preventDefault();
        this.callTypeValue = '';
        this.selectedObjectives = [];
        this.taskDateValue = ''; 
        this.taskCommentValue = '';
        this.budjetSpentValue = ''; 
        this.selectedContacts= [];
        this.otherContact ='';
        this.spentCount = '';
        this.amountForEach='';
        this.costError ='';
        this.taskDateError='';
        this.callTypeError='';
        this.taskCommentError='';
        this.contactError='';
        this.showAmounts =false;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.type === 'checkbox' || element.type === 'checkbox-button'){
              element.checked = false;
            }
            if(element.type === 'number'){
                element.value = null;
              }
        })
       // this.template.querySelector('lightning-input[data-name="cost"]').value ='';    
       await getRelatedContacts_helper1(this); 
       await getObjectivesValues_helper1(this);
        console.log("Todo:this.contactOptions " + JSON.stringify(this.contactOptions));
    }

    handleIsLoading(isLoading) {
		this.isLoading = isLoading;
    }
}