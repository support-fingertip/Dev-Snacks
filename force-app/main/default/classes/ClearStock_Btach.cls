Global class ClearStock_Btach implements Database.Batchable<Sobject>,Database.stateful {
    
    global  string query;
    global  List<Route__c> routeList = new list<Route__c>(); 
    global string htmlbody;
     global List<Route__c> routeNameList = new list<Route__c>(); 
    
    global ClearStock_Btach(string q,List<Route__c> routes){
        this.routeList = routes;
        this.query = q;
    }
    global Database.QueryLocator Start(Database.BatchableContext BC){
        
        return Database.getQueryLocator( query);
    }
    global void execute (Database.BatchableContext BC,List <sobject> scope){
        
           list<Stock__c> stocklist =[select Id,Name, Intial_Stock__c, Available_Quantity__c, Mismatch_Qty__c, CreatedDate,  Route__r.Name from Stock__c  where Route__c IN :routeList and Available_Quantity__c != 0 and Available_Quantity__c!=null];
       routeNameList = scope;
        
        try{
            for(Stock__c stock : stocklist){
            stock.Mismatch_Qty__c = stock.Available_Quantity__c;
            stock.Available_Quantity__c = 0;
            stock.ownerId =label.StockOwner;
        }
         if(!stocklist.isEmpty()){
        update stocklist;
         }
        list<Stock_History__c> stockHistoryList =[select Id,Available_Quantity__c from Stock_History__c where Date__c=TODAY AND Route__c IN :routeList];
        for(Stock_History__c sh :stockHistoryList){
            sh.Available_Quantity__c =0;
        }
            if(!stockHistoryList.isEmpty()){
        update stockHistoryList;
            }
            this.htmlbody ='Dear user,<br/><br/> We are pleased to inform you that the stock clearance has been successfully completed for the following routes:<br/><br/>';
            htmlbody +='<table border="1px" width="80%" style=" border: 1px solid black; border-collapse: collapse;"><tr><th>Id</th><th>Route</th></tr>';
            for(Route__c r: routeNameList){
              htmlbody +='<tr ><td style="padding:3px;text-align:center;">'+r.Id+' </td><td style="padding:3px;text-align:center;">'+r.Name+'</td> </tr>';
                    }
            
           htmlbody+= '<tr><td style="padding:3px;text-align:center;"> No of Record Proessed</td><td style="padding:3px;text-align:center;">'+stocklist.size()+'</td></tr></table><br/> Thank you.<br/>';
            
        }catch(Exception ae){
            this.htmlbody ='Dear user,<br/><br/> We regret to inform you that the stock clearance was not successfully completed for the following routes:<br/>';
                  htmlbody +='<table border="1px" width="80%" style="border: 1px solid black; border-collapse: collapse;"><tr><th>Id</th><th>Route</th></tr>';
            for(Route__c r: routeNameList){
              htmlbody +='<tr><td style="padding:3px;text-align:center;">'+r.Id+' </td><td style="padding:3px;text-align:center;">'+r.Name+'</td> </tr>';
                    }
            htmlbody += '<tr><td style="padding:3px;text-align:center;"> Error Message :</td><td style="padding:3px;text-align:center;"> '+ae.getLineNumber()+'</td?</tr><tr><td style="padding:3px;text-align:center;"> Message : </td><td style="padding:3px;text-align:center;">'+ae.getMessage()+
                '</td> </tr><tr><td style="padding:3px;text-align:center;">StackTrace : </td><td style="padding:3px;text-align:center;">'+ae.getStackTraceString() +'</td></tr><tr><td style="padding:3px;text-align:center;"> Type : </td><td style="padding:3px;text-align:center;">'+ ae.getTypeName()+'</td></tr></table><br/> <br/>Thank you';
            
             ExceptionHandler.addLog(ae,String.valueOf(stocklist)); 

        }
    }
    global void finish(Database.BatchableContext BC){
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'it@seraphinedevimpex.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Clear Stock Batch');
         mail.setHtmlBody(htmlbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}