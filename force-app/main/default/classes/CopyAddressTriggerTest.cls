@isTest
public class CopyAddressTriggerTest 
{
	@isTest
    public static void TestTrigger()
    {
          Account testAccount1 = new Account(
            Name = 'Test Account 1',
            Approval_Status__c = 'Approved',
            CompanyId__c = 'Dev'
        );
        insert testAccount1;
        
        
        Address__c add1 = new Address__c();
		add1.Customer__c = testAccount1.id; 
        add1.Address__c = 'Church Street';
        add1.Address_Type__c = 'B';
        add1.Block__c = 'Test';
        add1.Building__c = 'Test';
        add1.City__c = 'Test';
        add1.Country__c = 'IN';
        add1.District__c = 'Bagalkot';
        add1.GST_No__c = '1ZDJMPA0010AQAZ';
        add1.RowNum__c = 2;
        add1.State__c = 'KT';
        add1.Street__c = 'Street';
        add1.Street_No__c = 'Street No';
        add1.ZipCode__c = 000000;
        insert add1;
       
        
        Address__c add2 = new Address__c();
        add2.Address_Type__c ='S';
        add2.Same_as_Billing_Address__c = true;
        add2.Customer__c = testAccount1.id;
        insert add2;
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
    }
}