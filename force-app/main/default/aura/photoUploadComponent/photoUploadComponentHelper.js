({  
    getUploadedFiles : function(component, event){
        var recordId = component.get('v.parentRecordId');
        console.log('recordId : '+recordId)
        var action = component.get("c.getFiles"); 
        action.setParams({  
            recordId : recordId
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    deleteUploadedFile : function(component, event) {  
        var target = event.currentTarget;
        var record = target.dataset;
        alert('record===== : '+record);
        var action = component.get("c.deleteFile");           
        action.setParams({
            "contentDocumentId": event.currentTarget.id            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                this.getUploadedFiles(component);
                component.set("v.showSpinner", false); 
                // show toast on file deleted successfully
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "File has been deleted successfully!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire();
            }  
        });  
        $A.enqueueAction(action);  
    },  
 })