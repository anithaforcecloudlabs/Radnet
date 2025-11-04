import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import {getUserInfoAttributes_helper1} from './lwcSolomoSurfacePage_helper1';
import {updateBaseUrlWithUrlParams_helper2} from './lwcSolomoSurfacePage_helper2';

export default class LwcSolomoSurfacePage extends LightningElement {

    @api baseUrl;
    @api height;
    @api recordId;
    @api dontCallUrl;
    @api debug;
    userClsRec;
    iframeHeight;
    listStateParams;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback(){
        console.log(`baseUrl = ${this.baseUrl}`);
        console.log(`this.recordId = ${this.recordId}`);
        this.handleInitialLoad();
    }

    async handleInitialLoad(){
        await getUserInfoAttributes_helper1(this);
        await this.constructUrlForIframe();
        await updateBaseUrlWithUrlParams_helper2(this); 
        console.log(`this.baseUrl = ${JSON.stringify(this.baseUrl)}`);
        await this.setIframeProperties();
        // console.log(`this.baseUrl = ${this.baseUrl}`);
    }

    async constructUrlForIframe(){
        console.log(`this.userClsRec = ${JSON.stringify(this.userClsRec)}`);
        this.baseUrl = `${this.baseUrl}?embed=true&session_id=${this.userClsRec['sessionId']}&username=${this.userClsRec['userName']}&prod=${this.userClsRec['prodVal']}&orgId=${this.userClsRec['orgId']}`;
        if(this.recordId && this.recordId!=''){
            this.baseUrl = `${this.baseUrl}&recordId=${this.recordId}`;
        }
        console.log(`this.baseUrl = ${JSON.stringify(this.baseUrl)}`);
    }

    async setIframeProperties(){
        console.log(`this.height = ${this.height}`);
        if(this.height>0){
            this.iframeHeight = this.height+'px';
        }
        console.log(`this.height = ${this.iframeHeight}`);
    }
}