public class ExpenseSheetController {
    
    
    public list<wrapper> wraplist{get;set;}
    
    
    public ExpenseSheetController(){
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
        
        Date incDate = fromdate1;
        wraplist = new list<wrapper>();
        
        List<Cashbook__c> cblist = [select Id,Name,Branch__c,Opening_Balance__c,Closing_Balance__c,CreatedDate,Date__c from Cashbook__c where Route__c = :recordId and (Date__c >=:incDate and Date__c <=:toDate1  ) ];
        Map<Date,Cashbook__c> cbMap = new Map<Date,Cashbook__c>();
        
        for(Cashbook__c cb: cblist){
            cbMap.put(cb.Date__c,cb);
        }
         List<Cash_Transfer__c> cflist = [select Id,Name,Branch__c,Branch__r.Name,Amount__c,CreatedDate,Date__c from Cash_Transfer__c where Route__c = :recordId and (Date__c >=:incDate and Date__c <=:toDate1  ) ];
        Map<Date,Cash_Transfer__c> cfMap = new Map<Date,Cash_Transfer__c>();
        
        for(Cash_Transfer__c cf: cflist){
            cfMap.put(cf.Date__c,cf);
        }
        system.debug('cfMap'+cfMap);
        List<AggregateResult> resinvlist = [select Route__c,DAY_ONLY(createdDate)dt,sum(Invoice_Total__c)amt from Sales_Invoice__c where Route__c = :recordId and  (DAY_ONLY(createdDate)>=:incDate and DAY_ONLY(createdDate)<=:toDate1 ) group by Route__c,DAY_ONLY(createdDate) ];  
        Map<Date,Decimal> aggMapInv = new Map<Date,Decimal>();
        for(AggregateResult res: resinvlist){
            aggMapInv.put(Date.valueof(res.get('dt')), (Decimal)res.get('amt'));
        }
        
        List<AggregateResult> resReclist = [select Route__c,DAY_ONLY(createdDate)dt,sum(Amount__c)amt from Receipt__c where Route__c = :recordId and  Mode_of_Payment__c = 'Cash' and  Receipt_Status__c != 'Cancelled' and (DAY_ONLY(createdDate)>=:incDate and DAY_ONLY(createdDate)<=:toDate1 ) group by Route__c,DAY_ONLY(createdDate) ];  
        Map<Date,Decimal> aggMapRec = new Map<Date,Decimal>();
        for(AggregateResult res: resReclist){
            aggMapRec.put(Date.valueof(res.get('dt')), (Decimal)res.get('amt'));
        }
        
        List<AggregateResult> resExp = [select Route__c,DAY_ONLY(createdDate)dt,sum(Total_Amount__c)amt from Expense__c where Route__c = :recordId and  (DAY_ONLY(createdDate)>=:incDate and DAY_ONLY(createdDate)<=:toDate1 ) and Approval_Status__c = 'Approved'  group by Route__c,DAY_ONLY(createdDate)];   
        Map<Date,Decimal> aggMapExp = new Map<Date,Decimal>();
        for(AggregateResult res: resExp){
            aggMapExp.put(Date.valueof(res.get('dt')), (Decimal)res.get('amt'));
        }
        
       //  List<Expense__c> expList = [select Route__c,DAY_ONLY(createdDate)dt,Total_Amount__c from Expense__c where Route__c = :recordId and  (DAY_ONLY(createdDate)>=:incDate and DAY_ONLY(createdDate)<=:toDate1 ) and Approval_Status__c = 'Approved' ];   
       // Map<Date,List<Expense__c>> expMap = new Map<Date,List<Expense__c>>();
        
        
        List<Dailylog__c> dllist = [select Id,Route__c,Driver__c,Sales_Man__r.Name,CreatedDate from Dailylog__c where Route__c = :recordId and (DAY_ONLY(createdDate)>=:incDate and DAY_ONLY(createdDate)<=:toDate1 ) ];
        Map<Date,Dailylog__c> dlMap = new Map<Date,Dailylog__c>();
        
        for(Dailylog__c dl: dllist){
            dlMap.put(Date.valueof(dl.CreatedDate),dl);
        }
        
        
        while(incDate != todate1.addDays(1)){
            wrapper w = new wrapper();
            w.OpeningBalance = 0;
            w.ClosingBalance = 0;
            w.saleAmount = 0;
            w.Amount = 0;
            w.totalAmount = 0;
            w.totalExp = 0;
            
            if(cbMap.size() > 0 && cbMap.containsKey(incDate)){
                w.OpeningBalance = cbMap.get(incDate).Opening_Balance__c;
                w.ClosingBalance = cbMap.get(incDate).Closing_Balance__c;
            }
            
            
            // List<AggregateResult> resRec = [select Route__c,sum(Amount__c)amt from Receipt__c where Route__c = :recordId and  Mode_of_Payment__c = 'Cash' and  DAY_ONLY(createdDate)=:incDate group by Route__c limit 1];   
            
            if(aggMapInv.size() > 0 && aggMapInv.containsKey(incDate)){
                w.saleAmount = aggMapInv.get(incDate);
            }
            
            if(aggMapRec.size() > 0 && aggMapRec.containsKey(incDate)){
                w.Amount = aggMapRec.get(incDate);
            }
            
            w.totalAmount = w.OpeningBalance + w.Amount;
            
            // List<AggregateResult> resExp = [select Route__c,sum(Total_Amount__c)amt from Expense__c where Route__c = :recordId and  DAY_ONLY(createdDate)=:incDate and Approval_Status__c = 'Approved'  group by Route__c limit 1];   
            /* if(resExp.size() > 0){
w.totalExp = (Decimal)resExp[0].get('amt');
//w.Particulars = String.valueof(resExp.get('Expense_Comments__c'));
w.Particulars = 'ex';
}*/
            if(aggMapExp.size() > 0 && aggMapExp.containsKey(incDate)){
                w.totalExp = aggMapExp.get(incDate);
                w.Particulars = 'Total Expenses on ' + incDate.format();
            }
            
            //List<Dailylog__c> dl = [select Id,Route__c,Driver__c,Sales_Man__r.Name from Dailylog__c where Route__c = :recordId and  DAY_ONLY(createdDate)=:incDate limit 1];
            if(dlMap.size() > 0 && dlMap.containsKey(incDate)){
                w.SalesMan = dlMap.get(incDate).Sales_Man__r.Name;
            }
            w.transDate = incDate;
            wraplist.add(w);
           // to branch
            if(cfMap.size() > 0 && cfMap.containsKey(incDate)){
                if(cfMap.get(incDate).Branch__c != null){
                 wrapper w1 = new wrapper();
            w1.OpeningBalance = 0;
            w1.ClosingBalance = 0;
            w1.saleAmount = 0;
            w1.Amount = cfMap.get(incDate).Amount__c;
            w1.totalAmount = 0;
            w1.totalExp = 0;
            w1.Tobranch =cfMap.get(incDate).Branch__r.Name;
            w1.transDate = incDate;
            wraplist.add(w1);
            }
            }   
            
            
           //end 
            
            
            
            incDate = incDate.addDays(1);
            
        }
        
        wraplist.sort();
        //this.wraplist = wraplist;
        system.debug('wraplist:' + wraplist);
        
        
    }
    public class wrapper implements Comparable{
        
        public Date transDate{get;set;}
        public Decimal saleAmount{get;set;}
        public Decimal OpeningBalance{get;set;}
        public String Particulars{get;set;}
        public String SalesMan{get;set;}
        public Decimal Amount{get;set;}
        public Decimal totalAmount{get;set;}
        public Decimal totalExp{get;set;}
        public Decimal ClosingBalance{get;set;}
          public String Tobranch{get;set;}
        
        
        public  Integer compareTo(Object anotherObject){
            wrapper wso2=(wrapper) anotherObject;
            if(transDate>wso2.transDate){
                return 1;
            }else if(transDate<wso2.transDate){
                return -1;
            }
            return 0;
        }
    }
}