/*
* ************************************************************************************************************************************************************************
* LWC Component Name - dH_VerifyCaller.js
* Created Date - 22-May-2024
* Function - JS class of contact center verify caller screen.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       ---------------------
* CC-425                     22-May-2024          Added invokeRisPatientSearch method.
* CC-426                     25-May-2024          Added handleCreatePatientInRis and handleSearchPatientInRis methods.
* CC-428,CC-429              29-May-2024          Added handleConfirmPatientInRis method.
* CC-474                     01-July-2024         Added changes related to dynamic table columns and the data formatting as required
* CC-480                     08-July-2024         Added the methods expandAll and collapseAll to perform action on button click.
* CC-724                     18-July-2024         Updated the getAllSelectedRecord and getAllSelectedRecordFromChild methods to change button variant.
* CC-622                     25-July-2024         Updated getAllSelectedRecord,getAllSelectedRecordFromChild,handleConfirmPatientInRis to do conditional rendering of error.
* CC-482                     26-July-2024         Updated invokeRisPatientSearch method.
* CC-505                     04-August-2024       Updated handleConfirmPatientInRis method.
* CC-716,CC-633,CC-664       16-August-2024       Updated handleConfirmPatientInRis to add createLogRecord and invokeRisOpenPatientApi methods.
* CC-962                     28-August-2024       Added checkDuplicateExist method and related variable.
* CC-520                     18-August-2024       Added error messages for failed API services and Updated invokeNewPatientService method
* CC-572,CC-590,CC-481       18-August-2024       Addded createNewPatient method
* CC-692                     02-September-2024    Added previousVerifiedPatient variable.
* CC-962                     04-September-2024    Added showChildRecords to conditionally render child records.
* CC-962                     04-September-2024    Added renderColor to render the colors for header for childdata.
* CC-962                     04-September-2024    Updated expandALl and collapseAll function for conditionally rendering the expandAll and collapseAll button.
* CC-962                     04-September-2024    Updated invokeRisPatientSearch and handleSearchPatientInRis for rendering the color for childData.
* CC-1291,1271,1270          04-September-2024    Updated invokeRisPatientSearch, handleCreatePatientInRis, handleSearchPatientInRis methods and added isDataFetchedError variable
* CC-1296                    12-September-2024    Updated handleSearchPatientInRis method
* CC-1337                    20-September-2024    Updated connectedCallback method
* CC-1365                    30-September-2024    Updated connectedCallback method
* CC-1394                    30-September-2024    Updated getAllSelectedRecord,showChildRecords method
* CC-1439                    30-October-2024	  Replaced all instances of FromPhoneNumber with F9_Call_ANI__c  
* CC-1455                    14-November-2024     Added fetchPatientData and made changes to reduce the delay in fetching patient information from RIS
* CC-1312                    23-April-2025        Updated handleConfirmPatientInRis, handleSearchPatientInRis and handleCreatePatientInRis
* CC-1545                    23-April-2025        Updated invokeRisPatientSearch method
* **************************************************************************************************************************************************************************
*/
import { LightningElement, api, track, wire } from 'lwc';
import { MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {NavigationMixin} from 'lightning/navigation';
import {getRecord} from 'lightning/uiRecordApi';
import getDynamicTableColumnsRecords from '@salesforce/apex/DH_VerifyCallerController.getDynamicTableColumnsRecords';
import createLogRecord from '@salesforce/apex/DH_DexLoggingUtility.createLogRecord';
import invokeRisPatientSearchApi from '@salesforce/apex/DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi';
import getPreviousVerifiedPatient from '@salesforce/apex/DH_MessagingSessionTriggerHelper.getPreviousVerifiedPatient';
import errorMessageForSearchPatient from '@salesforce/label/c.DH_ErrorMessageForSearchPatient';
import errorMessageForSearchPatientInRis from '@salesforce/label/c.DH_ErrorMessageForSearchPatientInRis';
import SelectLaunchPatient from '@salesforce/label/c.DH_LaunchSelectedPatientButtonName';
import CreatePatientInRis from '@salesforce/label/c.DH_NewPatientButtonName';
import SearchPatientInRis from '@salesforce/label/c.DH_PatientSearchButtonName';
import VerifyChatlabel from '@salesforce/label/c.Store_the_name_of_the_Verify_chat_screen';


import invokeRisOpenPatientApiIead from '@salesforce/apex/DH_DexOutServiceRisOpenPatientMS.invokeRisOpenPatientApi';
import validatePreviousVerifiedChatLead from '@salesforce/apex/DH_MessagingSessionTriggerHelper.validatePreviousVerifiedChat';
import SearchPatientManuallyInRisModal from "c/dH_PatientSearchMS";
import patientVerified from '@salesforce/label/c.DH_PatientVerified';
import buttonColor from '@salesforce/label/c.DH_ButtonColor';
import patientSelectionError from '@salesforce/label/c.DH_PatientSelectionError';
import noAdditionalData from '@salesforce/label/c.DH_noAdditionalDataInDuplicatePatient';
import recentOutreachbg from '@salesforce/label/c.DH_RecentOutreachBackgroundColor';
import openEMRbg from '@salesforce/label/c.DH_OpenEMRBackgroundColor';
import nonEMRbg from '@salesforce/label/c.DH_NonEMRBackgroundColor';
import priorApptbg from '@salesforce/label/c.DH_PriorAppointmentBackgroundColor';
import upcomingapptbg from '@salesforce/label/c.DH_UpcomingAppointmentBackgroundColor';
import CALLER_NUMBER_FIELD from '@salesforce/schema/MessagingSession.Mobile_Phone__c';
import SYSTEM_ID_FIELD from '@salesforce/schema/MessagingSession.System_Id__c';
import QUEUE_NAME_FIELD from '@salesforce/schema/MessagingSession.Queue_Name__c';
//import CALL_DISPOSITION_FIELD from '@salesforce/schema/MessagingSession.F9_Call_disposition_name__c';
import {getTabInfo , closeTab, getAllTabInfo} from 'lightning/platformWorkspaceApi';
import CALL_TYPE_FIELD from '@salesforce/schema/MessagingSession.Origin';
import DOB_FIELD from '@salesforce/schema/MessagingSession.Date_of_Birth__c';

export default class dH_VerifyChat extends NavigationMixin(LightningElement) {  
    @api objectApiName;
    @track idToClose;
    @track allTabList=[];
    @track previousVerifiedPatientId;
    @track tempPreviousVerifiedPatient;
    @track isReVerified=false;
    @track loggerParam = null;
    @api recordId;
    @track phoneNo;
    @track callType;
    @track queueName;
    @track systemId;
    @track responseCode;
    @track createPatientInRisParam = null;
    @track openPatientInRisParam = null;
    @track recordPageUrl
    @track displayManualSearchButton
    @track displayConfirmPatientButton
    @track selectedRow;
    @track selectedMRN;
    @track patientList = [];
    @track patientColumns=[];
    @track columnList = [];
    @track patientListCopy = [];
    @track sortBy;
    @track sortDirection;
    @track isDataFetched = false;
	@track isDataFetchedError = true;
    @track showError = false;
    @track disableExpandCollapseAll=true;
    @track errorDisplayedSearch = false;
    @track isApiError = false;
    @track apiError;
    @track patientId;
    buttonVariant;
    buttonVariantChanged;
    @track noRecordFoundErrorMessage='Searching for Patients. Please Wait!';
    @track noAdditionalDataInDuplicate = noAdditionalData;
    @track recentOutreachBackgroundColor;
    @track openEMROrderBackgroundColor;
    @track nonEMROrderBackgroundColor;
    @track priorAppointmentBackgroundColor;
    @track upcomingAppointmentBackgroundCo;
    @track isChild = false;
    @track verifiedPatientId;
    @track phoneError = false;
    @track disableCreatePatientInRis = false;
    @track disableConfirmPatientInRis = false;
    @track disableSearchPatientInRis = false;
    fields = [CALLER_NUMBER_FIELD, SYSTEM_ID_FIELD,QUEUE_NAME_FIELD, CALL_TYPE_FIELD,DOB_FIELD];
    @wire(MessageContext)
    messageContext;
    label = {
        CreatePatientInRis,
        SelectLaunchPatient,
        SearchPatientInRis,
        VerifyChatlabel,
        patientVerified,
        patientSelectionError,
        noAdditionalData
    };
    @track previousVerifiedPatient ;
    /**
	* @Jira CC-425,692 
    * @description - This method is used to get table columns dynamically from metadata and to retrieve the voice call record phone number, call invokePatientSearch method and calls getPreviousVerifiedPatient method.
	**/
    connectedCallback(){
        const labelValues = buttonColor.split(','); 
        console.log('Insideconnectedcallback');
        this.buttonVariant = labelValues[0];
        this.buttonVariantChanged = labelValues[1];
        getDynamicTableColumnsRecords().then((result)=>{
            this.columnList = result;
        })   
        this.recentOutreachBackgroundColor = recentOutreachbg;
        this.openEMROrderBackgroundColor = openEMRbg;
        this.nonEMROrderBackgroundColor = nonEMRbg;
        this.priorAppointmentBackgroundColor = priorApptbg;
        this.upcomingAppointmentBackgroundCo = upcomingapptbg;

    }

       handlegetAllTabInfo(){
        getAllTabInfo().then((allTabInfo)=>{
            this.allTabList = allTabInfo;
        }).catch(function(error){
            console.log(error);
        });
                this.allTabList.forEach(tab=>{  
                tab.subtabs.forEach(subTab => {
                 getTabInfo(subTab.tabId)
        .then(response =>  {
            if(response.recordId==this.tempPreviousVerifiedPatient){
                this.idToClose=subTab.tabId;
            }
        });
    });  
    });
    }

   
  
@wire(getRecord, { recordId: '$recordId', fields: [CALLER_NUMBER_FIELD, SYSTEM_ID_FIELD, CALL_TYPE_FIELD, DOB_FIELD, QUEUE_NAME_FIELD] })
wiredMessagingSessionRecord({ data, error }) {
    console.log('first step');
        if(data){   
             console.log('first data',data);
        this.phoneNo   = data.fields.Mobile_Phone__c?.value || '';
        this.callType  = data.fields.Origin?.value || '';
        this.birthDate = data.fields.Date_of_Birth__c?.value || null;
        this.systemId  = data.fields.System_Id__c?.value || '';
        this.queueName = data.fields.Queue_Name__c?.value || '';  // ✅ custom field

        if (this.phoneNo && this.systemId) {
            this.fetchPatientData();
        }
    } else if (error) {
        this.loggerParam = {
            ErrorMessage: error.message,
            ClassName: 'dh_VerifyChat-wireGetRecord',
            RelatedTo: this.recordId,
        };
        createLogRecord({ log: this.loggerParam });
    }
}
 
    fetchPatientData(){
        this.handlegetAllTabInfo();
        console.log('fetchPatientData=');
        getPreviousVerifiedPatient({ recordId: this.recordId })
        .then((result) => {
            if (result != null) {
                console.log('Previousverifir='+result);
                this.previousVerifiedPatient = result;
                this.verifiedPatientId = result.Id;
                this.handleConfirmPatientInRis();
            } else {
                this.invokeRisPatientSearch();
            }
        })
        .catch((error) => {
            this.invokeRisPatientSearch();
        }); 
    }
    /**
	* @Jira CC-425-475
    * @description - This method is used to format table columns properly and to retrieve the patient data from ris using phone number and convert it in proper required format.
	**/
    invokeRisPatientSearch() {
        this.handlegetAllTabInfo();
        const searchPatientInRisParam = 
        {
            recordId: this.recordId,
            phoneNumber: this.phoneNo,
            dateOfBirth: this.birthDate,
            systemId: this.systemId,
            isAdvanceSearch: false,
            callType: this.callType        
        };
        invokeRisPatientSearchApi({urlParametersWrapper : searchPatientInRisParam})
        .then((result) => {
            const len = Object.keys(result).length;
            if(result && len>0 && Object.keys(result)[0] != -1 && Object.keys(result)[0] != -2){
                if(this.phoneError == true){
                    this.isApiError = false;
                    this.phoneError = false;
                }
                this.isDataFetched = true;
				this.isDataFetchedError = false;
                this.patientList = [];
            for(const [key, value] of Object.entries(result)) {
                this.patientList.push(value);
            }
                let tableColumn = [];
                this.columnList.sort((a,b)=>a.DH_AttributeSequenceNumber__c - b.DH_AttributeSequenceNumber__c);
                this.columnList.forEach(columnName=>{
                    let InitialWidth = Number(columnName.DH_AttributeDisplayWidth__c);
                    if(columnName.DH_AttributeDataType__c=='date-local' || columnName.DH_AttributeDataType__c=='date' ){
                        tableColumn.push({ label:  columnName.DH_AttributeLabel__c, fieldName: columnName.DH_AttributeName__c, type: columnName.DH_AttributeDataType__c ,initialWidth:InitialWidth,typeAttributes:{month: columnName.DH_TypeAttributeDateDay__c,day: columnName.DH_TypeAttributeDateMonth__c}});
                    }else{
                        tableColumn.push({ label: columnName.DH_AttributeLabel__c, fieldName: columnName.DH_AttributeName__c, type: columnName.DH_AttributeDataType__c ,initialWidth:InitialWidth});
                    }
                });
                this.patientColumns = tableColumn;
                this.patientListCopy = this.patientList.map(item=>{
                    return {parent: item[0], childData: [...item], flag:false , isDup:item.length>1,hideParentRecord:false,showChildData:false}
                });  
                this.disableExpandCollapseAll = true;
                this.checkDuplicateExist();
                this.renderColor();
            }else if(result && len==1 && Object.keys(result)[0] == -1){
                this.isDataFetched = false;
				this.isDataFetchedError = false;
                this.errorDisplayed = true;
                this.apiError = result[-1][0].errorMessage;
                this.isApiError = true;
                this.phoneError = true;
            }else if(result && len==1 && Object.keys(result)[0] == -2){
                this.isDataFetched = false;
				this.isDataFetchedError = false;
                this.errorDisplayed = true;
                this.apiError = result[-2][0].errorMessage;
                this.isApiError = true;
                this.phoneError = true;
            }
            else if(result && len === 0){
                this.isDataFetched = false;
				this.isDataFetchedError = true;
                this.errorDisplayed = true;
                this.isApiError = false;
                this.noRecordFoundErrorMessage = errorMessageForSearchPatient;
            }
            
        })
        .catch((error) => {
            console.log("ERROR in phone api" + error);
        });        
    } 
    /**
	* @Jira CC-962 Method to disable the expand all button
    * @description - This method is used to expand or open all duplicate records if available.
	**/
    checkDuplicateExist(){ 
        this.patientListCopy.forEach(item=>{
            if(item.childData.length>1){
                this.disableExpandCollapseAll = false;
            }
        });
    }
    /**
	* @Jira CC-480
    * @description - This method is used to expand or open all duplicate records if available.
	**/
    expandAll(){ 
        this.patientListCopy.forEach(item=>{
            if(item.childData.length>1){
            item.showChildData = true;
            item.hideParentRecord = true; 
            }
        });
        this.renderColor();
    }
    /**
	* @Jira CC-480
    * @description - This method is used to Collapse or close all duplicate records if available.
	**/
    collapseAll(){
        this.patientListCopy.forEach(item=>{
            item.showChildData = false;
            item.hideParentRecord = false;
        });
    }
    /**
	* @Jira CC-474
    * @description - This method is used to get the selected patient record data.
	**/
    getAllSelectedRecord(event) {
        this.showError=false;
        const selectedKey = event.target.dataset.id;
        if (this.selectedMRN === selectedKey) {
            this.selectedMRN = null; 
        } else {
            if(this.isChild === true){
                this.selectedMRN = selectedKey;
                this.selectedRow = this.patientListCopy.find(patient => patient.childData.find(child => child.mrn === selectedKey));
                this.selectedRow = this.selectedRow.childData.find(patient => patient.mrn === selectedKey);
                this.buttonVariant = this.buttonVariantChanged;
            }
            else{
                this.selectedMRN = selectedKey;
                this.selectedRow = this.patientListCopy.find(patient => patient.parent.mrn === selectedKey);
                this.selectedRow = this.selectedRow.parent;
                this.buttonVariant = this.buttonVariantChanged;
            }
        }
    }
    /**
	* @Jira CC-425
    * @description - This method is used show the toast message when a record is verified.
	**/
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        });
        this.dispatchEvent(event);
    }
    goBackToStepOne() {
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepOne')
            .classList.remove('slds-hide');
    }
    /**
	* @Jira CC-428,429,505,716,633,664
    * @description - This method is used to invoke invokeRisOpenPatientApi method of the Open Patient in RIS service class class.
	**/
    handleConfirmPatientInRis(){
         console.log('Inside handleConfirmPatientInRis');
        if(this.callType != 'Outbound'){
              console.log('this.callType'+this.callType);
            this.handlegetAllTabInfo();
            if(this.isReVerified){
                console.log('isReVerified'+this.isReVerified);
                validatePreviousVerifiedChatLead({MessagingSessionId: this.recordId })
            .then((result) => { 
                console.log('isReVerified false'+this.isReVerified);
            this.isReVerified=false;
            })
            .catch((error) => {     
                console.log(error);
            }); 
            }
            if(this.selectedRow || this.previousVerifiedPatient){    
                   console.log('selectedRow'+this.selectedRow);
                     console.log('✅ selectedRow:', JSON.stringify(this.selectedRow));
                this.openPatientInRisParam = 
                { 
                    recordId:this.recordId,
                    patientKey:(this.previousVerifiedPatient==null ?this.selectedRow.patientKey:this.previousVerifiedPatient.DH_Patient_Key__c),
                    systemId:(this.previousVerifiedPatient==null ? this.selectedRow.systemID : this.systemId)
                };
                 console.log('selectedRow'+this.verifiedPatientId);
                if(this.verifiedPatientId==null || this.verifiedPatientId==undefined){
                    console.log('openPatientInRisParam'+this.openPatientInRisParam);
                     console.log('✅ selectedRow:', JSON.stringify(this.selectedRow));
                invokeRisOpenPatientApiIead({urlParametersWrapper : this.openPatientInRisParam})
                .then((result) => {
                    if(result!=null){
                         console.log('✅ invokeRisOpenPatientApiIead:', JSON.stringify(result));
                    if(this.idToClose!=null && this.tempPreviousVerifiedPatient!=result){
                closeTab(this.idToClose);
            }
                        this.previousVerifiedPatientId = result;
                        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
                        this.template.querySelector('div.verified').classList.remove('slds-hide');
                        this[NavigationMixin.Navigate]({
                            type:'standard__recordPage',
                            attributes:{
                                recordId:result,
                                objectApiName:'Account',
                                actionName:'view'
                            }
                        });
                    }
                    else{
                        console.log("Data recieved from RIS is not proper");
                    }
                })
                .catch((error) => {
                    this.loggerParam = 
                    {
                        ErrorMessage:error.message,
                        ClassName:'dh_VerifyCaller-invokeRisOpenPatientApi',
                        RelatedTo:this.recordId,
                    };
                    createLogRecord({log : this.loggerParam})
                })
                }else{
                        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
                        this.template.querySelector('div.verified').classList.remove('slds-hide');
                        this.previousVerifiedPatientId = this.verifiedPatientId;
                        this[NavigationMixin.Navigate]({
                            type:'standard__recordPage',
                            attributes:{
                                recordId:this.verifiedPatientId,
                                objectApiName:'Account',
                                actionName:'view',
                            }
                        });
                        this.verifiedPatientId=null;

                }
            }else{
                if(this.patientList.length > 0){
                    this.showError=true;
                }
                else{
                    console.log('No data from api');
                }
            }
            this.disableExpandCollapseAll=true;  
        }
    }
   
    /**
	* @Jira CC-425
    * @description - This method is used search the patient using additional search by pressing search additional patient in ris.
	**/
   async handleSearchPatientInRis() {
    console.log('systemId', this.systemId);

    if (this.callType !== 'Outbound') {
        this.showError = false;

        try {
            const result = await SearchPatientManuallyInRisModal.open({
                size: 'small',
                systemId: this.systemId,
                description: this.recordId,
            });

            console.log('✅ Modal result:', JSON.stringify(result));

            let resultData = null;

            if (result) {
                if (result.data) {
                    resultData = result.data;
                }

                if (resultData && result.dataEntered && Object.keys(result.data).length > 0 && result.flag) {
                    this.isApiError = false;
                    this.isDataFetched = true;
                    this.isDataFetchedError = false;
                    this.patientList = [];

                    for (const [key, value] of Object.entries(resultData)) {
                        this.patientList.push(value);
                    }

                    let tableColumn = [];
                    this.columnList.sort((a, b) => a.DH_AttributeSequenceNumber__c - b.DH_AttributeSequenceNumber__c);

                    this.columnList.forEach(columnName => {
                        let InitialWidth = Number(columnName.DH_AttributeDisplayWidth__c);
                        if (columnName.DH_AttributeDataType__c === 'date-local' || columnName.DH_AttributeDataType__c === 'date') {
                            tableColumn.push({
                                label: columnName.DH_AttributeLabel__c,
                                fieldName: columnName.DH_AttributeName__c,
                                type: columnName.DH_AttributeDataType__c,
                                initialWidth: InitialWidth,
                                typeAttributes: {
                                    month: columnName.DH_TypeAttributeDateDay__c,
                                    day: columnName.DH_TypeAttributeDateMonth__c
                                }
                            });
                        } else {
                            tableColumn.push({
                                label: columnName.DH_AttributeLabel__c,
                                fieldName: columnName.DH_AttributeName__c,
                                type: columnName.DH_AttributeDataType__c,
                                initialWidth: InitialWidth
                            });
                        }
                    });

                    this.patientColumns = tableColumn;
                    this.patientListCopy = this.patientList.map(item => {
                        return {
                            parent: item[0],
                            childData: [...item],
                            flag: false,
                            isDup: item.length > 1,
                            hideParentRecord: false,
                            showChildData: false
                        };
                    });
                } else {
                    this.isApiError = false;
                    this.isDataFetched = false;
                    this.isDataFetchedError = true;
                    this.errorDisplayed = true;
                    this.noRecordFoundErrorMessage = errorMessageForSearchPatientInRis;
                    this.patientListCopy = [];
                }
            }

            this.disableExpandCollapseAll = true;
            this.checkDuplicateExist();

        } catch (err) {
            console.error('❌ Error in handleSearchPatientInRis:', JSON.stringify(err));
            this.isApiError = true;
            this.isDataFetched = false;
            this.isDataFetchedError = true;
            this.errorDisplayed = true;
            this.noRecordFoundErrorMessage = err?.body?.message || err?.message || 'Unknown error occurred';
        }
    }
}

    /**
	* @Jira CC-962
    * @description - This method is used conditionally render child records.
	**/
    showChildRecords(event){
        const patientMrn = event.target.dataset.id;
        this.patientListCopy =  this.patientListCopy.map((item)=>{
            if(item.parent.mrn == patientMrn){                
                item.showChildData = !item.showChildData;     
                item.hideParentRecord = !item.hideParentRecord; 
                this.isChild = !this.isChild;
            }   
            return item;       
        })
        this.renderColor();
    }
    /**
	* @Jira CC-962
    * @description - This method is used to render the color for header for child details.
	**/
    renderColor(){
    this.template.querySelector(".parentWrapper")
        .style.setProperty("--recent-Outreach",this.recentOutreachBackgroundColor); 
    this.template.querySelector(".parentWrapper")
        .style.setProperty("--open-EMR",this.openEMROrderBackgroundColor); 
    this.template.querySelector(".parentWrapper")
        .style.setProperty("--non-EMR",this.nonEMROrderBackgroundColor); 
    this.template.querySelector(".parentWrapper")
        .style.setProperty("--upcoming-Appointment",this.upcomingAppointmentBackgroundCo); 
    this.template.querySelector(".parentWrapper")
        .style.setProperty("--prior-Appointment",this.priorAppointmentBackgroundColor);  
    }

    handleReverifyCaller() {
    this.isReVerified=true;
    this.handlegetAllTabInfo();
    this.patientColumns=[];
    this.patientListCopy=[];
    this.isDataFetched = false;
    this.isDataFetchedError = true;
    this.showError = false;
    this.disableExpandCollapseAll=true;
    this.errorDisplayedSearch = false;
    this.isApiError = false;
    this.isChild = false;
    this.tempPreviousVerifiedPatient=this.previousVerifiedPatientId;
    this.verifiedPatientId=null;
    this.previousVerifiedPatient=null;
    this.previousVerifiedPatientId=null;
    this.invokeRisPatientSearch();
    this.template.querySelector('div.stepTwo').classList.remove('slds-hide');
    this.template.querySelector('div.verified').classList.add('slds-hide');
    this.handlegetAllTabInfo();
    }
}