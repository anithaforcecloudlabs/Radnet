import {
    calculateRowTotal_helper2, constructTotalObj_helper2, getColumnDataForTable_helper2
} from './lwcReferralAnalysis_helper2';

const setPhysicianReferralList_helper3 = async (parentCmp) => {
    parentCmp.listPhysicians = [];
    parentCmp.listReferralTableData = [];
    parentCmp.listSites =[];
   
    if (parentCmp.listReferralTableDataSelected) {
        parentCmp.listReferralFilteredTableData = [...parentCmp.listReferralTableDataSelected];
        parentCmp.listReferralFilteredTableData = parentCmp.listReferralFilteredTableData.filter(
            item => item !== item.PHYNPI
        );
        for (let physId in parentCmp.listReferralTableDataSelected) {
            if (parentCmp.listReferralTableDataSelected[physId].MASTERLOCATIONNAME !== 'Total') {               
                parentCmp.listReferralTableData = [...parentCmp.listReferralTableData, { ...parentCmp.listReferralTableDataSelected[physId], selected: true }];
                parentCmp.listSites = [...parentCmp.listReferralTableData, { ...parentCmp.listReferralTableDataSelected[physId], selected: true } ];   
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

const deselectPhysiciansInList_helper3 = async (parentCmp) => {
    let listPhysiciansFilters = [...parentCmp.template.querySelectorAll(`lightning-input[data-input-id='phyCheckbox']`)];
    
    if (listPhysiciansFilters && listPhysiciansFilters.length > 0) {
        let listFilteredPhysicians =  await Promise.all(listPhysiciansFilters.filter(phyElement => phyElement.checked).map(phyElement => phyElement.label));
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
                listFilteredReferralData = [...listFilteredReferralData, totalObj];
                parentCmp.listReferralFilteredTableData = listFilteredReferralData;
               
            } else {
                parentCmp.listReferralFilteredTableData = [];
            }
        } else { 
            parentCmp.listReferralFilteredTableData = [];
        }
    }
   
}

const filterDeselectedSites_helper3 = async (parentCmp) => {
    let listSiteFilters = [...parentCmp.template.querySelectorAll(`lightning-input[data-input-id='siteCheckbox']`)];
    if (listSiteFilters && listSiteFilters.length > 0) {
        let listFilteredSites = await Promise.all(listSiteFilters
            .filter(siteElement => siteElement.checked).map(siteElement => siteElement.label));       
        parentCmp.numberOfSelectedSitesLabel = listFilteredSites.length + ' sites selected';        
        if (listFilteredSites && listFilteredSites.length > 0) {
            let listFilteredReferralData = parentCmp.listReferralTableDataSelected.filter(
                refRec => listFilteredSites.includes(refRec.MASTERLOCATIONNAME));

            if (listFilteredReferralData && listFilteredReferralData.length > 0) {
                let totalObj = {};
                for (let refRec of listFilteredReferralData) {
                    if (refRec && Object.keys(refRec).length > 0) {
                        refRec = await calculateRowTotal_helper2(parentCmp, refRec);                      
                        totalObj = await constructTotalObj_helper2(parentCmp, refRec, totalObj);                       
                        await getColumnDataForTable_helper2(parentCmp, refRec);
                    }
                    if (totalObj && Object.keys(totalObj).length > 0) {
                        let listStrTotalObjKeys = Object.keys(totalObj).filter(refKey => typeof totalObj[refKey] == 'string');
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

const showColumnsObject_helper3 = async (parentCmp) => { 
    let hideFiltered = [];
    for (let physic in parentCmp.listReferralFilteredTableData) {       
        let newObject = (({ PHYNPI, PHYNAME, ...object }) => object)(parentCmp.listReferralTableDataSelected[physic]);
        hideFiltered = [...hideFiltered, newObject ];
    }
    parentCmp.listReferralFilteredTableData = hideFiltered;
}
    
export {
    deselectPhysiciansInList_helper3,
    setPhysicianReferralList_helper3,
    filterDeselectedSites_helper3,
    showColumnsObject_helper3
};