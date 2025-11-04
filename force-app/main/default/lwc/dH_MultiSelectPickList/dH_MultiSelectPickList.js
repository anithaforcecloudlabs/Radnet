import { LightningElement, api } from 'lwc';

export default class DH_MultiSelectPickList extends LightningElement {
    placeholder = '';
    showDD = false;
    init = false;
    isExpanded = false;
    isSelectAll = false;
    finalSelectedList = [];
    @api selectedOptions = [];
    selecetedVal = '';
    @api options = [];
    @api label;
    @api required;
    @api showpills;
    @api disabled = false;
    showSelectedPill = false;
    showAll = true;
    showResult = false;
    showOptList = true;
    searchKey = '';
    isClearAllClicked = false;

    //renderedCallback handled button click events and dropdown visibility
    renderedCallback() {
        if (!this.init && !this.disabled) {
            this.template.querySelector('.cmpl-input').addEventListener('click', (event) => {
                if (this.showDD) {
                    this.showDD = !this.showDD;
                } else {
                    this.searchFun('');
                    if (this.options.length > 0) {
                        this.showDD = true;
                        this.showResult = true;
                        let opts = this.options ? this.options.filter((element) => element.show).length : 0;
                        if (!this.isClearAllClicked) {
                            this.showDD = opts > 0;
                        }
                        this.isClearAllClicked = false;

                    } else {
                        this.showResult = false;
                        this.showDD = true;
                    }
                }

                this.dispatchDDVisible;
                event.stopPropagation();

            });
            this.template.addEventListener('click', (event) => {
                event.stopPropagation();
            });
            document.addEventListener('click', () => {
                this.showDD = false;
            });
            this.resetOptions();
            this.init = true;
        }

        this.template.querySelector('.cmpl-input').addEventListener('blur', (event) => {
            this.showDD = false;
            this.dispatchDDVisible;
        });
    }

    //handle search key change inside dropdown
    onSearch(event) {
        this.searchKey = event.detail.value.toLowerCase();
        this.searchFun(this.searchKey);
    }

    get pillContainerClass() {
        return this.disabled ? 'slds-pill_container slds-input-has-icon slds-input-has-icon_left-right cmpl-input pillContainerDisabled' : 'slds-pill_container slds-input-has-icon slds-input-has-icon_left-right cmpl-input '
    }

    //search keywords inside dropdown options
    searchFun(key) {
        this.showAll = true;
        this.showOptList = false;
        this.options.forEach(option => {
            option.show = option.label.toLowerCase().includes(key);
            this.showAll = true;
            if (key.toLowerCase() != 'all' && key != '') {
                this.showAll = false;
            } else {
                this.showAll = true;
            }
        });

        let filteredopts = this.options.filter((element) => element.show);
        if (filteredopts.length > 0) {
            this.showOptList = true;
            this.init = true;
            this.showAll = true;
        } else {
            this.showDD = true;
        }
    }

    //reset dropdown options
    resetOptions() {
        this.options.forEach(option => {
            option.show = true;
        });
    }

    //handle dropdown option selection
    onSelect(event) {
        if (event.target.value == 'SelectAll') {
            this.options.forEach(option => {
                option.checked = event.target.checked;
            });
        } else {
            this.options.find(option => option.label === event.target.value).checked = event.target.checked;
        }
        this.postSelect();
    }

    //handle dropdown all selection
    onSelectAllFromRow() {
        this.options.forEach(option => {
            if (this.isSelectAll == true) {
                option.checked = false;
            } else {
                option.checked = true;
            }
        });
        this.postSelect();
    }

    //row selection
    onSelectFromRow(event) {
        this.options.find(option => option.label === event.currentTarget.dataset.label).checked =
            !this.options.find(option => option.label === event.currentTarget.dataset.label).checked;
        this.postSelect();
    }

    // clear all selected options 
    @api
    clearAll() {
        this.options.forEach(option => {
            option.checked = false;
        });
        this.SelectAll = false;
        this.isClearAllClicked = true;
        this.searchKey = '';
        this.searchFun(this.searchKey);
        this.init = true;
        this.postSelect();
    }

    //handle unchec of option
    onRemove(event) {
        this.options.find(option => option.label === event.detail.name).checked = false;
        this.postSelect();
    }

    // perform post selection operations of dropdown value 
    postSelect() {
        this.finalSelectedList = this.options.filter((element) => element.checked);
        this.selectedOptions = this.finalSelectedList.map((val) => {
            return val.value;
        });
        let count = this.options.filter((element) => element.checked).length;
        if (count === 1) {
            this.placeholder = this.finalSelectedList[0].value;
        } else if (count > 1) {
            this.placeholder = count + ' Options Selected';
        } else {
            this.placeholder = '';
        }
        this.showSelectedPill = count > 0 ? true : false;
        this.isSelectAll = (count == this.options.length);
        if (this.required) {
            if (count == 0) {
                this.template.querySelector('.cmpl-input').setCustomValidity('Please select item(s)');
            } else {
                this.template.querySelector('.cmpl-input').setCustomValidity('');
            }
            this.template.querySelector('.cmpl-input').reportValidity();
        }
        this.dispatchValueChange();
    }

    //get selected value from parent
    @api
    getSelectedList() {
        return this.options.filter((element) => element.checked).map((element) => element.label).join(';');
    }

    //set selected value in dropdown options from parent
    @api
    setSelectedList(selected) {
        selected?.split(';').forEach(name => {
            this.options.find(option => option.label === name).checked = true;
        });
        this.postSelect();
    }

    // set list of options from parent
    @api
    setOptions(opts, selectedOpts) {
        this.options = opts.map(opt => { return { "label": opt.label, "value": opt.value, "show": true, "checked": false } });
        if (selectedOpts.length > 0) {
            this.options.filter(function (obj) {
                if (selectedOpts.indexOf(obj.value) !== -1) {
                    obj.checked = true;
                }
            });
        } else {
            this.options.filter(function (obj) {
                obj.checked = false;
            });
        }
        this.postSelect();
    }

    //validation on options if required
    @api
    isValid() {
        if (this.required) {
            let count = this.options ? this.options.filter((element) => element.checked).length : 0;
            if (count == 0) {
                this.template.querySelector('.cmpl-input').setCustomValidity('Please select item(s)');
                this.template.querySelector('.cmpl-input').reportValidity();
                return false;
            }
        }
        return true;
    }

    //send selected values to parent
    dispatchValueChange() {
        this.dispatchEvent(new CustomEvent('valuechange', { detail: { selectedoptionvalue: this.selectedOptions } }));
    }

}