public with sharing class UnsealedItemTrigger_Handler {

    public static void updateStockHistory(list<Unsealed_Item__c> unsealedItems){
          map<string,decimal> stockQtyMap = new map<string,decimal>();
        for(Unsealed_Item__c u : unsealedItems){
             decimal quantity =0;
            if(u.Stock__c != null && u.Quantity__c !=null){
                if(stockQtyMap.containsKey(u.Stock__c)){
                    quantity = stockQtyMap.get(u.Stock__c);
                }
                quantity += u.Quantity__c;
                  stockQtyMap.put(u.Stock__c,quantity);
            } 
        }   
       if(!stockQtyMap.isEmpty()){
            List<Stock__c> stocksList = [select Id,Route__c,Available_Quantity__c,Free_Quantity__c from Stock__c where Id in :stockQtyMap.keySet() ];
            
            for(Stock__c s : stocksList ){
                s.Available_Quantity__c =  s.Available_Quantity__c != null ?  (s.Available_Quantity__c - stockQtyMap.get(s.Id) ) : - stockQtyMap.get(s.Id);
                s.Free_Quantity__c =  s.Free_Quantity__c != null ?  (s.Free_Quantity__c + stockQtyMap.get(s.Id) ) : stockQtyMap.get(s.Id);
            }
            try{
                update stocksList;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(stocksList)  ); 
            } 
        }       
        
        
        
        
        
        
        
         
         List<AggregateResult> avaggList = [select Product__c prod,Unsealed__r.Route__c rt, SUM(Quantity__c) freeQty from Unsealed_Item__c where createddate=today  group by Product__c,Unsealed__r.Route__c];
        Map<String,Decimal> availMap = new Map<String,Decimal>();
            Set<String> extids = new Set<String>();
        for(AggregateResult agg:avaggList){
            
            string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
            extids.add(ext);
            availMap.put(ext,(Decimal)agg.get('freeQty'));
        }
        
         List<Stock_History__c> hisList = [select Id,Name,Route__c,Product__c,Available_Quantity__c,Initial_Quantity__c,
                                          Damaged_Quantity__c,Free_Quantity__c,Sold_Quantity__c,
                                          Replaced_Quantity__c,Unsealed_Quantity__c,CreatedDate,Ext_ID__c from Stock_History__c where  Ext_ID__c IN:extIds];
    	 List<Stock_History__c> hisListToUpdate = new List<Stock_History__c>();
        if(hisList.size() > 0){
            for(Stock_History__c his : hisList){
                his.Unsealed_Quantity__c = availMap.containsKey(his.Ext_ID__c) ? availMap.get(his.Ext_ID__c) : his.Unsealed_Quantity__c;
               
                hisListToUpdate.add(his);
            }
        }
        
        try {
            upsert hisListToUpdate;
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(hisListToUpdate) );
        }  
    }
}