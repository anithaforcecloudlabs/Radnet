import { LightningElement, api, track } from "lwc";


export default class PreviewFileModal extends LightningElement {
  @api url;
  @api fileExtension;
  @api files;
  showFrame = false;
  showModal = false;
  @api show() {
    if (this.fileExtension === "pdf") this.showFrame = true;
    else this.showFrame = false;
    this.showModal = true;
  }

  records; //All records available in the data table
  totalRecords; //Total no.of records
  pageSize; //No.of records to be displayed per page
  totalPages; //Total no.of pages
  @api pagenumber; //Page number    
  @track recordsToDisplay = [];

  connectedCallback() {
    this.records = this.files; //All records available in the data table
    this.totalRecords = this.files.length; //Total no.of records
    this.pageSize = 1; //No.of records to be displayed per page
    this.totalPages = Math.ceil(this.totalRecords / this.pageSize); //Total no.of pages
    if (this.pagenumber <= 1) {
      this.pagenumber = 1;
    } else if (this.pagenumber >= this.totalPages) {
      this.pagenumber = this.totalPages;
    }
    // set records to display on current page 
    for (let i = (this.pagenumber - 1) * this.pageSize; i < this.pagenumber * this.pageSize; i++) {
      if (i === this.totalRecords) {
        break;
      }
      this.recordsToDisplay.push(this.records[i]);
    }
  }

  get paginationDisableFirst() {
    return this.pagenumber == 1;
  }
  get paginationDisableLast() {
    return this.pagenumber == this.totalPages;
  }

  handleRecordsPerPage(event) {
    this.pageSize = event.target.value;
    this.paginationHelper();
  }
  previousPage() {
    this.pagenumber = this.pagenumber - 1;
    this.paginationHelper();
  }
  nextPage() {
    this.pagenumber = this.pagenumber + 1;
    this.paginationHelper();
  }
  firstPage() {
    this.pagenumber = 1;
    this.paginationHelper();
  }
  lastPage() {
    this.pagenumber = this.totalPages;
    this.paginationHelper();
  }

  paginationHelper() {
    this.recordsToDisplay = [];
    // calculate total pages
    this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
    // set page number 
    if (this.pagenumber <= 1) {
      this.pagenumber = 1;
    } else if (this.pagenumber >= this.totalPages) {
      this.pagenumber = this.totalPages;
    }
    // set records to display on current page 
    for (let i = (this.pagenumber - 1) * this.pageSize; i < this.pagenumber * this.pageSize; i++) {
      if (i === this.totalRecords) {
        break;
      }
      this.recordsToDisplay.push(this.records[i]);
    }
  }

  closeModal() {
    this.showModal = false;
  }

}