public with sharing class StockTrackingReportPdfCtrl {

    public String routeName { get; private set; }
    public String generatedBy { get; private set; }
    public String generatedOn { get; private set; }
    public String fromDateStr { get; private set; }
    public String toDateStr { get; private set; }
    public String selectedColumn { get; private set; }
    
    public List<StockReportController.StockReportRow> rows { get; private set; }

    public StockTrackingReportPdfCtrl() {
        Id routeId = (Id) ApexPages.currentPage().getParameters().get('routeId');
        Date fromDate = Date.valueOf(ApexPages.currentPage().getParameters().get('from'));
        Date toDate   = Date.valueOf(ApexPages.currentPage().getParameters().get('to'));

        routeName = [SELECT Name FROM Route__c WHERE Id = :routeId].Name;

        generatedBy = UserInfo.getName();
        generatedOn = Datetime.now().format('yyyy-MM-dd HH:mm:ss', 'Asia/Kolkata');

        fromDateStr = String.valueOf(fromDate);
        toDateStr   = String.valueOf(toDate);
        String sortBy  = ApexPages.currentPage().getParameters().get('sortBy');
        String sortDir = ApexPages.currentPage().getParameters().get('sortDir');
String selectedCol = ApexPages.currentPage().getParameters().get('selectedCol');
        if(selectedCol !=null && selectedCol !='')
        selectedColumn = selectedCol.replaceAll(';',',');
        rows = StockReportController.getStockRowsNew(fromDate, toDate, routeId,selectedCol, sortBy, sortDir);
        // Uses your existing report generator (invoiceCancellation stays 0 as you requested)
      //  rows = StockReportController.getStockRows(fromDate, toDate, routeId);
    }
}