@isTest
public class LightningFileUploadHandlerTest {
    Public static testmethod void testfileupload(){
        
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.EId__c = 'S25321252hsb2';
      	acc.CompanyId__c = 'Dev';
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        insert acc;
       
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
cdl.LinkedEntityId = acc.id;
cdl.ContentDocumentId = documents[0].Id;
cdl.shareType = 'V';
insert cdl;
         LightningFileUploadHandler.getFiles(acc.id);
    LightningFileUploadHandler.deleteFile(documents[0].Id);
    }
  
}