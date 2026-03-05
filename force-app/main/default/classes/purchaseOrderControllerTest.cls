@isTest
public class purchaseOrderControllerTest {
    public static testmethod void testPO(){
         Warehouse__c wa = new Warehouse__c();
        wa.Name = 'test';
        insert wa;
        Warehouse__c wa1 = new Warehouse__c();
        wa1.Name = 'test';
        insert wa1;
		
		vendor__c acc = new vendor__c();
        acc.name = 'test';
        insert acc;
        
        Purchase_Order__c ord1 = new Purchase_Order__c();
        ord1.PO_Date__c =  system.today();
        ord1.Vendor__c = acc.id;
        insert ord1;   
        
        Product__c pr1 = new Product__c();
        pr1.MRP__c = 10;
        insert pr1;
        
        Product__c pr11 = new Product__c();
        pr11.MRP__c = 100;
        insert pr11;
            
        PO_Item__c odritem = new PO_Item__c();
        odritem.Product__c = pr1.id;
        odritem.Ordered_Quantity__c = 2;
        odritem.Unit_Price__c = 10;
        odritem.Purchase_Order__c = ord1.id;
        insert odritem;        
                PO_Item__c odritem1 = new PO_Item__c();
        odritem1.Product__c = pr11.id;
        odritem1.Ordered_Quantity__c = 100;
        odritem1.Unit_Price__c = 100;
        odritem1.Purchase_Order__c = ord1.id;
        insert odritem1;
                        PO_Item__c odritem11 = new PO_Item__c();
        odritem11.Product__c = pr11.id;
        odritem11.Ordered_Quantity__c = 25;
        odritem11.Unit_Price__c = 100;
        odritem11.Purchase_Order__c = ord1.id;
        insert odritem11;
        List<PO_Item__c> poList = new List<PO_Item__c>();
        PO_Item__c odritem12 = new PO_Item__c();
        odritem12.Product__c = pr11.id;
        odritem12.Ordered_Quantity__c = 25;
        odritem12.Unit_Price__c = 100;
        odritem12.Purchase_Order__c = ord1.id;
        poList.add(odritem12);
        test.startTest();
        purchaseOrderController.getdata(ord1.id);
        purchaseOrderController.getproductList();
        purchaseOrderController.getVendorList();
        purchaseOrderController.insertItemList(poList,ord1.id,'PO_Item__c',acc.Id,system.today());
        
    }

}