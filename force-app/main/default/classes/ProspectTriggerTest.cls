@isTest
public class ProspectTriggerTest {

    public static testmethod void  testprospect(){
        Prospect__c prs = new Prospect__c();
        prs.Name = 'test';
        insert prs;
        prs.Status__c = 'Closed won';
        
        try{
            update prs;
        }catch(Exception e){
              
            system.debug(e.getMessage());
            System.assert(e.getMessage().contains('Please click on convert button to convert prospect'));
        }
    }
}