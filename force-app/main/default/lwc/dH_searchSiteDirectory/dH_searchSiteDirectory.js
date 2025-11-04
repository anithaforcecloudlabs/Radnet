/*
* ***************************************************************************************************************************
* LWC Component Name - DH_searchSiteDirectory
* 
* Created Date : 20/03/2025
* 
* @description : This component is used to fetch the Site Directory records from the Site Directory Object.
*
* @Jira Id     : CC-1519
*
* *****************************************************************************************************************************
*/
import { LightningElement,track, wire } from 'lwc';
import getRecords from '@salesforce/apex/DH_SearchSiteDirectory.getRecords';
const columns = [
    {
       label: 'State',
       fieldName: 'State__c',
       hideDefaultActions: true
      
   }, {
       label: 'Site Group',
       fieldName: 'Site_Group__c',
       wrapText: true,
       hideDefaultActions: true
   }, {
       label: 'Code',
       fieldName: 'Site_Code__c',
    
       wrapText: true,
       hideDefaultActions: true
   }, {
       label: 'Site Name',
       fieldName: 'procedureLink',
       type: 'url',
       typeAttributes: { label: { fieldName: 'Site_Name__c' }, target: '_blank' },
       wrapText: true,
       hideDefaultActions: true
   }, {
       label: 'Address',
       fieldName: 'Address__c',
       wrapText: true,
       hideDefaultActions: true
   }, {
       label: 'Phone',
       fieldName: 'Site_Phone__c',
       wrapText: true,
       hideDefaultActions: true
   }, {
       label: 'Fax ',
       fieldName: 'Site_Fax_Number__c',
       wrapText: true,
       hideDefaultActions: true
   },{
    label: 'Medical Records\n For internal use only, \n Do NOT give out DID',
    fieldName: 'Site_Medical_Records_Ring_Group__c',
//    wrapText: true
hideDefaultActions: true
},{
    label: 'Front Desk \n For internal use only, \n Do NOT give out DID',
    fieldName: 'Site_Front_Desk_Ring_Group__c',
 //   wrapText: true
 hideDefaultActions: true
},{
    label: 'Scheduling',
    fieldName: 'Scheduling_Main__c',
//    wrapText: true
hideDefaultActions: true
},{
    label: 'Extra Info',
    fieldName: 'Extra_Info__c',
//    wrapText: true
hideDefaultActions: true
},

];
export default class DH_searchSiteDirectory extends LightningElement {
    @track columns = columns;
    @track error;
    @track searchData = [];
    @track originalData = [];

 
    selectedValue;
    isConnected = true;
    showResult = false;
    callChild= false;
    showModal= false;


    print(){
        window.print();
    }
    
     // this method is used to get list of Site directory records.
        @wire(getRecords)
        wiredSiteRecords({ error, data }) {
            if (data) {
                this.isConnected = true;
                this.searchData = data.map(data1 => {
                    let tmpData = { ...data1 };
                    //copy the elements of a particular array/object into a new array without affecting the original array/object, use the spread operator
                    tmpData.procedureLink = '/lightning/r/Site_Directory__c/' + data1.Id + '/view'; //used relative URL
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
            }else if(error){
                this.error = error;
            } 
        }    

        /**
    * Handles the change event for the Search Functionality.
    * Updates the selected values and applies the combined filters.
    */
    handleChange(event) {
        
        this.selectedValue = event.target.value;
        this.applyCombinedFilters();
     }

     /*
      * Applies combined filters to the original data based on selected address or site phone number.
      * Updates the search data with the filtered results.
     */

applyCombinedFilters() {    
    let filteredData = this.originalData || [];     
    let nameFilter = this.selectedValue ? this.selectedValue.toLowerCase() : '';  
    if (nameFilter) {    
        
        filteredData = filteredData.filter(record => {  
            if (!record) {  
                console.error('Record is undefined or null');  
                return false; // Skip undefined or null records  
            }  

            const addressMatch = record.Address__c?.toLowerCase().includes(nameFilter);  
            const phoneMatch = record.Site_Phone__c?.includes(nameFilter);  
            const faxMatch = record.Site_Fax_Number__c?.includes(nameFilter);
            const groupMatch = record.Site_Group__c?.toLowerCase().includes(nameFilter);  
            const nameMatch = record.Site_Name__c?.toLowerCase().includes(nameFilter);  
            const codeMatch = record.Site_Code__c?.toLowerCase().includes(nameFilter);  
            const medicalMatch = record.Site_Medical_Records_Ring_Group__c?.includes(nameFilter);  
            const schedulingMatch = record.Scheduling_Main__c?.includes(nameFilter);  
            const frontDeskMatch = record.Site_Front_Desk_Ring_Group__c?.includes(nameFilter);  
            const stateMatch = record.State__c?.toLowerCase().includes(nameFilter); 
            const infoMatch = record.Extra_Info__c?.toLowerCase().includes(nameFilter); 

            const matches = addressMatch || phoneMatch || groupMatch || nameMatch ||   
                            codeMatch || medicalMatch || schedulingMatch ||   
                            frontDeskMatch || stateMatch || faxMatch || infoMatch;   
            return matches;  
        });  
    }  

    this.searchData = filteredData;  
}  


     handleShow() {
        this.callChild= true;
      }
    

        handleClose(event) {
        this.callChild= false;
    }

    /* 
    * Handles the clear action to reset the search filters and data.
    * Resets the search data to the original data, clears selected filter values,
    * clears the input fields in the template.
    */
    handleClear() {
        this.searchData=this.originalData;
        this.selectedValue='';
        this.template.querySelectorAll('lightning-input').forEach(element=> {
            element.value='';
        })
    }
}