@isTest
public class customNewExpenseControllerTest {

    Public static testmethod void testexpense(){
        
        Expense__c exp = new Expense__c();
        exp.Expense_Date__c = system.today();
        exp.TA__c = 100;
        exp.DA__c = 100;
       // exp.Other_Expenses__c = 100;
        exp.Expense_Comments__c = 'test';
        
        Test.startTest();
        customNewExpenseController.dataBox db = new customNewExpenseController.dataBox();
        customNewExpenseController.getDates();
        customNewExpenseController.insertExpense(exp);
        customNewExpenseController.submitapproval(exp.id);
        customNewExpenseController.getExpenseAccount();
        Test.stopTest();
    }
}