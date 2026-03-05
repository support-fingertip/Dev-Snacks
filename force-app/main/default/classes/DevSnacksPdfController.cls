public class DevSnacksPdfController {
    
    public Decimal totalDebit {get; set;}
    public String customer {get;set;}
    public Date fDate {get;set;}
    public Date tDate {get;set;}
    public Decimal totalCredit {get; set;}
    public Decimal totalDebitwithOB {get;set;}
    public Decimal OpeningBalance{get;set;}
    public Decimal ClosingBalance{get;set;}
    public list<wrapper> wraplist{get;set;}
    
    
    public DevSnacksPdfController(){
        
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        String fromDate = ApexPages.currentPage().getParameters().get('from'); 
        String toDate = ApexPages.currentPage().getParameters().get('to'); 
        Date fromdate1 = date.valueof(fromDate);
        Date todate1 = date.valueof(toDate);
        
        fDate = fromdate1;
        tDate = todate1;
        
        Date fromdate2 = date.valueof(fromDate).addDays(-1);
        Date todate2 = date.valueof(toDate).addDays(-1);
        
        system.debug('fromDate:' + fromdate1);
        system.debug('toDate:' + todate1);
        
        wraplist = new list<wrapper>();
        
        OpeningBalance = 0;
        ClosingBalance=0;
            
        totalDebit = OpeningBalance; 
        totalCredit = 0;
        List<Account> accList = [select id, Name from Account where id=:recordId Limit 1];  
        if(accList.size()>0){
            customer = accList[0].Name;
        }
        
        
        
        List<Customer_Cashbook__c> cbList = [select Id,Name,Date__c,Customer__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Customer_Cashbook__c where Customer__c = :recordId and (Date__c=:fromDate1  or Date__c=:toDate1) ];
            if(cbList.size() > 0){
                for(Customer_Cashbook__c cb: cbList){
                   if(cb.Date__c == fromDate1){
                        OpeningBalance = cb.Opening_Balance__c;
                    }
                    if(cb.Date__c == toDate1){
                        ClosingBalance = cb.Closing_Balance__c;
                    }
                }
            }
        
        totalDebit = OpeningBalance; 
        
         List<Sales_Invoice__c> salesInvoices = [SELECT id,Name,Invoice_Date__c,Customer__c,Grand_Total_Discounted__c,CreatedDate FROM Sales_Invoice__c where Customer__c=:recordId and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1) ];
        
        if(salesInvoices.size() > 0){
                for(Sales_Invoice__c ct: salesInvoices){
                    if(ct.Grand_Total_Discounted__c !=null){
                        wrapper w = new wrapper();
                        w.transDate = Date.valueOf(ct.Invoice_Date__c);
                        w.Debit = ct.Grand_Total_Discounted__c;
                        w.objest = true;
                        w.Remarks = 'Sales GST';
                        w.VocherNum = ct.Name;
                        w.VocherType = 'TVM2 Sales';
                        w.CreatedDate = ct.CreatedDate;
                       // w.Status = ct.From__c == 'Branch' && (ct.To__c == 'Route' || ct.To__c == 'Head Office' ) ? 'Debited' :(ct.From__c == 'Route' || ct.From__c == 'Head Office' ) && ct.To__c == 'Branch' ? 'Credited' : '';
                        wraplist.add(w);
                        totalDebit = totalDebit + w.Debit;

                    }
                    
                }
            }

        List<Receipt__c> receipts = [SELECT id,Amount__c,Bank_Name__c,Receipt_Date__c,Cheque_Trasaction_Number__c,Mode_of_payment__c, Customer__c, Name,CreatedDate FROM Receipt__c where Customer__c=:recordId and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1) ];
        if(receipts.size() > 0){
            for(Receipt__c ct: receipts){
                if(ct.Amount__c !=null){
                    wrapper w = new wrapper();
                    w.transDate = Date.valueOf(ct.Receipt_Date__c);
                    w.Credit = ct.Amount__c;
                    w.objest = false;
                    //w.Remarks = ct.Mode_of_payment__c +'-'+ct.Bank_Name__c+'-'+ ct.Cheque_Trasaction_Number__c;
                    w.Remarks = ((ct.Mode_of_payment__c != null && String.isNotBlank(String.valueOf(ct.Mode_of_payment__c))) ? ct.Mode_of_payment__c  : '') +
                        ((ct.Bank_Name__c != null && String.isNotBlank(String.valueOf(ct.Bank_Name__c))) ?  '-' + ct.Bank_Name__c  : '') +
                        ((ct.Cheque_Trasaction_Number__c != null && String.isNotBlank(String.valueOf(ct.Cheque_Trasaction_Number__c))) ?  '-' + String.valueOf(ct.Cheque_Trasaction_Number__c) : '');
                    w.VocherNum = ct.Name;
                    w.VocherType = 'TVM2 Receipt';
                    w.CreatedDate = ct.CreatedDate;
                    // w.Status = ct.From__c == 'Branch' && (ct.To__c == 'Route' || ct.To__c == 'Head Office' ) ? 'Debited' :(ct.From__c == 'Route' || ct.From__c == 'Head Office' ) && ct.To__c == 'Branch' ? 'Credited' : '';
                    wraplist.add(w);
                    
                    totalCredit = totalCredit + w.Credit;
                    
                }
                
            }
        }
        
        List<Return__c> retList = [SELECT id,Name,Return_Date__c,Customer__c,Grand_Total__c,CreatedDate FROM Return__c where Customer__c=:recordId and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1)];
        if(retList.size() > 0){
            for(Return__c ct: retList){
                if(ct.Grand_Total__c !=null){
                    wrapper w = new wrapper();
                    w.transDate = Date.valueOf(ct.Return_Date__c);
                    w.Credit = ct.Grand_Total__c;
                    w.objest = false;  
                    w.Remarks = 'Sales Returns';
                    w.VocherNum = ct.Name;
                    w.VocherType = 'Credit Note';
                    w.CreatedDate = ct.CreatedDate;
                    // w.Status = ct.From__c == 'Branch' && (ct.To__c == 'Route' || ct.To__c == 'Head Office' ) ? 'Debited' :(ct.From__c == 'Route' || ct.From__c == 'Head Office' ) && ct.To__c == 'Branch' ? 'Credited' : '';
                    wraplist.add(w);
                    
                    totalCredit = totalCredit + w.Credit;
                    
                }
                
            }
        }

        ClosingBalance = totalDebit - totalCredit;
        wraplist.sort();
    }
    public class wrapper implements Comparable{
        
        public String Branch{get;set;}
        public String Route{get;set;}
        public String Customer{get;set;}
        public String VocherNum{get;set;}
        public String VocherType{get;set;}
        public String From1{get;set;}
        public boolean objest{get;set;}
        public String To1{get;set;}
        public Decimal Amount{get;set;}
        public Decimal Debit{get;set;}
        public Decimal Credit{get;set;}
        public String Remarks{get;set;}
        public DateTime CreatedDate{set;get;}
        public String Status{get;set;}
        public Date transDate{get;set;}
        
        public  Integer compareTo(Object anotherObject){
            wrapper wso2=(wrapper) anotherObject;
            if(CreatedDate>wso2.CreatedDate){
                return 1;
            }else if(CreatedDate<wso2.CreatedDate){
                return -1;
            }
            return 0;
        }
    }

}