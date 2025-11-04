import getAccounts from '@salesforce/apex/RelatedAccountsAPX.getAccounts';
import getAccountsForUpdate from '@salesforce/apex/RelatedAccountsAPX.getAccountsForUpdate';
import removeAccountRelation from '@salesforce/apex/RelatedAccountsAPX.removeAccountRelation';

const relatedGetAccounts_helper1 = async (parentCmp) => { 
    parentCmp.handleIsLoading(true);
    getAccounts({
        recordId: parentCmp.recordId
    }).then((data) => {        
        parentCmp.showComp = false;
        parentCmp.accountObjData = data;			
        let resp = JSON.parse(JSON.stringify(data));
        resp.forEach(item => {
            item['accountLink'] = parentCmp.a_Record_URL + '/lightning/r/Account/' + item['AccountId'] + '/view';
            item['AccountName'] = item.Account.Name;
            item['street'] = item.Account.ShippingStreet;
            item['postalCode'] = item.Account.ShippingPostalCode;
            item['AccountStreet'] = item['AccountId'];
            item['AccountPostal'] = item['AccountId'];
        });
        parentCmp.accountObjData = resp;
        parentCmp.accountLabel = 'Related Accounts (' + parentCmp.accountObjData.length + ' )';
        parentCmp.showComp = true;
        parentCmp.handleIsLoading(false);
    }).catch(error => {
        parentCmp.error = error;
    });
}
const relatedRenameAccounts_helper1 = async (parentCmp) => { 
    if (parentCmp.selectedAccounts.length) {
        parentCmp.isShowFormModal = true;
        let resp = JSON.parse(JSON.stringify(parentCmp.selectedAccounts));
        getAccountsForUpdate({
            accounIds: parentCmp.selectedAccounts
        }).then((result) => {
            parentCmp.showComp = true;
            parentCmp.selectedAccountsForRename = result;
        })
    } else {
        parentCmp.showToast('Accounts not selected', 'Please select account', 'warning', 'dismissable');
        parentCmp.setSelectedListToNull();
    }
}

const relatedSaveRenameAccounts_helper1 = async (parentCmp) => { 
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
            parentCmp.showToast('Success', parentCmp.recordId, 'Success', 'dismissable');            
            parentCmp.setSelectedListToNull();
            parentCmp.closeModal();
            relatedGetAccounts_helper1(parentCmp);
        } catch (error) {
            parentCmp.showToast('Error while updating or refreshing records', error.body.message, 'error', 'dismissable');            
            relatedGetAccounts_helper1(parentCmp);
        }
    } else {
        parentCmp.showToast('Error while updating or refreshing records','Record name is not updateble', 'error', 'dismissable');        
        parentCmp.setSelectedListToNull();
    }
}

const relatedRemove_helper1 = async (parentCmp) => { 
    if (parentCmp.listForRemove.length) {
        removeAccountRelation({
            accountRelations: parentCmp.listForRemove,
            recordId: parentCmp.recordId
        }).then((result) => {
            parentCmp.showToast('Success', result, 'Success', 'dismissable');
            parentCmp.setSelectedListToNull();
        }).catch(error => {
            setTimeout(() => {
                parentCmp.showToast('Error updating or refreshing records', error.body.message, 'Error', 'dismissable');
            }, 300);				
        }).finally(() => {
            relatedGetAccounts_helper1(parentCmp);           
            parentCmp.setSelectedListToNull();
        });
    } else {
        parentCmp.showToast('Accounts not selected', 'Please select account', 'warning', 'dismissable');
        parentCmp.setSelectedListToNull();
    }
}

const getAccountForMerge_helper1 = async (parentCmp) => {    
    getAccountsForUpdate({
        accounIds: parentCmp.selectedAccounts
    }).then((result) => {						
        let resultObj = JSON.parse(JSON.stringify(result));						
        resultObj.forEach(item => {
            item['accountMergeName'] = item['Name'];					
            item['id'] = item['Id'];
            let postal = (item.ShippingAddress.postalCode === 'null' || !item.ShippingAddress.postalCode) ? '' : item.ShippingAddress.postalCode ;
            let street = (item.ShippingAddress.street === 'null' || !item.ShippingAddress.street) ? '' : item.ShippingAddress.street ;
            let city = (item.ShippingAddress.city === 'null' || !item.ShippingAddress.city) ? '' : item.ShippingAddress.city ;
            let state = (item.ShippingAddress.state === 'null' || !item.ShippingAddress.state) ? '' : item.ShippingAddress.state ;
            let country = (item.ShippingAddress.country === 'null' || !item.ShippingAddress.country) ? '' : item.ShippingAddress.country ;

            item['address'] = street +', ' + city +', '+ state + ', ' + postal + ', ' + country;
            item['owner'] = item.Owner.Name;
            item['phoneNumber'] = item['Phone'];	
            item['faxNumber'] = item['Fax'];
        });
        
        resultObj.forEach(x => {							
            parentCmp.arrName.push({ label: x.accountMergeName, value: x.accountMergeName });
            parentCmp.arrAddress.push({ label: x.address, value: x.address});
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
                parentCmp.arrFax.push({ label:'unknown', value: 'unknown' });
            } else { 
                parentCmp.arrFaxExist = true;
                parentCmp.arrFax.push({ label: String(x.faxNumber), value: String(x.faxNumber) });
            }
        })
    })
}
export { 
    relatedGetAccounts_helper1,
    relatedRenameAccounts_helper1,
    relatedSaveRenameAccounts_helper1,
    getAccountForMerge_helper1,
    relatedRemove_helper1
}