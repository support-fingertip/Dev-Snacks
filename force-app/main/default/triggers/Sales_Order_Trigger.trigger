trigger Sales_Order_Trigger on Sales_order__c (After Update) {
    if(trigger.operationType == TriggerOperation.AFTER_UPDATE){
        set<Id> custId = new set<Id>();
        list<Account> AccountList = new list<Account>();
        for(Sales_order__c so : trigger.New){
            if(so.Status__c =='Converted' && so.Status__c !=trigger.oldMap.get(so.Id).Status__c && so.Skip_Credit_Limit_For_Next_Order__c&& so.Customer__c!=null){
                custId.add(so.Customer__c);
            }
        } 
        if(custId.size() > 0){
            for(Id cust :custId ){
                Account acc = new Account();
                acc.Id = cust;
                acc.Skip_Credit_Limit_For_Next_Order__c=false;
                if(!AccountList.contains(acc)){
                AccountList.add(acc);
                }
            }
            try{
            update AccountList;
            }catch(exception ex){
                   ExceptionHandler.addLog(ex,String.valueOf(AccountList)); 
            }
        }
    }
}