import { LightningElement, api } from 'lwc';
import {getUserInfoAttributes_helper1} from './lwcSolomoSurfaceHomePage_helper1';

export default class LwcSolomoSurfaceHomePage extends LightningElement {
    @api baseUrl;
    @api height;
    @api recordId;
    @api dontCallUrl;
    @api debug;
    userClsRec;
    iframeHeight;

    connectedCallback(){
        console.log(`baseUrl = ${this.baseUrl}`);
        console.log(`this.recordId = ${this.recordId}`);
        this.handleInitialLoad();
    }

    async handleInitialLoad(){
        await getUserInfoAttributes_helper1(this);
        await this.constructUrlForIframe();
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