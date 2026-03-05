public class ClearStockController {
     public List<Route__c> routeList;
      public boolean isError{get;set;}
    
      // Constructor
      public ClearStockController(ApexPages.StandardSetController cntlr){
           routeList = cntlr.getSelected(); //get selected records from account list view
         
      } 

    public PageReference clearStock(){
        system.debug('routeList:' + routeList);
        
        Profile pr = [select id,name from Profile where Id=:UserInfo.getProfileId() limit 1];
        
        if(pr.Name != 'ADMIN' && pr.Name != 'System Administrator' ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You don\'t have sufficient priviliges. Please Contact Admin.'));
            isError = true;
            return null;
        }
        else{
            if(routeList.size() <= 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No records selected.'));
                isError = true;
                return null;
            }
            else{
               /* List<Stock__c> stlist = [select Id,Name, Intial_Stock__c, Available_Quantity__c, Mismatch_Qty__c, CreatedDate, Route__r.Name from Stock__c where Route__c IN :routeList and Available_Quantity__c != 0];
                  system.debug('stlist:' + stlist);
                for(Stock__c st:stlist){
                    st.Mismatch_Qty__c = st.Available_Quantity__c;
                    st.Available_Quantity__c = 0;
                }
                update stlist; */
           string query ='select Id,Name from Route__c where Id in :routeList';                
            ClearStock_Btach batch = new ClearStock_Btach(query,routeList);
            Database.executeBatch(batch);  // Execute the batch job
                
                return new ApexPages.Action('{!List}').invoke();
            }
        }
       //return null;
       
    }
    
   /*   public PageReference redirectToLC(){
            String returnUrl = '/lightning/cmp/c__ProcessListView?c__listofAccounts='+routeIds;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
          //  return null;
      }*/

}