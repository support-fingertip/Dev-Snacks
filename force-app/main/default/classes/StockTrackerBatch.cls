global class StockTrackerBatch  implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='select Id,Name,Product_Code__c,Company_Id__c from Product__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Product__c> scope){
        Set<String> pIds = new Set<String>();
        
        List<Route__c> rtList = new List<Route__c>();
        
        rtList = [select Id,Name,CompanyId__c,OwnerId from Route__c ];
        
        
        for(Product__c pro : scope){
            for(Route__c rt:rtList){
                if(pro.Company_Id__c == rt.CompanyId__c){
                    string ext = String.valueOf(pro.Id) + String.valueOf(rt.Id) + system.today();
                    pIds.add(ext);
                }
                
            }
        }
        
        List<AggregateResult> avaggList = [select Product__c prod,Route__c rt, SUM(Available_Quantity__c) availQty from Stock__c where  Stock_Type__c='New' and Product__c IN:scope  group by Product__c,Route__c];
        Map<String,Decimal> availMap = new Map<String,Decimal>();
        for(AggregateResult agg:avaggList){
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
            availMap.put(ext,(Decimal)agg.get('availQty'));
        }
        
        List<AggregateResult> inaggList = [select Product__c prod,Route__c rt, SUM(Intial_Stock__c) initQty from Stock__c where CreatedDate = TODAY AND Stock_Type__c='New' and Product__c IN:scope  group by Product__c,Route__c];
        Map<String,Decimal> initMap = new Map<String,Decimal>();
        for(AggregateResult agg:inaggList){
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
            initMap.put(ext,(Decimal)agg.get('initQty'));
        }
        
        List<AggregateResult> damaggList = [select Product__c prod,Route__c rt, SUM(Available_Quantity__c) availQty from Stock__c where  Stock_Type__c='Damaged' and Product__c IN:scope  AND CreatedDate = TODAY  group by Product__c,Route__c];
        Map<String,Decimal> damMap = new Map<String,Decimal>();
        for(AggregateResult agg:damaggList){
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
            damMap.put(ext,(Decimal)agg.get('availQty'));
        }
        
        List<AggregateResult> avaggListSold = [select Product__c prod,Sales_Invoice__r.Route__c rt, SUM(Quantity__c) soldQty from Sales_Invoice_Item__c where createddate=today AND Sales_Invoice__r.Sales_Invoice_Status__c !='Cancelled' and Product__c IN:scope group by Product__c,Sales_Invoice__r.Route__c];
        Map<String,Decimal> soldMap = new Map<String,Decimal>();
        for(AggregateResult agg:avaggListSold){
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
            soldMap.put(ext,(Decimal)agg.get('soldQty'));
        }
        
        List<AggregateResult> avaggListFree = [select Product__c prod,Unsealed__r.Route__c rt, SUM(Quantity__c) freeQty from Unsealed_Item__c where createddate=today  and Product__c IN:scope group by Product__c,Unsealed__r.Route__c];
        Map<String,Decimal> freeMap = new Map<String,Decimal>();
        for(AggregateResult agg:avaggListFree){
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
            freeMap.put(ext,(Decimal)agg.get('freeQty'));
        }

         List<AggregateResult> avaggListRep = [select New_Created_Stock__r.Product__c prod,Item_Replacement__r.Route__c rt, SUM(Quantity__c) repQty from Replaced_Item__c where createddate=today  and New_Created_Stock__r.Product__c IN:scope group by New_Created_Stock__r.Product__c,Item_Replacement__r.Route__c];
        Map<String,Decimal> repMap = new Map<String,Decimal>();
        for(AggregateResult agg:avaggListRep){
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
            repMap.put(ext,(Decimal)agg.get('repQty'));
        }
        
        List<Stock_History__c> hisList = [select Id,Name,Route__c,Product__c,Available_Quantity__c,Initial_Quantity__c,
                                          Damaged_Quantity__c,Free_Quantity__c,Sold_Quantity__c,
                                          Replaced_Quantity__c,Unsealed_Quantity__c,CreatedDate,Ext_ID__c from Stock_History__c where  Ext_ID__c IN:pIds];
        List<Stock_History__c> hisListToUpdate = new List<Stock_History__c>();
        if(hisList.size() > 0){
            for(Stock_History__c his : hisList){
                his.Available_Quantity__c = availMap.containsKey(his.Ext_ID__c) ? availMap.get(his.Ext_ID__c) : his.Available_Quantity__c;
                his.Initial_Quantity__c = initMap.containsKey(his.Ext_ID__c) ? initMap.get(his.Ext_ID__c) : his.Initial_Quantity__c;
                his.Damaged_Quantity__c = damMap.containsKey(his.Ext_ID__c) ? damMap.get(his.Ext_ID__c) : his.Damaged_Quantity__c;
                his.Unsealed_Quantity__c = freeMap.containsKey(his.Ext_ID__c) ? freeMap.get(his.Ext_ID__c) : his.Unsealed_Quantity__c;
                his.Sold_Quantity__c = soldMap.containsKey(his.Ext_ID__c) ? soldMap.get(his.Ext_ID__c) : his.Sold_Quantity__c;
                his.Replaced_Quantity__c =  repMap.containsKey(his.Ext_ID__c) ? repMap.get(his.Ext_ID__c) : his.Replaced_Quantity__c;
                hisListToUpdate.add(his);
            }
        }
        
        try {
            update hisListToUpdate;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(hisListToUpdate) );
        }  
    }

    
    public void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext SC){
        database.executeBatch(new StockTrackerBatch(),1);
        
    } 
    
}