@isTest
public class visitTriggerTest {
public static testMethod void movetoNext(){
        List<Account> accList = new  List<Account>();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.EId__c = 'S25321252hsb2';
    	acc.CompanyId__c = 'Dev';
      
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        insert acc;
      	acc.Approval_Status__c = 'Approved';
         update acc;
    
     Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c=acc.id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Status__c = 'Planned';
        vst2.Comments__c = 'Reachndhd';
    	insert vst2;
}
}