global class StockBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='select Id,Name,Product_Code__c,Company_Id__c from Product__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Product__c> scope){
        Set<String> pIds = new Set<String>();
        
        List<Route__c> rtList = new List<Route__c>();
        //Dev Users to Dev Products, Eva Users to EVA Products
       // if(Test.isRunningTest()){
            rtList = [select Id,Name,CompanyId__c,OwnerId from Route__c where Id='a0LN0000008h2ADMAY'];
        //}
        //else{
        //    rtList = [select Id,Name,CompanyId__c,OwnerId from Route__c];
       // }
         
        
        for(Product__c pro : scope){
            for(Route__c rt:rtList){
                if(pro.Company_Id__c == rt.CompanyId__c){
                    string ext = String.valueOf(pro.Id) + String.valueOf(rt.Id) + system.today();
                    pIds.add(ext);
                }
                
            }
        }
       
        List<AggregateResult> aggList = [select Product__c prod,Route__c rt, SUM(Available_Quantity__c) availQty from Stock__c where Stock_Type__c = 'New' and Product__c IN:scope group by Product__c,Route__c];
        
        Map<String,Decimal> availMap = new Map<String,Decimal>();
        
        for(AggregateResult agg:aggList){
            
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt'));
            availMap.put(ext,(Decimal)agg.get('availQty'));
           
        }
      
        Map<String,Stock_History__c> histMap = new Map<String,Stock_History__c>();
        
        List<Stock_History__c> hisList = [select Id,Name,Route__c,Product__c,Available_Quantity__c,CreatedDate,Ext_ID__c from Stock_History__c where CreatedDate = yesterday and Ext_ID__c IN:pIds];
        List<Stock_History__c> hisListToUpdate = new List<Stock_History__c>();
        
        if(hisList.size() != 0){
            for(Stock_History__c sh: hisList){
                histMap.put(sh.Ext_ID__c,sh);
            }
        }
        else{
            for(Product__c pro : scope){
                for(Route__c rt:rtList){
                    if(pro.Company_Id__c == rt.CompanyId__c){
                        Stock_History__c his = new Stock_History__c();
                        his.Route__c = rt.Id;
                        his.Product__c = pro.Id;
                        if(availMap.containsKey(String.valueOf(his.Product__c) + String.valueOf(his.Route__c)))
                        {
                            his.Opening_Quantity__c = availMap.get(String.valueOf(his.Product__c) + String.valueOf(his.Route__c));
                        }
                        else{
                            his.Opening_Quantity__c = 0;
                        }
                        his.Available_Quantity__c = his.Opening_Quantity__c;
                        his.Ext_ID__c = String.valueOf(his.Product__c) + String.valueOf(his.Route__c)  + system.today();
                        his.Date__c = system.today();
                        his.OwnerId = rt.OwnerId;
                        hisListToUpdate.add(his);
                        
                    }
                }
            }      
            
        }
        if(histMap.size() != 0){
            for(Product__c pro : scope){
                for(Route__c rt:rtList){
                    if(pro.Company_Id__c == rt.CompanyId__c){
                        string ext = String.valueOf(pro.Id) + String.valueOf(rt.Id)  + system.today();
                        if(histMap.containsKey(ext)){
                            Stock_History__c his = new Stock_History__c();
                            his.Route__c = rt.Id;
                            his.Product__c = pro.Id;
                            his.Opening_Quantity__c = histMap.get(ext).Available_Quantity__c;
                            his.Available_Quantity__c = his.Opening_Quantity__c;
                            his.Ext_ID__c = String.valueOf(his.Product__c) + String.valueOf(his.Route__c) + system.today();
                            his.Date__c = system.today();
                            his.OwnerId = rt.OwnerId;
                            hisListToUpdate.add(his);
                        }
                        else{
                            Stock_History__c his = new Stock_History__c();
                            his.Route__c = rt.Id;
                            his.Product__c = pro.Id;
                            if(availMap.containsKey(String.valueOf(his.Product__c) + String.valueOf(his.Route__c)))
                            {
                                his.Opening_Quantity__c = availMap.get(String.valueOf(his.Product__c) + String.valueOf(his.Route__c));
                            }
                            else{
                                his.Opening_Quantity__c = 0;
                            }
                            his.Available_Quantity__c = his.Opening_Quantity__c;
                            his.Ext_ID__c = String.valueOf(his.Product__c) + String.valueOf(his.Route__c) + system.today();
                            his.Date__c = system.today();
                            his.OwnerId = rt.OwnerId;
                            hisListToUpdate.add(his);
                        }
                    }
                }
            }
            
            
        }
        system.debug('hisListToUpdate:' + hisListToUpdate);
        //insert hisListToUpdate;
        database.insert(hisListToUpdate,false);
        
        /*  Integer batchSize = 2000;
        Integer nrOfRecordsProcessed = 0;
        
        Integer rowsReturned = batchSize;
        Map<String,Decimal> availMap = new Map<String,Decimal>();
        while (rowsReturned == batchSize) {
            rowsReturned = 0;
            for(AggregateResult agg : [select Product__c prod,Route__c rt, SUM(Available_Quantity__c) availQty from Stock__c where Stock_Type__c = 'New'  group by Product__c,Route__c LIMIT :batchSize OFFSET :nrOfRecordsProcessed]) {
                string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt'));
                availMap.put(ext,(Decimal)agg.get('availQty'));
                rowsReturned++;
            }
            nrOfRecordsProcessed = nrOfRecordsProcessed + rowsReturned;
        }*/
         
       /* Integer recordCount = [select count() from Stock__c  where Stock_Type__c = 'New'];
        Integer sizeBlock = recordCount/2000 + (math.mod(recordCount,2000)!=0?1:0) ;
        Set<Id> setAppIds = new Set<Id>(); 
        Map<String,Decimal> availMap = new Map<String,Decimal>();
        //Iterate aggregate result with blocks of 2000 to avoid exception
        for(Integer i=0;i<sizeBlock;i++){            
            for(AggregateResult agg : [select Product__c prod,Route__c rt, SUM(Available_Quantity__c) availQty from Stock__c
                                      where Stock_Type__c = 'New' and id not in :setAppIds 
                                      group by Product__c,Route__c limit 2000]) {
                                          
            	string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt'));
            	availMap.put(ext,(Decimal)agg.get('availQty'));
            	setAppIds.add(Id.valueOf(String.valueOf(agg.get('id'))));
            }
        }*/
        
        

    }
    
    public void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext SC){
        database.executeBatch(new StockBatch(),1);
        
    } 
    
    
}