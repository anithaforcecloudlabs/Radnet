import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPractice from '@salesforce/apex/DH_SiteSearchOptions.getPractice';
import getRIS from '@salesforce/apex/DH_SiteSearchOptions.getRIS';
import getModalities from '@salesforce/apex/DH_SiteSearchOptions.getModalities';
import getSubModalities from '@salesforce/apex/DH_SiteSearchOptions.getSubModalities';
import getsiteGroupOptions from '@salesforce/apex/DH_SiteSearchOptions.getsiteGroupOptions';
import searchSites from '@salesforce/apex/DH_SiteSearchController.searchSites';
import getVFOrigin from '@salesforce/apex/DH_SiteSearchOptions.getVFOrigin';
import isCurrentUserGuest from '@salesforce/apex/DH_SiteSearchOptions.isCurrentUserGuest';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import mapApiAutocomplete from '@salesforce/apex/MapApi.searchPlaces';
import mapApiDistance from '@salesforce/apex/MapApi.getDistances';
import {getAllTabInfo,setTabLabel,setTabIcon,focusTab} from 'lightning/platformWorkspaceApi';


export default class DH_siteSearch extends NavigationMixin(LightningElement) {
  practiceOptions = [];
  wiredPracticeList = [];
  selectedRIS = [];
  selectedPractices = [];
  selectedRegions = [];
  selectedModalities = [];
  selectedSubModalities = [];
  siteNameVal = '';
  inputAddressVal = '';
  wiredRISList = [];
  risOptions = [];
  wiredModalityList = [];
  wiredSubModalityList = [];
  modalityOptions = [];
  subModalityOptions = [];
  wiredRegionList = [];
  regionOptions = [];
  siteId = '';
  vfOrigin = '';
  siteCodeOrName = '';
  address = '';
  searchData = [];
  initialSearchRecords = [];
  showSSRBreadCrumb = false;
  disableClearAll = false;
  activeSections = ['A'];
  @api selectedcoast = '';
  @track inputAddressLongitude;
  @track inputAddressLatitude;
  @track distancesList = [];
  @track sitesInfoMap = {};
  @track siteList = [];
  @track inputAddressVal1;
  @track inputAddressObject = {};
  searchAddressResult = [];
  hasSearchAddress = false;
  radiusVal = 25;
  hasRadiusChanged = false;
  sortedDirection;
  sortedColumn;
  isGuestUser = false;

  // getting the user type of the user whether it is a guest user or not
  @wire(isCurrentUserGuest)
  userType(result) {
    if (result.data) {
      this.isGuestUser = result.data;
    }
    else if (result.error) {
      console.log('error found -> ' + JSON.stringify(result.error));
    }
  }

  // getting the vf origin from the org dynamically
  @wire(getVFOrigin)
  vfOrigin(result) {
    if (result.data) {
      if (this.isGuestUser === true) {
        this.vfOrigin = result.data.replace('--c', '').replace('vf.force.com', 'my.site.com');
      }
      else {
        this.vfOrigin = result.data;
      }
    }
    else if (result.error) {
      this.error = result.error;
    }
  };

  //Get Options for RIS Instance
  @wire(getRIS, { selectedCoast: '$selectedcoast' })
  wiredris(result) {
    this.wiredRISList = result;
    if (result.data) {
      this.risOptions = result.data.map((ris) => {
        return { 'label': ris.Name, 'value': ris.Name };
      });
      setTimeout(() => {
        this.refs.rislist.setOptions(this.risOptions, this.selectedRIS);
      }, '100');

      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.risOptions = undefined;
    }
  }

  //Get Options for practice
  @wire(getPractice, { regionList: "$selectedRIS", selectedCoast: '$selectedcoast' })
  wiredpractice(result) {
    this.wiredPracticeList = result;
    if (result.data) {
      let resData = JSON.parse(JSON.stringify(result.data));
      resData = resData.sort((a, b) => a.Name.localeCompare(b.Name));
      this.practiceOptions = resData.map((practice) => {
        return { 'label': practice.Name, 'value': practice.Name };
      });
      if (!this.selectedRIS.length > 0) {
        this.selectedPractices = [];
      }
      setTimeout(() => {
        this.refs.practicelist.setOptions(this.practiceOptions, this.selectedPractices);
      }, '100');
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.practiceOptions = undefined;
    }
  }

