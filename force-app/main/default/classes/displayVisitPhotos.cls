public class displayVisitPhotos {
 public class imageBox{
          @AuraEnabled
        public string url {get; set;}
        @AuraEnabled
        public string imgid {get; set;} 
         
    }       
    
     @AuraEnabled
    public static list<imageBox> imagesMethod(string visitid){
		List<imageBox> imgList = new List<imageBox>();
     List<ContentDocumentLink> conList = [select Id,ContentDocument.title,ContentDocumentId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileType from ContentDocumentLink
            where LinkedEntityId=:visitid and ContentDocument.FileType in ('JPG', 'JPEG', 'PNG')];
        for(ContentDocumentLink cList : conList){
            imageBox img = new imageBox();
            img.imgid = cList.id;
           img.url = 'https://fit-fls-dev-ed--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+ cList.ContentDocument.LatestPublishedVersionId+'&operationContext=CHATTER&contentId='+cList.ContentDocumentId;
            imgList.add(img);
        }
        if(conList.size()!=0){
             return imgList;
        }else{
            return null;
        }
  
  
}
     @AuraEnabled
    public static list<imageBox> deleteImage(string imageId,string visitid){
        DELETE [select Id,ContentDocument.title FROM ContentDocumentLink WHERE Id=:imageId];
         Visit__c vs  = [SELECT id,name,ownerId,No_of_photos__c  FROM visit__c WHERE id=:visitid];
         
        List<imageBox> imgList = new List<imageBox>();
     List<ContentDocumentLink> conList = [select Id,ContentDocument.title,ContentDocumentId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileType from ContentDocumentLink
            where LinkedEntityId=:visitid and ContentDocument.FileType in ('JPG', 'JPEG', 'PNG')];
         vs.No_of_photos__c = conList.size();
        update vs;
        system.debug(visitid +'  '+conList);
        for(ContentDocumentLink cList : conList){
            imageBox img = new imageBox();
            img.imgid = cList.id;
           img.url = 'https://fit-fls-dev-ed--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+ cList.ContentDocument.LatestPublishedVersionId+'&operationContext=CHATTER&contentId='+cList.ContentDocumentId;
            imgList.add(img);
        }
         if(conList.size()!=0){
             return imgList;
        }else{
            return null;
        }
    }
}