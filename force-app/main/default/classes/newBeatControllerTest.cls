@isTest
public class newBeatControllerTest {
    Public static testmethod void testnewbeat(){
        
        Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        Route__c rut = new Route__c();
        rut.warehouse__c = wh.id;
        rut.Name = 'test route';
        insert rut;
       List<Account> acLIst = new List<Account>();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.EId__c = 'S25321252hsb2';
        acc.CompanyId__c = 'Dev';
      	acc.OwnerId = UserInfo.getUserId();
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        acc.warehouse__c = rut.warehouse__c;
        acc.routes__c = rut.id;
        acLIst.add(acc);
        insert acLIst;
      	acLIst[0].Approval_Status__c = 'Approved';
         update acLIst;
        
        New_Beat__c nbn = new New_Beat__c();
        nbn.warehouse__c = rut.warehouse__c;
        nbn.routes__c = rut.id;
        nbn.Beat_Date__c = system.today();
        insert nbn;
        List<visit__c> vList = new List<visit__c>();
         Visit__c vst = new Visit__c();
        vst.Actual_Start_Time__c = system.now();
        vst.Account1__c=acLIst[0].id;
        vst.Planned_Start_Time__c = system.now();
        vst.Status__c = 'Planned';
        vst.Comments__c = 'Reachndhd';
        vst.New_Beat__c = nbn.id;
       vList.add(vst);
        insert vList;
        
        Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c=acLIst[0].id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Status__c = 'Planned';
        vst2.Comments__c = 'Reachndhd';
    	
        
        
       Test.startTest();
            newBeatController.getUserList();
        newBeatController.getRouteList(userinfo.getUserId());
        newBeatController.getStoreList(userinfo.getUserId(),rut.id);
        newBeatController.getbeatList(userinfo.getUserId(),rut.id);
        newBeatController.getvisitList(nbn.id);
        newBeatController.createBeat(userinfo.getUserId(),acLIst,system.today(),rut.id);
        newBeatController.createnewBeat(userinfo.getUserId(),vList,system.today(),rut.id);
        newBeatController.getupcominbeats(userinfo.getUserId());
        newBeatController.changeVisitOwner(userinfo.getUserId(),vList,userinfo.getUserId(),nbn.id);
        Test.stopTest();   
            
            
        
    }
}