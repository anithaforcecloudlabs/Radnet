import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import fuselib from '@salesforce/resourceUrl/fusejs';
import markjs from '@salesforce/resourceUrl/markjs';
import TABLE_IMAGE from "@salesforce/resourceUrl/goingcamping";
import callDirectionAPI from '@salesforce/apex/MapApi.getDirection';
import mapApiAutocomplete from '@salesforce/apex/MapApi.searchPlaces';
import updateAccountXRLink from '@salesforce/apex/DH_SiteSearchOptions.updateAccountXRLink';
import MapUrl from '@salesforce/label/c.DH_Map_Url';
import MapUrlPrefix from '@salesforce/label/c.DH_Map_Url_Prefix';
import MapUrlSuffix from '@salesforce/label/c.DH_Map_Url_Suffix';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import isSiteSearchSuperUser from '@salesforce/customPermission/Site_Search_Super_User';
import ProfileName from '@salesforce/schema/User.Profile.Name';

export default class DH_siteSearchTable extends NavigationMixin(LightningElement) {
  @api records;
  @api initialsearchrecords = [];
  @api searchKey = '';
  @api inputaddressobject;
  @track selectedCons = [];
  descId;
  isSiteSort = true;
  isAsc = true;
  isDsc = false;
  sortedDirection = 'asc';
  @api sortedColumn = 'Name';
  @track
  dataVisible;
  dataCount;
  dataCountVisible;
  pageCountPlaceHolder = 'View: 25';
  noRecords = 25;
  fuseInitialized = false;
  showTable = true;
  pageCountmessage = '';
  disableCBCount = false;
  tableImage = TABLE_IMAGE;
  selectedSiteAddresses = [];
  showMapInput = false;
  mapUrl = MapUrl; // fetching this from custom label
  @api sortDistance = 'Alphabetical';
  @api disableSortOrder;
  @api distanceRadius = 25;
  @api distanceRadiusLabel = '25 Miles';

  //mapinput
  mapInput1 = '';
  mapInput2 = '';
  mapInputResult1 = [];
  mapInputResult2 = [];
  hasMapInput1 = false;
  hasMapInput2 = false;
  mapAddressObj1 = {};
  mapAddressObj2 = {};
  mapCons = [];
  mapAddress = [];
  //mapinput
  showRowDistance = false;
  @api hideTableImage = false;
  @api disableRadius = false;
  isFirstTimeSorted = false;
  isSiteSort = false;
  isDsc = false;
  @api scolumn = '';
  clearBtnDisable = true;
  @api showSpinner = false;

  isChecked = false;
  isChekedSKey = '';
  ssIdFromVF;
  timeoutID;
  hasSiteSearchSuperUser=false;
  perpage = [
    {
      id: 'menu-item-1',
      label: '10',
      value: 10,
    },
    {
      id: 'menu-item-2',
      label: '25',
      value: 25,
    },
    {
      id: 'menu-item-3',
      label: '50',
      value: 50,
    },
    {
      id: 'menu-item-4',
      label: 'All',
      value: 'All',
    },
  ];

  sortDistanceOptions = [
    {
      id: 'menu-item-1',
      label: 'Alphabetical',
      value: 'Alphabetical',
    },
    {
      id: 'menu-item-2',
      label: 'Distance',
      value: 'Distance',
    },
  ];

  milesOptions = [
    {
      id: 'menu-item-1',
      label: '1 Mile',
      value: 1,
    },
    {
      id: 'menu-item-2',
      label: '5 Miles',
      value: 5,
    },
    {
      id: 'menu-item-3',
      label: '15 Miles',
      value: 15,
    },
    {
      id: 'menu-item-4',
      label: '25 Miles',
      value: 25,
    },
    {
      id: 'menu-item-5',
      label: '50 Miles',
      value: 50,
    },
  ];

  isGuestUser = false;
  profileName = "";
  roleName = "";

  //Method used to get/set guest user
  @api
  get guestUser() {
    return this.mapUrl;
  }
  set guestUser(value) {
    if (value) {
      this.mapUrl = MapUrlPrefix + window.location.origin + MapUrlSuffix; // fetching prefix and suffix map url from custom label
      this.isGuestUser = true;
    }
  }

