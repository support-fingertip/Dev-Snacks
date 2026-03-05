@isTest
public class schedulerEndDayTest {
    Public static testmethod void endDayMethod(){
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
        
        
         DailyLog__c dl = new DailyLog__c();
         dl.Clock_In__c = system.now();
         dl.Clock_In_Location__Latitude__s = 23.733732;
         dl.Clock_In_Location__Longitude__s = 69.859741;
         insert dl;
        
        schedulerEndDay schBatch = new schedulerEndDay();
        Database.executebatch(schBatch);
    }
}