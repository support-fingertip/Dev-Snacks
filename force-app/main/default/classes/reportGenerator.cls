public class reportGenerator {

     @auraEnabled
    public static List<Route__c> getRoutes() {
        
        return [select Id,Name from Route__c];
    }
}