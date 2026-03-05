public class newStoreController {

    @AuraEnabled
    public string defaultCompany {get; set;}
    @AuraEnabled
    public Map<String,string> companyNamesMap{get; set;}
    @AuraEnabled
    public Map<String,string> customerTypeMap{get; set;}
    /*@AuraEnabled
    public Id defaultRecordTypeId {get; set;}
     @AuraEnabled
    public Map<Id, String> contactRecordTypes {get; set;}*/

    public class dataBox{
        @AuraEnabled
        public List<Warehouse__c> whList {get; set;} 
        @AuraEnabled
        public string listId {get; set;} 
    }
    
    @AuraEnabled
    public static newStoreController getCompany(){
        boolean hasDefaultCompanyName = false;
        newStoreController obj = new newStoreController();
        User currentUser = [select Id,Company_Name__c from User where Id =: userinfo.getUserId()];
        
        Map<String,string> pickListValuesMap = new Map<String,string>();
        Schema.DescribeFieldResult fieldResult = Account.CompanyId__c.getDescribe();
        //system.debug('fieldResult=== '+fieldResult);
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        system.debug('picklistValues=== '+picklistValues);
         for( Schema.PicklistEntry pickListVal : picklistValues){
             system.debug('pickListVal=== '+pickListVal);
            pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
        } 
        obj.companyNamesMap = pickListValuesMap;
        System.debug('Values in Rating are: '+obj.companyNamesMap);
        
        if(currentUser.Company_Name__c != null && currentUser.Company_Name__c != ''){
            obj.defaultCompany = currentUser.Company_Name__c;
        }
        system.debug('companyNames=== '+obj);
        return obj;
    }
    
    @AuraEnabled
    public static newStoreController getCustomerType(){
        boolean hasDefaultCompanyName = false;
        newStoreController obj = new newStoreController();
        
        Map<String,string> pickListValuesMap = new Map<String,string>();
        Schema.DescribeFieldResult fieldResult = Account.CustomerType__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        system.debug('picklistValues=== '+picklistValues);
         for( Schema.PicklistEntry pickListVal : picklistValues){
             system.debug('pickListVal=== '+pickListVal);
            pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
        } 
        obj.customerTypeMap = pickListValuesMap;
        System.debug('Values in Rating are: '+obj.customerTypeMap);
        system.debug('companyNames=== '+obj);
        return obj;
    }

    /*@AuraEnabled       
    public static newStoreController getRecordTypeValues(){
        newStoreController obj = new newStoreController();
        Map<Id, String> recordtypeMap = new Map<Id, String>();
        //Get all record types of Account object
        List<Schema.RecordTypeInfo> recordTypeInfoList = Account.SObjectType.getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo info: recordTypeInfoList) {
            //Check record type is available for current user profile
            if(info.isAvailable()) {
                //Check master record type
                if(info.getName() != 'Master' && info.getName().trim() != ''){
                    recordtypeMap.put(info.getRecordTypeId(), info.getName());
                }
                //Get the default record type for current user profile
                if(info.isDefaultRecordTypeMapping()){
                    obj.defaultRecordTypeId = info.getRecordTypeId();
                }
            }
        }    
        obj.contactRecordTypes = recordtypeMap;
        return obj;
    }*/
    
    
    @AuraEnabled
    public static dataBox getwarehouseList(){
        dataBox db = new dataBox();
        db.whList = [SELECT Id,Name FROM Warehouse__c];
        system.debug(db.whList);
        List<ListView> listviews = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView WHERE SobjectType ='Account' and DeveloperName='AllAccounts'];
        db.listId = listviews[0].Id;
        return db;
    }
    
    @AuraEnabled
    public static Account insertAccount(Account acc){ 
        system.debug('acc=== '+acc);
        if(acc !=null ){
           
            try {
                upsert acc;
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(acc) ); 
            }    
            system.debug(acc.id);
            return acc;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Account> getAccountList() {
        return [SELECT Id,Name FROM Account];
    }
        
    @AuraEnabled
    public static string checkDuplicateAccountEmail(string email) {
         list<Account> accList=[SELECT Id,Name,Email__c FROM Account where Email__c =: email];
        if(accList.size()>0){
            return 'Entered email adderess is already exist.';
        }
         return '';
    }
    
    @AuraEnabled
    public static List<Account> getDuplicateAccount(string mobileNumber) {
        List<Account> duplicateAccounts = [SELECT Id,Name,GST__c,Phone,Email__c,Approval_Status__c,Parent_Customer__c FROM Account 
                                           where Phone=: mobileNumber AND Phone != null];
        system.debug('duplicateAccounts=== '+duplicateAccounts);
        if(duplicateAccounts.size()>0){
            return duplicateAccounts;
        }
        return null;
    }
    
   /* @AuraEnabled
    public static List<Account> getNotApprovedDuplicateAccount(string gstNumber,string mobileNumber){
        List<Account> duplicateAccounts = [SELECT Id,Name,GST__c,Phone,Email__c,Approval_Status__c,Parent_Customer__c FROM Account 
                                           where  Phone=: mobileNumber AND Approval_Status__c != 'Approved'];
        system.debug('duplicateAccounts=== '+duplicateAccounts);
        if(duplicateAccounts.size()>0){
            return duplicateAccounts;
        }
        return null;
    }*/
    
    /*@AuraEnabled
    public static Account getParentAccount(string parentAccountId) {
        return [SELECT Id,Name,GST__c,Phone,Email__c,Approval_Status__c FROM Account where Id =: parentAccountId Limit 1];
    }*/
        
    @AuraEnabled
    public static List<Route__c> getRouteList(string whId) {
        return [SELECT Id,Name FROM Route__c WHERE warehouse__c =:whId AND ownerId =: userinfo.getUserId()];
    }
    @AuraEnabled
    public static void submitapproval(string storeId){ 
        
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(storeId);
        
        requests.add(req);
        
        Approval.ProcessResult[] processResults = Approval.process(requests);
        
        
    }
    @AuraEnabled
    public static map<String,string> getPickListValuesIntoList(){
       map<String,string> pickListValuesMap= new map<String,string>();
		Schema.DescribeFieldResult fieldResult = Account.State__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
		}     
		return pickListValuesMap;
    }
}