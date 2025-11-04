import {datatableRecSelectorValidation_helper5} from './relatedAccounts_helper5';
import {create_RIS_Request_helper2} from './relatedAccounts_helper2';
const createRISReqOnLocationRename_helper7 = async(cmp)=>{
    await datatableRecSelectorValidation_helper5(cmp);
    let listSelectedObjs = await accLocationRISRequestSetup_helper7(cmp);
    await create_RIS_Request_helper2(cmp, listSelectedObjs, false);
    cmp.isShowFormModal = false;
};

const accLocationRISRequestSetup_helper7 = async(cmp)=>{
    let listSelectedObjs = [];
    let listInpFields = cmp.template.querySelectorAll(`lightning-input-field[data-account-id][data-purpose='rename']`);
    if(listInpFields && listInpFields.length>0){
        for(let inpField of listInpFields){
            let listFilteredRecs = cmp.accountObjData.filter(accObjRec=>accObjRec.AccountId == inpField.dataset.accountId);
            if(listFilteredRecs && listFilteredRecs.length>0){
                listFilteredRecs[0]['Rename_Location'] = true;
                listFilteredRecs[0]['Type'] = 'Renaming an account';
                listFilteredRecs[0]['Subject'] = 'Renaming an account';
                listFilteredRecs[0]['Loc_Description'] = `Practice location <b>${listFilteredRecs[0].Account.Name}</b> is being renamed to <b>${inpField.value} </b>`;
                console.log(`listFilteredRecs[0]['Loc_Description']  = ${listFilteredRecs[0]['Loc_Description']}`);
                listSelectedObjs = [...listSelectedObjs, listFilteredRecs[0]];
            }
        }
    }

    return listSelectedObjs;
};

export{createRISReqOnLocationRename_helper7};