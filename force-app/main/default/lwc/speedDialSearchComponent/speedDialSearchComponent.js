import { LightningElement, track } from 'lwc';
import search from '@salesforce/apex/ActSpeedDialSearch.getDials';
import { getAllUtilityInfo, open } from 'lightning/platformUtilityBarApi';

export default class SpeedDialSearchComponent extends LightningElement {
  @track results;
  @track error;
  @track uiResults;

  // Add this connectedCallback to inject the styles
  connectedCallback() {
    const style = document.createElement('style');
    style.textContent = SpeedDialSearchComponent.styles;
    this.template.appendChild(style);
    this.fetchResults();
  }

  fetchResults() {
    console.log('Fetching results...');
    search().then(result => {
      console.log('actSpeedDialSearch API response:', result);
      this.results = result;
      this.uiResults = result;
    }).catch(error => {
      console.error('actSpeedDialSearch API Error:', error)
      this.error = error;
    });
  }
    
  async openOmniChannelPopUp() {
    console.log('inside openOmni');
    try {
        const utilityItems = await getAllUtilityInfo();
        if (utilityItems && utilityItems.length > 0) {
            const firstUtilityId = utilityItems[0].id;
            await open(firstUtilityId);
            console.log('First utility item opened.');
        } else {
            console.warn('No utility items found.');
        }
    } catch (error) {
        console.error('Error opening utility item:', error);
    }
  }

  handleSearch(event) {
    console.log('Handling search...');
    let searchTerm = event.target.value;
    
    try {
      if (searchTerm && searchTerm.length > 0) {
        let searchTermsArray = searchTerm.split(" ");
        this.uiResults = this.results.filter(result => {
          if (result.description) {
            let resultToCompare = result.description.toLowerCase();
            for(let i=0; i<searchTermsArray.length; i++) {
              let singleSearchTerm = searchTermsArray[i];
              if(resultToCompare.includes(singleSearchTerm.toLowerCase())) {
                continue;
              }
              else{
                return false;
              }
            }
            return true;
          } else {
            return false;
          }
        });
      } else {
        this.uiResults = this.results;
      }
    } catch (error) {
      console.error('Error handling search:', error);
    }
  }

  handleOnClickSpeed(){
    console.log('Speed');

  }
}