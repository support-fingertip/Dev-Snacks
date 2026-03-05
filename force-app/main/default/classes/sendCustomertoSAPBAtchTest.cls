@isTest
public class sendCustomertoSAPBAtchTest {
    
    @isTest static void testCallout() {
        List<Account> acLIst = new List<Account>();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.Store_Category__c = 'Hyper market';
        acc.Grade__c = 'A';
        acc.CompanyId__c = 'Dev';
        acc.OwnerId = UserInfo.getUserId();
        acc.Credit_period__c = 10;
       
        acLIst.add(acc);
        insert acLIst;
         acc.Approval_Status__c = 'Approved';
        update acc;
        
        Address__c addr = new Address__c();
        addr.Customer__c = acc.Id;
        addr.Address__c = 'test';
        addr.Country__c = 'IN';
        addr.State__c = 'KL';
        addr.District__c = 'Ernakulam';
        addr.City__c = 'test';
        addr.Address_Type__c = 'B';
        insert addr;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        sendCustomertoSAPBAtch bs = new sendCustomertoSAPBAtch();
        
        Test.startTest();
        database.executeBatch(bs,200);
        Test.stopTest();
    }
}