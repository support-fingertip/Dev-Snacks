@isTest
public class UserAllowedForMultipleVisitsCtrlTest {

    @isTest
    public static void userMultipleVisitTest(){
        
        //List<Profile> profileRec = [SELECT Id,Name from Profile where (Name='Sales execuitive' Or Name='Van excuitive') Limit 1];
        //system.debug('profileRec=== '+profileRec);
        //if(profileRec.size()>0){
            /*List<User> usrRecord = [SELECT Id,Name,Username,Profile.Name,Manager.Name,Allow_Multiple_Visits__c FROM User 
                                    Where isActive = true and (Profile.Name='Sales Executive' Or Profile.Name='Van Executive')  Limit 1];*/
          User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Executive'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
        Route_Id__c='Route123');
        insert testUser;
        
        //    system.debug('usrRecord== '+usrRecord);
           // if(usrRecord.size()>0){
                Test.startTest();
                UserAllowedForMultipleVisitsController.getAllUsers();
                UserAllowedForMultipleVisitsController.allowMultipleVisits(testUser.Id, true);
                system.assert(testUser.Allow_Multiple_Visits__c = true);
                Test.stopTest();
          //  }
        //}
        
    }
    
}