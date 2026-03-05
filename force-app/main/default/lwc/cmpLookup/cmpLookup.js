/*
API : 50
Source : lwcFactory.com
*/
import { LightningElement,api,wire,track} from 'lwc';
// import apex method from salesforce module 
import fetchLookupData from '@salesforce/apex/cmpLookup.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/cmpLookup.fetchDefaultRecord';

const DELAY = 300; // dealy apex callout timing in miliseconds  

export default class CustomLookupLwc extends LightningElement { 
    // public properties with initial default values 
    @api label = 'custom lookup label';  
    @api placeholder = 'search...'; 
    @api iconName = 'standard:product';
    @api sObjectApiName = 'Product__c';
    @api lookupField = 'Product__c';
    @api lookupNameField = 'Product__r.Name'; 
     
    @api defaultRecordId = '';  
    @api selectedRecord = {};   
    @track selectedRecordData = {};   

    @api index =  0;  
    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
     searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
   // selectedRecord = {}; // to store selected lookup record in object formate 

   // initial function to populate default selected lookup record if defaultRecordId provided  
   connectedCallback(){
    if(this.selectedRecord){
        this.selectedRecordData =  JSON.parse(JSON.stringify(this.selectedRecord));  
    }

   }
   renderedCallback(){
      

         if(this.defaultRecordId != ''){
            fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName })
            .then((result) => {
                if(result != null){
                    this.selectedRecordData = result;
                    console.log(result);
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                this.error = error;
                this.selectedRecordData = {};
            });
         }
         if(this.selectedRecordData.Id){
            this.handelSelectRecordHelper();
        }
    }

    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { searchKey: '$searchKey' , sObjectApiName : '$sObjectApiName' })
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
             this.hasRecords = data.length == 0 ? false : true; 
             this.lstResult = JSON.parse(JSON.stringify(data)); 
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };
       
  // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey;
        }, DELAY); 
    }


    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
           }
    }

   // method to clear selected lookup record  
   handleRemove(){
    this.searchKey = '';   
    this.selectedRecordData.Id  = null;  
    this.selectedRecordData.Name  = null;  
    this.lookupUpdatehandler(this.selectedRecordData); // update value on parent component as well from helper function 
    this.selectedRecordData = {};
    // remove selected pill and display input field again 
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-hide');
     searchBoxWrapper.classList.add('slds-show');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-show');
     pillDiv.classList.add('slds-hide');
   }

  // method to update selected record from search result 
handelSelectedRecord(event){   
     var objId = event.target.getAttribute('data-recid'); // get selected record Id 
     this.selectedRecordData = this.lstResult.find(data => data.Id === objId); // find selected record from list 
     this.selectedRecordData.index = this.index;
     this.lookupUpdatehandler(this.selectedRecordData); // update value on parent component as well from helper function 
     this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
}

/*COMMON HELPER METHOD STARTED*/

handelSelectRecordHelper(){
    this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');

     const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-show');
     searchBoxWrapper.classList.add('slds-hide');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-hide');
     pillDiv.classList.add('slds-show');     
}

// send selected lookup record to parent component using custom event
lookupUpdatehandler(value){    
    const oEvent = new CustomEvent('lookupupdate',
    {
        'detail': {selectedRecord: value}
    }
);
this.dispatchEvent(oEvent);
}


}