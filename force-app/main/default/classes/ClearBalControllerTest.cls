@isTest
public class ClearBalControllerTest {
    @isTest
    public static void testClearBalController(){
        Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        Branch__c br = new Branch__c();
        br.Name = 'BR1';
        br.Cash_In_Hand__c = 100000;
        insert br;
        List<Route__c> rut = new List<Route__c>();
        Route__c r = new Route__c();
        r.warehouse__c = wh.id;
        r.Name = 'test route';
        r.Branch_Name__c = br.Id;
        rut.add(r);
        insert rut;
        List<Trip__c> tri = new List<Trip__c>();
        Trip__c tr = new Trip__c();
        tr.Route__c = r.id;
        tr.Status__c = 'Started';
        tr.End_Date__c = null;
        tri.add(tr);
        insert tr;
        
        String sobjectType = 'Trip__c';
        Trip__c tr1 = new Trip__c();
        tr1.Route__c = r.id;
      
        insert tr1;
        
        Trip__c trp = [select id,Name,Route__c,Route__r.Branch_Name__c,Cash_In_Hand__c,Last_Cleared_Date__c from Trip__c where id=:tr1.id];
        system.debug(trp+'dhebchdbchdbcgvcgdfvc');
        
        
            Cash_Transfer__c ct1 = new Cash_Transfer__c();
            ct1.From__c = 'Route';
            ct1.To__c = 'Branch';
            ct1.Route__c = trp.Route__c;
            ct1.Branch__c = trp.Route__r.Branch_Name__c;
            ct1.Amount__c = 566;
            
            insert ct1;
            
            trp.Cash_In_Hand__c = 0;
            trp.Last_Cleared_Date__c = system.today();
            update trp;
            
            Route__c rt4 = new Route__c();
            rt4.Id = trp.Route__c;
            rt4.Cash_In_Hand__c = 0;
            rt4.Last_Cleared_Date__c = system.today();
            update rt4;
            
        
        
        Cash_Transfer__c ct = new Cash_Transfer__c();
            ct.From__c = 'Route';
            ct.To__c = 'Branch';
            ct.Route__c = r.id;
            
            ct.Amount__c = 100;
            
            insert ct;
        ClearBalController.checkBalance(r.id);
        ClearBalController.checkBalance(tr.id);
        
        ClearBalController.clearBalance(r.id);
        ClearBalController.clearBalance(tr.id);
    }

}