import { LightningElement } from 'lwc';
import RADNET_LOGO from '@salesforce/resourceUrl/DH_radnetcclogo';
import WESTSTCOAST_SVG from '@salesforce/resourceUrl/DH_PathLeft';
import EASTCOAST_SVG from '@salesforce/resourceUrl/DH_PathRight';

export default class DH_kmCommunityHomePage extends LightningElement {
    logoURL;
    eastSvg;
    westSvg;
    isModalOpen;
    selectedCoast;
    coastHeader;
    changeSelectedCoast;
    showModalitySearch = false;
    homeTabSelected = true;
    modalityTabSelected = false;
    siteSearchTabSelected = false;
    knowledgeArticleTabSelected = false;
    openConfirmationModal = false;
    unselectCoastHeader;
    showAccountDetailpage = false;
    ccAccountDetailPageURL;

    connectedCallback() {
        this.logoURL = RADNET_LOGO;
        this.eastSvg = EASTCOAST_SVG;
        this.westSvg = WESTSTCOAST_SVG;
        this.isModalOpen = true;
    }

    // Set values on East Selection
    handleEastClick() {
        this.coastHeader = 'East';
        this.unselectCoastHeader = 'West';
        this.selectedCoast = 'East Coast'
        this.showModalitySearch = true;
        this.isModalOpen = false;
        this.eastDisabled = true;
        this.westDisabled = false;
        setTimeout(() => {
            this.handleHomeTabClick();
        }, "100");

    }

    // Set values on East Selection
    handleWestClick() {
        this.coastHeader = 'West';
        this.unselectCoastHeader = 'East';
        this.selectedCoast = 'West Coast';
        this.showModalitySearch = false;
        this.isModalOpen = false;
        this.eastDisabled = false;
        this.westDisabled = true;
        setTimeout(() => {
            this.handleHomeTabClick();
        }, "100");
    }

    //Reset selected tab
    resetSelectedContainer() {
        const selectedTabs = this.template.querySelectorAll('.tabcontainer');
        for (let i = 0; i <= selectedTabs.length; i++) {
            if (selectedTabs[i].classList.contains('slds-show')) {
                selectedTabs[i].classList.remove('slds-show');
                selectedTabs[i].classList.add('slds-hide');
                break;
            }
        }
        this.homeTabSelected = false;
        this.modalityTabSelected = false;
        this.siteSearchTabSelected = false;
        this.knowledgeArticleTabSelected = false;
    }

    //Handle Home tab click
    handleHomeTabClick() {
        this.resetSelectedContainer();
        if (this.refs.hometab.classList.contains('selectedtab')) {
            //
        } else {
            this.refs.hometab.classList.add('selectedtab');

        }
        if (this.refs.homecontainer.classList.contains('slds-show')) {
            //
        } else {
            this.refs.homecontainer.classList.add('slds-show');
        }

        if (this.showModalitySearch) {
            this.refs.modalitytab.classList.remove('selectedtab');
        }
        this.refs.sitesearchtab.classList.remove('selectedtab');
        this.refs.knowledgearticletab.classList.remove('selectedtab');
        this.refs.homecontainer.classList.remove('slds-hide');
        this.homeTabSelected = true;
    }

    //Handle Modality Search tab click
    handleModalitySearchClick() {
        this.resetSelectedContainer();
        if (this.refs.modalitytab.classList.contains('selectedtab')) {
            //
        } else {
            this.refs.modalitytab.classList.add('selectedtab');
        }
        this.refs.hometab.classList.remove('selectedtab');
        this.refs.sitesearchtab.classList.remove('selectedtab');
        this.refs.knowledgearticletab.classList.remove('selectedtab');
        this.refs.modalitycontainer.classList.remove('slds-hide');
        this.refs.modalitycontainer.classList.add('slds-show');
        this.modalityTabSelected = true;
    }

    //Handle Site Search tab click
    handleSiteSearchClick() {
        this.resetSelectedContainer();
        if (this.refs.sitesearchtab.classList.contains('selectedtab')) {
            //
        } else {
            this.refs.sitesearchtab.classList.add('selectedtab');
        }
        this.refs.hometab.classList.remove('selectedtab');
        if (this.showModalitySearch) {
            this.refs.modalitytab.classList.remove('selectedtab');
        }
        this.refs.knowledgearticletab.classList.remove('selectedtab');
        this.refs.sitesearchcontainer.classList.remove('slds-hide');
        this.refs.sitesearchcontainer.classList.add('slds-show');
        this.siteSearchTabSelected = true;
    }

    //Handle Knowledge Articles tab click
    handleKnowledgeArticleClick() {
        this.resetSelectedContainer();
        if (this.refs.knowledgearticletab.classList.contains('selectedtab')) {
            //
        } else {
            this.refs.knowledgearticletab.classList.add('selectedtab');
        }
        this.refs.hometab.classList.remove('selectedtab');
        if (this.showModalitySearch) {
            this.refs.modalitytab.classList.remove('selectedtab');
        }
        this.refs.sitesearchtab.classList.remove('selectedtab');
        this.refs.knowledgearticlecontainer.classList.remove('slds-hide');
        this.refs.knowledgearticlecontainer.classList.add('slds-show');
        this.knowledgeArticleTabSelected = true;
    }

    //Handle Change Region selection
    handleChangeRegion(event) {
        this.openConfirmationModal = true;
        this.changeSelectedCoast = event.detail.value;
    }

    //Handle Change Region confirmation
    closeRegionConfirmation() {
        this.openConfirmationModal = false;
    }

    //Handle Coast/Region Selection from Change Region menu
    handleCoastSelect() {
        this.selectedCoast = this.changeSelectedCoast;
        this.openConfirmationModal = false;
        if (this.selectedCoast === 'East Coast') {
            this.handleEastClick();
        } else if (this.selectedCoast === 'West Coast') {
            this.handleWestClick();
        }
        this.refs.sitesearchcmp.handleClearAll();
        this.refs.knowledgearticlecmp.refreshCategoryResult();
        this.template.querySelector('c-d-h_knowledge-search-base-l-w-c').resetSearchKey();
    }

    //Set Home tab as default tab
    handleHomeNavigation(event) {
        if (event.detail.navigatetocchome === true) {
            this.handleHomeTabClick();
        }
    }

    // Set detail page visibility : CC-646
    handleShowDetailPage(event) {
        this.showAccountDetailpage = event.detail.showaccountdetailpage;
        this.ccAccountDetailPageURL = event.detail.detailpageurl;
        this.template.querySelector('.accdet').classList.remove('slds-hide');
        this.template.querySelector('.sscomp').classList.add('slds-hide');
    }

    // Set detail page visibility : CC-646
    handleHideDetailPage(event) {
        this.showAccountDetailpage = event.detail.showAccountDetailpage;
        this.template.querySelector('.sscomp').classList.remove('slds-hide');
        this.template.querySelector('.accdet').classList.add('slds-hide');
    }
}