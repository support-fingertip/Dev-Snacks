@isTest
Public class UpdateRouteOpeningBalanceTest 
{
	@isTest
    Public static void Test()
    {
        Branch__c br = new Branch__c();
        br.Name = 'tesbranch';
        br.Address__c = 'Bengaluru';
        br.Branch_Id__c = 453647;
        br.Account_Id__c = 'AccountId';
        br.Account_Name__c = 'Acc';
        insert br;
        
        Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        
        Route__c rt = new Route__c();
        rt.Name = 'RT1';
        insert rt;
        
        Cashbook__c cb = new Cashbook__c();
        cb.Opening_Balance__c = 2000;
        cb.Closing_Balance__c = 3000;
        cb.Branch__c = br.id;
        cb.Route__c = rt.Id;
        insert cb;
        Test.setCreatedDate(cb.Id, DateTime.now().addDays(-1));
        
        Test.startTest();
        database.executeBatch(new UpdateRouteOpeningBalance(),100);
        Test.stopTest();
        
        
    }
    @isTest
    Public static void Test2()
    {
        Branch__c br = new Branch__c();
        br.Name = 'tesbranch';
        br.Address__c = 'Bengaluru';
        br.Branch_Id__c = 453647;
        br.Account_Id__c = 'AccountId';
        br.Account_Name__c = 'Acc';
        insert br;
        
        Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        
        Route__c rt = new Route__c();
        rt.Name = 'RT1';
        insert rt;
        
        Cashbook__c cb = new Cashbook__c();
        cb.Opening_Balance__c = 2000;
        cb.Closing_Balance__c = 3000;
        cb.Branch__c = br.id;
        cb.Route__c = rt.Id;
        insert cb;
        //Test.setCreatedDate(cb.Id, DateTime.now().addDays(-1));
        
        Test.startTest();
        database.executeBatch(new UpdateRouteOpeningBalance(),100);
        Test.stopTest(); 
    }
}