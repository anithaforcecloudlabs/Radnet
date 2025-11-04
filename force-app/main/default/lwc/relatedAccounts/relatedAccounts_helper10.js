import mergeAcrs from '@salesforce/apex/RelatedAccountsAPX.mergeAcrs';
import getDuplicateRecordsAfterMerged from '@salesforce/apex/RelatedAccountsAPX.getDuplicateRecordsAfterMerged';
const buildMergeNotes_helper10 = async(cmp)=>{
    cmp.isLoading = true;
    let mergeNotes = `Name:${cmp.nameValue}\nAddress:${cmp.addressValue}\nOwner:${cmp.ownerValue}`;
    mergeNotes = cmp.phoneValue?`${mergeNotes}\nPhone:${cmp.phoneValue}`:mergeNotes;
    mergeNotes = cmp.faxValue?`${mergeNotes}\nPhone:${cmp.faxValue}`:mergeNotes;
    mergeNotes = cmp.textCommentValue?`${mergeNotes}\Comment:${cmp.textCommentValue}`:mergeNotes;
    

    try {
        let checkDuplicates = await getDuplicateRecordsAfterMerged({
            recordIds: cmp.arrAccountIds
        })			
        let parseResult = JSON.parse(JSON.stringify(checkDuplicates));
        console.log('getDuplicateRecordId parseResult ', parseResult);        
        if (parseResult && parseResult.length > 0) {
            console.log('getDuplicateRecordId parseResult.length ', parseResult.length);
            cmp.showToast('warning', 'There is already a pending RIS request for merge that is open', 'warning', 'dismissible');	
        } else {
            cmp.showToast('Success', 'A RIS request has been created for this merge request', 'Success', 'dismissible');	
        }
        let updateAccount = await mergeAcrs({
            accountIds: cmp.arrAccountIds,
            noteMerge: mergeNotes
        })
        if (updateAccount !== 'success') {
            cmp.showToast('Error', 'There was an error creating a RIS Request to merge the records. Please contact system administrator', 'Error', 'dismissable');
        }
        cmp.isLoading = false;
        cmp.isShowMergeModal=false;
        let dataTableCmp = cmp.template.querySelector('lightning-datatable');
        if(dataTableCmp){
            dataTableCmp.selectedRows = [];
        }
        //await Promise.all([updateAccount, checkDuplicates]);
    } catch (e) {
        // deal with any errors
    }

    /*await mergeAcrs({accountIds : cmp.arrAccountIds, noteMerge:mergeNotes}).then(result=>{
        if(result === 'success'){
            cmp.showToast('Success', 'A RIS request has been created for this merge request', 'Success', 'dismissible');
        }
        else{

            cmp.showToast('Error', 'There was an error creating a RIS Request to merge the records. Please contact system administrator', 'Error', 'dismissable');
        }
    }).catch(errorInMergeAcrs=>{
        console.log(`errorInMergeAcrs = ${JSON.stringify(errorInMergeAcrs)}`);
    });*/

};

export{buildMergeNotes_helper10};