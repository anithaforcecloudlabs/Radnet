import { LightningElement, api, track } from 'lwc';

export default class DH_searchPagination extends LightningElement {
  @track data = [];
  @track page = 1;
  @api perpage = 25;
  @track pages = [];
  set_size = 5;
  totalRecords;
  showPage = false;
  @api totalnorecords;
  recfrom = 1;
  recto = 25;
  pageCountmessage = '';
  hasRecs = false;

  get totalrecordsm() {
    return this.totalnorecords;
  }
  @api set totalrecordsm(totalrec) {
    this.pages = [];
    this.page = 1;
    this.totalnorecords = totalrec;
    this.recfrom = 0;
    if ((this.recfrom + this.perpage) < this.totalnorecords) {
      this.recto = this.perpage;
    }
    else {
      this.recto = this.totalnorecords;
    }
    this.recfrom++;
    this.setPages(this.totalnorecords);
  }
  get perpagem() {
    return this.perpage;
  }
  @api set perpagem(recperpage) {
    this.pages = [];
    this.page = 1;
    if (recperpage == 'All') {
      this.perpage = this.totalnorecords;
    }
    else {
      this.perpage = Number(recperpage);
    }

    this.recfrom = 0;
    if ((this.recfrom + this.perpage) < this.totalnorecords) {
      this.recto = this.perpage;
    }
    else {
      this.recto = this.totalnorecords;
    }
    this.recfrom++;
    this.setPages(this.totalnorecords);
  }
  get records() {
    return this.visibleRecords;
  }

  @api
  set records(compdata) {
    if (compdata) {
      // this.pages = [];
      // this.page = 1;
      this.data = compdata;
      this.totalRecords = compdata;
      if (this.data) {
        this.showPage = true;
      }

      //this.setPages(this.data);
      this.updateRecords();
    }
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
    let numberOfPages = Math.ceil(data / this.perpage);
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

  onNext = () => {
    ++this.page;
    this.recfrom = (this.page - 1) * this.perpage;
    if ((this.recfrom + this.perpage) < this.totalnorecords) {
      this.recto = this.recfrom + this.perpage;
    }
    else {
      this.recto = this.totalnorecords;
    }
    this.recfrom++;
    this.updateRecords();
  }

  onPrev = () => {
    --this.page;
    this.recfrom = (this.page - 1) * this.perpage;
    if ((this.recfrom + this.perpage) < this.totalnorecords) {
      this.recto = this.recfrom + this.perpage;
    }
    else {
      this.recto = this.totalnorecords;
    }
    this.recfrom++;
    this.updateRecords();
  }

  onPageClick = (e) => {
    this.page = parseInt(e.target.dataset.id, 10);
    this.recfrom = (this.page - 1) * this.perpage;
    if ((this.recfrom + this.perpage) < this.totalnorecords) {
      this.recto = this.recfrom + this.perpage;
    }
    else {
      this.recto = this.totalnorecords;
    }
    this.recfrom++;
    this.updateRecords();
  }

  get currentPageData() {
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
    this.hasRecs = this.totalRecords > 0 ? true : false;
    this.pageCountmessage = this.recfrom + ' to ' + this.recto + ' of ' + this.totalnorecords + ' results ';
    this.visibleRecords = this.pageData();
    this.dispatchEvent(new CustomEvent('update', { detail: { records: this.visibleRecords, rccount: this.totalnorecords, pageCountmessage: this.pageCountmessage } }));
  }
}