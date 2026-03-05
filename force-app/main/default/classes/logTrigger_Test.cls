@isTest
public class logTrigger_Test 
{
	@isTest
    Public static void Test(){
        Account acc = new Account();
        acc.name = 'TEST';
        acc.CompanyId__c='Dev';
        insert acc;
        Log__c l = new Log__c(Object__c='Account',Request__c ='[{"Route_Id__c":"SKEKLM01","GST_applicable_formula__c":"false","Branch_Id__c":1,"State__c":"KL","CustomerType__c":"1","CustomerGroupCode__c":"100","CardType__c":"C","CustomerId__c":"C-0201","CompanyId__c":"Ice","Name":"test","Id":"'+acc.Id+'"}]');
  insert l;
                Log__c r = new Log__c(RecordId__c=acc.Id,Type__c ='E Invoice - Generate',Object__c='Account',Request__c ='[{"Route_Id__c":"SKEKLM01","GST_applicable_formula__c":"false","Branch_Id__c":1,"State__c":"KL","CustomerType__c":"1","CustomerGroupCode__c":"100","CardType__c":"C","CustomerId__c":"C-0201","CompanyId__c":"Ice","Name":"test","Id":"001N000002BcyOEIAZ"}]');
  insert r;
                        Log__c r1 = new Log__c(RecordId__c=acc.Id,Type__c ='OutStandingInv',Object__c='Account',Request__c ='{"CustomerDetails":[{"CustomerId__c":"C-0217"}],"CompanyId__c":"Dev"}');
  insert r1;
    }

}