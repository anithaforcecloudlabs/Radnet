import getInsertedLocationRISReqsAPX from '@salesforce/apex/RelatedAccountsAPX.getInsertedLocationRISReqsAPX';
import insertRelatedRISRequestsAPX from '@salesforce/apex/RelatedAccountsAPX.insertRelatedRISRequestsAPX';
const getInsertedLocationRISReqs_helper4 = async(cmp,listLocationRISReqSuccessIds)=>{
    console.log(`listLocationRISReqSuccessIds = ${JSON.stringify(listLocationRISReqSuccessIds)}`);
    let listLocationRISReqs = [];
    if(listLocationRISReqSuccessIds && listLocationRISReqSuccessIds.length>0){
        await getInsertedLocationRISReqsAPX({listLocationRISReqSuccessIds:listLocationRISReqSuccessIds}).then(async listLocationRISReqRecs=>{
            if(listLocationRISReqRecs && listLocationRISReqRecs.length>0){
                listLocationRISReqs = listLocationRISReqRecs;
            }
            else{
                cmp.showToast(`Error!!`,`Couldn't find location RIS Requests. Please contact system administrator`,`error`,`dismissible`);
            }
        }).catch(errorInGetInsertedLocationRISReqsAPX=>{
            console.log(`errorInGetInsertedLocationRISReqsAPX = ${JSON.stringify(errorInGetInsertedLocationRISReqsAPX)}`);
        });
    }

    return listLocationRISReqs;
};

const createRelatedRISRequests_helper4 = async(cmp, listLocationRISReqs, listOnSaveVals)=>{
    let listRelatedRISRequests = [];
    if(listLocationRISReqs && listLocationRISReqs.length>0 && listOnSaveVals && listOnSaveVals.length>0){
        await Promise.all(listOnSaveVals.map(async saveResObj=>{
            let listFilteredLocationRISReqs = listLocationRISReqs.filter(locationRISRec=>locationRISRec.Account_Name__c==saveResObj['AccountId']);
            console.log(`listFilteredLocationRISReqs = ${JSON.stringify(listFilteredLocationRISReqs)}`);
            console.log(`saveResObj = ${JSON.stringify(saveResObj)}`);
            if(listFilteredLocationRISReqs && listFilteredLocationRISReqs.length>0){
                let relatedRISReq = {};
                relatedRISReq['Physician__c'] = saveResObj['ContactId'];
                relatedRISReq['RIS_Request__c'] = listFilteredLocationRISReqs[0].Id;
                // Account Contact Relation ID
                relatedRISReq['AcrId__c'] = saveResObj['Id'];
                relatedRISReq['Description__c'] = saveResObj['Phy_Description'];
                relatedRISReq['Contact_Fax_New__c'] = 'FAX__c' in saveResObj && saveResObj['FAX__c']?saveResObj['FAX__c']:'';
                relatedRISReq['Contact_Phone_New__c'] = 'Phone__c' in saveResObj && saveResObj['Phone__c']?saveResObj['Phone__c']:'';
                relatedRISReq['Email_Reports_New__c'] = 'Email_Reports__c' in saveResObj && saveResObj['Email_Reports__c']?saveResObj['Email_Reports__c']:'';
                listRelatedRISRequests = [...listRelatedRISRequests, relatedRISReq];
            }
        }));

        console.log(`listRelatedRISRequests = ${JSON.stringify(listRelatedRISRequests)}`);
    }

    return listRelatedRISRequests;
};  

const insertRelatedRISRequests_helper4 = async(cmp,listRelatedRISReqsToInsert)=>{
    console.log(`listRelatedRISReqsToInsert = ${JSON.stringify(listRelatedRISReqsToInsert)}`);
    if(listRelatedRISReqsToInsert && listRelatedRISReqsToInsert.length>0){
        await insertRelatedRISRequestsAPX({listRelatedRISReqsToInsert:listRelatedRISReqsToInsert}).then(async saveResStr=>{
            if(saveResStr && saveResStr!=''){
                let listSaveResults = JSON.parse(saveResStr);
                if(listSaveResults && listSaveResults.length>0){
                    let listErrors = listSaveResults.filter(saveResObj=> 'errors' in saveResObj && saveResObj['errors'] && saveResObj['errors'].length>0);
                    if(listErrors && listErrors.length>0){
                        // SHOW TOAST
                        console.log(`listErrors = ${JSON.stringify(listErrors)}`);
                    }
                    let listSuccesses = listSaveResults.filter(saveResObj=> 'success' in saveResObj && saveResObj['success'] && saveResObj['success']==true);
                    if(listSuccesses && listSuccesses.length>0){
                        if(listErrors && listErrors.length>0){
                            cmp.showToast(`Error!!`,`Some Related RIS Requests weren't not created. Please contact system administrator`,`error`,`dismissible`);
                        }
                        else{
                            cmp.showToast(`Success!!`,`Related RIS Requests has been created.`,`success`,`dismissible`);
                        }
                    }
                }
            }
            else{
                // SHOW TOAST
                cmp.showToast(`Error!!`,`Related RIS Requests weren't not created. Please contact system administrator`,`error`,`dismissible`);
            }
        }).catch(errorInInsertRelatedRISRequestsAPX=>{
            console.log(`errorInInsertRelatedRISRequestsAPX = ${JSON.stringify(errorInInsertRelatedRISRequestsAPX)}`);
        });
    }
};

export{getInsertedLocationRISReqs_helper4, createRelatedRISRequests_helper4, insertRelatedRISRequests_helper4};