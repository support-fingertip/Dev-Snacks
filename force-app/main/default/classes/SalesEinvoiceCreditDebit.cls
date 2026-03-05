public  without sharing  class SalesEinvoiceCreditDebit {
 public static string sendData(Id recordId,string type){
        string code='0';
        string postfix='',mm,dd;
        integer index = 1;
        Decimal totalCGST=0,totalSGST=0,totalIGST=0,discount=0,discountPer=0;
        Decimal totalassmt=0,totalInvItemAmout =0;
        Decimal sumOfTotalItemwithdisAmount=0.0,cashDis = 0.0;
        
        
        Integration_Details__mdt eInvInfo = [Select Endpoint__c from Integration_Details__mdt where Active__c = true and Integrate_to__c='EInvoice' limit 1];
     Return__c ret = [SELECT Id,Name,Sales_Invoice__c,Return_Full_Name__c,Customer__c,CompanyId__c,Grand_Total_Discounted__c,Grand_Total_after_discount__c,Return_Date__c,New_Flow__c,Round_off__c,Return_Total__c,IRN_Status__c,GSTzen_uuid__c,IRN_Number__c,E_invoice_Generate_Date__c,Acknowledgment_No__c,Send_to_GSTZen__c,SignedQrCodeImgUrl__c,EinvMessage__c,Branch_Id__c, (SELECT Id,Name,Return_Item_Id__c,Customer_Discount__c,Item_Name__c,Product__c,Product__r.Item_Description__c,Product__r.HSN_Code__c,Quantity__c,Unit_Price__c,Sales_Tax__c,Total_after_discount__c,Total_Unit_Price__c,Cash_Discount__c FROM Invoice_Items__r) FROM Return__c where Id = :recordId];
        Account customer=[select Id,Name,State__c,CustomerType__c,Email__c,Phone,Cash_Discount__c,IgstOnIntra__c,(SELECT Id,Address__c, Building__c, Street__c, Street_No__c, Block__c, City__c, District__c, State__c, Country__c, GST_No__c, Customer__c, Address_Type__c, GST_Type__c, ZipCode__c FROM Addresses__r where Address_Type__c='S' or Address_Type__c='B' limit 2) from Account where Id =:ret.Customer__c];
        Company__mdt sellerInfo = [Select Key__c,Value__c,Phone__c,Location__c,Pin_Code__c,Leagal_Name__c,GST_State_Code__c,Gstin__c,Email__c,Addr2__c,Addr1__c from Company__mdt where Company__c=:ret.CompanyId__c and Branch_Id__c =:ret.Branch_Id__c limit 1];
        
        
        Address__c Billadd = new Address__c();
        Address__c Shipadd = new Address__c();
        if(customer.Addresses__r.size() > 0){
            for(Address__c ad : customer.Addresses__r){
                if(ad.Address_Type__c =='B')
                    Billadd =ad;
                if(ad.Address_Type__c =='S')
                    Shipadd =ad;
            } 
        }
        
        State_Code__c pstate = State_Code__c.getValues(customer.State__c);  
        State_Code__c bstate = State_Code__c.getValues(Billadd.State__c);    
        State_Code__c sstate = State_Code__c.getValues(Shipadd.State__c);     
        
        EInvoice eInv = new EInvoice();
        eInv.Version ='1.1';
        DocDtls doc= new DocDtls();
        doc.Typ ='CRN';
        doc.No = ret.Return_Full_Name__c;
        date dateDt = ret.Return_Date__c;
        if(dateDt.month() <10){
            mm ='0'+string.valueOf(dateDt.month()); 
        } else{
            mm =string.valueOf(dateDt.month()); 
        }
        if(dateDt.day() <10){
            dd ='0'+string.valueOf(dateDt.day()); 
        } else{
            dd =string.valueOf(dateDt.day()); 
        }
        doc.Dt = dd + '/' + mm + '/' + dateDt.year();
        eInv.DocDtls = doc;
        
        BuyerDtls buyr = new BuyerDtls();
        buyr.Em = null;
        buyr.Ph =null;
        buyr.Loc = Billadd.City__c;
        buyr.Pin = integer.valueOf(Billadd.ZipCode__c);
        buyr.Pos = sstate.Code__c; //State code of Place of supply. If POS lies outside the country, the code shall be 96.
        buyr.Stcd = bstate.Code__c;
        buyr.Addr1 = Billadd.Address__c;
        buyr.Addr2 = Billadd.Street__c+' '+Billadd.Street_No__c +','+Billadd.City__c;
        buyr.Gstin=Billadd.GST_No__c;
        buyr.LglNm = customer.Name;
        eInv.BuyerDtls =buyr;
        
        ShipDtls shp = new ShipDtls();
        shp.Gstin = Shipadd.GST_No__c;
        shp.LglNm = customer.Name;
        shp.Addr1 = Shipadd.Address__c;
        shp.Addr2 = Shipadd.Street__c+' '+Shipadd.Street_No__c +','+Shipadd.City__c;
        shp.Loc = Shipadd.City__c;
        shp.Pin = integer.valueOf(Shipadd.ZipCode__c);
        shp.Stcd = sstate.Code__c;
        eInv.ShipDtls = shp;
        
        SellerDtls sel = new SellerDtls();
        sel.Em = sellerInfo.Email__c;
        sel.Ph = sellerInfo.Phone__c;
        sel.Loc = sellerInfo.Location__c;
        sel.Pin = integer.valueOf(sellerInfo.Pin_Code__c);
        sel.Stcd = sellerInfo.GST_State_Code__c;
        sel.Addr1 = sellerInfo.Addr1__c;
        sel.Addr2 = sellerInfo.Addr2__c;
        sel.Gstin =sellerInfo.Gstin__c;
        sel.LglNm =sellerInfo.Leagal_Name__c;
        eInv.SellerDtls =sel;  
        //  EwbDtls eb = new EwbDtls();
        // eb.VehNo ='KA33A1234';
        // eb.TransId ='29AAFCC9980M1ZR';
        // eb.VehType ='R';
        // eb.Distance =0;
        // eb.TransMode ='1';
        // eb.TransName ='Test';
        //  eInv.EwbDtls = eb;  
        TranDtls tran = new TranDtls();
        tran.RegRev ='N';
        if(customer.IgstOnIntra__c && customer.CustomerType__c == '2'){
            tran.SupTyp='SEZWP';  
            tran.IgstOnIntra ='Y';  
        }
        else{
            tran.SupTyp='B2B';
            tran.IgstOnIntra ='N';  
        }
        tran.TaxSch ='GST';
        tran.EcmGstin = null;
        eInv.TranDtls = tran;   
        list<Item> items = new list<Item>();
        if(ret.Invoice_Items__r.size() > 0){
            for(Return_Item__c  retItem : ret.Invoice_Items__r){
                decimal   totalTaxAmount =0;
                totalInvItemAmout =0;
                discountPer =retItem.Cash_Discount__c !=null ?retItem.Cash_Discount__c :0; 
                if(discount != 0){
                    discount =  ((retItem.Unit_Price__c * discountPer)/100); 
                }else{
                    discount = 0; 
                }
                Item it = new Item();
                it.SlNo = String.valueof(index++);
                it.PrdDesc = retItem.Product__r.Item_Description__c;
                it.IsServc ='N';
                //it.HsnCd = '11010000'; 
                it.HsnCd = retItem.Product__r.HSN_Code__c;         
                it.Qty = retItem.Quantity__c;
                it.Unit ='PAC';
                it.UnitPrice = (retItem.Unit_Price__c).setScale(2, RoundingMode.HALF_UP);
                it.TotAmt = (retItem.Total_Unit_Price__c).setScale(2, RoundingMode.HALF_UP);  
                
                if(ret.New_Flow__c && (retItem.Customer_Discount__c != null && retItem.Customer_Discount__c != 0 )){
                    it.Discount = (it.TotAmt - retItem.Customer_Discount__c).setScale(2, RoundingMode.HALF_UP); 
                }
                else{
                    it.Discount =0;      
                }
                
                it.AssAmt = it.TotAmt - it.Discount;  
                totalassmt +=it.AssAmt;
                // totalInvItemAmout = (invItem.Total_Before_Tax__c).setScale(2, RoundingMode.HALF_UP);
                if(retItem.Sales_Tax__c < 1){
                    it.GstRt = 0;   
                }else{
                    it.GstRt = retItem.Sales_Tax__c;  
                } 
                totalTaxAmount = ((it.AssAmt * retItem.Sales_Tax__c)/100).setScale(2, RoundingMode.HALF_UP); 
                
                if(customer.CustomerType__c == '1' ){
                    decimal taxamount = totalTaxAmount/2;
                    it.CgstAmt = taxamount.setScale(2, RoundingMode.HALF_UP);  
                    totalCGST += taxamount;
                    it.SgstAmt = taxamount.setScale(2, RoundingMode.HALF_UP);  
                    totalSGST += taxamount;
                    it.IgstAmt = 0;
                }else if(customer.CustomerType__c == '2'){
                    it.IgstAmt = totalTaxAmount;
                    it.CgstAmt = 0;    
                    it.SgstAmt =0;   
                    totalIGST += totalTaxAmount ;
                }
                it.TotItemVal = (retItem.Total_after_discount__c).setScale(2, RoundingMode.HALF_UP);
                sumOfTotalItemwithdisAmount +=retItem.Total_after_discount__c;
                items.add(it);
            }
            eInv.ItemList = items; 
        }
        
        cashDis = ret.Grand_Total_after_discount__c - ret.Grand_Total_Discounted__c;
        if(cashDis < 0){
            cashDis =0; 
        }
        ValDtls val = new ValDtls();
        val.AssVal = totalassmt.setScale(2, RoundingMode.HALF_UP);
        val.CgstVal = totalCGST.setScale(2, RoundingMode.HALF_UP);
        val.IgstVal = totalIGST.setScale(2, RoundingMode.HALF_UP);
        val.OthChrg =0;
        val.SgstVal = totalSGST.setScale(2, RoundingMode.HALF_UP);
        if(ret.New_Flow__c){
            val.Discount=0;
        }
        else{
            val.Discount= cashDis.setScale(2, RoundingMode.HALF_UP);
        }
       
        val.StCesVal =0;
        val.RndOffAmt = ret.Round_off__c;
        val.TotInvVal = ret.Return_Total__c;
        val.TotItemValSum = (sumOfTotalItemwithdisAmount).setScale(2, RoundingMode.HALF_UP);
        eInv.ValDtls =val;
      // if(type =='Generate')
        //   postfix='';   
        if(type == 'Cancel'){
            postfix = 'cancel/';     
        }
  
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(eInvInfo.Endpoint__c + postfix);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Token', sellerInfo.Value__c);
        String jsonString = JSON.serialize(eInv);
        system.debug('jsonString:' + jsonString);
        request.setBody(jsonString);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +  response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug( response.getBody());
            map<string,object> responseval =(Map<string,Object>)JSON.deserializeUntyped(response.getBody());
            ret.EinvMessage__c =JSON.serialize(responseval.get('message'));
            //code=(String)responseval.get('status');
            if(responseval.get('status') == 1){
                ret.Send_to_GSTZen__c = true;
                ret.SignedQrCodeImgUrl__c = JSON.serialize(responseval.get('SignedQrCodeImgUrl')).replace('"','');
                         ret.IRN_Number__c = JSON.serialize(responseval.get('Irn')).replace('"','');
                  if(type == 'Generate'){
                    ret.Acknowledgment_No__c = JSON.serialize(responseval.get('AckNo'));
                    ret.E_invoice_Generate_Date__c = JSON.serialize(responseval.get('AckDt')).replace('"','');
                }
                ret.GSTzen_uuid__c = JSON.serialize(responseval.get('uuid')).replace('"','');
                if(type == 'Cancel')
                    ret.E_invoice_Generate_Date__c = JSON.serialize(responseval.get('CancelDate')).replace('"','');
                ret.IRN_Status__c = JSON.serialize(responseval.get('IrnStatus')).replace('"','');
            
            }
            
            try{
                update ret;       
            }
            catch(DmlException ex){
                system.debug('Error'+ ex.getMessage());
            }
        }
        if(label.Enable_Logs == 'TRUE'){
            String reqsizeString = jsonString;
            Integer maxSize = 32000;
            if(reqsizeString.length() > maxSize ){
                reqsizeString = reqsizeString.substring(0, maxSize);
            }
            String ressizeString =  response.getBody();
            if(ressizeString.length() > maxSize ){
                ressizeString = ressizeString.substring(0, maxSize);
            }           
            Log__c getLogs = new Log__c();
            getLogs.Request__c = reqsizeString;
            getLogs.Response__c = ressizeString;
            getLogs.Object__c = 'Return__c';
            getLogs.RecordId__c =recordId ;
            getLogs.Type__c = 'E Credit Note - '+ type;
            getLogs.Status_Code__c = response.getStatusCode();
            getLogs.Status_Message__c = response.getStatus();
            insert getLogs;
            system.debug('getLogs=== '+ getLogs);
        }
        
        return response.getBody();
    }
    
    
    public class EInvoice{
        public DocDtls DocDtls{get; set;}  
        public ValDtls ValDtls{get; set;} 
        public string Version{get; set;} 
        list<Item> ItemList{get; set;} 
        public TranDtls TranDtls{get; set;} 
        public BuyerDtls BuyerDtls{get; set;} 
        public ShipDtls ShipDtls{get; set;} 
        public SellerDtls SellerDtls{get; set;} 
        public EwbDtls EwbDtls{get; set;} 
    }
    
    
    public class TranDtls {
        public String IgstOnIntra {get; set;}
        public String EcmGstin {get; set;}  
        public String TaxSch {get; set;}  
        public String SupTyp {get; set;}  
        public String RegRev {get; set;}     
    } 
    public class DocDtls {
        public String Typ {get; set;}  
        public String No {get; set;}  
        public string Dt {get; set;}   
    }
    public class SellerDtls {
        public String LglNm {get; set;} 
        public String Gstin {get; set;}  
        public String Addr2 {get; set;} 
        public String Addr1 {get; set;} 
        public String Stcd {get; set;} 
        public integer Pin {get; set;} 
        public String Loc {get; set;}  
        public String Ph {get; set;} 
        public String Em {get; set;} 
    }
    public class BuyerDtls {
        public String LglNm {get; set;} 
        public String Gstin {get; set;}  
        public String Addr2 {get; set;} 
        public String Addr1 {get; set;}  
        public String Stcd {get; set;}
        public String Pos {get; set;}  
        public integer Pin {get; set;} 
        public String Loc {get; set;}  
        public String Ph {get; set;} 
        public String Em {get; set;} 
    }
    public class DispDtls {
        public String Nm {get; set;}  
        public String Addr1 {get; set;}  
        public String Addr2 {get; set;}  
        public String Loc {get; set;}   
        public integer Pin {get; set;}  
        public String Stcd {get; set;}  
    } 
    public class ShipDtls {
        public String Gstin {get; set;}  
        public String LglNm {get; set;}  
        public String TrdNm {get; set;}    
        public string Addr1 {get; set;}  
        public String Addr2 {get; set;}  
        public String Loc {get; set;}  
        public integer Pin {get; set;}  
        public String Stcd {get; set;}  
    } 
    public class Item {
        public String SlNo {get; set;}  
        public String PrdDesc {get; set;}  
        public String IsServc {get; set;}    
        public string HsnCd {get; set;}  
        public String Barcde {get; set;}  
        public Double Qty {get; set;}  
        public Double FreeQty {get; set;}  
        public String Unit {get; set;}  
        public Double UnitPrice {get; set;}  
        public Double TotAmt {get; set;}  
        public Double Discount {get; set;} 
        public integer PreTaxVal {get; set;}  
        public Double AssAmt {get; set;}  
        public Double GstRt {get; set;}    
        public Double IgstAmt {get; set;}  
        public Double CgstAmt {get; set;} 
        public Double SgstAmt {get; set;}  
        public Double CesRt {get; set;}  
        public Double CesAmt {get; set;}  
        public integer CesNonAdvlAmt {get; set;}  
        public integer StateCesRt {get; set;}  
        public Double StateCesAmt {get; set;}  
        public integer StateCesNonAdvlAmt {get; set;}  
        public Double OthChrg {get; set;}  
        public Double TotItemVal {get; set;}  
        
    } 
    public class EwbDtls {
        public String VehNo {get; set;}  
        public String TransId {get; set;}  
        public String VehType {get; set;}  
        public Double Distance {get; set;}   
        public string TransMode {get; set;}  
        public String TransName {get; set;}  
    } 
    public class ValDtls {
        public Double AssVal {get; set;}  
        public Double CesVal {get; set;}  
        public Double CgstVal {get; set;}  
        public Double IgstVal {get; set;}  
        public Double OthChrg {get; set;}  
        public Double SgstVal {get; set;}
        public Double Discount {get; set;}  
        public Double StCesVal {get; set;}  
        public Double RndOffAmt {get; set;}  
        public Double TotInvVal {get; set;}  
        public Double TotItemValSum {get; set;}  
        
    } 
    
}