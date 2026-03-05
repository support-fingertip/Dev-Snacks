public class InvoiceNumberSeriesTriggerHandler {

    public static void addLastInvoiceNumber(List<Invoice_Number_Series__c> invNumberSeriesRecords){
        //String useRrouteId = [select Id,Route_Id__c from User where Id =: UserInfo.getUserId() Limit 1][0].Route_Id__c;
        //Route__c route = [select Id,Route_Id__c,(select Id,Last_Invoice_Number__c from Invoice_Number_Series__r) from Route__c where Route_Id__c =: useRrouteId Limit 1];
        List<Invoice_Number_Series__c> activeInvoiceNumberSeriesRecords = [select Id,Name,Route__c,Start_Number__c,End_Number__c,Last_Invoice_Number__c 
                                                                           from Invoice_Number_Series__c 
                                                                           where Active__c =: true];
        
        Map<Id,Invoice_Number_Series__c> insMap = new Map<Id,Invoice_Number_Series__c>();
        for(Invoice_Number_Series__c ins: activeInvoiceNumberSeriesRecords ){
            insMap.put(ins.Route__c,ins);
        }
        system.debug('activeInvoiceNumberSeriesRecords : '+activeInvoiceNumberSeriesRecords);
        
        for(Invoice_Number_Series__c invNumberSeries : invNumberSeriesRecords){
            
            if(insMap.containsKey(invNumberSeries.Route__c)){
                invNumberSeries.Active__c.addError('There will be only one active Invoice Number Series for each Route.');
            }
            
            Route__c route = [select Id,Route_Id__c,(select Id,Last_Invoice_Number__c from Invoice_Number_Series__r) from Route__c 
                              where Id =: invNumberSeries.Route__c Limit 1];
            //if(invNumberSeries.Route__c == route.Id){
                if(route.Invoice_Number_Series__r.size()>0){
                    Invoice_Number_Series__c invoiceNumberSeriesRecord = [select Id,Name,Start_Number__c,End_Number__c,Last_Invoice_Number__c 
                                                                          from Invoice_Number_Series__c
                                                                          where Route__c =: route.Id Order By CreatedDate Desc Limit 1];
                    
                    System.debug('invoiceNumberSeriesRecords : '+invoiceNumberSeriesRecord);
                    invNumberSeries.Last_Invoice_Number__c = invoiceNumberSeriesRecord.Last_Invoice_Number__c + 1;
                }else{
                    invNumberSeries.Last_Invoice_Number__c = 0;
                }
            //}
        }
    }
}