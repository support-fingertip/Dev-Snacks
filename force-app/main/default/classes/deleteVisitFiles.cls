public class deleteVisitFiles implements Schedulable {
    
    /*
    We need to execute below code in Execute Annonyams Window once.
    deleteVisitFiles deleteFile = new deleteVisitFiles();
    String sch = '0 0 0 1 * ?';
    String jobID = System.schedule('Delete Visits files older then one month', sch, deleteFile);
    */

    public static void execute(SchedulableContext SC){
        List<ContentVersion> contentVersions = [select id,CreatedDate,FirstPublishLocationId,ContentDocumentId from ContentVersion where CreatedDate < LAST_MONTH];
        system.debug('contentVersions=== '+contentVersions);
        set<Id> contentDocumentIds = new set<Id>();
        for(ContentVersion conVersion : contentVersions){
            if(string.valueOf(conVersion.FirstPublishLocationId).startsWith('a0Q') || string.valueOf(conVersion.FirstPublishLocationId).startsWith('a0U')){
                system.debug('conVersion record === '+conVersion);
                contentDocumentIds.add(conVersion.ContentDocumentId);
            }
        }
        
        if(contentDocumentIds.size()>0){
            system.debug('contentDocumentIds== '+contentDocumentIds);
            List<ContentDocument> getContentDocument = [select Id,LatestPublishedVersionId,ContentSize,ContentAssetId from ContentDocument 
                                                        where Id In : contentDocumentIds];
            system.debug('getContentDocument=== '+getContentDocument);
            delete getContentDocument;
        }
    }
}