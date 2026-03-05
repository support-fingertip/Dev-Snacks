({
    doInit : function(component, event, helper){  
        component.set('v.parentRecordId',component.get('v.recordId'));
       helper.getUploadedFiles(component, event);
       console.log('recordId === '+component.get('v.recordId'));
        var recordId = component.get('v.recordId');
        
    },      
    
    previewFile : function(component, event, helper){  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [event.currentTarget.id]
        });  
    },
    
    uploadFinished : function(component, event, helper){
        //alert(component.get('v.recordId'));
        helper.getUploadedFiles(component, event);
        var toastEvent = $A.get("e.force:showToast");
        // show toast on file uploaded successfully 
        toastEvent.setParams({
            "message": "Files have been uploaded successfully!",
            "type": "success",
            "duration" : 2000
        });
        toastEvent.fire();
    }, 
    
    deleteSelectedFile : function(component, event, helper){
        if( confirm("Confirm deleting this file?")){
            component.set("v.showSpinner", true); 
            helper.deleteUploadedFile(component, event);                
        }
    }
 })