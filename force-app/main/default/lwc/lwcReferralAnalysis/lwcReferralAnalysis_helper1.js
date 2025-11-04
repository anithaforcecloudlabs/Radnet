import getPhysicianAPX from '@salesforce/apex/lwcReferralAnalysisAPX.getPhysicianAPX';

const handleSetParams_helper1 = async (parentCmp)=>{
    parentCmp.listReferralTableColumns = [];
    parentCmp.listReferralTableData = [];
    parentCmp.payloadToPOST = {};
};

const getPhysicianNPI_helper1 = async(parentCmp)=>{
    await getPhysicianAPX({recordId:parentCmp.recordId}).then(listPhysicians=>{
        if(listPhysicians && listPhysicians.length>0){
            if('Physician_NPI__c' in listPhysicians[0]){
                parentCmp.payloadToPOST['pnpi'] = listPhysicians[0]['Physician_NPI__c'];
            }
        }
    }).catch(errorInGetPhysicianAPX=>{
        console.log(`errorInGetPhysicianAPX = ${JSON.stringify(errorInGetPhysicianAPX)}`);
    });
};

const setInitialDateValues_helper1 = async(parentCmp)=>{
    let currentDate = new Date();
    parentCmp.startDate = currentDate.getFullYear().toString()+'-'+(currentDate.getMonth()).toString()+'-'+ '01';
    let endDate = new Date(currentDate.getFullYear(), currentDate.getMonth()+1, 0 );
    parentCmp.endDate = endDate.getFullYear().toString()+'-'+(endDate.getMonth()+1).toString()+'-'+ endDate.getDate();
};

export {
    handleSetParams_helper1, setInitialDateValues_helper1, getPhysicianNPI_helper1
};