@isTest
public class uploaderControllerTest {
    public static testMethod void uploaderTestMethod(){
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.EId__c = 'S25321252hsb2';
        acc.CompanyId__c = 'Dev';
        acc.OwnerId = UserInfo.getUserId();
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        insert acc;
        acc.Approval_Status__c = 'Approved';
        update acc;
        
        Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c=acc.id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Status__c = 'Planned';
        vst2.OwnerId = UserInfo.getUserId();
        vst2.Comments__c = 'Reachndhd';
        insert vst2;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = vst2.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Test.StartTest(); 
        
        PageReference pageRef = Page.Uploader; 
        pageRef.getParameters().put('id', String.valueOf(vst2.Id));
        pageRef.getParameters().put('image', 'Test Content');
        Test.setCurrentPage(pageRef);
        
        UploaderController testAccPlan = new UploaderController();
        testAccPlan.init();
        
        Test.StopTest();
    }
}