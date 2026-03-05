@isTest
public class storeBulkApproveTest {
@isTest public static void testApproveMethod(){
        List<account> strList = new List<account>();
    	
    	Warehouse__c wa = new Warehouse__c();
    	wa.Name = 'testt';
    	insert wa;
    
         account stre = new account();
        stre.Name = 'test1';
        stre.Contact_Person__c = 'cperson';
        stre.Phone = '1234567892';
        stre.Store_Category__c = 'super market';
        stre.Grade__c = 'A';
    	stre.CompanyId__c = 'Dev';
    	stre.Pin_code__c = 123456;
    	stre.Warehouse__c = wa.id;
        strList.add(stre);
        insert strList;
      
          List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
          Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
          req.setObjectId(strList[0].id);
          requests.add(req);
    	Approval.ProcessResult[] processResults = Approval.process(requests);
       PageReference pageRef = Page.storebulkApprove;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id',strList[0].id);
		
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(strList);
		stdSetController.setSelected(strList);
		storeBulkApproveController objTest = new storeBulkApproveController(stdSetController); 
		
		Test.startTest();
		objTest.approveStores();
		Test.stopTest();
        
    }
}