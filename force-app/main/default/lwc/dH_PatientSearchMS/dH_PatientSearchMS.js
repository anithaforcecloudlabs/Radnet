/*
* ***************************************************************************************************************************
* LWC Component Name - dH_PatientSearch.js
* Created Date - 20-May-2024
* Function - JS class of Search Additional Patients in RIS screen.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       --------------------------------------------
* CC-430                     20-May-2024         Added onInputChange and handleSearch methods.
* CC-543                     11-July-2024        Updated the Birth Date as per standards.
* CC-622                     25-July-2024        Updated onChange and handelSearch method.
* CC-507                     26-July-2024        Updated handleSearch method and changes related to apiErrorMessage and apiError
* CC-1291                    04-Sept-2024        Added flag variable
* CC-1456                    04-Feb-2025         Added validations for First Name and Last Name
* CC-1457                    04-Feb-2025         Added validations for Date of Birth
* *****************************************************************************************************************************
*/
import {track ,api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import reduceModalWidth from '@salesforce/resourceUrl/reduceModalWidth';
import { loadStyle } from 'lightning/platformResourceLoader';
import invokeRisPatientSearchApi from '@salesforce/apex/DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi';
import getDynamicTableColumnsRecords from '@salesforce/apex/DH_VerifyCallerController.getDynamicTableColumnsRecordsForSearch';
import SearchPatientInRis from '@salesforce/label/c.DH_PatientSearchButtonName';
import emptyFieldError from '@salesforce/label/c.DH_PatientSearchErrorEmptyFields';
import firstNameError from '@salesforce/label/c.DH_RisFirstNameValidation';
import lastNameError from '@salesforce/label/c.DH_RisLastNameValidation';
import dobError from '@salesforce/label/c.DH_RisDobValidation';
import dobFormatError from '@salesforce/label/c.DH_RisDobValidFormat';
import createLogRecord from '@salesforce/apex/DH_DexLoggingUtility.createLogRecord';
import {getRecord} from 'lightning/uiRecordApi';
import QUEUE_NAME_FIELD from '@salesforce/schema/MessagingSession.Queue_Name__c';
import CALL_TYPE_FIELD from '@salesforce/schema/MessagingSession.Origin';
 
export default class SearchPatientManuallyInRisModal extends LightningModal {
    @track apiError = false;
    apiErrorMessage;
    @api recordId;
    firstName;
    lastName;
    email;
    phone;
    birthDate;
    actualDay;
    actualMonth;
    actualYear;
    showError=false;
    disableRisButton=true;
    mrnNumber;
    accessionNumber;
    @api description;
    @api systemId;
    contactData;
    @track columnList = [];
    emptyFieldsError=emptyFieldError;
    searchPatientInRisModelName = SearchPatientInRis;
    firstNameErrorValidation = firstNameError;
    lastNameErrorValidation = lastNameError;
    dobErrorValidation = dobError;
    dobFormatErrorValidation = dobFormatError;
    @track loggerParam = null;
    @track queueName;
    @track callType;
    @track disableFlipButton = true;
    fields = [QUEUE_NAME_FIELD,CALL_TYPE_FIELD];
 
    @wire(getRecord, {recordId: '$description', fields: '$fields'})
    wiredVoiceCallRecord({data, error}){
        if(data){  
            this.queueName = data.fields.Queue_Name__c.value != null ? data.fields.Queue_Name__c.value : '';
            this.callType = data.fields.Origin.value != null ? data.fields.Origin.value : '';
        } else if(error){
            this.loggerParam =
                {
                    ErrorMessage:error.message,
                    ClassName:'dH_PatientSearch-wireGetRecord',
                    RelatedTo:this.recordId,
                };
                createLogRecord({log : this.loggerParam})
        }
    }
 
    renderedCallback() {
        Promise.all([
            loadStyle( this, reduceModalWidth )
            ]).then(() => {
                console.log( 'Files loaded' );
            })
            .catch(error => {
                console.log( error.body.message );
        });
    }
    connectedCallback(){
        getDynamicTableColumnsRecords().then((result)=>{
            this.columnList = result;
            this.columnList.sort((a,b)=>a.DH_AttributeSequenceNumber__c - b.DH_AttributeSequenceNumber__c);
        }).catch((error) => {
            console.log('error in the getDynamicTableColumnsRecords: '+error);
        })
    }
    
    // Method to check valid date on input date change
    checkDateChange(event) {
        const inputDate = event.target.value.trim(); 
 
        const separators = ['-', '/'];
 
        const isValid = this.validateDate(inputDate, separators);
 
        if (isValid) {
            this.birthDate = inputDate;
            console.log('Valid date format:', inputDate);
            event.target.setCustomValidity(''); // Clear any previous error
            event.target.reportValidity();
            return true;
            
        } else {
            console.error('Invalid date format:', inputDate);
            event.target.setCustomValidity(this.dobFormatErrorValidation);
            event.target.reportValidity();
            return false;
        }
 
    }

    // Method to validate actual date
    validateDate(input, separators) {
        // Separator check
        let separatorUsed = '';
        for (const sep of separators) {
            if (input.includes(sep)) {
                separatorUsed = sep;
                break;
            }
        }
 
        // Split the input into parts based on separator or assume no separator
        let parts;
        if (separatorUsed) {
            parts = input.split(separatorUsed);
        } else {
            if (input.length === 6 || input.length === 8) {
                parts = [input.slice(0, 2), input.slice(2, 4), input.slice(4)];
            } else {
                return false; 
            }
        }
 
        if (parts.length !== 3) return false;
 
        const [month, day, year] = parts;
 
        // Validate month
        if (!this.isNumberInRange(month, 1, 12)) return false;
        this.actualMonth = month;
 
        // Validate day
        if (!this.isNumberInRange(day, 1, 31)) return false;
        if (!this.validateDateAgainstMonth(day, month)) return false;
        this.actualDay = day;
 
        // Validate year
        if (year.length !== 2 && year.length !== 4) return false;
        const currentYear = new Date().getFullYear();
        if (!this.isNumberInRange(year, -1, currentYear+1)) return false;
        if (year.length===2){
            const currentYearStr = String(currentYear);
            const truncYear = currentYearStr.slice(2);
            if (year<=truncYear){
                this.actualYear = '20'+year;
            }
            else{
                this.actualYear = '19'+year;
            }
        }
        else{
            this.actualYear = year;
        }
 
        return true; 
    }
    
    // Helper method for num range
    isNumberInRange(value, min, max) {
        const num = parseInt(value, 10);
        return !isNaN(num) && num >= min && num <= max;
    }

    // Method to validate the date against the actual month
    validateDateAgainstMonth(date, month) {
        const day = parseInt(date, 10);
        const monthIndex = parseInt(month, 10) - 1; // JavaScript months are zero-based (0 = January)

        const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
        // Leap year check for February
        if (monthIndex === 1) { 
            const currentYear = new Date().getFullYear(); 
            const isLeapYear = (currentYear % 4 === 0 && currentYear % 100 !== 0) || (currentYear % 400 === 0);
            if (isLeapYear) {
                daysInMonth[1] = 29;
            }
        }

        return day >= 1 && day <= daysInMonth[monthIndex];
    }
    
    // Helper method for null check 
    validateFields(){
        if(this.email || this.phone || this.mrnNumber || this.accessionNumber || ((this.firstName && this.lastName) || (this.firstName && this.birthDate) || (this.lastName && this.birthDate))){
            return true;
        }else{
            return false;
        }
    }
    
 
    onInputChange(ev){
        if(ev.target.name==="firstName"){
            this.firstName=ev.target.value;
            this.showError=false;
            this.disableFlipButton = false;
        }
        if(ev.target.name==="lastName"){
            this.lastName=ev.target.value;
            this.showError=false;
            this.disableFlipButton = false;
        }
        if(ev.target.name==="phone"){
            this.phone=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="email"){
            this.email=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="birthdate"){
            if(this.checkDateChange(ev)===false){
                this.showError=true;
            }else{
                this.birthDate=this.actualYear + '-' + this.actualMonth + '-' + this.actualDay;
                this.showError=false;
            }
        }
        if(ev.target.name==="mrnNumber"){
            this.mrnNumber=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="accessionNumber"){
            this.accessionNumber=ev.target.value;
            this.showError=false;
        }
        
        if(!this.validateFields() && this.firstName && !this.lastName && !this.birthDate){
            this.emptyFieldsError = this.firstNameErrorValidation
        }
        else if(!this.validateFields() && this.lastName && !this.firstName && !this.birthDate){
            this.emptyFieldsError = this.lastNameErrorValidation
        }else if(!this.validateFields() && this.birthDate && !this.lastName && !this.firstName){
            if(this.showError===true){
                this.emptyFieldsError = emptyFieldError;
            }else{
                this.emptyFieldsError = this.dobErrorValidation;
            }
        }else{
            this.emptyFieldsError = emptyFieldError;
        }

        this.disableRisButton = this.showError || this.apiError;
        if ((this.firstName === null || this.firstName === undefined || this.firstName.trim() === '') && (this.lastName === null || this.lastName === undefined || this.lastName.trim() === '')) {
            this.disableFlipButton = true;
        }
    }

    handleSearch() {
        if(this.validateFields()){
            const patientSearchParameters =
            {
                recordId: this.description,
                firstName: this.firstName,
                lastName: this.lastName,
                phoneNumber: this.phone,
                email: this.email,
                dateOfBirth: this.birthDate,
                patientMRN: this.mrnNumber,
                accessionNumber: this.accessionNumber,
                systemId: this.systemId,
                isAdvanceSearch: true,
                queueName : this.queueName,
                callType : this.callType
            };
            console.log('patientSearchParameters',JSON.stringify(patientSearchParameters));
            invokeRisPatientSearchApi({urlParametersWrapper : patientSearchParameters})
            .then((result) => {
                const len =Object.keys(result).length;
                if(len == 1 && Object.keys(result)[0] == -1){
                    this.apiError = true;
                    this.apiErrorMessage = result[-1][0].errorMessage;
                    this.disableRisButton = this.showError || this.apiError;
                }else if(len == 1 && Object.keys(result)[0] == -2){
                    this.apiError = true;
                    this.apiErrorMessage = result[-1][0].errorMessage;
                    this.disableRisButton = this.showError || this.apiError;
                }else if(result && len >= 0 && Object.keys(result)[0] != -1 && Object.keys(result)[0] != -2){
                    this.contactData = result;
                    this.close({dataEntered: true, data: this.contactData, flag: true});
                }                
            })
            .catch((error) => {
                console.log(error);
                this.close({dataEntered: true, data: 'error in the invokeRisPatientSearchApi: '+this.contactData, flag: false});
                this.loggerParam =
                {
                    ErrorMessage:error.message,
                    ClassName:'dh_PatientSearch-invokeRisPatientSearchApi',
                    RelatedTo:this.recordId,
                };
                createLogRecord({log : this.loggerParam});
            })
        }
        else{
            this.showError=true;
            
        }
    }
    handleFlipName(){
        const temp = this.firstName;
        this.firstName = this.lastName;
        this.lastName = temp;
    }
}