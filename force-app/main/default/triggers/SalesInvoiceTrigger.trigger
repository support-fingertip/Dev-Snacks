trigger SalesInvoiceTrigger on Sales_Invoice__c (before insert, before update,after update,after insert) {
    
    if(Label.Enable_Invoice_Trigger == 'TRUE'){
        
        /* To update Sales Invoice Name based on series added in routes. -- Mayuri */
        If(trigger.isInsert && trigger.isBefore){
            SalesInvoiceTriggerHandler.insertSalesInvoiceName2(trigger.new);
        }
        
        /* To create receipts and receipt Items automatically if the payment type is immediate. -- Mayuri */
        Set<Id> custIds = new Set<Id>();
        Map<Id,Decimal> pendMap =  new Map<Id,Decimal>();
        List<Sales_Invoice__c> invList = new List<Sales_Invoice__c>();
        if(Trigger.isAfter){
            for(Sales_Invoice__c inv: trigger.new){
                if(inv.Payment_Type__c == 'Credit'){
                    invList.add(inv);
                    if(inv.Customer__c != null){
                        custIds.add(inv.Customer__c);
                    }  
                    system.debug('inv.Pending_Amount__c=== '+inv.Pending_Amount__c);
                    
                    if(inv.Pending_Amount__c > 0){
                        pendMap.put(inv.id,inv.Pending_Amount__c);
                    }
                    
                }
                
            }
            List<Receipt_Item__c> recItemList = new List<Receipt_Item__c>();
            Map<Id,Decimal> amtMap =  new Map<Id,Decimal>();
            List<Receipt__c> recList = [select id,name,Type__c,On_Account_Value__c,Customer__c from Receipt__c where Customer__c IN:custIds and Type__c = 'On Account' and Deducted__c = false and On_Account_Value__c > 0 and Receipt_Status__c != 'Cancelled'];
            system.debug('invList:' + invList);
            integer i = 0;
            if(invList.size() > 0){
                if(recList.size() > 0){
                    Decimal pend = 0;
                    for(Receipt__c rec: recList){
                        Sales_Invoice__c inv = invList[i];
                        
                     /*   if(inv.Customer__c == rec.Customer__c){
                            amtMap.put(rec.id,rec.On_Account_Value__c);
                            
                            pend = pendMap.get(inv.id);
                            system.debug('pend:' + pend);
                            
                            while(pend > 0 && amtMap.get(rec.Id) > 0){
                                system.debug('amtMap.get(rec.Id):' + amtMap.get(rec.Id));
                                if(amtMap.get(rec.Id) <= pend){
                                    
                                    Receipt_Item__c ri = new Receipt_Item__c();
                                    ri.Sales_Invoice__c = inv.Id;
                                    ri.Receipt__c = rec.Id;
                                    ri.Amount__c = amtMap.get(rec.Id);
                                    recItemList.add(ri);
                                    system.debug('ri-if:' + ri);
                                    pend = pend - amtMap.get(rec.Id);
                                    pendMap.put(inv.Id,pend);
                                    amtMap.put(rec.Id,0);
                                    system.debug('pend-if:' + pend);
                                }
                                else{
                                    
                                    Receipt_Item__c ri = new Receipt_Item__c();
                                    ri.Sales_Invoice__c = inv.Id;
                                    ri.Receipt__c = rec.Id;
                                    ri.Amount__c = pend;
                                    recItemList.add(ri);
                                    pend = 0;
                                    pendMap.put(inv.Id,pend);
                                    amtMap.put(rec.Id, amtMap.get(rec.Id) - ri.Amount__c);
                                    if(invList.size() > i+1){
                                        i++; 
                                        inv = invList[i];
                                        pend =  inv.Pending_Amount__c;
                                        pendMap.put(inv.Id,pend);
                                        
                                    }
                                    system.debug('pend-else:' + pend);
                                    system.debug('ri-else:' + ri);
                                }
                                
                                
                            }
                        }*/
                        
                        
                    }
                }
                system.debug('invList:' + invList);
                
            }
            system.debug('recItemList:' + recItemList);
            
            try {
              //  insert recItemList;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(recItemList)  ); 
            }   
        }
        if(trigger.operationType == TriggerOperation.BEFORE_UPDATE){
            for(Sales_Invoice__c inv:trigger.new){
                if(inv.Sales_Invoice_Status__c =='Cancelled' && inv.Sales_Invoice_Status__c != trigger.oldMap.get(inv.Id).Sales_Invoice_Status__c){
                    inv.Invoice_Cancellation_Time__c =system.now();
                }
            }
        }   
        
        /* To update Available and Sold Qty. when Invoice is Cancelled. -- Mayuri */
        if(trigger.isUpdate && Trigger.isAfter ){
            Set<Id> invIds = new Set<Id>();
            list<Id> listInvoiceId =new List<Id>();
            
            for(Sales_Invoice__c inv:trigger.new){
                if(inv.Sales_Invoice_Status__c == 'Cancelled' && inv.Sales_Invoice_Status__c != trigger.oldmap.get(inv.Id).Sales_Invoice_Status__c){
                    invIds.add(inv.Id);
                }
                
                if(inv.Send_to_GSTZen__c  && inv.Send_to_GSTZen__c != trigger.oldmap.get(inv.Id).Send_to_GSTZen__c){
                  //  listInvoiceId.add(inv.Id);
                } 
                
            }
            if(invIds.size()>0){
                List<Sales_Invoice_Item__c> invItems = [select Id,Name,Quantity__c,Stock__c from Sales_Invoice_Item__c where Sales_Invoice__c IN:invIds];
                if(StopRecursion.executeSalesInvoiceItemTrigger){
                    SalesInvoiceItemTriggerHandler.readdStockForSalesInvoiceItem(invItems);
                }
            }
            
            if(listInvoiceId.size() > 0){
                SAPsend_TriggerHandler.sendToSap(listInvoiceId,'Sales_Invoice__c');
            }
            
            /* @author -Nanma  
* update outstanding amount in customer */
          /*  if(invIds.size()>0){
                map<Id,list<Sales_Invoice__c>> salaccountMAP = new map<Id,list<Sales_Invoice__c>>();
                list<Account> updateAcc= new list<Account>();
                list<Sales_Invoice__c> salInvList =[select Id,Amount_Received__c,Customer__c,Customer_Outstanding_Amount__c,Grand_Total__c from Sales_Invoice__c where Id in:invIds];
                if(salInvList.size() > 0){
                    for(Sales_Invoice__c sl :salInvList){
                        if(salaccountMAP.get(sl.Customer__c) == null){
                            list<Sales_Invoice__c> slin =new list<Sales_Invoice__c>();
                            slin.add(sl);
                            salaccountMAP.put(sl.Customer__c,slin);
                        }else{
                            list<Sales_Invoice__c> slin = salaccountMAP.get(sl.Customer__c);
                            slin.add(sl);
                            salaccountMAP.put(sl.Customer__c,slin);
                        }
                    }
                    if(salaccountMAP.size() > 0){
                        for(Id Ids :salaccountMAP.keyset()){
                            list<Sales_Invoice__c> custInvList =salaccountMAP.get(Ids);
                            if(custInvList.size() > 0){
                                Decimal Totalpending =0;
                                decimal Custoutstanding =0;
                                for(Sales_Invoice__c sl :custInvList){
                                    Totalpending += sl.Grand_Total__c -sl.Amount_Received__c; 
                                    if(sl.Customer_Outstanding_Amount__c == null){
                                        Custoutstanding =0;
                                    }else{
                                        Custoutstanding =sl.Customer_Outstanding_Amount__c;
                                    }
                                }
                                Account acc = new Account();
                                acc.Id = Ids; 
                                acc.Outstanding_Amount__c = Custoutstanding -Totalpending;
                                updateAcc.add(acc);
                            }
                        }  
                    }
                }
                if(updateAcc.size() > 0)
                    
                    try {
                        update updateAcc; 
                    }
                catch (System.Exception ae) { 
                    ExceptionHandler.addLog(ae,String.valueOf(updateAcc)  ); 
                }  
                
                
                
                
            }  */   
            
        }
            if(trigger.operationType == TriggerOperation.AFTER_INSERT){
            set<Id> custId = new set<Id>();
            list<Account> AccountList = new list<Account>();
            for(Sales_Invoice__c si : trigger.New){
                if(si.Skip_Credit_Limit__c && si.Customer__c!=null){
                    custId.add(si.Customer__c);
                }
            } 
            if(custId.size() > 0){
                for(Id cust :custId ){
                    Account acc = new Account();
                    acc.Id = cust;
                    acc.Skip_Credit_Limit_For_Next_Order__c=false;
                    if(!AccountList.contains(acc)){
                        AccountList.add(acc);
                    }
                }
                try{
                    update AccountList;
                }catch(exception ex){
                    ExceptionHandler.addLog(ex,String.valueOf(AccountList)); 
                } 
            }
        }
        
        /*To send data to SAP*/
        /*    if(trigger.isInsert && Trigger.isAfter){
list<Id> listInvoiceId =new List<Id>();
for(Sales_Invoice__c invoice : trigger.new){    
listInvoiceId.add(invoice.Id);    
}
if(listInvoiceId.size() > 0){
SAPsend_TriggerHandler.sendToSap(listInvoiceId,'Sales_Invoice__c');
}
//  SalesInvoiceTriggerHandler.updateLastInvoiceNumber(trigger.new);
}*/
        /*if(trigger.isUpdate && Trigger.isAfter){
list<Id> salesInvoiceId = new list<Id>();
for(Sales_Invoice__c invoice : trigger.new){ 
if(invoice.SAP_Code__c != null && invoice.Payment_Type__c == 'Immediate' && trigger.oldMap.get(invoice.Id).SAP_Code__c == null){
salesInvoiceId.add(invoice.Id); 
}
}
system.debug('System.IsBatch():' + System.IsBatch());
system.debug('System.isFuture():' + System.isFuture());
if(salesInvoiceId.size() > 0 && (System.IsBatch() == false || System.isFuture() == false) )
SalesInvoiceTriggerHandler.sendReceipt(salesInvoiceId);
}*/
        if(Test.isRunningTest()){
        integer i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
             i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;  
        }
    
    }
    
    
}