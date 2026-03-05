trigger StockRequest_Trigger on Stock_Request__c (After update) {
    
 if(Label.Enable_Stock_Request_Trigger == 'TRUE'){    
     /*To send data to SAP*/
    if(trigger.isUpdate || Trigger.isAfter){
        list<Id> listStockRequestId =new List<Id>();
           list<Id> listStockRequestCCId =new List<Id>();
        
        for(Stock_Request__c stockReq : trigger.new){    
            if(stockReq.Status__c =='Approved' && stockReq.Status__c != trigger.oldMap.get(stockReq.Id).Status__c)
                listStockRequestId.add(stockReq.Id);   
            
              if(stockReq.Sent_to_SAP__c == true && stockReq.Status__c != trigger.oldMap.get(stockReq.Id).Status__c && stockReq.Status__c =='Cancelled' )
                listStockRequestCCId.add(stockReq.Id);    
        }
        if(listStockRequestId.size() > 0){
            SAPsend_TriggerHandler.sendToSap(listStockRequestId,'Stock_Request__c');
            
        }
          if(listStockRequestCCId.size() > 0)
            try{
               SAPsend_TriggerHandler.sendCancellationToSap(listStockRequestCCId,'Stock_Request__c'); 
            }
            catch(Exception ex){
            system.debug('Error'+ ex.getMessage());
       } 
    }
    
 }
}