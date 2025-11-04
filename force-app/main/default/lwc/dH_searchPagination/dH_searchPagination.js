import { LightningElement, api, track } from 'lwc';
import DH_PaginationRecordCount from '@salesforce/label/c.DH_PaginationRecordCount';
export default class DH_searchPagination extends LightningElement {
    @track data = [];
    @track page = 1;
    perpage = 10;
    @track pages = [];
    set_size=5;
    totalRecords;
    showPage = false;
  
    get records() {
      return this.visibleRecords;
    }

    @api
    set records(compdata) {
      if (compdata) {
        this.pages = [];
        this.page = 1;
        this.data = compdata;
        this.totalRecords = compdata;
        if (this.data) {
          this.showPage = true;
        }
        this.setPages(this.data);
        this.updateRecords();
      }
    }

    connectedCallback() {
      this.perpage = DH_PaginationRecordCount;
    }
  
    renderedCallback() {
      this.renderButtons();
    }

    renderButtons = () => {
      this.template.querySelectorAll('button').forEach((but) => {
        but.style.backgroundColor = this.page === parseInt(but.dataset.id, 10) ? '#0070D2' : 'white';
        but.style.color = this.page === parseInt(but.dataset.id, 10) ? 'white' : 'black';
      });
    } 
    
    get pagesList() {
      let mid = Math.floor(this.set_size / 2) + 1;
      if (this.page > mid) {
        return this.pages.slice(this.page - mid, this.page + mid - 1);
      }
      return this.pages.slice(0, this.set_size);
    }

    setPages = (data) => {
      let numberOfPages = Math.ceil(data.length / this.perpage);
      for (let index = 1; index <= numberOfPages; index++) {
        this.pages.push(index);
      }
      this.updateRecords();
    } 

    get disablePrevious() {
      return this.page <= 1;
    }

    get disableNext() {
      return this.page >= this.pages.length;
    }

    get hasPrev() {
      return this.page > 1;
    }
  
    get hasNext() {
      return this.page < this.pages.length
    }
  
    onNext = ()=>{
          ++this.page;
          this.updateRecords();
      }

   onFirst = ()=>{   
        this.page=1;     
        this.updateRecords();
        
    }  
  
    onPrev = ()=>{
        --this.page;
        this.updateRecords();
    }

    onLast = ()=>{
      this.page=this.pages.length
        this.updateRecords();
    }
  
    onPageClick = (e)=>{
        this.page = parseInt(e.target.dataset.id,10);
        this.updateRecords();        
    }
  
    get currentPageData(){
      return this.pageData();
    }

    pageData = () => {
      let page = this.page;
      let perpage = this.perpage;
      let startIndex = (page * perpage) - perpage;
      let endIndex = (page * perpage);
      return this.data.slice(startIndex, endIndex);
    } 

    updateRecords() {
      this.visibleRecords = this.pageData();
      this.dispatchEvent(new CustomEvent('update', {detail: {records: this.visibleRecords, rccount: this.totalRecords.length}}));
    }
  }