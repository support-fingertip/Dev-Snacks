public class StockTriggerHandler {

    /**
     * BEFORE INSERT
     * Mark every new stock record as Latest by default
     */
    public static void beforeInsert(List<Stock__c> newStocks) {
        for (Stock__c s : newStocks) {
            s.Is_Latest__c = true;
        }
    }

    /**
     * AFTER INSERT
     * For same Product + Branch,
     * mark older stock records as NOT Latest
     */
    public static void afterInsert(List<Stock__c> newStocks) {

        Set<Id> productIds = new Set<Id>();
        Set<Id> branchIds  = new Set<Id>();

        // Collect Product & Branch IDs from new records
        for (Stock__c s : newStocks) {
            if (s.Product__c != null && s.Branch__c != null) {
                productIds.add(s.Product__c);
                branchIds.add(s.Branch__c);
            }
        }

        if (productIds.isEmpty() || branchIds.isEmpty()) {
            return;
        }

        // Fetch existing Latest stocks for same Product + Branch
        List<Stock__c> existingLatestStocks = [
            SELECT Id, Product__c, Branch__c, Stock_Date__c, Is_Latest__c
            FROM Stock__c
            WHERE Product__c IN :productIds
              AND Branch__c IN :branchIds
              AND Is_Latest__c = true
        ];

        List<Stock__c> stocksToUpdate = new List<Stock__c>();

        // Compare old vs new stock dates
        for (Stock__c oldStock : existingLatestStocks) {
            for (Stock__c newStock : newStocks) {

                if (oldStock.Product__c == newStock.Product__c &&
                    oldStock.Branch__c == newStock.Branch__c &&
                    oldStock.Id != newStock.Id &&
                    oldStock.Stock_Date__c <= newStock.Stock_Date__c) {

                    oldStock.Is_Latest__c = false;
                    stocksToUpdate.add(oldStock);
                }
            }
        }

        if (!stocksToUpdate.isEmpty()) {
            update stocksToUpdate;
        }
    }
}