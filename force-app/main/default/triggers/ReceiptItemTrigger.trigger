trigger ReceiptItemTrigger on Receipt_Item__c (after insert,before delete) {
    
    if(Label.Enable_Receipt_Item_Trigger == 'TRUE'){
        
        Map<Id,Receipt__c> recToUpdate = new Map<Id,Receipt__c>();
        Map<Id,Account> accToUpdate = new Map<Id,Account>();
        Set<Id> riIds = new Set<Id>();
        Map<Id,Decimal> amtMap =  new Map<Id,Decimal>();
        Map<Id,Decimal> outAmtMap =  new Map<Id,Decimal>();
        if(Trigger.isInsert){
            for(Receipt_Item__c ri: trigger.new){
                if(ri.Receipt__c != null){
                    riIds.add(ri.Id);
                }
            }
        }
        if(Trigger.isDelete){
            for(Receipt_Item__c ri: trigger.old){
                if(ri.Receipt__c != null){
                    riIds.add(ri.Id);
                }
            }
        }
           
        List<Receipt_Item__c> riList = [select id,name,Receipt__c,Receipt__r.Type__c,Receipt__r.Customer__c,Receipt__r.Customer__r.Outstanding_Amount__c, Receipt__r.On_Account_Value__c,Amount__c from Receipt_Item__c where id in:riIds];
        Decimal onacc = 0;
        map<Id,decimal> outMap = new map<Id,decimal>();
        for(Receipt_Item__c rit: riList){
            if(rit.Receipt__r.Type__c == 'On Account'){
                if(!amtMap.containsKey(rit.Receipt__c)){
                    if(Trigger.isInsert){
                        amtMap.put(rit.Receipt__c, rit.Receipt__r.On_Account_Value__c - rit.Amount__c);
                    }
                    if(Trigger.isDelete){
                        amtMap.put(rit.Receipt__c, rit.Receipt__r.On_Account_Value__c + rit.Amount__c);
                    }
                    
                }
                else{
                    if(Trigger.isInsert){
                        amtMap.put(rit.Receipt__c, amtMap.get(rit.Receipt__c) - rit.Amount__c);
                    }
                    if(Trigger.isDelete){
                        amtMap.put(rit.Receipt__c, amtMap.get(rit.Receipt__c) + rit.Amount__c);
                    }
                    
                }    
                
                
                Receipt__c rec = new Receipt__c();
                rec.id = rit.Receipt__c;
                rec.On_Account_Value__c = amtMap.get(rit.Receipt__c);
                string userId = userInfo.getUserId();
                if(userId == label.FitDev || userId == label.AdminDev){
                rec.Skip_Record_Edit_Validation__c =true;
                }
                recToUpdate.put(rec.Id,rec);
                system.debug('rec-onacc:'+ rec.Id + '----' + amtMap.get(rit.Receipt__c));
                   /*below commented lines moved to 69-134  */
           
        }
        system.debug('recToUpdate:' + recToUpdate.values());
        
        try {
            update recToUpdate.values();
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(recToUpdate)  ); 
        } 
            
            
            
            
             /*    if(rit.Receipt__r.Customer__c != null){
                    if(!outAmtMap.containsKey(rit.Receipt__r.Customer__c)){
                        if(Trigger.isInsert){
                            if(rit.Receipt__r.Customer__r.Outstanding_Amount__c != null){
                            //    outAmtMap.put(rit.Receipt__r.Customer__c, rit.Receipt__r.Customer__r.Outstanding_Amount__c - rit.Amount__c);
                            }
                            else{
                            //    outAmtMap.put(rit.Receipt__r.Customer__c, rit.Receipt__r.On_Account_Value__c);
                            }
                        }
                        if(Trigger.isDelete){
                          //  outAmtMap.put(rit.Receipt__r.Customer__c, rit.Receipt__r.Customer__r.Outstanding_Amount__c + rit.Amount__c);
                        }
                        
                    }
                    else{
                        if(Trigger.isInsert){
                           // outAmtMap.put(rit.Receipt__r.Customer__c, outAmtMap.get(rit.Receipt__r.Customer__c) - rit.Amount__c);
                        }
                        if(Trigger.isDelete){
                          //  outAmtMap.put(rit.Receipt__r.Customer__c, outAmtMap.get(rit.Receipt__r.Customer__c) + rit.Amount__c);
                        }
                        
                    }    
                    
                    system.debug('outAmtMap'+outAmtMap);
                   // Account acc = new Account();
                   // acc.Id = rit.Receipt__r.Customer__c;
                  //  acc.Outstanding_Amount__c = outAmtMap.get(rit.Receipt__r.Customer__c);
                   // accToUpdate.put(acc.Id,acc); 
                }*/
                
            }
                  /* @author -Nanma  
               * update outstanding amount in customer */
                /*if(rit.Receipt__r.Customer__c != null){
                      decimal amount=0;
                     system.debug('initialOut'+rit.Receipt__r.Customer__r.Outstanding_Amount__c);
                     if(rit.Receipt__r.Customer__r.Outstanding_Amount__c != null){
                         amount = rit.Receipt__r.Customer__r.Outstanding_Amount__c;
                         
                         if(trigger.isInsert){ 
                            amount =amount - rit.Amount__c;
                             system.debug('amount'+amount);
                         }
                         if(trigger.isDelete){
                         amount =amount + rit.Amount__c;
                                system.debug('amount'+amount);
                         }
                    outMap.put(rit.Receipt__r.Customer__c,amount);
                            
                     }else if(rit.Receipt__r.Customer__r.Outstanding_Amount__c == null){
  
                           if(Trigger.isInsert)
                         amount -= rit.Amount__c;
                           if(Trigger.isDelete)
                           amount += rit.Amount__c;
                           outMap.put(rit.Receipt__r.Customer__c,amount);
                     }
                    }
             Account acc = new Account();
                    acc.Id = rit.Receipt__r.Customer__c;
              system.debug('finalOut'+outMap.get(rit.Receipt__r.Customer__c));
                    acc.Outstanding_Amount__c = outMap.get(rit.Receipt__r.Customer__c);
                    accToUpdate.put(acc.Id,acc); 
            */
            
 /*try {
            update accToUpdate.values();
        }
        catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(accToUpdate)  ); 
        }   
      */
        
    }
}