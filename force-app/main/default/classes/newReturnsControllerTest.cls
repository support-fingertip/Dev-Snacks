@isTest
public class newReturnsControllerTest {

    public static testmethod void testReturns(){
        User user = [select id,name,Route_Id__c from User where id=:UserInfo.getUserId() limit 1];
        
         Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
    	acc.CompanyId__c = 'Dev';
        insert acc;
        
        Product__c pro = new Product__c();
         pro.Name = 'test';
         insert pro;
        
         Stock__c st = new Stock__c();
         st.Product__c = pro.Id;
        st.Intial_Stock__c = 100;
         insert st;
        
        Sales_Invoice__c si = new Sales_Invoice__c();
         si.Invoice_Date__c = system.today();  
        si.Customer__c = acc.Id;
       insert si;
      
        list<Sales_Invoice_Item__c>upsertlst=new list<Sales_Invoice_Item__c>();
        
        Sales_Invoice_Item__c i =new Sales_Invoice_Item__c();
        i.Total__c=200;
        i.GST_Percentage__c=10;
        i.Product__c=pro.Id;
        i.Stock__c =st.id;
        i.Quantity__c=20;
        i.Unit_Price__c = 30;
        i.Sales_Invoice__c=si.Id;
        i.Discount_Percent__c = 1;
        i.Total_after_discount__c = 200;
        upsertlst.add(i);
        insert upsertlst;
        
        Route__c route = new Route__c();
        route.Route_Id__c = user.Route_Id__c;
        insert route;
            acc.Routes__c=route.Id;
        update acc;
        Return__c ret = new Return__c();
        ret.Return_Date__c = system.today();
        ret.Customer__c = acc.Id;
        ret.Route__c = route.Id;
        ret.Sales_Invoice__c = si.Id;
        ret.Dept_Head__c = UserInfo.getUserId();
        list<Return_Item__c>rilist=new list<Return_Item__c>();
        
        Return_Item__c ri =new Return_Item__c();
        ri.Total__c=200;
        ri.GST_Percentage__c=10;
        ri.Product__c=pro.Id;
        ri.Quantity__c=20;
        ri.Unit_Price__c = 30;
        ri.Sales_Invoice__c=si.Id;
        rilist.add(ri);
        
        Test.startTest();
        ReturnUIController.getCustomerStock(acc.Id);
        ReturnUIController.getDiscounts(acc.Id);
      ReturnUIController.getInvoiceItems(upsertlst[0].Id);
          ReturnUIController.testcover();
         newReturnsController.testcover();
        newReturnsController.getCustomerName(acc.Id);
        newReturnsController.getCustomer(acc.Id);
        newReturnsController.getStock();
        newReturnsController.getDiscounts(acc.Id);
        newReturnsController.getItems(si.id);
        newReturnsController.saveNewReturn(ret, rilist);
        
        Test.stopTest();
    }
}