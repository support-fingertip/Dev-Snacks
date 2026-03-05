public class CreditNotePdfControllerClass 
{
    public string receipt { get; set; }
     public string siname{set;get;}
    public Branch__c branchRecord{get; set;}
    public string custmerdeatil{set;get;}
    public string custmerdeatil2{set;get;}
    public string custmerdeatil3{set;get;}
    
    public String billingAddress1 { get; set; }
    public String billingAddress2 { get; set; }
    public String shippingAddress1 { get; set; }
    public String shippingAddress2 { get; set; }
    
    public string billGST{set;get;}
    public string shipGST{set;get;}
    public boolean rateVar{get;set;}
      public String invoiceQRURL{get;set;}
    public List<Return_Item__c> returnItem {get; set; }
    public Decimal totalCashDiscount{get; set;}
    
    Public String numToWord{get;set;}
    public List<hsnGroupedItems> hsnGroupedItemList { get; set; }
    
    public Decimal sumOfTaxableValues{get; set;}
    public Decimal sumOfTaxAmountNormal{get; set;}
    public Decimal sumOfTaxAmountSez{get; set;}
    public Decimal sumOfTotalTaxAmounts{get; set;}
    public String sumOfTotalTaxAmountsInWords{get; set;}
    
    public Decimal roundoff{get; set;}
    public Decimal totalafterroundoff{get; set;}
    public CreditNotePdfControllerClass(ApexPages.StandardController controller)
    {
        Decimal sumOfTaxableValue = 0.00;
        Decimal sumOfTaxAmount = 0.00;
        Decimal sumOfTotalTaxAmount = 0.00;
        receipt = ApexPages.currentPage().getParameters().get('id');
        Set<Id> productIds = new Set<Id>();
        Return__c Rn = [select id, name,Sales_Invoice__r.Name,Route__c,Grand_Total_after_discount__c,Grand_Total_Discounted__c,Route__r.Branch_Name__c,Customer__r.CustomerType__c,Customer__c,Customer__r.name,Customer__r.GST__c,Customer__r.CustomerId__c,Customer__r.Cash_Discount__c,New_Flow__c,SignedQrCodeImgUrl__c,IRN_Number__c from Return__c where id=:receipt ];
       
        siname =Rn.Sales_Invoice__r.Name;
        
        if(Rn.Customer__r.Cash_Discount__c != null){
            totalCashDiscount = (Rn.Customer__r.Cash_Discount__c * Rn.Grand_Total_after_discount__c)/100;
        }
           if(Rn.SignedQrCodeImgUrl__c != null){
            String url = Rn.SignedQrCodeImgUrl__c.replace('"','');
            invoiceQRURL = 'https://my.gstzen.in'+url; 
        }
        custmerdeatil = Rn.Customer__r.Name ; 
        custmerdeatil2=Rn.Customer__r.CustomerId__c;
        custmerdeatil3 = Rn.Customer__r.GST__c;
        
        string Customer = [SELECT Customer__r.id FROM Return__c WHERE Id = :Rn.id].Customer__r.id;
        
        List<Address__c> billAdd = [select id,Address__c,GST_No__c,Building__c,City__c,Block__c,Country__c,District__c,State__c,Street__c,Street_No__c,Zip_Code__c from Address__c where Address_Type__c='B' and Customer__c =:Customer];
        if(billAdd.size()>0){
            billingAddress1 = getValidValue(billAdd[0].Address__c,',') +' '+getValidValue(billAdd[0].Building__c,',')+' '+getValidValue(billAdd[0].Block__c,',');
            billingAddress2 = getValidValue(billAdd[0].Street__c,',') +' '+  getValidValue(billAdd[0].Street_No__c,',')+' '+getValidValue(billAdd[0].District__c,',') +' '+getValidValue(billAdd[0].State__c,',')+getValidValue(billAdd[0].Country__c,',')+' '+getValidValue(billAdd[0].Zip_Code__c,'');
           billGST = billAdd[0].GST_No__c;
        }
        List<Address__c> shipAdd = [select id,Address__c,GST_No__c,Building__c,City__c,Block__c,Country__c,District__c,State__c,Street__c,Street_No__c,Zip_Code__c  from Address__c where Address_Type__c='S' and Customer__c =:Customer];
        if(shipAdd.size()>0){
            //shippingAddress = shipAdd[0].Address__c;
             shippingAddress1 = getValidValue(shipAdd[0].Address__c,',')+' '+getValidValue(shipAdd[0].Building__c,',')+' '+getValidValue(shipAdd[0].Block__c,',');
            shippingAddress2 = getValidValue(shipAdd[0].Street__c,',')+' '+  getValidValue(shipAdd[0].Street_No__c,',')+' '+getValidValue(shipAdd[0].District__c,',') +' '+getValidValue(shipAdd[0].State__c,',')+''+getValidValue(shipAdd[0].Country__c,',')+' '+getValidValue(shipAdd[0].Zip_Code__c,'');
            shipGST = shipAdd[0].GST_No__c;
        }
        
        returnItem = [select id, Quantity__c,Total__c,GST_Percentage__c,Sales_Tax__c,Return__r.Customer__r.Cash_Discount__c,Return__r.Customer__r.Name,Return__r.Customer__r.CustomerId__c,Unit_Price__c,Product__r.Name,Product__r.HSN_Code__c,Product__r.MRP__c,Return__r.Customer__c,Stock__r.Price__c,Damaged_Stock__r.Price__c,Cash_Discount__c,Customer_Discount__c,Total_Unit_Price__c,Rate__c from Return_Item__c where Return__c =: receipt];
        for( Return_Item__c inv : returnItem){
            if(inv.Return__r.Customer__r.Cash_Discount__c == null){
                inv.Return__r.Customer__r.Cash_Discount__c = 0.00;
            }
            if(inv.Rate__c != null){
               rateVar=true;
            }
            else{
                rateVar=false;
            }
        }
        
         
        List<Branch__c> branchRec = [select id,Account_Id__c,Account_Name__c,Address__c,Branch_Id__c,Cash_In_Hand__c,Company_Id__c,Contact_Number__c,
                                     District__c,Emails__c,GST_No__c,Name,State__c,Warehouse__c,Fssai_Licence_Number__c from Branch__c where Id =:Rn.Route__r.Branch_Name__c Limit 1];
        if(branchRec.size()>0){
            branchRecord = branchRec[0];
        }
        
        List<AggregateResult> aggrigateSalesInvoiceItems = [select Product__r.HSN_Code__c,Count(Id),SUM(Total__c)total,SUM(Quantity__c)quantity,SUM(Total_Unit_Price__c	)unitPrice,SUM(Total_after_tax__c)totalAfterTax,SUM(Total__c)totalBeforeTax,AVG(Sales_Tax__c)salesTax,SUM(Customer_Discount__c)totalafterCD
                                                            from Return_Item__c where Return__c =: Rn.Id GROUP BY Product__r.HSN_Code__c];
        system.debug('aggrigateSalesInvoiceItems=== '+aggrigateSalesInvoiceItems);
        List<hsnGroupedItems> hsnGrpItems = new List<hsnGroupedItems>();
        for(AggregateResult ager: aggrigateSalesInvoiceItems){
            hsnGroupedItems groupedItem = new hsnGroupedItems();
            groupedItem.hsnNumber = (String)ager.get('HSN_Code__c');
            groupedItem.total = (Decimal)ager.get('total');
            //groupedItem.unitPrice = (Decimal)ager.get('unitPrice');
            //groupedItem.salesTax = (Decimal)ager.get('salesTax');
            if(Rn.New_Flow__c && (Decimal)ager.get('totalafterCD') != null){
                groupedItem.unitPrice = (Decimal)ager.get('totalafterCD');
                groupedItem.totalTaxAmount = (((Decimal)ager.get('totalafterCD')*(Decimal)ager.get('salesTax'))/100);
            }
            else{
                groupedItem.unitPrice = (Decimal)ager.get('unitPrice');
              groupedItem.totalTaxAmount = (((Decimal)ager.get('unitPrice')*(Decimal)ager.get('salesTax'))/100);  
            }
            
            if(Rn.Customer__r.CustomerType__c == '1' ){
                groupedItem.centralTax = groupedItem.totalTaxAmount/2;
                groupedItem.stateTax = groupedItem.totalTaxAmount/2;
                groupedItem.centralTaxPercent = String.valueOf((Decimal)ager.get('salesTax') / 2)+'%';
                groupedItem.stateTaxPercent = String.valueOf((Decimal)ager.get('salesTax') / 2)+'%';
            }else if(Rn.Customer__r.CustomerType__c == '2'){
                groupedItem.integratedTax = groupedItem.totalTaxAmount;
                groupedItem.integratedTaxPercent = String.valueOf((Decimal)ager.get('salesTax'))+'%';
            }
            groupedItem.totalAfterTax = (Decimal)ager.get('totalAfterTax');
            groupedItem.totalBeforeTax = (Decimal)ager.get('totalBeforeTax');
              if(Rn.New_Flow__c && (Decimal)ager.get('totalafterCD') != null && (Decimal)ager.get('totalafterCD') != 0){
                sumOfTaxableValue += (Decimal)ager.get('totalafterCD');
              
            }else{
                sumOfTaxableValue += groupedItem.unitPrice;
            }
            sumOfTaxAmount += groupedItem.totalTaxAmount;
            sumOfTotalTaxAmount += groupedItem.totalTaxAmount;
            hsnGrpItems.add(groupedItem);
        }
                    
        if(hsnGrpItems.size()>0){
            hsnGroupedItemList = hsnGrpItems;
            sumOfTaxableValues = sumOfTaxableValue;
            if(Rn.Customer__r.CustomerType__c == '1'){
                sumOfTaxAmountNormal = sumOfTaxAmount / 2;
                system.debug('sumOfTaxAmountNormal=== '+sumOfTaxAmountNormal);
            }else if(Rn.Customer__r.CustomerType__c == '2'){
                sumOfTaxAmountSez = sumOfTaxAmount;
                system.debug('sumOfTaxAmountSez=== '+sumOfTaxAmountSez);
            }
            
            sumOfTotalTaxAmounts = sumOfTotalTaxAmount.setScale(2);
        }
        system.debug('hsnGroupedItemList=== '+hsnGroupedItemList);
        
        
        
        numberToWordConvertor inv = new numberToWordConvertor();
        numToWord = inv.getNumberTOWordConvertion(Rn.Grand_Total_Discounted__c);
        
        
        //Round off
        
        roundoff = (Integer)Math.ceil(sumOfTotalTaxAmount) - sumOfTotalTaxAmount;
        totalafterroundoff = roundoff + sumOfTotalTaxAmount;
        system.debug('sumOfTotalTaxAmount== '+sumOfTotalTaxAmount);
        numberToWordConvertor texAmount = new numberToWordConvertor();
        sumOfTotalTaxAmountsInWords = texAmount.getNumberTOWordConvertion(totalafterroundoff.setScale(2));
        system.debug('sumOfTotalTaxAmountsInWords== '+sumOfTotalTaxAmountsInWords);
        
        
    }
     public class hsnGroupedItems{
        public string hsnNumber{get; set;}
        public Decimal total{get; set;}
        public Decimal unitPrice{get; set;}
        public Decimal totalTaxAmount{get; set;}
        public Decimal totalAfterTax{get; set;}
        public Decimal totalBeforeTax{get; set;}
        public Decimal centralTax{get; set;}
        public Decimal stateTax{get; set;}
        public Decimal integratedTax{get; set;}
        public string centralTaxPercent{get; set;}
        public string stateTaxPercent{get; set;}
        public string integratedTaxPercent{get; set;}
    }
    public static String getValidValue(String txt,String apendtxt){
			return txt!=null?txt+apendtxt:'';
    }

}