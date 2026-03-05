import {LightningElement, track,api} from 'lwc';

//APEX-Methods
import getPickValues from '@salesforce/apex/MasterDetail.getPickValues'
import saveRecords from '@salesforce/apex/MasterDetail.saveRecords'  
import readRecords from '@salesforce/apex/MasterDetail.readRecords'  
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';


import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class masterDetail extends NavigationMixin(LightningElement){
   
    @api   recordId = 'a0B5g00000rUrJhEAK';
    @api   records  =  {'accounts':[], 'orders':[], 'order_items':[],'visits' : [] ,'products':[]};
    @track record={ "Store__r":{ "Name":"" } ,"EID__c":""};
    @track items = [];  

    @track totalAmount = 0 ; 
    @track totalTax = 0 ; 
    @track totalDiscount = 0 ; 
    @track grantTotal = 0 ; 
    @track EID__c ; 
    @track showSearchList = false;
    @track formfactor= '';
    @track cardview= true;

    connectedCallback(){   
        this.formfactor = FORM_FACTOR;
        if(this.formfactor == 'Large'){
            this.cardview = false;
         }else{
             this.cardview = true;
         }
        if(this.recordId && !this.EID__c){
            this.readRecordsCall()
        }
        if( ! this.recordId && this.EID__c){
            this.parseRecords()
        }
        if( ! this.recordId && ! this.EID__c){
            this.record.EID__c =  new Date().getTime();
            this.addNewRow();
        }
    }
    parseRecords(){ 
            this.record =  this.records.orders.find(data => data.EID__c  === this.EID__c);
            this.items =   this.records.order_items.find(  data  => { data.EID__c.startsWith(this.EID__c )       }  ) ;
            this.items.forEach( function( data,index){  data.index=index;}); 
            if(!this.record.EID__c == ""){ 
                this.record.EID__c =  new Date().getTime();
            }  
    } 
    readRecordsCall(){ 
        readRecords({ 'recordId' : this.recordId })
        .then((result) => {
            if(result != null){
                console.log(result);  
                 this.records =  JSON.parse(JSON.stringify(  result ) );
                 let items = JSON.parse(JSON.stringify( result.order_items )) ;
                 let record = JSON.parse(JSON.stringify( result.orders.find( data  =>  data.Id  === this.recordId ) ));
                 items.forEach( function( data,index){  data.index=index;}); 
                 this.items =    items ;               
                 this.record =   record;       
   
            }
        })
        .catch((error) => { 
            this.error = error;
            this.selectedRecord = {};
        });  

    }
    saveRecordsCall() {  
        this.records.order_items = this.items;
        this.records.orders =  this.records.orders.push(  this.record ) ;
        for(var i=0;i<this.records.order_items.length;i++){
            delete this.items[i].Product__r;
        }
        saveRecords({ 'recordsString' : JSON.stringify( this.records ) })
        .then((result) => {
            if(result != null){
                this.records = result;
            }
        })
        .catch((error) => {
            this.error = error;
            this.selectedRecord = {};
        });  
    } 
    get isCreateEdit() {
         return this.record.Id == undefined ? true : false;
    } 
    get itemsSize() {
        return this.items.length > 1;
   } 
    createRow(items) {
        let item = {};
        if(items.length > 0) { 
            item.index = items[items.length - 1].index + 1;
        } else {
            item.index = 1;
        } 
        item.Product__c = null;
        item.Product__r  = {'Id':null,'Name':null};
        item.Product_Name__c = null;        
        item.Quantity__c = null;
        item.Unit_Price__c = null;
        item.EID__c = this.record.EID__c +'-'+ new Date().getTime();
        items.push(item);
    } 
    addNewRow() {
        this.createRow(this.items);
    } 
    removeRow(event) {
        let toBeDeletedRowIndex = event.target.name; 
        let items  = [];
        for(let i = 0; i < this.items.length; i++) {
            let tempRecord = Object.assign({}, this.items[i]); //cloning object
            if(tempRecord.index !== toBeDeletedRowIndex) {
                items.push(tempRecord);
            }
        } 
        for(let i = 0; i < items.length; i++) {
            items[i].index = i + 1;
        } 
        this.items = items;
        this.calculateSummary();
    } 
    removeAllRows() {
        let items = [];
        this.createRow(items);
        this.items = items;
    }  
    handleRecordInputLookupChange(event) {
        console.log(JSON.stringify( event) );
        let selectedRecord =  {};
        if(event.detail ){
            selectedRecord =  event.detail.selectedRecord; 
            this.record.Store__r = { 'Id': selectedRecord.Id}
        } 
    }
    handleInputLookupChange(event) { 
        console.log(JSON.stringify( event) );
        let selectedRecord =  {};
        if(event.detail ){
            selectedRecord =  event.detail.selectedRecord; 
        } 
        for(let i = 0; i < this.items.length; i++) {
            if(this.items[i].index === parseInt(selectedRecord.index)) { 
               if( this.items[i].deleted){  
                    this.items[i]['Product__c']   =  null;
                    this.items[i]['Product__r.Name']   =  null; 
               }else{   
                this.items[i]['Product__c']   = selectedRecord.Id;
                this.items[i]['Product__r.Name']   = selectedRecord.Name;
                this.items[i].TAX_Per_GST__c = parseFloat(  selectedRecord.TAX_Per_GST__c ).toFixed(2);
                this.items[i].Unit_Price__c  = parseFloat(  selectedRecord.MRP__c ).toFixed(2);   
              }  
            } 
        }
    }   
    handleInputChange(event) { 
        let index = event.target.dataset.id;
        let fieldName = event.target.name; 
        let value = event.target.value  ;   
        this.totalAmount = 0;
        this.totalTax  =   0  ;
        this.grantTotal  = 0  ; 

        for(let i = 0; i < this.items.length; i++) {
            if(this.items[i].index === parseInt(index)) {
                this.items[i][fieldName] = value; 
            }  
        }
        this.calculateSummary(); 
    }
    calculateSummary(){ 
        this.totalAmount = 0;
        this.totalTax  =   0  ;
        this.grantTotal  = 0  ; 

        for(let i = 0; i < this.items.length; i++) { 
            if( this.items[i].Quantity__c &&  this.items[i].Unit_Price__c) { 
                this.items[i].Total_Amount__c = parseFloat( this.items[i].Quantity__c *  this.items[i].Unit_Price__c ).toFixed(2) ;
                this.items[i].Tax_value_edit__c  = parseFloat(  this.items[i].Total_Amount__c *( this.items[i].TAX_Per_GST__c ? this.items[i].TAX_Per_GST__c/100 : 0 ) ).toFixed(2) ;
                this.items[i].Total_Price__c =   parseFloat( parseFloat( this.items[i].Total_Amount__c )  +  parseFloat( this.items[i].Tax_value_edit__c )).toFixed(2);
                this.totalAmount =  ( parseFloat( this.totalAmount ) + parseFloat( this.items[i].Total_Amount__c) ).toFixed(2);
                this.totalTax  =  ( parseFloat( this.totalTax ) +  parseFloat( this.items[i].Tax_value_edit__c) ).toFixed(2)  ;
                this.grantTotal  = ( parseFloat( this.grantTotal ) + parseFloat(   this.items[i].Total_Price__c ) ).toFixed(2) ;   
             }  
        }  
        this.record.Grand_Total__c = this.grantTotal;

    } 
    itemsAdded(event){ 
        let items = this.items;
        let addedItems = JSON.parse( JSON.stringify( event.detail ) );
        for(let i=0;i<addedItems.length;i++){ 
            let item = {};
            if(items.length > 0) { 
                item.index = items[items.length - 1].index + 1;
            } else {
                item.index = 1; 
            } 
            item.Unit_Price__c = parseFloat( addedItems[i].MRP__c ).toFixed(2);    
            item.TAX_Per_GST__c = parseFloat( addedItems[i].TAX_Per_GST__c ).toFixed(2);
            item.Product__r  = {'Id':addedItems[i].Id,'Name':addedItems[i].Name};
            item.Product__c = addedItems[i].Id;
            item.Product_Name__c = addedItems[i].Name;  
            item.Quantity__c = null;
            item.EID__c = this.record.EID__c +'-'+ new Date().getTime();
            items.push(item);
         }
        this.items = items;
        this.calculateSummary();
        this.showSearchList = false;


     }
     searchItems(){ 
        this.showSearchList = true;
      /* //this.template.querySelector('c-cmp-list-view').showModalBox();
        var compDefinition = {
            componentDef: "c:cmpListView",
            attributes: {
                objectName: "Product__c"
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { 
                url: '/one/one.app#' + encodedCompDef
            }
        });  */ 
    } 
    navigateonSave(recordId){ 
        var compDefinition = {
            componentDef: "c:orderMasterDetail",
            attributes: {
                recordId: recordId
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { 
                url: '/one/one.app#' + encodedCompDef
            }
        });  
    }
    cancelSearch(){
        this.showSearchList = false;  
     }
}