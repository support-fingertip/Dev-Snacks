public with sharing class StockReportPdfService {
    
    @AuraEnabled
    public static String generatePdf(Id routeId, Date fromDate, Date toDate, string selectedCol, String sortBy, String sortDir) {
        if (routeId == null) throw new AuraHandledException('Select a Route.');
        if (fromDate == null || toDate == null) throw new AuraHandledException('Select From/To dates.');
        if (fromDate > toDate) throw new AuraHandledException('From Date cannot be after To Date.');
        
        PageReference pr = Page.StockTrackingReportPdf; // VF page name
        pr.getParameters().put('routeId', String.valueOf(routeId));
        pr.getParameters().put('from', String.valueOf(fromDate));
        pr.getParameters().put('to', String.valueOf(toDate));
        pr.getParameters().put('sortBy', sortBy);
        pr.getParameters().put('sortDir', sortDir);
        pr.getParameters().put('selectedCol', selectedCol); 
         Blob pdfBlob = Test.isRunningTest() ? Blob.valueOf('dummy') : pr.getContentAsPDF();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Stock Tracking Report_' + fromDate + '_to_' + toDate;
        cv.PathOnClient = 'StockTrackingReport.pdf';
        cv.VersionData = pdfBlob;
        insert cv;
        
        ContentDistribution cd = new ContentDistribution();
        cd.Name = cv.Title;
        cd.ContentVersionId = cv.Id;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = false;
        cd.PreferencesNotifyOnVisit = false;
        insert cd;
        
        return [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.Id]
            .DistributionPublicUrl;
        
        
        // Get ContentDocumentId
        /*  cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

// Return RELATIVE path only (no domain)
return '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId
+ '?operationContext=S1&contentDisposition=attachment'; */
        
        /*   ContentVersion cv = new ContentVersion();
cv.Title = 'Stock Tracking Report_' + fromDate + '_to_' + toDate;
cv.PathOnClient = 'StockTrackingReport.pdf';
cv.VersionData = pdfBlob;
insert cv;

String base = URL.getOrgDomainUrl().toExternalForm();
return '/sfc/servlet.shepherd/version/download/' + cv.Id
+ '?operationContext=S1&contentDisposition=attachment'; */
    }
}