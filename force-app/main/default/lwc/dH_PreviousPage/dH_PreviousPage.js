import { LightningElement,wire } from 'lwc';
import getUserType from '@salesforce/apex/DH_KMUtility.getUserType';
import { NavigationMixin } from 'lightning/navigation';
export default class DH_PreviousPage extends NavigationMixin(LightningElement) {
    showSSRBreadCrumb = false;
    isGuestUser=false;
  
        // getting the user type of the user whether it is a guest user or not
        @wire(getUserType)
        userType(result) {
            if (result.data) {
                this.isGuestUser = result.data;
            }
            else if (result.error) {
                console.log('error found -> ' + JSON.stringify(result.error));
            }
        } 

/*
    handlePreviousPage(){
        if(this.isGuestUser){
            this.dispatchEvent(new CustomEvent('hideaccountdetailpage', {
                detail: {
                  showaccountdetailpage: false
                }
              }));
        }else{
  // window.location.href = URL_Store;
   window.history.back();
        }
    } 
*/

handlePreviousPage() {
        if (this.isGuestUser) {
            // For guest user, dispatch the event to hide account details
            this.dispatchEvent(new CustomEvent('hideaccountdetailpage', {
                detail: {
                    showaccountdetailpage: false
                }
            }));
        } else {
            // For non-guest user, navigate to the "Site Search" tab using NavigationMixin
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'Site_Search_Custom_Tab' // Replace with your actual custom tab API name
                }
            });
        }
    }

}