  //Get Options for Modalities
  @wire(getModalities)
  wiredmodality(result) {
    this.wiredModalityList = result;
    if (result.data) {
      this.modalityOptions = result.data.map((modality) => {
        return { 'label': modality.Modality__c, 'value': modality.Modality__c };
      });
      setTimeout(() => {
        this.refs.modalitylist.setOptions(this.modalityOptions, this.selectedModalities);
      }, '100');

      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.modalityOptions = undefined;
    }
  }

  //Get Options for Sub-Modalities
  @wire(getSubModalities, { modality: "$selectedModalities" })
  wiredSubModality(result) {
    this.wiredSubModalityList = result;

    if (result.data) {
      this.subModalityOptions = result.data.map((subModality) => {
        return { 'label': subModality, 'value': subModality };
      });
      if (!this.selectedModalities.length > 0) {
        this.selectedSubModalities = [];
      }
      setTimeout(() => {
        this.refs.subModalities.setOptions(this.subModalityOptions, this.selectedSubModalities);
      }, '100');
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.subModalityOptions = undefined;
    }
  }

  //Get Options for Region
  @wire(getsiteGroupOptions, { practicesList: "$selectedPractices", regionList: "$selectedRIS", selectedCoast: '$selectedcoast' })
  wiredregion(result) {
    this.wiredRegionList = result;
    if (result.data) {
      this.regionOptions = result.data.map((region) => {
        return { 'label': region, 'value': region };
      });
      if (!this.selectedRIS.length > 0 && !this.selectedPractices.length > 0) {
        this.selectedRegions = [];
      } else if (!this.selectedPractices.length > 0) {
        this.selectedRegions = [];
      }
      setTimeout(() => {
        this.refs.regionlist.setOptions(this.regionOptions, this.selectedRegions);
      }, '100');
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.regionOptions = undefined;
    }
  }

  get isSubmodalityDisabled() {
    return this.selectedModalities.length == 0;
  }

  connectedCallback() {
    setTimeout(() => {
      this.setCustomTabUI();
    }, 500);
    this.disableClearAll = !this.hasInputValue();
    //added by Harsha Vardhani for P360 for CC-489
    this.handleSiteCodeOrName();
  }

    async setCustomTabUI() {
    try {
        const allTabs = await getAllTabInfo();
        const matchingTab = allTabs.find(t =>
            t.url && (t.url.includes('Site_Search_Custom_Tab'))
        );

        if (matchingTab && matchingTab.tabId) {
        await setTabLabel(matchingTab.tabId, 'Site Search');
        await setTabIcon(matchingTab.tabId, 'standard:search', {
            iconAlt: 'Site Search'
        });
        await focusTab(matchingTab.tabId);
        } else {
        console.warn('Tab not found for Site_Search_Custom_Tab');
        }
    } catch (error) {
        console.error('Tab customization failed:', error);
    }
  }
  //added for P360 for CC-489
  handleSiteCodeOrName() {
    this.siteCodeOrName = window.sessionStorage.getItem('selectedValue');
    if (this.siteCodeOrName && this.siteCodeOrName.length !== 0) {
      this.siteId = window.sessionStorage.getItem('selectedRecordId');
      this.hasRadiusChanged = true;
      this.disableClearAll = !this.hasInputValue();
      this.getSearchData();
      window.sessionStorage.setItem('selectedValue', '');
      window.sessionStorage.setItem('selectedRecordId', '');
    }
  }

  //handle practice selection
  handlePracticeChange(event) {
    this.selectedPractices = event.detail.selectedoptionvalue;
    this.disableClearAll = !this.hasInputValue();
  }

  //handle RIS Instance selection
  handleRISChange(event) {
    this.selectedRIS = event.detail.selectedoptionvalue;
    this.disableClearAll = !this.hasInputValue();
  }

