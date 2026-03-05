public without sharing class CashInHandHandler {
    
    public static Map<Id,Route__c> rtMap = new Map<Id,Route__c>();
    public static  Map<Id,Branch__c> brMap = new Map<Id,Branch__c>();
    public static  Map<Id,Trip__c> trMap = new Map<Id,Trip__c>();
    
    public CashInHandHandler(){
        List<Route__c> rtlist = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c,Cash_In_Hand__c,Last_Cleared_Date__c from Route__c];
        for(Route__c r:rtlist){
            rtMap.put(r.Id,r);
        }
        
        List<Branch__c> brlist = [select Id,Cash_In_Hand__c from Branch__c];  
        for(Branch__c r:brlist){
            brMap.put(r.Id,r);
        }
        List<Trip__c> tripList = [SELECT id,Route__c,Cash_In_Hand__c,Last_Cleared_Date__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null ) order by createddate ]; 
        for(Trip__c r:tripList){
            trMap.put(r.Route__c,r);
        }
    }
    
    
    public static void updateCIH(Receipt__c rec){
        
        Route__c rt = rtMap.containsKey(rec.Route__c) ? rtMap.get(rec.Route__c) : new Route__c();
        Branch__c br = brMap.containsKey(rec.Branch__c) ? brMap.get(rec.Branch__c) : new Branch__c();
        Trip__c trp = trMap.containsKey(rec.Route__c) ? trMap.get(rec.Route__c) : new Trip__c();
        
        if(rt != null){
            if(rt.Cash_In_Hand__c == null){
                rt.Cash_In_Hand__c =  rec.Amount__c; 
            }
            else{
                rt.Cash_In_Hand__c = rt.Cash_In_Hand__c + rec.Amount__c;
            }
        }
        else if(br != null){
            if(br.Cash_In_Hand__c == null){
                br.Cash_In_Hand__c =  rec.Amount__c; 
            }
            else{
                br.Cash_In_Hand__c = br.Cash_In_Hand__c + rec.Amount__c;
            }
        }
        if(trp != null){
            if(trp.Cash_In_Hand__c == null){
                trp.Cash_In_Hand__c =  rec.Amount__c;
            }
            else{
                trp.Cash_In_Hand__c = trp.Cash_In_Hand__c + rec.Amount__c;
            }
        }
    }
    
}