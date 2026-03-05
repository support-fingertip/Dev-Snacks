@isTest
public class CashTransferTriggerTest 
{
	@isTest
    Public static void Test()
    {
       Branch__c br = new Branch__c();
        br.Name = 'BR1';
        br.Cash_In_Hand__c = 200;
        insert br;
        
        Route__c rt = new Route__c();
        rt.Name = 'Route 1';
        insert rt;
        
        // Create a test trip
        Trip__c tr = new Trip__c();
        tr.Route__c = rt.id;
        tr.Cash_In_Hand__c = 100;
        tr.Last_Cleared_Date__c = System.today();
        tr.Status__c = 'Started';
        insert tr;
		system.debug('Trip is - '+tr);
        
        // Create a test daily log
        DailyLog__c dl = new DailyLog__c();
        dl.Clock_In__c = System.Today();
        dl.Clock_In__c = System.today() + 1;
        dl.Trip__c = tr.Id;
        dl.OwnerId = UserInfo.getUserId();
        insert dl;
        
        Cash_Transfer__c ct =  new Cash_Transfer__c();
        ct.From__c = 'Head Office';
        ct.To__c = 'Branch';
        ct.Amount__c = 200;
        ct.Route__c = rt.Id;
        insert ct;
        
        ct.From__c = 'Branch';
        ct.To__c = 'Route';
        update ct;
        
        ct.From__c = 'Branch';
        ct.To__c = 'Head Office';
        ct.Branch__c = br.id;
        update ct;
    }
}