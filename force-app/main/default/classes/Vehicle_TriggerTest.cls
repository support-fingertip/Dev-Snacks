@isTest
public class Vehicle_TriggerTest 
{
	@isTest
    Public static void Test()
    {
        /*
        Route__c rt = new Route__c();
        rt.Name = 'Route 1';
        insert rt;
        
        Branch__c br = new Branch__c();
        br.Name = 'Branch 1';
        br.Branch_Id__c = 26253;
        br.Account_Id__c = 'ID 2';
        br.Account_Name__c = 'Test Name';
        br.Address__c = 'Mugilpet';
        insert br;*/
        
        Vehicle__c veh = new Vehicle__c();
        veh.Vehicle_Number__c = '12345';
        veh.CompanyId__c = 'Dev';
      //  veh.Code__c = '12345';
        insert veh;
        /*
        Stock_Request__c sr = new Stock_Request__c();
        sr.Request_Date__c = Date.newInstance(2023, 06, 16);
        sr.Branch__c = br.Id;
        sr.Route__c = rt.Id;
        sr.Vehicle__c = veh.Id;
        
        insert sr;*/
    }
}