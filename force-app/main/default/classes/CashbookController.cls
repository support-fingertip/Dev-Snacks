public class CashbookController {
    
    public list<wrapper> wraplist{get;set;}
    public Decimal OpeningBalance{get;set;}
    public Decimal ClosingBalance{get;set;}
    public Decimal totalDr{get;set;}
    public Decimal totalCr{get;set;}
    
    public CashbookController(){
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
        
        wraplist = new list<wrapper>();
        OpeningBalance = 0;
        ClosingBalance=0;
        
        totalDr = OpeningBalance;
        totalCr = 0;
        // List<Cash_Transfer__c> translist = new List<Cash_Transfer__c>();
        
        if(sobjectType == 'Branch__c'){
            
            List<Cashbook__c> cbList = [select Id,Name,Date__c,Branch__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Cashbook__c where Branch__c = :recordId and (Date__c=:fromDate1  or Date__c=:toDate1) ];
            if(cbList.size() > 0){
                for(Cashbook__c cb: cbList){
                    if(cb.Date__c == fromDate1){
                        OpeningBalance = cb.Opening_Balance__c;
                    }
                    if(cb.Date__c == toDate1){
                        ClosingBalance = cb.Closing_Balance__c;
                    }
                }
            }
         totalDr = OpeningBalance;    
            
            List<Cash_Transfer__c> translist = [select id,Name,From__c, TO__c, Branch__c,Branch__r.Name, Route__c,Route__r.Name, Amount__c, Remarks__c, Status__c, CreatedDate from Cash_Transfer__c where Branch__c = :recordId and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1)];
            
            
            if(translist.size() > 0){
                for(Cash_Transfer__c ct: translist){
                    if(ct.Amount__c !=null){
                        wrapper w = new wrapper();
                        w.Branch = ct.Branch__r.Name;
                        w.Route = ct.Route__r.Name;
                        w.transDate = Date.valueOf(ct.CreatedDate);
                        //w.From1 = ct.From__c;
                        //w.To1 = ct.To__c;
                        w.Amount = ct.Amount__c;
                        if(ct.From__c == 'Branch' && ct.To__c == 'Route'){
                            w.Remarks = ct.Branch__r.Name +  + ' to ' + ct.Route__r.Name;
                        }
                        else if(ct.From__c == 'Route' && ct.To__c == 'Branch'){
                            w.Remarks = ct.Route__r.Name +  + ' to ' + ct.Branch__r.Name;
                        }
                        else if(ct.From__c == 'Branch' && ct.To__c == 'Head Office'){
                            w.Remarks = ct.Branch__r.Name +  + ' to ' + ct.To__c;
                        }
                        else if(ct.From__c == 'Head Office' && ct.To__c == 'Head Office'){
                            w.Remarks = ct.From__c +  + ' to ' + ct.Branch__r.Name;
                        }
                        else{
                             w.Remarks = ct.Remarks__c != null ? ct.Remarks__c : ct.From__c + ' to ' + ct.To__c;
                        }
                       
                        w.CreatedDate = ct.CreatedDate;
                        w.Status = ct.From__c == 'Branch' && (ct.To__c == 'Route' || ct.To__c == 'Head Office' ) ? 'Debited' :(ct.From__c == 'Route' || ct.From__c == 'Head Office' ) && ct.To__c == 'Branch' ? 'Credited' : '';
                        wraplist.add(w);
                        if(w.Status == 'Debited'){
                            totalDr = totalDr + w.Amount;
                        }
                        if(w.Status == 'Credited'){
                            totalCr = totalCr + w.Amount;
                        }
                    }
                    
                }
            }
            
            List<Receipt__c> recList = [select Id,Name,Branch__c,Branch__r.Name,Route__c,Route__r.Name,Amount__c,Receipt_Date__c,Customer__c,Customer__r.Name,Remarks__c,CreatedDate from Receipt__c where Mode_of_Payment__c = 'Cash' and Receipt_Status__c != 'Cancelled' and Branch__c = :recordId and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1) AND ((New_Approval_Flow__c =true AND Approval_status__c='Approved') OR (Approval_status__c=null AND New_Approval_Flow__c=false))];
         /*   if(recList.size() > 0){
                for(Receipt__c rec: recList){
                    if(rec.Amount__c != null && rec.Route__c != null && rec.Customer__c != null){
                        wrapper w = new wrapper();
                        w.Branch = rec.Branch__r.Name;
                        w.Route = rec.Route__r.Name;
                        w.Customer = rec.Customer__r.Name;
                        w.Amount = rec.Amount__c;
                        w.transDate = rec.Receipt_Date__c;
                        w.CreatedDate = rec.CreatedDate;
                        w.Status = 'Debited';
                        w.Remarks = 'Collected from '+rec.Customer__r.Name + ' ('+ rec.Route__r.Name + ')';
                        
                        wraplist.add(w);
                        if(w.Status == 'Debited'){
                            totalDr = totalDr + w.Amount;
                        }
                        if(w.Status == 'Credited'){
                            totalCr = totalCr + w.Amount;
                        }
                    }
                    
                }
            }*/
            
            List<Expense__c> explist = [select Id,Name,Branch__c,Route__c,Branch__r.Name,Route__r.Name,Expense_Date__c,Total_Amount__c,Expense_Comments__c,CreatedDate from Expense__c where Branch__c = :recordId and Approval_Status__c = 'Approved' and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1)];
            if(explist.size() > 0){
                for(Expense__c exp: explist){
                    if(exp.Total_Amount__c != null){
                        wrapper w = new wrapper();
                        w.Branch = exp.Branch__r.Name;
                        w.Route = exp.Route__r.Name;
                        w.Amount = exp.Total_Amount__c;
                        w.transDate = exp.Expense_Date__c;
                        w.CreatedDate = exp.CreatedDate;
                        w.Status = 'Credited';
                        w.Remarks = exp.Expense_Comments__c + ' ('+exp.Route__r.Name+')';
                        wraplist.add(w);
                        if(w.Status == 'Debited'){
                            totalDr = totalDr + w.Amount;
                        }
                        if(w.Status == 'Credited'){
                            totalCr = totalCr + w.Amount;
                        }
                    }
                    
                }
            }
            
            ClosingBalance = totalDr - totalCr;
            
            
        }
        if(sobjectType == 'Route__c'){
             List<Cashbook__c> cbList = [select Id,Name,Date__c,Branch__c,Opening_Balance__c,Closing_Balance__c,CreatedDate from Cashbook__c where Route__c = :recordId and (Date__c=:fromDate1  or Date__c=:toDate1) ];
            if(cbList.size() > 0){
                for(Cashbook__c cb: cbList){
                    if(cb.Date__c == fromDate1){
                        OpeningBalance = cb.Opening_Balance__c;
                    }
                    if(cb.Date__c == toDate1){
                        ClosingBalance = cb.Closing_Balance__c;
                    }
                }
            }
             totalDr = OpeningBalance;
            List<Cash_Transfer__c> translist = [select id,Name,From__c, TO__c, Branch__c,Branch__r.Name, Route__c,Route__r.Name, Amount__c, Remarks__c, Status__c, CreatedDate from Cash_Transfer__c where Route__c = :recordId  and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1) order by CreatedDate ];
            
            if(translist.size() > 0){
                for(Cash_Transfer__c ct: translist){
                    if(ct.Amount__c !=null){
                        wrapper w = new wrapper();
                        w.Branch = ct.Branch__r.Name;
                        w.Route = ct.Route__r.Name;
                        w.transDate = Date.valueOf(ct.CreatedDate);
                        //w.From1 = ct.From__c;
                        //w.To1 = ct.To__c;
                        w.Amount = ct.Amount__c;
                         w.Amount = ct.Amount__c;
                        if(ct.From__c == 'Branch' && ct.To__c == 'Route'){
                            w.Remarks = ct.Branch__r.Name +  + ' to ' + ct.Route__r.Name;
                        }
                        else if(ct.From__c == 'Route' && ct.To__c == 'Branch'){
                            w.Remarks = ct.Route__r.Name +  + ' to ' + ct.Branch__r.Name;
                        }
                        else if(ct.From__c == 'Branch' && ct.To__c == 'Head Office'){
                            w.Remarks = ct.Branch__r.Name +  + ' to ' + ct.To__c;
                        }
                        else if(ct.From__c == 'Head Office' && ct.To__c == 'Head Office'){
                            w.Remarks = ct.From__c +  + ' to ' + ct.Branch__r.Name;
                        }
                        else{
                             w.Remarks = ct.Remarks__c != null ? ct.Remarks__c : ct.From__c + ' to ' + ct.To__c;
                        }
                        w.CreatedDate = ct.CreatedDate;
                        w.Status = ct.From__c == 'Branch' && ct.To__c == 'Route' ? 'Credited' : ct.From__c == 'Route' && ct.To__c == 'Branch' ? 'Debited' : ''  ;
                        wraplist.add(w);
                        if(w.Status == 'Debited'){
                            totalDr = totalDr + w.Amount;
                        }
                        if(w.Status == 'Credited'){
                            totalCr = totalCr + w.Amount;
                        }
                        
                        /*  if(OpeningBalance == 0 && (ct.From__c =='Branch' && ct.To__c == 'Route')){
OpeningBalance = w.Amount;
}*/
                    }
                    
                }
            }
            
            List<Receipt__c> recList = [select Id,Name,Branch__c,Branch__r.Name,Route__c,Route__r.Name,Receipt_Date__c,Amount__c,Customer__c,Customer__r.Name,Remarks__c,CreatedDate from Receipt__c where Mode_of_Payment__c = 'Cash' and Receipt_Status__c != 'Cancelled' and Route__c = :recordId and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1) AND ((New_Approval_Flow__c =true AND Approval_status__c='Approved') OR (Approval_status__c=null AND New_Approval_Flow__c=false))];
           /* if(recList.size() > 0){
                for(Receipt__c rec: recList){
                    if(rec.Amount__c != null && rec.Route__c != null && rec.Customer__c != null){
                        wrapper w = new wrapper();
                        w.Branch = rec.Branch__r.Name;
                        w.Route = rec.Route__r.Name;
                        w.Customer = rec.Customer__r.Name;
                        w.Amount = rec.Amount__c;
                        w.transDate = rec.Receipt_Date__c;
                        w.CreatedDate = rec.CreatedDate;
                        w.Status = 'Credited';
                        w.Remarks = 'Collected from '+rec.Customer__r.Name + ' ('+ rec.Route__r.Name + ')';
                        
                        wraplist.add(w);
                        if(w.Status == 'Debited'){
                            totalDr = totalDr + w.Amount;
                        }
                        if(w.Status == 'Credited'){
                            totalCr = totalCr + w.Amount;
                        }
                    }
                    
                }
            }
            */
            List<Expense__c> explist = [select Id,Name,Branch__c,Route__c,Branch__r.Name,Route__r.Name,Expense_Date__c,Total_Amount__c,Expense_Comments__c,CreatedDate from Expense__c where Route__c = :recordId and (DAY_ONLY(createdDate)>=:fromDate1  and DAY_ONLY(createdDate)<=:toDate1)];
            if(explist.size() > 0){
                for(Expense__c exp: explist){
                    if(exp.Total_Amount__c != null){
                        wrapper w = new wrapper();
                        w.Branch = exp.Branch__r.Name;
                        w.Route = exp.Route__r.Name;
                        w.Amount = exp.Total_Amount__c;
                        w.transDate = exp.Expense_Date__c;
                        w.CreatedDate = exp.CreatedDate;
                        w.Status = 'Debited';
                        w.Remarks = exp.Expense_Comments__c + '('+exp.Route__r.Name+')';
                        wraplist.add(w);
                        if(w.Status == 'Debited'){
                            totalDr = totalDr + w.Amount;
                        }
                        if(w.Status == 'Credited'){
                            totalCr = totalCr + w.Amount;
                        }
                    }
                    
                }
            }
            
            ClosingBalance = totalCr - totalDr;
            
            
        }
        
        wraplist.sort();
        //this.wraplist = wraplist;
        system.debug('wraplist:' + wraplist);
    }
    
    
    public class wrapper implements Comparable{
        
        public String Branch{get;set;}
        public String Route{get;set;}
        public String Customer{get;set;}
        public String From1{get;set;}
        public String To1{get;set;}
        public Decimal Amount{get;set;}
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