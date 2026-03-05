({
    doInit : function(component, event, helper){
        
        if(window.navigator.onLine){
            
            component.set('v.spinner',true);
            
            var action1 = component.get("c.getData");
            action1.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var db = response.getReturnValue();
                    if(db != null){
                        helper.data.currentvisit = db.currentvisit;
                        helper.data.wrapper = db.stocks;
                        component.set('v.data',helper.data);
                        component.set('v.wrapper',db.stocks);
                        component.set('v.searchList',db.stocks);
                        component.set('v.discounts', db.discounts);
                        component.set('v.cashDiscount',db.currentvisit.Account1__r.Cash_Discount__c);
                        console.log(JSON.stringify(db.stocks));
                        
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
    addToCart: function(component, event, helper) {
        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var wrapper= component.get('v.searchList');
        var cartProductIds = component.get('v.cartProductIds');
       
        if(wrapper[index].availableQty >= wrapper[index].quantity){
            if(cartProductIds.includes(wrapper[index].stock.Id) && (wrapper[index].quantity < 1 || wrapper[index].quantity > wrapper[index].availableQty)){
                var ne=cartProductIds.indexOf(wrapper[index].stock.Id);
                cartProductIds.splice(ne,1);
            }
            else{
                
                if(!cartProductIds.includes(wrapper[index].stock.Id) && wrapper[index].quantity > 0){
                    cartProductIds.push(wrapper[index].stock.Id);  
                }
               
            }
        }
        else{
            if(cartProductIds.includes(wrapper[index].stock.Id)){
                var ne=cartProductIds.indexOf(wrapper[index].stock.Id);
                cartProductIds.splice(ne,1);
            }
            helper.showToast("Added quantity is more than available quantity for "+wrapper[index].product.Name,"error");
        }
        if(cartProductIds.length > 0){
            component.set('v.disableCart',false);
        }
        else{
            component.set('v.disableCart',true);
        }
       component.set('v.cartProductIds',cartProductIds);
        component.set('v.spinner', false);
       
    },
    cartClickOrder : function(component, event, helper){
        component.set('v.spinner', true);
        var oitems= component.get('v.orderItemList');
        var cashDis = component.get('v.cashDiscount');
        var wrapper= component.get('v.wrapper');
        var discounts = component.get('v.discounts');
        var cartProductIds = component.get('v.cartProductIds');
        
        var orderitems = [];
        var grandtotal = 0;
        var totalqty = 0;
        for(var i=0;i<wrapper.length;i++){
            
            if(cartProductIds.includes(wrapper[i].stock.Id) && (wrapper[i].quantity != 0 && wrapper[i].quantity != null && wrapper[i].quantity != undefined)){
                var dis = 0;
                if(wrapper[i].stock.Fixed_Price_Item__c){
                    dis = wrapper[i].stock.Margin__c; 
                }
                else{
                    for (var d = 0; d < discounts.length; d++) {
                        if (wrapper[i].stock.Product_GST__c == discounts[d].GST_Percentage__c) {
                 
                             if(wrapper[i].stock.Product__r.Brand__c == 'Eva Traders'){
                                 dis = discounts[d].Eva_Discount_Percent__c;
                            }else{
                            dis = discounts[d].Discount_Percent__c;
                            }
                        }
                    }
                }
               
                
                var item = {};
                if(cashDis == null || wrapper[i].stock.Fixed_Price_Item__c){
                    cashDis = 0;
                }
               dis = dis || 0;
                var unitPriceAfterDiscount = 0.0;
                
                item.Name = wrapper[i].stock.Product_Name__c;
                item.Product_Name__c =wrapper[i].stock.Product_Batch_Name__c;
                item.Product__c = wrapper[i].product.Id;
                item.Stock__c = wrapper[i].stock.Id;
                
                unitPriceAfterDiscount = (wrapper[i].price - ((wrapper[i].price * dis) / 100));
                item.Rate__c = Number(unitPriceAfterDiscount).toFixed(2); 
                unitPriceAfterDiscount = (unitPriceAfterDiscount - ((unitPriceAfterDiscount * cashDis) / 100));
                
                item.Unit_Price__c = Number(unitPriceAfterDiscount).toFixed(2);
                item.Quantity__c = wrapper[i].quantity;
                item.GST_Percentage__c = wrapper[i].stock.Product_GST__c;
                item.Discount_Percent__c = dis;
                item.Sales_Tax__c = wrapper[i].stock.Product_GST__c;
                item.Available_Quantity__c = wrapper[i].availableQty;
                item.Price__c = wrapper[i].price;
                item.Fixed_Price_Item__c = wrapper[i].stock.Fixed_Price_Item__c;
                item.Cash_Discount__c = Number(cashDis).toFixed(2);
                 
                var SalesTaxPrice=0;
                if(item.Unit_Price__c && wrapper[i].stock.Product_GST__c){
                    SalesTaxPrice  = (item.Unit_Price__c * item.Sales_Tax__c) / 100;
                }
                
                item.Sales_Tax_PercentValue__c = Number(SalesTaxPrice).toFixed(2) + '(' + item.Sales_Tax__c + '%)';
                
                var salesTaxPercent=0;
                if(item.Sales_Tax__c){
                    salesTaxPercent = item.Sales_Tax__c;
                }
                
                var totalWithGST = item.Unit_Price__c * item.Quantity__c;
                item.Total_Before_Tax__c = Number(totalWithGST).toFixed(2);
                
                var totalcashdis =totalWithGST;
                
                item.Customer_Discount__c = Number(totalcashdis).toFixed(2);
                
                var ttl = totalcashdis + (totalcashdis * salesTaxPercent/100 );
                item.Total__c = Number(ttl).toFixed(2);
                item.Total_after_discount__c = item.Total__c;
                
                grandtotal = Number(grandtotal) + Number(item.Total__c);
                totalqty = Number(totalqty) + Number(item.Quantity__c);
                
                console.log(grandtotal)
                orderitems.push(item);
                console.log(JSON.stringify(orderitems))
            }
           
        }
        
        if(orderitems.length >0){
            component.set('v.orderItemList',orderitems);
            component.set('v.GrandTotal', Number(grandtotal).toFixed(2));
            component.set('v.TotalQty', totalqty);
            
            component.set('v.spinner', false);
            component.set('v.showCart', true);
        }else{
            helper.showToast("Add atleast 1 item in the cart!","error");
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
    goBack: function(component, event, helper){
        component.set('v.spinner', true);
        component.set('v.showCart', false);
        component.set('v.spinner', false);
    },
    removeRow : function(component, event, helper) {
       component.set('v.spinner',true);
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        console.log(index);
        var oitems= component.get('v.orderItemList');
        var wrapper= component.get('v.wrapper');
        var cartProductIds = component.get('v.cartProductIds');
        console.log(JSON.stringify(oitems));
        
        for(var i=0;i<wrapper.length;i++){
            if(oitems[index].Stock__c == wrapper[i].stock.Id){
                wrapper[i].quantity = 0;
            }
        }
        
        if(cartProductIds.includes(oitems[index].Stock__c) ){
            var ne=cartProductIds.indexOf(oitems[index].Stock__c);
            cartProductIds.splice(ne,1);
          
        }
        if( oitems[index].Quantity__c !='' && oitems[index].Quantity__c !=undefined){
            // var total = ((oitems[index].Unit_Price__c * oitems[index].Quantity__c)+(oitems[index].Unit_Price__c * oitems[index].Quantity__c * salesTaxPercent / 100));
            var grandtotal = (component.get('v.GrandTotal')-oitems[index].Total__c);
           
            component.set('v.GrandTotal',Number(grandtotal).toFixed(2));
        }
        oitems.splice(index, 1);
        component.set("v.orderItemList", oitems);
        
        if(oitems.length < 1){
            component.set('v.showCart', false);
        }
        
        if(cartProductIds.length > 0){
            component.set('v.disableCart',false);
        }
        else{
            component.set('v.disableCart',true);
        }
        component.set('v.cartProductIds',cartProductIds);
        component.set('v.wrapper',wrapper);
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
   
    searchProducts: function (component, event) {
        var searchtext = component.get('v.searchProductName');
        var stlist = component.get('v.wrapper');
         var searchRes = [];
        if (searchtext != '' && searchtext != null) {
            for (var i = 0; i < stlist.length; i++) {
               
                if (stlist[i].product.Product_Name_Code__c.toLowerCase().includes(searchtext.toLowerCase())) {
                    searchRes.push(stlist[i]);
                }
            }
            component.set('v.searchList', searchRes);
        }
        else {
            component.set('v.searchList', component.get('v.wrapper'));
        }
    },
})