@isTest
public class deleteVisitFilesTest {
    @isTest
    public static void test1(){
        
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.EId__c = 'S25321252hsb2';
        acc.CompanyId__c = 'Dev';
        insert acc;
        
        Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c=acc.id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Status__c = 'Planned';
        vst2.Comments__c = 'Reachndhd';
    	insert vst2;  
        
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = Blob.valueOf('string');
        ContVerFile.Title = 'title'; 
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient='title.csv';
        ContVerFile.FirstPublishLocationId = vst2.Id;
        insert ContVerFile;
        system.debug('ContVerFile=== '+ContVerFile);
        Test.setCreatedDate(ContVerFile.Id, DateTime.now().addDays(-70));    
        
        Test.startTest();
        deleteVisitFiles deleteFiles = new deleteVisitFiles();
        String scheduleTime = '0 0 0 1 * ?'; 
        system.schedule('Test Territory Check', scheduleTime, deleteFiles); 
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :ContVerFile.id]);
        Test.stopTest();
    }
}