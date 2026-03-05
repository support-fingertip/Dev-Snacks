import { LightningElement, api, wire, track } from 'lwc';

export default class MultiPicklist extends LightningElement {
    placeholder = '';
    showDD=false;
    init = false; 
    isExpanded = false;
    isSelectAll = false;

   
    @api label;
    @api required;
    @api showpills;
    @api fromAura = false;
    @api optionsFromAura=[];

    connectedCallback() {
        if (!this.init) {
            // Set options from Aura if available
            if (this.fromAura && this.optionsFromAura) {
                this.options = this.optionsFromAura;  // Set options from Aura                
                // Initialize picklist only once
                const picklistElement = this.template.querySelector('.cmpl-input');
                if (picklistElement) {
                    picklistElement.setOptions(this.options);
                    picklistElement.setSelectedList();
                }
            }
            
        }
    }
@track _options = [];

@api
set options(value) {
    if (!value) {
        this._options = [];
        return;
    }

    // Normalize options — NO selection by default
    this._options = value.map(opt => ({
        label: opt.label,
        value: opt.value,
        show: true,
        checked: false
    }));

    // Reset UI state
    this.placeholder = '';
    this.isSelectAll = false;
}

get options() {
    return this._options;
}

    renderedCallback() {
    
        if(!this.init) {
            this.template.querySelector('.cmpl-input').addEventListener('click', (event) => {
                if(this.showDD) {
                    this.showDD = !this.showDD;
                } else {
                    let opts = this.options ? this.options.filter((element) => element.show).length : 0;
                    this.showDD = opts > 0;
                }
                event.stopPropagation();
            });
            this.template.addEventListener('click', (event) => {
                event.stopPropagation();
            });
            document.addEventListener('click', () => {
                this.showDD = false;
            });
            this.init=true;
        }
    }

    onSearch(event) {
        this.options.forEach(option => {
            option.show = option.label.toLowerCase().startsWith(event.detail.value.toLowerCase());
        });
        let filteredopts = this.options.filter((element) => element.show);
        this.showDD = false;
        if(filteredopts.length > 0) {
            this.showDD = true;
        }      
    }

    onSelect(event) {
        if(event.target.value == 'SelectAll') {
            this.options.forEach(option => {
                option.checked = event.target.checked;
            });
        } else {
            this.options.find(option => option.label === event.target.value).checked = event.target.checked;
        }         
        this.postSelect();
    }

    onRemove(event) {
        this.options.find(option => option.label === event.detail.name).checked = false;
        this.postSelect();        
    }

    postSelect() {
        try{
        let count = this.options.filter((element) => element.checked).length;

        let selectedItems = this.options.filter((element) => element.checked);
        var selectedValues='';
        selectedItems.forEach(option => {
            selectedValues +=option.value+';';
        });

        var retrunValue = selectedValues.substring(0, selectedValues.length - 1);
        const picklistSelectedEvent = new CustomEvent('picklistselected', {detail:  retrunValue });
        this.dispatchEvent(picklistSelectedEvent);

        this.placeholder = count > 0 ? count+ ' Item(s) Selected' : '';
        this.isSelectAll = (count == this.options.length);
        if(this.showpills) {
            let evnt = setInterval(() => {
                if(count > 1){
                    if(this.template.querySelector('[role="listbox"]').getBoundingClientRect().height > 
                        (this.template.querySelectorAll('[role="pill"]')[0].getBoundingClientRect().height+10)) {
                       
                    } else {
                       
                    }
                }
                clearInterval(evnt);
            }, 200);
        }
        if(this.required) {
            if(count == 0) {
                this.template.querySelector('.cmpl-input').setCustomValidity('Please select item(s)');
            } else {
                this.template.querySelector('.cmpl-input').setCustomValidity('');
            }            
            this.template.querySelector('.cmpl-input').reportValidity();
        }
    }catch(e){

    }
        
    }

    get showPillView() {
        if(this.showpills) {
            let count = this.options ? this.options.filter((element) => element.checked).length : 0;
            return this.showpills && count > 0;
        }
        return false;
    }

   

    @api
    getSelectedList() {
        return this.options.filter((element) => element.checked).map((element) => element.label).join(';');
    }

    @api
    setSelectedList(selected) {
        selected?.split(';').forEach(name => {
            this.options.find(option => option.label === name).checked = true;
        });
        this.postSelect();
    }

    @api
    setOptions(opts) {
        this.options = opts.map(opt => {return {"label": opt.label, "value": opt.value, "show": true, "checked":false}});
    }

    @api
    isValid() {
        if(this.required) {
            let count = this.options ? this.options.filter((element) => element.checked).length : 0;
            if(count == 0) {
                this.template.querySelector('.cmpl-input').setCustomValidity('Please select item(s)');
                this.template.querySelector('.cmpl-input').reportValidity();
                return false;
            }            
        }
        return true;
    }

}