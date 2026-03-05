@istest
public class MasterDetailTest {
    
    public static  testmethod void testgetPickValues (){ 
        MasterDetail.getPickValues('Product__c','ProductFamily__c');
    }
    public static  testmethod void searchRecords(){ 
        MasterDetail.searchRecords('Product__c','Id',''); 
    }
    public static  testmethod void readRecords(){ 
        Order__c o = new Order__c();
        insert o;
        MasterDetail.readRecords( o.id ); 
    }
    public static  testmethod void saveRecords(){ 
        MasterDetail.records r  = new  MasterDetail.records();
        r.accounts = new list<account>();
        r.visits = new list<visit__c>();
        r.orders = new list<order__c>();
        r.order_items = new list<order_item__c>();
        r.products = new list<product__c>();  
         r.invoices = new list<invoice__c>(); 
         r.invoice_items = new list<invoice_item__c>(); 
        
        Order__c o = new Order__c();
        o.EID__c  = (string.valueof( system.now().getTime() )) ;
        insert o;
         
        Route__c rt =  new Route__c();
        rt.name = 'test';
        rt.ownerid = userinfo.getUserId();
        insert rt;
        
        Account a  = new Account();
        a.ownerid = userinfo.getUserId();
        a.name= 'Test';
        a.Phone  = '9988776655';
        a.CompanyId__c = 'Dev';
        a.Routes__c = rt.id;
        a.Approval_Status__c ='Approved';
        r.accounts.add(a);
      
       
        order_item__c oi = new order_item__c();
        oi.EID__c = o.EID__c+'-'+ (string.valueof( system.now().getTime() ));
        r.order_items.add(oi);
        
        product__c p = new product__c();
        p.name= 'test';
        r.products.add(p);
        
        MasterDetail.saveRecords( JSON.serialize( r) ); 
    }
}