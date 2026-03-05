@IsTest
public class StockReportPdfServiceTest {

    @IsTest
    static void testGeneratePdf_Success() {

        Route__c route = new Route__c(Name = 'Test Route');
        insert route;

        Date fromDate = Date.today().addDays(-7);
        Date toDate   = Date.today();

        Test.startTest();
        String pdfUrl = StockReportPdfService.generatePdf(
            route.Id,
            fromDate,
            toDate,
            '',
            'productName',
            'desc'
        );
        Test.stopTest();

        System.assertNotEquals(null, pdfUrl);

        ContentVersion cv = [
            SELECT Id
            FROM ContentVersion
            WHERE Title LIKE 'Stock Tracking Report%'
            LIMIT 1
        ];
        System.assertNotEquals(null, cv.Id);

        ContentDistribution cd = [
            SELECT DistributionPublicUrl
            FROM ContentDistribution
            WHERE ContentVersionId = :cv.Id
            LIMIT 1
        ];
        System.assertNotEquals(null, cd.DistributionPublicUrl);
    }

    @IsTest
    static void testGeneratePdf_InvalidDateRange() {

        Route__c route = new Route__c(Name = 'Test Route 2');
        insert route;

        Boolean exceptionThrown = false;

        try {
            StockReportPdfService.generatePdf(
                route.Id,
                Date.today(),
                Date.today().addDays(-1),
                '',
                'productName',
            'desc'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        System.assertEquals(true, exceptionThrown);
    }
}