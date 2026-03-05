public class customNewExpenseController {

     public class dataBox{
        @AuraEnabled
        public Date Todaydate {get; set;}
        @AuraEnabled
        public Date yersterdaydate {get; set;}         
        @AuraEnabled
        public Date twodaydate {get; set;} 
        @AuraEnabled
        public string listId {get; set;} 
        @AuraEnabled
        public integer inprogressCount {get; set;}  
        @AuraEnabled
        public integer plannedCount {get; set;}   
     }
     @AuraEnabled
     public static dataBox getDates(){
             dataBox db = new dataBox();
             db.Todaydate = system.today();
             date mydate = system.today();
             db.twodaydate = mydate.addDays(-2);
             db.yersterdaydate = mydate.addDays(-1);
              List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Expense__c' and Name='All'];
			db.listId = listviews[0].Id;
             List<visit__c> inprogressList= [SELECT id,Name,Status__c FROM visit__c WHERE Status__c = 'In Progress' AND Planned_Start_Time__c = TODAY AND ownerId =:userinfo.getUserId()];
             db.inprogressCount = inprogressList.size();
              List<visit__c> plannedList= [SELECT id,Name,Status__c FROM visit__c WHERE Status__c = 'Planned' AND Planned_Start_Time__c = TODAY AND ownerId =:userinfo.getUserId()];
             db.plannedCount = plannedList.size();
             return db;
     }    
     @AuraEnabled
     public static Expense__c insertExpense(Expense__c expense){ 
        if(expense !=null ){
            
            try {
                upsert expense;
                return expense;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(expense)  ); 
                return null;
            }     
            
        }else{
            return null;
        }
        
    }
    @AuraEnabled
    public static void submitapproval(string expId){ 
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(expId);
        requests.add(req);
    	
        try {
            Approval.ProcessResult[] processResults = Approval.process(requests);
        }
        catch (System.Exception ae) { 
           ExceptionHandler.addLog(ae,String.valueOf(expId)  );   
        }     
        
    
    }
     @AuraEnabled
    public static list<Expense_Account__c> getExpenseAccount(){ 
          list<Expense_Account__c> expAccount;
                User currentUser = [SELECT Id, Company_Name__c,Route_Id__c,Branch_Id__c FROM User WHERE Id = :UserInfo.getUserId()];
       List<Route__c> route = [select Id,Route_Id__c,Branch_Name__c from Route__c where Route_Id__c =: currentUser.Route_Id__c Limit 1];
        List<Branch__c> branch = [select Id,Cash_In_Hand__c from Branch__c where Branch_Id__c = :currentUser.Branch_Id__c];
        
        if(route.size() > 0){
             expAccount =[select Id,Name from Expense_Account__c where Branch__c=:route[0].Branch_Name__c  order by Name asc ];
        }
        else if(branch.size()>0){
             expAccount =[select Id,Name from Expense_Account__c where Branch__c=:branch[0].Id  order by Name asc ];
        }
 
        return expAccount;
    } 
}