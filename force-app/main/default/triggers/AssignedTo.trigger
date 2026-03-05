trigger AssignedTo on Visit__c (before insert) {
    
    if(Label.Enable_Visit_Trigger == 'TRUE'){
        if(Trigger.isBefore && Trigger.isInsert){
            for(Visit__c vt : Trigger.New){
                if(vt.Assigned_To__c != null)
                {
                    vt.OwnerId = vt.Assigned_To__c;
                }
                else{
                    
                }
            }
        }
    }
    
    
}