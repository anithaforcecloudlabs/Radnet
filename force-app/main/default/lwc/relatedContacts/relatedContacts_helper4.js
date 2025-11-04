import createRisRequestImageNotes from '@salesforce/apex/RelatedContactController.createRisRequestImageNotes';

const handleSaveEditNotes_helper4 = async (parentCmp) => { 
	let listSelectedObjs = []
	let listInputNotesFields = [... parentCmp.template.querySelectorAll(`lightning-textarea[data-id="editnotes"]`)]
	if(listInputNotesFields && listInputNotesFields.length>0){
		for(let inputNote of listInputNotesFields) {
			let listFilteredRecs = parentCmp.selectedEditNotesList.find(contactRecord=>contactRecord.Id == inputNote.dataset.contactId);
			let previousNotevalue = (listFilteredRecs.Image_Preference_Notes__c) ? listFilteredRecs.Image_Preference_Notes__c : '';
			let risRequesrObj = {};
			let setNewIpNotes = (inputNote.value) ? inputNote.value : '[Please erase IP notes in RIS]';
			risRequesrObj['ContactId__c'] = inputNote.dataset.contactId;
			risRequesrObj['Status__c'] = 'New';
			risRequesrObj['Type__c'] = 'Image preference notes';
			risRequesrObj['Subject__c'] = 'Image preference notes';
			risRequesrObj['Description__c'] = `Previous IP Notes: <b>${previousNotevalue}</b><br/> New IP Notes Requested: <b>${setNewIpNotes} </b>`;
			risRequesrObj['New_Image_Preference_Notes__c'] = inputNote.value;
			risRequesrObj['Date_Time_opened__c'] = new Date().toISOString();
			listSelectedObjs = [...listSelectedObjs, risRequesrObj];
		}
	}

	try {
		await createRisRequestImageNotes({ createRisRequestList: listSelectedObjs });
		parentCmp.isShowEditNotes = false;
		parentCmp.selectedContactIds = [];
		parentCmp.showToast('Success', 'Contacts were updated', 'success', 'dismissable');
		clearDatatableSelection(parentCmp);
	} catch (error) {
		parentCmp.isShowEditNotes = false;
		parentCmp.showToast('Error updating', error.body?.message || error.message, 'error', 'dismissable');
	} finally {
		clearDatatableSelection(parentCmp);
	}
}

const clearDatatableSelection = async (parentCmp) => { 
	const datatable = parentCmp.template.querySelector('lightning-datatable');
	if (datatable) datatable.setSelectedRows = [];
}

export {handleSaveEditNotes_helper4}