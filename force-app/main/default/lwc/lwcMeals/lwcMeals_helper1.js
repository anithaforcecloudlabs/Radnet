import getContacts from '@salesforce/apex/lwcMealsCls.getContacts';
import getObjectValues from '@salesforce/apex/lwcMealsCls.getPicklistValues';
import saveTask from '@salesforce/apex/lwcMealsCls.saveTask';
import updateBudgetContacts from '@salesforce/apex/lwcMealsCls.updateBudgetContacts';
//import getMealsContactsSnowflack from '@salesforce/apex/lwcMealsCls.getMealsContactsSnowflackAPX';

const getRelatedContacts_helper1 = async (parentCmp) => { 
    parentCmp.handleIsLoading(true);
    getContacts({
        recordId: parentCmp.recordId
    }).then((data) => {        
        parentCmp.showComp = false;
        parentCmp.contactOptions = data;
        let resp = JSON.parse(JSON.stringify(data));
        resp.forEach(item => {
            parentCmp.handleIsLoading(false);
            item['contactId'] = item.Contact.Id;
            item['contactName'] = item.Contact.Name;            
            item['budgetLeft'] = (item.Contact.Remaining_Budget__c) ? item.Contact.Remaining_Budget__c : 0;
            item['budgetLeftMessage'] = (item.Contact.Remaining_Budget__c) ? item.Contact.Remaining_Budget__c  + ' left' : 'none';
            item['budgetSpent'] = (item.Contact.Budget_Spent__c) ? item.Contact.Budget_Spent__c : 0;
            item['budgetLimit'] = (item.Contact.Allocated_Budget__c) ? item.Contact.Allocated_Budget__c : 0;
            item['budgetAddToSum'] = 0;
            item['budgetErrorSum'] = '';
            item['budgetErrorShow'] = false
            item['disabledAttr'] = (item.Contact.Budget_Spent__c  >= item.Contact.Allocated_Budget__c ) ? true : false;   

        });
        parentCmp.contactOptions = resp;
        parentCmp.contactsData = resp;
        //console.log( 'p', parentCmp.contactOptions);
        //console.log( 'contactsData', JSON.stringify(parentCmp.contactsData));
    }).catch(error => {
        parentCmp.error = error;
        //parentCmp.handleIsLoading(false);
    });
}
const getObjectivesValues_helper1 = async (parentCmp) => { 
    parentCmp.handleIsLoading(true);
    getObjectValues().then((data) => {
        parentCmp.handleIsLoading(false);      
        let resp = JSON.parse(JSON.stringify(data));
        resp.forEach(item => {
            item['label'] = item.label;
            item['value'] = item.value;           
        });
        parentCmp.objectiveOptions = resp;
    }).catch(error => {
        parentCmp.error = error;
    });
}

const createTask_helper1 = async (parentCmp) => { 
    parentCmp.handleIsLoading(true);
    let moveToNextStep = false;
    //let spentBudgetCost = parentCmp.budjetSpentValue / parentCmp.selectedContacts.length;
    let createdTask = isToday(new Date(parentCmp.taskDateValue));
    parentCmp.costLabel = (createdTask) ? 'Cost' : 'Estimated cost';
    let createTask = {};
        createTask.Call_Type__c = parentCmp.callTypeValue;
        createTask.Objective__c = parentCmp.selectedObjectives;
        createTask.WhatId = parentCmp.recordId;        
        createTask.Cost__c = parentCmp.budjetSpentValue;
        createTask.Other_Contact__c = parentCmp.otherContact;
        createTask.Description = parentCmp.taskCommentValue;
        createTask.ActivityDate = parentCmp.taskDateValue;
        createTask.Subject = 'Meals';
        createTask.Status = 'Open';
        createTask.WhoCount = parentCmp.selectedContacts.length;
        console.log('createTask ', createTask);
    saveTask({
        recordId: createTask, whoIdsList : parentCmp.selectedContacts, estimated : createdTask
    }).then((data) => {
        console.log( 'saveTask', data.Id );
        const today = new Date();
        console.log('today ', isToday( new Date(parentCmp.taskDateValue)));
        console.log('parentCmp.taskDateValue ', parentCmp.taskDateValue);
        console.log('today is today', isToday( new Date(parentCmp.taskDateValue)));
        if ( isToday( new Date(parentCmp.taskDateValue))) {
            console.log('today activity');
            let contactList = [];     
            moveToNextStep = true;
            let spentBudget = parentCmp.budjetSpentValue / parentCmp.selectedContacts.length;
            for (let index = 0; index<parentCmp.selectedContacts.length; index++ ){
                console.log('index ',  parentCmp.selectedContacts[index]);           
                let contactToUpdate ={};
                let getcurrentBudget = parentCmp.contactOptions.find(x => x.contactId == parentCmp.selectedContacts[index]).budgetSpent;
                contactToUpdate.Budget_Spent__c = getcurrentBudget + spentBudget;
                contactToUpdate.Id = parentCmp.selectedContacts[index];
                contactList.push(contactToUpdate);
            }
            updateBudgetContacts ({
                contactsToUpdate : contactList
            }).then((data) => {
                console.log( 'updateBudgetContacts', data );
                let toastCmp = parentCmp.template.querySelector(`c-lwc-toast-params`);
                    if(toastCmp){
                        toastCmp.handleInsertSuccessLogic();
                    }
                moveToNextStep = true;            
                
            }).catch(error => {
                parentCmp.error = error;
                console.log( 'updateBudgetContacts', error );
            }).finally(()=>{
                parentCmp.handleClear();
                getRelatedContacts_helper1(parentCmp);
                parentCmp.handleIsLoading(false);
                
            });
        } else {
            let toastCmp = parentCmp.template.querySelector(`c-lwc-toast-params`);
                if(toastCmp){
                    toastCmp.handleInsertSuccessLogic();
                }
            moveToNextStep = true;  
            parentCmp.handleClear();
            getRelatedContacts_helper1(parentCmp);
            parentCmp.handleIsLoading(false);
        }
     
    }).catch(errorMessage => {
        parentCmp.error = errorMessage;
        console.log( 'saveTask', errorMessage);
    });
    return moveToNextStep;
}

const isToday = (someDate) => {
    console.log('isToday someDate ', someDate);
    const today = new Date();
    console.log('isToday today ', today);
    return someDate.getDate() == today.getDate() &&
    someDate.getMonth() == today.getMonth() &&
    someDate.getFullYear() == today.getFullYear()
}

/*const getContactBudget_helper1 = async (parentCmp, taskId) => {
    console.log('taskId ', taskId);
    getMealsContactsSnowflack({
        taskId: taskId
    }).then((data) => {
        console.log(Json.stringify(data));
        console.log( 'getContactBudget_helper1 data', data );
    }).catch(error => {
        parentCmp.error = error;
        console.log( 'getContactBudget_helper1', error );
    });
}*/
export {getRelatedContacts_helper1, getObjectivesValues_helper1, createTask_helper1/*, getContactBudget_helper1*/}