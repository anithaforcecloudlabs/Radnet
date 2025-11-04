import getAccountsForUpdate from '@salesforce/apex/RelatedAccountsAPX.getAccountsForUpdate';

const getAccountsForMerge_helper9 = async(cmp)=>{
    cmp.arrName = [];
    cmp.arrOwner = [];
    cmp.arrPhone = [];
    cmp.arrFax = [];
    cmp.arrAccountIds = [];
    cmp.arrAddress = [];

    let dataTableCmp = cmp.template.querySelector('lightning-datatable');
    if(dataTableCmp){
        if(dataTableCmp.selectedRows && dataTableCmp.selectedRows.length>0){
            let listAccIds = [];
            await Promise.all(cmp.accountObjData.map(async accConRelObj=>{
                if(dataTableCmp.selectedRows.includes(accConRelObj.Id)){
                    listAccIds = [...listAccIds, accConRelObj.AccountId];
                }
            }));
            console.log(`dataTableCmp.selectedRows = ${JSON.stringify(dataTableCmp.selectedRows)}`);
            console.log(`listAccIds = ${JSON.stringify(listAccIds)}`);
            if(listAccIds && listAccIds.length>0){
                await getAccountsForUpdate({accounIds : listAccIds}).then(async listAccs =>{
                    console.log(`listAccs = ${JSON.stringify(listAccs)}`);
                    console.log(`listAccs = ${JSON.stringify(listAccs.length)}`);
                    if(listAccs && listAccs.length>0){
                        await Promise.all(listAccs.map(async accObjRec=>{
                            cmp.arrPhoneExist = true;
                            cmp.arrFaxExist = true;
                            let accMergeNameOption = await getSelectOptionObj_helper9(cmp, accObjRec.Name);
                            let accMergeOwnerOption = await getSelectOptionObj_helper9(cmp, accObjRec.Owner.Name);
                            let accMergePhoneOption = await getSelectOptionObj_helper9(cmp, accObjRec.Phone);
                            if ('label' in accMergePhoneOption && accMergePhoneOption['label']=='unknown'){
                                cmp.arrPhoneExist = false;
                            }
                            let accMergeFaxOption = await getSelectOptionObj_helper9(cmp, accObjRec.Fax);
                            if ('label' in accMergeFaxOption && accMergeFaxOption['label']=='unknown'){
                                cmp.arrFaxExist = false;
                            }
                            let street = 'street' in accObjRec.ShippingAddress && accObjRec.ShippingAddress.street?accObjRec.ShippingAddress.street:'';
                            let city =  'city' in accObjRec.ShippingAddress && accObjRec.ShippingAddress.city?accObjRec.ShippingAddress.city:'';
                            let state = 'state' in accObjRec.ShippingAddress && accObjRec.ShippingAddress.state?accObjRec.ShippingAddress.state:'';
                            let postalCode = 'postalCode' in accObjRec.ShippingAddress && accObjRec.ShippingAddress.postalCode?accObjRec.ShippingAddress.postalCode:'';
                            let country = 'country' in accObjRec.ShippingAddress && accObjRec.ShippingAddress.country?accObjRec.ShippingAddress.country:'';
                            let address = street +', ' + city +', '+ state + ', ' + postalCode + ', ' + country;
                            let accMergeAddressOption = await getSelectOptionObj_helper9(cmp, address);
    
                            cmp.arrName = [...cmp.arrName, accMergeNameOption];
                            cmp.arrOwner = [...cmp.arrOwner, accMergeOwnerOption];
                            cmp.arrPhone = [...cmp.arrPhone, accMergePhoneOption];
                            cmp.arrFax = [...cmp.arrFax, accMergeFaxOption];
                            cmp.arrAccountIds = [...cmp.arrAccountIds, accObjRec.Id];
                            cmp.arrAddress = [...cmp.arrAddress, accMergeAddressOption];
    
                        }));
                    }
                }).catch(errorInGetAccountsForUpdate=>{
                    console.log(`errorInGetAccountsForUpdate = ${JSON.stringify(errorInGetAccountsForUpdate)}`);
                });
            }
        }
    }
};

const getSelectOptionObj_helper9 = async(cmp, objParam)=>{
    let selectOptionObj ={};

    if(objParam){
        selectOptionObj['label'] = objParam;
        selectOptionObj['value'] = objParam;
    }
    else{
        selectOptionObj['label'] = 'unknown';
        selectOptionObj['value'] = 'unknown';
    }

    return selectOptionObj;
};

export{getAccountsForMerge_helper9};