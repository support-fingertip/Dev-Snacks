@isTest
public class CalenderManagerTest {

    public static testMethod void calenderTestMethod(){
    
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

        
        
        
        CalenderManager.accountData accdata = new CalenderManager.accountData();
         CalenderManager.calEvent call = new  CalenderManager.calEvent();
        call.startString = string.valueOf(system.now().addHours(1));
        call.endString = string.valueOf(system.now().addHours(5));
        call.dealerId = acc.id;
        call.ownerId = UserInfo.getUserId();
        call.id= vst2.id;
        CalenderManager.saveVisit(call);
        CalenderManager.listRecords(UserInfo.getUserId(),'test');
        CalenderManager.getRepresentative();
        CalenderManager.showEvents(UserInfo.getUserId(),string.valueOf(system.now()) ,string.valueOf(system.now()));
        CalenderManager.updateVisit(call);
        CalenderManager.deleteEvent(vst2.id);
         CalenderManager.showEvents(UserInfo.getUserId(),string.valueOf(system.now()) ,string.valueOf(system.now()));
        
    }
    
}