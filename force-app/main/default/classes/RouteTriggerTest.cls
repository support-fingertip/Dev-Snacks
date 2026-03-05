@istest
public class RouteTriggerTest {
    
     public static  testmethod void saveRecords(){       
         
        Route__c rt =  new Route__c();
        rt.name = 'test';
        rt.ownerid = userinfo.getUserId();
        insert rt;
         
         Account a  = new Account();
         a.ownerid = userinfo.getUserId();
         a.name= 'Test';
         a.Phone  = '9988776655';
         a.Routes__c = rt.id;
         a.CompanyId__c = 'Dev';
         insert a;
          
         User u = new User(
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
         insert u;
         rt.ownerid = u.id;
         update rt;
        
    }
}