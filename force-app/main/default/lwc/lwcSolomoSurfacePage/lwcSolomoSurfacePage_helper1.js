import getUserInfoApx from '@salesforce/apex/lwcSolomoSurfacePageAPX.getUserInfoApx';

const getUserInfoAttributes_helper1 = async(cmp)=>{
    await getUserInfoApx().then(async userClsRec=>{
        console.log(`userClsRec = ${JSON.stringify(userClsRec)}`);
        cmp.userClsRec = userClsRec;
    }).catch(errorINgetUserInfoApx=>{
        console.log(`errorINgetUserInfoApx = ${JSON.stringify(errorINgetUserInfoApx)}`);
    });
};

export{getUserInfoAttributes_helper1};