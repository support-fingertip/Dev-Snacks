public class expenseBulkApproveController {
    public List<Expense__c> getIDs{set;get;}
   public expenseBulkApproveController(ApexPages.StandardSetController controller){
  getIDs = controller.getSelected();
    }
 public PageReference approveExpenses(){
        List<Id> exids = new List<Id>();
        for(Expense__c exp : getIDs){
            exids.add(exp.id);
            
        }
        Map<String, Object> response = new Map<String, Object>();
   
    	List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
    	List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :exids ];
    	for(ProcessInstanceWorkitem workItem : workItems){
          Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
          req.setWorkitemId(workItem.Id);
          req.setAction('Approve');
          req.setComments('Bulk Approved.');
          requests.add(req);
  }
     
     Approval.ProcessResult[] processResults = Approval.process(requests);
          string u = string.valueOf(URL.getSalesforceBaseUrl().getHost());
     List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Expense__c' and Name='Pending Approvals'];
     String returnUrl = 'https://'+u+'/lightning/o/Expense__c/list?filterName='+listviews[0].id;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
    
            return pgReturnPage;

}
}