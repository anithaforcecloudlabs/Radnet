import getContactsForRename from '@salesforce/apex/RelatedContactController.getContactsForRename';
import removeContactRelation from '@salesforce/apex/RelatedContactController.removeContactRelation';
import getACRContactsForRemove from '@salesforce/apex/RelatedContactController.getACRContactsForRemove';
import updateRemoveComment from '@salesforce/apex/RelatedContactController.updateRemoveComment';
import createRISRequestOnACRRemove from '@salesforce/apex/RelatedContactController.createRISRequestOnACRRemove';
import checkExistsRisRequest from '@salesforce/apex/RelatedContactController.checkExistsRisRequest';

import { handleRelatedContacts_helper1 } from './relatedContacts_helper1';

const handleRenameContacts_helper2 = async (parentCmp) => { 
	if (parentCmp.selectedContactIds.length) {
		parentCmp.isShowFormModal = true;
		getContactsForRename({
			contactIds: parentCmp.selectedContactIds
		})
		.then((result) => {
			parentCmp.showComp = true;
			parentCmp.selectedRenameList = result;
		});
	} else {
		parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
		parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
	}
}

const handleSaveRename_helper2 = async (parentCmp) =>{
	let isVal = true;   
	parentCmp.template.querySelectorAll('lightning-input-field').forEach(element => {
		isVal = isVal && element.reportValidity();
	});
	parentCmp.showComp = false;
	if (isVal) {
		try {
			parentCmp.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
				element.submit();
			});
			parentCmp.showToast('Success', 'Contacts was updated', 'Success', 'dismissable');
		} catch (error) {
			parentCmp.showToast('Error with renaming', 'It not possible rename physicians', 'Error', 'dismissable');
		}
		
		parentCmp.closeModal();
		parentCmp.selectedRenameList = [];
		parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
		parentCmp.handleLoadContacts();
	} else { 
		parentCmp.showToast('Error while updating or refreshing records','Record name is not updateble', 'Error', 'dismissable');
	}
}
const handleContactsForRemove_helper2 = async (parentCmp) =>{
	if (parentCmp.removeList.length) {
		getACRContactsForRemove({
			contactRelations: parentCmp.removeList
		})
		.then((result) => {
			parentCmp.removePhysList = result;
		})
		.catch(error => {
			parentCmp.showToast('Error updating or refreshing records', error.body.message, 'Error', 'dismissable');
			parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
		}).finally(() => {
			parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
		});
	} else {
		parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
		parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
	}
}
const handleRemove_helper2 = async (parentCmp) => {
	if (parentCmp.physRemoveData) { 
		updateRemoveComment({			
			listPhysic : parentCmp.physRemoveData
		}).then((result) => { 
			console.log(result);
		})
	};

	if (parentCmp.removeList.length) {
		if (parentCmp.isRisDataManager) {
			removeContactRelation({
				contactRelations: parentCmp.removeList,
				recordId: parentCmp.recordId
			})
			.then((result) => {
				parentCmp.contacts = result;
				parentCmp.isShowRemoveModal = false;
				parentCmp.showToast('Success', 'Contacts removed', 'Success', 'dismissable');
				handleRelatedContacts_helper1(parentCmp);
			})
			.catch(error => {
				parentCmp.isShowRemoveModal = false;
				parentCmp.showToast('Error updating or refreshing records', error.body.message, 'Error', 'dismissable');
				parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
			}).finally(() => { 
				parentCmp.isShowRemoveModal = false;
				handleRelatedContacts_helper1(parentCmp);
				parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
			});
		} else {
			const acrIds = parentCmp.removeList || [];
			const accountId = parentCmp.recordId;
			const physRemoveData = parentCmp.physRemoveData;
			let removeInfos;

			if (physRemoveData && physRemoveData.length) {
				removeInfos = physRemoveData.map(item => ({
					contactId: item.phyAccId,
					comment: item.phyComment,
					reason: item.phyReason
				}));
			}
			checkExistsRisRequest({accountId, acrIds, removeInfos})
			.then((result) => {
				if (result && result != []) {
					let parseData = JSON.parse(JSON.stringify(result));
					parentCmp.messageData = [];
					parentCmp.messageNewData = [];
					let arrayExists = [];
					let arrayNew = [];
					for (let key in parseData) {
						if (key === 'exist') {
							arrayExists = parseData[key];
						}
						if (key === 'new') {
							arrayNew = parseData[key];
						}
					}
					if (arrayExists != []) {
						parentCmp.existShow = true;
						let getExistRecords =  JSON.parse(JSON.stringify(arrayExists));
						for (let key in getExistRecords) {
							let mess = {};
							let physArr = [];
							mess.url = parentCmp.a_Record_URL + '/lightning/r/RIS_Requests__c/' + getExistRecords[key][0].RIS_Request__c + '/view',
							mess.label = getExistRecords[key][0].RIS_Request__r.Name;
							for (let item in getExistRecords[key]) {
								physArr = [...physArr, getExistRecords[key][item].Physician__r.Name];
							}						   
							mess.Physicians = physArr.join(', ');
							parentCmp.messageData.push(mess);
						}
					}

					if (arrayNew != []) {
						parentCmp.newShow = true;
						let getExistRecords =  JSON.parse(JSON.stringify(arrayNew));
						for (let key in getExistRecords) {
							let mess = {};
							let physArr =[];
							mess.url = parentCmp.a_Record_URL + '/lightning/r/RIS_Requests__c/' + getExistRecords[key][0].RIS_Request__c + '/view',
							mess.label = getExistRecords[key][0].RIS_Request__r.Name;
							for (let item in getExistRecords[key]) {
								physArr = [...physArr, getExistRecords[key][item].Physician__r.Name];
							}
						   
							mess.Physicians = physArr.join(', ');
							parentCmp.messageNewData.push(mess);
						}
					}
					parentCmp.isShowExistRisRequestModal = true;
				}
			}).finally(() => {
					parentCmp.isShowRemoveModal = false;
					handleRelatedContacts_helper1(parentCmp);
					parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
			});

		  /* createRISRequestOnACRRemove({accountId, acrIds, removeInfos}).then(() => {
				parentCmp.showToast('Success', 'Physicians were removed', 'success', 'dismissable');
		   }).finally(() => {
				parentCmp.isShowRemoveModal = false;
				handleRelatedContacts_helper1(parentCmp);
				parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
		   });*/
		}
	} else {
		parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
		parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
	}
}

export {handleRenameContacts_helper2, handleSaveRename_helper2, handleContactsForRemove_helper2, handleRemove_helper2};