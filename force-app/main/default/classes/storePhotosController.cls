public class storePhotosController {
	public class imageBox{
          @AuraEnabled
        public string url {get; set;}
        @AuraEnabled
        public string imgid {get; set;} 
         @AuraEnabled
        public Date createdDate {get; set;} 
         @AuraEnabled
        public string visitId {get; set;} 
    }       
    
     @AuraEnabled
    public static list<imageBox> imagesMethod(string accId){
        List<imageBox> imgList = new List<imageBox>();
        List<visit__c> VistList= [SELECT id,name,Account1__c,Actual_end_time__c FROM visit__c WHERE Account1__c=:accId LIMIT 10];
        for(visit__c vis : VistList){
             List<ContentDocumentLink> conList = [select Id,ContentDocument.title,ContentDocumentId,ContentDocument.LatestPublishedVersionId,ContentDocument.FileType,ContentDocument.createdDate from ContentDocumentLink
            where LinkedEntityId=:vis.Id and ContentDocument.FileType in ('JPG', 'JPEG', 'PNG')];
        for(ContentDocumentLink cList : conList){
            imageBox img = new imageBox();
            img.imgid = cList.id;
            img.visitId = vis.Name;
            img.createdDate = Date.valueOf(cList.ContentDocument.createdDate);
           img.url = 'https://fit-fls-dev-ed--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+ cList.ContentDocument.LatestPublishedVersionId+'&operationContext=CHATTER&contentId='+cList.ContentDocumentId;
            imgList.add(img);
        }
            
        }
    system.debug(imgList);
        if(imgList.size()!=0){
             return imgList;
        }else{
            return null;
        }
    }
  
}