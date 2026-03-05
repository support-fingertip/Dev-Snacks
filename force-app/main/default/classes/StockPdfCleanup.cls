global class StockPdfCleanup implements Schedulable {
    global void execute(SchedulableContext sc) {
        Datetime cutoff = System.now().addDays(-1);

        List<ContentVersion> cvs = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Title LIKE 'Stock Tracking Report_%'
              AND CreatedDate < :cutoff
        ];

        Set<Id> docIds = new Set<Id>();
        for (ContentVersion cv : cvs) if (cv.ContentDocumentId != null) docIds.add(cv.ContentDocumentId);

        if (!docIds.isEmpty()) {
            delete [SELECT Id FROM ContentDocument WHERE Id IN :docIds];
        }
    }
}