  //Method used to get User details CC-1245
  @wire(getRecord, { recordId: Id, fields: [ProfileName] })
  userDetails({ error, data }) {
      if (error) {
        console.log('error => '+JSON.stringify(error));
      } 
      else if (data) {
        this.profileName = (data.fields.Profile.value != null) ? data.fields.Profile.value.fields.Name.value : '';
      }
    }
  
  get checkEditVisible(){
    return (!this.isGuestUser && (this.profileName=='System Administrator' || this.hasSiteSearchSuperUser)) ;
  }

  //Method for Showing/ Hiding Account data table
  handleShowHideTable() {
    this.showTable = this.showTable ? false : true;
    if (!this.showTable) {
      this.refs.fullmap.classList.add('slds-size_3-of-3');
      this.refs.fullmap.classList.remove('slds-size_1-of-3');
    } else {
      this.refs.fullmap.classList.add('slds-size_1-of-3');
      this.refs.fullmap.classList.remove('slds-size_3-of-3');
    }
  }

  @api vfRoot;
  //Set No of records on main page to 25 default
  @api setNoOfRecords() {
    this.noRecords = 25;
    this.pageCountPlaceHolder = 'View: ' + this.noRecords;
  }

  //Method used to pass data to vfpage and add markers
  @api
  sendtovf() {
    let vfWindow = this.template.querySelector("iframe").contentWindow;
    vfWindow.postMessage(this.records, this.vfRoot);
    if (Object.keys(this.inputaddressobject).length !== 0) {
      this.sendToAddMarkerForInputAddressVF('AddMarkerForInputAddress', this.inputaddressobject.Latitude, this.inputaddressobject.Longitude, this.inputaddressobject.Address);
    }
  }

  //Default Sorting
  @api sortInitialLoad() {
    if (this.records) {
      this.isSiteSort = true;
      this.sortTableData('Name');
    }
  }

  connectedCallback() {
    this.hasSiteSearchSuperUser=isSiteSearchSuperUser; //CC-1245-Check if the user has the 'Site Search Super User' permission
    if (this.fuseInitialized) {
      return;
    }
    this.fuseInitialized = true;
    Promise.all([loadScript(this, fuselib), loadScript(this, markjs)])
      .then(
        () => {
          this.disableSortOrder = true;
          this.disableRadius = true;
          this.isFirstTimeSorted = false;
        })
      .catch((error) => {
        console.error('ERR : ' + error);
      });

    window.addEventListener("message", this.handleVFResponse.bind(this));// CC-646
  }

  // Get Record ID from VF Page :  CC-646
  handleVFResponse(message) {
    if (message.origin === this.vfRoot && message.data.name === 'idFromVfPage') {
      this.ssIdFromVF = message.data.payload;
      if (this.isGuestUser) {
        this.navigateToViewRecordPageCommunity(this.ssIdFromVF);
      } else {
        this.navigateToViewRecordPageSF(this.ssIdFromVF);
      }
    }
  }

  //Disable checkboxes if selected 2 checkboxes
  @api
  disableCheckboxes() {
    this.selectedCons = [];
    this.selectedSiteAddresses = [];
  }

  //Method to call after clearall
  @api
  handleClearAllData() {
    this.selectedCons = [];
    this.selectedSiteAddresses = [];
    this.distanceRadius = 25;
    this.distanceRadiusLabel = '25 Miles';
    this.noRecords = 25;
    this.sortDistance = 'Alphabetical';
    this.isAsc = true;
    this.isDsc = false;
    this.sortedDirection = 'asc';
    this.isChecked = false;
    //CC-645-To clear the checkbox on Clear All
    const checkbox = this.template.querySelector('lightning-input[data-id="exactMatchCheckbox"]');
    if (checkbox) {
      checkbox.checked = false;
    }
    this.handleMapInputClear();
  }

