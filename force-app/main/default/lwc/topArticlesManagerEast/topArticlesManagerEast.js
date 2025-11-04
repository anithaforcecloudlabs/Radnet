/*
* ***************************************************************************************************************************
* LWC Component Name - topArticlesManagerEast.js
* Created Date - 13-Sep-2024
* Function - JS file for Top 5 KM Articles for east coast users
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       --------------------------------------------
* CC-1534                    21-May-2025           Added all core functionalities
* *****************************************************************************************************************************
*/
import { LightningElement, track, wire, api } from 'lwc';
import getSelectedTopArticles from '@salesforce/apex/DH_TopArticlesManager.getSelectedTopArticles';
import getAllArticles from '@salesforce/apex/DH_TopArticlesManager.getAllArticles';
import saveSelectedTopArticles from '@salesforce/apex/DH_TopArticlesManager.saveSelectedTopArticles';
import getUserProfileName from '@salesforce/apex/DH_TopArticlesManager.getUserProfileName';
import hasKnowledgeSuperUserPermission from '@salesforce/apex/DH_TopArticlesManager.hasKnowledgeSuperUserPermission';
import getArticlesByIds from '@salesforce/apex/DH_TopArticlesManager.getArticlesByIds';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TopArticlesManagerEast extends LightningElement {
    @track topArticles = [];
    @track articleOptions = [];
    @track filteredOptions = [];
    @track selectedArticleIds = [];
    @track showModal = false;
    isEditable = false;

    connectedCallback() {
        this.loadProfile();
        this.loadTopArticles();
    }

    loadProfile() {
        hasKnowledgeSuperUserPermission()
            .then(hasPermission => {
                this.isEditable = hasPermission;
                if (this.isEditable) {
                    this.loadAllArticles();
                }
            })
            .catch(error => {
                console.error('Error checking permission set:', error);
            });
    }
    

    loadTopArticles() {
        getSelectedTopArticles()
            .then(data => {
                this.topArticles = data;
            });
    }

    loadAllArticles() {
        getAllArticles()
            .then(data => {
                this.articleOptions = data.map(article => ({
                    label: article.Title,
                    value: article.Id
                }));
                this.filteredOptions = [...this.articleOptions];
            });
    }

    handleArticleClick(event) {
        const articleId = event.currentTarget.dataset.id;
        window.open(`/lightning/r/Knowledge__kav/${articleId}/view`, '_blank');
    }

    openModal() {
        this.selectedArticleIds = this.topArticles.map(article => article.Id);
        this.filteredOptions = [...this.articleOptions];
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.selectedArticleIds = [];
    }

    handleSelectionChange(event) {
        const selected = event.detail.value;
    
        if (selected.length > 5) {
            this.showErrorToast('You can select only 5 articles.');
            
            // Revert back to previous valid selection
            this.template.querySelector('lightning-dual-listbox').value = this.selectedArticleIds;
            return;
        }
    
        this.selectedArticleIds = selected;
    }
    

    saveSelection() {
        if (this.selectedArticleIds.length !== 5) {
            this.showErrorToast('Please select exactly 5 articles.');
            return;
        }

        saveSelectedTopArticles({ articleIds: this.selectedArticleIds })
            .then(() => {
                return getArticlesByIds({ articleIds: this.selectedArticleIds });
            })
            .then(data => {
                this.topArticles = [...data];
                this.closeModal();
                this.showSuccessToast();
            })
            .catch(error => {
                console.error('Error saving or fetching selected articles:', error);
                this.showErrorToast('An error occurred while saving.');
            });
    }

    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        const selectedSet = new Set(this.selectedArticleIds);
        if (!searchTerm) {
            this.filteredOptions = [...this.articleOptions];
        } else {
            this.filteredOptions = this.articleOptions.filter(opt =>
                !selectedSet.has(opt.value) && opt.label.toLowerCase().includes(searchTerm)
            ).concat(
                this.articleOptions.filter(opt => selectedSet.has(opt.value))
            );
        }
    }

    showSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Top 5 articles updated successfully.',
                variant: 'success'
            })
        );
    }

    showErrorToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message,
                variant: 'error'
            })
        );
    }
}