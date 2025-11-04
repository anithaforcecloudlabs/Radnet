const checkNumberOfAccsSelected_helper8 = async(cmp)=>{
    let dataTableCmp = cmp.template.querySelector('lightning-datatable');
    if(dataTableCmp){
        // console.log(`dataTableCmp.selectedRows = ${dataTableCmp.selectedRows}`);
        if(dataTableCmp.selectedRows && dataTableCmp.selectedRows.length>1){
            // console.log(`dataTableCmp.selectedRows = ${JSON.stringify(dataTableCmp.selectedRows)}`);
            if( dataTableCmp.selectedRows.length>3){
                dataTableCmp.selectedRows = [];
                cmp.showToast(`Error!!`,`Please select only 3 accounts. Cannot merge more than 3 accounts.`,`error`,`dismissible`);
                return false;
            }
            else{
                if(cmp.accountObjData && cmp.accountObjData.length>0){
                    console.log(`dataTableCmp.selectedRows = ${dataTableCmp.selectedRows}`);
                    let listFilteredRows = cmp.accountObjData.filter(accObj => accObj.Account.RecordType.DeveloperName == 'Practice_Location' && dataTableCmp.selectedRows.includes(accObj.Id));
                    console.log(`listFilteredRows = ${JSON.stringify(listFilteredRows)}`);
                    if(listFilteredRows && listFilteredRows.length>0 && listFilteredRows.length == dataTableCmp.selectedRows.length){
                        return true;
                    }
                    else{
                        dataTableCmp.selectedRows = [];
                        cmp.showToast(`Error!!`,`It is not possible to merge these accounts due to because of different record types.`,`error`,`dismissible`);
                        return false;
                    }
                }
                else{
                    dataTableCmp.selectedRows = [];
                    cmp.showToast(`Error!!`,`Please contact system administrator. Cannot find accounts from datatable.`,`error`,`dismissible`);
                    return false;
                }
            }
        }
        else{
            dataTableCmp.selectedRows = [];
            cmp.showToast(`Error!!`,`Please select at least two accounts.`,`error`,`dismissible`);
            return false;
        }
    }
    return false;
};

export{checkNumberOfAccsSelected_helper8};