  //handle on checkbox select
  handleCheckboxSelect(event) {
    if (this.selectedCons.length === 0 && Object.keys(this.inputaddressobject).length !== 0) {
      this.selectedCons.push({
        Name: this.inputaddressobject.Address,
        Id: 'InputAddressValue',
        Latitude: this.inputaddressobject.Latitude,
        Longitude: this.inputaddressobject.Longitude,

      });
      this.selectedSiteAddresses.push({
        name: this.inputaddressobject.Address,
        id: 'InputAddressValue',
        address: this.inputaddressobject.Address
      });
    }

    if (event.target.checked == true) {
      this.selectedCons.push({
        Name: event.target.value,
        Id: event.target.dataset.id,
        Latitude: event.target.dataset.latitude,
        Longitude: event.target.dataset.longitude
      })
      this.selectedSiteAddresses.push({
        name: event.target.value,
        id: event.target.dataset.id,
        address: event.target.dataset.shippingstreet + ', ' + event.target.dataset.shippingcity + ', ' + event.target.dataset.shippingstate + ', ' + event.target.dataset.shippingpostalcode,
      })
      let selectRowId = event.target.dataset.id;
      const updatedData = this.records.map(item => {
        if (item.Id === selectRowId) {
          return { ...item, checkedbox: true };
        }
        return item;
      });
      this.records = updatedData;
      const updatedData2 = this.initialsearchrecords.map(item => {
        if (item.Id === selectRowId) {
          return { ...item, checkedbox: true };
        }
        return item;
      });
      this.initialsearchrecords = updatedData2;
    }
    if (event.target.checked == false) {
      this.selectedCons = this.selectedCons.filter(row => row.Id !== event.target.dataset.id);
      this.selectedSiteAddresses = this.selectedSiteAddresses.filter(row => row.id !== event.target.dataset.id);
      let selectRowId = event.target.dataset.id;
      const updatedData = this.records.map(item => {
        if (item.Id === selectRowId) {
          return { ...item, checkedbox: false };
        }
        return item;
      });
      this.records = updatedData;
      const updatedData2 = this.initialsearchrecords.map(item => {
        if (item.Id === selectRowId) {
          return { ...item, checkedbox: false };
        }
        return item;
      });
      this.initialsearchrecords = updatedData2;
    }
    if (this.selectedCons.length === 2 && this.selectedSiteAddresses.length === 2) {
      this.findDirections(this.selectedCons, this.selectedSiteAddresses);
      const updatedData = this.records.map(item => {
        if (item.checkedbox == false) {
          return { ...item, checkdisable: true };
        }
        return item;
      });
      this.records = updatedData;
      const updatedData2 = this.initialsearchrecords.map(item => {
        if (item.checkedbox == false) {
          return { ...item, checkdisable: true };
        }
        return item;
      });
      this.initialsearchrecords = updatedData2;
    }
    else if (this.selectedCons.length === 1) {
      this.sendToRemoveMarkerVF('RemoveMarker');
      const updatedData = this.records.map(item => {
        return { ...item, checkdisable: false };
      });
      this.records = updatedData;
      const updatedData2 = this.initialsearchrecords.map(item => {
        return { ...item, checkdisable: false };
      });
      this.initialsearchrecords = updatedData2;
    }

  }

  //Apex call for direction
  findDirections(selectedCons, selectedSiteAddresses) {
    let combinedUniqueIDForRoute = selectedCons[0].Id + selectedCons[1].Id;
    let sourceLatLongObj = {
      latitude: selectedCons[0].Latitude,
      longitude: selectedCons[0].Longitude
    }
    let destLatLongObj = {
      latitude: selectedCons[1].Latitude,
      longitude: selectedCons[1].Longitude
    }
    callDirectionAPI({ source: sourceLatLongObj, destination: destLatLongObj })
      .then(result => {
        let address1Coordinates = result.routes[0].geometry.coordinates;
        this.sendtoAnothervf('functionDirection', address1Coordinates, combinedUniqueIDForRoute, selectedSiteAddresses, result.routes[0].distance, result.routes[0].duration);
      })

      .catch(error => {
        console.error('Error fetching directions:', error);
      });
  }

  //Add markers for map
  @api
  sendToAddMarkerForInputAddressVF(functionName, latitude, longitude, address) {
    let vfWindow = this.template.querySelector("iframe").contentWindow;
    let message = {
      functionName: functionName,
      Address: address,
      Latitude: latitude,
      Longitude: longitude
    };
    vfWindow.postMessage(message, this.vfRoot);
  }

  //Remove markers if checkbox disselected/clearall hit
  @api
  sendToRemoveMarkerVF(removeMarker) {
    let vfWindow = this.template.querySelector("iframe").contentWindow;
    let message = {
      functionName: removeMarker
    };
    vfWindow.postMessage(message, this.vfRoot);
  }

