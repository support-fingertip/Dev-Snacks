@isTest
public class MsgControllerTest {

    public static testmethod void testMsg(){
        Account acc=new Account();
        acc.Name='testbccount12';
        acc.Phone = '9984527722';
        acc.Contact_Person__c = 'test';
        acc.Store_Category__c = 'Hyper market';
        acc.Grade__c = 'A';
        acc.CompanyId__c = 'Dev';
        insert acc;
        
        MsgController.checkAddresses(acc.Id);
        
        Address__c add = new Address__c();
        add.Address__c = '2234234234';
        add.Address_Type__c = 'B';
        add.Customer__c = acc.Id;
        add.Country__c = 'IN';
        add.State__c = 'GJ';
        add.District__c = 'Kutch';
        add.GST_No__c = 'GH2334663222NKK';
        insert add;
        
        MsgController.checkAddresses(acc.Id);
        
        add.Address_Type__c = 'S';
        update add;
        
        MsgController.checkAddresses(acc.Id);
        
        
    }
}