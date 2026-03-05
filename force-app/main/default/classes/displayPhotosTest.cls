@isTest
public class displayPhotosTest {
    Public static testmethod void testShowPhotos(){
        displayVisitPhotos.imageBox image = new displayVisitPhotos.imageBox();
        List<Account> accList = new  List<Account>();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.EId__c = 'S25321252hsb2';
        
      	acc.CompanyId__c = 'Dev';
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
        
 ContentVersion contentVersion2 = new ContentVersion(
  Title = 'Penguins',
  PathOnClient = 'Penguins.jpg',
  VersionData = Blob.valueOf('Test Content'),
  IsMajorVersion = true
);
insert contentVersion2;    
List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =: contentVersion2.id];

//create ContentDocumentLink  record 
ContentDocumentLink cdl2 = New ContentDocumentLink();
cdl2.LinkedEntityId = vst2.id;
cdl2.ContentDocumentId = documents2[0].Id;
cdl2.shareType = 'V';
insert cdl2;
        displayVisitPhotos.imagesMethod(vst2.id);
         displayVisitPhotos.deleteImage(cdl.id,vst2.id);
    }

}