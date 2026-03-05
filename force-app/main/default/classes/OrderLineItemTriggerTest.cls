@isTest
public class OrderLineItemTriggerTest {
    public static testmethod void testItem(){
        Order__c ord = new Order__c();
        ord.Order_Date__c = system.today();
        insert ord;
         product__c p = new product__c();
        p.name= 'test';
        insert p;
        
        Order_Item__c item = new Order_Item__c();
        item.Order__c = ord.id;
        item.Product__c = p.Id;
        item.Quantity__c = 2;
        insert item;
        
    }

}