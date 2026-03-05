({
	doInit : function(component, event, helper) {
          const profile = component.get('v.CurrentUser')['Profile'].Name;
        if(profile == 'Recovery Head'){
            component.set('v.selProfileFilter','Recovery Presales');
        }else{
           component.set('v.selProfileFilter','Pre Sales'); 
        }
        
		helper.getUsers(component);
      
	},
     /*selectChange:function(component, event, helper) {
        //var options = component.find("option");
       // alert(event.currentTarget.dataset.id)
        //options = options? []: options.length? options: [options];
        var selUserId = event.currentTarget.dataset.id;
        var users = component.get('v.users');
       // alert(JSON.stringify(users))
        var user;
        for(var i=0;i<=users.length;i++){
            if(users[i].Id === selUserId){
                
                user = users[i];
                //alert(JSON.stringify(user))
                break;
            }
        }
       
        component.set("v.selUser",user);
       helper.submit(component,event,helper);
          
    },*/
       selectChange2:function(component, event, helper) {
           var userId = event.currentTarget.dataset.id;
           console.log('userId=== '+userId);
           var toggleVal = event.currentTarget.dataset.value;
           console.log('toggleVal=== '+toggleVal);   
           var action = component.get('c.allowMultipleVisits');
           action.setParams({
               userId : userId,
               toggleVal : toggleVal
           });
           action.setCallback(this, function(response){
               var state = response.getState();
               if (state === "SUCCESS") {
                   var result = response.getReturnValue();
                   if(result == true){
                       helper.showToast('Success','User is allowed to create multiple visits.','Allowed Multiple Visits');
                   }else{
                       helper.showToast('Error','User is not allowed to create multiple visits.','Not Allowed Multiple Visits');
                   }
                   console.log('result val== '+ result);
               }else if(state === "ERROR") {
                   var errors = response.getError();
                   if (errors) {
                       if (errors[0] && errors[0].message) {
                           alert('Error message: ' + '"' + errors[0].message + '".');
                       }
                   }
               }
           });
           $A.enqueueAction(action);
        /*var users = component.get('v.users');
        var user;
        for(var i=0;i<=users.length;i++){
            if(users[i].Id === selUserId){
                user = users[i];
                break;
            }
        }
        component.set("v.selUser",user);
       helper.submit2(component,event,helper);*/
          
    },
    /*onChange : function(component, event, helper){
         var pageSize = component.get("v.pageSize");
       var action = component.get('c.getAllUsers');
          action.setParams({
            "zone": component.get('v.selZoneFilter'),
            "profile": component.get('v.selProfileFilter')
        });
        action.setCallback(this,function(response){
            var state=response.getState();            
            if(state==='SUCCESS'){
                var userDetails = response.getReturnValue();
                component.set("v.users",userDetails);
                 component.set("v.totalSize", component.get("v.users").length);
                component.set("v.start",0);
                component.set("v.end",pageSize-1);
                
                 var paginationList = [];
                for(var i=0; i< pageSize; i++)
                {
                    paginationList.push(response.getReturnValue()[i]);
                }
                component.set("v.paginationList", paginationList);
                
                //alert(userDetails)
            }else if(state==='ERROR'){
                var toastsuccessEvent = $A.get("e.force:showToast");
                toastsuccessEvent.setParams({
                    "title": "Something went wrong.",
                    "message": "Please contact System Administrator.",
                    "type" : "error"
                });
                toastsuccessEvent.fire(); 
            }
        });
        $A.enqueueAction(action);    
    },*/
    first : function(component, event, helper)
    {
        
        var oppList = component.get("v.users");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        for(var i=0; i< pageSize; i++)
        {
            paginationList.push(oppList[i]);
        }
        component.set("v.paginationList", paginationList);
        component.set("v.start",0);
        component.set("v.end",1);
    },
    
    last : function(component, event, helper)
    {
        
        var oppList = component.get("v.users");
        var pageSize = component.get("v.pageSize");
        var totalSize = component.get("v.totalSize");
        var paginationList = [];
        
        for(var i=totalSize-pageSize+1; i< totalSize; i++)
        {
            paginationList.push(oppList[i]);
        }
        component.set("v.paginationList", paginationList);
       component.set("v.start",1);
        component.set("v.end",totalSize);
    },
    
    next : function(component, event, helper)
    {
        
        var oppList = component.get("v.users");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        
        for(var i=end+1; i<end+pageSize+1; i++)
        {
            if(oppList.length > end)
            {
                paginationList.push(oppList[i]);
                counter ++ ;
            }
        }
        
        start = start + counter;
        end = end + counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.paginationList", paginationList);
        
    },
    
    previous : function(component, event, helper)
    {
        
        var oppList = component.get("v.users");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        
        for(var i= start-pageSize; i < start ; i++)
        {
            if(i > -1)
            {
                paginationList.push(oppList[i]);
                counter ++;
            }
            else {
                start++;
            }
        }
        
        start = start - counter;
        end = end - counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.paginationList", paginationList);
    },
})