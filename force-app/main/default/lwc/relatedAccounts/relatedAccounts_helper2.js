import {create_location_ris_request_helper3, insertLocationRISRequests_helper3} from './relatedAccounts_helper3';
import {getInsertedLocationRISReqs_helper4, createRelatedRISRequests_helper4,insertRelatedRISRequests_helper4} from './relatedAccounts_helper4';

const create_RIS_Request_helper2 = async(cmp, listObjVals, createRelatedRequests)=>{
    let listAccObjSelectedVals = [];
    let listAccLocationIds = [];
    if(listObjVals && listObjVals.length>0){
        await Promise.all(listObjVals.map(async objVal=>{
            
            let description = await getDescriptions_helper2(objVal);
            let saveVal = objVal;
            let listLocObjRecs = cmp.accountObjData.filter(locationObj=>locationObj.Id == saveVal.Id);
            
            if(listLocObjRecs && listLocObjRecs.length==1){
                saveVal['AccountId'] = listLocObjRecs[0]['AccountId'];
                saveVal['ContactId'] = listLocObjRecs[0]['ContactId'];
                saveVal['Phy_Description'] = description;
                
                if (!('Type' in saveVal)){
                    saveVal['Type'] = 'Change Physician Details';
                }
                if (!('Subject' in saveVal)){
                    saveVal['Subject'] = 'Requesting to Change Physician Contact Details';
                }
                if (!('Loc_Description' in saveVal)){
                    saveVal['Loc_Description'] = 'Changes Requested for Physician(s) at Location : ';
                }
                if(listAccLocationIds && listAccLocationIds.length>0){
                    if(!listAccLocationIds.includes(listLocObjRecs[0].AccountId)){
                        listAccLocationIds = [...listAccLocationIds, listLocObjRecs[0].AccountId];
                    }
                }
                else{
                    listAccLocationIds = [...listAccLocationIds, listLocObjRecs[0].AccountId];
                }
            }
            listAccObjSelectedVals = [...listAccObjSelectedVals, saveVal];
        }));
    }

    let listLocRisRequestsToInsert = await create_location_ris_request_helper3(cmp, listAccLocationIds, listAccObjSelectedVals);
    let listLocationRISReqSuccessIds = await insertLocationRISRequests_helper3(cmp, listLocRisRequestsToInsert);
    if(createRelatedRequests){
        let listLocationRISReqs = await getInsertedLocationRISReqs_helper4(cmp, listLocationRISReqSuccessIds);
        let listRelatedRISReqsToInsert = await createRelatedRISRequests_helper4(cmp, listLocationRISReqs, listAccObjSelectedVals);
        await insertRelatedRISRequests_helper4(cmp, listRelatedRISReqsToInsert);
    }
};


const getDescriptions_helper2 = async(objVal)=>{
    if(objVal){
        let description = '';
        if ('Phone__c' in objVal && objVal['Phone__c']) {                 
            description = `Contact Phone : ${objVal['Phone__c']}`+ '\n';
        }
        if ('FAX__c' in objVal && objVal['FAX__c']) {                 
            description =`FAX : ${objVal['FAX__c']}` + '\n';
        }
        if ('Email_Reports__c' in objVal && objVal['Email_Reports__c']) {                 
            description = `Email Reports : ${objVal['Email_Reports__c']}` + '\n';
        }
        if ('Contact_Email__c' in objVal && objVal['Contact_Email__c']) {                 
            description = `Contact Email : ${objVal['Contact_Email__c']}` + '\n';
        }
        if ('Fax_Reports__c' in objVal && objVal['Fax_Reports__c']) {                 
            description = `FAX Reports : ${objVal['Fax_Reports__c']}` + '\n';
        }

        return description;
    }

};

export{create_RIS_Request_helper2};