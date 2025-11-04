import { LightningElement } from 'lwc';

export default class DH_GoLiveCalendarWrapper extends LightningElement {
    isGoLiveCal = false;
    isSearchPhoneDir = false;
    connectedCallback() {
        let str = window.location.href;
        str = str.split("/");
        str = str[str.length - 1].replaceAll('-', ' ');
        if (str.toLowerCase().includes('go live')) {
            this.isGoLiveCal = true;
        } else if (str.toLowerCase().includes('phone directory')) {
            this.isSearchPhoneDir = true;
        }
    }
}