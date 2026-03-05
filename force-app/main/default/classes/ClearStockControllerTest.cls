@isTest
public class ClearStockControllerTest {

     public static testmethod void testVFPage(){
         
         List<Route__c> rut = new List<Route__c>();
         Route__c r = new Route__c();
         r.Name = 'test route';
         rut.add(r);
         insert rut;
         
         Product__c productRec = new Product__c();
         productRec.Name = 'Dev Snacks Rosted peanut';
         productRec.Product_Code__c = 'P100';
         productRec.MRP__c = 25;
         productRec.GST__c = '5';
         insert productRec;
         
         Stock__c stock = new Stock__c();
         stock.Intial_Stock__c = 100;
         stock.Available_Quantity__c = 70;
         stock.Sold_Qty__c = 15;
         stock.Blocked_Quantity__c = 15;
         stock.Product__c = productRec.id;
         stock.Route__c = r.Id;
         Insert stock;
         
         Test.startTest();
         
         Test.setCurrentPage(Page.ClearStock);
         
         ApexPages.StandardSetController sc = new ApexPages.StandardSetController(rut);
         sc.setSelected(rut);
         ClearStockController testAccPlan = new ClearStockController(sc);
         testAccPlan.clearStock();
         
         Test.stopTest(); 
         
     }
    
    public static testmethod void testVFPage2(){
         
         List<Route__c> rut = new List<Route__c>();
         Route__c r = new Route__c();
         r.Name = 'test route';
         rut.add(r);
         insert rut;
         
         Product__c productRec = new Product__c();
         productRec.Name = 'Dev Snacks Rosted peanut';
         productRec.Product_Code__c = 'P100';
         productRec.MRP__c = 25;
         productRec.GST__c = '5';
         insert productRec;
         
         Stock__c stock = new Stock__c();
         stock.Intial_Stock__c = 100;
         stock.Available_Quantity__c = 70;
         stock.Sold_Qty__c = 15;
         stock.Blocked_Quantity__c = 15;
         stock.Product__c = productRec.id;
         stock.Route__c = r.Id;
         Insert stock;
         
         Test.startTest();
         
         Test.setCurrentPage(Page.ClearStock);
         
         ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Route__c>());
         sc.setSelected(new List<Route__c>());
         ClearStockController testAccPlan = new ClearStockController(sc);
         testAccPlan.clearStock();
         
         Test.stopTest(); 
         
     }
}