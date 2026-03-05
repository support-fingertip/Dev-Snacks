@isTest
public class bulkReassignmentControllerTest {
    
    public static testmethod void testBulkReassignSV(){
        Profile svprofileId = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        
        User svusr = new User(LastName = 'LIVESTON',
                              FirstName='JASON',
                              Alias = 'jliv',
                              Email = 'testdevuser@dev.com',
                              Username = 'testdevuser@dev.com',
                              ProfileId = svprofileId.id,
                              TimeZoneSidKey = 'GMT',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US',
                              Route_Id__c = 'TEST1');
        insert svusr;
        
        
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.Store_Category__c = 'Hyper market';
        acc.Grade__c = 'A';
        acc.CompanyId__c = 'Dev';
        acc.OwnerId = svusr.Id;
        acc.Credit_period__c = 10;
        insert acc;
        
        Test.startTest();
        system.runAs(svusr){
            bulkReassignmentController.getuserdetails();
            List<Account> acclist = bulkReassignmentController.getcustomers(svusr.id);
            bulkReassignmentController.updateOwner(acclist, svusr.id, UserInfo.getUserId());
        }
        
        Test.stopTest();
    }
}