({
    
    closeModal: function(component, event, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Account"
        });
        homeEvt.fire();
        
        // Close the Quick Action panel and refresh the view in both cases
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
       // dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    },
    fetchCustomer: function(component, event, helper) {
        component.set('v.spinner', true);
        var pageReference = component.get("v.pageReference");
        component.set("v.customerId", pageReference.state.c__customerId);
        var customer =component.get('v.customerId');
        if(customer){
            var action=component.get("c.getCustomerStock");
            action.setParams({ custId:component.get('v.customerId').toString() });
            
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == "SUCCESS" ){ 
                    var db = response.getReturnValue();
                    component.set('v.cashDiscount', db.customer.Cash_Discount__c);
                    component.set('v.Products',db.stocks);
                    component.set('v.productStockMap',db.productStockMap);
                    component.set('v.routeId',db.customer.Routes__c);
                    component.set('v.spinner', false);
                    component.set('v.showItems', true);
                    let options=[];
                          for (var key in db.productStockMap) {
                              options.push({ label: key, value: key});
                          }
                  component.set('v.productOptions', options);  
                    component.set('v.showProduct', true);
                }else if (response.getState() === "ERROR") {
                       component.set('v.spinner', false);
                    var errors = response.getError();
                    console.error(errors);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                           // helper.showToast(errors[0].message,'error');
                        }
                    }
                }
                
            });
            $A.enqueueAction(action);
        } 
    },
    changeSalesInvoice :function(component, event, helper) {
        var salesInvoice = component.get('v.salesInvoiceId');
        if(salesInvoice !=null && salesInvoice !=undefined && salesInvoice !=''){
            helper.helperclickInvoice(component, event, helper); 
        }else{
            component.set("v.returnItems" ,[]);   
        }
    } ,
    changeAGSalesInvoice :function(component, event, helper) {
        var salesInvoice = component.get('v.agSalesInvoiceId');
        
    } ,
    getGrandTotal: function (component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var items = component.get('v.returnItems');
        
        console.log(JSON.stringify(items))
        
        var salesTaxPercent=0;
        if(items[index].GST_Percentage__c){
            salesTaxPercent = items[index].GST_Percentage__c;
        }
        
        var totalWithGST = items[index].Unit_Price__c * items[index].Quantity__c;
        var cashDis = items[index].Cash_Discount__c;
        if(cashDis == null  || items[index].Fixed_Price_Item__c){
            cashDis = 0;
        }
        var totalcashdis =totalWithGST;
        items[index].Cash_Discount__c = Number(cashDis).toFixed(2);
        items[index].Customer_Discount__c = Number(totalcashdis).toFixed(2);
        
        var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
        
        items[index].Total__c = Number(ttl).toFixed(2);
        // alert( items[index].Total__c);
        component.set('v.returnItems', items);
        var grandtotal = 0;
        
        for (var i = 0; i < items.length; i++) {
            
            if (items[i].Total__c != '') {
                
                grandtotal = Number(grandtotal) + Number(items[i].Total__c);
            }
        }
        for (var i = 0; i < items.length; i++) {
            if (items[i].Quantity__c != 0) {
                component.set('v.disableSave', false);
                break;
            }
            else {
                component.set('v.disableSave', true);
            }
        }
        component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
    },
    handleSubmit: function (component, event, helper) {
        event.preventDefault();
        const fields = event.getParam('fields');
        if (helper.validateOrderList(component, event, helper)) {
            component.find('return').submit(fields);
        }
    },
    handleSuccess : function(component ,event , helper){
        var record = event.getParam("response");
        var returns = event.getParams().response;
        component.set('v.recordId',returns.id);
        helper.saveReturns(component, event, helper);
    },
    handleError: function (component, event, helper) {
        var errorMessage = event.getParam("message"); 
        helper.showToast("Error",JSON.stringify(errorMessage),"error"); 
    },
    onSelectType: function (component, event, helper) {
        try{
            
            var retType = component.get('v.returnType');
            component.set('v.returnItems',[]);
            
            if(retType == 'Against Customer'){
                component.set('v.showItems', true);
                component.set('v.spinner', true);
                var action = component.get("c.getDiscounts");
                action.setParams({ custId:component.get('v.customerId') });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        var db = response.getReturnValue();
                        component.set('v.discounts', db);
                        component.set('v.spinner', false);
                    }
                });
                $A.enqueueAction(action);
                helper.addReturnRecord(component, event, helper);
            }
        }catch(error){
            console.error(error.message);
        }
    },
  /*  searchProduct: function (component, event, helper) {

        try {
            const products = component.get('v.Products') || [];
            const oitems = component.get('v.returnItems') || [];
            var index = Number(event.getSource().get('v.name'));

    component.set('v.searchIndex', index);

    // Ensure index is valid
    if (index < 0 || index >= oitems.length) {
        component.set('v.matchproducts', []);
        return;
    }

    const searchText = oitems[index].Item_Name__c.toLowerCase() ;

    if (searchText) {
       /// alert(JSON.stringify(products));
        // Use `filter` for concise and efficient filtering
        const matchprds = products.filter(product => 
             product.Product_Batch_Name__c.toLowerCase().includes(searchText)
        );
        component.set('v.matchproducts', matchprds);
        //   alert(JSON.stringify(matchprds));
    } else {
        component.set('v.matchproducts', []);
    }
         
} catch (error) {
    console.error('Error:', error.message);
    }

    },
    */
    updateProduct: function (component, event, helper) {
        try{
            component.set('v.spinner', true);
            var products = component.get('v.matchproducts');
            var discounts = component.get('v.discounts');
            var cashDis = component.get('v.cashDiscount');
            var returnItems= component.get('v.returnItems');
            var productStockMap = component.get('v.productStockMap');
           returnItems.forEach(function(item) {
               if(item.Item_Name__c){
                   let stocks =[];
                   stocks =productStockMap[item.Item_Name__c];
                   var dis = 0;
                  let gstpercent = item.Tax_Option__c === 'Old Tax' ?stocks[0].Product_Old_GST__c :stocks[0].Product_GST__c;  
             
                  if(stocks[0].Fixed_Price_Item__c){
                        dis = stocks[0].Margin__c; 
                    }
                    else{
                        for (var d = 0; d < discounts.length; d++) {
                            if (gstpercent == discounts[d].GST_Percentage__c) {
                                if(stocks[0].Product__r.Brand__c == 'Eva Traders'){
                                    dis = discounts[d].Eva_Discount_Percent__c;
                                }else{
                                    dis = discounts[d].Discount_Percent__c;
                                }
                            }
                        }
                    }
               
                        dis = dis || 0;
                    
                    if(cashDis == null  || stocks[0].Fixed_Price_Item__c){
                        cashDis = 0;
                    }
                    var unitPriceAfterDiscount = 0.0;
                    
                   item.Name = stocks[0].Product_Name__c;
                 //  item.Item_Name__c = stocks[0].Product_Name__c;
                   item.Batch_No__c = stocks[0].Batch_Number__c;
                   item.Product__c = stocks[0].Product__c;
                   item.Stock__c =stocks[0].Id;
                   item.GST_Percentage__c = stocks[0].Product_GST__c;
                   item.Fixed_Price_Item__c = stocks[0].Fixed_Price_Item__c;
                   // For New Tax calculation
                   item.Brand__c = stocks[0].Product__r.Brand__c;
                   item.New_GST_Percentage__c = stocks[0].Product_GST__c;
                   item.Old_GST_Percentage__c = stocks[0].Product_Old_GST__c;
                   item.Price__c = stocks[0].Price__c; 
                    item.Type__c = '';
                    item.Remarks__c = '';
                   // item.Quantity__c = 0;
                    unitPriceAfterDiscount = (stocks[0].Price__c - ((stocks[0].Price__c * dis) / 100));
                    item.Rate__c = Number(unitPriceAfterDiscount).toFixed(2);
                    unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
                    item.Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                    item.UnitPriceWithDiscount__c = Number(unitPriceAfterDiscount).toFixed(2);
                    item.Cash_Discount__c =cashDis;
                    item.Discount_Percent__c = dis;
               }else{
                  
                       item.Name                    = '';
                       item.Item_Name__c            = '';
                       item.Batch_No__c             = '';
                       item.Product__c              = '';
                       item.Stock__c                = '';
                       item.GST_Percentage__c       = 0;
                       item.Brand__c                = '';
                       item.New_GST_Percentage__c   = 0;
                       item.Old_GST_Percentage__c   = 0;
                       item.Price__c                = 0;
                       item.Type__c                 = '';
                       item.Remarks__c              = '';
                       item.Quantity__c             = 0;
                       item.Rate__c                 = 0;
                       item.Unit_Price__c           = 0;
                       item.UnitPriceWithDiscount__c = 0;
                       item.Cash_Discount__c        = 0;
                       item.Discount_Percent__c     = 0;
                   
                   
               }
            
           });
            
       
            console.log('items:====='+JSON.stringify(returnItems));
            component.set('v.returnItems', returnItems);
            component.set('v.spinner', false);
            
        }catch(error){
            console.error('bug'+error.message);
        } 
        
    },
    addRow: function(component, event, helper) { 
        helper.addReturnRecord(component, event, helper);
    },
    removeRow : function(component, event, helper) {
        try{ 
            var selectedItem = event.currentTarget;
            var index = selectedItem.dataset.record;
            //   alert(index)
            var oitems= component.get('v.returnItems');
            console.log('items in remove1:' + oitems);
            // if(oitems[index].Id !='undefined' && oitems[index].Id !=''){
            
            var salesTaxPercent=0;
            if(oitems[index].GST_Percentage__c){
                salesTaxPercent = oitems[index].GST_Percentage__c;
            }
            
            if( oitems[index].Quantity__c !='' && oitems[index].Quantity__c !=undefined){
                //  var total = ((oitems[index].Unit_Price__c * oitems[index].Quantity__c)+(oitems[index].Unit_Price__c * oitems[index].Quantity__c * salesTaxPercent / 100));
                var total = oitems[index].Total__c;
                var grandtotal = (component.get('v.GrandTotal')-total);
                //alert('grandtotal=== '+grandtotal);
                component.set('v.GrandTotal',Number(grandtotal).toFixed(2));
            }
            oitems.splice(index, 1);
            component.set("v.returnItems", oitems);
            console.log('items in remove2:' + oitems);
            if(oitems.length < 1){
                helper.addReturnRecord(component, event, helper);
            }
            component.set('v.spinner',false);
            
        }catch(error){
            console.error(error.message);
        }
    },
        onChangeTax:function(component, event, helper) {
            try{
        var index =  event.currentTarget.dataset.record;
        var oitems= component.get('v.returnItems');
        var discounts = component.get('v.discounts');
        var cashDis = component.get('v.cashDiscount');
        
        
        var t1 = oitems[index].Tax_Option__c;
        
        
         var dis = 0;
          let gstpercent = oitems[index].Tax_Option__c === 'Old Tax' ?oitems[index].Old_GST_Percentage__c :oitems[index].New_GST_Percentage__c;


        if(oitems[index].Fixed_Price_Item__c){
            dis = oitems[index].Discount_Percent__c;
        }
        else{
            for (var d = 0; d < discounts.length; d++) {
                if (gstpercent == discounts[d].GST_Percentage__c) {
                    if(oitems[index].Brand__c == 'Eva Traders'){
                        dis = discounts[d].Eva_Discount_Percent__c;
                    }else{
                        dis = discounts[d].Discount_Percent__c;
                    }
                }
            }
        }
        
        if(cashDis == null  || oitems[index].Fixed_Price_Item__c){
            cashDis = 0;
        }
        dis = dis || 0;
        var unitPriceAfterDiscount = 0.0;
        oitems[index].GST_Percentage__c = gstpercent;
        unitPriceAfterDiscount = (oitems[index].Price__c - ((oitems[index].Price__c * dis) / 100));
        oitems[index].Rate__c = Number(unitPriceAfterDiscount).toFixed(2);
        unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
        
        oitems[index].Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
        oitems[index].UnitPriceWithDiscount__c = Number(unitPriceAfterDiscount).toFixed(2);
        oitems[index].Cash_Discount__c =cashDis;
        oitems[index].Discount_Percent__c = dis;
        
        if( oitems[index].Quantity__c !='' && oitems[index].Quantity__c !=undefined){
            
            var totalWithGST = oitems[index].Unit_Price__c * oitems[index].Quantity__c;
            var cashDis = oitems[index].Cash_Discount__c;
            if(cashDis == null  || oitems[index].Fixed_Price_Item__c){
                cashDis = 0;
            }
            
            var totalcashdis =totalWithGST;
            
            oitems[index].Cash_Discount__c = Number(cashDis).toFixed(2);
            oitems[index].Customer_Discount__c = Number(totalcashdis).toFixed(2);
            
            var ttl = totalcashdis + (totalcashdis * gstpercent/100 );
            
            oitems[index].Total__c = Number(ttl).toFixed(2);
            
              console.log('items:====='+JSON.stringify(oitems));
        }
        
        var grandtotal = 0;
        
        for (var i = 0; i < oitems.length; i++) {
            
            if (oitems[i].Total__c != '') {
                
                grandtotal = Number(grandtotal) + Number(oitems[i].Total__c);
            }
        }
        for (var i = 0; i < oitems.length; i++) {
            if (oitems[i].Quantity__c != 0) {
                component.set('v.disableSave', false);
                break;
            }
            else {
                component.set('v.disableSave', true);
            }
        }
        
        component.set("v.returnItems", oitems);
        component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
        
     }catch(error){
            console.error(error.message);
        }   
    },
})