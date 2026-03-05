@isTest
public class UpdateCustClosingBalanceTest {

    @isTest
    Public static void Test1()
    {
        Account account = new Account();
        account.Name = 'Test acc';
        account.Approval_Status__c = 'Approved';
        account.Phone = '9966332255';
        account.Pan_Number__c = 'ASDFA1234E';
        account.CompanyId__c = 'Eva';
        account.CardType__c = 'c';
        account.CustomerGroupCode__c = '100';
        account.Account_Status__c = 'Approved';
        insert account;
        
        Customer_Cashbook__c custCashbook = new Customer_Cashbook__c();
        custCashbook.Customer__c = account.id;
        insert custCashbook;
        
        Test.startTest();
        UpdateCustClosingBalance obj = new UpdateCustClosingBalance();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, obj); 
        //DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}