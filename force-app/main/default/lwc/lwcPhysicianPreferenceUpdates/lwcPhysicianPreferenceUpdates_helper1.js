import getPhysicianPreferenceUpdates from '@salesforce/apex/lwcPhysicianPreferenceUpdatesAPX.getPhysicianPreferenceUpdates';
import getAcrsForUpdate from '@salesforce/apex/lwcPhysicianPreferenceUpdatesAPX.approvedAcrUpdates';

const getPhysicianPreferenceUpdates_helper1 = async (parentCmp) => {
	getPhysicianPreferenceUpdates({
		risRequestId: parentCmp.recordId
	}).then((data) => {
		parentCmp.hasPhysicianUpdates = true;
		parentCmp.physicianUpdatesObjectData = JSON.parse(JSON.stringify(data));
		let resp = data.filter(f => f.Physician__r?.Name).map(item => {
			return {
				...item,
				contactLink: parentCmp.a_Record_URL + '/lightning/r/Contact/' + item['Physician__c'] + '/view',
				physicianName: item.Physician__r?.Name || null,
				recordName: item['Name'],
				recordDetail: parentCmp.a_Record_URL + '/lightning/r/Related_Request__c/' + item['Id'] + '/view',
				physicianNPI: item.Physician__r?.Physician_NPI__c
			}
		});
		parentCmp.physicianUpdatesData = resp;
		parentCmp.physicianUpdatesLabel = 'Physician Preference updates (' + parentCmp.physicianUpdatesData.length + ')';
		parentCmp.showComp = true;
		parentCmp.showViewAll = (parentCmp.physicianUpdatesData.length> 0) ? true : false;
	}).catch(error => {
		parentCmp.error = error;
	});
}

const handleApprove_helper1 = async (parentCmp) => { 
	if (parentCmp.selectedRelatedRequestIds.length) {
		const relatedRisRequest = parentCmp.physicianUpdatesObjectData.filter(item => parentCmp.selectedRelatedRequestIds.includes(item.Id));
		getAcrsForUpdate({
			relatedRisRequests : relatedRisRequest,
			status: 'Approve'
		})
		.then((result) => {   
			parentCmp.showComp = true;
			parentCmp.relatedRisRequestApproved = result;
			parentCmp.showToast('Success', 'Physicians updated', 'Success', 'dismissable');
		}).catch(error => {
			parentCmp.showToast(
				'Error Approve', 
				error.body.pageErrors[0].statusCode + ' : ' + error.body.pageErrors[0].message,
				'Error', 
				'dismissable'
			);
		}).finally(() => {
			console.log('finally ');  
			parentCmp.handleLoad();		 
			parentCmp.selectedRelatedRequestIds = [];
			parentCmp.setSelectedRows=[];
			parentCmp.template.querySelector('lightning-datatable').selectedRows = [];
		});
	} else {
		parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
		parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
	}
	parentCmp.createdRecord = true;
	
}
const handleReject_helper1 = async (parentCmp) => {
	if (parentCmp.selectedRelatedRequestIds.length) {
		const relatedRisRequest = parentCmp.physicianUpdatesObjectData.filter(item => parentCmp.selectedRelatedRequestIds.includes(item.Id));
		getAcrsForUpdate({
			relatedRisRequests : relatedRisRequest,
			status: 'Reject'
		})
		.then((result) => {   
			parentCmp.showComp = true;
			parentCmp.relatedRisRequestApproved = result;
			parentCmp.showToast('Success', 'Physicians updated', 'Success', 'dismissable');
		}).catch(error => {
			parentCmp.showToast(
				'Error Reject', 
				error.body,
				'Error', 
				'dismissable');
		}).finally(() => {
			parentCmp.handleLoad();		 
			parentCmp.selectedRelatedRequestIds = [];
			parentCmp.setSelectedRows=[];
			parentCmp.template.querySelector('lightning-datatable').selectedRows = [];
		});
	} else {
		//parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
		parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
	}
	parentCmp.createdRecord = true;
	
}

export {getPhysicianPreferenceUpdates_helper1,handleApprove_helper1, handleReject_helper1}