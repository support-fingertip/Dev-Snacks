@isTest
public class UpdateBranchClosingBalanceTest {

     public static testmethod void testBranch(){
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.CompanyId__c = 'Dev';
        insert acc;
        
        
        Branch__c br = new Branch__c();
        br.Name = 'BR1';
         br.Cash_In_Hand__c =200000;
        insert br;
        
        Route__c rt = new Route__c();
        rt.Name = 'RT1';
        insert rt;
        
        Cashbook__c cb = new Cashbook__c();
        cb.Opening_Balance__c = 2000;
        cb.Closing_Balance__c = 3000;
        cb.Branch__c = br.id;
        insert cb;
        
        
        Cash_Transfer__c ct = new Cash_Transfer__c();
        ct.From__c = 'Route';
        ct.To__c = 'Branch';
        ct.Branch__c = br.Id;
        ct.Route__c = rt.Id;
        ct.Amount__c = 30000;
        insert ct;
         
          Cash_Transfer__c ct2 = new Cash_Transfer__c();
        ct2.From__c = 'Branch';
        ct2.To__c = 'Route';
        ct2.Branch__c = br.Id;
        ct2.Route__c = rt.Id;
        ct2.Amount__c = 30000;
        insert ct2;
        
        Receipt__c rec = new Receipt__c();
        rec.Branch__c = br.Id;
        rec.Mode_of_payment__c = 'Cash';
        rec.Customer__c = acc.Id;
        rec.Amount__c = 2000;
        insert rec;
        
        Expense__c exp = new Expense__c();
        exp.Select_Expense_Entry__c = 'General Entry';
        exp.Expense_Comments__c = 'Some Comment';
        exp.Branch__c = br.Id;
        exp.Food_Expense__c = 20;
        insert exp;
        
        Test.startTest();
        
        exp.Approval_Status__c = 'Approved';
        update exp;
         database.executeBatch(new UpdateBranchClosingBalance(),100);
         /* UpdateBranchClosingBalance shcloseb = new UpdateBranchClosingBalance();
			String schcloseb = '0 55 23 * * ? *';
			system.schedule('Branch Closing Balance', schcloseb, shcloseb);
		*/        
        Test.stopTest();        
    }
}