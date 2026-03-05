public class LightningFileUploadHandler {
	@AuraEnabled  
    public static List<ContentDocument> getFiles(Id recordId){ 
        system.debug('recordId== '+recordId);
        ID filter = recordId;
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:filter]; 
        
        Set<Id> documentIds = new Set<Id>(); 
       
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }    
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :documentIds];        
    } 
    
    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :contentDocumentId];       
    }  
}