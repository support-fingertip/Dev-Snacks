@isTest
public class sapApiController_Test {
    @isTest
     static void testproPostAPI() {     
        String JsonMsg='[{\"CompanyId__c\":\"Dev\",\"Employee_Id__c\":\"EMP-100022\",\"Name\":\"Tesme56\",\"Mobile__c\":\"100002023\",\"Email__c\":\"NewabcCust4@gmail.com\",\"Designation__c\":\"Director\",\"Role__c\":\"Driver\"}]';
     Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
         RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
        request.requestUri ='/api/CreateEmployee'; 
        request.httpMethod = 'POST';
         request.params.put('key','96ca585abb297b995fab61679e0516fb');
          request.params.put('value','employees');
        RestContext.request = request;
             request.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = request;
        RestContext.response= res;
         sapApiController.doGet();
            
     }
@isTest
    static void testPostAPI1() {
          Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
          String JsonMsg='[{\"Margins__r\":[{\"GST_Percentage__c\":\"5\",\"Discount_Percent__c\":12,\"Name\":\"Dis-0030\",\"Id\":\"a0aN000000BrNbwIAF\",\"Customer__c\":\"001N000002AkH0VIAV\"}],\"Addresses__r\":[{\"RowNum__c\":1,\"GST_No__c\":\"22ASWEy1234DAZA\",\"Country__c\":\"IN\",\"State__c\":\"KL\",\"ZipCode__c\":12345,\"District__c\":\"Kannur\",\"City__c\":\"c1\",\"Block__c\":\"b1\",\"Street_No__c\":\"s2\",\"Street__c\":\"s1\",\"Building__c\":\"b1\",\"Address__c\":\"test\",\"Address_Type__c\":\"S\",\"Name\":\"ADD-0080\",\"Id\":\"a0pN0000009eaycIAA\",\"Customer__c\":\"001N000002AkH0VIAV\"}],\"CustomerType__c\":\"1\",\"Pan_Number__c\":\"ASWER1234D\",\"Email__c\":\"sapcust1@gmail.com\",\"CustomerGroupCode__c\":\"100\",\"CardType__c\":\"C\",\"CustomerId__c\":\"C-0163\",\"CompanyId__c\":\"Dev\",\"Name\":\"SAP cust1\",\"Id\":\"001N000002AkH0VIAV\"}]';
       RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
        request.requestUri ='/api/CustomerCreation'; 
        request.httpMethod = 'POST';
         request.params.put('key','96ca585abb297b995fab61679e0516fb');
          request.params.put('value','customers');
        RestContext.request = request;
             request.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = request;
        RestContext.response= res;
         sapApiController.doGet();
         test.stopTest();  
    }
    @isTest
    static void testPostAPI2() {
          Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
          String JsonMsg='[{\"CompanyId__c\":\"Dev\",\"Route_Id__c\":\"RCT-10001\",\"Name\":\"KL39\",\"State__c\":\"TVS2\",\"District__c\":\"121\",\"Week__c\":\"FIR\",\"Week_Sales__c\":\"FRI\"}]';
       RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
        request.requestUri ='/api/CreateRouteMaster'; 
        request.httpMethod = 'POST';
         request.params.put('key','96ca585abb297b995fab61679e0516fb');
          request.params.put('value','routes');
        RestContext.request = request;
             request.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = request;
        RestContext.response= res;
         sapApiController.doGet();
         test.stopTest();  
    }
     @isTest
    static void testPostAPI3() {
          Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
          String JsonMsg='[{\"Invoice_Items__r\":[{\"Batch_No__c\":\"ABC\",\"Unit_Price__c\":30,\"Quantity__c\":1,\"Item_Name__c\":\"a0IN000000BVkU4\",\"Item_Code__c\":\"TEST1\",\"Inv_Line_Items_Id__c\":\"ITEM-1444\",\"Name\":\"ITEM-1438\",\"Id\":\"a0kN000000F2TgCIAV\",\"Sales_Invoice__c\":\"a0jN000000CHJZkIAP\"}],\"Customer_Id__c\":\"C-0001\",\"Invoice_Number__c\":\"0543\",\"Tax_Date__c\":\"2023-06-01\",\"Doc_Date__c\":\"2023-06-01\",\"Branch_Id__c\":1,\"Driver_Code__c\":\"test driver\",\"Route_Id__c\":\"SKEKLM01\",\"CompanyId__c\":\"Dev\",\"Name\":\"2001\",\"Id\":\"a0jN000000CHJZkIAP\"}]';
       RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
        request.requestUri ='/api/CreateARInvoice'; 
        request.httpMethod = 'POST';
         request.params.put('key','96ca585abb297b995fab61679e0516fb');
          request.params.put('value','invoices');
        RestContext.request = request;
             request.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = request;
        RestContext.response= res;
         sapApiController.doGet();
         test.stopTest();  
    }
    
    
         @isTest
    static void testPostAPI4() {
          Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
          String JsonMsg='[{\"CompanyId__c\":\"Dev\",\"Code__c\":\"KL393334\",\"Vehicle_Number__c\":\"KL393344\",\"Model__c\":\"TVS\",\"Engine__c\":\"101\",\"Capacity__c\":\"1000CC\",\"Registration_Date__c\":\"2022-12-31\"}]';
       RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
        request.requestUri ='/api/CreateVehicleMaster'; 
        request.httpMethod = 'POST';
         request.params.put('key','96ca585abb297b995fab61679e0516fb');
          request.params.put('value','vehicles');
        RestContext.request = request;
             request.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = request;
        RestContext.response= res;
         sapApiController.doGet();
         test.stopTest();  
    }
    
