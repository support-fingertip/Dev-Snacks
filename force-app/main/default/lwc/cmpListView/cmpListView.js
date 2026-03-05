import { LightningElement,track,api } from 'lwc';
import getPickValues from '@salesforce/apex/MasterDetail.getPickValues'
import searchRecords from '@salesforce/apex/MasterDetail.searchRecords'
import custom_icons from '@salesforce/resourceUrl/custom_icons';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class cmpPopup extends LightningElement {
    @track isShowModal = true;
    @track selectedItems = []; 
    @track options =  {}; 
    filter =  {};
    fields  = ['Name','Id', 'MRP__c','TAX_Per_GST__c', 'Description__c'];
    @track items = [];
    @api objectName = 'Product__c';
    @track formfactor= '';
    @track cardview= true;
    @track currencysymbol = '';

     
    connectedCallback() {  
        this.formfactor = FORM_FACTOR;
        this.currencysymbol = custom_icons+'/custom_icons/symbols.svg#Rupee'
        if(this.formfactor == 'Large'){
           this.cardview = false;
        }else{
            this.cardview = true; 
        }
        
    }
    renderedCallback() {  
        this.loadFilters();
    }
    @api  showModalBox() {  
        this.isShowModal = true;
    }
    hideModalBox() {  
        this.isShowModal = false;
    }
    changeView(){
        this.cardview = !this.cardview;
    }
     
    handleFilterChange(event){ 
        this.filter[event.target.dataset.field] = event.target.value;
    }
    loadFilters(){ 
        let filters = this.template.querySelectorAll('[data-use="filter"]'); 
        for(var i=0;i<filters.length;i++){
          this.filter[filters[i].dataset.field] = null;
        }
        let picklists = this.template.querySelectorAll('[data-type="picklist"]'); 
        for(var i=0;i<picklists.length;i++){
            this.loadPickList( this.objectName,filters[i].dataset.field)
        }
 	}
    loadPickList(object,field){
 		getPickValues({ objectName: object, fieldName: field })
		.then(result => {
             this.options[field ] = result ;
  		})
		.catch(error => {
			this.error = error;
			this.accounts = undefined; 
		})
	} 
    searchRecordsCall(){ 
        let wherefilter = ''
        console.log(this.filter);
        for (const property in this.filter) {
            if(this.filter[property]){
                wherefilter = wherefilter + ( wherefilter !='' ? ' AND ': ' where ' ) + property +'=\'' + this.filter[property] + '\' '
            } 
        }  
         
        this.items = [];
        searchRecords({ objectName: this.objectName, fields :this.fields.join() , filter: wherefilter  })
		.then(result => {
             let items = JSON.parse(  JSON.stringify(result)  ) ;
             let selectedItems = this.selectedItems
             items.forEach(function( item ){
                 item.Quantity__c = 0;
                 item.Discount__c = 0;
                 if(selectedItems){
                    item.selected =  selectedItems.find( data=> data.Id === item.Id )? true:false;
                }

             }) 

 
             this.items = items;
 		})
		.catch(error => {
			this.error = error;
			this.accounts = undefined;
		})
    }   
    onselectItem(event){
        for(let i = 0; i < this.items.length; i++) {
            if( this.items[i].Id == event.currentTarget.dataset.id && ( event.currentTarget.dataset.cart == 'out' || event.target.checked ) ){
                console.log(this.selectedItems.find( data=> data.Id === this.items[i].Id ))
                if(! this.selectedItems.find( data=> data.Id === this.items[i].Id ) ){
                    this.items[i].selected = true; 
                    this.selectedItems.push(this.items[i]);
                }
            }else
            if( this.items[i].Id == event.currentTarget.dataset.id && ( event.currentTarget.dataset.cart == 'in' || !event.target.checked )  ){
                if( this.selectedItems.find( data=> data.Id === this.items[i].Id ) ){
                    this.items[i].selected = false; 
                    const index = this.selectedItems.indexOf(this.items[i]);
                    this.selectedItems.splice(index, 1);
                 }
            } 
        }  
    }  
    onselectAll(event){ 
        for(let i = 0; i < this.items.length; i++) {
            if(  event.target.checked){
                if(! this.selectedItems.includes(this.items[i])){
                    this.selectedItems.push(this.items[i]);
                }
            }
            if( ! event.target.checked){
                if(this.selectedItems.includes(this.items[i])){
                    const index = this.selectedItems.indexOf(this.items[i]);
                    this.selectedItems.splice(index, 1);
                 }
            } 
        } 
        if(  event.target.checked){ 
            this.template.querySelectorAll('.checkbox').forEach(function(element) {  
                element.checked = true;
             }) 
        }
        if( ! event.target.checked){
            this.template.querySelectorAll('.checkbox').forEach(function(element) {  
                element.checked = false;
             }) 
        }
    } 
    addItemsEvent(){ 
        const selectedEvent = new CustomEvent('itemsadded', { 'detail':   this.selectedItems});
        this.dispatchEvent(selectedEvent); 
        this.isShowModal = false; 
        this.items = [];
        this.selectedItems = [];
     }
     cancelEvent(){    
        const eventCancel = new CustomEvent('eventcancel', { 'detail':  ''});
        this.dispatchEvent(eventCancel); 
        this.isShowModal = false; 
        this.items = [];
        this.selectedItems = [];
     }
}