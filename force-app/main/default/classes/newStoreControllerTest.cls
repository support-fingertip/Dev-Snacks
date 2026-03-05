@isTest
public class newStoreControllerTest {
    
    public static testmethod void testnewstore(){
         Warehouse__c wh = new Warehouse__c();
        wh.name = 'test1';
        insert wh;
        Route__c rut = new Route__c();
        rut.warehouse__c = wh.id;
        rut.Name = 'test route1';
        insert rut;
       List<Account> acLIst = new List<Account>();
        Account acc=new Account();
        acc.Name='testbccount12';
        acc.Phone = '9984527722';
        acc.Contact_Person__c = 'test';
        acc.Store_Category__c = 'Hyper market';
        acc.Grade__c = 'A';
        acc.CompanyId__c = 'Dev';
        acc.EId__c = 'S25321252hsb2';
      	acc.OwnerId = UserInfo.getUserId();
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        acc.warehouse__c = rut.warehouse__c;
        acc.routes__c = rut.id;
        acLIst.add(acc);
        insert acLIst;
      	acLIst[0].Approval_Status__c = 'Approved';
         update acLIst;
       
        test.startTest();
         newStoreController.dataBox dbox = new newStoreController.dataBox();
        newStoreController.getwarehouseList();
        newStoreController.getRouteList(wh.id);
        newStoreController.insertAccount(acLIst[0]);
        newStoreController.insertAccount(null);
        //newStoreController.getParentAccount(acc.id);
        //newStoreController.getNotApprovedDuplicateAccount('12ERTYU9876HQZA','9765357974');
        newStoreController.getDuplicateAccount('9765357974');
        newStoreController.checkDuplicateAccountEmail('ndgt@gmail.com');
        newStoreController.getAccountList();
        newStoreController.getCompany();
        newStoreController.getCustomerType();
        newStoreController.getPickListValuesIntoList();
        //newStoreController.submitapproval(acc.Id);
       // newStoreController.submitapproval(acLIst[0].id);
        test.stopTest();
        
    }

}