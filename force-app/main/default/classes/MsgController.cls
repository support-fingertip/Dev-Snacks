public class MsgController {
    
    @AuraEnabled
    public static String checkAddresses(String recId){
        //List<Address__c> addlist = [select Id,Address_Type__c from Address__c where Customer__c = :recId];
        
        Account acc = [select Id,Name,(select Id,Address_Type__c from Addresses__r),(select Id from Margins__r) from Account where Id=:recId];
        
        if(acc.Addresses__r.size() > 0){
            Boolean ship=false,bill=false;
            for(Address__c add: acc.Addresses__r){
                if(add.Address_Type__c == 'S'){
                    ship = true;
                }
                if(add.Address_Type__c == 'B'){
                    bill=true;
                }
            }
            
            if(ship == false){
                return 'Please add Shipping Address.';
            }
            if(bill == false){
                return 'Please add Billing Address.';
            }
        }
        else{
            return 'Please add Addresses.';
        }
    
        
       /* if(acc.Discount1__r.size() == 0){
            return 'Please add atleast 1 margin.';
        }*/
        
        return  '';
    }

}