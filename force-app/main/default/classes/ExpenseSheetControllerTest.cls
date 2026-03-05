@isTest
public class ExpenseSheetControllerTest {
    
    public static testmethod void testExp(){
        Cashbook__c cb = new Cashbook__c();
        cb.Opening_Balance__c = 2000;
        cb.Closing_Balance__c = 3000;
        //cb.CreatedDate = system.today().addDays(-1);
       
        insert cb;
         Test.setCreatedDate(cb.Id, system.today().addDays(-1));
        
        Route__c rt = new Route__c();
        rt.Name = 'RT1';
        insert rt;
        
         Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
    	acc.CompanyId__c = 'Dev';
        insert acc;
        acc.Approval_Status__c = 'Approved';
        update acc;
        
        Receipt__c rec = new Receipt__c();
        rec.Mode_of_payment__c = 'Cash';
        rec.Customer__c = acc.Id;
        rec.Amount__c = 2000;
        rec.Route__c = rt.Id;
        insert rec;
        
          Trip__c tr = new Trip__c();
        tr.Route__c = rt.id;
        tr.Cash_In_Hand__c = 100;
        tr.Last_Cleared_Date__c = System.today();
        tr.Status__c = 'Started';
        insert tr;
		system.debug('Trip is - '+tr);
        
        Employee__c emp = new Employee__c();
        emp.Name = 'test';
        insert emp;
        
        // Create a test daily log
        DailyLog__c dl = new DailyLog__c();
        dl.Clock_In__c = System.Today();
        dl.Trip__c = tr.Id;
        dl.Sales_Man__c = emp.id;
        dl.Route__c = rt.id;
        insert dl;
        
        Expense__c exp = new Expense__c();
        exp.Select_Expense_Entry__c = 'General Entry';
        exp.Expense_Comments__c = 'Some Comment';
        exp.Route__c = rt.Id;
        exp.Food_Expense__c = 20;
        insert exp;
        
        Test.startTest();
        
          exp.Approval_Status__c = 'Approved';
        update exp;
        
        PageReference pageRef = Page.ExpenseSheet;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id',rt.Id );
        ApexPages.currentPage().getParameters().put('from', String.valueOf(System.today().addDays(-2)) );
        ApexPages.currentPage().getParameters().put('to', String.valueOf(System.today())  );
        
        ExpenseSheetController b = new ExpenseSheetController();
        
    
        Test.stopTest();        
    }
    

}