  //Method used to send data to Vfpage
  @api
  sendtoAnothervf(functionName, address1Coordinates, combinedUniqueIDForRoute, selectedSiteAddresses, distance, duration) {
    let vfWindow = this.template.querySelector("iframe").contentWindow;
    let message = {
      type: 'fromLWC',
      functionName: functionName,
      routeId: combinedUniqueIDForRoute,
      parameters: address1Coordinates,
      selectedSiteAddresses: selectedSiteAddresses,
      distance: distance,
      duration: duration
    };
    vfWindow.postMessage(message, this.vfRoot);
  }

  handleSiteLinkNav(event) {
    this.descId = event.currentTarget.dataset.descid;
    if (this.isGuestUser) {
      this.navigateToViewRecordPageCommunity(this.descId);
    } else {
      this.navigateToViewRecordPageSF(this.descId);
    }
  }

  // Handle actual Navigation to View Record Page - Community
  navigateToViewRecordPageCommunity(rcId) {
    this[NavigationMixin.GenerateUrl]({
      type: 'standard__recordPage',
      attributes: {
        recordId: rcId,
        objectApiName: 'Account',
        actionName: 'view'
      },
    }).then(generatedUrl => {
      this.dispatchEvent(new CustomEvent('showaccountdetailpage', {
        detail: {
          showaccountdetailpage: true,
          detailpageurl: window.location.origin + generatedUrl
        }
      }));
    });
  }

