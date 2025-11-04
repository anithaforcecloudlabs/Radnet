import movePhysiciansToLocation from '@salesforce/apex/RelatedContactController.movePhysiciansToLocation';
import getRelatedRisRequests from '@salesforce/apex/RelatedContactController.getRelatedRisRequests';

const handleAcrsToMove_helper3 = async (parentCmp) => {
	if (parentCmp.moveACRList.length) {
		const filterAcrs = parentCmp.contacts.filter(item =>
			parentCmp.moveACRList.includes(item.Id)
		);
		parentCmp.moveAcrsTable = JSON.parse(JSON.stringify(filterAcrs));
	} else {
		parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
	}
};

const handleToMove_helper3 = async (parentCmp) => {
	if (!parentCmp.moveACRList.length) {
		parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
		parentCmp.isShowMoveModal = false;
		return;
	}
	if (!parentCmp.moveToAccount) {
		parentCmp.showToast('Please select Future practice location', 'Please select Future practice location', 'warning', 'dismissable');
		return;
	}

	let sendData = [];
	const getPrhysicianUpdates = parentCmp.moveAcrsTable || [];
	if (getPrhysicianUpdates.length) {
		getPrhysicianUpdates.forEach(item => {
			const risrequest = {
				AcrId__c: item.Id,
				Physician__c: item.ContactId,
				Contact_Phone__c: item.Phone__c,
				PAP__c: item.PAP__c,
				Contact_Fax__c: item.FAX__c,
				Email_Reports_New__c: item.Email_Reports__c || '',
				Image_Preference_Notes__c: item.Image_Preference_Notes__c || '',
				Preferred_Reader__c: item.Preferred_Reader__c || ''
			};

			if (Array.isArray(parentCmp.physiciansMoveUpdates)) {
				const update = parentCmp.physiciansMoveUpdates.find(el => el.Id === item.Id);
				if (update) {
					risrequest.Contact_Phone_New__c = update.Phone__c || '';
					risrequest.PAP_New__c = update.PAP__c || '';
					risrequest.Contact_Fax_New__c = update.FAX__c || '';
					risrequest.Email_Reports_New__c = update.Email_Reports__c || '';
					risrequest.Preferred_Reader_New__c = update.Preferred_Reader__c || '';
				}
			}
			sendData.push(risrequest);
		});
	}

	const resetMoveState = () => {
		parentCmp.moveACRList = [];
		parentCmp.moveToAccount = "";
		parentCmp.selectedRecordName = "";
		parentCmp.isValueSelected = false;
		parentCmp.searchString = '';
		parentCmp.physiciansMoveUpdates = [];
		parentCmp.showMoveConfirm = false;
		parentCmp.isShowMoveModal = false;
		const datatable = parentCmp.template.querySelector('lightning-datatable');
		if (datatable) datatable.selectedRows = [];
	};

	if (!parentCmp.isRisDataManager) {
		try {
			const data = await getRelatedRisRequests({
				accountId: parentCmp.recordId,
				moveToAccount: parentCmp.moveToAccount,
				selectedACRs: parentCmp.moveACRList,
				risRequestUpdates: sendData
			});
			if (data && Object.keys(data).length) {
				const arrayExists = data.exist || [];
				const arrayNew = data.new || [];
				if (arrayExists.length) {
					const messages = buildRisMessages(arrayExists, parentCmp.a_Record_URL);
					messages.forEach(mess => {
						const messageString = `A similar RIS request has been submitted. Please review. ${mess.label} for Physicians: ${mess.Physicians} !`;
						parentCmp.showToast('Warning', messageString, 'warning', 'dismissable');
					});
				}
				if (arrayNew.length) {
					const messages = buildRisMessages(arrayNew, parentCmp.a_Record_URL);
					messages.forEach(mess => {
						parentCmp.showToast('Success', `${mess.label} Moving Physicians RIS Request was created for Physicians ${mess.Physicians}`, 'success', 'dismissable');
					});
				}
			}
		} catch (error) {
			parentCmp.error = error;
			parentCmp.showToast('Error', error.body?.message || error.message, 'error', 'dismissable');
		} finally {
			resetMoveState();
		}
	} else {
		try {
			await movePhysiciansToLocation({
				accountId: parentCmp.recordId,
				moveToAccount: parentCmp.moveToAccount,
				selectedACRs: parentCmp.moveACRList,
				risRequestUpdates: sendData
			});
			parentCmp.showToast('Success', `Physicians moved to ${parentCmp.selectedRecordName}`, 'success', 'dismissable');
		} catch (error) {
			parentCmp.error = error;
			parentCmp.showToast('Error', error.body?.message || error.message, 'error', 'dismissable');
		} finally {
			resetMoveState();
		}
	}
};

const buildRisMessages = (records, baseUrl) => {
	return records.map(recordArr => {
		const first = recordArr[0];
		return {
			url: `${baseUrl}/lightning/r/RIS_Requests__c/${first.RIS_Request__c}/view`,
			label: first.RIS_Request__r.Name,
			Physicians: recordArr.map(r => r.Physician__r.Name).join(', ')
		};
	});
}
export { handleAcrsToMove_helper3, handleToMove_helper3 };