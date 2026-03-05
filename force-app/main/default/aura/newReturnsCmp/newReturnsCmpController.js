({
    doInit : function(component, event, helper) {
        component.set('v.spinner', true);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        component.set('v.Return.Return_Date__c',today);
        var action=component.get("c.getCustomer");
        action.setParams({ custId:component.get('v.customerId') });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                component.set('v.Return.Customer__c', component.get('v.customerId'));
                component.set('v.Return.Return_Type__c','');
                component.set('v.customerName', db.Name);
                component.set('v.cashDiscount', db.Cash_Discount__c);
                 component.set('v.cashDiscountCust', db.Cash_Discount__c);
                component.set('v.spinner', false);
                
            }
        });
        $A.enqueueAction(action);
        
        var action1=component.get("c.getStock");
        
        action1.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                component.set('v.Products',db);
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action1);
        
    },
    
    handleReturnType : function(component, event, helper) {
        var returntype = component.get('v.Return.Return_Type__c');
        console.log('returntype== '+returntype);
        if(returntype == 'Manufacturing Defect'){
            component.set('v.makeRemarkRequired',true);
        }else{
            component.set('v.makeRemarkRequired',false);
        }
    },
    
    clickInvoice : function(component, event, helper) {
        component.set('v.spinner', true);
        var invid = component.get('v.Return.Sales_Invoice__c').toString();
        var items = component.get('v.returnItems');
        items = [];
        var action=component.get("c.getItems");
        action.setParams({ invId:invid});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                
                for (var i = 0; i < db.length; i++){
                    
                    items.push({
                        'Invoice_Item__c':db[i].Id,
                        //'Stock__c': db[i].Stock__c,
                        'Batch_No__c':db[i].Batch_No__c,
                        'Product__c':db[i].Product__c,
                        'Stock__c':db[i].Stock__c,
                        'Item_Name__c': db[i].Item_Name__c,
                        'GST_Percentage__c': db[i].Sales_Tax__c,
                        'GST_Value__c': db[i].GST_Value__c,
                        'Name': db[i].Item_Name__c,
                        'Type__c':'',
                        'Remarks__c' : '',
                        'Quantity__c':0.00,
                        'Inv_Quantity':db[i].Quantity__c,
                        'Rate__c':db[i].Rate__c,
                        'Unit_Price__c':db[i].Unit_Price__c,
                        'Cash_Discount__c':db[i].Cash_Discount__c,
                        'Customer_Discount__c':db[i].Customer_Discount__c,
                        'UnitPriceWithDiscount__c':db[i].UnitPriceWithDiscount__c,
                        'Total__c':0
                    });
                    component.set('v.cashDiscount', db[i].Cash_Discount__c);
                    component.set('v.Return.Customer__c', db[i].Sales_Invoice__r.Customer__c);
                    component.set('v.customerName', db[i].Sales_Invoice__r.Customer__r.Name);
                }
                
                component.set('v.showItems', true);
                component.set('v.returnItems', items);
                component.set('v.spinner', false);
                component.set('v.GrandTotal', 0);
                component.set('v.disableSave', true);
            }
        });
        $A.enqueueAction(action);
    },
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
        //var totalcashdis = 0;
        // var totalcashdis = totalWithGST - ((totalWithGST * cashDis) / 100);
         var totalcashdis =totalWithGST;
        /*if(items[index].UnitPriceWithDiscount__c != items[index].Unit_Price__c){
            totalcashdis = totalWithGST - ((totalWithGST * cashDis) / 100);
        }
        else{
            totalcashdis =totalWithGST;
        }*/
        
        items[index].Cash_Discount__c = Number(cashDis).toFixed(2);
        items[index].Customer_Discount__c = Number(totalcashdis).toFixed(2);
        
     //   alert(totalcashdis)
     //   alert(salesTaxPercent )
        var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
        
        // var ttl = totalWithGST + (totalWithGST * salesTaxPercent/100 );
        items[index].Total__c = Number(ttl).toFixed(2);
        
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
    CancelClick: function (component, event) {
        
        var redit = component.get('v.redirect');
        //alert(redit);
        if(redit == true)
        {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId'),
                "slideDevName": "detail"
            });
            navEvt.fire();
            
        }
        else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:MobileVisit",
            });
            evt.fire();
        }
        
    },
    save: function (component, event, helper) {
        
        
        if (helper.validateOrderList(component, event, helper)) {
            var items = component.get('v.returnItems');
            var order = component.get('v.Return');
            
            
            helper.saveReturns(component, event, helper);
            
        }
    },
    onSelectType: function (component, event, helper) {
        var ret = component.get('v.Return');
        component.set('v.returnItems',[]);
        if(ret.Type__c == 'Against Customer'){
            component.set('v.showItems', true);
            component.set('v.spinner', true);
            var action1 = component.get("c.getCustomerStock");
            action1.setParams({ custId:component.get('v.customerId') });
            action1.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var db = response.getReturnValue();
                    component.set('v.discounts', db.disList);
                          component.set('v.productStockMap',db.productStockMap);
                      let options=[];
                          for (var key in db.productStockMap) {
                              options.push({ label: key, value: key});
                          }
                  component.set('v.productOptions', options);  
                    component.set('v.showProduct', true);
                    component.set('v.spinner', false);
                }
            });
            $A.enqueueAction(action1);
            helper.addReturnRecord(component, event, helper);
        }
        
    },
  /*  searchProduct: function (component, event, helper) {
        // alert('dd')
        var products = component.get('v.Products');
        // alert(products)
        // var searchText = component.get('v.searchProduct');
        var oitems= component.get('v.returnItems');
        var index = event.currentTarget.dataset.record;
        
        component.set('v.searchIndex',Number(index));
        // alert(component.get('v.searchIndex'));
        // alert(index)
        //var eid = event.currentTarget.dataset.id;
        
        var searchText = oitems[index].Item_Name__c;
        //  alert(searchText)
        
        var matchprds = [];
        if (searchText != '') {
            
            for (var i = 0; i < products.length; i++) {
                
                if (products[i].Product_Batch_Name__c.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    matchprds.push(products[i]);
                    
                }
            }
            // alert(JSON.stringify(matchprds))
            if (matchprds.length > 0) {
                component.set('v.matchproducts', matchprds);
                
            }
        } else {
            component.set('v.matchproducts', []);
        }
    },*/
    updateProduct: function (component, event, helper) {
          try{
            var grandtotal = 0;
            component.set('v.spinner', true);
            var products = component.get('v.matchproducts');
            var discounts = component.get('v.discounts');
            var cashDis = component.get('v.cashDiscountCust');
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
                    console.log('stocks[0].Price__c '+stocks[0].Price__c )
                    unitPriceAfterDiscount = (stocks[0].Price__c - ((stocks[0].Price__c * dis) / 100));
                    item.Rate__c = Number(unitPriceAfterDiscount).toFixed(2);
                    unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
                    item.Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                    item.UnitPriceWithDiscount__c = Number(unitPriceAfterDiscount).toFixed(2);
                    item.Cash_Discount__c =cashDis;
                     item.Discount_Percent__c = dis;
                    if( item.Quantity__c !='' && item.Quantity__c !=undefined){
                        
                        var totalWithGST = item.Unit_Price__c * item.Quantity__c;
                        var cashDis = item.Cash_Discount__c;
                        if(cashDis == null  || item.Fixed_Price_Item__c){
                            cashDis = 0;
                        }
                        
                        var totalcashdis =totalWithGST;
                        
                       item.Cash_Discount__c = Number(cashDis).toFixed(2);
                        item.Customer_Discount__c = Number(totalcashdis).toFixed(2);
                        
                        var ttl = totalcashdis + (totalcashdis * gstpercent/100 );
                        
                     item.Total__c = Number(ttl).toFixed(2);
                        if (item.Total__c != '') {
                            
                            grandtotal = Number(grandtotal) + Number(item.Total__c);
                        }
                    }
                    
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
                    item.Total__c     = 0;
                   
               }
            
           });
            
            component.set("v.returnItems", returnItems);
            component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
            component.set('v.returnItems', returnItems);
            component.set('v.spinner', false);
               }catch(error){
            console.error('bug'+error.message);
        } 
        
    },
    onChangeTax:function(component, event, helper) { 
       
        component.set('v.disableSave',true);
        var index =  event.currentTarget.dataset.record;
        var oitems= component.get('v.returnItems');
        var discounts = component.get('v.discounts');
        var cashDis = component.get('v.cashDiscountCust');
         
        
        var t1 = oitems[index].Tax_Option__c;
        
        
         var dis = 0;
        
          let gstpercent = oitems[index].Tax_Option__c === 'Old Tax' ?oitems[index].Old_GST_Percentage__c :oitems[index].New_GST_Percentage__c;
        console.log(oitems)
        
        
       
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
        console.log('selected %'+gstpercent);
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
        
         component.set('v.disableSave',false);
        
    },
    addRow: function(component, event, helper) { 
         helper.addReturnRecord(component, event, helper);
    },
     removeRow : function(component, event, helper) {
    	
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
       // }
         
    },
    changeSalesInvoice :function(component, event, helper) {
        var salesInvoice = component.get('v.salesInvoiceId');
        if(salesInvoice !=null && salesInvoice !=undefined && salesInvoice !=''){
              component.set("v.Return.Sales_Invoice__c" , salesInvoice);
            helper.helperclickInvoice(component, event, helper); 
        }else{
            component.set("v.Return.Sales_Invoice__c" , null);  
           component.set("v.returnItems" ,[]);   
        }
    } ,
        changeAGSalesInvoice :function(component, event, helper) {
        var salesInvoice = component.get('v.agSalesInvoiceId');
        if(salesInvoice !=null && salesInvoice !=undefined && salesInvoice !=''){
              component.set("v.Return.Sales_Invoice__c" , salesInvoice);
        }else{
            component.set("v.Return.Sales_Invoice__c" , null);  
        }
    } ,
})