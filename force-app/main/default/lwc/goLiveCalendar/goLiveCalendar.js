/*
* ***************************************************************************************************************************
* LWC Component Name - goLiveCalendar
* 
* Created Date : 13/06/2024
* 
* @description : This component is used to create event and search events on the basis of title, project category, region and goLive date.
*
* @Jira Id     : CC-103, CC-964
*
* *****************************************************************************************************************************
*/
import { LightningElement, track, wire, api } from 'lwc';
import getRegion from '@salesforce/apex/GoLiveCalendarController.getRegion';
import getgoLiveDate from '@salesforce/apex/GoLiveCalendarController.getgoLiveDate';
import getEventRecords from '@salesforce/apex/GoLiveCalendarController.getEventRecords';
import getRelatedFilesByRecordId from '@salesforce/apex/GoLiveCalendarController.getRelatedFilesByRecordId';
import createEvent from '@salesforce/apex/GoLiveCalendarController.createEvent';
import hasPermissionSet from '@salesforce/apex/GoLiveCalendarController.hasPermissionSet';
import getUserType from '@salesforce/apex/DH_KMUtility.getUserType';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import CC_FILE_PREVIEW_URL from '@salesforce/label/c.DH_CCFilePreview';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class GoLiveCalendar extends NavigationMixin(LightningElement) {

    
    ampm = false;
    timeZone = TIME_ZONE;
    //to show button
    @api showButton = false;
    //map to store name of the images related to records
    @track mapOfRecordIdandRelatedImaged;

    //sort data
    @track sortDirection = 'asc'; // Default sorting direction
    @track sortedBy; // Track the column currrently being sorted
    //is form opened by user?
    @track isFormOpen;
    //to store form data 
    @track title;
    @track goLiveDate;
    @track category;
    @track region;
    @track newRecordId;
    //rgeion optionin form;

    //to show table only when we get the search data
    @track isDataAvailable = false;
    @track isTitleAsc = true;
    @track isDateAsc = true;
    @track error;
    @track searchData = [];
    @track originalData = [];
    refreshResults = [];
    @track selectedValues = { Title: '', ProjectCategory: '', region: '', goLiveDate: '' };
    isConnected = true;
    showResult = false;
    selectedTitleValue;
    selectedProjectCategoryValue;
    @track regionOptions = [];
    selectedRegionValue;
    @track goLiveDateOptions = [];
    selectedGoLiveDateValue;
    isGuestUser = false;

    //set regionOptions
    get regionNewOptions() {
        return [
            { label: 'Any', value: 'Any' },
            { label: 'AZ', value: 'AZ' },
            { label: 'CA', value: 'CA' },
            { label: 'CA and AZ', value: 'CA and AZ' },
            { label: 'SoCal', value: 'SoCal' },
            { label: 'Socal and AZ', value: 'Socal and AZ' },
        ];
    }

    //Set accepted file formats
    get acceptedFormat() {
        return ['.png', '.jpg', '.jpeg', '.pdf', '.xlsx'];
    }

    // getting the user type of the user whether it is a guest user or not
    @wire(getUserType)
    userType(result) {
        if (result.data) {
            this.isGuestUser = result.data;
        }
        else if (result.error) {
            console.log('error found -> ' + JSON.stringify(result.error));
        }
    }

    //Renderedcalback
    renderedCallback() {
        refreshApex(this.refreshResults);
    }
    //Check Knowledge_Search_Super_User Permission Set
    @wire(hasPermissionSet, { permissionSetName: 'Knowledge_Search_Super_User' })
    wiredPermSet({ data, error }) {
        if (data) {
            this.showButton = data;
        }
        else if (error) {
            console.error('Error loading user permission set', error);
        }
    }

    @wire(getEventRecords, { title: null, category: null, region: null, goLiveD: null })
    wiredAllRecords(result) {
        this.refreshResults = result;
        let { data, error } = result;
        if (data) {
            this.searchData = data;

            if (this.searchData.length > 0) {
                this.isDataAvailable = true;
            }
            else {
                this.isDataAvailable = false;
            }
            this.error = undefined;
        }
        else if (error) {
            this.searchData = undefined;
        }
    }

    // this method is used to get all the region from Go_Live_Calendar__c
    @wire(getRegion)
    wiredregion({ error, data }) {
        if (data) {
            this.regionOptions = data.map((region) => {
                return { 'label': region, 'value': region };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.regionOptions = undefined;
        }
    }

    //this method returns the golive date picklist options.
    @wire(getgoLiveDate)
    wiredgetgoLiveDate({ error, data }) {
        if (data) {
            this.goLiveDateOptions = data.map((goLiveDate) => {
                return { 'label': goLiveDate, 'value': goLiveDate };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.goLiveDateOptions = undefined;
        }
    }

    //The function handleTitleChange is designed to handle changes in the title input or selection. It expects an event object as an argument, which presumably contains details about the change event.
    handleTitleChange(event) {
        this.selectedTitleValue = event.detail.value;
        this.selectedValues.Title = this.selectedTitleValue;
    }

    //Updates the selected project category value when the user changes it
    handleProjectCategoryChange(event) {
        this.selectedProjectCategoryValue = event.detail.value;
        this.selectedValues.ProjectCategory = this.selectedProjectCategoryValue;
    }

    /*
     * Handles the change event when the user selects a new region.
     * Updates the selected region value in the component's state.
    */
    handleRegionChange(event) {
        this.selectedRegionValue = event.detail.value;
        this.selectedValues.region = this.selectedRegionValue;
    }

    /*
      * Handles the change event when the user selects a new Go Live date.
      * Updates the selected Go Live date value in the component's state.
    */
    handleGoLiveDateChange(event) {
        this.selectedGoLiveDateValue = event.detail.value;
        this.selectedValues.goLiveDate = this.selectedGoLiveDateValue;

    }

    //this method is used to get event records based on title, category, region and goLive date
    handleApply() {
        getEventRecords({ title: this.selectedTitleValue, category: this.selectedProjectCategoryValue, region: this.selectedRegionValue, goLiveD: this.selectedGoLiveDateValue })
            .then((result) => {
                this.searchData = result;
                if (this.searchData.length > 0) {
                    this.isDataAvailable = true;
                }
                else {
                    this.isDataAvailable = false;
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.searchData = undefined;
            });
    }

    /*
    * Resets the search and filter criteria to their initial state.
    * Clears input values and resets data to original state.
    */
    handleClear() {
        this.searchData = this.originalData;
        this.selectedTitleValue = '';
        this.selectedProjectCategoryValue = '';
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.value = '';
        })
    }

    //this method gets the document related to the event
    handlePreviewImage(event) {
        const recordIdimg = event.target.dataset.descid;
        getRelatedFilesByRecordId({ recordId: recordIdimg })
            .then((data) => {
                const ImageId = data.ContentDocumentId;
                const imgVerId = data.Id;
                const filetyp = data.FileType;
                if (this.isGuestUser) {
                    let renditionVal = '';
                    console.log('filetyp : '+filetyp);
                    if (['PNG', 'JPG', 'JPEG'].includes(filetyp)) {
                        renditionVal = 'THUMB720BY480&versionId=';
                    } else if (['PDF', 'EXCEL_X','WORD_X'].includes(filetyp)) {
                        renditionVal = 'SVGZ&versionId=';
                    }
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: window.location.origin + CC_FILE_PREVIEW_URL + renditionVal + imgVerId
                        }
                    }, false);
                } else {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'filePreview'
                        },
                        state: {
                            selectedRecordId: ImageId
                        }
                    })
                }
            })
            .catch((error) => {
                console.log(error);
            })
    }

    handleAddNewEvet() {
        this.isFormOpen = true;
    }

    //Updates component state properties based on form input changes.
    handleNewEventFormData(event) {
        if (event.target.name === 'title') {
            this.title = event.target.value;
        }
        else if (event.target.name === 'goLivedate') {
            this.goLiveDate = event.target.value;
        }
        else if (event.target.name === 'category') {
            this.category = event.target.value;
        }
        else if (event.target.name === 'region') {
            this.region = event.target.value;
        }
    }

    handleSaveEvent() {
        //show toast if user does not enter any of the value 
        if (this.title === undefined || this.category === undefined || this.region === undefined || this.goLiveDate === undefined ||
            this.title === '' || this.category === '' || this.region === '' || this.goLiveDate === null) {
            const ele1 = this.template.querySelectorAll('.errorMessage');
            ele1.forEach(ele => {
                ele.classList.add('slds-hide');
            });
            if (this.title === undefined || this.title === '') {
                const ele = this.template.querySelector('.TitleErrorMessage');
                ele.classList.remove('slds-hide');
            }
            if (this.category === undefined || this.category === '') {
                const ele = this.template.querySelector('.CategoryErrorMessage');
                ele.classList.remove('slds-hide');
            }
            if (this.region === undefined || this.region === '') {
                const ele = this.template.querySelector('.RegionErrorMessage');
                ele.classList.remove('slds-hide');
            }
            if (this.goLiveDate === undefined || this.goLiveDate === null) {
                const ele = this.template.querySelector('.DateErrorMessage');
                ele.classList.remove('slds-hide');
            }
            return;
        }

        //this method creates a new Event
        createEvent({ title: this.title, goLiveDate: this.goLiveDate, category: this.category, region: this.region })
            .then((data) => {
                const toastEvent = new ShowToastEvent({
                    title: "Event Created Successfully",
                    message: "You can add file related to event if needed",
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                this.newRecordId = data;
                refreshApex(this.refreshResults);
                this.template.querySelector('div.screenOne').classList.add('slds-hide');
                this.template.querySelector('div.screenTwo').classList.remove('slds-hide');
                this.goLiveDate = undefined;
                this.category = undefined;
                this.region = undefined;
            })
            .catch((error) => {
                console.log(error);
            })
    }

    //Handles the cancellation of the form.
    handleCancel() {
        this.isFormOpen = false;
    }

    /**
     * Handles the completion of file upload.
     * Closes the form after the upload process is finished.
    */
    handleUploadFinished() {
        this.isFormOpen = false;
        refreshApex(this.refreshResults);
    }

    //Handles the sorting of data based on the selected column.
    handleSort(evt) {
        const columnName = evt.target.dataset.column;
        if (columnName) {
            // Clone the array to avoid modifying the original data directly
            const sortedData = [...this.searchData];
            // Determine the sorting direction
            const isAsc = this.sortDirection === 'asc';
            // Sort the array based on the selected column and direction
            sortedData.sort((a, b) => {
                if (columnName === 'Title') {
                    if (isAsc) {
                        this.isTitleAsc = true;
                    }
                    else {
                        this.isTitleAsc = false;
                    }
                    return isAsc
                        ? a.Title__c.localeCompare(b.Title__c)
                        : b.Title__c.localeCompare(a.Title__c);
                } else if (columnName === 'GoLiveDate') {
                    if (isAsc) {
                        this.isDateAsc = true;
                    }
                    else {
                        this.isDateAsc = false;
                    }
                    return isAsc
                        ? new Date(a.Go_Live_Date__c) - new Date(b.Go_Live_Date__c)
                        : new Date(b.Go_Live_Date__c) - new Date(a.Go_Live_Date__c);
                }
                return 0;
            });

            // i updated the tracked variable with the sorted data
            this.searchData = sortedData;
            // Toggle the sorting direction for the next click
            this.sortDirection = isAsc ? 'desc' : 'asc';
        }
    }

    /**
     * Handles the sorting of data by the 'Title' column.
     * Logs the event target for debugging purposes and delegates sorting to handleSort method.
    */
    handleTitleSort(event) {
        this.handleSort(event);
    }

    //Handles the sorting of data by the 'Go Live Date' column.
    handleGoLiveDateSort(event) {
        this.handleSort(event);
    }

    //Handles the navigation of record to Go Live Calender record page.
    handleTitleClick(event) {
        let dataId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: dataId,
                actionName: 'view'
            }
        });
    }
}