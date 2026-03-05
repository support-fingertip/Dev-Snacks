trigger CashTransferTrigger on Cash_Transfer__c (before insert, before update) {
    
    if(Label.Enable_Cash_Transfer_Trigger == 'TRUE'){
        Map<Id,Cash_Transfer__c> ctMap = new Map<Id,Cash_Transfer__c>();
        Set<Id> rtIds = new Set<Id>();
         Set<Id> brIds = new Set<Id>();
        Set<Id> trpIds = new Set<Id>();
        
        for(Cash_Transfer__c tran: trigger.new){
            /* if(clockinClockout.size() != 0){
tran.Daily_Log__c = clockinClockout[0].Id;
}
if(tripList.size() != 0){
system.debug('trip:' + tripList[0].Id);
tran.Trip__c = tripList[0].Id;
}*/
            
            if(tran.Route__c != null){
                rtIds.add(tran.Route__c);  
            }
             if(tran.Branch__c != null){
                brIds.add(tran.Branch__c);  
            }
            
            if(tran.From__c == 'Head Office' && tran.To__c == 'Branch'){
                tran.Status__c = 'Credited';
            }
            else if(tran.From__c == 'Branch' && tran.To__c == 'Route'){
                
                //rtIds.add(tran.Route__c);   
                //trpIds.add(tran.Trip__c);   
                // tran.Status__c = 'Debited';
            }
            else if(tran.From__c == 'Branch' && tran.To__c == 'Head Office'){
                tran.Status__c = 'Debited';
            }
        }
        
        //  List<Route__c> rtList = [select id,Name,Cash_In_Hand__c,Last_Cleared_Date__c from Route__c where id in: rtIds];
        //List<Trip__c> trips = [select id,Name,Cash_In_Hand__c,Last_Cleared_Date__c from Trip__c where id in: trpIds];
        
        List<Route__c> rtList = [select id,Name,Cash_In_Hand__c,Last_Cleared_Date__c from Route__c where id in: rtIds];
        List<DailyLog__c> logs = [SELECT id,Trip__c,Route__c from  DailyLog__c  WHERE    Clock_In__c = TODAY AND Route__c IN:rtIds order by CreatedDate desc ]; 
        List<Trip__c> trips = [SELECT id,Route__c,Cash_In_Hand__c,Last_Cleared_Date__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null )  AND Route__c IN:rtIds  order by CreatedDate desc ]; 
        List<Branch__c> brList = [select id,Name,Cash_In_Hand__c from Branch__c where id in: brIds];
        
        Map<Id,DailyLog__c> dlMap = new Map<Id,DailyLog__c>();
        Map<Id,Trip__c> trpMap = new Map<Id,Trip__c>();
        Map<Id,Route__c> rtMap = new Map<Id,Route__c>();
        Map<Id,Branch__c> brMap = new Map<Id,Branch__c>();
        
        for(Route__c rt: rtList){
            rtMap.put(rt.Id,rt);
        }
        for(Branch__c br: brList){
            brMap.put(br.Id,br);
        }
        for(DailyLog__c dl : logs){
            if(!dlMap.containsKey(dl.Route__c)){
                dlMap.put(dl.Route__c,dl);
            }
            
        }
        for(Trip__c trp: trips){
            if(!trpMap.containsKey(trp.Route__c)){
                trpMap.put(trp.Route__c,trp);
            }
            
        }
        
        for(Cash_Transfer__c tran: trigger.new){
            
            if(dlMap.containsKey(tran.Route__c)){
                tran.Daily_Log__c = dlMap.get(tran.Route__c).Id;
            }
            if(trpMap.containsKey(tran.Route__c)){
                Trip__c trp =trpMap.get(tran.Route__c);
                tran.Trip__c = trp.Id;
                
                if(trp.Cash_In_Hand__c == 0 || trp.Cash_In_Hand__c == null){
                    trp.Cash_In_Hand__c = tran.Amount__c;
                }
                else{
                    trp.Cash_In_Hand__c = trp.Cash_In_Hand__c + tran.Amount__c;
                }
            }
            if(rtMap.containsKey(tran.Route__c)){
                Route__c rt = rtMap.get(tran.Route__c);
                
                if(rt.Cash_In_Hand__c == 0 || rt.Cash_In_Hand__c == null){
                    rt.Cash_In_Hand__c = tran.Amount__c;
                }
                else{
                    rt.Cash_In_Hand__c = rt.Cash_In_Hand__c + tran.Amount__c;
                }
            }
            
           if(brMap.containsKey(tran.Branch__c)){
                Branch__c br = brMap.get(tran.Branch__c);
                
               if(tran.From__c == 'Head Office' && tran.To__c == 'Branch'){
                   if(br.Cash_In_Hand__c == 0 || br.Cash_In_Hand__c == null){
                       br.Cash_In_Hand__c = tran.Amount__c;
                   }
                   else{
                       br.Cash_In_Hand__c = br.Cash_In_Hand__c + tran.Amount__c;
                   }
               }
               else if(tran.From__c == 'Branch' && tran.To__c == 'Route'){
                   if(br.Cash_In_Hand__c <= 0 || br.Cash_In_Hand__c == null){
                        tran.addError('Not enough Balance to transfer.');
                   }
                   else{
                       br.Cash_In_Hand__c = br.Cash_In_Hand__c - tran.Amount__c;
                   }
               }
               else if(tran.From__c == 'Branch' && tran.To__c == 'Head Office'){
                   if(br.Cash_In_Hand__c == 0 || br.Cash_In_Hand__c == null){
                      // br.Cash_In_Hand__c = tran.Amount__c;
                      tran.addError('Not enough Balance to transfer.');
                   }
                   else{
                       br.Cash_In_Hand__c = br.Cash_In_Hand__c - tran.Amount__c;
                   }
               }
               
                
            }
        }
        system.debug('brMap:' + brMap); 
        system.debug('rtMap:' + rtMap);
        system.debug('trpMap:' + trpMap);
        
        
        try{
            update rtMap.values();
            update trpMap.values();
            update brMap.values();
        }
        catch(DmlException ex){
            system.debug('ex:' + ex.getMessage());
            ExceptionHandler.addLog(ex,String.valueOf(rtMap) + '----' + String.valueOf(brMap) + '----' + String.valueOf(trpMap)   ); 
        }
    }
}