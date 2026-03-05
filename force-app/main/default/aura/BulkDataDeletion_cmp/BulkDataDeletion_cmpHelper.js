({
    
    
    getData : function(component, pageNumber, pageSize)  {
        var action=component.get("c.PreviewRecords");
        action.setParams({
            "startDate": component.get("v.startDate"),
            "endDate": component.get("v.endDate"),
            "objectName": component.get("v.objectName"),
            "pageNumber": pageNumber,
            "pageSize": pageSize
        })
        action.setCallback(this,function(response){ 
           // alert(JSON.stringify(response.getError()));
            if(response.getState() == "SUCCESS"){ 
                var resultData  = response.getReturnValue();
               // component.set('v.records',resultData.dataList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
                resultData.dataList.forEach(function(record){
                        record.linkName = '/'+record.Id;
                   
                    
                    });
                   component.set('v.records',resultData.dataList);
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action); 
    },
})