public class UpdateInvoiceFullName {
    
    public static void updateName(List<Sales_Invoice__c> salesInvoiceList){
        
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
                
                if(ins != null){
                    if(ins.Invoice_number_prefix__c != null && ins.Invoice_Post_fix__c != null){
                        salesInv.Invoice_Full_Name__c = ins.Invoice_number_prefix__c + string.valueOf(salesInv.Name) + ins.Invoice_Post_fix__c; 
                    }
                    else if(ins.Invoice_number_prefix__c != null && ins.Invoice_Post_fix__c == null){
                        salesInv.Invoice_Full_Name__c = ins.Invoice_number_prefix__c + string.valueOf(salesInv.Name); 
                    }
                    else if(ins.Invoice_number_prefix__c == null && ins.Invoice_Post_fix__c != null){
                        salesInv.Invoice_Full_Name__c = string.valueOf(salesInv.Name) + ins.Invoice_Post_fix__c; 
                    }
                    else{
                        salesInv.Invoice_Full_Name__c = string.valueOf(salesInv.Name);
                    }
                }
                
                
            }
            
            
        }
        update salesInvoiceList;
        
    }
}