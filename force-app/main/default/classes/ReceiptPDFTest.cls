@isTest
public class ReceiptPDFTest {
   
    public static testmethod void testReceiptPDF(){
        
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.CompanyId__c = 'Dev';
        acc.Cash_Discount__c = 1;
        insert acc;
        Route__c routeRec = new Route__c();
        routeRec.Name = 'Kannur Route';
        routeRec.Route_Id__c = 'RI-01000';
        routeRec.Week_Sales__c = 'SUN';
        //routeRec.Week__c = 'First Week';
        insert routeRec;
        
        Sales_Invoice__c salInvoice = new Sales_Invoice__c();
        salInvoice.Route__c = routeRec.Id;
        salInvoice.Doc_Date__c = system.today();
        salInvoice.Tax_Date__c = system.today();
        salInvoice.Customer__c = acc.id;
        insert salInvoice;
        
        Receipt__c rec = new Receipt__c();
        rec.Mode_of_payment__c = 'Cash';
        rec.Customer__c = acc.Id;
        rec.Type__c = 'Against Invoice';
        rec.Amount__c = 200;
        rec.Sales_Invoice__c = salInvoice.id;
		insert rec;
        
        Receipt_Item__c rItem = new Receipt_Item__c();
        rItem.Sales_Invoice__c = salInvoice.id;
        rItem.Receipt__c = rec.id;
        insert rItem;
        Test.startTest();

        PageReference pageRef = Page.ReceiptPDF;
        pageRef.getParameters().put('id', rec.Id);
        Test.setCurrentPage(pageRef);  
        
        ApexPages.StandardController controller = new ApexPages.StandardController(rec);
        ReceiptPDF testAccPlan = new ReceiptPDF(controller);
        
        Test.stopTest();   
    }

}