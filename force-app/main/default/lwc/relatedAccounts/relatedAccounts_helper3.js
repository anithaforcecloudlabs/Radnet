import getRISRequestGrpAPX from '@salesforce/apex/RelatedAccountsAPX.getRISRequestGrpAPX';
import insertLocationRISReqAPX from '@salesforce/apex/RelatedAccountsAPX.insertLocationRISReqAPX';
import getLocationAccountsAPX from '@salesforce/apex/RelatedAccountsAPX.getLocationAccountsAPX';

const create_location_ris_request_helper3 = async(cmp, listAccLocationIds, listAccObjSelectedVals)=>{
    console.log(`listAccLocationIds = ${JSON.stringify(listAccLocationIds)}`);
    let listLocRisRequestsToInsert = [];
    if(listAccLocationIds && listAccLocationIds.length>0){
        await getLocationAccountsAPX({listAccLocationIds:listAccLocationIds}).then(async listAccLocations=>{
            console.log(`listAccLocations = ${JSON.stringify(listAccLocations)}`);
            if(listAccLocations && listAccLocations.length>0){
                await getRISRequestGrpAPX({groupName:'RISRequest'}).then(async listRisReqGroups=>{
                    if(listRisReqGroups && listRisReqGroups.length>0){
                        await Promise.all(listAccLocations.map(async locationRec=>{
                            let locationAddress = 'ShippingStreet' in locationRec && locationRec['ShippingStreet'] && locationRec['ShippingStreet']!=''?locationRec['ShippingStreet']:'';
                            locationAddress = locationAddress + ' ' + 'ShippingCity' in locationRec && locationRec['ShippingCity'] && locationRec['ShippingCity']!=''?locationRec['ShippingCity']:'';
                            locationAddress = locationAddress + ' ' + 'ShippingState' in locationRec && locationRec['ShippingState'] && locationRec['ShippingState']!=''?locationRec['ShippingState']:'';
                            locationAddress = locationAddress + ' ' + 'ShippingPostalCode' in locationRec && locationRec['ShippingPostalCode'] && locationRec['ShippingPostalCode']!=''?locationRec['ShippingPostalCode']:'';
                            locationAddress = locationAddress + ' ' + 'ShippingCountry' in locationRec && locationRec['ShippingCountry'] && locationRec['ShippingCountry']!=''?locationRec['ShippingCountry']:'';

                            let listFilteredLocationRISReqs = listAccObjSelectedVals.filter(accObjSelectedVal=>accObjSelectedVal['AccountId']==locationRec['Id']);
                            // console.log(`listFilteredLocationRISReqs = ${JSON.stringify(listFilteredLocationRISReqs)}`);
                            if(listFilteredLocationRISReqs && listFilteredLocationRISReqs.length>0){
                                let risRequestObj = {};
                                risRequestObj['Status__c'] = 'New';
                                risRequestObj['Type__c'] = listFilteredLocationRISReqs[0]['Type']; 
                                risRequestObj['Subject__c'] = listFilteredLocationRISReqs[0]['Subject'];
                                if ('Rename_Location' in listFilteredLocationRISReqs[0] && listFilteredLocationRISReqs[0]['Rename_Location']){
                                    risRequestObj['Description__c'] = listFilteredLocationRISReqs[0]['Loc_Description'];
                                }
                                else{
                                    risRequestObj['Description__c'] = `${listFilteredLocationRISReqs[0]['Loc_Description']} ${locationRec.Name} ${locationAddress}`; 
                                }
                                risRequestObj['OwnerId'] = listRisReqGroups[0].Id;
                                risRequestObj['Account_Name__c'] = locationRec.Id;
                                listLocRisRequestsToInsert = [...listLocRisRequestsToInsert, risRequestObj];
                            }
                        }));
                    }
                    else{
                        cmp.showToast(`Error!!`,`No RIS Request Group was found. Please contact system administrator.`,`error`,`dismissible`);
                    }
                }).catch(errorInGetRISRequestGrpAPX=>{
                    cmp.showToast(`Error!!`,`RIS Request(s) Were Not Created. Please contact system administrator.`,`error`,`dismissible`);
                    console.log(`errorInGetRISRequestGrpAPX = ${JSON.stringify(errorInGetRISRequestGrpAPX)}`);
                });
            }
            else{
                cmp.showToast(`Error!!`,`RIS Request(s) Were Not Created. Please contact system administrator.`,`error`,`dismissible`);
            }
        }).catch(errorInGetLocationAccountsAPX=>{
            cmp.showToast(`Error!!`,`RIS Request(s) Were Not Created. Please contact system administrator.`,`error`,`dismissible`);
            console.log(`errorInGetLocationAccountsAPX = ${JSON.stringify(errorInGetLocationAccountsAPX)}`);
        });
        
    }
    return listLocRisRequestsToInsert;
};

const insertLocationRISRequests_helper3 = async(cmp, listLocRisRequestsToInsert)=>{
    console.log(`listLocRisRequestsToInsert = ${JSON.stringify(listLocRisRequestsToInsert)}`);
    let listLocationRISReqSuccessIds = [];
    if(listLocRisRequestsToInsert && listLocRisRequestsToInsert.length>0){
        await insertLocationRISReqAPX({listLocRisRequestsToInsert:listLocRisRequestsToInsert}).then(async saveResRespStr=>{
            if(saveResRespStr && saveResRespStr!=''){
                let listSaveResults = JSON.parse(saveResRespStr);
                if(listSaveResults && listSaveResults.length>0){
                    await Promise.all(listSaveResults.map(async locationSaveResObj=>{
                        console.log(`locationSaveResObj = =${JSON.stringify(locationSaveResObj)}`);
                        if('success' in locationSaveResObj && locationSaveResObj['success']){
                            if('id' in locationSaveResObj && locationSaveResObj['id'] && locationSaveResObj['id']!=''){
                                listLocationRISReqSuccessIds = [...listLocationRISReqSuccessIds, locationSaveResObj['id']];
                            }
                            cmp.showToast(`Success!!`,`A RIS request has been created.`,`success`,`dismissible`);
                        }
                    }));
                    let listErrors = listSaveResults.filter(saveResObj=> 'errors' in saveResObj && saveResObj['errors'] && saveResObj['errors'].length>0);
                    if(listErrors && listErrors.length>0){
                        console.log(`listErrors = ${JSON.stringify(listErrors)}`);
                        cmp.showToast(`Error!!`,`Some RIS Request(s) Were Not Created`,`error`,`dismissible`);
                    }
                }
            }
        }).catch(errorInInsertLocationRISReqAPX=>{
            cmp.showToast(`Error!!`,`RIS Request(s) Were Not Created. Please contact system administrator`,`error`,`dismissible`);
            console.log(`errorInInsertLocationRISReqAPX = ${JSON.stringify(errorInInsertLocationRISReqAPX)}`);
        });
    }
    return listLocationRISReqSuccessIds;
};

export{create_location_ris_request_helper3, insertLocationRISRequests_helper3};