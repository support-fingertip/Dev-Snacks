import { api, LightningElement, wire } from 'lwc';
import queryTargets from '@salesforce/apex/TargetHandlerController.queryTargets';
import queryPeriods from '@salesforce/apex/TargetHandlerController.queryPeriods';
import queryProfiles from '@salesforce/apex/TargetHandlerController.queryProfiles';
import queryUsers from '@salesforce/apex/TargetHandlerController.queryUsers';
 
 

export default class ApexWireMethodToFunction extends LightningElement { 
    rows;
    columns;

    error;
    @api periodSelected = '';
    @api profileSelected = '';
    @api userSelected = ''; 


    isExpandedProfiles = true;
   
    @api periods = [];
    @api profiles = [ ];
    @api users = [];
    connectedCallback() {  
        queryPeriods()
        .then(result => { 
            console.log(JSON.stringify( result ) ) 
            this.periods = result;
         })
        .catch(error => {
            console.log(error) 
 
        });  
    } 

    openSuggestion(event){ 
        event.taget.style.display = 'block'; 
    }

    onselectedPeriod(event){
        this.periodSelected = event.detail;
        queryProfiles({ periodId:event.detail } )
        .then(result => { 
            console.log(JSON.stringify( result ) ) 
            this.profiles = result;
         })
        .catch(error => {
            console.log(error) 
 
        }); 
    }
    onselectedProfile(event){
        this.profileSelected = event.detail;
        queryUsers({ profileId: this.profileSelected } )
        .then(result => { 
            console.log(JSON.stringify( result ) ) 
            this.users = result;
            this.queryTargetData();

         }) 
        .catch(error => {
            console.log(error) 
 
        }); 
    }
    onselectedUser(event){
        this.userSelected = event.detail;
        this.queryTargetData();
       
    }
    queryTargetData(){
        alert('query');
        queryTargets({ 'periodId':this.periodSelected, 'profileId':this.profileSelected,'reportingTo': this.userSelected})
        .then(result => { 
            console.log(JSON.stringify( result ) ) 
            this.rows = result.targetsWrapper;
            this.columns = result.targetMetrics;
        })
        .catch(error => { 
            console.log(error) 
 
        });


    }
    clearPeriod(){
        
    }
 
}