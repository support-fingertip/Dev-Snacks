public with sharing class ReplacedItemTriggerHandler {

    
    public static void updateStockHistory(list<Replaced_Item__c> replacedItems){
       list<Id> listReplaceId =new List<Id>();
        Map<String,Decimal> availMap = new Map<String,Decimal>();
        Map<String,Decimal> damagedMap = new Map<String,Decimal>();
        Set<String> extids = new Set<String>();
        for(Replaced_Item__c ir : replacedItems){
            // if(ir.R_Type__c == 'Replacement') {
            listReplaceId.add(ir.Item_Replacement__c);  
            //  }
            string ext = String.valueOf(ir.Product__c) + String.valueOf(ir.RouteLKP__c) + system.today();
            extids.add(ext);   
            damagedMap.put(ext,ir.Quantity__c);
        } 
        if(listReplaceId.size() > 0){
            List<AggregateResult> avaggList = [select New_Stock__r.Product__c prod,Item_Replacement__r.Route__c rt, SUM(Quantity__c) replQty from Replaced_Item__c where createddate=today AND Item_Replacement__c IN :listReplaceId group by New_Stock__r.Product__c,Item_Replacement__r.Route__c]; 
            
            for(AggregateResult agg:avaggList){
                string ext = String.valueOf(agg.get('prod')) + String.valueOf(agg.get('rt')) + system.today();
                extids.add(ext);
                availMap.put(ext,(Decimal)agg.get('replQty'));
            }  
        }
        system.debug(extids);
        List<Stock_History__c> hisList = [select Id,Name,Route__c,Product__c,Available_Quantity__c,Initial_Quantity__c,
                                          Damaged_Quantity__c,Free_Quantity__c,Sold_Quantity__c,
                                          Replaced_Quantity__c,Unsealed_Quantity__c,CreatedDate,Ext_ID__c from Stock_History__c where  Ext_ID__c IN:extIds];
        List<Stock_History__c> hisListToUpdate = new List<Stock_History__c>();
        if(hisList.size() > 0){
            for(Stock_History__c his : hisList){
                if(availMap.containsKey(his.Ext_ID__c) ){
                    his.Replaced_Quantity__c = availMap.get(his.Ext_ID__c);
                    
                }
                if(his.Damaged_Quantity__c != null && damagedMap.containsKey(his.Ext_ID__c)){
                    his.Damaged_Quantity__c = (damagedMap.get(his.Ext_ID__c) +  his.Damaged_Quantity__c ); 
                }else if(damagedMap.containsKey(his.Ext_ID__c)){
                    his.Damaged_Quantity__c = damagedMap.get(his.Ext_ID__c);
                }
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