({
    returnAttList : function(component, event, helper) {
      
        var action=component.get("c.imagesMethod");
		 action.setParams({'visitid': component.get('v.visitId')});
        action.setCallback(this,function(a){

            component.set("v.atlist",a.getReturnValue());
           
            console.log('rtn value >>>>'+a.getReturnValue());

        });
        $A.enqueueAction(action);
    },
    doDelete : function(component, event, helper) {
       
         var eventsource = event.getSource();
        var imgeId= eventsource.get('v.name');
         var action=component.get("c.deleteImage");
		 action.setParams({
             'imageId': imgeId,
             'visitid': component.get('v.visitId')
                          });
        action.setCallback(this,function(a){
             component.set("v.atlist",a.getReturnValue());
          
        });
        $A.enqueueAction(action);
        
    },
     showSinglePhoto : function(component, event, helper) {
       var target = event.currentTarget;
        var dataIndex = target.dataset.index;
        var record = target.dataset.id ; 
        //alert(record);
         component.set('v.imgUrl',record);
        component.set('v.showPhoto', true); 
    },
    closePhoto : function(component, event, helper) {
        component.set('v.showPhoto',false);
    },
    
})