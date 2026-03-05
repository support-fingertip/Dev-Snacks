public class userRoutesController {

     @AuraEnabled
    public static List<user> getUserList() {
        
        return [SELECT Id,Name FROM user];
        
    }
      @AuraEnabled
    public static List<Route__c> getRouteList(string uId) {
        return [SELECT Id,Name,Route_Id__c,warehouse_Name__c,ownerId FROM Route__c WHERE ownerId =:uId ];
    }
    @AuraEnabled
    public static List<Account> getStoreList(string routeId) {
        return [SELECT Id,Name,RouteName__c,WarehouseName__c,Street_Name__c,Owner.Name,State__c,Store_Category__c,District__c,Grade__c FROM Account WHERE Routes__c=:routeId ORDER BY Name ASC NULLS FIRST];
        
    }
     @AuraEnabled
    public static List<Account> fetchaAllStore() {
        return [SELECT Id,Name,Contact_Person__c,Phone,RouteName__c,WarehouseName__c,Street_Name__c,OwnerName__c,State__c,Store_Category__c,District__c,Grade__c FROM Account ORDER BY Name ASC NULLS FIRST];
        
    }
     @AuraEnabled
    public static List<warehouse__c> fetchaWarehouses() {
        return [SELECT Id,Name FROM warehouse__c ORDER BY Name ASC NULLS FIRST];
    }
    @AuraEnabled
    public static List<Route__c> fetchRouteNames(string whId) {
        return [SELECT Id,Name,warehouse_Name__c,OwnerName__c FROM Route__c WHERE warehouse__c=:whId ORDER BY Name ASC NULLS FIRST];
    }
    @AuraEnabled
    public static List<Route__c> changeRouteOwner(List<Route__c> routes, string whId , string nextuId) {
        system.debug(routes.size());
        set<id> rids = new set<id>();
        List<Route__c> updateRouteList = new List<Route__c>();
        for(Route__c rt : routes){
            rt.OwnerId = nextuId;
            rids.add(rt.Id);
            updateRouteList.add(rt);
            
        }
          system.debug(updateRouteList.size());
        update updateRouteList;
         List<Account> updateAccountList = new List<Account>();
        for(Account acc: [SELECT id,Routes__c,OwnerId FROM Account WHERE Routes__c IN : rids]){
            acc.OwnerId = nextuId;
            updateAccountList.add(acc);
        }
         system.debug(updateAccountList.size());
        update updateAccountList;
        return [SELECT Id,Name,Route_Id__c,warehouse_Name__c,OwnerName__c FROM Route__c WHERE warehouse__c =:whId ORDER BY Name ASC NULLS FIRST];
        
    }
    @AuraEnabled
    public static List<Account> deleteStores(List<Account> stores) {
        DELETE stores;
        return [SELECT Id,Name,Contact_Person__c,Phone,RouteName__c,WarehouseName__c,Street_Name__c,OwnerName__c,State__c,Store_Category__c,District__c,Grade__c FROM Account ORDER BY Name ASC NULLS FIRST];
        
    }
}