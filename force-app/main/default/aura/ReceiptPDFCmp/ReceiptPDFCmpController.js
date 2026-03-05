({
	doInit : function(component, event, helper) {
		var userId = $A.get("$SObjectType.CurrentUser.Id");
        $A.get("e.force:closeQuickAction").fire();
        console.log('userId=== '+userId);
        console.log('recordId CMP=== '+component.get("v.recordId"));
        window.open('https://seraphinedevimpexpvtltd2--sbox1.sandbox.my.salesforce-sites.com/receipt/ReceiptPDF?Id='+component.get("v.recordId")+'&userId='+userId+'','_blank');
	}
})