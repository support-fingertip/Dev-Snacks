public without sharing class gstVerification {
    @future(callout =true)
    public static void sendDataforValidation(Id recordId){
        Integration_Details__mdt Info = [Select Endpoint__c,Token__c from Integration_Details__mdt where Active__c = true and Integrate_to__c='GSTvalidator' limit 1];
        Address__c address =[select GST_No__c,GST_Validator_Response__c,GST_Verification_Status__c from Address__c where Id=:recordId];
        
        if(address.GST_No__c != null && address.GST_No__c !='' ){
            gstWrap g=new gstWrap();
            g.gstin =address.GST_No__c;
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Info.Endpoint__c );
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Token', Info.Token__c);
            string jsonString = JSON.serialize(g);
            system.debug('jsonString:' + jsonString);
            request.setBody(jsonString);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +  response.getStatusCode() + ' ' + response.getStatus());
            } else {
                system.debug('response.getBody() :'+ response.getBody());
                map<string,object> responseval =(Map<string,Object>)JSON.deserializeUntyped(response.getBody());
                
                if(responseval.get('status') == 1){
                    string valid = JSON.serialize(responseval.get('valid')).replace('"','');
                    address.GST_Validator_Response__c ='Success ,GST valid :'+valid;  
                    address.GST_Verification_Status__c=valid;
                }
                if(responseval.get('status') == 0){
                    string message = JSON.serialize(responseval.get('message')).replace('"','');
                    address.GST_Validator_Response__c =message;  
                }
            }
            try{
                update address;       
            }
            catch(DmlException ex){
                system.debug('Error'+ ex.getMessage());
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
                getLogs.Object__c = 'Address__c';
                getLogs.RecordId__c =recordId ;
                getLogs.Type__c = 'GST Validator';
                getLogs.Status_Code__c = response.getStatusCode();
                getLogs.Status_Message__c = response.getStatus();
                insert getLogs;
                system.debug('getLogs=== '+ getLogs);
            }
            
        }
        
        
    }
    public class gstWrap{
        public string gstin{get; set;}    
    }
}