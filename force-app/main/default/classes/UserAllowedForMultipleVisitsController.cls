public without sharing class UserAllowedForMultipleVisitsController {

     @AuraEnabled
    public static List<User> getAllUsers(){
        return [SELECT Id,Name,Username,Profile.Name,Manager.Name,Allow_Multiple_Visits__c FROM User Where isActive = true and (Profile.Name='Sales Executive' Or Profile.Name='Van Executive')  ORDER BY NAME ASC];
    }
    
    @AuraEnabled
    public static boolean allowMultipleVisits(String userId,Boolean toggleVal){
       system.debug('toggleVal== '+toggleVal);
        User userRec = [select Id,Name,Username,Profile.Name,Allow_Multiple_Visits__c from User
                       where Id =: userId Limit 1];
        if(userRec.Allow_Multiple_Visits__c != toggleVal){
            userRec.Allow_Multiple_Visits__c = toggleVal;
            update userRec;
        }
        return toggleVal;
    }
}