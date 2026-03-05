trigger StockTrigger on Stock__c (after insert, after update) {
    
    if (Label.Enable_Stock_Trigger == 'TRUE') {

        Set<String> ids = new Set<String>();
        Set<String> extids = new Set<String>();
        Set<String> proIds = new Set<String>();
        Set<String> rouIds = new Set<String>();

        // Collect IDs from Trigger records
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (Stock__c st : Trigger.new) {
                ids.add(st.Id);
                extids.add(String.valueOf(st.Product__c) + String.valueOf(st.Route__c) + System.today());
                proIds.add(st.Product__c);
                rouIds.add(st.Route__c);
            }
        }
        
        // Proceed only if records exist
        if (ids.size() > 0) {

            //  List<AggregateResult> aggList = [
            //      select Product__c prod,
            //             Route__c rt,
            //             Stock_Type__c typ,
            //             SUM(Available_Quantity__c) availQty,
            //             sum(Intial_Stock__c) initQty,
            //             sum(Sold_Qty__c) sldQty,
            //             sum(Free_Quantity__c) freeQty,
            //             sum(Replaced_Quantity__c) repQty
            //      from Stock__c
            //      where Id IN :ids
            //      group by Product__c, Route__c, Stock_Type__c
            //  ];
            
            List<AggregateResult> avaggList = [
                select Product__c prod,
                       Route__c rt,
                       SUM(Available_Quantity__c) availQty
                from Stock__c
                where Stock_Type__c = 'New'
                  and Product__c IN :proIds
                  and Route__c IN :rouIds
                  and (Available_Quantity__c != null and Available_Quantity__c > 0)
                group by Product__c, Route__c
            ];

            Map<String, Decimal> availMap = new Map<String, Decimal>();
            for (AggregateResult agg : avaggList) {
                String ext = String.valueOf(agg.get('prod')) +
                             String.valueOf(agg.get('rt')) +
                             System.today();
                availMap.put(ext, (Decimal) agg.get('availQty'));
            }
            
            List<AggregateResult> inaggList = [
                select Product__c prod,
                       Route__c rt,
                       SUM(Intial_Stock__c) initQty
                from Stock__c
                where CreatedDate = TODAY
                  and Stock_Type__c = 'New'
                  and Product__c IN :proIds
                  and Route__c IN :rouIds
                  and (Intial_Stock__c != null and Intial_Stock__c > 0)
                group by Product__c, Route__c
            ];

            Map<String, Decimal> initMap = new Map<String, Decimal>();
            for (AggregateResult agg : inaggList) {
                String ext = String.valueOf(agg.get('prod')) +
                             String.valueOf(agg.get('rt')) +
                             System.today();
                initMap.put(ext, (Decimal) agg.get('initQty'));
            }
            
            List<AggregateResult> damaggList = [
                select Product__c prod,
                       Route__c rt,
                       SUM(Available_Quantity__c) availQty
                from Stock__c
                where Stock_Type__c = 'Damaged'
                  and Product__c IN :proIds
                  and Route__c IN :rouIds
                  and CreatedDate = TODAY
                group by Product__c, Route__c
            ];

            Map<String, Decimal> damMap = new Map<String, Decimal>();
            for (AggregateResult agg : damaggList) {
                String ext = String.valueOf(agg.get('prod')) +
                             String.valueOf(agg.get('rt')) +
                             System.today();
                damMap.put(ext, (Decimal) agg.get('availQty'));
            }
            
            List<Stock_History__c> hisList = [
                select Id, Name, Route__c, Product__c,
                       Available_Quantity__c, Initial_Quantity__c,
                       Damaged_Quantity__c, Free_Quantity__c,
                       Sold_Quantity__c, Replaced_Quantity__c,
                       Unsealed_Quantity__c, CreatedDate, Ext_ID__c
                from Stock_History__c
                where Ext_ID__c IN :extIds
            ];

            List<Stock_History__c> hisListToUpdate = new List<Stock_History__c>();
            if (hisList.size() > 0) {
                for (Stock_History__c his : hisList) {
                    his.Available_Quantity__c =
                        availMap.containsKey(his.Ext_ID__c)
                        ? availMap.get(his.Ext_ID__c)
                        : his.Available_Quantity__c;

                    his.Initial_Quantity__c =
                        initMap.containsKey(his.Ext_ID__c)
                        ? initMap.get(his.Ext_ID__c)
                        : his.Initial_Quantity__c;

                    his.Damaged_Quantity__c =
                        damMap.containsKey(his.Ext_ID__c)
                        ? damMap.get(his.Ext_ID__c)
                        : his.Damaged_Quantity__c;

                    /* his.Unsealed_Quantity__c = freeMap.get(his.Ext_ID__c);
                       his.Sold_Quantity__c = soldMap.get(his.Ext_ID__c);
                       his.Replaced_Quantity__c = repMap.get(his.Ext_ID__c); */

                    hisListToUpdate.add(his);
                }
            }
            
            // upsert hisListToUpdate;
            // database.upsert(hisListToUpdate, false);

            try {
                update hisListToUpdate;
            }
            catch (System.Exception ae) {
                ExceptionHandler.addLog(ae, String.valueOf(hisListToUpdate));
            }
            
            /* Map<String,Decimal> soldMap = new Map<String,Decimal>();
               Map<String,Decimal> freeMap = new Map<String,Decimal>();
               Map<String,Decimal> damMap  = new Map<String,Decimal>();
               Map<String,Decimal> repMap  = new Map<String,Decimal>(); */

            /* for (AggregateResult agg : aggList) {
                   ...
               } */
        }

        // ===================================================
        //  LATEST STOCK LOGIC (MUST RUN LAST)
        // ===================================================
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            StockTriggerHandler.afterInsert(Trigger.new);
        }
    }
}