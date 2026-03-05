trigger Payment_Trigger on Payment__c (after Insert) {
    if(trigger.isInsert && trigger.isAfter  ){
      list<Id> paymentsId = new list<Id>();
        for(Payment__c paymt : trigger.New){
            if(paymt.Bouncing_Charge__c>0){
               paymentsId.add(paymt.Id); 
            }
            } 
        if(paymentsId.size() >0)
            SAPsend_TriggerHandler.sendToSap(paymentsId, 'Payment__c');
        }
    
           /*   map<Id,Decimal> custBounChar =new map<Id,Decimal>();
            if(paymt.Bouncing_Charge__c != null ){
                if(custBounChar.containsKey(paymt.Customer__c)){
                    decimal amount =0;
                    amount = custBounChar.get(paymt.Customer__c);
                    amount +=paymt.Bouncing_Charge__c;
                    custBounChar.put(paymt.Customer__c,amount);
                }else{
                    custBounChar.put(paymt.Customer__c, paymt.Bouncing_Charge__c);   
                }   
            }
            if(custBounChar.size() > 0){
                list<Account> accList=[select Id,Outstanding_Amount__c,Bouncing_Charges__c from Account where Id in:custBounChar.keyset()]; 
                if(accList.size() > 0){
                    for(Account acc : accList){
                        decimal amount =0;
                                    amount = custBounChar.get(acc.Id);
                        if(acc.Outstanding_Amount__c != null){
                
                            acc.Outstanding_Amount__c = acc.Outstanding_Amount__c+ amount;
                        }else{
                            acc.Outstanding_Amount__c = amount;
                        }
                  
                        if(acc.Bouncing_Charges__c != null){
                           acc.Bouncing_Charges__c = acc.Bouncing_Charges__c+amount;
                        }else{
                             acc.Bouncing_Charges__c = amount;
                          }      
                    }
                }
              //  try{
                    update accList;  
               // }
               // catch(Exception ex){
                //    system.debug(ex.getMessage());
               // }
                
            }                  
        }  
    }*/
      /* Payment data Send to SAP*/
   // if(trigger.isAfter && trigger.isInsert){

             //list<Id> lstPaymentId= new list<Id>();
        //for(Payment__c pay : trigger.New){
        //   lstPaymentId.add(pay.Id); 
        //}
     //  SAPsend_TriggerHandler.sendToSap(lstPaymentId,'Payment__c');
       

   // }  
}