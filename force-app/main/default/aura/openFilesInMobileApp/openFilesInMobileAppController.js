({
	doInit : function(component, event, helper) {
		var navService = cmp.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: '069e0000000azKYAAY',
                objectApiName: 'ContentDocument',
                actionName: 'view'
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);
	}
})