  //handle site group selection
  handleRegionChange(event) {
    this.selectedRegions = event.detail.selectedoptionvalue;
    this.disableClearAll = !this.hasInputValue();
  }

  //handle modality selection
  handleModalityChange(event) {
    this.selectedModalities = event.detail.selectedoptionvalue;
    this.disableClearAll = !this.hasInputValue();
  }

  //handle sub modality selection
  handleSubModalityChange(event) {
    this.selectedSubModalities = event.detail.selectedoptionvalue;
    this.disableClearAll = !this.hasInputValue();
  }

  //handle site name selection
  onSiteSelection(event) {
    this.siteCodeOrName = event.detail.selectedValue;
    this.siteId = event.detail.selectedRecordId;
    this.disableClearAll = !this.hasInputValue();
  }

  //Address logic Integrate
  showAddressOptions() {
    if (!this.searchAddressResult) {
      this.searchAddressResult = this.searchAddressResult;
    }
  }

  //handle input address
  handleAddressChange(event) {
    var timeOutId;
    this.inputAddressVal = event.target.value;
    this.disableClearAll = !this.hasInputValue();
    window.clearTimeout(timeOutId);
    if (this.inputAddressVal.length < 2) {
      this.searchAddressResult = [];
      this.hasSearchAddress = false;
    }
    if (this.inputAddressVal.length > 2) {
      timeOutId = setTimeout(() => {
        this.funAutocomplete();
      }, 300);

    } else {
      this.inputAddressObject = {};
    }
  }

  // autocomplete api callout to get list of address options 
  funAutocomplete() {
    mapApiAutocomplete({ query: this.inputAddressVal })
      .then(result => {
        this.hasSearchAddress = true;
        this.searchAddressResult = [];
        this.searchAddressResult = result;
      })
      .catch(error => {
        this.error = error;
      });
    this.hasSearchAddress = false;
  }

  //handle selection of address from input addres
  selectSearchResultAddress(event) {
    this.inputAddressVal = event.currentTarget.dataset.address;
    this.searchAddressResult = [];
    this.hasSearchAddress = false;
    this.inputAddressObject = {
      Longitude: event.currentTarget.dataset.longitude,
      Latitude: event.currentTarget.dataset.latitude,
      Address: event.currentTarget.dataset.address
    }
  }

  onLeaveAddressBox() {
    setTimeout(() => {
      this.hasSearchAddress = false;
      this.searchAddressResult = [];
    }, 300);
  }

