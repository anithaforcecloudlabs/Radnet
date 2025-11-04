import { LightningElement, api, wire} from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import COMPETITION from '@salesforce/schema/Competition__c.Name';
import COMPETITION_ID from '@salesforce/schema/Competition__c.Id';
import LightningConfirm from 'lightning/confirm';
import LightningPrompt from 'lightning/prompt';

import Id from '@salesforce/user/Id'; //this scoped module imports the current user ID 
import Name from '@salesforce/schema/User.Name'; //this scoped module imports the current user full name
import RoleName from '@salesforce/schema/User.UserRole.Name'; //this scoped module imports the current user role name
import ProfileName from '@salesforce/schema/User.Profile.Name'; //this scoped module imports the current user profile name
import ManagerName from '@salesforce/schema/User.Manager.Name';

const fields = [
    COMPETITION,
    COMPETITION_ID
];

export default class LwcDeleteCompetition extends NavigationMixin(LightningElement) {
    @api recordId;
    competition;
    error;
    userId = Id;
    userName;
    userRoleName;
    userProfileName;
    userManagerName;
    reasonForDeletion ='';
    competitionName;

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

    @wire(getRecord, { recordId: '$recordId', fields:fields})
    competitiveDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Name.value != null) {
                this.competitionName = data.fields.Name.value;
            }
        }
    }

    @api invoke() {
        //if (this.userProfileName === 'System Administrator') {
            const result = LightningConfirm.open({
                message: 'Are you sure you want to permanently delete this competition ?',
                //variant: 'headerless',
                label: 'Delete Competition',
                defaultValue: 'initial input value',
                // setting theme would have no effect
            }).then((result) => {
                console.log('Result: ' + result);
                if (result) {
                    removeRelation({ recordIdToDelete: recordIdToDelete })
                        .then(result => {
                            if (result) {
                                this.handleLoad();
                                this.showToast('Success', 'Related Competitions deleted', 'Success', 'dismissable');
                            }
                        })
                        .catch(error => {
                            this.error = error;
                        });
                }
            });
        } /*else { 
            const result = LightningPrompt.open({
                message: 'Are you sure you want to permanently delete this competition?',
                theme: 'warning',
                label: 'Requesting to delete the competition',
                variant: 'header',
                message: 'Reason for delete.',
                defaultValue: '',
            }).then((result) => {
                console.log('Result: ' + result);
                if (result != null) {
                    createRisRequestRecord({
                        competitionId: this.recordId,
                        competitionName: this.competitionName,
                        descriptionText: result,
                        userName: this.userName
                    })
                        .then(resultRisRequest => {
                            console.log('resultRisRequest: ' + resultRisRequest);
                            if (resultRisRequest) {
                                console.log('resultRisRequest: ' + resultRisRequest);
                                //this.showToast('Success', 'Related Competitions deleted', 'Success', 'dismissable');
                            }
                        })
                        .catch(error => {
                            console.log('resultRisRequest:error ' + error);
                            this.error = error;
                        });
                }
                //Prompt has been closed
                //result is input text if OK clicked
                //and null if cancel was clicked
            });
        }
    }*/

}