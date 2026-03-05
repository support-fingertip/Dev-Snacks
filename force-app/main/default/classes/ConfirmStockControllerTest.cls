@isTest
public class ConfirmStockControllerTest {
    @isTest
    public static void testConfirmStockController(){
        
        Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        List<Route__c> rut = new List<Route__c>();
        Route__c r = new Route__c();
        r.warehouse__c = wh.id;
        r.Name = 'test route';
        rut.add(r);
        insert rut;
        
        //Vehicle__c vh = new Vehicle__c();
        //vh.Vehicle_Number__c = '23';
        //insert vh;
        Branch__c br = new Branch__c();
        br.Name = 'tesbranch';
        br.Address__c = 'Bengaluru';
        br.Branch_Id__c = 453647;
        br.Account_Id__c = 'AccountId';
        br.Account_Name__c = 'Acc';
        insert br;
        
        Product__c productRec = new Product__c();
        productRec.Name = 'Dev Snacks Rosted peanut';
        productRec.Product_Code__c = 'P100';
        productRec.MRP__c = 25;
        productRec.GST__c = '5';
        insert productRec;
        
        Stock_Request__c sr = new Stock_Request__c();
        sr.Branch__c = br.Id;
        //sr.Vehicle__c = vh.id;
        sr.Route__c = r.id;
        sr.Request_Date__c = Date.NewInstance(2022,03,09);
        sr.Godown_Manager__c = Userinfo.getUserId();
        insert sr;
        
        List<Stock_Request_Item__c> srtList = new List<Stock_Request_Item__c>();
        Stock_Request_Item__c srt = new Stock_Request_Item__c();
        srt.Name = 'Masala';
        srt.Batch_Number__c = 'ABC23';
        srt.MRP__c = 100;
        srt.Manufacturing_Date__c = system.today();
        srt.Received_Qunatity__c = 100;
        srt.Product__c = productRec.Id;
        srt.Stock_Request__c = sr.id;
        srtList.add(srt);
        insert srt;
        
        
        ConfirmStockController.getUIThemeDescription();
        ConfirmStockController.getStock(sr.id);
        ConfirmStockController.checkStatus(sr.id);
        ConfirmStockController.rejectNewRequest(srtList,sr.id );
        ConfirmStockController.saveNewRequest(srtList,sr.id );
        
        ConfirmStockController.saveNewRequest(srtList,sr.id );
    }

}