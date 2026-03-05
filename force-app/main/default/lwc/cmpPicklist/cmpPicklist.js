import { api,track, LightningElement } from 'lwc';

export default class uipicklist extends LightningElement {

  @api items;
  @api selectedItem = {label: 'Select an Option…',value:''}; 
  @track isVisible = false; 
  @track valueselected = '';

  clickToOpen(){ 
      this.isVisible = true;
     

  }

  connectedCallback() {
    document.addEventListener('click',   this.close.bind(this)); 
  }
  close(event) { 
    console.log(event);
    this.isVisible = false;
  }

  ignore(event) {
    event.stopPropagation();
    return false;
  }
  changeOption(event){ 
        var valueselected = '';   
        this.items.forEach(element => { 
                if(element.name == event.currentTarget.dataset.value){
                     this.template.querySelector("span[data-id=picklistvalue]").innerText =  element.label;
                     this.selectedItem = element;
                     this.valueselected = element.name;
                 }  
        }); 
        this.isVisible = false;  
        const selectedEvent = new CustomEvent('selected', { 'detail':  this.valueselected});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
  } 
  clearItem(){
      this.selectedItem = {label: 'Select an Option…',value:''};  
     const selectedEvent = new CustomEvent('selected', { 'detail':  ''});
      // Dispatches the event.
     this.dispatchEvent(selectedEvent);
  }
}