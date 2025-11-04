/******************************************************************************************************************************************************
 * 
 * LWC Component Name : DH_mostViewedArticles
 * 
 * Created Date    :  06/03/2024
 * 
 * @description    : This class serves to provide the functionality for Most viewed article component.
 * 
 * @JIRA Id        : CC-331
 * 
 * */
import { LightningElement,track,wire,api } from 'lwc';
import getMostViewedKnowledgeArticles from '@salesforce/apex/DH_knowledgeSearchFuncController.getMostViewedKnowledgeArticles';
import articleViewCountUpdate from '@salesforce/apex/DH_KMQueryManager.articleViewCountUpdate';
import { NavigationMixin } from 'lightning/navigation';


export default class DH_mostViewedArticles  extends NavigationMixin(LightningElement)  {

  @track mostViewedArticles=[];
  @api selectedcoast = '';
  kArecordId;
  //fetch 5 most viewed knowledge articles data
  @wire(getMostViewedKnowledgeArticles,{ selectedCoast : '$selectedcoast' })
  wiredGetMostViewedKnowledgeArticles({error, data}){    
    if (data) {
      this.mostViewedArticles = data;
    }
    else if (error) {
      this.error = error;
      this.mostViewedArticles = undefined;
    }
  }

  //handle click of knowledge article from the list of most viewed articles
  handleArticleClick(event){
    debugger
    const recId = event.currentTarget.dataset.knowledgearticleid;
    this.navigateToViewRecordPage(recId);
  }

  //navigation to detail view page of selected knowledge article 
  navigateToViewRecordPage(rcId) {
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {recordId: rcId, objectApiName: 'Knowledge__kav', actionName: 'view'},
    })
    .then(generatedUrl => {
        window.open(generatedUrl);
        this.kArecordId = rcId;
        this.getKnowledgeArticleUpdatedViewCount();
    })
    .catch(error => {
        console.log('Error generating Url:', JSON.stringify(error));
    });
  }

  // update the view count of navigated knowledge article in UCC
  async getKnowledgeArticleUpdatedViewCount(){
    try{
      await articleViewCountUpdate({knowledgeArticleId : this.kArecordId});
    } catch(error){
      console.log('Error generating Url:', JSON.stringify(error));
    } 
  }
  
}