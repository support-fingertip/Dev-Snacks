({
	collectionSheet : function(component, event, helper) {
		 window.open('https://seraphinedevimpexpvtltd2--sbox1.sandbox.my.salesforce-sites.com/CollectionSheet?Id='+component.get("v.recordId")+'&from=' + component.get('v.FromDate') +'&to=' + component.get('v.ToDate')+'', '_blank');
	},
    ExpenseSheet : function(component, event, helper) {
		 window.open('https://seraphinedevimpexpvtltd2--sbox1.sandbox.my.salesforce-sites.com/ExpenseSheet?Id='+component.get("v.recordId")+'&from=' + component.get('v.FromDate') +'&to=' + component.get('v.ToDate')+'', '_blank');
	},
 cashbook : function(component, event, helper) {
		 window.open('https://seraphinedevimpexpvtltd2--sbox1.sandbox.my.salesforce-sites.com/Cashbook?Id='+component.get("v.recordId")+'&from=' + component.get('v.FromDate') +'&to=' + component.get('v.ToDate')+'', '_blank');
	},
    vanstock : function(component, event, helper) {
	 window.open('https://seraphinedevimpexpvtltd2--sbox1.sandbox.my.salesforce-sites.com/vanStock?Id='+component.get("v.recordId")+'&from=' + component.get('v.FromDate') +'&to=' + component.get('v.ToDate')+'', '_blank');
	},
    onDateChange: function(component, event, helper) {
        if(component.get('v.ToDate') !=null && component.get('v.FromDate') !=null){
            component.set('v.showReport',true);
        }else{
             component.set('v.showReport',false);
        }
    },
    
})