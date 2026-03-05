@isTest
public class ConvertToInvoiceControllerTest {
    @isTest
    public static void TestConvertToInvoiceController(){
        
        Vehicle__c vh = new Vehicle__c();
        vh.Vehicle_Number__c = '100';
        
        insert vh;
        if(vh.id != null){
           // vh.Code__c = vh.Name;
            update vh;
        }

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
      
        acLIst.add(acc);
        insert acLIst;
        
         Visit__c vst = new Visit__c();
        vst.Actual_Start_Time__c = system.now();
        vst.Account1__c=acLIst[0].id;
        vst.Planned_Start_Time__c = system.now();
        vst.Status__c = 'Planned';
        vst.Comments__c = 'Reachndhd';
        //vst.New_Beat__c = nbn.id;
      
        insert vst;
        
        Sales_Order__c so = new Sales_Order__c();
        so.Customer__c = acc.id;
        insert so;
        
        Sales_Order__c so1 = new Sales_Order__c();
        so1.Status__c = 'New';
        so1.Customer__c = acc.Id;
        so1.Route__c = rut.Id;
        so1.Visit__c = vst.Id;
        so1.Warehouse__c = wh.Id;
        so1.Vehicle__c = vh.Id;
        insert so1;
      
        Branch__c br = new Branch__c();
        br.Name = 'tesbranch';
        br.Address__c = 'Bengaluru';
        br.Branch_Id__c = 453647;
        br.Account_Id__c = 'AccountId';
        br.Account_Name__c = 'Acc';
        insert br;
        Stock_Request__c sr = new Stock_Request__c();
        sr.Branch__c = br.Id;
        //sr.Vehicle__c = vh.id;
        sr.Route__c = rut.id;
        sr.Request_Date__c = Date.NewInstance(2022,03,09);
        
        insert sr;
        
        Sales_order_item__c soItem = new Sales_order_item__c();
        //soItem. Sales_order__c = so1.id;
        
        	ConvertToInvoiceController.getSalesOrderRecord(so.Id);
         //   ConvertToInvoiceController.checkCreditPeriod(so1.Id);
            ConvertToInvoiceController.createInvoice(so.Id);
            //ConvertToInvoiceController.createInvoiceItems
            ConvertToInvoiceController.testcover();
    }

}