public with sharing class StockReportController {
    @AuraEnabled 
    public RouteInitResponse routes{get;set;}
    @AuraEnabled 
    public List<StockReportRow> reportRows{get;set;}
    
    
    public class Option {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        public Option(String l, String v){ label = l; value = v; }
    }
    
    public class RouteInitResponse {
        @AuraEnabled public List<Option> options { get; set; }
        @AuraEnabled public String defaultRouteId { get; set; }
    }
    
    public class StockReportRow {
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public String productName { get; set; }
        
        @AuraEnabled public Decimal openingQty { get; set; }
        @AuraEnabled public Decimal totalStockReceived { get; set; }
        @AuraEnabled public Decimal invoiceCancellation { get; set; }
        @AuraEnabled public Decimal saleableReturns { get; set; }
        @AuraEnabled public Decimal totalSaleableQty { get; set; }
         @AuraEnabled public Decimal unsealedQty { get; set; }
        
        @AuraEnabled public Decimal soldQty { get; set; }
        @AuraEnabled public Decimal saleableClosingQty { get; set; }
        @AuraEnabled public Decimal damagedQty { get; set; }
        @AuraEnabled public Decimal totalQty { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static RouteInitResponse initRoutes() {
        Id uid = UserInfo.getUserId();
        User user = [select id,name,Route_Id__c,Branch_Id__c,ManagerId,Profile.Name from User where id=:UserInfo.getUserId() limit 1];
        List<User> subordinates = [select id,name,Route_Id__c,ManagerId,Profile.Name from User where (id=:UserInfo.getUserId() or ManagerId =:UserInfo.getUserId()) and Route_Id__c != null ];
        Set<String> subordinateIds = new Set<String>();
        for(User u : subordinates){
            subordinateIds.add(u.Route_Id__c);
        }
       
        
        // 2) All routes for dropdown (optional, keep if you want full list)
        List<Route__c> allRoutes = new List<Route__c>();
        if(user.Profile.Name != 'Van Executive' && user.Profile.Name != 'Sales Executive'){
            allRoutes = [
                SELECT Id, Name
                FROM Route__c WHERE Route_Id__c != null
                ORDER BY Name
                LIMIT 2000
            ];
        }
        else{
            allRoutes = [
                SELECT Id, Name
                FROM Route__c where Route_Id__c IN :subordinateIds
                ORDER BY Name
                LIMIT 2000
            ];
        }
        
        
        RouteInitResponse res = new RouteInitResponse();
        res.options = new List<Option>();
        
        for (Route__c r : allRoutes) {
            res.options.add(new Option(r.Name, (String)r.Id));
        }
        
        // Default: first route owned by user, else null
        res.defaultRouteId = [select id from Route__c where Route_Id__c =:user.Route_Id__c limit 1].Id;
        
        return res;
    }
    
    //not in use
    @AuraEnabled(cacheable=true)
    public static List<Option> getRoutes() {
        List<Option> out = new List<Option>();
        for (Route__c r : [SELECT Id, Name FROM Route__c ORDER BY Name]) {
            out.add(new Option(r.Name, r.Id));
        }
        return out;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<StockReportRow> getStockRows(Date fromDate, Date toDate, Id routeId) {
        if (routeId == null) throw new AuraHandledException('Select a Route.');
        if (fromDate == null || toDate == null) throw new AuraHandledException('Select From and To dates.');
        if (fromDate > toDate) throw new AuraHandledException('From Date cannot be after To Date.');
        system.debug('u');
        // Products that exist for this route in the date range
        Set<Id> productIds = new Set<Id>();
        for (AggregateResult ar : [
            SELECT Product__c p
            FROM Stock_History__c
            WHERE Route__c = :routeId
            AND Date__c >= :fromDate AND Date__c <= :toDate
            GROUP BY Product__c
        ]) {
            productIds.add((Id) ar.get('p'));
        }
        if (productIds.isEmpty()) return new List<StockReportRow>();
        
        // Movements within range (cumulative)
        Map<Id, AggregateResult> mov = new Map<Id, AggregateResult>();
        for (AggregateResult ar : [
            SELECT Product__c p,
            SUM(Initial_Quantity__c) recv,
            SUM(Unsealed_Quantity__c) uns,
            SUM(Sold_Quantity__c) sold
            FROM Stock_History__c
            WHERE Route__c = :routeId
            AND Date__c >= :fromDate AND Date__c <= :toDate
            AND Product__c IN :productIds
            GROUP BY Product__c
        ]) {
            mov.put((Id) ar.get('p'), ar);
        }
        
        // ---------- OPENING SNAPSHOT ----------
        Map<Id, Decimal> openingMap = new Map<Id, Decimal>();
        
        // 1) Exact FromDate rows
        for (Stock_History__c sh : [
            SELECT Product__c, Opening_Quantity__c
            FROM Stock_History__c
            WHERE Route__c = :routeId
            AND Date__c = :fromDate
            AND Product__c IN :productIds
        ]) {
            openingMap.put(sh.Product__c, nz(sh.Opening_Quantity__c));
        }
        
        // 2) For products missing FromDate, pull latest prior date per product (MAX(Date__c))
        Set<Id> missingOpen = new Set<Id>(productIds);
        missingOpen.removeAll(openingMap.keySet());
        
        if (!missingOpen.isEmpty()) {
            Map<Id, Date> openMaxDate = new Map<Id, Date>();
            Set<Date> openDates = new Set<Date>();
            
            for (AggregateResult ar : [
                SELECT Product__c p, MAX(Date__c) md
                FROM Stock_History__c
                WHERE Route__c = :routeId
                AND Product__c IN :missingOpen
                AND Date__c < :fromDate
                GROUP BY Product__c
            ]) {
                Id pid = (Id) ar.get('p');
                Date md = (Date) ar.get('md');
                openMaxDate.put(pid, md);
                openDates.add(md);
            }
            
            // 3) Fetch only those rows and take Available as opening (previous closing)
            for (Stock_History__c sh : [
                SELECT Product__c, Date__c, Available_Quantity__c
                FROM Stock_History__c
                WHERE Route__c = :routeId
                AND Product__c IN :missingOpen
                AND Date__c IN :openDates
            ]) {
                if (openMaxDate.get(sh.Product__c) == sh.Date__c) {
                    openingMap.put(sh.Product__c, nz(sh.Available_Quantity__c));
                }
            }
        }
        
        // ---------- CLOSING SNAPSHOT ----------
        Map<Id, Stock_History__c> closeMap = new Map<Id, Stock_History__c>();
        
        // 1) Exact ToDate rows
        for (Stock_History__c sh : [
            SELECT Product__c, Available_Quantity__c, Damaged_Quantity__c, Total_Qty__c
            FROM Stock_History__c
            WHERE Route__c = :routeId
            AND Date__c = :toDate
            AND Product__c IN :productIds
        ]) {
            closeMap.put(sh.Product__c, sh);
        }
        
        // 2) For products missing ToDate, pull latest prior date per product
        Set<Id> missingClose = new Set<Id>(productIds);
        missingClose.removeAll(closeMap.keySet());
        
        if (!missingClose.isEmpty()) {
            Map<Id, Date> closeMaxDate = new Map<Id, Date>();
            Set<Date> closeDates = new Set<Date>();
            
            for (AggregateResult ar : [
                SELECT Product__c p, MAX(Date__c) md
                FROM Stock_History__c
                WHERE Route__c = :routeId
                AND Product__c IN :missingClose
                AND Date__c < :toDate
                GROUP BY Product__c
            ]) {
                Id pid = (Id) ar.get('p');
                Date md = (Date) ar.get('md');
                closeMaxDate.put(pid, md);
                closeDates.add(md);
            }
            
            for (Stock_History__c sh : [
                SELECT Product__c, Date__c, Available_Quantity__c, Damaged_Quantity__c, Total_Qty__c
                FROM Stock_History__c
                WHERE Route__c = :routeId
                AND Product__c IN :missingClose
                AND Date__c IN :closeDates
            ]) {
                if (closeMaxDate.get(sh.Product__c) == sh.Date__c) {
                    closeMap.put(sh.Product__c, sh);
                }
            }
        }
        
        
        // Product master
        Map<Id, Product__c> prodMap = new Map<Id, Product__c>([
            SELECT Id, Name, Product_Code__c
            FROM Product__c
            WHERE Id IN :productIds
        ]);
        
        // Build output
        List<StockReportRow> out = new List<StockReportRow>();
        
        for (Id pid : productIds) {
            Product__c p = prodMap.get(pid);
            if (p == null) continue;
            
            AggregateResult ar = mov.get(pid);
            Decimal opening = openingMap.containsKey(pid) ? openingMap.get(pid) : 0;
            Decimal received = ar == null ? 0 : nz((Decimal) ar.get('recv'));
            Decimal uns = ar == null ? 0 : nz((Decimal) ar.get('uns'));
            Decimal sold = ar == null ? 0 : nz((Decimal) ar.get('sold'));
            
            Stock_History__c cl = closeMap.get(pid);
            
            StockReportRow r = new StockReportRow();
            r.productId = pid;
            r.productName = p.Name;
            r.productCode = (p.Product_Code__c != null) ? p.Product_Code__c : p.Name;
            
            r.openingQty = opening;
            r.totalStockReceived = received;
            
            // Placeholder as requested
            r.invoiceCancellation = 0;
            
            // What your batch is filling (Unsealed_Quantity__c)
            r.saleableReturns = uns;
            
            // V1 computed
            r.totalSaleableQty = opening + received + uns - r.invoiceCancellation;
            
            r.soldQty = sold;
            r.saleableClosingQty = (cl != null) ? nz(cl.Available_Quantity__c) : 0;
            r.damagedQty = (cl != null) ? nz(cl.Damaged_Quantity__c) : 0;
            r.totalQty = (cl != null) ? nz(cl.Total_Qty__c) : (r.saleableClosingQty + r.damagedQty);
                
                out.add(r);
        }
        
        out.sort(new RowSorter());
        return out;
    }
    
    @AuraEnabled
    public static List<StockReportRow> getStockRowsNew(Date fromDate, Date toDate, Id routeId, string selectedCol ,String sortBy, String sortDir) {
        
        if (routeId == null) throw new AuraHandledException('Select a Route.');
        if (fromDate == null || toDate == null) throw new AuraHandledException('Select From/To dates.');
        if (fromDate > toDate) throw new AuraHandledException('From Date cannot be after To Date.');
        list<string> selectedColFilter =new  list<string>();
        if(selectedCol !=null && selectedCol !=''){
            selectedColFilter = selectedCol.split(';');
        }
        // Opening snapshot: Latest record on or before fromDate
        Map<Id, Decimal> openingMap = new Map<Id, Decimal>();
        for (Stock_History__c sh : [ SELECT Product__c, Opening_Quantity__c FROM Stock_History__c WHERE Route__c = :routeId AND Date__c = :fromDate] ) {
            openingMap.put(sh.Product__c, nz(sh.Opening_Quantity__c));
        }
        // Total Stock Received
        Map<Id, Decimal> receivedMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT Product__c p, SUM(Received_Qunatity__c) receivedQty  FROM Stock_Request_Item__c  WHERE Status__c = 'Received'  AND Stock_Request__r.Received_Date_Time__c >= :fromDate AND Stock_Request__r.Received_Date_Time__c <= :toDate AND Stock_Request__r.Route__c = :routeId GROUP BY Product__c]) {
            receivedMap.put((Id) ar.get('p'), nz((Decimal) ar.get('receivedQty')));
        }
        
        // Invoice Cancellation (Cancelled Invoices)
        Map<Id, Decimal> invoiceCancelMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Product__c p, SUM(Quantity__c) cancelledQty
            FROM Sales_Invoice_Item__c
            WHERE Sales_Invoice__r.Sales_Invoice_Status__c = 'Cancelled'
            AND Sales_Invoice__r.Invoice_Cancellation_Time__c >= :fromDate
            AND Sales_Invoice__r.Invoice_Cancellation_Time__c <= :toDate
            AND Sales_Invoice__r.Route__c = :routeId
            GROUP BY Product__c
        ]) {
            invoiceCancelMap.put((Id) ar.get('p'), nz((Decimal) ar.get('cancelledQty')));
        }
        
        // Saleable Returns (Approved returns)
        Map<Id, Decimal> saleableReturnsMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Product__c p, SUM(Quantity__c) returnQty
            FROM Return_Item__c
            WHERE Return__r.Return_Type__c = 'Saleable'
            AND Return__r.Approved_Date_Time__c >= :fromDate
            AND Return__r.Approved_Date_Time__c <= :toDate
            AND Return__r.Route__c = :routeId
            GROUP BY Product__c
        ]) {
            saleableReturnsMap.put((Id) ar.get('p'), nz((Decimal) ar.get('returnQty')));
        }
        
        // Sold Quantity (Sales Invoice Items)
        Map<Id, Decimal> soldMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Product__c p, SUM(Quantity__c) soldQty
            FROM Sales_Invoice_Item__c
            WHERE CreatedDate >= :fromDate AND CreatedDate <= :toDate
            AND Sales_Invoice__r.Route__c = :routeId
            GROUP BY Product__c
        ]) {
            soldMap.put((Id) ar.get('p'), nz((Decimal) ar.get('soldQty')));
        }
        
        // Saleable Closing Quantity (Calculated)
        Map<Id, Decimal> saleableClosingMap = new Map<Id, Decimal>();
        
        // Damaged Quantity (Non-Saleable returns)
        Map<Id, Decimal> damagedMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Product__c p, SUM(Quantity__c) damagedQty
            FROM Return_Item__c
            WHERE Return__r.Return_Type__c = 'Non-Saleable'
            AND Return__r.Approved_Date_Time__c >= :fromDate
            AND Return__r.Approved_Date_Time__c <= :toDate
            AND Return__r.Route__c = :routeId
            GROUP BY Product__c
        ]) {
            damagedMap.put((Id) ar.get('p'), nz((Decimal) ar.get('damagedQty')));
        }
       
         Map<Id, Decimal> unsealedMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [select Product__c p, SUM(Quantity__c) unsealedQty 
                                   from Unsealed_Item__c where createddate >= :fromDate
                                   AND createddate <= :toDate AND Unsealed__r.Route__c = :routeId group by Product__c]){
           unsealedMap.put((Id) ar.get('p'), nz((Decimal) ar.get('unsealedQty')));
        }
        
        // Total Quantity (Saleable Closing + Damaged)
        Map<Id, Decimal> totalQtyMap = new Map<Id, Decimal>();
        
        // Get Products and Calculate Values
        List<StockReportRow> reportRows = new List<StockReportRow>();
        Set<Id> productIds = new Set<Id>(openingMap.keySet());
        
        // Query product data (Name + Code)
        Map<Id, Product__c> productMap = new Map<Id, Product__c>([
            SELECT Id, Name, Product_Code__c
            FROM Product__c
            WHERE Id IN :productIds
        ]);
        
        for (Id productId : openingMap.keySet()) {
            StockReportRow row = new StockReportRow();
            row.productId = productId;
            
            // Assign product name and code
            Product__c product = productMap.get(productId);
            row.productName = (product != null) ? product.Name : 'Unknown';
            row.productCode = (product != null && product.Product_Code__c != null) ? product.Product_Code__c : 'N/A';
            if(selectedColFilter.contains('openingQty')){
                row.openingQty = openingMap.containsKey(productId) ? openingMap.get(productId) : 0; 
                if( row.openingQty ==0) continue;
            }else{
                row.openingQty = openingMap.containsKey(productId) ? openingMap.get(productId) : 0;     
            }
            if(selectedColFilter.contains('totalStockReceived')){
                row.totalStockReceived = receivedMap.containsKey(productId) ? receivedMap.get(productId) : 0;
                if( row.totalStockReceived ==0) continue;
            }else{
                row.totalStockReceived = receivedMap.containsKey(productId) ? receivedMap.get(productId) : 0;
            }
            if(selectedColFilter.contains('invoiceCancellation')){
                row.invoiceCancellation = invoiceCancelMap.containsKey(productId) ? invoiceCancelMap.get(productId) : 0;
                if( row.invoiceCancellation ==0) continue;
            }else{
                row.invoiceCancellation = invoiceCancelMap.containsKey(productId) ? invoiceCancelMap.get(productId) : 0;
            }  
            if(selectedColFilter.contains('saleableReturns')){
                row.saleableReturns = saleableReturnsMap.containsKey(productId) ? saleableReturnsMap.get(productId) : 0;
                if( row.saleableReturns ==0) continue;
            }else{
                row.saleableReturns = saleableReturnsMap.containsKey(productId) ? saleableReturnsMap.get(productId) : 0;
            }   
            
            if(selectedColFilter.contains('unsealedQty')){
                row.unsealedQty = unsealedMap.containsKey(productId) ? unsealedMap.get(productId) : 0;
                if( row.unsealedQty ==0) continue;
            }else{
                row.unsealedQty = unsealedMap.containsKey(productId) ? unsealedMap.get(productId) : 0;
            }
            
            if(selectedColFilter.contains('totalSaleableQty')){
                row.totalSaleableQty = row.openingQty + row.totalStockReceived + row.saleableReturns + row.invoiceCancellation;
                if( row.totalSaleableQty ==0) continue;
            }else{
                row.totalSaleableQty = row.openingQty + row.totalStockReceived + row.saleableReturns + row.invoiceCancellation;
            }   
            
            if(selectedColFilter.contains('soldQty')){
                row.soldQty = soldMap.containsKey(productId) ? soldMap.get(productId) : 0;
                if( row.soldQty ==0) continue;
            }else{
                row.soldQty = soldMap.containsKey(productId) ? soldMap.get(productId) : 0;
            }  
            if(selectedColFilter.contains('saleableClosingQty')){
                row.saleableClosingQty = row.totalSaleableQty - row.soldQty - row.unsealedQty;
                if( row.saleableClosingQty ==0) continue;
            }else{
                row.saleableClosingQty = row.totalSaleableQty - row.soldQty - row.unsealedQty;
            }
            if(selectedColFilter.contains('damagedQty')){
                row.damagedQty = damagedMap.containsKey(productId) ? damagedMap.get(productId) : 0;
                if( row.damagedQty ==0) continue;
            }else{
                row.damagedQty = damagedMap.containsKey(productId) ? damagedMap.get(productId) : 0;
            }
            if(selectedColFilter.contains('totalQty')){
                row.totalQty = row.saleableClosingQty + row.damagedQty;
                if( row.totalQty ==0) continue;
            }else{
                row.totalQty = row.saleableClosingQty + row.damagedQty;
            }
            
            
            
            sortRows(reportRows, sortBy, sortDir);
            reportRows.add(row);
        }
        
        return reportRows;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static StockReportController getStockRowsDefault(Date fromDate, Date toDate,String sortBy, String sortDir) {
        StockReportController stocks =new StockReportController();
        RouteInitResponse resRoute =initRoutes();
        string routeId =resRoute.defaultRouteId;
        stocks.routes =resRoute;
        
        // Opening snapshot: Latest record on or before fromDate
        Map<Id, Decimal> openingMap = new Map<Id, Decimal>();
        for (Stock_History__c sh : [ SELECT Product__c, Opening_Quantity__c FROM Stock_History__c WHERE Route__c = :routeId AND Date__c = :fromDate] ) {
            openingMap.put(sh.Product__c, nz(sh.Opening_Quantity__c));
        }
        
        // Total Stock Received
        Map<Id, Decimal> receivedMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT Product__c p, SUM(Received_Qunatity__c) receivedQty  FROM Stock_Request_Item__c  WHERE Status__c = 'Received'  AND Stock_Request__r.Received_Date_Time__c >= :fromDate AND Stock_Request__r.Received_Date_Time__c <= :toDate AND Stock_Request__r.Route__c = :routeId GROUP BY Product__c]) {
            receivedMap.put((Id) ar.get('p'), nz((Decimal) ar.get('receivedQty')));
        }
        
        // Invoice Cancellation (Cancelled Invoices)
        Map<Id, Decimal> invoiceCancelMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Product__c p, SUM(Quantity__c) cancelledQty
            FROM Sales_Invoice_Item__c
            WHERE Sales_Invoice__r.Sales_Invoice_Status__c = 'Cancelled'
            AND Sales_Invoice__r.Invoice_Cancellation_Time__c >= :fromDate
            AND Sales_Invoice__r.Invoice_Cancellation_Time__c <= :toDate
            AND Sales_Invoice__r.Route__c = :routeId
            GROUP BY Product__c
        ]) {
            invoiceCancelMap.put((Id) ar.get('p'), nz((Decimal) ar.get('cancelledQty')));
        }
        
        // Saleable Returns (Approved returns)
        Map<Id, Decimal> saleableReturnsMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [ SELECT Product__c p, SUM(Quantity__c) returnQty FROM Return_Item__c  WHERE Return__r.Return_Type__c = 'Saleable'
            AND Return__r.Approved_Date_Time__c >= :fromDate AND Return__r.Approved_Date_Time__c <= :toDate
            AND Return__r.Route__c = :routeId  GROUP BY Product__c
        ]) {
            saleableReturnsMap.put((Id) ar.get('p'), nz((Decimal) ar.get('returnQty')));
        }
        
        //unsealed items
         Map<Id, Decimal> unsealedMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [select Product__c p, SUM(Quantity__c) unsealedQty 
                                   from Unsealed_Item__c where createddate >= :fromDate
                                   AND createddate <= :toDate AND Unsealed__r.Route__c = :routeId group by Product__c]){
           unsealedMap.put((Id) ar.get('p'), nz((Decimal) ar.get('unsealedQty')));
        }
        
        // Sold Quantity (Sales Invoice Items)
        Map<Id, Decimal> soldMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [ SELECT Product__c p, SUM(Quantity__c) soldQty FROM Sales_Invoice_Item__c
            WHERE CreatedDate >= :fromDate AND CreatedDate <= :toDate  AND Sales_Invoice__r.Route__c = :routeId
            GROUP BY Product__c ]) 
        {
            soldMap.put((Id) ar.get('p'), nz((Decimal) ar.get('soldQty')));
        }
        
        // Saleable Closing Quantity (Calculated)
        Map<Id, Decimal> saleableClosingMap = new Map<Id, Decimal>();
        
        // Damaged Quantity (Non-Saleable returns)
        Map<Id, Decimal> damagedMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [ SELECT Product__c p, SUM(Quantity__c) damagedQty
            FROM Return_Item__c  WHERE Return__r.Return_Type__c = 'Non-Saleable' AND Return__r.Approved_Date_Time__c >= :fromDate
            AND Return__r.Approved_Date_Time__c <= :toDate AND Return__r.Route__c = :routeId  GROUP BY Product__c]) {
            damagedMap.put((Id) ar.get('p'), nz((Decimal) ar.get('damagedQty')));
        }
        
        // Total Quantity (Saleable Closing + Damaged)
        Map<Id, Decimal> totalQtyMap = new Map<Id, Decimal>();
        
        // Get Products and Calculate Values
        List<StockReportRow> reportRows = new List<StockReportRow>();
        Set<Id> productIds = new Set<Id>(openingMap.keySet());
        
        // Query product data (Name + Code)
        Map<Id, Product__c> productMap = new Map<Id, Product__c>([
            SELECT Id, Name, Product_Code__c
            FROM Product__c
            WHERE Id IN :productIds
        ]);
        
        for (Id productId : openingMap.keySet()) {
            StockReportRow row = new StockReportRow();
            row.productId = productId;
            
            // Assign product name and code
            Product__c product = productMap.get(productId);
            row.productName = (product != null) ? product.Name : 'Unknown';
            row.productCode = (product != null && product.Product_Code__c != null) ? product.Product_Code__c : 'N/A';
            row.openingQty = openingMap.containsKey(productId) ? openingMap.get(productId) : 0; 
            row.totalStockReceived = receivedMap.containsKey(productId) ? receivedMap.get(productId) : 0;
            row.invoiceCancellation = invoiceCancelMap.containsKey(productId) ? invoiceCancelMap.get(productId) : 0;
            row.saleableReturns = saleableReturnsMap.containsKey(productId) ? saleableReturnsMap.get(productId) : 0;
             row.unsealedQty = unsealedMap.containsKey(productId) ? unsealedMap.get(productId) : 0;
            row.totalSaleableQty = row.openingQty + row.totalStockReceived + row.saleableReturns + row.invoiceCancellation;
            row.soldQty = soldMap.containsKey(productId) ? soldMap.get(productId) : 0;
            
            row.saleableClosingQty = row.totalSaleableQty - row.soldQty;
            row.damagedQty = damagedMap.containsKey(productId) ? damagedMap.get(productId) : 0;
            row.totalQty = row.saleableClosingQty + row.damagedQty;
            sortRows(reportRows, sortBy, sortDir);
            reportRows.add(row);
        }
        
        stocks.reportRows =reportRows;
        return stocks;
    }
    
    // Utility function to return 0 if the value is null
    private static Decimal nz(Decimal d) { return d == null ? 0 : d; }
    
    private class RowSorter implements System.Comparator<StockReportRow> {
        public Integer compare(StockReportRow a, StockReportRow b) {
            String sa = (a == null || a.productName == null) ? '' : a.productName.toLowerCase();
            String sb = (b == null || b.productName == null) ? '' : b.productName.toLowerCase();
            return sa.compareTo(sb);
        } 
    }
    
    public static void sortRows(List<StockReportRow> rows, String sortBy, String sortDir) {
        if (rows == null || rows.isEmpty()) return;
        
        String key = String.isBlank(sortBy) ? 'productName' : sortBy;
        Boolean asc1 = (String.isBlank(sortDir) || sortDir.toLowerCase() == 'asc');
        
        rows.sort(new StockRowSorter(key, asc1));
    }
    
    // ✅ top-level helper methods (allowed to be static)
    private static Integer cmpDec(Decimal x, Decimal y) {
        Decimal a = (x == null) ? 0 : x;
        Decimal b = (y == null) ? 0 : y;
        if (a == b) return 0;
        return (a > b) ? 1 : -1;
    }
    
    private static Integer cmpStr(String x, String y) {
        String a = (x == null) ? '' : x.toLowerCase();
        String b = (y == null) ? '' : y.toLowerCase();
        if (a == b) return 0;
        return (a > b) ? 1 : -1;
    }
    
    private class StockRowSorter implements System.Comparator<StockReportRow> {
        private String key;
        private Boolean asc1;
        
        StockRowSorter(String key, Boolean asc1){
            this.key = key;
            this.asc1 = asc1;
        }
        
        public Integer compare(StockReportRow a, StockReportRow b) {
            Integer c;
            
            if (key == 'productName') c = cmpStr(a.productName, b.productName);
            else if (key == 'productCode') c = cmpStr(a.productCode, b.productCode);
            else if (key == 'openingQty') c = cmpDec(a.openingQty, b.openingQty);
            else if (key == 'totalStockReceived') c = cmpDec(a.totalStockReceived, b.totalStockReceived);
            else if (key == 'invoiceCancellation') c = cmpDec(a.invoiceCancellation, b.invoiceCancellation);
            else if (key == 'saleableReturns') c = cmpDec(a.saleableReturns, b.saleableReturns);
            else if (key == 'totalSaleableQty') c = cmpDec(a.totalSaleableQty, b.totalSaleableQty);
            else if (key == 'soldQty') c = cmpDec(a.soldQty, b.soldQty);
            else if (key == 'saleableClosingQty') c = cmpDec(a.saleableClosingQty, b.saleableClosingQty);
            else if (key == 'damagedQty') c = cmpDec(a.damagedQty, b.damagedQty);
            else if (key == 'totalQty') c = cmpDec(a.totalQty, b.totalQty);
            else c = cmpStr(a.productName, b.productName);
            
            return asc1 ? c : -c;
        }
    }
    
    @AuraEnabled
    public static List<StockReportRow> getStockRowsProduct(Date fromDate, Date toDate, Id routeId, string prodId ) {
        
        // Opening snapshot: Latest record on or before fromDate
        Map<Id, Decimal> openingMap = new Map<Id, Decimal>();
        for (Stock_History__c sh : [ SELECT Product__c, Opening_Quantity__c FROM Stock_History__c WHERE Route__c = :routeId AND Date__c = :fromDate and Product__c=:prodId] ) {
            openingMap.put(sh.Product__c, nz(sh.Opening_Quantity__c));
        }
        // Total Stock Received
        Map<Id, Decimal> receivedMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT Product__c p, SUM(Received_Qunatity__c) receivedQty  FROM Stock_Request_Item__c  WHERE Status__c = 'Received'  AND Stock_Request__r.Received_Date_Time__c >= :fromDate AND Stock_Request__r.Received_Date_Time__c <= :toDate AND Stock_Request__r.Route__c = :routeId and Product__c=:prodId GROUP BY Product__c]) {
            receivedMap.put((Id) ar.get('p'), nz((Decimal) ar.get('receivedQty')));
        }
        
        // Invoice Cancellation (Cancelled Invoices)
        Map<Id, Decimal> invoiceCancelMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [ SELECT Product__c p, SUM(Quantity__c) cancelledQty FROM Sales_Invoice_Item__c
            WHERE Sales_Invoice__r.Sales_Invoice_Status__c = 'Cancelled'  AND Sales_Invoice__r.Invoice_Cancellation_Time__c >= :fromDate
            AND Sales_Invoice__r.Invoice_Cancellation_Time__c <= :toDate  AND Sales_Invoice__r.Route__c = :routeId and Product__c=:prodId GROUP BY Product__c ]) {
            invoiceCancelMap.put((Id) ar.get('p'), nz((Decimal) ar.get('cancelledQty')));
        }
        
        // Saleable Returns (Approved returns)
        Map<Id, Decimal> saleableReturnsMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT Product__c p, SUM(Quantity__c) returnQty FROM Return_Item__c  WHERE Return__r.Return_Type__c = 'Saleable'
            AND Return__r.Approved_Date_Time__c >= :fromDate  AND Return__r.Approved_Date_Time__c <= :toDate
            AND Return__r.Route__c = :routeId and Product__c=:prodId GROUP BY Product__c ]) {
            saleableReturnsMap.put((Id) ar.get('p'), nz((Decimal) ar.get('returnQty')));
        }
        
        // Sold Quantity (Sales Invoice Items)
        Map<Id, Decimal> soldMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT Product__c p, SUM(Quantity__c) soldQty
            FROM Sales_Invoice_Item__c WHERE CreatedDate >= :fromDate AND CreatedDate <= :toDate
            AND Sales_Invoice__r.Route__c = :routeId and Product__c=:prodId  GROUP BY Product__c ]) {
            soldMap.put((Id) ar.get('p'), nz((Decimal) ar.get('soldQty')));
        }
        
        // Saleable Closing Quantity (Calculated)
        Map<Id, Decimal> saleableClosingMap = new Map<Id, Decimal>();
        
        // Damaged Quantity (Non-Saleable returns)
        Map<Id, Decimal> damagedMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT Product__c p, SUM(Quantity__c) damagedQty
            FROM Return_Item__c  WHERE Return__r.Return_Type__c = 'Non-Saleable'
            AND Return__r.Approved_Date_Time__c >= :fromDate AND Return__r.Approved_Date_Time__c <= :toDate
            AND Return__r.Route__c = :routeId and Product__c=:prodId GROUP BY Product__c ]) {
            damagedMap.put((Id) ar.get('p'), nz((Decimal) ar.get('damagedQty')));
        }
        
        // Total Quantity (Saleable Closing + Damaged)
        Map<Id, Decimal> totalQtyMap = new Map<Id, Decimal>();
        
        // Get Products and Calculate Values
        List<StockReportRow> reportRows = new List<StockReportRow>();
        Set<Id> productIds = new Set<Id>(openingMap.keySet());
        
        // Query product data (Name + Code)
        Map<Id, Product__c> productMap = new Map<Id, Product__c>([
            SELECT Id, Name, Product_Code__c
            FROM Product__c
            WHERE Id IN :productIds
        ]);
        
        for (Id productId : openingMap.keySet()) {
            StockReportRow row = new StockReportRow();
            row.productId = productId;
            
            // Assign product name and code
            Product__c product = productMap.get(productId);
            row.productName = (product != null) ? product.Name : 'Unknown';
            row.productCode = (product != null && product.Product_Code__c != null) ? product.Product_Code__c : 'N/A';
            
            row.openingQty = openingMap.containsKey(productId) ? openingMap.get(productId) : 0;     
            
            row.totalStockReceived = receivedMap.containsKey(productId) ? receivedMap.get(productId) : 0;
            
            row.invoiceCancellation = invoiceCancelMap.containsKey(productId) ? invoiceCancelMap.get(productId) : 0;
            
            row.saleableReturns = saleableReturnsMap.containsKey(productId) ? saleableReturnsMap.get(productId) : 0;
            
            row.totalSaleableQty = row.openingQty + row.totalStockReceived + row.saleableReturns + row.invoiceCancellation;
            
            row.soldQty = soldMap.containsKey(productId) ? soldMap.get(productId) : 0;
            
            row.saleableClosingQty = row.totalSaleableQty - row.soldQty;
            
            row.damagedQty = damagedMap.containsKey(productId) ? damagedMap.get(productId) : 0;
            
            row.totalQty = row.saleableClosingQty + row.damagedQty;
            
            system.debug(row);
            reportRows.add(row);
        }
        return reportRows;
        
    }
}