({
    doInit : function(component, event, helper){
        
        if(window.navigator.onLine){
            helper.addProductRecord(component, event);
            component.set('v.spinner',true);
            
            var action1 = component.get("c.getData");
            action1.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var db = response.getReturnValue();
                    if(db != null){
                        helper.data.currentvisit = db.currentvisit;
                        helper.data.stocks = db.stocks;
                        component.set('v.data',helper.data);
                        component.set('v.Stocks',db.stocks);
                        component.set('v.Products',db.products);
                        component.set('v.discounts', db.discounts);
                        component.set('v.cashDiscount',db.currentvisit.Account1__r.Cash_Discount__c);
                        console.log(component.get('v.cashDiscount'));
                        
                        var order = {};
                        order.Customer__c = db.currentvisit.Account1__c;
                        order.Visit__c = db.currentvisit.Id;
                        order.Daily_logs__c = db.currentvisit.Daily_log__c;
                        order.Trip__c = db.currentvisit.Daily_log__r.Trip__c;
                        
                        component.set('v.Order',order);
                        component.set('v.spinner', false);
                        console.log(JSON.stringify(component.get('v.Order')));
                    }
                    else{
                        helper.showToast("Please start the visit first!","error");
                        component.set('v.spinner', false);
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:MobileVisit",
                        });
                        evt.fire();
                    }
                    
                }
            });
            $A.enqueueAction(action1);
        }
        else{
            helper.showToast("You are offline!","info");
        }
        
    },
    getGrandTotal : function(component, event, helper) {
        
        var index = event.currentTarget.dataset.record;
        var oitems= component.get('v.orderItemList');
        var cashDis = component.get('v.cashDiscount');
        
        console.log('Sales_Tax__c== '+oitems[index].Sales_Tax__c);
        
        var salesTaxPercent=0;
        if(oitems[index].Sales_Tax__c){
            salesTaxPercent = oitems[index].Sales_Tax__c;
        }
        
        var totalWithGST = oitems[index].Unit_Price__c * oitems[index].Quantity__c;
        if(cashDis == null){
            cashDis = 0;
        }
        var totalcashdis =totalWithGST;
        oitems[index].Cash_Discount__c = Number(cashDis).toFixed(2);
        oitems[index].Customer_Discount__c = Number(totalcashdis).toFixed(2);
        
        var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
        oitems[index].Total__c = Number(ttl).toFixed(2);
        oitems[index].Total_Before_Tax__c = Number(totalWithGST).toFixed(2);
        oitems[index].Total_after_discount__c = oitems[index].Total__c;
        
        component.set('v.orderItemList',oitems);
        
        var grandtotal = 0;
        var grandtotaldisc = 0;
        
        for (var i = 0; i < oitems.length; i++) {
            if (oitems[i].Total__c) {
                grandtotal = Number(grandtotal) + Number(oitems[i].Total__c);
            }
        }
        grandtotaldisc = component.get('v.GrandTotalDisc');
        
        grandtotaldisc = grandtotal;
        component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
        component.set('v.GrandTotalDisc', Number(grandtotaldisc).toFixed(2));
        
    },
    searchProduct: function (component, event, helper) {
        
        var stocks = component.get('v.Stocks');
        // alert(stocks)
        var oitems= component.get('v.orderItemList');
        var index = event.currentTarget.dataset.record;
        
        component.set('v.searchIndex',Number(index));
        
        var searchText = oitems[index].Product_Name__c;
        //  alert(searchText)
        
        var matchprds = [];
        if (searchText != '') {
            const arrLength = stocks.length;
            for (var i = 0; i < arrLength; i++) {
                
                if (stocks[i].Product_Batch_Name__c.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    matchprds.push(stocks[i]);
                    
                }
            }
            if (matchprds.length > 0) {
                component.set('v.matchstocks', matchprds);
                
            }
        } else {
            component.set('v.matchstocks', []);
        }
        
    },
    updateProduct: function (component, event, helper) {
        
        
        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        // alert(index)
        var eid = event.currentTarget.dataset.id;
        var stocks = component.get('v.matchstocks');
        var discounts = component.get('v.discounts');
        var cashDis = component.get('v.cashDiscount');
        console.log(component.get('v.cashDiscount'));
        //alert(JSON.stringify(discounts))
        var oitems= component.get('v.orderItemList');
        console.log('ord----'+JSON.stringify(oitems[index]))
        for (var i = 0; i < stocks.length; i++) {
            var dis = 0;
            for (var d = 0; d < discounts.length; d++) {
                if (stocks[i].Product_GST__c == discounts[d].GST_Percentage__c) {
                    if(stocks[i].Product__r.Brand__c == 'Eva Traders'){
                        dis = discounts[d].Eva_Discount_Percent__c;
                    }else{
                        dis = discounts[d].Discount_Percent__c;
                    }
                }
            }
            
            if (stocks[i].Id === eid) {
                
                console.log(cashDis);
                if(cashDis == null){
                    cashDis = 0;
                    console.log('--if'+cashDis);
                }
                var unitPriceAfterDiscount = 0.0;
                
                oitems[index].Name = stocks[i].Product_Name__c;
                oitems[index].Product_Name__c =stocks[i].Product_Batch_Name__c;
                oitems[index].Product__c = stocks[i].Product__c;
                oitems[index].Stock__c = stocks[i].Id;
                
                unitPriceAfterDiscount = (stocks[i].Price__c - ((stocks[i].Price__c * dis) / 100));
                oitems[index].Rate__c = Number(unitPriceAfterDiscount).toFixed(2); 
                unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
                
                oitems[index].Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                oitems[index].GST_Percentage__c = stocks[i].Product_GST__c;
                oitems[index].Discount_Percent__c = dis;
                oitems[index].Sales_Tax__c = stocks[i].Product_GST__c;
                oitems[index].Available_Quantity__c = stocks[i].Available_Quantity__c;
                oitems[index].Price__c = stocks[i].Price__c;
                oitems[index].Cash_Discount__c = Number(cashDis).toFixed(2);
                
                if(oitems[index].Quantity__c != null && oitems[index].Quantity__c != ''){
                    var salesTaxPercent=0;
                    if(oitems[index].Sales_Tax__c){
                        salesTaxPercent = oitems[index].Sales_Tax__c;
                    }
                    
                    var totalWithGST = oitems[index].Unit_Price__c * oitems[index].Quantity__c;
                    
                    var totalcashdis =totalWithGST;
                    console.log('---cff'+Number(cashDis).toFixed(2));
                    
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
        //  console.log(JSON.stringify(stocks[i]));
        component.set('v.matchstocks', []);
        component.set('v.spinner', false);
        
        
    },
    addRow: function(component, event, helper) { 
        helper.addProductRecord(component, event);
        
    },
    removeRow : function(component, event, helper) {
        
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        console.log(index);
        var oitems= component.get('v.orderItemList');
        console.log(JSON.stringify(oitems));
        /* var salesTaxPercent=0;
        if(oitems[index].Sales_Tax__c){
            salesTaxPercent = oitems[index].Sales_Tax__c;
        }*/
        if( oitems[index].Quantity__c !='' && oitems[index].Quantity__c !=undefined){
            // var total = ((oitems[index].Unit_Price__c * oitems[index].Quantity__c)+(oitems[index].Unit_Price__c * oitems[index].Quantity__c * salesTaxPercent / 100));
            var grandtotal = (component.get('v.GrandTotalDisc')-oitems[index].Total__c);
            
            component.set('v.GrandTotalDisc',Number(grandtotal).toFixed(2));
            component.set('v.GrandTotal',Number(grandtotal).toFixed(2));
        }
        oitems.splice(index, 1);
        component.set("v.orderItemList", oitems);
        
        if(oitems.length < 1){
            helper.addProductRecord(component, event);
        }
        component.set('v.spinner',false);
        
    },
    CancelClick: function (component, event) {
        if(window.navigator.onLine){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:MobileVisit",
            });
            evt.fire();
        }
        else{
            helper.showToast("You are offline!","info");
        }
        
    },
    save: function(component,event,helper) {
        
        if (helper.validateOrderList(component, event)) {
            helper.saveOrder(component,event,helper);
        }else{
            component.set('v.disableBtn',false);
        }
        
    },
})