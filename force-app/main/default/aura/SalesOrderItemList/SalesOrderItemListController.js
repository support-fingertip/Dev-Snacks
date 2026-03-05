({
    doInit : function(component, event, helper){
        
        helper.addProductRecord(component, event);
        
        component.set('v.spinner',true);
        component.set('v.Receipt',{'Customer__c':'','Daily_Log__c':'','Payment_Type__c:':''});
        
        
        var action2=component.get("c.getBanks");  
        
        action2.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var banks = response.getReturnValue();
                component.set("v.banks",banks);
                 component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action2);
        
        var action=component.get("c.getOrder");
        var ordId = component.get("v.recordId");
        
        action.setParams({ 'ordId' :  ordId})
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                console.log(db)
                component.set('v.Order',db);
                component.set('v.routeId',db.Route__c);
                component.set("v.GrandTotal",Number(db.Grand_Total__c).toFixed(2));
                component.set("v.GrandTotalDisc",Number(db.Grand_Total__c).toFixed(2));
                component.set("v.cashDiscount",db.Customer__r.Cash_Discount__c);
                var action1 = component.get("c.getDiscounts");
                action1.setParams({ 'accId': component.get('v.Order.Customer__c') })
                action1.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        var db = response.getReturnValue();
                        component.set('v.discounts', db);
                        component.set('v.spinner', false);
                    }
                });
                $A.enqueueAction(action1);
                
                var action2=component.get("c.getStock");
                 action2.setParams({ 'routeId': component.get('v.routeId') })
                action2.setCallback(this,function(response){
                    var state = response.getState();
                    if(state == "SUCCESS" ){ 
                        var db = response.getReturnValue();
                        component.set('v.Products',db);
                        component.set('v.spinner',false);
                    }
                });
                $A.enqueueAction(action2);
        
                
            }
        });
        $A.enqueueAction(action);
        
        
        var action=component.get("c.getOrderItems");
        var ordId = component.get("v.recordId");
        
        action.setParams({ 'ordId' :  ordId})
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                console.log('Before:' + JSON.stringify(db))
                //alert(JSON.stringify(db))
                 var grandtotal = 0;
                for (var i = 0; i < db.length; i++) {
                    if(db[i].Sales_order__r.New_Flow__c == false){
                        var salesTaxPercent=0;
                        if(db[i].Sales_Tax__c){
                            salesTaxPercent = db[i].Sales_Tax__c;
                        }
                        var cashDis = component.get('v.cashDiscount');
                      //  alert(cashDis)
                        if(cashDis == null){
                            cashDis = 0;
                        }
                        var totalWithGST = db[i].Unit_Price__c * db[i].Quantity__c;
                        
                        //var totalcashdis = totalWithGST - ((totalWithGST * cashDis) / 100);
                        var totalcashdis =totalWithGST;
                        db[i].Cash_Discount__c = Number(cashDis).toFixed(2);
                        db[i].Customer_Discount__c = Number(totalcashdis).toFixed(2);
                        
                        var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
                        db[i].Total__c = Number(ttl).toFixed(2);
                        db[i].Total_Before_Tax__c = Number(totalWithGST).toFixed(2);
                        db[i].Discount_Percent__c = db[i].Discount_Percent__c;
                        
                         grandtotal = Number(grandtotal) + Number(db[i].Total__c);
                    }
                    else{
                        var cashDis = component.get('v.cashDiscount');
                         if(cashDis == null){
                                cashDis = 0;
                            }
                        var unitPriceAfterDiscount=0.0;
                        
                        if(db[i].Discount_Percent__c == null){
                            db[i].Discount_Percent__c = 0;
                        }
                        if(db[i].Rate__c == null){
                            unitPriceAfterDiscount = (db[i].Stock__r.Price__c - ((db[i].Stock__r.Price__c * db[i].Discount_Percent__c) / 100));
                            db[i].Rate__c = Number(unitPriceAfterDiscount).toFixed(2); 
                            unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
                            
                            db[i].Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                            var salesTaxPercent=0;
                            if(db[i].Sales_Tax__c){
                                salesTaxPercent = db[i].Sales_Tax__c;
                            }
                            
                            var totalWithGST = db[i].Unit_Price__c * db[i].Quantity__c;
                            
                           
                            // var totalcashdis = totalWithGST - ((totalWithGST * cashDis) / 100);
                            var totalcashdis =totalWithGST;
                            db[i].Cash_Discount__c = Number(cashDis).toFixed(2);
                            db[i].Customer_Discount__c = Number(totalcashdis).toFixed(2);
                            
                            var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
                            db[i].Total__c = Number(ttl).toFixed(2);
                            db[i].Total_Before_Tax__c = Number(totalWithGST).toFixed(2);
                           
                           
                            grandtotal = Number(grandtotal) + Number(db[i].Total__c);
                            
                        }
                        else{
                            grandtotal = component.get('v.GrandTotal');
                        }
                        
                    }
                    db[i].Available_Quantity__c = db[i].Stock__r.Available_Quantity__c;
                    db[i].Price__c = db[i].Stock__r.Price__c;
                }
                console.log('After:' + JSON.stringify(db))
                component.set('v.orderItemList',db);
                component.set('v.spinner',false);
                component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
                component.set('v.GrandTotalDisc', Number(grandtotal).toFixed(2));
            }
        });
        $A.enqueueAction(action);
        
       
    },
    removeRow : function(component, event, helper) {
        //var orderList = component.get("v.orderItemList");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var oitems= component.get('v.orderItemList');
        if(oitems[index].Id !='undefined' && oitems[index].Id !=''){
           /* var action=component.get("c.deleteSalesOrderItem");
            action.setParams({'prId':  oitems[index].Id  })
            action.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){   
                    if( oitems[index].Quantity__c !='' && oitems[index].Quantity__c !=undefined){
                        var total = (((oitems[index].Unit_Price__c * oitems[index].Quantity__c)*oitems[index].TAX_Per_GST__c)/100)+(oitems[index].Unit_Price__c * oitems[index].Quantity__c);
                        var grandtotal = (component.get('v.GrandTotalDisc')-total);
                        component.set('v.GrandTotalDisc',grandtotal);
                    }
                    oitems.splice(index, 1);
                    component.set("v.orderItemList", oitems);
                    
                    if(oitems.length < 1){
                        helper.addProductRecord(component, event);
                    }
                      component.set('v.spinner',false);
                }
            });
            $A.enqueueAction(action);*/
            
            var salesTaxPercent=0;
            if(oitems[index].Sales_Tax__c){
                salesTaxPercent = oitems[index].Sales_Tax__c;
            }
            
             if( oitems[index].Quantity__c !='' && oitems[index].Quantity__c !=undefined){
                        var total = ((oitems[index].Unit_Price__c * oitems[index].Quantity__c)+(oitems[index].Unit_Price__c * oitems[index].Quantity__c * salesTaxPercent / 100));
                        var grandtotal = (component.get('v.GrandTotalDisc')-total);
                         //alert('grandtotal=== '+grandtotal);
                        component.set('v.GrandTotalDisc',Number(grandtotal).toFixed(2));
                    }
                    oitems.splice(index, 1);
                    component.set("v.orderItemList", oitems);
                    
                    if(oitems.length < 1){
                        helper.addProductRecord(component, event);
                    }
                      component.set('v.spinner',false);
        }
        /*var total = (((oitems[index].Unit_Price__c * oitems[index].Quantity__c)*oitems[index].TAX_Per_GST__c)/100)+(oitems[index].Unit_Price__c * oitems[index].Quantity__c);
        var grandtotal = (component.get('v.GrandTotal')-total);
        component.set('v.GrandTotal',grandtotal);
        orderList.splice(index, 1);
        component.set("v.orderItemList", orderList);
        if(orderList.length < 1){
            helper.addProductRecord(component, event);
        }*/
        
    },
    getGrandTotal : function(component, event, helper) {
        
        var index = event.currentTarget.dataset.record;
        var oitems= component.get('v.orderItemList');
        // alert('oitems== '+JSON.stringify(oitems));
        var cashDis = component.get('v.cashDiscount');
        
        // alert(oitems[index].TAX_Per_GST__c);
        //  console.log('up: '+oitems[index].MRP__c);
        //   console.log('Qty: '+oitems[index].Quantity__c);
        // console.log('tax: '+oitems[index].TAX_Per_GST__c);
        /*if(oitems[index].GST_Percentage__c == ''){
            oitems[index].GST_Percentage__c = 1;
        }*/
        
        console.log('Sales_Tax__c== '+oitems[index].Sales_Tax__c);
        //oitems[index].Total__c  = (((oitems[index].Unit_Price__c * oitems[index].Quantity__c)*oitems[index].GST_Percentage__c)/100)+(oitems[index].Unit_Price__c * oitems[index].Quantity__c);
        //oitems[index].Unit_Price__c = (oitems[index].Unit_Price__c * oitems[index].Discount_Percent__c);
       // oitems[index].Total__c = (((oitems[index].Unit_Price__c * oitems[index].Quantity__c) * oitems[index].Sales_Tax__c) / 100) + (oitems[index].Unit_Price__c * oitems[index].Quantity__c);
        //oitems[index].Total_after_discount__c  = oitems[index].Total__c  - ((oitems[index].Total__c * oitems[index].Discount_Percent__c) / 100 );
        
        var salesTaxPercent=0;
        if(oitems[index].Sales_Tax__c){
            salesTaxPercent = oitems[index].Sales_Tax__c;
        }
       
         var totalWithGST = oitems[index].Unit_Price__c * oitems[index].Quantity__c;
        if(cashDis == null  || oitems[index].Fixed_Price_Item__c){
            cashDis = 0;
        }
        // var totalcashdis = totalWithGST - ((totalWithGST * cashDis) / 100);
        var totalcashdis =totalWithGST;
        oitems[index].Cash_Discount__c = Number(cashDis).toFixed(2);
        oitems[index].Customer_Discount__c = Number(totalcashdis).toFixed(2);
        
        var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
        oitems[index].Total__c = Number(ttl).toFixed(2);
        oitems[index].Total_Before_Tax__c = Number(totalWithGST).toFixed(2);
        
        component.set('v.orderItemList',oitems);
        
        var grandtotal = 0;
        var grandtotaldisc = 0;

        //var oit= component.get('v.orderItemList');
        for (var i = 0; i < oitems.length; i++) {
            if (oitems[i].Total__c) {
                // alert('Total== '+oitems[i].Total__c);
                // alert('dis== '+oitems[i].Total_after_discount__c);
                grandtotal = Number(grandtotal) + Number(oitems[i].Total__c);
            }
        }
        grandtotaldisc = component.get('v.GrandTotalDisc');
      /*  if (component.get('v.Receipt').Payment_Type__c == 'Immediate') {
            grandtotaldisc = component.get('v.GrandTotalDisc');
            var disApplied = component.get('v.disApplied');
            //alert(cashDis)
            if (cashDis != null && cashDis != "undefined") {
                grandtotaldisc = grandtotal - ((grandtotal * cashDis) / 100);
            }else{
                grandtotaldisc = grandtotal;
            }
            component.set('v.disApplied', true);
          
        }
        else {
            grandtotaldisc = grandtotal;
            component.set('v.disApplied', false);
        }*/
        grandtotaldisc = grandtotal;
        component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
        component.set('v.GrandTotalDisc', Number(grandtotaldisc).toFixed(2));
        
    },
    addRow: function(component, event, helper) { 
        // var storeId = component.get('v.data.currentvisit.Account1__r.EId__c');
        // var visitId = component.get('v.data.currentvisit.EId__c');
        helper.addProductRecord(component, event);
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
    onSelectPay : function(component, event, helper){
        var rec = component.get('v.Receipt');
        // alert(JSON.stringify(rec))
        var recDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var storeId = component.get('v.Order.Customer__c');
        var cashDis = component.get('v.cashDiscount');
        var grandtotaldisc = component.get('v.GrandTotal');
        
        var disApplied = component.get('v.disApplied');
        
        
        component.set('v.Receipt.Customer__c',storeId);
       // component.set('v.Receipt.Daily_Log__c',component.get('v.data.dailyLog.Id'));
        component.set('v.Receipt.Receipt_Date__c',recDate);
       // component.set('v.Receipt.Trip__c',component.get('v.data.dailyLog.Trip__c'));
        var grandtotal = component.get('v.GrandTotal');
        // alert(grandtotal)
        
        var oitems= component.get('v.orderItemList');
        
        if(rec.Payment_Type__c == 'Immediate'){
            
            component.set('v.showPayment',true);
            
           /* if(grandtotaldisc != 0 && disApplied == false){
                if(cashDis != null && cashDis != "undefined"){
                    grandtotaldisc = grandtotaldisc - ((grandtotaldisc * cashDis)/100);
                }
                component.set('v.disApplied',true);
                component.set('v.GrandTotalDisc',Number(grandtotaldisc).toFixed(2));
            }*/
        }
        else{
            
            //grandtotaldisc = grandtotal;
            component.set('v.disApplied',false);
            component.set('v.showPayment',false);
            //alert(grandtotaldisc)
           // component.set('v.GrandTotalDisc',grandtotal);
            //alert(component.get('v.GrandTotalDisc'))
        }
        
         
        //  var a = component.get('c.getGrandTotal');
        //$A.enqueueAction(a);
    },
    Pending : function(component, event, helper){
        var pe = component.get('v.selectedValue');
        var ot = component.get('v.Pending');
        var gt = component.get('v.GrandTotal');
        
        ot = gt-pe;
        
        component.set('v.Pending',Number(ot).toFixed(2));
        
        
    },
    onSelectPayMode : function(component, event, helper){
        // alert(JSON.stringify(component.get('v.Receipt')))
        var rec = component.get('v.Receipt');
        // alert(JSON.stringify(rec))
        rec.Bank_Name__c = '';
        rec.Cheque_Trasaction_Number__c = '';
        rec.Cheque_Date__c = '';
        
        component.set('v.Receipt',rec);
        
    },
    save: function(component,event,helper) {
        
        //component.set('v.disableBtn',true);
        if (helper.validateOrderList(component, event)) {
           // var oitems= component.get('v.orderItemList');
           // var order= component.get('v.Order');
            //var dataOrderItems = component.get('v.data.orderitems');
            // alert('inside js save method');
            // alert(JSON.stringify(component.get('v.Receipt')));
           // var dataOrder = component.get('v.data.orders');
            //alert(JSON.stringify(dataOrder));
            component.set('v.Order.Payment_Type__c',component.get('v.Receipt.Payment_Type__c'));
           // dataOrderItems.push(oitems);
            
           // dataOrder.push(order);
            
            //component.set('v.data.orderitems',dataOrderItems);
            //component.set('v.data.orders',dataOrder);
            
            
            helper.saveOrder(component,event,helper);
           // helper.checkOnline(component, event, helper);
            
        }else{
            component.set('v.disableBtn',false);
        }
    },
    cancel:function(component, event, helper) {
        
        if(redit == true)
        {
            component.set("v.orderItemList", []);
            component.set('v.GrandTotal',0.00);
            component.set("v.Products", []);
            component.set("v.Order", {});
            component.set("v.matchproducts", []);
            component.set("v.visitsView",true);
            component.set("v.showorder",false);
            component.set("v.showOrderWithItems",false);
            component.set("v.Receipt",{});
            component.set("v.showPayment",false);
            component.set('v.disApplied',false);
            component.set("v.selectedCheckBoxes",[]);
            component.set('v.GrandTotalDisc',0.00);
            var redit = component.get('v.redirect');
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId'),
                "slideDevName": "detail"
            });
            navEvt.fire();
            
        }
        else{
            component.set("v.orderItemList", []);
            component.set('v.GrandTotal',0.00);
            component.set("v.Products", []);
            component.set("v.Order", {});
            component.set("v.matchproducts", []);
            component.set("v.visitsView",true);
            component.set("v.showorder",false);
            component.set("v.showOrderWithItems",false);
            component.set("v.Receipt",{});
            component.set("v.showPayment",false);
            component.set('v.disApplied',false);
            component.set("v.selectedCheckBoxes",[]);
            component.set('v.GrandTotalDisc',0.00);
            var redit = component.get('v.redirect');
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:MobileVisit",
            });
            evt.fire();
        }
        
    },
    
    itemSave: function(component,event,helper) {
        helper.saveQuote(component,event,helper);
    },
    
    searchProduct: function (component, event, helper) {
    try{
        var products = component.get('v.Products');
        console.log(products)
       // var searchText = component.get('v.searchProduct');
        var oitems= component.get('v.orderItemList');
          var index = event.currentTarget.dataset.record;
        
        component.set('v.searchIndex',Number(index));
        // alert(component.get('v.searchIndex'));
       // alert(index)
        //var eid = event.currentTarget.dataset.id;
        
        var searchText = oitems[index].Product_Name__c;
      //  alert(searchText)
        
        var matchprds = [];
        if (searchText != '') {
             const arrLength = products.length;
            for (var i = 0; i < arrLength; i++) {
                
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
    }catch(error){
        console.error(error.message);
    }
    },
    updateProduct: function (component, event, helper) {
        
        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
       // alert(index)
        var eid = event.currentTarget.dataset.id;
        var products = component.get('v.matchproducts');
        var discounts = component.get('v.discounts');
         var cashDis = component.get('v.cashDiscount');
        //alert(JSON.stringify(discounts))
        var oitems= component.get('v.orderItemList');
        console.log('ord----'+JSON.stringify(oitems[index]))
        for (var i = 0; i < products.length; i++) {
           
            
            if (products[i].Id === eid) {
                
                var dis = 0;
                if(products[i].Fixed_Price_Item__c){
                    dis = products[i].Margin__c; 
                }
                else{
                    for (var d = 0; d < discounts.length; d++) {
                        if (products[i].Product_GST__c == discounts[d].GST_Percentage__c) {
                            
                             if(products[i].Product__r.Brand__c == 'Eva Traders'){
                                 dis = discounts[d].Eva_Discount_Percent__c;
                            }else{
                            dis = discounts[d].Discount_Percent__c;
                            }
                        }
                    }
                }
                dis =dis || 0;
                
               // alert(JSON.stringify(oitems))
                //component.set('v.searchProduct', products[i].Product_Batch_Name__c);
                
                /*oitems.push({
                            'sobjectType': 'Sales_Invoice_Item__c',
                            'Name': products[i].Product_Name__c,
                            'Product__c': products[i].Product__c,
                            'Stock__c': products[i].Id,
                            'Available_Quantity__c': products[i].Available_Quantity__c,
                            'Quantity__c': '',
                            'Unit_Price__c': products[i].Price__c - dis,
                            'GST_Percentage__c': products[i].Product_GST__c,
                            'Discount_Percent__c': dis,
                            'Total__c': '',
                            'Total_after_discount__c': ''
                        });*/
              //  alert(products[i].Price__c)
              //  alert(products[i].Price__c - ((products[i].Price__c * dis) / 100))
                cashDis = component.get('v.cashDiscount');
               if(cashDis == null  || products[i].Fixed_Price_Item__c){
                    cashDis = 0;
                }
               var unitPriceAfterDiscount = 0.0;
               
                oitems[index].Name = products[i].Product_Name__c;
                oitems[index].Product_Name__c =products[i].Product_Batch_Name__c;
                oitems[index].Product__c = products[i].Product__c;
                oitems[index].Stock__c = products[i].Id;
                oitems[index].Fixed_Price_Item__c = products[i].Fixed_Price_Item__c;
                
                unitPriceAfterDiscount = (products[i].Price__c - ((products[i].Price__c * dis) / 100));
                oitems[index].Rate__c = Number(unitPriceAfterDiscount).toFixed(2); 
                unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
                
                oitems[index].Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                oitems[index].GST_Percentage__c = products[i].Product_GST__c;
                oitems[index].Discount_Percent__c = dis;
                oitems[index].Sales_Tax__c = products[i].Product_GST__c;
                oitems[index].Available_Quantity__c = products[i].Available_Quantity__c;
                oitems[index].Price__c = products[i].Price__c;
               // oitems[index].Cash_Discount__c = products[i].Cash_Discount__c;
                //oitems[index].Customer_Discount__c = products[i].Customer_Discount__c;
//                alert(JSON.stringify(oitems))
               // oitems[index].Blocked_Quantity__c = products[i].Blocked_Quantity__c;
              
                if(oitems[index].Quantity__c != null && oitems[index].Quantity__c != ''){
                    var salesTaxPercent=0;
                    if(oitems[index].Sales_Tax__c){
                        salesTaxPercent = oitems[index].Sales_Tax__c;
                    }
                    
                    var totalWithGST = oitems[index].Unit_Price__c * oitems[index].Quantity__c;
                    
                    // var totalcashdis = totalWithGST - ((totalWithGST * cashDis) / 100);
                    var totalcashdis =totalWithGST;
                    oitems[index].Cash_Discount__c = Number(cashDis).toFixed(2);
                    oitems[index].Customer_Discount__c = Number(totalcashdis).toFixed(2);
                    
                    var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
                    oitems[index].Total__c = Number(ttl).toFixed(2);
                    oitems[index].Total_Before_Tax__c = Number(totalWithGST).toFixed(2);
                    
                    component.set('v.orderItemList',oitems);
                    
                    var grandtotal = 0;
                    var grandtotaldisc = 0;
                    
                    for (var i = 0; i < oitems.length; i++) {
                        if (oitems[i].Total__c) {
                            
                            grandtotal = Number(grandtotal) + Number(oitems[i].Total__c);
                        }
                    }
                    
                    grandtotaldisc = grandtotal;
                    component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
                    component.set('v.GrandTotalDisc', Number(grandtotaldisc).toFixed(2));
                    
                }
               
                break;
            }
            
        }
        console.log(JSON.stringify(oitems));
        component.set('v.orderItemList', oitems);
        //  console.log(JSON.stringify(products[i]));
        component.set('v.matchproducts', []);
        component.set('v.spinner', false);
        
        
    },
})