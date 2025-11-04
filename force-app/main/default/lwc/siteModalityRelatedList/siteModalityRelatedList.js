import { LightningElement, track, wire, api } from 'lwc';
import getRecords from '@salesforce/apex/siteModalityController.getSiteModalities';
import deleteSiteModalityRecord from '@salesforce/apex/siteModalityController.deleteSiteModalityRecord';
import hasCreateAccess from '@salesforce/apex/siteModalityController.hasCreateAccess';
import hasUpdateAccess from '@salesforce/apex/siteModalityController.hasUpdateAccess';
import hasDeleteAccess from '@salesforce/apex/siteModalityController.hasDeleteAccess';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { refreshApex } from '@salesforce/apex';

export default class site_modality_related_list extends NavigationMixin(LightningElement) {
    //custom related list for site modality on site record page
    @api recordId;
    @track showPopup = false;
    records = [];
    recordShow = [];
    activeSections1 = [];
    title = "Site Modalities (0)";
    norec = 0;
    objectApiName = 'CareProviderFacilitySpecialty';
    formattedString;
    showBtn = false;
    showEdit = false;
    showDelete = false;
    wiredMoadlityResult;
    error;

    @track recId = '';
    @track isGuestUser = false;

    //used to check initial access for user to show buttons
    connectedCallback() {
        this.checkaccess();

        // fetches recordId from url for guest user
        const origin = window.location.origin;
        if (origin.endsWith('site.com')) {
            this.isGuestUser = true;
            const url = window.location.href;
            const regex = /\/account\/([a-zA-Z0-9]{18}|[a-zA-Z0-9]{15})\//;
            const matches = url.match(regex);
            if (matches && matches.length > 1) {
                this.recId = matches[1];
            }
        }
        else {
            this.recId = this.recordId;
        }
    }

    //used to call refresh component
    refreshList = () => {
        refreshApex(this.wiredMoadlityResult);
    }
    refreshcomp() {
        refreshApex(this.wiredMoadlityResult);
    }

    //Used to fetch all related site modalities
    @wire(getRecords, { record: '$recId' })
    wiredModalityRecords(result) {
        this.norec = 0;
        this.title = "Site Modalities (0)";
        this.wiredMoadlityResult = result;
        if (result.data) {

            this.recordShow = result.data.map(data1 => {
                let tmpData = { ...data1 };                                                  //copy the elements of a particular array/object into a new array without affecting the original array/object, use the spread operator

                this.activeSections1.push(data1.name);
                if (tmpData.description) {
                    this.formattedString = tmpData.description.split(";").join("\n");
                    tmpData.description = this.formattedString;
                }

                if (data1 != null) {
                    this.norec = this.norec + 1;
                }
                this.title = "Site Modalities (" + this.norec + ")";
                return tmpData;
            });
        }
        else if (result.error) {
            this.error = result.error;
        }
    }

    //navigate to site modality page
    navigateToRecord(event) {
        const recordId1 = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId1,
                objectApiName: 'CareProviderFacilitySpecialty',
                actionName: 'view'
            }
        });
    }

    //checking CRUD permissions and showing buttons conditionally
    checkaccess() {
        hasCreateAccess({ isGuestUser: this.isGuestUser })
            .then((result) => {
                this.data = result;
                this.showBtn = this.data === true ? true : false;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
            });

        hasUpdateAccess({ isGuestUser: this.isGuestUser })
            .then((result) => {
                this.data = result;
                this.showEdit = this.data === true ? true : false;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
            });

        hasDeleteAccess({ isGuestUser: this.isGuestUser })
            .then((result) => {
                this.data = result;
                this.showDelete = this.data === true ? true : false;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    //navigate to standard site modality creation page
    newSiteModality() {
        const defaultValues = encodeDefaultFieldValues({
            AccountId: this.recordId
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: "CareProviderFacilitySpecialty",
                actionName: "new"
            },
            state: {
                navigationLocation: 'RELATED_LIST',
                defaultFieldValues: defaultValues
            }

        });
    }

    //navigate to standard site modality edit page
    editSiteModality(event) {
        const recordId1 = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId1,
                objectApiName: 'CareProviderFacilitySpecialty',
                actionName: 'edit'
            }
        });
    }

    //apex event to delete site modality
    deleteSiteModality(event) {
        const recordId1 = event.currentTarget.dataset.id;
        deleteSiteModalityRecord({ recordId: recordId1 })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Record deleted",
                        variant: "success",
                    }),
                );
                refreshApex(this.wiredMoadlityResult);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error deleting record",
                        message: error.body.message,
                        variant: "error",
                    }),
                );
                this.isLoading = false;
            });
    }

}