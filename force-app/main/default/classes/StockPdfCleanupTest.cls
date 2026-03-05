@IsTest
public class StockPdfCleanupTest {

    @IsTest
    static void testStockPdfCleanupExecution() {

       
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Stock Tracking Report_Test';
        cv.PathOnClient = 'StockTrackingReport.pdf';
        cv.VersionData = Blob.valueOf('test pdf');
        insert cv;

      
        Test.setCreatedDate(cv.Id, System.now().addDays(-2));

     
        cv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];
        System.assertNotEquals(null, cv.ContentDocumentId);

    
        Test.startTest();
        System.schedule(
            'Stock PDF Cleanup Test Job',
            '0 0 0 * * ?',
            new StockPdfCleanup()
        );
        Test.stopTest();

       
        Integer countDocs = [
            SELECT COUNT()
            FROM ContentDocument
            WHERE Id = :cv.ContentDocumentId
        ];

        System.assertEquals(
            0,
            countDocs,
            'Old Stock PDF should be deleted'
        );
    }
}