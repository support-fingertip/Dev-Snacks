@isTest
public class InvoiceNumberSeriesTriggerTest 
{
	@isTest
    Public static void Test()
    {
        
        Route__c testRoute = new Route__c(
            Route_Id__c = 'Route123'
        );
        insert testRoute;
        
        Invoice_Number_Series__c ins2 = new Invoice_Number_Series__c();
        ins2.Start_Number__c = 234;
        ins2.End_Number__c = 346;
        ins2.Route__c = testRoute.Id;
        insert ins2;
        
        
        test.startTest();
        Invoice_Number_Series__c ins = new Invoice_Number_Series__c();
        ins.Start_Number__c = 234;
        ins.End_Number__c = 346;
        ins.Route__c = testRoute.Id;
        insert ins;
        
        system.assertEquals(1, [select id,Start_Number__c,End_Number__c,Route__c,Last_Invoice_Number__c from Invoice_Number_Series__c where id =: ins.Id].Last_Invoice_Number__c);
        
        //system.debug('ins==='+);
        test.stopTest();
        
    }
}