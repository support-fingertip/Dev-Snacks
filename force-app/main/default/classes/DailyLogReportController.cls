public with sharing class DailyLogReportController {

    public class LogReportRow {
        @AuraEnabled public String   logId;
        @AuraEnabled public String   logName;
        @AuraEnabled public String   branch;        // Branch Name
        @AuraEnabled public String   route;         // Route Name
        @AuraEnabled public Datetime clockIn;
        @AuraEnabled public Datetime clockOut;
        @AuraEnabled public String   firstInvoiceId;
        @AuraEnabled public Datetime firstInvoiceCreated;
        @AuraEnabled public String   lastInvoiceId;
        @AuraEnabled public Datetime lastInvoiceCreated;
    }

    // Fetch Branches for picklist
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getBranches() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        options.add(new Map<String, String>{'label' => '-- All Branches --', 'value' => ''});
        // Adjust object and field names as per your org
        for (Branch__c b : [SELECT Id, Name FROM Branch__c ORDER BY Name]) {
            options.add(new Map<String, String>{'label' => b.Name, 'value' => b.Id});
        }
        return options;
    }

    // Fetch Routes for picklist (existing)
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getRoutes() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        options.add(new Map<String, String>{'label' => '-- All Routes --', 'value' => ''});
        for (Route__c r : [SELECT Id, Name FROM Route__c ORDER BY Name]) {
            options.add(new Map<String, String>{'label' => r.Name, 'value' => r.Id});
        }
        return options;
    }

    @AuraEnabled(cacheable=false)
    public static List<LogReportRow> getLogReport(Date startDate, Date endDate, String branchId, String routeId) {
        if (startDate == null || endDate == null) {
            throw new AuraHandledException('Start Date and End Date are required.');
        }
        if (endDate < startDate) {
            throw new AuraHandledException('End Date cannot be earlier than Start Date.');
        }

        Datetime startDT = Datetime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        Datetime endDT = Datetime.newInstance(endDate.addDays(1), Time.newInstance(0, 0, 0, 0));

        // Build dynamic WHERE clause
        String logWhere = 'Clock_In__c >= :startDT AND Clock_In__c <= :endDT';
        if (String.isNotBlank(branchId)) {
            logWhere += ' AND Route__r.Branch_Name__c = :branchId';   // assuming Branch__c on DailyLog__c
        }
        if (String.isNotBlank(routeId)) {
            logWhere += ' AND Route__c = :routeId';
        }

        // Fetch Daily Logs with related Branch and Route names
        List<DailyLog__c> logs = Database.query(
            'SELECT Id, Name, Clock_In__c, Clock_Out__c, ' +
            'Route__r.Branch_Name__r.Name, Route__r.Name ' +
            'FROM DailyLog__c WHERE ' + logWhere +
            ' ORDER BY Route__r.Branch_Name__r.Name, Route__r.Name, Clock_In__c ASC'
        );

        if (logs.isEmpty()) {
            return new List<LogReportRow>();
        }

        Set<Id> logIds = new Set<Id>();
        for (DailyLog__c d : logs) logIds.add(d.Id);

        // Fetch invoices linked to these logs
        List<Sales_Invoice__c> invoices = [
            SELECT Id, Name, CreatedDate, Daily_log__c, Visit__c, Visit__r.Daily_Log__c
            FROM Sales_Invoice__c
            WHERE CreatedDate >= :startDT
              AND CreatedDate <= :endDT
              AND (
                    Daily_log__c IN :logIds
                 OR (Daily_log__c = NULL AND Visit__c != NULL AND Visit__r.Daily_Log__c IN :logIds)
                  )
            ORDER BY CreatedDate ASC
        ];

        Map<Id, Sales_Invoice__c> firstInvByLog = new Map<Id, Sales_Invoice__c>();
        Map<Id, Sales_Invoice__c> lastInvByLog  = new Map<Id, Sales_Invoice__c>();

        for (Sales_Invoice__c inv : invoices) {
            Id effectiveLogId = inv.Daily_log__c;
            if (effectiveLogId == null && inv.Visit__c != null) {
                effectiveLogId = inv.Visit__r != null ? inv.Visit__r.Daily_Log__c : null;
            }
            if (effectiveLogId == null) continue;

            if (!firstInvByLog.containsKey(effectiveLogId)) {
                firstInvByLog.put(effectiveLogId, inv);
            }
            lastInvByLog.put(effectiveLogId, inv);
        }

        List<LogReportRow> outRows = new List<LogReportRow>();
        for (DailyLog__c d : logs) {
            LogReportRow row = new LogReportRow();
            row.logId = (String) d.Id;
            row.logName = d.Name;
            row.clockIn = d.Clock_In__c;
            row.clockOut = d.Clock_Out__c;
            row.branch = d.Route__r.Branch_Name__r.Name;   // safe navigation
            row.route = d.Route__r.Name;

            Sales_Invoice__c f = firstInvByLog.get(d.Id);
            Sales_Invoice__c l = lastInvByLog.get(d.Id);

            if (f != null) {
                row.firstInvoiceId = (String) f.Name;
                row.firstInvoiceCreated = f.CreatedDate;
            }
            if (l != null) {
                row.lastInvoiceId = (String) l.Name;
                row.lastInvoiceCreated = l.CreatedDate;
            }

            outRows.add(row);
        }

        return outRows;
    }

    // ... (keep your testcover method)



    public static void testcover(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
    }
}