@isTest
public class SAPGetData_Test {
    @isTest 
    static void testproPostAPI() {
        
        
        String JsonMsg='{\"data\":[{\"Name\":\"Dev Snacks peanut Masala\",\"CompanyId__c\":\"Dev\",\"Product_Code__c\":\"P010\",\"SKU__c\":\"XYZ12345\",\"Product_Image_Url__c\":\"https:images-na.ssl-images-amazon.comimages1gY92G6x1L._SY879_.jpg\",\"Item_Description__c\":\"Dev Snacks peanut Masala\",\"Brand__c\":\"DJS23\",\"Sales_Tax__c\":2,\"HSN_Code__c\":\"HSN243\",\"Purchase_Tax__c\":5},{\"Name\":\"Dev Snacks Pakkavada\",\"CompanyId__c\":\"Dev\",\"Product_Code__c\":\"P011\",\"SKU__c\":\"XYZ12345\",\"Product_Image_Url__c\":\"https:content40163233_1-dev-snacks-pakkavadaribbon-pakoda.png\",\"Item_Description__c\":\"Dev Snacks Pakkavada\",\"Brand__c\":\"DJS23\",\"Sales_Tax__c\":2,\"HSN_Code__c\":\"HSN243\",\"Purchase_Tax__c\":5}]}';
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestURI ='/services/apexrest/send/SAPGetData';
        request.params.put('key', '96ca585abb297b995fab61679e0516fb');
        request.params.put('value', 'productMaster');
        request.requestBody = Blob.valueof(JsonMsg);
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response= res;
        SAPGetData.doPost();
    }
      @isTest 
    static void testtransPostAPI() {
        
         Product__c productRec = new Product__c();
        productRec.Name = 'Dev Snacks Rosted peanut';
        productRec.Product_Code__c = 'P100';
        productRec.MRP__c = 25;
        productRec.GST__c = '5';
        insert productRec;
        
        Route__c r = new Route__c();
        r.Name = 'test route';
        insert r;
        r=[select id,name,route_id__c from route__c where id=:r.Id];
        
         Branch__c br = new Branch__c();
        br.Name = 'tesbranch';
        br.Address__c = 'Bengaluru';
        br.Branch_Id__c = 453647;
        insert br;
        Stock_Request__c sr = new Stock_Request__c();
        
        sr.Branch__c = br.Id;
        //sr.Vehicle__c = vh.id;
        sr.Route__c = r.id;
        sr.Request_Date__c = Date.NewInstance(2022,03,09);
        insert sr;
        
        Stock_Request_Item__c srt = new Stock_Request_Item__c();
        srt.Name = 'Masala';
        srt.Received_Qunatity__c = 100;
        srt.Product__c = productRec.Id;
        srt.Stock_Request__c = sr.id;
        insert srt;
        
        sr=[select id,name,Stock_Request_Id__c from Stock_Request__c where id=:sr.Id];
        srt=[select id,name,stock_request_item_id__c from Stock_Request_Item__c where id=:srt.Id];
        
        system.debug('sr:' + sr.Stock_Request_Id__c);
        system.debug('srt:' + srt.Stock_Request_Item_Id__c);
        String JsonMsg='{\"data\":[{\"CompanyId__c\":\"Dev\",\"Stock_Request_Id__c\":\"'+sr.Stock_Request_Id__c+'\",\"Transfer_Date__c\":\"2023-06-02\",\"Route_Id__c\":\"'+r.route_id__c+'\",\"Branch_Id__c\":\"'+br.Branch_Id__c+'\",\"Stock_Request_Items__r\":[{\"Stock_Request_Item_Id__c\":\"'+srt.Stock_Request_Item_Id__c+'\",\"Item_Code__c\":\"TEST2\",\"Transfered_Quantity__c\":12,\"Status__c\":\"Transferred\",\"Batch_Number__c\":\"12\",\"MRP__c\":200,\"Expiry_Date__c\":\"2023-02-14\",\"Manufacturing_Date__c\":\"2023-02-14\"},{\"Item_Code__c\":\"P100\",\"Transfered_Quantity__c\":12,\"Status__c\":\"Transferred\",\"Batch_Number__c\":\"12\",\"MRP__c\":200,\"Expiry_Date__c\":\"2023-02-14\",\"Manufacturing_Date__c\":\"2023-02-14\"}]}]}';
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestURI ='/services/apexrest/send/SAPGetData';
        request.params.put('key', '96ca585abb297b995fab61679e0516fb');
        request.params.put('value', 'StockTransfer');
        request.requestBody = Blob.valueof(JsonMsg);
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response= res;
        SAPGetData.doPost();
    }
}