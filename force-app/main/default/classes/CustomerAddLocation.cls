public class CustomerAddLocation {

    @AuraEnabled
    public static Account gettingOutlet(String recordId){
        system.debug('accountId: '+recordId);
        Account account = new Account();
        account = [select id,Name,Approval_Status__c,GeoLocation__c,Geolocation_Approval__c,GeoLocation__Latitude__s,GeoLocation__Longitude__s from Account where id=:recordId];
        system.debug('account rec : '+account);
        return account;
    }
    @AuraEnabled
    Public static string updateOutlet(string outId, decimal lat,decimal longi){
        string message;
        system.debug('Account Id : '+outId);
        system.debug('lat: '+lat);
        system.debug('longi: '+longi);
        
        Account account = [select id,Name,GeoLocation__c,GeoLocation__Latitude__s,GeoLocation__Longitude__s,New_Geo_Location__Latitude__s,New_Geo_Location__Longitude__s from Account
                   where id=:outId];
        //try{
            if(Schema.sObjectType.Account.fields.New_Geo_Location__Latitude__s.isUpdateable() && Schema.sObjectType.Account.fields.New_Geo_Location__Longitude__s.isUpdateable()) {
            account.New_Geo_Location__Latitude__s=lat;
            account.New_Geo_Location__Longitude__s=longi;
            }
          system.debug('App:' + Approval.isLocked(account));
                if(Approval.isLocked(account)){
                    Approval.Unlock(account, false);
                }
                system.debug('App:' + Approval.isLocked(account));
            if(Schema.Account.sObjectType.getDescribe().isAccessible() && Schema.Account.sObjectType.getDescribe().isAccessible()){
            update account;
            }
            message = account.Name;
            return message;
        //}
       /* catch(Exception ex){
            message = ex.getMessage();
           // throw new AuraHandledException('Something went wrong: '+ ex.getMessage());
           return message;
        }*/
        
        
    }
}