import getReferralsFromIntegrationPlatformAPX from '@salesforce/apex/lwcReferralAnalysisAPX.getReferralsFromIntegrationPlatformAPX';

const getReferrals_helper2 = async(parentCmp)=>{
    parentCmp.listReferralTableColumns = [];
    parentCmp.listReferralTableData = [];
    parentCmp.isLoading = true;
    parentCmp.payloadToPOST['start_date'] = parentCmp.startDate;
    parentCmp.payloadToPOST['end_date'] = parentCmp.endDate;    
    await getReferralsFromIntegrationPlatformAPX({
        objectApiName: parentCmp.objectApiName,
        payloadToPOST: JSON.stringify(parentCmp.payloadToPOST)
    }).then(async respBody => {
        if (respBody && respBody != '') {
            parentCmp.isLoading = false;
            let listReferrals = await JSON.parse(respBody);
            if (listReferrals && listReferrals.length > 0) {
                let totalObj = {};
                for (let refRec of listReferrals) {
                    if (refRec && Object.keys(refRec).length > 0) {
                        //1. calculate row totals
                        refRec = await calculateRowTotal_helper2(parentCmp, refRec);
                        //2. calculate total obj
                        totalObj = await constructTotalObj_helper2(parentCmp, refRec, totalObj);
                        //3. construct columns
                        await getColumnDataForTable_helper2(parentCmp, refRec);
                    }
                }
                if (totalObj && Object.keys(totalObj).length > 0) {
                    let listStrTotalObjKeys = Object.keys(totalObj).filter(refKey => typeof totalObj[refKey] == 'string');
                    if (listStrTotalObjKeys && listStrTotalObjKeys.length > 0) {
                        totalObj[listStrTotalObjKeys[listStrTotalObjKeys.length - 1]] = 'Total';
                    }
                }
                
                listReferrals = [totalObj, ...listReferrals];
                parentCmp.listReferralAllTableData = [...listReferrals];
                parentCmp.listReferralTableDataSelected = [totalObj];
                
            }
            for (let physId in parentCmp.listReferralTableDataSelected) {
               
                if (parentCmp.listReferralTableDataSelected[physId].MASTERLOCATIONNAME !== 'Total') {
                      
                }
            }
        }
    }).catch(errorInGetReferralsFromIntegrationPlatformAPX => {
        parentCmp.isLoading = false;
        console.log(`errorInGetReferralsFromIntegrationPlatformAPX = ${errorInGetReferralsFromIntegrationPlatformAPX}`);
    });
};

const calculateRowTotal_helper2 = async(parentCmp, refRec)=>{
    refRec['Total'] = 0;
    await Promise.all(Object.keys(refRec).map(async refKey=>{
        if(refKey !== 'Total' && refRec[refKey] && typeof  refRec[refKey] === 'number'){
            refRec['Total'] = refRec['Total'] + refRec[refKey];
           
        }
    }));
    return refRec;
};

const constructTotalObj_helper2 = async (parentCmp, refRec, totalObj) => {
    
    await Promise.all(Object.keys(refRec).map(async refKey=>{
        if(totalObj){
            if(refKey in totalObj == false){
                if(typeof refRec[refKey] == 'string'){
                    totalObj[refKey] = '';
                }
                if(typeof refRec[refKey] == 'number'){
                    totalObj[refKey] = refRec[refKey] && refRec[refKey]>0?refRec[refKey]:0;
                }
            }
            else{
                if(typeof refRec[refKey] == 'number'){
                    totalObj[refKey] = refRec[refKey] && refRec[refKey]>0? totalObj[refKey] + refRec[refKey]: totalObj[refKey];
                }
            }
        }
        else{
            if(typeof refRec[refKey] == 'string'){
                totalObj[refKey] = '';
            }
            if(typeof refRec[refKey] == 'number'){
                totalObj[refKey] = refRec[refKey] && refRec[refKey]>0?refRec[refKey]:0;
            }
        }
    }));

    return totalObj;
    
};

const getColumnDataForTable_helper2 = async (parentCmp, refRec) => {

    await Promise.all(Object.keys(refRec)       
        .map(async refKey => {
        if (parentCmp.objectApiName === 'Contact' && (refKey === 'PHYNPI' || refKey === 'PHYNAME'))
            return;
        if (parentCmp.objectApiName === 'Account' && refKey === 'PHYNPI')
            return;
        if(parentCmp.listReferralTableColumns && parentCmp.listReferralTableColumns.length>0){
            let listOfFilteredReferralTableCols = parentCmp.listReferralTableColumns.filter(column=>column.fieldName == refKey);

            if(listOfFilteredReferralTableCols==null || listOfFilteredReferralTableCols==undefined || (listOfFilteredReferralTableCols && listOfFilteredReferralTableCols.length==0)){
                let columnRec = {};
                let alignment = {};
                const labelName = await getLabel_helper2(parentCmp, refKey);                
                columnRec['label']= labelName;
                columnRec['fieldName']= refKey;
                columnRec['type']= 'text';
                columnRec['wrapText']= true;
                columnRec['hideDefaultActions']= true;
                alignment['alignment'] = 'center'; 
                if (refKey === 'Total') { 
                    alignment['class'] = 'slds-text-color_success slds-text-title_bold';
                }
                if (refKey === 'MASTERLOCATIONNAME') { 
                    columnRec['initialWidth'] = 200;
                    alignment['alignment'] = 'left'; 
                }
                if (refKey === 'PHYNAME') { 
                    columnRec['initialWidth'] = 100;
                    alignment['alignment'] = 'left'; 
                }
                columnRec['cellAttributes']= alignment;
                parentCmp.listReferralTableColumns = [...parentCmp.listReferralTableColumns, columnRec];
            }
            
        }
        else {            
            let columnRec = {};
            let alignment = {};
            const labelName = await getLabel_helper2(parentCmp, refKey);           
            columnRec['label']= labelName;
            columnRec['fieldName']= refKey;
            columnRec['type']= 'text';
            columnRec['wrapText']= true;
            columnRec['hideDefaultActions']= true;
            alignment['alignment'] = 'center';
            if (refKey === 'Total') { 
                alignment['class'] = 'slds-text-color_success slds-text-title_bold';
            }  
            if (refKey === 'MASTERLOCATIONNAME') { 
                columnRec['initialWidth'] = 200;
                alignment['alignment'] = 'left'; 
            }
            if (refKey === 'PHYNAME') { 
                columnRec['initialWidth'] = 100;
                alignment['alignment'] = 'left'; 
            }
            columnRec['cellAttributes']= alignment;
            parentCmp.listReferralTableColumns = [...parentCmp.listReferralTableColumns, columnRec];
        }
           
    }));
};
const getLabel_helper2 = async (parentCmp, refKey) => { 
    if (refKey === 'PHYNPI') { 
        return 'Physician NPI';
    }
    if (refKey === 'MASTERLOCATIONNAME') { 
        return 'Location';
    }
    if (refKey === 'PHYNAME') { 
        return 'Physician';
    }
    return refKey;      
}
export {
    getReferrals_helper2,calculateRowTotal_helper2, constructTotalObj_helper2, getColumnDataForTable_helper2
};