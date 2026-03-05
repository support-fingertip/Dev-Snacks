public with sharing class ProductBranchLatestPriceController {

    @AuraEnabled(cacheable=true)
    public static List<BranchPriceWrapper> getLatestBranchPrice(Id productId) {

        List<Stock__c> stocks = [
            SELECT Id,
                   Branch__c,
                   Branch__r.Name,
                   Price__c,
                   Stock_Date__c
            FROM Stock__c
            WHERE Product__c = :productId
            AND Branch__c != NULL
            ORDER BY Branch__c, Stock_Date__c DESC
        ];

        Map<Id, BranchPriceWrapper> branchMap = new Map<Id, BranchPriceWrapper>();

        for (Stock__c stk : stocks) {
            if (!branchMap.containsKey(stk.Branch__c)) {
                branchMap.put(
                    stk.Branch__c,
                    new BranchPriceWrapper(
                        stk.Branch__r.Name,
                        stk.Price__c,
                        stk.Stock_Date__c
                    )
                );
            }
        }

        return branchMap.values();
    }

  
    public class BranchPriceWrapper {
        @AuraEnabled public String branchName;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Date stockDate;

        public BranchPriceWrapper(String branchName, Decimal price, Date stockDate) {
            this.branchName = branchName;
            this.price = price;
            this.stockDate = stockDate;
        }
    }
}