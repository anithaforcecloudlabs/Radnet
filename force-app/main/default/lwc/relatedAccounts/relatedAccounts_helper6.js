import getLocationAccountsAPX from '@salesforce/apex/RelatedAccountsAPX.getLocationAccountsAPX';

const getLocationAccounts_helper6 = async(cmp, listAccLocationIds, listAccObjSelectedVals)=>{
    await getLocationAccountsAPX({listAccLocationIds:listAccLocationIds}).then(async listAccLocations=>{
        if(listAccLocations && listAccLocations.length>0){
            if(listAccObjSelectedVals && listAccObjSelectedVals.length>0){
                await Promise.all(listAccObjSelectedVals.map(async accObjSelectedVal=>{
                    await Promise.all(listAccLocations.map(async listAccLocVal=>{
                        if(accObjSelectedVal['AccountId'] == listAccLocVal['Id']){
                            accObjSelectedVal['accObj'] = listAccLocVal;
                        }
                    }));
                }));
            }
            return listAccObjSelectedVals;
        }
        else{
            cmp.showToast(`Error!!`,`Account(s) couldn't be retrieved. Please contact system administrator.`,`error`,`dismissible`);
        }
    }).catch(errorInGetLocationAccountsAPX=>{
        console.log(`errorInGetLocationAccountsAPX = ${JSON.stringify(errorInGetLocationAccountsAPX)}`);
    });
};

const createLocationRISRequest_helper6 = async(cmp)=>{

};

export{getLocationAccounts_helper6}