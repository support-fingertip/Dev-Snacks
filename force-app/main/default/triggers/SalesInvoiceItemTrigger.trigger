trigger SalesInvoiceItemTrigger on Sales_Invoice_Item__c (After insert,Before insert,After update) {
    if(Label.Enable_Invoice_Item_Trigger == 'TRUE'){
                /*if(trigger.isInsert && trigger.isAfter){
        SalesInvoiceItemTriggerHandler.deductStockForSalesInvoiceItem(trigger.new);
        }*/
        
       // if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        if(trigger.isAfter && trigger.isInsert){
            if(StopRecursion.executeSalesInvoiceItemTrigger){
                
                list<Sales_Invoice_Item__c> fifoList =new List<Sales_Invoice_Item__c>();
                list<Sales_Invoice_Item__c> nofifoList =new List<Sales_Invoice_Item__c>();
                
                Map<Id,User> userMap = new Map<Id,User>();
                List<User> usrlist = [SELECT Id,Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Label = 'New Invoice CMP')];
                for(User u:usrlist){
                    userMap.put(u.Id,u);
                }
                
                for(Sales_Invoice_Item__c item :trigger.new){
                    //if(item.Fifo__c){
                    if(userMap.containsKey(UserInfo.getUserId())){
                        fifoList.add(item);
                    }
                    else{
                        nofifoList.add(item);
                    }
                }
                if(fifoList.size() > 0){
                    SalesInvoiceItemTriggerHandler.deductStockforInvoice(fifoList);
                }
                else{
                    SalesInvoiceItemTriggerHandler.deductStockForSalesInvoiceItem(nofifoList);
                }
            }
        }
        
        if(trigger.isInsert && trigger.isAfter){
            list<Id> listInvoiceId =new List<Id>();
            list<Id> listEInvoice =new List<Id>();
            Set<Id> routeIds = new Set<Id>();
            for(Sales_Invoice_Item__c salesInv :trigger.new){
                if(salesInv.Sales_Invoice__c != null && salesInv.GST_applicable_formula__c ==false){  
                    if(!listInvoiceId.contains(salesInv.Sales_Invoice__c))
                        listInvoiceId.add(salesInv.Sales_Invoice__c);  
                }
                if(salesInv.Sales_Invoice__c != null && salesInv.GST_applicable_formula__c){
                    if(!listEInvoice.contains(salesInv.Sales_Invoice__c))
                        listEInvoice.add(salesInv.Sales_Invoice__c);  
                }
            }
            
            if(listInvoiceId.size() > 0){ 
                SAPsend_TriggerHandler.sendToSap(listInvoiceId,'Sales_Invoice__c');  
            }
            if(listEInvoice.size() > 0)
                Einvoice_Send_TriggerHandler.sendToPortal(listEInvoice, 'Generate');
            /*below commented lines moved to 100-154  */
        }
        
        if(Label.SalesInvoiceItemSubDisable == 'True'){  
            if(trigger.isInsert && trigger.isBefore){
                
                Map<String,Decimal> discMap = new Map<String,Decimal>();
                for(Account acc:[Select Id,Name,Cash_Discount__c from Account where Cash_Discount__c != null]){
                    discMap.put(acc.Id,acc.Cash_Discount__c);
                }
                
                for(Sales_Invoice_Item__c salesInv :trigger.new){
                    if(salesInv.Quantity__c != 0 && salesInv.Quantity__c != null && salesInv.Unit_Price__c != 0 && salesInv.Unit_Price__c != null){
                        Decimal totalWithGST = salesInv.Quantity__c * salesInv.Unit_Price__c;
                        Decimal cashDis = 0;
                        Decimal totalcashdis = 0;
                        if(salesInv.Cash_Discount__c != null && salesInv.Cash_Discount__c != 0){
                            cashDis = salesInv.Cash_Discount__c; 
                        }
                        else if(salesInv.Customer_Id__c != null){
                            if(discMap.containsKey(salesInv.Customer_Id__c)){
                                cashDis = discMap.get(salesInv.Customer_Id__c); 
                            }
                        }
                        salesInv.Cash_Discount__c = cashDis.setScale(2, RoundingMode.HALF_UP); 
                        //totalcashdis = totalWithGST - ((totalWithGST * cashDis) / 100);
                        totalcashdis = totalWithGST ;
                        
                        //   if(salesInv.Customer_Discount__c == 0 || salesInv.Customer_Discount__c == null){
                        salesInv.Customer_Discount__c = totalcashdis.setScale(2, RoundingMode.HALF_UP);
                        //  }
                        if(salesInv.Sales_Tax__c != 0 && salesInv.Sales_Tax__c != null){
                            
                            Decimal ttl = totalcashdis + (totalcashdis * salesInv.Sales_Tax__c/100 );
                            salesInv.Total__c =ttl.setScale(2, RoundingMode.HALF_UP);  
                            salesInv.Total_Before_Tax__c = totalWithGST.setScale(2, RoundingMode.HALF_UP);  
                            salesInv.Total_after_discount__c = salesInv.Total__c;                            
                        }
                    }
                    /*below commented lines moved to 81-90  */
                }
            }
        }     
    }
                /*   if(salesInv.Total_Before_Tax__c ==0 && salesInv.Quantity__c != 0 && salesInv.Quantity__c != null && salesInv.Unit_Price__c != 0 && salesInv.Unit_Price__c != null ){
            salesInv.Total_Before_Tax__c = salesInv.Quantity__c * salesInv.Unit_Price__c;
            if(salesInv.Sales_Tax__c != 0 && salesInv.Sales_Tax__c != null){
            salesInv.Total_after_discount__c = (salesInv.Total_Before_Tax__c + (salesInv.Total_Before_Tax__c *salesInv.Sales_Tax__c)/100).setScale(2, RoundingMode.HALF_UP);  
            salesInv.Total__c =(salesInv.Total_Before_Tax__c + ((salesInv.Total_Before_Tax__c *salesInv.Sales_Tax__c)/100)).setScale(2, RoundingMode.HALF_UP);  
            }else{
            salesInv.Total_after_discount__c = salesInv.Total_Before_Tax__c.setScale(2, RoundingMode.HALF_UP);  
            salesInv.Total__c = salesInv.Total_Before_Tax__c.setScale(2, RoundingMode.HALF_UP);    
            }
            }*/
                /*if(trigger.isUpdate && trigger.isAfter){
            SalesInvoiceItemTriggerHandler.updateStockForSalesInvoiceItem(trigger.new,trigger.oldMap);
            }*/
                /* @author -Nanma  
            * update outstanding amount in customer */
                
                /*   if(listInvoiceId.size() > 0){
            list<Sales_Invoice__c> slList =[select Id,Customer__c,Customer__r.Outstanding_Amount__c from Sales_Invoice__c where Id in:listInvoiceId];
            map<string,Decimal> accountOutMap = new map<string,Decimal>(); 
            map<Id,Id> invCustMap = new map<Id,Id>(); 
            list<Account> accToUpdate = new list<Account>();
            for(Sales_Invoice__c sInv :slList){
            invCustMap.put(sInv.Id,sInv.Customer__c);
            if(!accountOutMap.containsKey(sInv.Customer__c))
            {
            if(sInv.Customer__r.Outstanding_Amount__c == null){
            accountOutMap.put(sInv.Customer__c,0);
            }else{
            accountOutMap.put(sInv.Customer__c,sInv.Customer__r.Outstanding_Amount__c);
            }
            
            }
            }    
            
            for(Sales_Invoice_Item__c salesInv :trigger.new){
            string custId =invCustMap.get(salesInv.Sales_Invoice__c);
            if(accountOutMap.containsKey(custId))
            {
            if(salesInv.Total__c != null ){
            decimal amount =0;
            amount =accountOutMap.get(custId);
            amount +=salesInv.Total__c ;
            accountOutMap.put(custId,amount);
            }  
            }
            
            }
            system.debug('accountOutMap'+accountOutMap); 
            
            for(Id cId :accountOutMap.keyset()){
            Account acc = new Account();
            acc.Id = cId;
            acc.Outstanding_Amount__c  = accountOutMap.get(cId);
            
            accToUpdate.add(acc);   
            }
            
            if(accToUpdate.size() > 0){
            
            try {
            update accToUpdate; 
            }
            catch (System.Exception ae) { 
            ExceptionHandler.addLog(ae,String.valueOf(accToUpdate)  ); 
            }  
            
            }
            }*/
}