  // Fetch data for Modality Procedure Table
  getSearchData() {
    if (!this.hasRadiusChanged) {
      this.refs.searchtable.handleClearAllData();
      this.radiusVal = 25;
    }
    if (this.hasInputValue()) {
      if (Object.keys(this.inputAddressObject).length === 0 && this.inputAddressVal.length > 0) {
        const evt = new ShowToastEvent({
          title: 'Please select correct address for search',
          message: '',
          variant: 'error',
        });
        this.dispatchEvent(evt);
      }
      else {
        searchSites({ region: this.selectedRIS, practice: this.selectedPractices, sitegroup: this.selectedRegions, siteCodeOrName: this.siteCodeOrName, address: this.address, modality: this.selectedModalities, Lat: this.inputAddressObject.Latitude, Longt: this.inputAddressObject.Longitude, siteRadius: this.radiusVal, selectedcoast: this.selectedcoast, subModality: this.selectedSubModalities })
          .then((result) => {

            if (result) {
              this.refs.searchtable.showSpinner = true;
              let tempdata = result.map(v => ({
                ...v, showmore: false,isLoading:false, modality: '', submodality: '', distances: '', duration: '', checkdisable: false, checkedbox: false,
              }));

              for (let i = 0; i < tempdata.length; i++) {
                tempdata[i].checkdisable = false;
                tempdata[i].checkedbox = false;

                if (tempdata[i]?.careProviderFacilitySpecialties) {
                  for (let j = 0; j < tempdata[i].careProviderFacilitySpecialties.length; j++) {
                    if (tempdata[i].careProviderFacilitySpecialties[j]?.name) {
                      if (tempdata[i].modality) {
                        tempdata[i].modality = tempdata[i].modality + ', ' + tempdata[i].careProviderFacilitySpecialties[j].name;
                      } else {
                        tempdata[i].modality = tempdata[i].careProviderFacilitySpecialties[j].name;
                      }
                      if (tempdata[i].submodality) {
                        tempdata[i].submodality = (tempdata[i].careProviderFacilitySpecialties[j].subModality) ? tempdata[i].submodality + ', ' + tempdata[i].careProviderFacilitySpecialties[j].subModality : tempdata[i].submodality.replaceAll(';', ',');
                      } else {
                        tempdata[i].submodality = (tempdata[i].careProviderFacilitySpecialties[j].subModality) ? tempdata[i].careProviderFacilitySpecialties[j].subModality.replaceAll(';', ',') : '';
                      }
                    }
                  }
                }
              }
              this.tempTabledata = tempdata;
              this.searchData = tempdata;
              this.initialSearchRecords = tempdata;
              this.error = undefined;
              this.showSSRBreadCrumb = this.searchData.length > 0;
              if (Object.keys(this.inputAddressObject).length !== 0 && this.inputAddressObject.constructor === Object) {  //find
                this.refs.searchtable.disableRadius = false;
                this.refs.searchtable.sortDistance = 'Distance';
                this.refs.searchtable.scolumn = 'distances';
                this.refs.searchtable.sortedColumn = 'distances';
                this.findLangLatOfInputAddress();
              } else {
                this.refs.searchtable.disableRadius = true;
                if (this.searchData.length > 0) {
                  this.sortTableData('Name');
                  this.searchData = this.tempTabledata;
                  this.initialSearchRecords = this.tempTabledata;
                  this.refs.searchtable.sortDistance = 'Alphabetical';
                  this.refs.searchtable.scolumn = 'Name';
                  this.refs.searchtable.sortedColumn = 'Name';
                }
                this.refs.searchtable.showSpinner = false;
              }

              setTimeout(() => {
                this.refs.searchtable.sendtovf();
                this.refs.searchtable.disableCheckboxes();
                this.refs.searchtable.hideTableImage = true;
                this.refs.searchtable.disableSortOrder = (this.inputAddressVal.length > 0 && this.searchData.length > 0) ? false : true;
              }, '200');
            }
          })
          .catch((error) => {
            this.error = error;
            this.searchData = undefined;
            console.log('error : ' + JSON.stringify(error));
          });
      }
    } else {
      const evt = new ShowToastEvent({
        title: 'Please make a selection to search results.',
        message: '',
        variant: 'error',
      });
      this.dispatchEvent(evt);
    }
    this.hasRadiusChanged = false;
  }

  //clear all options and selected values
  @api
  handleClearAll() {
    this.searchData = [];
    this.initialSearchRecords = [];
    this.selectedRIS = [];
    this.selectedPractices = [];
    this.selectedRegions = [];
    this.selectedModalities = [];
    this.selectedSubModalities = [];
    this.siteNameVal = '';
    this.siteId = '';
    this.inputAddressVal = '';
    this.refs.practicelist.clearAll();
    this.refs.rislist.clearAll();
    this.refs.regionlist.clearAll();
    this.refs.modalitylist.clearAll();
    this.refs.subModalities.clearAll();
    this.refs.searchtable.searchKey = '';
    this.refs.siteName.removeRecordOnLookup();
    this.showSSRBreadCrumb = this.searchData.length > 0;
    this.inputAddressObject = {};
    this.radiusVal = 25;
    setTimeout(() => {
      this.refs.searchtable.sendtovf();
    }, '200');
    this.refs.searchtable.handleClearAllData();
    this.refs.searchtable.hideTableImage = false;
    this.hasSearchAddress = false; //clear inputbox
  }

