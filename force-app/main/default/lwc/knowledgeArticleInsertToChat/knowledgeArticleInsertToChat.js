import { LightningElement, api, track,wire } from 'lwc';
import getArticles from '@salesforce/apex/KnowledgeArticleController.getArticles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KnowledgeArticleInsertToChat extends LightningElement {
     @track articleOptions = [];
    selectedArticleId;
    insertedText;

    @wire(getArticles)
    wiredArticles({ error, data }) {
        if(data){
            this.articleOptions = data.map(a => ({ label: a.Title, value: a.Id }));
        } else if(error){
            console.error('Error fetching articles', error);
        }
    }

    handleArticleChange(event){
        this.selectedArticleId = event.detail.value;
    }

    insertArticle(){
        if(!this.selectedArticleId){
            alert('Please select an article');
            return;
        }

        // Find the article description
        const article = this.articleOptions.find(a => a.value === this.selectedArticleId);

        if(article){
            // Set the text to show in conversation UI
            this.insertedText = article.label + '\n\n' + article.summary;

            // Custom event: You can bubble this text to parent component if needed
            this.dispatchEvent(new CustomEvent('inserttext', {
                detail: { text: this.insertedText }
            }));
        }
    }}