({
	selectChange : function(component, event, helper) {
     
        if(!(component.get('v.showCmp'))){
             component.set('v.showCmp',true); 
            
        var action = component.get("c.getLogResult");
          action.setParams({
                'recordId' :component.get('v.recordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
          var  result = response.getReturnValue();
                if(result != null)
               component.set('v.logList',result);   
            }
        });
        $A.enqueueAction(action); 
        
        }  
        else{
           component.set('v.showCmp',false);  
        }
           

	}
})