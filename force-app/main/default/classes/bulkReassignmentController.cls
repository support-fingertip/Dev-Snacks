public class bulkReassignmentController {
    
    @AuraEnabled
    public static List<user> getuserdetails(){
        return [SELECT Id,Name,Route_Id__c,Username FROM user where Route_Id__c != null];
    }
    @AuraEnabled
    public static List<Account> getcustomers(string currentUserId){
        user u = [SELECT Id,Name,Route_Id__c FROM User WHERE Id=:currentUserId];
        List<Account> acclist = new List<Account>();
        acclist = [select Id,Name,CustomerId__c,Phone,RouteName__c,OwnerId,CreatedDate from Account where OwnerId=:currentUserId];
        return acclist;
    }
    @AuraEnabled
    Public static List<Account> updateOwner(List<Account> accs, string currentUserId, string assignToId){
        user currentUser = [SELECT Id,Name,Route_Id__c FROM User WHERE Id=:currentUserId];
        user assignToUser = [SELECT Id,Name,Route_Id__c FROM User WHERE Id=:assignToId];
        List<Route__c> rt = [select Id,Name from Route__c where Route_Id__c = :assignToUser.Route_Id__c];
        List<Account> acclist = new List<Account>();
        
        for(Account acc : accs){
            Account acc1 = new Account();
            acc1.Id = acc.Id;
            if(acc.OwnerId ==currentUserId){
                acc1.OwnerId =  assignToId;
            }
            
            if(rt.size() > 0){
                acc1.Routes__c = rt[0].Id;
            }
           acclist.add(acc1);
        } 
         system.debug('acclist:' + acclist);
            try{
                
                update acclist;
                return getcustomers(currentUserId);
            }
            catch(DmlException ex){
                system.debug('Ex:' + ex.getMessage());
                  return null;
            }
            
            
      
        
        
    }
    
    
    
}