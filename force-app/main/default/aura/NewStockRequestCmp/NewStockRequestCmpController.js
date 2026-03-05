({
	doInit : function(component, event, helper) {
		var action=component.get("c.getStock");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                
                component.set('v.stockList',db);
            }
        });
        $A.enqueueAction(action);
         component.set('v.pageNumber',1);
            component.set('v.isLastPage',false);
            component.set('v.dataSize',0);
            component.set('v.data','');
            component.set('v.dataSort','');
            component.set('v.totalRecords',0);
            component.set('v.totalPage',1);
            component.set('v.isLastPage',true);
        component.set('v.searchType','');
         helper.getColumnAndAction(component,helper);
       
        component.set('v.condition',true);
	},
   
    onSearchChange: function(component, event, helper) {
        component.find('searchField').set("v.disabled", false); 
        component.find('searchField2').set("v.disabled", false); 
      
        component.set('v.searchType','');
         
        var val = event.getSource().get("v.value");
        if(val != null && (val).trim() != '' && ((val).trim()).length > 0) {
             
            if(event.getSource().getLocalId() == 'searchField') {
                component.find('searchField2').set("v.disabled", true); 
               
                component.set('v.searchType','Name');
            }
             
            if(event.getSource().getLocalId() == 'searchField2') {
                component.find('searchField').set("v.disabled", true); 
               
                component.set('v.searchType','Code');
            }
         
        }
    },
    Search: function(component, event, helper) {
        component.set('v.pageNumber',1);
        component.set('v.isLastPage',false);
        component.set('v.dataSize',0);
        component.set('v.data','');
        component.set('v.dataSort','');
        component.set('v.totalRecords',0);
        component.set('v.totalPage',1);
        component.set('v.isLastPage',true);
        // alert(component.find('searchType'))
        if(component.get('v.searchType') != undefined && component.get('v.searchType') != '') {
            var searchField;
           
            if(component.get('v.searchType') == 'Name') {           
                searchField = component.find('searchField');        
            }
            if(component.get('v.searchType') == 'Code') {          
                searchField = component.find('searchField2');       
            }
           // alert(searchField.get('v.value'))
            var isValueMissing = searchField.get('v.validity').valueMissing;
             
            if(isValueMissing) {
                searchField.showHelpMessageIfInvalid();
                searchField.focus();
            } else {
                searchField.set('v.value',(searchField.get('v.value')).trim());
                if(searchField.get('v.value').length < 3) {
                    searchField.set('v.validity', {valid:false, badInput :true});
                    searchField.showHelpMessageIfInvalid();
                    searchField.focus();
                } else {
                    helper.getProductsList(component, helper);
                }
            }
        }
        else {
                    helper.getProductsList(component, helper);
                }
    },
     updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        // alert(JSON.stringify(selectedRows))
        
        component.set('v.SelectedProducts', selectedRows);
    },
     NextClick: function (component, event, helper) {
         var itm = component.get('v.SelectedProducts');
         
         if(itm.length >= 1){
              var stockRequests = component.get('v.stockRequests');
         var selRows=component.get('v.selectedRows');
           
         for(var i=0;i<itm.length;i++){
             let obj = stockRequests.find(o => o.Product__c === itm[i].Id);
             if(obj == undefined){
                 stockRequests.push({
                     'sobjectType': 'Stock_Request_Item__c',
                     'Name': itm[i].Name,
                     'Product__c': itm[i].Id,
                     'Quantity__c': '',
                     'Item_Code__c': itm[i].Product_Code__c,
                     'Status__c': 'Requested'
                     
                 });
                 
                 selRows.push(itm[i].Id);
             }
             
             
         }
       
         component.set('v.stockRequests',stockRequests);
             component.set('v.selectedRows',selRows);
         component.set("v.showReq",true);
        
         }
         else{
             helper.showToast('Select at least one record and try again.','Error');
         }
     
    },
    
    save: function(component,event,helper) {
        
        if (helper.validateReqList(component, event)) {
            helper.saveOrder(component,event,helper);
        }
    },
    prev: function(component,event,helper) {
       
        component.set("v.showReq",false);
        
    },
    cancel:function(component, event, helper) {
    var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Stock_Request__c"
        });
        homeEvt.fire();
         $A.get('e.force:refreshView').fire();
        
    },
      onSearchType: function(component, event, helper) {
        component.find('m_SearchField').set("v.disabled", true);
        component.find('m_SearchButton').set("v.disabled", true);  
        component.set('v.searchType','');
        if(component.find('selectSearchType').get('v.value') != 'NONE'){
            component.find('m_SearchField').set("v.disabled", false);
            component.find('m_SearchButton').set("v.disabled", false);
            component.set('v.searchType',component.find('selectSearchType').get('v.value'));
        }else{
            component.set('v.pageNumber',1);
            component.set('v.isLastPage',false);
            component.set('v.dataSize',0);
            component.set('v.data','');
            component.set('v.dataSort','');
            component.set('v.totalRecords',0);
            component.set('v.totalPage',1);
            component.set('v.isLastPage',true);
        }     
    },
    SearchMobile: function(component, event, helper) {
         
        component.set('v.pageNumber',1);
        component.set('v.isLastPage',false);
        component.set('v.dataSize',0);
        component.set('v.data','');
        component.set('v.dataSort','');
        component.set('v.totalRecords',0);
        component.set('v.totalPage',1);
        component.set('v.isLastPage',true);
         
            var searchField = component.find('m_SearchField');
            if(searchField == undefined || searchField.get('v.value') == undefined) {
                searchField.set('v.validity', {valid:false, badInput :true});
                searchField.showHelpMessageIfInvalid();
                searchField.focus();
            } else {
                searchField.set('v.value',(searchField.get('v.value')).trim());
                if(searchField.get('v.value').length < 3) {
                    searchField.set('v.validity', {valid:false, badInput :true});
                    searchField.showHelpMessageIfInvalid();
                    searchField.focus();
                } else {
                    helper.getProductsList(component, helper);
                }
            }
    },
    handleSort : function(component,event,helper) {
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    },
      
    handleNext : function(component, event, helper) { 
         var itm = component.get('v.SelectedProducts');
        alert('itm:'+itm)
          alert('selrows:'+component.get('v.selectedRows'))
         
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
         
        var dataSort1 = component.get("v.dataSort");
        var parseData = JSON.parse(JSON.stringify(dataSort1));
        var data1 = parseData.slice((component.get("v.pageNumber") * component.get('v.pageSize')) - 15, component.get("v.pageNumber") * component.get('v.pageSize'));
        component.set("v.data", data1);
        component.set("v.dataSize", data1.length);
         
        if(component.get('v.pageNumber') == component.get('v.totalPage')) {
            component.set('v.isLastPage',true);
        } else {
            component.set("v.isLastPage", false);
        }
    },
      
    handlePrev : function(component, event, helper) {        
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
         
        var dataSort1 = component.get("v.dataSort");
        var parseData = JSON.parse(JSON.stringify(dataSort1));
        var data1 = parseData.slice((component.get("v.pageNumber") * component.get('v.pageSize')) - 15, component.get("v.pageNumber") * component.get('v.pageSize'));
        component.set("v.data", data1);
        component.set("v.dataSize", data1.length);
        component.set("v.isLastPage", false);
    },
     
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
         alert(JSON.stringify(row))
        if (action.name == 'view') {
            component.set("v.modal", true);
            component.set("v.Name", row.Name);
            component.set("v.code", row.Product_Code__c);
            component.set("v.desc", row.Item_Description__c);
            component.set("v.unit", row.Unit__c);
            component.set("v.fixed", row.Fixed_Price_Item__c);
            component.set("v.category", row.Product_catogery__c);
        }
    },
     
    closeModel: function(component, event, helper) {
      component.set("v.modal", false);
   },
   

})