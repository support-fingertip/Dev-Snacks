@isTest
public class AssignedToTest 
{
	@isTest
    public static void MethodTest()
    {
        User testUser = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'system administrator'].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US' );
         insert testUser;
        
        Visit__c vs = new Visit__c();
        vs.Status__c = 'Planned';
        vs.Assigned_To__c = testUser.Id;
        insert vs;
    }
}