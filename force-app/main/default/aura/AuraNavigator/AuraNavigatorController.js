({
	doInit : function(component, event, helper) {
        
        var recordId = component.get('v.recordId');
        var url  = window.location.href;
        if( ( url.indexOf('Order__c') != -1 )   ){
            component.set('v.objectName', 'Order');   
        }else 
        if( ( url.indexOf('Invoice__c') != -1 )   ){
            component.set('v.objectName', 'Invoice');   
        }
		
	}
})