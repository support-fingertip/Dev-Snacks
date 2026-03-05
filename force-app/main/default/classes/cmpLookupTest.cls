@istest
public class cmpLookupTest {
  
    public static  testmethod void fetchLookupData (){ 
        
        product__c p = new product__c();
        p.name= 'test';
        insert p; 
        cmpLookup.fetchLookupData( 'test','product__c');
    }
    public static  testmethod void fetchDefaultRecord(){
        product__c p = new product__c();
        p.name= 'test';
        insert p;
        cmpLookup.fetchDefaultRecord(p.id,'Product__c'); 
    }
    
}