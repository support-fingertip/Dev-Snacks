public class storeBulkApproveController {
    public List<Account> getIDs{set;get;}
   public storeBulkApproveController(ApexPages.StandardSetController controller){
  getIDs = controller.getSelected();
    }
 public PageReference approveStores(){
        List<Id> accids = new List<Id>();
        for(Account acc : getIDs){
            accids.add(acc.id);
            
        }
        Map<String, Object> response = new Map<String, Object>();
   
    	List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
    	List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :accids ];
    	for(ProcessInstanceWorkitem workItem : workItems){
          Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
          req.setWorkitemId(workItem.Id);
          req.setAction('Approve');
          req.setComments('Bulk Approved.');
          requests.add(req);
  }
     
     Approval.ProcessResult[] processResults = Approval.process(requests);
          string u = string.valueOf(URL.getSalesforceBaseUrl().getHost());
     List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Account' and Name='Pending Approvals'];
     String returnUrl = 'https://'+u+'/lightning/o/Account/list?filterName='+listviews[0].id;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
    
            return pgReturnPage;

}
}