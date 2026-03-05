({
	 getColumnAndAction : function(component,helper) {
         
        var action = component.get("c.getUIThemeDescription");
         
        action.setCallback(this, function(a) {
            //component.set("v.theme", a.getReturnValue());
            if(a.getReturnValue()=='Theme4d'){
                component.set("v.isDesktop",true);
                component.set("v.isMobile1",false);
                component.set('v.columns', [
                    //{ label: 'Image', fieldName: 'Product_Image_Url__c', cellAttributes: { class: 'slds-text-color_error slds-text-title_bold'}},
                            {label: 'Name', fieldName: 'Name', type: 'text',sortable : true , wrapText: true},
                            {label: 'Product Code', fieldName: 'Product_Code__c', type: 'text',sortable : true , wrapText: true},
                            {label: 'Item Description', fieldName: 'Item_Description__c', type: 'text',sortable : true , wrapText: true},
                    		{label: 'Fixed Price Item', fieldName: 'Fixed_Price_Item__c', type: 'text',sortable : true , wrapText: true},
                         //  {label: 'Unit', fieldName: 'Unit__c', type: 'text',sortable : true , wrapText: true}, 
                           //{label: 'Product Category', fieldName: 'Product_catogery__c', type: 'text',sortable : true , wrapText: true}
                        ]);
                
            }else if(a.getReturnValue()=='Theme4t'){
                component.set("v.isMobile1",true);
                component.set("v.isDesktop",false);
                component.set('v.columns', [
                                 {label: 'Name', fieldName: 'Name', type: 'text',sortable : true , wrapText: true},
                            {label: 'Product Code', fieldName: 'Product_Code__c', type: 'text',sortable : true , wrapText: true},
                                {label: 'Details', type: 'button', initialWidth: 105, typeAttributes: { label:'Details', name:'view', title: 'Click to View Details'}}, 
                               // {label: 'Account Address', fieldName: 'BillingAddress', type: 'text',sortable : true , wrapText: true}
                              ]);
                    } 
                    console.log('='+component.get("v.isMobile1")+'::'+component.get("v.isDesktop"));
                    helper.getProductsList(component, helper);
                    });
        $A.enqueueAction(action);
         
    },
      
    getProductsList : function(component, helper) {
             
        var searchField;
        var searchVal='';
        var action = component.get("c.getProducts");
        var pageSize = component.get("v.pageSize").toString();
        var pageNumber = component.get("v.pageNumber").toString();
        var sortBy = component.get("v.sortBy");
        var sortDirection = component.get("v.sortDirection");
        
        //component.find('Id_spinner').set('v.class','slds-show'); 
                    if(component.get("v.isDesktop")){
                        if(component.get('v.searchType') == 'Name') {           
                        searchField = component.find('searchField');  
                    	searchVal = searchField.get('v.value');
                        }
                         
                        if(component.get('v.searchType') == 'Code') {          
                        searchField = component.find('searchField2');  
                    searchVal = searchField.get('v.value');
                        }
                       
                    }
                    else if(component.get("v.isMobile1")){
                        searchField = component.find('m_SearchField');
                    searchVal = searchField.get('v.value');
                    }
       //  alert(searchVal)
        action.setParams({
            'pageSize' : pageSize,
            'pageNumber' : pageNumber,
            'searchText':searchVal,
            'sortDirection':sortDirection,
            'sortBy':sortBy,
            'searchType':component.get('v.searchType')
        });
         
        action.setCallback(this,function(response) {
            var state = response.getState();
            component.find('Id_spinner').set('v.class' , 'slds-hide');
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                    
                var parseData = JSON.parse(JSON.stringify(resultData));
                parseData.forEach(function(record){
                    record.linkName = '/'+record.OwnerId;
                });
                var resData = parseData.slice(0, component.get('v.pageSize'));
                  //  alert(JSON.stringify(resData))
                component.set("v.data", resData);
                component.set("v.dataSize", resData.length);
                component.set("v.dataSort", parseData);
                component.set('v.totalRecords',resultData.length);
                component.set("v.condition",true);
                 
                  //  alert(resultData.length);
                   // alert(component.get('v.pageSize'))
                    
                if(resultData.length > component.get('v.pageSize')) {
                    component.set('v.totalPage',Math.ceil(resultData.length/component.get('v.pageSize')));
                }
                 
                if(component.get('v.pageNumber') < component.get('v.totalPage')) {
                    component.set('v.isLastPage',false);
                } else {
                    component.set("v.isLastPage", true);
                }
            }
        });
        $A.enqueueAction(action);
    },
      validateReqList: function(component, event) {
        var isValid = true;
        var prdList = component.get("v.stockRequests");
                   // alert(JSON.stringify(prdList))
        for (var i = 0; i < prdList.length; i++) {
             if(prdList[i].Quantity__c == '' || prdList[i].Quantity__c == null || prdList[i].Quantity__c == 0){
                 isValid = false;
                 alert('please enter valid quantity on row number ' + (i + 1));
            }
               
        }
        return isValid;
    }, 
    saveOrder : function(component,event,helper) {  
            
            var action1=component.get("c.saveNewRequest");
            action1.setParams({'reqList':  component.get('v.stockRequests')
                              });
            action1.setCallback(this,function(response){ 
                //alert(response.getState());
                if(response.getState() == "SUCCESS"){
                    
                    helper.showToast('Stock Request has been created Successfully!','Success');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.getReturnValue(),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
                }else if (response.getState() === "ERROR") {
                    //alert(1);
                    var errors = response.getError();
                    //alert(JSON.stringify(errors));
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    }
                }
            });
            $A.enqueueAction(action1); 
            
            
            
    }, 
    showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
    sortData : function(component,fieldName,sortDirection) { 
        var data = component.get("v.dataSort");
        if (fieldName == 'linkName') {
            fieldName = 'OwnerName';
        } 
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
         
        data.sort(function(a,b){ 
            var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a>b) - (b>a));
        });    
         
        //set sorted data to account data attribute
        data.forEach(function(record) {
            record.linkName = '/'+record.OwnerId;
        });
        var data1 = data.slice((component.get("v.pageNumber") * component.get('v.pageSize')) - 15, component.get("v.pageNumber") * component.get('v.pageSize'));
        component.set("v.data",data1);
        component.set("v.dataSort", data);
    },
})