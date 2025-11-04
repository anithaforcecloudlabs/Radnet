import getLocationsFromIntegrationPlatformAPX from '@salesforce/apex/lwcReferralAnalysisAPX.getReferralsFromIntegrationPlatformAPX';
import {
    calculateRowTotal_helper2, constructTotalObj_helper2, getColumnDataForTable_helper2
} from './lwcReferralAnalysis_helper2';

const handleSetParams_helper4 = async (parentCmp) => {
    parentCmp.listReferralTableColumns = [];
    parentCmp.listReferralTableData = [];
    parentCmp.payloadToPOST = {};
    let currentDate = new Date();
    parentCmp.startDate = currentDate.getFullYear().toString() + '-' + (currentDate.getMonth()).toString() + '-' + '01';
    let endDate = new Date(currentDate.getFullYear(), currentDate.getMonth()+1, 0 );
    parentCmp.endDate = endDate.getFullYear().toString()+'-'+(endDate.getMonth()+1).toString()+'-'+ endDate.getDate();
};

const getReferrals_helper4 = async(parentCmp)=>{
    parentCmp.listReferralTableColumns = [];
    parentCmp.listReferralTableData = [];
    parentCmp.isLoading = true;
    parentCmp.payloadToPOST = {};    
    parentCmp.payloadToPOST['start_date'] = parentCmp.startDate;
    parentCmp.payloadToPOST['end_date'] = parentCmp.endDate;
    parentCmp.payloadToPOST['acc_id'] = parentCmp.recordId;    
   
    await getLocationsFromIntegrationPlatformAPX({objectApiName:parentCmp.objectApiName, payloadToPOST:JSON.stringify(parentCmp.payloadToPOST)}).then(async respBody=>{
        
        if (respBody && respBody != '') {
            parentCmp.isLoading = false;
            let listReferrals = await JSON.parse(respBody);            
            if(listReferrals && listReferrals.length>0){
                let totalObj = {};
                for(let refRec of listReferrals){
                    if(refRec && Object.keys(refRec).length>0){
                        //1. calculate row totals
                        refRec = await calculateRowTotal_helper2(parentCmp, refRec);                        
                        //2. calculate total obj
                        totalObj = await constructTotalObj_helper2(parentCmp, refRec, totalObj);                        
                        //3. construct columns
                        await getColumnDataForTable_helper2(parentCmp, refRec);
                    }
                }
                if(totalObj && Object.keys(totalObj).length>0){
                    let listStrTotalObjKeys = Object.keys(totalObj).filter(refKey=>typeof totalObj[refKey] == 'string');
                    if(listStrTotalObjKeys && listStrTotalObjKeys.length>0){                        
                        totalObj[listStrTotalObjKeys[listStrTotalObjKeys.length - 1]] = 'Total';
                    }
                }
                listReferrals = [totalObj, ...listReferrals];
                parentCmp.listReferralAllTableData = [...listReferrals];
                parentCmp.listReferralTableDataSelected = [totalObj];               
            }
        }        

    }).catch(errorInGetReferralsFromIntegrationPlatformAPX=>{
        console.log(`errorInGetReferralsFromIntegrationPlatformAPX = ${JSON.stringify(errorInGetReferralsFromIntegrationPlatformAPX)}`);
    });
};

const setLocationReferralList_helper4 = async (parentCmp) => {
    parentCmp.listPhysicians = [];
    parentCmp.listReferralTableData = [];
    parentCmp.listSites =[];
   
    if (parentCmp.listReferralTableDataSelected) {
        parentCmp.listReferralFilteredTableData = [...parentCmp.listReferralTableDataSelected];       
        for (let physId in parentCmp.listReferralTableDataSelected) {             
            if (parentCmp.listReferralTableDataSelected[physId].MASTERLOCATIONNAME !== 'Total') {               
                parentCmp.listReferralTableData = [...parentCmp.listReferralTableData, { ...parentCmp.listReferralTableDataSelected[physId], selected: true }];
                parentCmp.listSites = [...parentCmp.listReferralTableData, { ...parentCmp.listReferralTableDataSelected[physId], selected: true } ];   
                parentCmp.listPhysicians = [...parentCmp.listReferralTableData, { ...parentCmp.listReferralTableDataSelected[physId], selected: true } ];   
            
            }          
        }
    }
    
    parentCmp.listPhysicians = parentCmp.listReferralTableData.filter(
        (obj, index) =>
        parentCmp.listReferralTableData.findIndex(
            (item) => item.PHYNAME === obj.PHYNAME
        ) === index
    );

    parentCmp.listSites = parentCmp.listReferralTableData
        .filter((obj, index) => parentCmp.listReferralTableData.findIndex(
            (item) =>  item.MASTERLOCATIONNAME === obj.MASTERLOCATIONNAME) === index
    );   
    parentCmp.numberOfSelectedReferralsLabel = parentCmp.listPhysicians.length + ' physician(s) selected';
    parentCmp.numberOfSelectedSitesLabel = parentCmp.listSites.length + ' sites selected'; 
}

const deselectPhysiciansInList_helper4 = async (parentCmp) => {
    let listPhysiciansFilters = [...parentCmp.template.querySelectorAll(`lightning-input[data-input-id='phyCheckbox']`)];
    
    if (listPhysiciansFilters && listPhysiciansFilters.length > 0) {
        let listFilteredPhysicians = await Promise.all(listPhysiciansFilters
            .filter(phyElement => phyElement.checked).map(phyElement => phyElement.label)
        );
        parentCmp.numberOfSelectedReferralsLabel = listFilteredPhysicians.length + ' physician(s) selected';
        
        if (listFilteredPhysicians && listFilteredPhysicians.length > 0) {
            let listFilteredReferralData = parentCmp.listReferralTableDataSelected
                .filter(refRec => listFilteredPhysicians.includes(refRec.PHYNAME));
            if (listFilteredReferralData && listFilteredReferralData.length > 0) {
                let totalObj = {};
                for (let refRec of listFilteredReferralData) {
                    if (refRec && Object.keys(refRec).length > 0) {
                        refRec = await calculateRowTotal_helper2(parentCmp, refRec);
                        totalObj = await constructTotalObj_helper2(parentCmp, refRec, totalObj);
                        await getColumnDataForTable_helper2(parentCmp, refRec);
                    }
                    if (totalObj && Object.keys(totalObj).length > 0) {
                        let listStrTotalObjKeys = Object.keys(totalObj)
                            .filter(refKey => typeof totalObj[refKey] === 'string');
                        if (listStrTotalObjKeys && listStrTotalObjKeys.length > 0) {
                            totalObj[listStrTotalObjKeys[listStrTotalObjKeys.length - 1]] = 'Total';
                        }
                    }
                }
                listFilteredReferralData = [totalObj, ...listFilteredReferralData];
                parentCmp.listReferralFilteredTableData = listFilteredReferralData;
               
            } else {
                parentCmp.listReferralFilteredTableData = [];
            }
        } else {
            parentCmp.listReferralFilteredTableData = [];
        }

    }
}
const showColumnsObject_helper4 = async (parentCmp) => { 
    let hideFiltered = [];
    for (let physic in parentCmp.listReferralFilteredTableData) {       
        let newObject = (({ PHYNPI, ...object }) => object)(parentCmp.listReferralTableDataSelected[physic]);
        hideFiltered = [...hideFiltered, newObject ];
    }
    parentCmp.listReferralFilteredTableData = hideFiltered;
}
  
export {
    handleSetParams_helper4,
    getReferrals_helper4,
    setLocationReferralList_helper4,
    showColumnsObject_helper4,
    deselectPhysiciansInList_helper4,
};