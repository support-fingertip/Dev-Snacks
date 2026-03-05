@isTest
public class EmployeeTrackerTest {
    public static testMethod void EmployeeTestMethod(){
        
       EmployeeTracker.userWrap usw = new EmployeeTracker.userWrap();
       EmployeeTracker.showSummeryCount(string.valueOf(system.today()),UserInfo.getUserId(),23.7337320,69.859741);

          Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.EId__c = 'S25321252hsb2';
      	acc.OwnerId = UserInfo.getUserId();
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        acc.CompanyId__c = 'Dev';
        insert acc;
      	acc.Approval_Status__c = 'Approved';
         update acc;
        
         Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c=acc.id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Status__c = 'Planned';
        vst2.OwnerId = UserInfo.getUserId();
        vst2.Comments__c = 'Reachndhd';
    	insert vst2;
        EmployeeTracker.getUserList();
        EmployeeTracker.showSummeryCount(string.valueOf(system.today()),UserInfo.getUserId(),23.7337320,69.859741);
        EmployeeTracker.showMeeting(string.valueOf(23.7337320),string.valueOf(69.859741),string.valueOf(system.today()),UserInfo.getUserId());
         EmployeeTracker.getClockInClockOut();

    }
}