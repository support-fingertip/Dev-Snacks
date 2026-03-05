({
    doInit : function(component, event, helper) {
        component.set('v.spinner', true);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        component.set('v.Replacement.Date__c',today);
        
        var action=component.get("c.getCustomer");
        action.setParams({ custId:component.get('v.customerId') });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                component.set('v.customerName', db.Name);
                component.set('v.Replacement.Customer__c', component.get('v.customerId'));
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
        
        helper.addReplaceRecord(component,event);
        helper.getProducts(component,event);
    },
    searchProduct: function (component, event, helper) {
        /*var products = component.get('v.Products');
        var oitems= component.get('v.replaceItems');
        var index = event.currentTarget.dataset.record;
        component.set('v.searchIndex',Number(index));
             oitems[index].Damaged_Stock__c = '';
         oitems[index].New_Stock__c = '';
        var searchText = oitems[index].Name;
        
        var matchprds = [];
        if (searchText != '') {
            
            for (var i = 0; i < products.length; i++) {
                
                if (products[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    matchprds.push(products[i]);
                    
                }
            }
            // alert(JSON.stringify(matchprds))
            if (matchprds.length > 0) {
                component.set('v.matchproducts', matchprds);
                
            }
        } else {
            component.set('v.matchproducts', []);
        }*/
        try{
           
            const products = component.get('v.Products');
            const replaceItems = component.get('v.replaceItems');
            const index = Number(event.currentTarget.dataset.record);
           
            component.set('v.searchIndex', Number(index));
            replaceItems[index].searchIndexPrd = Number(index);
            // Clear stock fields
            replaceItems[index].Damaged_Stock__c = '';
            replaceItems[index].New_Stock__c = '';
            const searchText = replaceItems[index].Name  ;
            const matchedProducts = searchText ? products.filter(product => product.Name.toLowerCase().includes(searchText.toLowerCase()))   : [];
         //   const matchedProducts = searchText ? products.filter(product => product.Name.toLowerCase().includes(searchText))  : [];
            replaceItems[index].matchproducts =  matchedProducts;
            component.set('v.replaceItems', replaceItems);
        }catch(error){
            console.error(error.message);
        }

    },
    updateProduct: function (component, event, helper) {
        
        component.set('v.spinner', true);
        const index = Number(event.currentTarget.dataset.record);
        const productId = event.currentTarget.dataset.id;
        const replaceItems = component.get('v.replaceItems');
        const products =  replaceItems[index].matchproducts;
        // Find the selected product by ID
        const selectedProduct = products.find(product => product.Id === productId);
        
        if (selectedProduct) {
            replaceItems[index].Name = selectedProduct.Name;
            replaceItems[index].Product__c = selectedProduct.Id;
            replaceItems[index].stockList = selectedProduct.Stocks__r || [];
        }
        replaceItems[index].matchproducts = [];
        component.set('v.replaceItems', replaceItems);
        component.set('v.spinner', false);


/*        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var eid = event.currentTarget.dataset.id;
        var products = component.get('v.matchproducts');
        var stockList = component.get('v.stockList');
        var oitems= component.get('v.replaceItems');
        for (var i = 0; i < products.length; i++) {
            
            if (products[i].Id === eid) {
               // console.log('products:---' + JSON.stringify(products[i] ))
                oitems[index].Name = products[i].Name;
                oitems[index].Product__c = products[i].Id;
                stockList = products[i].Stocks__r;
                break;
            }
            
        }
       // console.log('items:====='+JSON.stringify(oitems));
        component.set('v.replaceItems', oitems);
        component.set('v.stockList', stockList);
        //  console.log(JSON.stringify(products[i]));
        component.set('v.matchproducts', []);
        component.set('v.spinner', false);
     */   
        
    },
    searchDamStock: function (component, event, helper) {
       
        /*var stocks = component.get('v.stockList');
        var oitems= component.get('v.replaceItems');
        var index = event.currentTarget.dataset.record;
        component.set('v.searchIndex',Number(index));
        oitems[index].Damaged_Stock__c = '';
         oitems[index].New_Stock__c = '';
             component.set('v.replaceItems', oitems);
        var searchText = oitems[index].Damaged_Stock_Name__c;
        var matchprds = [];
        if (searchText != '' && stocks != null) {
            for (var i = 0; i < stocks.length; i++) {
                if(stocks[i].Product_Batch_Name__c.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    if(stocks[i].Sold_Qty__c > 0){
                        matchprds.push(stocks[i]);
                    }
                }
            }
            if (matchprds.length > 0) {
                component.set('v.matchDmgStocks', matchprds);
            }
        } else {
            component.set('v.matchDmgStocks', []);
        }*/
        
        const replaceItems = component.get('v.replaceItems');
        const index = Number(event.currentTarget.dataset.record);
        const stocks =  replaceItems[index].stockList  || [];
        replaceItems[index].searchIndexDmgStock = index;
        // Clear stock fields
        replaceItems[index].Damaged_Stock__c = '';
        replaceItems[index].New_Stock__c = '';
        const searchText = replaceItems[index].Damaged_Stock_Name__c.toLowerCase() || '';
        const matchedStocks = searchText? stocks.filter(stock =>
            stock.Product_Batch_Name__c.toLowerCase().includes(searchText.toLowerCase()) &&
            stock.Sold_Qty__c > 0): [];
        replaceItems[index].matchDmgStocks =matchedStocks;
         component.set('v.replaceItems', replaceItems);
    },
    updateDamStock: function (component, event, helper) {
       /* 
        component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var Isvalid=true;
        var eid = event.currentTarget.dataset.id;
        var stocks = component.get('v.stockList');
        var oitems= component.get('v.replaceItems');
        for (var i = 0; i < stocks.length; i++) {            
            if (stocks[i].Id === eid && Isvalid==true) {
                oitems[index].Damaged_Stock_Name__c = stocks[i].Product_Batch_Name__c;
                oitems[index].Damaged_Stock__c = stocks[i].Id;
                oitems[index].MRP__c = stocks[i].Price__c;
                break;
            }
        }
       // console.log('items:====='+JSON.stringify(oitems));
        component.set('v.replaceItems', oitems);
        component.set('v.matchDmgStocks', []);
        component.set('v.spinner', false);
       */
        component.set('v.spinner', true);
        const index = Number(event.currentTarget.dataset.record);
        const stockId = event.currentTarget.dataset.id;
        const replaceItems = component.get('v.replaceItems');
        const stocks =  replaceItems[index].stockList  || [];        
        // Debugging log for the selected item
        const selectedStock = stocks.find(stock => stock.Id === stockId);
        if (selectedStock) {
            replaceItems[index].Damaged_Stock_Name__c = selectedStock.Product_Batch_Name__c;
            replaceItems[index].Damaged_Stock__c = selectedStock.Id;
            replaceItems[index].MRP__c = selectedStock.Price__c;
        }
        // Update the component with the modified replaceItems
        replaceItems[index].matchDmgStocks =[]; 
        component.set('v.replaceItems', replaceItems);
        component.set('v.spinner', false);        
    },
    searchNewStock: function (component, event, helper) {
     /*   var stocks = component.get('v.stockList');
        var oitems= component.get('v.replaceItems');
        var index = event.currentTarget.dataset.record;
        component.set('v.searchIndex',Number(index));
        var searchText = oitems[index].New_Stock_Name__c;
        var products = component.get('v.Products');
        var stockList=[];
           oitems[index].New_Stock__c = '';
             component.set('v.replaceItems', oitems);
        products.forEach(function(record){
            if(record.Stocks__r != null){
                var stock=[];
                stock =record.Stocks__r;
                stock.forEach(function(rec){
                    if(rec.Available_Quantity__c != undefined && rec.Available_Quantity__c >0 && rec.Price__c!=undefined && rec.Price__c == oitems[index].MRP__c) 
                        stockList.push(rec);             
                });
            }
        });         
        if(stockList.length <= 0){
            helper.showToast('Same MRP stocks not available for replacement','error');  
        }
        component.set('v.newStockList',stockList);
        var matchprds = [];
        if (searchText != '') {
            for (var i = 0; i < stockList.length; i++) {
                //stocks[i].price__c == oitems[index].MRP__c;
                if (stockList[i].Product_Batch_Name__c.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    matchprds.push(stockList[i]);
                }
            }
            if (matchprds.length > 0) {
                component.set('v.matchNewStocks', matchprds);
                
            }
        } else {
            component.set('v.matchNewStocks', []);
        }*/
        try{
        const products = component.get('v.Products') ;
        const replaceItems = component.get('v.replaceItems');
        const index = Number(event.currentTarget.dataset.record);
        const searchText = replaceItems[index].New_Stock_Name__c.toLowerCase();
        // Clear stock field for the selected item
            replaceItems[index].New_Stock__c = '';
            replaceItems[index].searchIndexNewStock = index;
           
            var stockList=[];
        // Filter stocks matching MRP and having available quantity
            products.forEach(function(record){
                if(record.Stocks__r != null){
                    var stock=[];
                    stock =record.Stocks__r;
                    stock.forEach(function(rec){
                        if(rec.Available_Quantity__c != undefined && rec.Available_Quantity__c >0 && rec.Price__c!=undefined && rec.Price__c == replaceItems[index].MRP__c) 
                            stockList.push(rec);             
                    });
                }
            }); 
        if (stockList.length === 0) {
        helper.showToast('Same MRP stocks not available for replacement', 'error');
        }
        replaceItems[index].newStockList = stockList;;
        // Filter stocks matching the search text
        const matchedStocks = searchText ? stockList.filter(stock =>stock.Product_Batch_Name__c.toLowerCase().includes(searchText.toLowerCase())) : [];
         replaceItems[index].matchNewStocks =matchedStocks; 
        component.set('v.replaceItems', replaceItems);  
        }catch(error){
            console.error(error.message);
        }
    },
    updateNewStock: function (component, event, helper) {
      /*  component.set('v.spinner', true);
        var index = event.currentTarget.dataset.record;
        var eid = event.currentTarget.dataset.id;
        var stocks = component.get('v.newStockList');
        var Isvalid =true;
        var oitems= component.get('v.replaceItems');
         var replList = component.get("v.replaceItems");
         replList.forEach(function(record){
             if(record.New_Stock__c == eid && record.Product__c ==  oitems[index].Product__c){
              Isvalid=false;  
                  helper.showToast('Replacement item with selected stock already present in the list','warning');
             }
        });
        for (var i = 0; i < stocks.length; i++) {
            
            if (stocks[i].Id === eid && Isvalid) {
              //  console.log('stocks:---' + JSON.stringify(stocks[i] ))
                oitems[index].New_Stock_Name__c = stocks[i].Product_Batch_Name__c;
                oitems[index].New_Stock__c = stocks[i].Id;
                oitems[index].Available_Quantity__c = stocks[i].Available_Quantity__c;
                break;
            }
        }
       // console.log('items:====='+JSON.stringify(oitems));
        component.set('v.replaceItems', oitems);
        component.set('v.matchNewStocks', []);
        component.set('v.spinner', false);
        */
        component.set('v.spinner', true);
        const index = Number(event.currentTarget.dataset.record);
        const stockId = event.currentTarget.dataset.id;
         const replaceItems = component.get('v.replaceItems');
        const stocks =  replaceItems[index].newStockList ;
        let isValid = true;
        // Check if the selected stock is already in use
        replaceItems.forEach(record => {
            if (record.New_Stock__c === stockId && record.Product__c === replaceItems[index].Product__c) {
            isValid = false;
            helper.showToast('Replacement item with selected stock already present in the list', 'warning');
        } });
        // Update the selected item if valid
        if (isValid) {
            const selectedStock = stocks.find(stock => stock.Id === stockId);
            if (selectedStock) {
                replaceItems[index].New_Stock_Name__c = selectedStock.Product_Batch_Name__c;
                replaceItems[index].New_Stock__c = selectedStock.Id;
                replaceItems[index].Available_Quantity__c = selectedStock.Available_Quantity__c;
            }
        }
        // Update component attributes
        replaceItems[index].matchNewStocks =[];
        component.set('v.replaceItems', replaceItems);
        component.set('v.spinner', false);

    },
    addRow: function(component, event, helper) { 
        helper.addReplaceRecord(component, event, helper);
    },
    removeRow : function(component, event, helper) {
        component.set('v.spinner',true);
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        
        var oitems= component.get('v.replaceItems');
      //  console.log('items in remove1:' + oitems);
        
        oitems.splice(index, 1);
        component.set("v.replaceItems", oitems);
       // console.log('items in remove2:' + oitems);
        if(oitems.length < 1){
            helper.addReplaceRecord(component, event, helper);
        }
        component.set('v.spinner',false);
        
    },
    save : function(component, event, helper) {
        let isAllValid = component.find('field1').reduce(function (isValidSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);
        
        if (isAllValid == true) {
            // component.set('v.disableSave', true);
            if (helper.validate(component, event, helper)) {
                helper.saveRecord(component, event, helper);
            }
        }
        
    },
    CancelClick : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:MobileVisit",
        });
        evt.fire();   
        
    },
    
})