             @isTest
    static void testPostAPI5() {
          Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
          String JsonMsg='[{\"Stock_Request_Items__r\":[{\"Stock_Request_Item_Id__c\":\"79\",\"Quantity__c\":1,\"Item_Code__c\":\"TEST1\",\"Name\":\"a0IN000000BVkU4\",\"Id\":\"a0eN0000009s7SuIAI\",\"Stock_Request__c\":\"a0dN000000HuquVIAR\"}],\"Route_Id__c\":\"SKEKLM01\",\"Branch_Id__c\":1,\"Request_Date__c\":\"2023-06-01\",\"Stock_Request_Id__c\":\"REQ-0067\",\"CompanyId__c\":\"Dev\",\"Name\":\"REQ-0066\",\"Id\":\"a0dN000000HuquVIAR\"}]';
       RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
        request.requestUri ='/api/InventoryTransferRequest'; 
        request.httpMethod = 'POST';
         request.params.put('key','96ca585abb297b995fab61679e0516fb');
          request.params.put('value','stockRequests');
        RestContext.request = request;
             request.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = request;
        RestContext.response= res;
         sapApiController.doGet();
         test.stopTest();  
    }
        
         @isTest
    static void testPostAPI6() {
          Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
          String JsonMsg='[{\"Account_Name__c\":\"Fuel Expenses (Kerala)\",\"Account_Code__c\":\"512018-01\",\"Account_Id__c\":\"_SYS00000002064\",\"Total_Amount__c\":84,\"Expense_Id__c\":\"Exp-0020\",\"Expense_Date__c\":\"2023-06-01\",\"Branch_Id__c\":1,\"CompanyId__c\":\"Ice\",\"Name\":\"EP-00019\",\"Id\":\"a07N000000TUG1jIAH\"}]';
       RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
        request.requestUri ='/api/CreateJournalEntry'; 
        request.httpMethod = 'POST';
         request.params.put('key','96ca585abb297b995fab61679e0516fb');
          request.params.put('value','expenses');
        RestContext.request = request;
             request.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = request;
        RestContext.response= res;
         sapApiController.doGet();
         test.stopTest();  
    }
    
             @isTest
    static void testPostAPI7() {
          Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
          String JsonMsg='[{\"CompanyId__c\":\"Dev\",\"Receipt_Id__c\":\"11\",\"Customer_Id__c\":\"C-0001\",\"Branch_Id__c\":1,\"Amount__c\":2688,\"Receipt_Date__c\":\"2023-04-19\",\"Tax_Date__c\":\"2023-04-19\",\"Mode_of_payment__c\":\"Cash\",\"Receipt_Items__r\":[{\"Receipt_Item_Id__c\":\"1\",\"Invoice_Id__c\":\"11\",\"Amount__c\":2688}]}]';
       RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
        request.requestUri ='/api/CreateIncomingPay'; 
        request.httpMethod = 'POST';
         request.params.put('key','96ca585abb297b995fab61679e0516fb');
          request.params.put('value','receipts');
        RestContext.request = request;
             request.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = request;
        RestContext.response= res;
         sapApiController.doGet();
         test.stopTest();  
    }
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}