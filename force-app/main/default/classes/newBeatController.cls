public class newBeatController {
  @AuraEnabled
    public static List<user> getUserList() {
        user u = [SELECT Id,Name,Profile.Name FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];
        if(u.Profile.Name == 'Sales executive' || u.Profile.Name == 'Van Executive'){
            return [SELECT Id,Name,Routes__c FROM user WHERE Id=:userinfo.getUserId() ORDER BY Name ASC];
        }else{
            return [SELECT Id,Name,Routes__c FROM user where Profile.Name='Sales Executive' or Profile.Name='Van Executive' ORDER BY Name ASC];
        }
        
        
    }
      @AuraEnabled
    public static List<Route__c> getRouteList(string uId) {
        return [SELECT Id,Name FROM Route__c WHERE ownerId =:uId ];
    }
    @AuraEnabled
    public static List<Account> getStoreList( string uId,string route) {
       
        return [SELECT id,Name,RouteName__c,WarehouseName__c,Owner.Name,State__c,Store_Category__c,District__c,Grade__c FROM Account WHERE ownerId=:uId AND Routes__c=:route AND Approval_Status__c='Approved'];
        
    }
    @AuraEnabled
    public static List<New_Beat__c> getbeatList( string uId,string route) {
       
        return [SELECT id,Name,Route__c,Owner.Name,Beat_Date__c,RouteName__c,WarehouseName__c FROM New_Beat__c WHERE ownerId=:uId AND Routes__c=:route ORDER BY  Beat_Date__c DESC NULLS LAST];
        
    }
     @AuraEnabled
    public static List<visit__c> getvisitList( string BeatId) {
       
        return [SELECT id,Name,Account1__c,Account_Name__c,Status__c,Planned_start_time__c,Account1__r.Routes__c FROM visit__c WHERE New_Beat__c=:BeatId ];
        
}
	 @AuraEnabled
    public static List<New_Beat__c> createBeat( string uId,List<Account> stores,date sdate,string route) {
        //system.debug('1');
        List<visit__c> vList = new List<visit__c>();
        route__c rt = [SELECT id,Name,warehouse__c FROM route__c WHERE id =:route];
        New_Beat__c nb = new New_Beat__c();
        nb.Beat_Date__c = sdate;
        nb.Routes__c = route;
        nb.warehouse__c = rt.warehouse__c;
        nb.OwnerId = uId;
        insert nb;
        //system.debug('2');
        for(Account acc : stores){
            visit__c v = new visit__c();
            v.Account1__c = acc.id;
            v.New_Beat__c = nb.id;
            v.Planned_Start_Time__c = sdate;
            v.Status__c = 'Planned';
            v.OwnerId = uId;
            vList.add(v);
        }
         //system.debug('3');
        insert vList;
           //system.debug('4');
         return [SELECT id,Name,Route__c,Owner.Name,Beat_Date__c,RouteName__c,WarehouseName__c FROM New_Beat__c WHERE ownerId=:uId AND Routes__c=:route ORDER BY  Beat_Date__c DESC NULLS LAST];
    }
     @AuraEnabled
    public static List<New_Beat__c> createnewBeat( string uId,List<visit__c> stores,date sdate,string route) {
        List<visit__c> vList = new List<visit__c>();
        route__c rt = [SELECT id,Name,warehouse__c FROM route__c WHERE id =:route];
        New_Beat__c nb = new New_Beat__c();
        nb.Beat_Date__c = sdate;
        nb.Routes__c = route;
        nb.warehouse__c = rt.warehouse__c;
        nb.OwnerId = uId;
        insert nb;
        for(visit__c acc : stores){
            visit__c v = new visit__c();
            v.Account1__c = acc.Account1__c;
            v.New_Beat__c = nb.id;
            v.Planned_Start_Time__c = sdate;
            v.Status__c = 'Planned';
            v.OwnerId = uId;
            vList.add(v);
        }
        insert vList;
         return [SELECT id,Name,Route__c,Owner.Name,Beat_Date__c,RouteName__c,WarehouseName__c FROM New_Beat__c WHERE ownerId=:uId AND Routes__c=:route ORDER BY  Beat_Date__c DESC NULLS LAST];
    }
     @AuraEnabled
    public static List<New_Beat__c> getupcominbeats( string uId) {
        return [SELECT id,Name,Route__c,Owner.Name,Beat_Date__c,RouteName__c,WarehouseName__c FROM New_Beat__c WHERE ownerId=:uId AND Beat_Date__c >= TODAY ORDER BY  Beat_Date__c DESC NULLS LAST];
        
    }
     @AuraEnabled
    public static List<New_Beat__c> changeVisitOwner( string uId,List<visit__c> stores,string assId,string beId) {
        List<visit__c> vList = new List<visit__c>();
       New_Beat__c nb = [SELECT id,name,OwnerId,Routes__c,warehouse__c,Beat_Date__c FROM New_Beat__c WHERE id=:beId LIMIT 1];
       
        New_Beat__c newnb = new New_Beat__c();
         newnb.OwnerId = assId;
        newnb.Beat_Date__c = nb.Beat_Date__c;
        newnb.warehouse__c = nb.warehouse__c;
        newnb.Route__c = nb.Routes__c;
        insert newnb;
        for(visit__c acc : stores){
            visit__c v = new visit__c(id=acc.id);
            v.New_Beat__c = newnb.id;
            v.OwnerId = assId;
            vList.add(v);
        }
        
        update vList;
         return [SELECT id,Name,Route__c,Owner.Name,Beat_Date__c,RouteName__c,WarehouseName__c FROM New_Beat__c WHERE ownerId=:uId AND Beat_Date__c >= TODAY ORDER BY  Beat_Date__c DESC NULLS LAST];
    }
}