  //check if any option selected for search 
  hasInputValue() {
    let hasInput = (this.selectedRIS.length > 0 || this.selectedPractices.length > 0 || this.selectedRegions.length > 0 || this.selectedModalities.length > 0 || this.selectedSubModalities.length > 0 || this.siteNameVal.length > 0 || this.siteId.length > 0 || this.inputAddressVal.length > 0) ? true : false;
    return hasInput;
  }

  //Navigate to home page / bread crumbs
  navigateToHomePage() {
    if (this.isGuestUser) {
      const selectEvent = new CustomEvent('cchometab', {
        detail: { navigatetocchome: true }
      });
      this.dispatchEvent(selectEvent);
    } else {
      this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
          pageName: 'home'
        },
      });
    }
  }

  //find lat long for distance api
  async findLangLatOfInputAddress() {
    let srclatlong = {
      latitude: this.inputAddressObject.Latitude,
      longitude: this.inputAddressObject.Longitude
    }
    for (let i = 0; i < this.searchData.length;) {
      const accountSitesIdList = [];
      let destlatlong = [];
      let j;
      try {
        for (j = i; j < i + 24 && j < this.searchData.length; j++) {
          if (this.searchData[j].ShippingLatitude !== undefined && this.searchData[j].ShippingLongitude !== undefined) {
            let dest = {
              latitude: parseFloat(this.searchData[j].ShippingLatitude),
              longitude: parseFloat(this.searchData[j].ShippingLongitude)
            }
            destlatlong.push(dest);
            var Id = this.searchData[j].Id;
            accountSitesIdList.push(Id);
          }
        }
        this.siteList = accountSitesIdList;
      } catch (error) {
        console.log('error in for : ' + error);
      }
      await this.findDistance(srclatlong, destlatlong, accountSitesIdList);
      i = j;
    }
    this.sortTableData('distances');
    this.searchData = this.tempTabledata;
    this.initialSearchRecords = this.tempTabledata;
    this.refs.searchtable.showSpinner = false;
  }

  //distance api callout
  async findDistance(srclatlong, destlatlong, accountSitesIdList) {
    let result = await mapApiDistance({ source: srclatlong, destinations: destlatlong });
    if (result.length > 0) {

      for (let index = 0; index < accountSitesIdList.length; index++) {
        var distance = parseFloat(result[index].distance) / 1609.344;
        var duration = parseFloat(result[index].duration) / 3600;

        for (let i = 0; i < this.searchData.length; i++) {
          if (this.searchData[i].Id === accountSitesIdList[index]) {
            this.searchData[i].distances = distance.toFixed(2);
            this.searchData[i].duration = duration.toFixed(2);
          }
        }
      }
      this.searchData = [...this.searchData];
    }
  }

  //handle radius value selection
  handleRadiusValue(event) {
    this.radiusVal = event.detail.radiusval;
    this.hasRadiusChanged = true;
    this.getSearchData();
  }

  //default Sort table   
  sortTableData(sortColumnName) {
    this.sortedDirection = 'asc';
    // check reverse direction
    let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
    this.sortedColumn = sortColumnName;
    // sort the data
    this.tempTabledata = JSON.parse(JSON.stringify(this.tempTabledata)).sort((a, b) => {
      if (a[sortColumnName] == 'distances') {
        a[sortColumnName] = parseFloat(a[sortColumnName]);
      }
      if (sortColumnName === 'distances') {
        a = parseFloat(a[sortColumnName]) ? parseFloat(a[sortColumnName]) : 0;
      } else {
        a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : '';
      }
      if (sortColumnName === 'distances') {
        b = parseFloat(b[sortColumnName]) ? parseFloat(b[sortColumnName]) : 0;
      } else {
        b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';
      }
      return a > b ? 1 * isReverse : -1 * isReverse;
    });
  }

  // CC-646
  handleshowDetailPage(event) {
    if (event.detail.showaccountdetailpage) {
      this.dispatchEvent(new CustomEvent('showaccountdetailpage', {
        detail: {
          showaccountdetailpage: event.detail.showaccountdetailpage,
          detailpageurl: event.detail.detailpageurl
        }
      }));
    }
  }
 //Refresh Data CC-1245
  handledataChanged(){
      this.getSearchData();
  }
}