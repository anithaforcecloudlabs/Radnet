import getRenamedRelatedRisRequests from '@salesforce/apex/LwcRenamePracticeLocationController.getRelatedRisRequests';

const handleRenameAccounts_helper3 = async (parentCmp) => {
	let checkedAccountIds = [];
	checkedAccountIds.push(parentCmp.recordId, parentCmp.selectedPracticeOverviewId);
	parentCmp.messageExistsData = [];
	let checkDuplicates = await getRenamedRelatedRisRequests({
		selectedAccountIds: checkedAccountIds,
		risRequestType: 'Renaming an account'
	})
	let parseResult = JSON.parse(JSON.stringify(checkDuplicates));

	if (parseResult && parseResult.length > 0) {
		parentCmp.showSaveButton = false;
		parentCmp.showRenameProcess = false;
		parseResult.forEach(item => {
			let mess = {};
			let accountArray = [];
			mess.url = parentCmp.a_Record_URL + '/lightning/r/RIS_Requests__c/' + item['Id'] + '/view',
			mess.label = item['Name'];
			accountArray = [...accountArray, item.Account_Name__r.Name];
			mess.Locations = accountArray.join(', ');
			parentCmp.messageExistsData.push(mess);
			parentCmp.messageResults = 'There is already a pending RIS request for rename that is open';
			parentCmp.messageString = 'A similar RIS request has been submitted.  Please review';
			parentCmp.showMessage = true;
			parentCmp.isNewPracticeName = false;
			parentCmp.isSaveNewPractice = false;
			parentCmp.isCreateNewPractice = false;
			parentCmp.showRename = true;
		});
	} else {
		parentCmp.messageResults = 'RIS request for rename was opened';
		parentCmp.showMessage = true;
		parentCmp.isNewPracticeName = false;
		parentCmp.isSaveNewPractice = false;
		parentCmp.isCreateNewPractice = false;
		parentCmp.showRename = true;
		await parentCmp.updateAccount();
	}
}

export { handleRenameAccounts_helper3 }