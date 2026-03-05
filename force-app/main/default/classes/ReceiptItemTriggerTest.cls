@isTest
public class ReceiptItemTriggerTest 
{
	@isTest
    Public static void Test()
    {
        Account acc=new Account();
        acc.Name='testaccount1';
        acc.Phone = '9985542322';
        acc.Email__c = 'test@gmail.com';
        acc.CardType__c = 'C';
        acc.CompanyId__c = 'Dev';
      	acc.OwnerId = UserInfo.getUserId();
        acc.Approval_Status__c='Approved';
        insert acc;
         acc.Approval_Status__c='Approved';
        update acc;
        
        Receipt__c rec = new Receipt__c();
        rec.Type__c = 'On Account';
        rec.Customer__c = acc.Id;
        rec.On_Account_Value__c = 200;
        rec.Amount__c=100;
        insert rec;

        Route__c routeRec = new Route__c();
        routeRec.Name = 'Kannur Route';
        routeRec.Route_Id__c = 'RI-01000';
        routeRec.Week_Sales__c = 'SUN';
        //routeRec.Week__c = 'First Week';
        insert routeRec;
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c();
        salInvoice.Route__c = routeRec.Id;
        salInvoice.Doc_Date__c = system.today();
        salInvoice.Tax_Date__c = system.today();
        salInvoice.Customer__c = acc.id;
        insert salInvoice;
        
     
         Receipt_Item__c recpItem = new Receipt_Item__c();
        recpItem.Receipt__c = rec.Id;
        recpItem.Sales_Invoice__c = salInvoice.Id;
        recpItem.Amount__c = 200;
        insert recpItem;
        
       recpItem.Amount__c = 300;
        update recpItem;
       
    }
    	@isTest
    Public static void Test2()
    {
        Account acc=new Account();
        acc.Name='testaccount1';
        acc.Phone = '9985542322';
        acc.Email__c = 'test@gmail.com';
        acc.CardType__c = 'C';
        acc.CompanyId__c = 'Dev';
      	acc.OwnerId = UserInfo.getUserId();
        acc.Approval_Status__c='Approved';
        insert acc;
         acc.Approval_Status__c='Approved';
        update acc;
        
      
        Route__c routeRec = new Route__c();
        routeRec.Name = 'Kannur Route';
        routeRec.Route_Id__c = 'RI-01000';
        routeRec.Week_Sales__c = 'SUN';
        //routeRec.Week__c = 'First Week';
        insert routeRec;
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c();
        salInvoice.Route__c = routeRec.Id;
        salInvoice.Doc_Date__c = system.today();
        salInvoice.Tax_Date__c = system.today();
        salInvoice.Customer__c = acc.id;
        insert salInvoice;
        
          Receipt__c rec1 = new Receipt__c();
        rec1.Type__c = 'Against Invoice';
        rec1.Customer__c = acc.Id;
        rec1.Sales_Invoice__c = salInvoice.Id;
        rec1.Amount__c=100;
        insert rec1;
        
  
    }
    	@isTest
    Public static void Test3()
    {
        Account acc=new Account();
        acc.Name='testaccount1';
        acc.Phone = '9985542322';
        acc.Email__c = 'test@gmail.com';
        acc.CardType__c = 'C';
        acc.CompanyId__c = 'Dev';
      	acc.OwnerId = UserInfo.getUserId();
        acc.Approval_Status__c='Approved';
        insert acc;
         acc.Approval_Status__c='Approved';
        update acc;
        
        Receipt__c rec = new Receipt__c();
        rec.Type__c = 'On Account';
        rec.Customer__c = acc.Id;
        rec.On_Account_Value__c = 200;
        rec.Amount__c=100;
        insert rec;

        Route__c routeRec = new Route__c();
        routeRec.Name = 'Kannur Route';
        routeRec.Route_Id__c = 'RI-01000';
        routeRec.Week_Sales__c = 'SUN';
        //routeRec.Week__c = 'First Week';
        insert routeRec;
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c();
        salInvoice.Route__c = routeRec.Id;
        salInvoice.Doc_Date__c = system.today();
        salInvoice.Tax_Date__c = system.today();
        salInvoice.Customer__c = acc.id;
        insert salInvoice;
      
        
         Receipt_Item__c recpItem = new Receipt_Item__c();
        recpItem.Receipt__c = rec.Id;
        recpItem.Sales_Invoice__c = salInvoice.Id;
        recpItem.Amount__c = 200;
        insert recpItem;
        
   
        delete recpItem;
    }
}