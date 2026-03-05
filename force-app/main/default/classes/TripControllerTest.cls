@isTest
Public class TripControllerTest 
{
	@isTest
    Public static void Test()
    {
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
            LocaleSidKey = 'en_US' );
        insert testUser;
		
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.CompanyId__c = 'Dev';
        acc.Cash_Discount__c = 1;
        insert acc;
        
        Route__c rt = new Route__c();
        rt.Name = 'Route 1';
        insert rt;
        
        Trip__c tr = new Trip__c();
        tr.Route__c = rt.id;
        tr.Last_Cleared_Date__c = System.today();
        tr.End_Date__c = null;
        tr.End_KM__c = 0.00;
        tr.End_Location__Latitude__s = null;
        tr.End_Location__Longitude__s = null;
        tr.Status__c = 'Started';
        tr.Cash_In_Hand__c = 200;
		insert tr;
        
        List<Visit__c> visitList = new List<Visit__c>();
        Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c= acc.id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Eid__c = 'mnh25ad221a5';
        vst2.Status__c = 'Planned';
        vst2.Comments__c = 'Reachndhd';
        visitList.add(vst2);
        insert visitList;
        
        list<DailyLog__c> dllist = new list<DailyLog__c>();
        DailyLog__c dl = new DailyLog__c();
        dl.Clock_In__c = system.now();
        dl.Clock_In_Location__Latitude__s = 23.733732;
        dl.Clock_In_Location__Longitude__s = 69.859741;
        dllist.add(dl);
        insert dllist;
                
        TripController.getTripData();
        TripController.getTodaysVisits();
        TripController.getDailyLog();
        TripController.upsertTrip(tr);
    }
}