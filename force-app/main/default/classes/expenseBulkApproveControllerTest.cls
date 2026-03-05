@isTest
public class expenseBulkApproveControllerTest {

    public static testmethod void testApproveMethod(){
        List<Expense__c> expList = new List<Expense__c>();
         Expense__c exp = new Expense__c();
        exp.Expense_Date__c = system.today();
        exp.TA__c = 100;
        exp.DA__c = 100;
        //exp.Other_Expenses__c = 100;
        exp.Expense_Comments__c = 'test';
        expList.add(exp);
        insert expList;
      
          List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
          Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
          req.setObjectId(expList[0].id);
          requests.add(req);
    	Approval.ProcessResult[] processResults = Approval.process(requests);
       PageReference pageRef = Page.expensebulkApprove;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id',expList[0].id);
		
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(expList);
		stdSetController.setSelected(expList);
		expenseBulkApproveController objTest = new expenseBulkApproveController(stdSetController); 
		
		Test.startTest();
		objTest.approveExpenses();
		Test.stopTest();
        
    }
}