  // Handle actual Navigation to View Record Page - Community
  navigateToViewRecordPageSF(rcId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: rcId,
        objectApiName: 'Account',
        actionName: 'view'
      },
      state: {
        c__source: 'SiteSaearch' //must be string
      }
    });
  }

  //Default sorting accounts
  sortSite() {
    this.sortTableData(this.scolumn);
  }

  //Method calls on update records 
  updateRecordsHandler(event) {
    this.dataVisible = [...event.detail.records];
    if(this.dataVisible && this.dataVisible.length>0){
        this.dataVisible = this.dataVisible.map(x => {
          x = {...x, showLink:true};
          x.xrLinkLabel= ((x.xrLinkLabel)?x.xrLinkLabel:x.Name);
          return x;
        });
      }
    else
    this.dataCount = event.detail.rccount;
    this.pageCountmessage = event.detail.pageCountmessage;
    this.dataCountVisible = this.dataCount > 0 ? true : false;
    this.disableCBCount = this.dataCount > 0 ? false : true;
    if (this.disableCBCount){
      this.refs.cbcount.classList.add('customComboBoxDisable');
    } else {
      this.refs.cbcount.classList.remove('customComboBoxDisable');
    }
    if (this.disableSortOrder) {
      this.refs.sorby.classList.add('customComboBoxDisable');
    } else {
      this.refs.sorby.classList.remove('customComboBoxDisable');
    }
    if (this.dataCountVisible) {
      this.unmarkKeywords();
      if (!this.isChecked) {
        setTimeout(() => {
          this.handleHighlight(this.searchKey);
        }, '200');
      } else {
        setTimeout(() => {
          this.handleHighlightSentence(this.searchKey);
        }, '200');
      }

    }
  }

  //Method to extend handle show more 
  handleShowMore(event) {
    const selectRowId = event.currentTarget.dataset.descid;
    const updatedData = this.records.map(item => {
      if (item.Id === selectRowId) {
        if (item.showmore == false) {
          return { ...item, showmore: true };
        }
        if (item.showmore == true) {
          return { ...item, showmore: false };
        }
      }
      return item;
    });
    this.records = [...updatedData];
    this.unmarkKeywords();
  }

   // CC-1245-Method to edit the X-Ray hour field in SiteSearchTable
   handleEdit(event){
    let btnName = event.target.name;
    let index = event.target.dataset.row;
    let accId = event.target.dataset.rowid;
    if(btnName=="success"){
      let ele = this.template.querySelector(`[data-id="${index}"]`);
      if(ele.value!=null && ele.value.trim()!=""){
        const updatedData = this.records.map(item => {
        if (item.Id === accId) {
          if (item.isLoading == false) {
            return { ...item, isLoading: true,showmore: false };
          }
        }
        return item;
      });
      this.records = [...updatedData];
        this.dataVisible[index].xrLinkLabel = ele.value;
        updateAccountXRLink({accountId:accId, linkLabel:ele.value}).then(res=>{
          const refreshEvent =new CustomEvent('datachanged');
          this.dispatchEvent(refreshEvent);
          this.dataVisible[index].showLink = !this.dataVisible[index].showLink;
      }).catch(err=>{
        console.log('error occurred '+JSON.stringify(err));
      })
    }   
   }
    else{
      this.dataVisible[index].showLink = !this.dataVisible[index].showLink;
    }     
  }

  get viewoptions() {
    return [
      { label: '10', value: 10 },
      { label: '25', value: 25 },
      { label: '50', value: 50 },
      { label: 'All', value: 'All' },
    ];
  }

  //Method for no of records changed
  handleNoRecChange(event) {
    if (event.detail.value) {
      this.noRecords = event.detail.value;
    }
  }

  // Hilight searched text inside tables
  handleHighlight(sKey) {
    var selected = this.template.querySelectorAll('.content');
    for (let i = 0; i <= selected.length; i++) {
      var ob = new Mark(selected[i]);
      ob.mark(sKey, { className: 'a0' });
    }
  }

  //Unmark previously highlighted keywords
  unmarkKeywords() {
    let selectedElem = this.template.querySelectorAll('.content');
    for (let i = 0; i <= selectedElem.length; i++) {
      let ob = new Mark(selectedElem[i]);
      ob.unmark();
    }
  }

  // Use Fuse Lib to perform search and scoring inside Modality Procedure table
  handleSearchTableData() {
    var recs = this.initialsearchrecords;
    const options = {
      includeScore: true,
      includeMatches: true,
      useExtendedSearch: true,
      matchAllTokens: true,
      shouldSort:true,
      //isCaseSensitive: this.isChecked ? true : false,
      threshold: this.isChecked ? -0.1 : 0.1,
      keys: [
        'Name',
        'siteGroup',
        'siteAddress',
        'alert',
        'modality',
        'submodality',
        'phone',
        'fax',
        'schedulingHours',
        'xRayHours',
        'xrLinkLabel',
        'taxID',
        'npi',
        'siteManager2',
      ]
    };
    const fuse = new Fuse(recs, options);
    this.records = fuse.search(this.fuseSearchKey);
    this.records = this.records.map(a => a.item);
    if (this.isChecked) {
      this.records = this.records.filter(a =>  JSON.stringify(a).toLocaleLowerCase().includes(this.searchKey.toLocaleLowerCase())
      );
    }
    this.records = [...this.records];
  }

  // Initiate Search inside table
  handleSearchChange(event) {
    this.unmarkKeywords();
    clearTimeout(this.timeoutID);    
    this.searchKey = event.target.value;
    this.timeoutID = setTimeout(() => {      
      if (this.searchKey) {
        this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey.trim());
        this.isSiteSort = false;
        setTimeout(() => {
          this.handleSearchTableData();
        }, '300');
      } else {
        this.records = this.initialsearchrecords;
        setTimeout(() => {
          this.resetDefaultSortColumn();
        }, '300');
      }
    }, 200);
  }

  //build fuse search key
  // changes for 645
  buildSearchKeyForFuse(sKey) {
    var skeyArr = [];
    var sKeyOR = '';
    var sKeyAnd = '';
    var returnSKey = '';
    this.isChekedSKey = sKey;
    skeyArr = sKey.split(' ');
    if (skeyArr.length === 1 && skeyArr != null) {
      returnSKey = "'" + sKey;
    }
    else if (skeyArr.length > 1 && !this.isChecked) {
      for (let i = 0; i < skeyArr.length; i++) {
        sKeyOR += " | " + skeyArr[i];
        sKeyAnd += " '" + skeyArr[i];
      }
      returnSKey = sKeyAnd + sKeyOR;
    }
    else if (skeyArr.length > 1 && this.isChecked) {
      for (let i = 0; i < skeyArr.length; i++) {
        sKeyAnd += " '" + skeyArr[i];
      }
      returnSKey = sKeyAnd;
    }
    else {
      returnSKey = "'" + sKey;
    }
    return returnSKey;
  }

  //CC-649-Highlight Exact match searched text inside tables 
  handleHighlightSentence(sKey) {
    let selected = this.template.querySelectorAll('.content');
    selected.forEach(element => {
      var ob = new Mark(element);
      ob.mark(sKey, {
        separateWordSearch: false,
        className: 'a0',
        //caseSensitive: true
      });
    });

  }

  //Initiate Search for exact match search text inside tables
  handleCheckboxChange(event) {
    this.isChecked = event.target.checked;
    this.unmarkKeywords();
    if (this.searchKey) {
      this.fuseSearchKey = this.buildSearchKeyForFuse(this.searchKey.trim());
      this.handleSearchTableData();
    }
  }

  //reset sort order for procedure column
  @api
  resetDefaultSortColumn() {
    this.sortTableDataAfterFuse(this.scolumn);
  }
  // Sorting after search inside table
  sortTableDataAfterFuse(sortColumnName) {
    // check arrow direction
    if (this.sortedDirection === 'asc') {
      this.isAsc = true;
      this.isDsc = false;
    } else {
      this.isAsc = false;
      this.isDsc = true;
    }

    // check reverse direction
    let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
    this.sortedColumn = sortColumnName;
    // sort the data
    this.records = JSON.parse(JSON.stringify(this.records)).sort((a, b) => {
      if (a[sortColumnName] === 'distances') {
        a[sortColumnName] = parseFloat(a[sortColumnName]);
      }

      if (sortColumnName === 'distances') {
        a = parseFloat(a[sortColumnName]) ? parseFloat(a[sortColumnName]) : 0;  // Handle null values
      } else {
        a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : '';  // Handle null values
      }

      if (sortColumnName === 'distances') {
        b = parseFloat(b[sortColumnName]) ? parseFloat(b[sortColumnName]) : 0;  // Handle null values
      } else {
        b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';  // Handle null values
      }

      return a > b ? 1 * isReverse : -1 * isReverse;
    });
  }

  // Sorting on modality procedure table
  @api sortTableData(sortColumnName) {
    if (this.sortedColumn === sortColumnName) {
      this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortedDirection = 'asc';
    }
    // check arrow direction
    if (this.sortedDirection === 'asc') {
      this.isAsc = true;
      this.isDsc = false;
    } else {
      this.isAsc = false;
      this.isDsc = true;
    }

    // check reverse direction
    let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
    this.sortedColumn = sortColumnName;
    // sort the data
    this.records = JSON.parse(JSON.stringify(this.records)).sort((a, b) => {
      if (a[sortColumnName] == 'distances') {
        a[sortColumnName] = parseFloat(a[sortColumnName]);
      }

      if (sortColumnName === 'distances') {
        a = parseFloat(a[sortColumnName]) ? parseFloat(a[sortColumnName]) : 0;  // Handle null values
      } else {
        a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : '';  // Handle null values
      }

      if (sortColumnName === 'distances') {
        b = parseFloat(b[sortColumnName]) ? parseFloat(b[sortColumnName]) : 0;  // Handle null values
      } else {
        b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';  // Handle null values
      }

      return a > b ? 1 * isReverse : -1 * isReverse;
    });
  }

  //Method to extend map
  handleShowHideMapPopup() {
    this.showMapInput = this.showMapInput ? false : true;
    if (this.showMapInput == true) {
      this.refs.signpost.classList.add('signPostSelected');
    } else {
      this.refs.signpost.classList.remove('signPostSelected');
    }
  }

  //Method used to handle dort by distance
  handleSortDistance(event) {
    if (event.detail.value) {
      this.sortDistance = event.detail.value;
      this.setSortColumn(this.sortDistance);
    }
  }

  //Method used to set sort by distance or Alphabetical
  @api setSortColumn(sortDistance) {
    if (sortDistance == 'Alphabetical') {
      this.scolumn = 'Name';
    } else if (sortDistance == 'Distance') {
      this.scolumn = 'distances';
    }
    this.setSortOrder(this.scolumn);
  }

  //Method used to call sortTableData
  @api setSortOrder(scolumn) {
    this.sortTableData(scolumn);
  }

  //Method used to set radius value
  onRadiusChange(event) {
    if (event.detail.value) {
      this.distanceRadius = event.detail.value;
      this.distanceRadiusLabel = this.distanceRadius > 1 ? this.distanceRadius + ' Miles' : this.distanceRadius + ' Mile';
    }
    this.postRadiusValueToParent(this.distanceRadius);

  }

  //Method used to send radius value to parent
  postRadiusValueToParent(distanceRadius) {
    this.dispatchEvent(new CustomEvent('radiusvalue', {
      detail: {
        radiusval: distanceRadius
      }
    }));
  }

  //Address input in map logic Integrate
  showAddressOptions1() {
    if (!this.mapInputResult1) {
      this.mapInputResult1 = this.mapInputResult1;
    }
  }

  //Method for address change input box inside map 1
  handleMapAddressChange1(event) {
    this.mapInput1 = event.target.value;
    if (this.mapInput1 == '' && this.mapInput1 == '') {
      this.clearBtnDisable = true;
    } else {
      this.clearBtnDisable = false;
    }
    if (this.mapInput1.length < 2) {
      this.mapInputResult1 = [];
      this.hasMapInput1 = false;
    }
    if (this.mapInput1.length > 2) {
      setTimeout(() => {
        mapApiAutocomplete({ query: this.mapInput1 })
          .then(result => {
            this.hasMapInput1 = true;
            this.mapInputResult1 = [];
            this.mapInputResult1 = result;

          })
          .catch(error => {
            this.error = error;
          });
        this.hasMapInput1 = false;
      }, 300);
    }
  }

  //Method used to set address value from input box 1
  selectSearchResultAddress1(event) {
    this.mapInput1 = event.currentTarget.dataset.address;
    this.mapInputResult1 = [];
    this.hasMapInput1 = false;
    this.mapAddressObj1 = {
      Id: 'MapInput1',
      Longitude: event.currentTarget.dataset.longitude,
      Latitude: event.currentTarget.dataset.latitude,
      Address: event.currentTarget.dataset.address
    };
    this.mapCons = [];
    this.mapAddress = [];
    if (Object.keys(this.mapAddressObj1).length !== 0 && Object.keys(this.mapAddressObj2).length !== 0) {
      this.mapCons.push({
        Name: this.mapAddressObj2.Address,
        Id: 'MapId2',
        Latitude: this.mapAddressObj2.Latitude,
        Longitude: this.mapAddressObj2.Longitude,
      }, {
        Name: this.mapAddressObj1.Address,
        Id: 'MapId1',
        Latitude: this.mapAddressObj1.Latitude,
        Longitude: this.mapAddressObj1.Longitude,
      });
      this.mapAddress.push({
        name: this.mapAddressObj2.Address,
        id: 'MapId2',
        address: this.mapAddressObj2.Address
      }, {
        name: this.mapAddressObj1.Address,
        id: 'MapId1',
        address: this.mapAddressObj1.Address
      });
      this.findDirections(this.mapCons, this.mapAddress);
    }
  }

  //Method for onleave Input box 1
  onLeaveMapAddressBox1(event) {
    setTimeout(() => {
      this.hasMapInput1 = false;
      this.mapInputResult1 = [];
    }, 300);
  }

  //Method to set address options input box 2 
  showAddressOptions2() {
    if (!this.mapInputResult2) {
      this.mapInputResult2 = this.mapInputResult2;
    }
  }

  //Method for address change input box inside map 2
  handleMapAddressChange2(event) {
    this.mapInput2 = event.target.value;
    if (this.mapInput1 == '' && this.mapInput1 == '') {
      this.clearBtnDisable = true;
    } else {
      this.clearBtnDisable = false;
    }

    if (this.mapInput2.length < 2) {
      this.mapInputResult2 = [];
      this.hasMapInput2 = false;
    }



    if (this.mapInput2.length > 2) {
      setTimeout(() => {
        mapApiAutocomplete({ query: this.mapInput2 })
          .then(result => {
            this.hasMapInput2 = true;
            this.mapInputResult2 = [];
            this.mapInputResult2 = result;
          })
          .catch(error => {
            this.error = error;
          });
        this.hasMapInput2 = false;
      }, 300);
    }
  }

  //Method used to set address value from input box 2
  selectSearchResultAddress2(event) {
    this.mapInput2 = event.currentTarget.dataset.address;
    this.mapInputResult2 = [];
    this.hasMapInput2 = false;
    this.mapAddressObj2 = {
      Longitude: event.currentTarget.dataset.longitude,
      Latitude: event.currentTarget.dataset.latitude,
      Address: event.currentTarget.dataset.address
    }
    this.mapCons = [];
    this.mapAddress = [];
    if (Object.keys(this.mapAddressObj1).length !== 0 && Object.keys(this.mapAddressObj2).length !== 0) {
      this.mapCons.push({
        Name: this.mapAddressObj2.Address,
        Id: 'MapId2',
        Latitude: this.mapAddressObj2.Latitude,
        Longitude: this.mapAddressObj2.Longitude,
      }, {
        Name: this.mapAddressObj1.Address,
        Id: 'MapId1',
        Latitude: this.mapAddressObj1.Latitude,
        Longitude: this.mapAddressObj1.Longitude,
      });
      this.mapAddress.push({
        name: this.mapAddressObj2.Address,
        id: 'MapId2',
        address: this.mapAddressObj2.Address
      }, {
        name: this.mapAddressObj1.Address,
        id: 'MapId1',
        address: this.mapAddressObj1.Address
      });
      this.findDirections(this.mapCons, this.mapAddress);
    }
  }

  //Method on leave input box 2
  onLeaveMapAddressBox2(event) {
    setTimeout(() => {
      this.hasMapInput2 = false;
      this.mapInputResult2 = [];
    }, 300);
  }

  // Method for clearing input box 1
  clearAdress1() {
    this.clearAdress1Val();
    this.clearMarkers();
    const updatedData = this.records.map(item => {
      return { ...item, checkdisable: false, checkedbox: false };
    });
    this.records = updatedData;
    const updatedData2 = this.initialsearchrecords.map(item => {
      return { ...item, checkdisable: false, checkedbox: false };
    });
    this.initialsearchrecords = updatedData2;
    this.selectedCons = [];//removing the values of selectedCons.
    this.selectedSiteAddresses = [];
  }

  // Method for clearing address input box 1
  clearAdress1Val() {
    this.mapInput1 = '';
    this.mapInputResult1 = [];
    this.hasMapInput1 = false;
    this.mapAddressObj1 = {};
    this.mapCons = [];
    this.mapAddress = [];
    if (this.mapInput1 == '' && this.mapInput1 == '') {
      this.clearBtnDisable = true;
    } else {
      this.clearBtnDisable = false;
    }
  }

  // Method for clearing address input box 2
  clearAdress2() {
    this.clearAdress2Val();
    this.clearMarkers();
    const updatedData = this.records.map(item => {
      return { ...item, checkdisable: false, checkedbox: false };
    });
    this.records = updatedData;
    const updatedData2 = this.initialsearchrecords.map(item => {
      return { ...item, checkdisable: false, checkedbox: false };
    });
    this.initialsearchrecords = updatedData2;
    this.selectedCons = [];//removing the values of selectedCons.
    this.selectedSiteAddresses = [];
  }

  // Method for clearing address input box 2
  clearAdress2Val() {
    this.mapInput2 = '';
    this.mapInputResult2 = [];
    this.hasMapInput2 = false;
    this.mapAddressObj2 = {};
    this.mapCons = [];
    this.mapAddress = [];
    if (this.mapInput1 == '' && this.mapInput1 == '') {
      this.clearBtnDisable = true;
    } else {
      this.clearBtnDisable = false;
    }
  }

  //Method for clear button inside map
  handleMapInputClear() {
    this.clearAdress1Val();
    this.clearAdress2Val();
    this.clearMarkers();
    const updatedData = this.records.map(item => {
      return { ...item, checkdisable: false, checkedbox: false };
    });
    this.records = updatedData;
    const updatedData2 = this.initialsearchrecords.map(item => {
      return { ...item, checkdisable: false, checkedbox: false };
    });
    this.initialsearchrecords = updatedData2;
    this.selectedCons = [];//removing the values of selectedCons.
    this.selectedSiteAddresses = [];
  }

  //Method to clear all markers
  clearMarkers() {
    this.sendToRemoveMarkerVF('removeAllMarkers');
    this.sendToRemoveMarkerVF('RemoveMarker');
    this.sendtovf();
  }

  //Method used to open input address on map on clicking signpost icon
  signpostMouseOver() {
    this.refs.signpost.classList.add('signPostSelected');
  }

  //Method used to close input address on map on clicking signpost icon
  signpostMouseOut() {
    if (this.showMapInput == false) {
      this.refs.signpost.classList.remove('signPostSelected');
    }
  }
}