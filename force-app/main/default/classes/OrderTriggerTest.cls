@isTest
public class OrderTriggerTest {
    public static testmethod void testOrder(){
        Order__c ord = new Order__c();
        ord.Order_Date__c = system.today();
        insert ord;
    }

}