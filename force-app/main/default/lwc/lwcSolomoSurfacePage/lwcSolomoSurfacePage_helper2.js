const updateBaseUrlWithUrlParams_helper2 = async(cmp)=>{
    // console.log(`current page reference ${JSON.stringify(cmp.currentPageReference.state)}`);
    if ('state' in cmp.currentPageReference  && cmp.currentPageReference.state){
        // console.log(`current page state ${Object.keys(cmp.currentPageReference.state)}`);
        await Promise.all(Object.keys(cmp.currentPageReference.state).map(async stateKey=>{
            // console.log(`stateKey ${stateKey}`);
            // console.log(`cmp.currentPageReference.state[stateKey] ${cmp.currentPageReference.state[stateKey]}`);
            // console.log(`cmp.baseUrl ${cmp.baseUrl}`);
            cmp.baseUrl = `${cmp.baseUrl}&${stateKey}=${cmp.currentPageReference.state[stateKey]}`;
            // console.log(`cmp.baseUrl ${cmp.baseUrl}`);
        }));
    }
    // console.log(`cmp.baseUrl ${cmp.baseUrl}`);
};

export{updateBaseUrlWithUrlParams_helper2};