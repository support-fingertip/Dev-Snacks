({
	searchText : function(component, event, helper) {
        var accounts= component.get('v.accounts');
        var searchText= component.get('v.searchText');
        var matchaccounts=[];
        if(searchText !=''){
        for(var i=0;i<accounts.length; i++){ 
            if(accounts[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
               matchaccounts.push( accounts[i] )
            } 
         } 
            if(matchaccounts.length >0){
		 component.set('v.matchaccounts',matchaccounts);
            }
        }else{
            component.set('v.matchaccounts',[]);
        }
    },update: function(component, event, helper) {
        
        component.set('v.value', event.currentTarget.dataset.id);
        var edi = component.get('v.value');
         var accounts= component.get('v.matchaccounts');
        for(var i=0;i<accounts.length; i++){ 
            if(accounts[i].EId__c ===  edi ){
               component.set('v.searchText', accounts[i].Name);
                component.set('v.storeName', accounts[i].Name);
                component.set('v.status', accounts[i].Approval_Status__c )
                break;
            } 
         } 
       
         component.set('v.matchaccounts',[]);
        //alert(component.get('v.value'));
    },
   
})