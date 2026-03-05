({  
    FilterRecords :function(component) {  
        //data showing in table  
        var data = component.get("v.data");  
        // all data featched from apex when component loaded  
        var allData = component.get("v.UnfilteredData");  
        //Search tems  
        var searchKey = component.get("v.filter");  
        // check is data is not undefined and its lenght is greater than 0  
        if(data!=undefined || data.length>0){  
            // filter method create a new array tha pass the test (provided as function)  
            var filtereddata = allData.filter(word => (!searchKey) || word.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);  
            console.log('** '+filtereddata);  
        }  
        // set new filtered array value to data showing in the table.  
        component.set("v.data", filtereddata);  
        // check if searchKey is blank  
        if(searchKey==''){  
            // set unfiltered data to data in the table.  
            component.set("v.data",component.get("v.UnfilteredData"));  
        }  
        if (searchKey==''){
            component.set("v.onsearch", false);  
        }
        else{
            component.set("v.onsearch", true);
        }
    },
    showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})