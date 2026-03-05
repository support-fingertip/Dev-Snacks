public class ClearBalController {
    
    @AuraEnabled
    public static Decimal checkBalance(Id recId){
        String sobjectType = recId.getSObjectType().getDescribe().getName();
        
        if(sobjectType == 'Route__c'){
            Route__c rt = [select id,Name,Branch_Name__c,Cash_In_Hand__c,Last_Cleared_Date__c from Route__c where id=:recId];
            return rt.Cash_In_Hand__c;
        }
        
        if(sobjectType == 'Trip__c'){
            Trip__c trp = [select id,Name,Route__c,Route__r.Branch_Name__c,Cash_In_Hand__c,Last_Cleared_Date__c from Trip__c where id=:recId];
            return trp.Cash_In_Hand__c;
        }
        return null;
    }
    @AuraEnabled
    public static void clearBalance(Id recId){
        String sobjectType = recId.getSObjectType().getDescribe().getName();
        
        if(sobjectType == 'Route__c'){
            Route__c rt = [select id,Name,Branch_Name__c,Branch_Name__r.Cash_In_Hand__c,Cash_In_Hand__c,Last_Cleared_Date__c from Route__c where id=:recId];
            
            Cash_Transfer__c ct = new Cash_Transfer__c();
            ct.From__c = 'Route';
            ct.To__c = 'Branch';
            ct.Route__c = recId;
            ct.Branch__c = rt.Branch_Name__c;
            ct.Amount__c = rt.Cash_In_Hand__c;
            
            
            try {
                insert ct;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(ct)  );  
            }     
            
            rt.Cash_In_Hand__c = 0;
            rt.Last_Cleared_Date__c = system.today();
            
            try {
                update rt;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(rt)  );  
            }     
            
            Branch__c br = new Branch__c();
            br.Id = rt.Branch_Name__c;
            if(rt.Branch_Name__r.Cash_In_Hand__c == null || rt.Branch_Name__r.Cash_In_Hand__c == 0){
                br.Cash_In_Hand__c = ct.Amount__c;
            }
            else{
                br.Cash_In_Hand__c = rt.Branch_Name__r.Cash_In_Hand__c + ct.Amount__c;
            }
            
            try {
                update br;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(br)  );  
            }     
            
            Trip__c trp = [SELECT id,Route__c,Cash_In_Hand__c,Last_Cleared_Date__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null )  AND Route__c =:recId limit 1]; 
            trp.Cash_In_Hand__c = 0;
            trp.Last_Cleared_Date__c = system.today();
            
            try {
                update trp;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(trp)  );   
            }     
            
        }
        
        if(sobjectType == 'Trip__c'){
            Trip__c trp = [select id,Name,Route__c,Route__r.Branch_Name__c,Route__r.Branch_Name__r.Cash_In_Hand__c,Cash_In_Hand__c,Last_Cleared_Date__c from Trip__c where id=:recId];
            
            Cash_Transfer__c ct = new Cash_Transfer__c();
            ct.From__c = 'Route';
            ct.To__c = 'Branch';
            ct.Route__c = trp.Route__c;
            ct.Branch__c = trp.Route__r.Branch_Name__c;
            ct.Amount__c = trp.Cash_In_Hand__c;
            
            
            try {
                insert ct;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(ct)  );  
            }     
            
            trp.Cash_In_Hand__c = 0;
            trp.Last_Cleared_Date__c = system.today();
            
            try {
                update trp;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(trp)  );  
            }     
            
            Branch__c br = new Branch__c();
            br.Id = trp.Route__r.Branch_Name__c;
            if(trp.Route__r.Branch_Name__r.Cash_In_Hand__c == null || trp.Route__r.Branch_Name__r.Cash_In_Hand__c == 0){
                br.Cash_In_Hand__c = ct.Amount__c;
            }
            else{
                br.Cash_In_Hand__c = trp.Route__r.Branch_Name__r.Cash_In_Hand__c + ct.Amount__c;
            }
            
            try {
                update br;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(br)  );   
            }     
            
            Route__c rt = new Route__c();
            rt.Id = trp.Route__c;
            rt.Cash_In_Hand__c = 0;
            rt.Last_Cleared_Date__c = system.today();
            
            try {
                update rt;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(rt)  );  
            }  
            
        }
        
    }
}