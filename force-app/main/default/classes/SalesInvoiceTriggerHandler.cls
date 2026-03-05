public without sharing class SalesInvoiceTriggerHandler {
    
 /*   public static void insertSalesInvoiceName(List<Sales_Invoice__c> salesInvoiceList){
        
        for(Sales_Invoice__c salesInv : salesInvoiceList){
            system.debug('calling SalesInvoiceTriggerHandler====');
            if(salesInv.Route__c != null){
                system.debug('got route====');
                string salesInvName = '';
                Route__c routeRecord = [select Id,Name,Route_Id__c,(select id,Route__c,Invoice_number_prefix__c,Last_Invoice_Number__c,Start_Number__c,End_Number__c from Invoice_Number_Series__r),
                                        (select Id,Name from Sales_Invoices__r Order By CreatedDate Desc Limit 1)
                                        from Route__c where Id =: salesInv.Route__c Limit 1];
                system.debug('routeRecord=== '+routeRecord);
                if(routeRecord.Sales_Invoices__r.size()>0 && routeRecord.Sales_Invoices__r[0].Name != ''){
                    system.debug('routeRecord.Sales_Invoices__r=== '+routeRecord.Sales_Invoices__r);
                    system.debug('if=========');
                    // If there are other Sales Invoices for same route.
                    Integer salesInvoiceCount = Integer.valueOf(routeRecord.Sales_Invoices__r[0].Name.substringBetween('-','/'));
                    salesInvName = 'INV-'+string.valueOf(salesInvoiceCount+1)+'/'+ string.valueOf(system.today().Year());
                    salesInv.Name = salesInvName;
                    system.debug('salesInvName==='+salesInvName);
                }else{
                    system.debug('else=========');
                    if(routeRecord.Invoice_Number_Series__r.size()>0){
                        Invoice_Number_Series__c invoiceListNumbers = [select Id,Route__c,Name,Invoice_number_prefix__c,Start_Number__c,End_Number__c,Last_Invoice_Number__c,Invoice_Post_fix__c from Invoice_Number_Series__c
                                                                       where Route__c =: routeRecord.Id Order By CreatedDate Desc Limit 1];
                        if(invoiceListNumbers.Last_Invoice_Number__c != null){
                               // Add Sales Name with all field maping from Invoice Number Series.
                               if(invoiceListNumbers.Invoice_number_prefix__c != null && invoiceListNumbers.Invoice_Post_fix__c != null){
                                   salesInvName = invoiceListNumbers.Invoice_number_prefix__c + string.valueOf(invoiceListNumbers.Last_Invoice_Number__c+1) + invoiceListNumbers.Invoice_Post_fix__c; 
								   salesInv.Name =  salesInvName;                                 
                               }
                               else if(invoiceListNumbers.Invoice_number_prefix__c != null && invoiceListNumbers.Invoice_Post_fix__c == null){
                                   salesInvName = invoiceListNumbers.Invoice_number_prefix__c + string.valueOf(invoiceListNumbers.Last_Invoice_Number__c+1); 
                                   salesInv.Name = salesInvName;                                
                               }
                                else if(invoiceListNumbers.Invoice_number_prefix__c == null && invoiceListNumbers.Invoice_Post_fix__c != null){
                                    salesInvName = string.valueOf(invoiceListNumbers.Last_Invoice_Number__c+1) + invoiceListNumbers.Invoice_Post_fix__c; 
                                   salesInv.Name = salesInvName;
                               }
                               else{
                                   salesInvName = string.valueOf(invoiceListNumbers.Last_Invoice_Number__c+1);
                                   salesInv.Name =  salesInvName;                                  
                               }
                               
                           }else{
                               // Add sales name with pre defined format if Invoice Number Series,Invoice number prefix , or Invoice Post fix is blank.
                               system.debug('Invoice Number Series,Invoice number prefix , or Invoice Post fix is blank');
                               //salesInvName = 'INV-'+string.valueOf(invoiceListNumbers.Last_Invoice_Number__c+1)+'/'+ string.valueOf(system.today().Year());
                               salesInv.Name = String.valueof(invoiceListNumbers.Start_Number__c);
                           }
                    }else{
                        // Add Sales Name with 1 when there is no Invoice Number Series.
                        system.debug('No Invoice Number Series is created.');
                        salesInvName = 'INV-'+'1'+'/'+ string.valueOf(system.today().Year());   
                        salesInv.Name =  salesInvName;            
                    }
                    system.debug('salesInvName==='+salesInvName);
                }
                system.debug('salesInvName==='+salesInvName);
            }
            
            
          
        }
    }*/
    
     public static void insertSalesInvoiceName2(List<Sales_Invoice__c> salesInvoiceList){
         
         system.debug('salesInvoiceList:----'+ salesInvoiceList);
         system.debug('salesInvoiceList-size:----'+ salesInvoiceList.size());
             
         Set<Id> routeIds = new Set<Id>();
         for(Sales_Invoice__c salesInv : salesInvoiceList){
             if(salesInv.Route__c != null){
                 routeIds.add(salesInv.Route__c);
             }
         }
         
         Map<Id,Invoice_Number_Series__c> inMap = new Map<Id,Invoice_Number_Series__c>();
         
         List<Route__c> rtlist = [select Id,Name,Route_Id__c,(select id,Route__c,Invoice_number_prefix__c,Last_Invoice_Number__c,Start_Number__c,End_Number__c,Invoice_Post_fix__c from Invoice_Number_Series__r where Active__c = true order by createddate desc limit 1),
                                        (select Id,Name from Sales_Invoices__r Order By CreatedDate Desc Limit 1)
                                        from Route__c where Id in :routeIds];
         
         for(Route__c rt: rtlist){
             if(rt.Invoice_Number_Series__r.size() > 0){
                 inMap.put(rt.Id,rt.Invoice_Number_Series__r);
             }
         }
        
        for(Sales_Invoice__c salesInv : salesInvoiceList){
            system.debug('calling SalesInvoiceTriggerHandler====');
            
            if(inMap.size() > 0 && salesInv.Route__c != null){
                Invoice_Number_series__c ins = inMap.get(salesInv.Route__c);
                
                   if(ins.Last_Invoice_Number__c != null && ins.Last_Invoice_Number__c != 0){
                    salesInv.Name = String.valueof(ins.Last_Invoice_Number__c + 1);
                    ins.Last_Invoice_Number__c = ins.Last_Invoice_Number__c + 1;
                     inMap.put(salesInv.Route__c,ins);//added
                }
                else{
                    salesInv.Name = String.valueof(ins.Start_Number__c);
                    ins.Last_Invoice_Number__c = ins.Start_Number__c;
                }
                
                if(ins.Invoice_number_prefix__c != null && ins.Invoice_Post_fix__c != null){
                    salesInv.Invoice_Full_Name__c = ins.Invoice_number_prefix__c + string.valueOf(ins.Last_Invoice_Number__c) + ins.Invoice_Post_fix__c; 
                }
                else if(ins.Invoice_number_prefix__c != null && ins.Invoice_Post_fix__c == null){
                    salesInv.Invoice_Full_Name__c = ins.Invoice_number_prefix__c + string.valueOf(ins.Last_Invoice_Number__c); 
                }
                else if(ins.Invoice_number_prefix__c == null && ins.Invoice_Post_fix__c != null){
                    salesInv.Invoice_Full_Name__c = string.valueOf(ins.Last_Invoice_Number__c) + ins.Invoice_Post_fix__c; 
                }
                else{
                    salesInv.Invoice_Full_Name__c = string.valueOf(ins.Last_Invoice_Number__c);
                }

             
                
                
            }
            
              
            try {
                update inMap.values();       
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(inMap)  ); 
            }   
        }
    }
    
   /*   public static void insertSalesInvoiceSeriesUpdate(Sales_Invoice__c salesInvoice){
         
             if(salesInvoice.Route_Id__c != null || test.isRunningTest()){
  
         Map<string,Invoice_Number_Series__c> inMap = new Map<string,Invoice_Number_Series__c>();
         
         List<Route__c> rtlist = [select Id,Name,Route_Id__c,(select id,Route__c,Invoice_number_prefix__c,Last_Invoice_Number__c,Start_Number__c,End_Number__c from Invoice_Number_Series__r where Active__c = true order by createddate desc limit 1),
                                        (select Id,Name from Sales_Invoices__r Order By CreatedDate Desc Limit 1)
                                        from Route__c where Route_Id__c =:salesInvoice.Route_Id__c];
         
         for(Route__c rt: rtlist){
             if(rt.Invoice_Number_Series__r.size() > 0){
                 inMap.put(rt.Route_Id__c,rt.Invoice_Number_Series__r);
             }
         }

            system.debug('calling SalesInvoiceTriggerHandler====');
            
            if(inMap.size() > 0 && salesInvoice.Route_Id__c != null){
                Invoice_Number_series__c ins = inMap.get(salesInvoice.Route_Id__c);
                
                if(ins.Last_Invoice_Number__c != null && ins.Last_Invoice_Number__c != 0){
                  //  salesInvoice.Name = String.valueof(ins.Last_Invoice_Number__c + 1);
                   ins.Last_Invoice_Number__c = ins.Last_Invoice_Number__c + 1;
                }
                else{
                 //   salesInvoice.Name = String.valueof(ins.Start_Number__c);
                    ins.Last_Invoice_Number__c = ins.Start_Number__c;
                }
            }
            
            update inMap.values();
        }
    }
    
    public static void updateLastInvoiceNumber(List<Sales_Invoice__c> salesInvList){
        
        List<Invoice_Number_Series__c> invNumbersUpdate= new List<Invoice_Number_Series__c>();
        for(Sales_Invoice__c salesInv: salesInvList){
            Integer salesInvoiceCount = Integer.valueOf(salesInv.Name.substringBetween('-','/'));
            system.debug('salesInv num ===='+salesInvoiceCount);
           // Integer lastSalesInvoiceNumber = Integer.valueOf(salesInv.Name.substringBetween('-','/'));
            //Integer lastSalesInvoiceNumber = Integer.valueOf(salesInv.Name);
            List<Invoice_Number_Series__c> invNumberSeriesList = [select Id,Route__c,Last_Invoice_Number__c from Invoice_Number_Series__c 
                                                                  where Route__c =: salesInv.Route__c And Active__c =: true];
            if(invNumberSeriesList.size()>0){
                invNumberSeriesList[0].Last_Invoice_Number__c = salesInvoiceCount;
                invNumbersUpdate.add(invNumberSeriesList[0]);
            }
        }
        
        if(invNumbersUpdate.size()>0){
            update invNumbersUpdate;
        }
        system.debug('invNumbersUpdate=== '+invNumbersUpdate);
    }*/
   /* @future(callout =true)
    public static void sendReceipt(List<Id> salesInvoiceId){
        
        list<Receipt__c> Receipts =[select Id,Name,CompanyId__c,Receipt_Id__c,Customer_Id__c,Branch_Id__c,Receipt_Date__c,Tax_Date__c,Amount__c,Mode_of_payment__c,Cheque_Date__c,Cheque_Trasaction_Number__c,Bank_Name__c,(select Id,Name,Receipt_Item_Id__c,Invoice_Id__c,Amount__c from Receipt_Items__r) from Receipt__c where Sales_Invoice__c in :salesInvoiceId];
          if(Receipts.size() > 0)  
        SAPSendData.sendData(Receipts);
    }
    */

}