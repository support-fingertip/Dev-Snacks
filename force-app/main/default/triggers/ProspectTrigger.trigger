trigger ProspectTrigger on Prospect__c (before update) {
    for(Prospect__c pro : Trigger.new){
       if(!convertProspect.frombutton && pro.status__c != Trigger.oldmap.get(pro.id).status__c && pro.status__c =='Closed won'){
        pro.adderror('Please click on convert button to convert prospect');
    }
    }
    
}