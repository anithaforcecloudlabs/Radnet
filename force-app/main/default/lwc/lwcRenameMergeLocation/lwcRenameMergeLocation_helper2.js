import getAccountsForUpdate from '@salesforce/apex/RelatedAccountsAPX.getAccountsForUpdate';
import mergeAcrs from '@salesforce/apex/RelatedAccountsAPX.mergeAcrs';
import getRelatedRisRequests from '@salesforce/apex/LwcRenamePracticeLocationController.getRelatedRisRequests';

const getAccountsForMerge_helper2 = async (parentCmp) => {
	if (!parentCmp.messageProfileUsers) {
		getAccountsForUpdate({
			accounIds: parentCmp.selectedAccountIds
		}).then((result) => {
			let resultObj = JSON.parse(JSON.stringify(result));
			if (parentCmp.messageProfileUsers) {
				parentCmp.showErrorMessage = true;
				parentCmp.countMergeRecords = false;
				parentCmp.isShowMergeModal = false;
			} else {
				if (resultObj.length == 2 || resultObj.length == 3) {
					validateRecordType(resultObj);
					if (parentCmp.messageRecordTypesRecords) {
						parentCmp.showErrorMessage = true;
						parentCmp.countMergeRecords = false;
						parentCmp.isShowMergeModal = false;
					} else {
						resultObj.forEach(item => {
							item['accountMergeName'] = item['Name'];
							item['id'] = item['Id'];
							item['ownerName'] = item.Owner.Name;
							item['id'] = item['Id'];
							if (item.ShippingAddress) {
								let postal = (item.ShippingAddress.postalCode === 'undefined' || item.ShippingAddress.postalCode === 'null' || !item.ShippingAddress.postalCode) ? '' : item.ShippingAddress.postalCode;
								let street = (item.ShippingAddress.street === 'null' || !item.ShippingAddress.street) ? '' : item.ShippingAddress.street;
								let city = (item.ShippingAddress.city === 'null' || !item.ShippingAddress.city) ? '' : item.ShippingAddress.city;
								let state = (item.ShippingAddress.state === 'null' || !item.ShippingAddress.state) ? '' : item.ShippingAddress.state;
								let country = (item.ShippingAddress.country === 'null' || !item.ShippingAddress.country) ? '' : item.ShippingAddress.country;

								item['address'] = street + ', ' + city + ', ' + state + ', ' + postal + ', ' + country;
							}
							item['owner'] = item.Owner.Name;
							item['phoneNumber'] = item['Phone'];
							item['faxNumber'] = item['Fax'];
						});

						resultObj.forEach(x => {
							parentCmp.arrName.push({ label: x.accountMergeName, value: x.accountMergeName });
							parentCmp.arrAddress.push({ label: x.address, value: x.address });
							parentCmp.arrOwner.push({ label: x.owner, value: x.owner });
							parentCmp.arrAccountIds.push(x.Id);
							if (String(x.phoneNumber) === 'undefined') {
								parentCmp.arrPhoneExist = false;
								parentCmp.arrPhone.push({ label: 'unknown', value: 'unknown' });
							} else {
								parentCmp.arrPhoneExist = true;
								parentCmp.arrPhone.push({ label: String(x.phoneNumber), value: String(x.phoneNumber) });
							}

							if (String(x.faxNumber) === 'undefined') {
								parentCmp.arrFaxExist = false;
								parentCmp.arrFax.push({ label: 'unknown', value: 'unknown' });
							} else {
								parentCmp.arrFaxExist = true;
								parentCmp.arrFax.push({ label: String(x.faxNumber), value: String(x.faxNumber) });
							}
						})
						parentCmp.isShowMergeModal = true;

					}
				} else {
					parentCmp.showErrorMessage = true;
					parentCmp.countMergeRecords = true;
					parentCmp.isShowMergeModal = false;
				}
			}
		});
	} else {
		console.log('errror');
	}
}

const handleMergeSubmit_helper2 = async (parentCmp) => {
	validRequired_helper2(parentCmp);
	let noteMerge = 'Name: ' + parentCmp.nameValue + '\n' + 'Address: ' + parentCmp.addressValue + '\n' + 'Owner: ' + parentCmp.ownerValue;
	noteMerge = (parentCmp.phoneValue) ? noteMerge + '\n' + 'Phone: ' + parentCmp.phoneValue : noteMerge;
	noteMerge = (parentCmp.faxValue) ? noteMerge + '\n' + 'Fax: ' + parentCmp.faxValue : noteMerge;
	noteMerge = (parentCmp.textCommentValue) ? noteMerge + '\n' + 'Comment: ' + parentCmp.textCommentValue : noteMerge;
	parentCmp.isShowMergeModal = false;
	parentCmp.messageExistsData = [];
	try {
		let checkDuplicates = await getRelatedRisRequests({
			selectedAccountIds: parentCmp.arrAccountIds,
			risRequestType: 'Merge Request'
		})
		let parseResult = JSON.parse(JSON.stringify(checkDuplicates));

		if (parseResult && parseResult.length > 0) {
			parentCmp.showSaveButton = false;
			parseResult.forEach(item => {
				let mess = {};
				let accountArray = [];
				mess.url = parentCmp.a_Record_URL + '/lightning/r/RIS_Requests__c/' + item['Id'] + '/view',
				mess.label = item['Name'];
				accountArray = [...accountArray, item.Account_Name__r.Name];
				mess.Locations = accountArray.join(', ');
				parentCmp.messageExistsData.push(mess);
				parentCmp.messageResults = 'There is already a pending RIS request for merge that is open.';
				parentCmp.messageString = 'A similar RIS request has been submitted.  Please review';
				parentCmp.showMessage = true;				
				parentCmp.isNewPracticeName = false;
				parentCmp.isSaveNewPractice = false;
				parentCmp.isCreateNewPractice = false;
			});
		} else {
			parentCmp.messageResults = 'RIS request for merge was opened';
			parentCmp.showMessage = true;
			parentCmp.isNewPracticeName = false;
			parentCmp.isSaveNewPractice = false;
			parentCmp.isCreateNewPractice = false;
			parentCmp.showSaveButton = false;
			let updateAccount = await mergeAcrs({
				accountIds: parentCmp.arrAccountIds,
				noteMerge: noteMerge
			});
			if (updateAccount) {
				let message = 'New Request Type was created ' + updateAccount.fields.Name.value + '!';
				console.log('updateAccount ', updateAccount);
				console.log('message ', message);
				parentCmp.showToast('Success', message, 'success', 'dismissable');
				parentCmp.closeModal();
			}
		}
		
	} catch (e) {
		// deal with any errors
	}
}

const validRequired_helper2 = async (parentCmp) => {
	if (parentCmp.nameValue && parentCmp.addressValue && parentCmp.ownerValue) {
		parentCmp.showSaveButton = true;
		parentCmp.showRename = true;
	};
}


const validateRecordType = async (resultObj) => {
	resultObj.find(item => {
		if (item.RecordType.DeveloperName !== 'Practice_Location') {
			parentCmp.messageRecordTypesRecords = true;
		}
	})
}
export { getAccountsForMerge_helper2, handleMergeSubmit_helper2, validRequired_helper2 }