import { create_RIS_Request_helper2 } from './relatedAccounts_helper2';
import { deleteRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';

const datatableRecSelectorValidation_helper5 = async(cmp)=>{
	let dataTableCmp = cmp.template.querySelector('lightning-datatable');
	if(dataTableCmp){
		console.log(`dataTableCmp.selectedRows = ${dataTableCmp.selectedRows}`);
		if(dataTableCmp.selectedRows && dataTableCmp.selectedRows.length>0){
			console.log(`dataTableCmp.selectedRows = ${JSON.stringify(dataTableCmp.selectedRows)}`);
			return dataTableCmp.selectedRows;
		}
		else{
			cmp.showToast(`Error!!`,`Please select at least one account.`,`error`,`dismissible`);
		}
	}
	return null;
};


const createRISReqOnPhysRemove_helper5 = async(cmp)=>{
	let listSelectedDatatableKeys = await datatableRecSelectorValidation_helper5(cmp);
	let listSelectedObjs = [];

	if (cmp.isRisRequestManager) {
		(listSelectedDatatableKeys || []).forEach(async (recordId) => {
			await deleteRecord(recordId);
		});

		if (listSelectedDatatableKeys && listSelectedDatatableKeys.length > 1) {
			cmp.showToast(`Success`,`Records were removed! `,`success`,`dismissible`);
		} else {
			cmp.showToast(`Success`,`Record was removed! `,`success`,`dismissible`);
		}
		
		window.location.reload();

	} else if (listSelectedDatatableKeys && listSelectedDatatableKeys.length > 0) {
		await Promise.all(listSelectedDatatableKeys.map(async selectedId => {
			if (cmp.accountObjData && cmp.accountObjData.length>0){
				let listFilteredRecs = cmp.accountObjData.filter(accObjRec=>accObjRec.Id == selectedId);

				if (listFilteredRecs && listFilteredRecs.length > 0) {
					listFilteredRecs[0]['Remove_Physician'] = true;
					listFilteredRecs[0]['Type'] = 'Physician Removed';
					listFilteredRecs[0]['Subject'] = 'Removing a Physician from a location';
					listFilteredRecs[0]['Loc_Description'] = 'Physician(s) were removed from ';
					listSelectedObjs = [...listSelectedObjs, listFilteredRecs[0]];
				}
			}
		}));

		await create_RIS_Request_helper2(cmp, listSelectedObjs, true);
	}
};

export{createRISReqOnPhysRemove_helper5,datatableRecSelectorValidation_helper5};