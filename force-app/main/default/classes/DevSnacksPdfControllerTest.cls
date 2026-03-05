@isTest
public class DevSnacksPdfControllerTest {
    
    public static testmethod void testLedger(){
        
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
    	acc.CompanyId__c = 'Dev';
        insert acc;
        
        Branch__c br = new Branch__c();
        br.Name = 'BR1';
        br.Cash_In_Hand__c = 100000;
        insert br;
        
        Route__c rt = new Route__c();
        rt.Name = 'RT1';
        insert rt;
        
        Receipt__c rec = new Receipt__c();
        rec.Branch__c = br.Id;
        rec.Mode_of_payment__c = 'Cash';
        rec.Customer__c = acc.Id;
        rec.Amount__c = 2000;
        rec.Route__c = rt.Id;
        insert rec;
        
        Return__c ret = new Return__c();
        ret.Customer__c = acc.id;
        insert ret;
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c();
        salInvoice.Name = 'Test';
        salInvoice.Route__c = rt.Id;
        salInvoice.Doc_Date__c = system.today();
        salInvoice.Tax_Date__c = system.today();
        salInvoice.Customer__c = acc.id;
        salInvoice.Invoice_Date__c  = Date.newInstance(2023, 05, 21);
        salInvoice.Payment_Type__c = 'Immediate';
        insert salInvoice;
        
        Test.startTest();
        PageReference pageRef = Page.DevSnacksPDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id',acc.Id );
        ApexPages.currentPage().getParameters().put('from', String.valueOf(System.today()) );
        ApexPages.currentPage().getParameters().put('to', String.valueOf(System.today())  );
        
        DevSnacksPDFController b = new DevSnacksPDFController();
        
        ApexPages.currentPage().getParameters().put('Id',rt.Id );
        ApexPages.currentPage().getParameters().put('from', String.valueOf(System.today()) );
        ApexPages.currentPage().getParameters().put('to', String.valueOf(System.today())  );
        
        DevSnacksPDFController b2 = new DevSnacksPDFController();
        Test.stopTest();
        
    } 

}