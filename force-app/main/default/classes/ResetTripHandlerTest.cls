@isTest
public class ResetTripHandlerTest {
    @isTest
    public static void testTesetTripHandler(){
        
        string id = UserInfo.getUserId();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.CompanyId__c = 'Dev';
        acc.Cash_Discount__c = 1;
        insert acc;
        Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        List<Route__c> rut = new List<Route__c>();
        Route__c r = new Route__c();
        r.warehouse__c = wh.id;
        r.Name = 'test route';
        rut.add(r);
        insert rut;
        
        //Vehicle__c vh = new Vehicle__c();
        //vh.Vehicle_Number__c = '23';
        //insert vh;
        Branch__c br = new Branch__c();
        br.Name = 'tesbranch';
        br.Address__c = 'Bengaluru';
        br.Branch_Id__c = 453647;
        br.Account_Id__c = 'AccountId';
        br.Account_Name__c = 'Acc';
        insert br;
        Vehicle__c veh = new Vehicle__c();
        veh.Vehicle_Number__c = '12345';
        veh.CompanyId__c = 'Dev';
       // veh.Code__c = '12345';
        insert veh;
        Route__c routeRec = new Route__c();
        routeRec.Name = 'Kannur Route';
        routeRec.Route_Id__c = 'RI-01000';
        routeRec.Week_Sales__c = 'SUN';
        routeRec.Branch_Name__c = br.id;
        routeRec.Warehouse__c =  wh.id;
        routeRec.Vehicle__c = veh.id;
        //routeRec.Week__c = 'First Week';
        insert routeRec;
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'system administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US' ,
        Route_Id__c = routeRec.Route_Id__c);
        insert testUser;
        List<Trip__c> trlist = new List<Trip__c>();
        for(integer i=0; i<5; i++){
            Trip__c tr = new Trip__c();
            tr.Route__c = routeRec.id;
            tr.Last_Cleared_Date__c = System.today();
            tr.End_Date__c = null;
            tr.End_KM__c = 0.00;
            tr.End_Location__Latitude__s = null;
            tr.End_Location__Longitude__s = null;
            tr.Status__c = 'Started';
            trlist.add(tr);
            
        }
        
        insert trlist;
        
        if(trlist.size()>0){
            update trlist;
        }
        
        ResetTripHandler.loadData();
        ResetTripHandler.resetUserTrip(testUser.id);
    }

}