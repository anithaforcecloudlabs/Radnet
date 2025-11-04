/*
* ***************************************************************************************************************************
* LWC Component Name - DH_searchPhoneDirectory
* 
* Created Date : 13/06/2024
* 
* @description : This component is used to fetch the phone number in the knowledge article.
*
* @Jira Id     : CC-341
*
* *****************************************************************************************************************************
*/
import { LightningElement, track, wire } from 'lwc';
import getRegion from '@salesforce/apex/DH_SearchPhoneDirectoryApex.getRegion';
import getEntryPointName from '@salesforce/apex/DH_SearchPhoneDirectoryApex.getEntryPointName';
import getRecords from '@salesforce/apex/DH_SearchPhoneDirectoryApex.getRecords';
import getUserType from '@salesforce/apex/DH_KMUtility.getUserType';
const columns = [
      {
         label: 'Entry Point Name',
         fieldName: 'procedureLink',
         type: 'url',
         typeAttributes: { label: { fieldName: 'ENTRY_POINT_NAME__c' }, target: '_blank' },
         wrapText: true
     }, {
         label: 'Region',
         fieldName: 'REGION__c',
         wrapText: true
     }, {
         label: 'Phone Number',
         fieldName: 'PHONE_NUMBER__c',
         initialWidth: 150,
         wrapText: true
     }, {
         label: 'Comments',
         fieldName: 'COMMENTS__c',
         wrapText: true
     },
 
 ];

export default class DH_searchPhoneDirectory extends LightningElement {
    
    @track columns = columns;
    @track error;
    @track searchData = [];
    @track originalData = [];

    @track selectedValues = { Region: '', EntryPointName: '' };
    isConnected = true;
    showResult = false;

    @track regionOptions = [];
    selectedRegionValue;

    @track entryPointNameOptions = [];
    selectedEntryPointNameValue;
    isGuestUser=false;

   

    

    // getting the user type of the user whether it is a guest user or not
    @wire(getUserType)
    userType(result) {
        if (result.data) {
            console.log('WIRE FIRED');
            this.isGuestUser = result.data;  
            console.log('this.isGuestUser : '+this.isGuestUser);          
            this.setTableColumns();
        }
        else if (result.error) {
            console.log('error found -> ' + JSON.stringify(result.error));
        }
    }

    // this method is used to get all the region from Phone_Directory__c 
    @wire(getRegion, {})
    wiredgetRegion({ error, data }) {
        if (data) {
            try {
                this.regionOptions = data.map((region) => {
                    return { 'label': region, 'value': region };
                });
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
    }

    //this method is used to get all the entry point name from Phone_Directory__c
    @wire(getEntryPointName)
    wiredmodality({ error, data }) {
        if (data) {
            this.entryPointNameOptions = data.map((entryPointName) => {
                return { 'label': entryPointName, 'value': entryPointName };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.entryPointNameOptions = undefined;
        }
    }

    // this method is used to get list of phone directory records on the basis of region and entry point name.
    @wire(getRecords, { reg: null, entry: null })
    wiredPhoneRecords({ error, data }) {
        if (data) {
            this.isConnected = true;
            this.selectedValues = { Region: '', EntryPointName: '' };
            this.searchData = data.map(data1 => {
                let tmpData = { ...data1 };
                //copy the elements of a particular array/object into a new array without affecting the original array/object, use the spread operator
                tmpData.procedureLink = '/lightning/r/Phone_Directory__c/' + data1.Id + '/view'; //used relative URL
                //tmpData.procedureLink = '';
                return tmpData;
            });
            this.originalData = this.searchData;
            if (this.searchData.length === 0) {
                this.showResult = true;
                this.isConnected = false;
            }
            else {
                this.showResult = false;
                this.isConnected = true;
            }
        } else if (error) {
            this.error = error;
            this.entryPointNameOptions = undefined;
        }
        console.log('this.columns : '+JSON.stringify(this.columns)); 
    }    

    print(){
        window.print();
    }
    
    /**
    * Handles the change event for the region selection.
    * Updates the selected region value and applies the combined filters.
    */
    handleRegionChange(event) {
        this.selectedRegionValue = event.detail.value;
        this.selectedValues.Region = this.selectedRegionValue;
        this.applyCombinedFilters();
     }

     /*
     * Handles the change event for the entry point name selection.
     * Updates the selected entry point name value and applies the combined filters.
     */
     handleEntryChange(event) {
        this.selectedEntryPointNameValue = event.detail.value;
        this.selectedValues.EntryPointName = this.selectedEntryPointNameValue;
        this.applyCombinedFilters();
     }

     /*
      * Applies combined filters to the original data based on selected region and entry point name.
      * Updates the search data with the filtered results.
     */
     applyCombinedFilters() {
        let filteredData = this.originalData;
        let regionFilter = '';
        if (this.selectedRegionValue) {
            regionFilter = this.selectedRegionValue.toLowerCase();
        }
        let entryPointFilter = '';
        if (this.selectedEntryPointNameValue) {
            entryPointFilter = this.selectedEntryPointNameValue.toLowerCase();
        }
        if (regionFilter !== '' || entryPointFilter !== '') {
            filteredData = this.originalData.filter(record => {
                let regionMatch = true;
                let entryPointMatch = true;
                if (regionFilter !== '') {
                    regionMatch = record.REGION__c.toLowerCase().includes(regionFilter);
                }
                if (entryPointFilter !== '') {
                    entryPointMatch = record.ENTRY_POINT_NAME__c.toLowerCase().includes(entryPointFilter);
                }
                return regionMatch && entryPointMatch;
            });
        }
        this.searchData = filteredData;
     }

    /* 
    * Handles the clear action to reset the search filters and data.
    * Resets the search data to the original data, clears selected filter values,
    * clears the input fields in the template.
    */
    handleClear() {
        this.searchData=this.originalData;
        this.selectedRegionValue='';
        this.selectedEntryPointNameValue='';
        this.template.querySelectorAll('lightning-input').forEach(element=> {
            element.value='';
        })
    }

    //Set Table Columns for Community V/S HC
    setTableColumns(){
        let firstColumn=[];        
        if(this.isGuestUser){
            this.columns.shift();
            firstColumn.push({ 
                label: 'Entry Point Name',
                fieldName: 'ENTRY_POINT_NAME__c',
                wrapText: true
            });
            this.columns=firstColumn.concat(this.columns);
        }
    }
}