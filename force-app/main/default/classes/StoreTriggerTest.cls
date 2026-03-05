@isTest
public class StoreTriggerTest {
	public static testMethod void storeTestMethod(){
        List<Account> accList = new  List<Account>();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        insert acc;
        acc.Approval_Status__c = 'Approved';
        update acc;
        acc.Approval_Status__c = 'Rejected';
        update acc;
      	
}
}