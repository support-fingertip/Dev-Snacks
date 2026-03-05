public class CollectionSheetController {
   
    public Decimal ClosingBalance{get;set;}
    public Decimal TotalSalesAmount{get;set;}
    public Decimal totalCashCollection{get;set;}
    public Decimal totalChequeCollection{get;set;}
    public Decimal totalExpense{get;set;}
    public list<wrapper>salesInvoices{get;set;}
    
      public CollectionSheetController(){
        Id recordId = ApexPages.currentPage().getParameters().get('Id'); 
        String fromDate = ApexPages.currentPage().getParameters().get('from'); 
        String toDate = ApexPages.currentPage().getParameters().get('to'); 
        
        Date fromdate1 = date.valueof(fromDate);
        Date todate1 = date.valueof(toDate);
        
        String sobjectType = recordId.getSObjectType().getDescribe().getName(); 
        system.debug('sobjectType:' + sobjectType);
        
        system.debug('id:' + recordId);
        system.debug('fromDate:' + fromdate1);
        system.debug('toDate:' + todate1);
        
        Date fromdate2 = date.valueof(fromDate).addDays(-1);
        Date todate2 = date.valueof(toDate).addDays(-1);
        
        ClosingBalance=0;
        totalCashCollection = 0;
        totalChequeCollection = 0;
        TotalSalesAmount = 0;
        totalExpense = 0;
        salesInvoices = new list<wrapper>();

        if(sobjectType == 'Route__c'){
             List<Cashbook__c> cbList = [select Id,Name,Date__c,Branch__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Cashbook__c where Route__c = :recordId and (Date__c=:fromDate1  or Date__c=:toDate1) ];
            if(cbList.size() > 0){
                for(Cashbook__c cb: cbList){
                    if(cb.Date__c == toDate1){
                        ClosingBalance = cb.Closing_Balance__c;
                    }
                }
            }
            List<Sales_Invoice__c> salesInvoiceList = [select id,Name,CreatedDate,Customer__r.Name,Route__c, Customer__r.State__c,Invoice_Number__c,Grand_Total_Discounted__c,Invoice_Total__c,Invoice_Date__c,Customer__r.Phone,
                                                (Select Id,Cheque_Trasaction_Number__c,Mode_of_payment__c,Amount__c From Collections__r where Receipt_Status__c != 'Cancelled' AND ((New_Approval_Flow__c =true AND Approval_status__c='Approved') OR (Approval_status__c=null AND New_Approval_Flow__c=false))) from Sales_Invoice__c 
                                                where Route__c =: recordId AND (Invoice_Date__c >=:fromDate1  and Invoice_Date__c <=:toDate1) AND Invoice_Total__c !=0 order by Invoice_Date__c];
            system.debug('salesInvoiceList=== '+salesInvoiceList);
            for(Sales_Invoice__c salesInvoice : salesInvoiceList){
               /* wrapper wrp = new wrapper();
                wrp.PartyName = salesInvoice.Customer__r.Name;
                wrp.Place = salesInvoice.Customer__r.State__c;
                wrp.InvoiceNo = salesInvoice.Name;
                wrp.SaleAmount = salesInvoice.Grand_Total_Discounted__c;
                TotalSalesAmount =TotalSalesAmount + salesInvoice.Grand_Total_Discounted__c;
                wrp.invDate = salesInvoice.Invoice_Date__c;*/
                
                if(salesInvoice.Collections__r.size()>0){
                    
                    for(Receipt__c rec:salesInvoice.Collections__r){
                        wrapper wrp = new wrapper();
                        wrp.PartyName = salesInvoice.Customer__r.Name;
                        wrp.Place = salesInvoice.Customer__r.State__c;
                        wrp.InvoiceNo = salesInvoice.Name;
                        wrp.SaleAmount = salesInvoice.Invoice_Total__c;
                        TotalSalesAmount =TotalSalesAmount + salesInvoice.Invoice_Total__c;
                        wrp.invDate = salesInvoice.Invoice_Date__c;
                        
                        if(rec.Mode_of_payment__c == 'Cheque'){
                            wrp.CheckNo = rec.Cheque_Trasaction_Number__c;
                            wrp.ChequeAmount = rec.Amount__c;
                            totalChequeCollection = totalChequeCollection + rec.Amount__c;
                        }
                        else{
                            wrp.CashAmount = rec.Amount__c;
                            totalCashCollection = totalCashCollection + rec.Amount__c;
                        }
                        wrp.Phone = salesInvoice.Customer__r.Phone;
                        
                        salesInvoices.add(wrp);
                    }
                    
                   
                    
                   /* if(salesInvoice.Collections__r[0].Mode_of_payment__c == 'Cheque'){
                        wrp.ChequeAmount = salesInvoice.Grand_Total_Discounted__c;
                        totalChequeCollection = totalChequeCollection + salesInvoice.Grand_Total_Discounted__c;
                    }else{
                       // wrp.ChequeAmount = 0.00;
                    }*/
                    
                  /*  if(salesInvoice.Collections__r[0].Mode_of_payment__c == 'Cash'){
                        wrp.CashAmount = salesInvoice.Grand_Total_Discounted__c;
                        totalCashCollection = totalCashCollection + salesInvoice.Grand_Total_Discounted__c;
                    }else{
                      //  wrp.CashAmount = 0.00;
                    }*/
                }else{
                    
                    wrapper wrp = new wrapper();
                    wrp.PartyName = salesInvoice.Customer__r.Name;
                    wrp.Place = salesInvoice.Customer__r.State__c;
                    wrp.InvoiceNo = salesInvoice.Name;
                    wrp.SaleAmount = salesInvoice.Invoice_Total__c;
                    TotalSalesAmount =TotalSalesAmount + salesInvoice.Invoice_Total__c;
                    wrp.invDate = salesInvoice.Invoice_Date__c;
                    wrp.Phone = salesInvoice.Customer__r.Phone;
                    
                    salesInvoices.add(wrp);
                  //  wrp.CheckNo = null;
                  //  wrp.ChequeAmount = 0.00;
                   // wrp.CashAmount = 0.00;
                   
                }
                
                
                
            }
            
            List<Expense__c> expenseList = [Select Id,Total_Amount__c from Expense__c
                                            where Route__c =: recordId AND (CreatedDate >=:fromDate1  and CreatedDate <=:toDate1) order by CreatedDate];
            
            system.debug('expenseList=== '+expenseList);
            if(expenseList.size()>0){
                for(Expense__c exp : expenseList){
                    totalExpense = totalExpense + exp.Total_Amount__c;
                }
            }
            
        }
        
    }
    
    public class wrapper{
        public String PartyName{get;set;}
        public String Place{get;set;}
        public String InvoiceNo{get;set;}
        public Decimal SaleAmount{get;set;}
        public Decimal CheckNo{get;set;}
        public Date invDate{get;set;}
        public Decimal ChequeAmount{get;set;}
        public Decimal CashAmount{set;get;}
        public string Phone{get;set;}
    }
}