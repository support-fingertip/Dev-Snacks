@isTest
public class userRoutesControllerTest {
    public static testmethod void testusermethod(){
         Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        List<Route__c> rut = new List<Route__c>();
        Route__c r = new Route__c();
        r.warehouse__c = wh.id;
        r.Name = 'test route';
        rut.add(r);
        insert rut;
       List<Account> acLIst = new List<Account>();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.Store_Category__c = 'Hyper market';
        acc.Grade__c = 'A';
        acc.EId__c = 'S25321252hsb2';
        acc.CompanyId__c = 'Dev';
      	acc.OwnerId = UserInfo.getUserId();
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        acc.warehouse__c = rut[0].warehouse__c;
        acc.routes__c = rut[0].id;
        acLIst.add(acc);
        insert acLIst;
        test.startTest();
        userRoutesController.getUserList();
        userRoutesController.getRouteList(userinfo.getUserId());
        userRoutesController.getStoreList(rut[0].id);
        userRoutesController.fetchaAllStore();
        userRoutesController.deleteStores(acLIst);
        userRoutesController.fetchaWarehouses();
        userRoutesController.fetchRouteNames(wh.Id);
        userRoutesController.changeRouteOwner(rut,wh.Id,userinfo.getUserId()); 
        test.stopTest();
    }
}