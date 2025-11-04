import getContacts from '@salesforce/apex/RelatedContactController.getContacts';
import createCaseRecord from '@salesforce/apex/RelatedContactController.createCaseRecord';

const handleRelatedContacts_helper1 = async (parentCmp) => {
	try {
		const data = await getContacts({ recordId: parentCmp.recordId });
		let resp = Array.isArray(data)
			? data.map(item => ({
				...item,
				contactName: item.Contact?.Name,
				contactBudgetSpent: item.Contact?.Budget_Spent__c,
				contactLink: `${parentCmp.a_Record_URL}/lightning/r/Contact/${item.ContactId}/view`,
				physicianNPI: item.Contact?.Physician_NPI__c,
				imagePreference: item.Contact?.Image_Preference_Notes__c,
				physicianPAP: item.Contact?.PAP__c
			}))
			: [];
		parentCmp.contacts = resp;
		parentCmp.showComp = true;
		parentCmp.contactLabel = `Physicians (${resp.length})`;
	} catch (error) {
		parentCmp.error = error;
	}
};

const handleSave_helper1 = async (parentCmp) => {
	try {
		const getPhysicianUpdates = parentCmp.physiciansUpdates || [];
		const getPhysicianUpdatesList = getPhysicianUpdates.map(item => {
			const descriptions = [];
			if (item.Phone__c) descriptions.push(`Contact Phone : ${item.Phone__c}`);
			if (item.FAX__c) descriptions.push(`Contact FAX : ${item.FAX__c}`);
			if (item.PAP__c) descriptions.push(`PAP : ${item.PAP__c}`);
			if (item.EMR__c) descriptions.push(`EMR : ${item.EMR__c}`);
			if (item.Mail_Reports__c) descriptions.push(`Mail Reports : ${item.Mail_Reports__c}`);
			if (item.Fax_Reports__c) descriptions.push(`Fax Reports : ${item.Fax_Reports__c}`);
			if (item.Email_Reports__c) descriptions.push(`Email Reports : ${item.Email_Reports__c}`);
			if (item.Preferred_Reader__c) descriptions.push(`Preferred Reader : ${item.Preferred_Reader__c}`);
			if (item.Contact_Email__c) descriptions.push(`Contact Email : ${item.Contact_Email__c}`);
			return { key: item.Id, value: descriptions };
		});

		parentCmp.relatedRisUpdates = getPhysicianUpdates.map(item => ({
			AcrId__c: item.Id,
			Contact_Phone_New__c: item.Phone__c || '',
			PAP_New__c: item.PAP__c || '',
			Contact_Fax_New__c: item.FAX__c || '',
			Email_Reports_New__c: item.Email_Reports__c || '',
			Preferred_Reader_New__c: item.Preferred_Reader__c || '',
			Contact_Email_New__c: item.Contact_Email__c || ''
		}));

		const data = await createCaseRecord({
			accountId: parentCmp.recordId,
			getPhysicianUpdates: JSON.stringify(getPhysicianUpdatesList),
			risRequestUpdates: parentCmp.relatedRisUpdates
		});
		parentCmp.caseNumber = data.Name;
		parentCmp.showToast('Success', `Contacts updated. RIS Request was created ${parentCmp.caseNumber}`, 'success', 'dismissable');
	} catch (error) {
		parentCmp.error = error;
	}
};

export {
	handleRelatedContacts_helper1,
	handleSave_helper1
}