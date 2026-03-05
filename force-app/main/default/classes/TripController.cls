public class TripController {
    
     @AuraEnabled
    public static Trip__c getTripData(){
        List<Trip__c> tripList = [SELECT id,Start_Location__Latitude__s,Start_Location__Longitude__s,End_Location__Latitude__s,End_Location__Longitude__s,Start_Date__c,End_Date__c,Cash_In_Hand__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null )  AND OwnerId =:UserInfo.getUserId() limit 1]; 
        if(tripList.size() == 0){
            return null;
        }else{
            system.debug(tripList[0]);
        } 
        return tripList[0]; 
    }
      @AuraEnabled
    public static List<Visit__c> getTodaysVisits(){    
        List<Visit__c> listVisits =  [SELECT Id,Revisit__c,Account1__r.GeoLocation__Latitude__s,TA_DA_Applicable__c,Account1__r.GeoLocation__Longitude__s,EId__c,Meet_and_greet__c,Placements__c,Checked_expiry__c,Product_introduction__c,presentation__c,marketing_material__c,AccountName__c,Check_In_location__c,Check_out_location__c,CheckedOutLatitude__c,CheckedOutLongitude__c,ClockIn_Latitude__c,Clockin_Longitude__c,Clockout_Longitude__c,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Missed_PostPone_Reason__c,Planned_Start_Time__c,Status__c,Account1__r.Mobile__c,Account1__r.Name from Visit__c where  Planned_Start_Time__c = TODAY  and  OwnerId =:userinfo.getUserId()  ORDER BY status__c asc ]; 
        return  listVisits;    
    }
     @AuraEnabled
    public static DailyLog__c getDailyLog(){
        List<DailyLog__c> clockinClockout = [SELECT id,Name,Driver__r.Name,Sales_Man__r.Name,Sales_Manager__r.Name,Assistant_SalesMan__r.Name from  DailyLog__c  WHERE    Clock_In__c = TODAY AND OwnerId =:UserInfo.getUserId() limit 1]; 
        if(clockinClockout.size() == 0){
            return null;
        }else{
            system.debug(clockinClockout[0]);
        } return clockinClockout[0]; 
    }
    
     @AuraEnabled
    public static Trip__c upsertTrip(Trip__c trip){ 
        system.debug(trip);
        if(trip !=null ){
            User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
            List<Route__c> rt = new List<Route__c>();
            if(user.Route_Id__c != null){
                rt = [select id,Route_Id__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
                if(rt.size() > 0){
                    trip.Route__c = rt[0].Id;
                }
            }
            upsert trip;
        }
        List<Trip__c> tripList = [SELECT id,Start_Location__Latitude__s,Start_Location__Longitude__s,End_Location__Latitude__s,End_Location__Longitude__s,Start_Date__c,End_Date__c,Cash_In_Hand__c from  Trip__c  WHERE   id=:trip.Id AND OwnerId =:UserInfo.getUserId() limit 1]; 
        if(tripList.size() == 0){
            return null;
        }else{
             return tripList[0]; 
        } 
       
    }
    
}