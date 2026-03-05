public class ResetTripHandler {
    @AuraEnabled  
    public static List<user> loadData(){  
        List<user> conList = [select Profile.Name,Id,Name,Email from user where IsActive = true and (Profile.Name='Sales Executive' Or Profile.Name='Van Executive')  order by Name asc];  
        return conList;  
    }
    
    @AuraEnabled
    public static string resetUserTrip(Id userId){
        system.debug('userId=== '+userId);
        List<Trip__c> trips = new List<Trip__c>();
        User currentUser = [select Id,Route_Id__c,Name from User where Id =: userId Limit 1];
        Route__c route = [select Id,Route_Id__c,Branch_Name__r.Id,Warehouse__r.Id,Vehicle__r.Id from Route__c where Route_Id__c =: currentUser.Route_Id__c Limit 1];
        List<Trip__c> tripList = [select Id,End_Date__c,End_KM__c,End_Location__c,End_Location__Latitude__s,End_Location__Longitude__s,Route__c,Status__c,Trip_Id__c from Trip__c
                                  where Route__c =: route.Id And CreatedDate = THIS_WEEK];
        system.debug('tripList=== '+tripList);
        for(Trip__c tripRec : tripList){
            tripRec.End_Date__c = null;
            tripRec.End_KM__c = 0.00;
            tripRec.End_Location__Latitude__s = null;
            tripRec.End_Location__Longitude__s = null;
            tripRec.Status__c = 'Started';
            trips.add(tripRec);
        }
        
        if(trips.size()>0){
            update trips;
            system.debug('trips=== '+trips);
            return 'Trip has been restarted sucessfully for '+'"'+currentUser.Name+'"'+'.';
        }
        return '';
    }
}