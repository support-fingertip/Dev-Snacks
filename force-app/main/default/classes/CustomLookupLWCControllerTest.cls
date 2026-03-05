@IsTest
public class CustomLookupLWCControllerTest {

    @testSetup
    static void setupData() {

        List<Account> accList = new List<Account>();

        for (Integer i = 0; i < 6; i++) {
            accList.add(new Account(
                Name = 'Test Account ' + i,
                CompanyId__c = 'Dev' // ✅ valid picklist API value
            ));
        }
        insert accList;
    }

    // Search with text
    @IsTest
    static void testSearchWithSearchTerm() {

        List<sObject> result =
            CustomLookupLWCController.search('Test', 'Account', null);

        System.assertNotEquals(null, result);
        System.assert(result.size() > 0);
        System.assert(result.size() <= 5);
    }

    // Search without text (LastViewedDate path)
    @IsTest
    static void testSearchWithoutSearchTerm() {

        List<sObject> result =
            CustomLookupLWCController.search('', 'Account', null);

        System.assertNotEquals(null, result);
        System.assert(result.size() <= 5);
    }

    // Search with filter
    @IsTest
    static void testSearchWithFilter() {

        List<sObject> result =
            CustomLookupLWCController.search(
                'Test',
                'Account',
                'CompanyId__c = \'Dev\''
            );

        System.assertNotEquals(null, result);
        System.assert(result.size() > 0);
    }
}