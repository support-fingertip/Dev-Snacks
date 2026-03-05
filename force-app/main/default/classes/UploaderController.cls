global without sharing class UploaderController {
    public string imageData{get; set;}
    public string cropped{get; set;}
    public string headers {get; set;}
    public string response{get; set;}
    
    public void init() { 
        
        system.debug(ApexPages.currentPage().getParameters().get('id'));
        if ( ApexPages.currentPage().getParameters().get('id') != null )
            
            try{
                imageData = ApexPages.currentPage().getParameters().get('image');
                
                
                /*    cropped = ApexPages.currentPage().getParameters().get('cropped');
system.debug(ApexPages.currentPage().getheaders());
Attachment attachment = new Attachment();

if(cropped == 'true'){
attachment.Name = ApexPages.currentPage().getParameters().get('id');
}else{
attachment.Name = ApexPages.currentPage().getParameters().get('id')+'_';
}
attachment.ParentId =  Id.valueOf(ApexPages.currentPage().getParameters().get('id')) ;
attachment.body = Encodingutil.base64Decode( imageData );
attachment.IsPrivate = false;

insert attachment;
response= attachment.id; */
                
                
                
                
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                conVer.PathOnClient = 'selfiebysales.jpeg'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = 'Visit Selfie'; // Display name of the files
                conVer.VersionData = EncodingUtil.base64Decode(imageData); // converting your binary string to Blog
                
                insert conVer;    //Insert ContentVersion
                // First get the Content Document Id from ContentVersion Object
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                //create ContentDocumentLink  record 
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = ApexPages.currentPage().getParameters().get('id') ;// Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
                conDocLink.shareType = 'V';
                insert conDocLink;
                response= conDocLink.id;
               
                List<ContentDocumentLink> conList = [select Id,ContentDocument.ownerId,ContentDocument.title,ContentDocumentId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileType from ContentDocumentLink
                                                     where LinkedEntityId=:ApexPages.currentPage().getParameters().get('id') and ContentDocument.FileType in ('JPG', 'JPEG', 'PNG') ];
                system.debug(conList.size());
                Visit__c vs  = [SELECT id,name,ownerId,No_of_photos__c  FROM visit__c WHERE id=:ApexPages.currentPage().getParameters().get('id') LIMIT 1];
                vs.No_of_photos__c = conList.size();
                update vs;
                List<ContentDocument> clist = new List<ContentDocument>();
                for(ContentDocumentLink c : conList){
                    List<ContentDocument> cd = [select Id,ownerId,title,LatestPublishedVersionId,FileType from ContentDocument WHERE id=:c.ContentDocumentId LIMIT 1];
                    cd[0].ownerId = vs.ownerId;
                    clist.add(cd[0]);
                }
                update clist;
                
            }
        catch(Exception e){
            response = 'FAIL'+ e.getmessage();
            
        }
        
    }
   
    
}