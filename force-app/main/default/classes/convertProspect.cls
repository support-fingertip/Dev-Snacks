public class convertProspect {
	public static boolean frombutton = false;
    @auraEnabled
    public static void convertLead(string recId){
        frombutton = true;
        Prospect__c pro = [SELECT Id, OwnerId, Name, Store_Category__c, Grade__c, Contact_Person__c, Warehouse__c, Mobile__c, Route__c, 
                           Alternate_Mobile__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Email__c, GST__c, Description__c, 
                           Street_Name__c, State__c,Company__c, Panchayath__c, District__c, City__c, Pincode__c FROM Prospect__c WHERE Id=:recId];
        Account acc = new Account();
        acc.prospect__c = pro.Id;
        acc.name = pro.Name;
        acc.Store_Category__c = pro.Store_Category__c;
        acc.Grade__c = pro.Grade__c;
        acc.Contact_Person__c = pro.Contact_Person__c;
        acc.Warehouse__c = pro.Warehouse__c;
        acc.Phone = pro.Mobile__c;
        acc.Routes__c = pro.Route__c;
        acc.Alternate_Mobile__c = pro.Alternate_Mobile__c;
        acc.GeoLocation__Latitude__s = pro.GeoLocation__Latitude__s;
        acc.GeoLocation__Longitude__s = pro.GeoLocation__Longitude__s;
        acc.Email__c = pro.Email__c;
        acc.GST__c = pro.GST__c;
        acc.Description = pro.Description__c;
        acc.Street_Name__c = pro.Street_Name__c;
        acc.State__c = pro.State__c;
        acc.Panchayath__c = pro.Panchayath__c;
        acc.District__c = pro.District__c;
        acc.City__c = pro.City__c;
        acc.Pin_code__c = pro.Pincode__c;
        acc.CompanyId__c = pro.Company__c;
        insert acc;
        
        pro.Store__c = acc.Id;
        pro.Status__c = 'Closed Won';
        update pro;
    }
}