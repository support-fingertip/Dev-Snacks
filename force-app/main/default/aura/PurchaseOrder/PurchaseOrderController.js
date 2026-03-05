({
	doInit : function(component, event, helper) {
   
     helper.addProduct(component, event,helper);
       
      //helper.getExistingData(component, event,helper);
    },
    addRow: function(component, event, helper) {
        helper.addProduct(component, event);
    }, 
    removeRow: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var oitems= component.get('v.ItemList');
        
        if( oitems[index].Ordered_Quantity__c !='' && oitems[index].Ordered_Quantity__c !=undefined){
            var total = (oitems[index].Unit_Price__c * oitems[index].Ordered_Quantity__c)+(((oitems[index].Unit_Price__c * oitems[index].Ordered_Quantity__c)*oitems[index].Tax__c)/100);
            var grandtotal = (component.get('v.GrandTotal')-total);
            component.set('v.GrandTotal',grandtotal);
        }
        oitems.splice(index, 1);
        component.set("v.ItemList", oitems);
        if(oitems.length < 1){
            helper.addProduct(component, event);
        }
    },
    doSave: function(component,event,helper) {
        if (helper.validateItemList(component, event)) {
            var oitems= component.get('v.ItemList');
            helper.saveRecord(component,event,helper);
        }
    },
    doCancel:function(component, event, helper) {
        component.set("v.ItemList", []);
        component.set('v.GrandTotal',0.00);
        component.set("v.Products", []);
        component.set("v.matchproducts", []);
        component.set("v.vendorId",'');
        component.set("v.poDate",'');
        component.set("v.vendorName",'');
        /*var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "detail"
        });
        navEvt.fire();*/
        $A.get('e.force:refreshView').fire();
        
    },
     searchText : function(component, event, helper) {
        var products= component.get('v.Products');
        var searchText= component.get('v.searchText');
        var matchprds=[];
        if(searchText !=''){
            for(var i=0;i<products.length; i++){ 
                if(products[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchprds.push( products[i] );
                } 
            } 
            if(matchprds.length >0){
                component.set('v.matchproducts',matchprds);
            }
        }else{
            component.set('v.matchproducts',[]);
        }
    },
    update: function(component, event, helper) {
        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var pid =event.currentTarget.dataset.id;
        var prds= component.get('v.matchproducts');
        var oitems= component.get('v.ItemList');
        for(var i=0;i<prds.length; i++){ 
            if(prds[i].Id === pid ){
                oitems[index].Product__c = prds[i].Id;
                oitems[index].Product_Name__c = prds[i].Name;
                 oitems[index].Tax__c = prds[i].TAX_Per_GST__c;
                component.set('v.searchText', '');
                break;
            }
        } 
        component.set('v.ItemList',oitems);
        component.set('v.matchproducts',[]);
        component.set('v.spinner', false);
    },
    searchText2 : function(component, event, helper) {
        console.log('vednor search');
        var vendors= component.get('v.vendors');
        var searchText= component.get('v.searchText2');
        console.log(vendors.length);
        var matchVendors=[];
        if(searchText !=''){
            for(var i=0;i<vendors.length; i++){ 
                if(vendors[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchVendors.push( vendors[i] );
                } 
            } 
            if(matchVendors.length >0){
                component.set('v.matchVendors',matchVendors);
            }
        }else{
            component.set('v.matchVendors',[]);
        }
    },
    update2: function(component, event, helper) {
        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var pid =event.currentTarget.dataset.id;
        var prds= component.get('v.matchVendors');
        for(var i=0;i<prds.length; i++){ 
            if(prds[i].Id === pid ){
                component.set('v.vendorName',prds[i].Name);
                 component.set('v.vendorId',prds[i].Id);
                component.set('v.searchText2', '');
                break;
            }
        } 
        component.set('v.matchVendors',[]);
        component.set('v.spinner', false);
    },
    getGrandTotal : function(component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var oitems= component.get('v.ItemList');
        oitems[index].Total_Price__c  = (oitems[index].Unit_Price__c * oitems[index].Ordered_Quantity__c)+(((oitems[index].Unit_Price__c * oitems[index].Ordered_Quantity__c)*oitems[index].Tax__c)/100);
        component.set('v.ItemList',oitems);
        var grandtotal = 0;
        var oit= component.get('v.ItemList');
        for(var i=0;i<oit.length; i++){ 
            grandtotal = grandtotal+oit[i].Total_Price__c;
        } 
        component.set('v.GrandTotal',grandtotal);
        
    },
     sendEmail: function(component, event, helper) {
      //  alert(1)
        helper.sendEmail(component, event, helper);
        
    },
    
})