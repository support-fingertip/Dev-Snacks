public class InvoicePDFControllerClass {
    
    public string receipt { get; set; }
    Public String numToWord{get;set;}
   public List<Sales_Invoice_Item__c> invoiceItems {get; set; }
    public Branch__c branchRecord{get; set;}
    public String billingAddress1 { get; set; }
    public String billingAddress2 { get; set; }
    public String shippingAddress1 { get; set; }
    public String shippingAddress2 { get; set; }
    public List<hsnGroupedItems> hsnGroupedItemList { get; set; }
    public Decimal sumOfTaxableValues{get; set;}
    public Decimal sumOfTaxAmountNormal{get; set;}
    public Decimal sumOfTaxAmountSez{get; set;}
    public Decimal sumOfTotalTaxAmounts{get; set;}
    public String sumOfTotalTaxAmountsInWords{get; set;}
    public string custmerdeatil{set;get;}
    public string custmerdeatil2{set;get;}
    public string custmerdeatil3{set;get;}
    public string custmerdeatil4{set;get;}
    public string billGST{set;get;}
    public string shipGST{set;get;}
    public Decimal totalCashDiscount{get; set;}
    public string siname{set;get;}
    public Decimal roundoff{get; set;}
    public Decimal totalafterroundoff{get; set;}
    public String invoiceQRURL{get;set;}
    public String PurchaseOrder{get;set;}
    public boolean rateVar{get;set;}
    
    public InvoicePDFControllerClass(ApexPages.StandardController controller){
        Decimal sumOfTaxableValue = 0.00;
        Decimal sumOfTaxAmount = 0.00;
        Decimal sumOfTotalTaxAmount = 0.00;
        
        map<string,Sales_Invoice_Item__c> invoiceItemMap=new  map<string,Sales_Invoice_Item__c>();
          Sales_Invoice_Item__c sInv=new  Sales_Invoice_Item__c();
        
        receipt = ApexPages.currentPage().getParameters().get('id');
        Set<Id> productIds = new Set<Id>();
        Sales_Invoice__c si = [select id,Name,Route__c,New_Flow__c, Purchase_Order__c,Route__r.Branch_Name__c,Customer__r.Phone,Customer__r.CustomerType__c,Customer__c,Customer__r.name,Customer__r.GST__c,Customer__r.CustomerId__c,Customer__r.Cash_Discount__c,Grand_Total_after_discount__c, Grand_Total_Discounted__c,Sales_Order__r.Name,SignedQrCodeImgUrl__c,Send_to_GSTZen__c,Payment_Type__c,Invoice_Total__c from Sales_Invoice__c where Id=:receipt];
        
        siname =si.Sales_Order__r.Name;
        if(si.Customer__r.Cash_Discount__c != null){
            totalCashDiscount = (si.Customer__r.Cash_Discount__c * si.Grand_Total_after_discount__c)/100;
        }
        if(si.Purchase_Order__c != null){
            PurchaseOrder = si.Purchase_Order__c;
        }
        if(si.SignedQrCodeImgUrl__c != null){
            String url = si.SignedQrCodeImgUrl__c.replace('"','');
            invoiceQRURL = 'https://my.gstzen.in'+url; 
        }
        system.debug(si+'WORLD');
        string Customer = [SELECT Customer__r.id FROM Sales_Invoice__c WHERE Id = :si.id].Customer__r.id;
        system.debug(Customer+'HELLO');
       List<Sales_Invoice_Item__c> salesinvoiceItems  = [select id, Product__c,Quantity__c,Product_Discount_Amount__c,Total_Discount__c,Total_after_discount__c,Total_Before_Tax__c,Sales_Tax__c,Customer_Discount__c,Cash_Discount__c,Sales_Invoice__r.Customer__r.Cash_Discount__c,Sales_Invoice__r.Customer__r.Name,Sales_Invoice__r.Customer__r.CustomerId__c, Discount_Percent__c,Unit_Price__c,Product__r.Name,Product__r.HSN_Code__c,Product__r.MRP__c,Sales_Invoice__r.Grand_Total_Discounted__c,Sales_Invoice__r.Customer__c,GST_Percentage__c,Stock__r.Price__c,Rate__c from Sales_Invoice_Item__c where Sales_Invoice__c =: receipt order by Item_Name__c];
        for(Sales_Invoice_Item__c inv : salesinvoiceItems){
            if(inv.Sales_Invoice__r.Customer__r.Cash_Discount__c == null){
                inv.Sales_Invoice__r.Customer__r.Cash_Discount__c = 0.00;
            }
            if(inv.Rate__c != null){
                rateVar=true;
            }
            else{
                rateVar=false;
            }
            string compositekey = inv.Product__c+''+inv.Stock__r.Price__c+''+inv.Rate__c;
            if(invoiceItemMap.containsKey(compositekey)){
                 sInv =invoiceItemMap.get(compositekey);
                sInv.Quantity__c+= inv.Quantity__c;
                sInv.Unit_Price__c+= inv.Unit_Price__c;
                sInv.Total_Before_Tax__c+= inv.Total_Before_Tax__c;
                sInv.Total_after_discount__c+=inv.Total_after_discount__c;
                invoiceItemMap.put(compositekey,sInv);
                system.debug(sInv);
            }else{
                invoiceItemMap.put(compositekey,inv);
            }
            
        }
        
        invoiceItems=invoiceItemMap.values();
        //salesinvoice =[select id,name,Customer__r.name,Customer__r.CustomerId__c from Sales_Invoice__c where id =:receipt];
        custmerdeatil = si.Customer__r.Name ; 
        custmerdeatil2=si.Customer__r.CustomerId__c;
        custmerdeatil3 = si.Customer__r.GST__c;
        custmerdeatil4 =si.Customer__r.Phone;
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
        
        List<Branch__c> branchRec = [select id,Account_Id__c,Account_Name__c,Address__c,Branch_Id__c,Cash_In_Hand__c,Company_Id__c,Contact_Number__c,
                                     District__c,Emails__c,GST_No__c,Name,State__c,Warehouse__c,Fssai_Licence_Number__c from Branch__c where Id =:si.Route__r.Branch_Name__c Limit 1];
        if(branchRec.size()>0){
            branchRecord = branchRec[0];
        }
        
        List<AggregateResult> aggrigateSalesInvoiceItems = [select Product__r.HSN_Code__c,Count(Id),SUM(Total__c)total,SUM(Quantity__c)quantity,SUM(Total_Unit_Price__c	)unitPrice,SUM(Total_after_tax__c)totalAfterTax,SUM(Total_Before_Tax__c)totalBeforeTax,AVG(Sales_Tax__c)salesTax,SUM(Customer_Discount__c)totalafterCD
                                                            from Sales_Invoice_Item__c where Sales_Invoice__c =: si.Id GROUP BY Product__r.HSN_Code__c];
        system.debug('aggrigateSalesInvoiceItems=== '+aggrigateSalesInvoiceItems);
        List<hsnGroupedItems> hsnGrpItems = new List<hsnGroupedItems>();
        for(AggregateResult ager: aggrigateSalesInvoiceItems){
            hsnGroupedItems groupedItem = new hsnGroupedItems();
            groupedItem.hsnNumber = (String)ager.get('HSN_Code__c');
            groupedItem.total = (Decimal)ager.get('total');
            
            
            //groupedItem.salesTax = (Decimal)ager.get('salesTax');
            if(si.New_Flow__c && (Decimal)ager.get('totalafterCD') != null){
                groupedItem.unitPrice = (Decimal)ager.get('totalafterCD');
                groupedItem.totalTaxAmount = (((Decimal)ager.get('totalafterCD')*(Decimal)ager.get('salesTax'))/100);
            }
            else{
                groupedItem.unitPrice = (Decimal)ager.get('unitPrice');
                groupedItem.totalTaxAmount = (((Decimal)ager.get('unitPrice')*(Decimal)ager.get('salesTax'))/100);  
            }
            
            if(si.Customer__r.CustomerType__c == '1' ){
                groupedItem.centralTax = groupedItem.totalTaxAmount/2;
                groupedItem.stateTax = groupedItem.totalTaxAmount/2;
                groupedItem.centralTaxPercent = String.valueOf((Decimal)ager.get('salesTax') / 2)+'%';
                groupedItem.stateTaxPercent = String.valueOf((Decimal)ager.get('salesTax') / 2)+'%';
            }else if(si.Customer__r.CustomerType__c == '2'){
                groupedItem.integratedTax = groupedItem.totalTaxAmount;
                groupedItem.integratedTaxPercent = String.valueOf((Decimal)ager.get('salesTax'))+'%';
            }
            groupedItem.totalAfterTax = (Decimal)ager.get('totalAfterTax');
            groupedItem.totalBeforeTax = (Decimal)ager.get('totalBeforeTax');
            if(si.New_Flow__c && (Decimal)ager.get('totalafterCD') != null  && (Decimal)ager.get('totalafterCD') != 0){
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
            if(si.Customer__r.CustomerType__c == '1'){
                sumOfTaxAmountNormal = sumOfTaxAmount / 2;
                system.debug('sumOfTaxAmountNormal=== '+sumOfTaxAmountNormal);
            }else if(si.Customer__r.CustomerType__c == '2'){
                sumOfTaxAmountSez = sumOfTaxAmount;
                system.debug('sumOfTaxAmountSez=== '+sumOfTaxAmountSez);
            }
            
            sumOfTotalTaxAmounts = sumOfTotalTaxAmount.setScale(2);
        }
        system.debug('hsnGroupedItemList=== '+hsnGroupedItemList);
        
        
        numberToWordConvertor inv = new numberToWordConvertor();
        numToWord = inv.getNumberTOWordConvertion(si.Invoice_Total__c);
        system.debug('numToWord== '+numToWord);
        // new code =====================================
        //roundoff = (Integer)Math.ceil(sumOfTotalTaxAmount) - sumOfTotalTaxAmount;
        //totalafterroundoff = roundoff + sumOfTotalTaxAmount;
        totalafterroundoff = sumOfTotalTaxAmount.round(RoundingMode.HALF_UP);
        roundoff = totalafterroundoff > sumOfTotalTaxAmount? totalafterroundoff - sumOfTotalTaxAmount : sumOfTotalTaxAmount - totalafterroundoff;
        system.debug('sumOfTotalTaxAmount== '+sumOfTotalTaxAmount);
          system.debug('totalafterroundoff== '+totalafterroundoff);
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