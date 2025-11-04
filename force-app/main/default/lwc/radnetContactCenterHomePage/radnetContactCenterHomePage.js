import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Icons from "@salesforce/resourceUrl/IconsforComponents";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Home_Page_Link_Availability_Message from '@salesforce/label/c.Home_Page_Link_Availability_Message';

export default class RadnetContactCenterHomePage extends NavigationMixin(LightningElement) {
    @track siteSearchURL = Icons + '/Images/sitesearch.png';
    @track knowledgeURL  = Icons + '/Images/knowledge.png';
    message = Home_Page_Link_Availability_Message;

    openSiteSearch(){
        console.log('OUTPUT : ', 'opensitesearch');
        this.showNotification();
       /* this[NavigationMixin.GenerateUrl]({
           type: 'standard__navItemPage',
           attributes: {
               apiName: "Site_Search",
           },
       }).then(url => window.open(url, "__blank"));*/
    }

    openKnowledgeArticles(){
        console.log('OUTPUT : ', 'knowledge articles');
        this.showNotification();
       /* this[NavigationMixin.GenerateUrl]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Knowledge__kav',
                actionName: 'list'
            },
            state: {
                filterName: '00BVG0000009e6I2AQ' 
            }
        }).then(url => window.open(url, "__blank"));
    }*/

  }

  showNotification() {
        const evt = new ShowToastEvent({
            title: '',
            message: this.message,
            variant: 'info', //warning error success
        });
        this.dispatchEvent(evt);
    }
}