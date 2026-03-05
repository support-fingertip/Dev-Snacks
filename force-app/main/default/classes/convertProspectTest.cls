@isTest
public class convertProspectTest {
	 public static testmethod void  testprospect(){
        Prospect__c prs = new Prospect__c();
        prs.Name = 'test';
         prs.Mobile__c = '9876543210';
         prs.Company__c = 'Dev';
        insert prs;
        test.startTest();
        convertProspect.convertLead(prs.Id);
         test.stopTest();
    }
}