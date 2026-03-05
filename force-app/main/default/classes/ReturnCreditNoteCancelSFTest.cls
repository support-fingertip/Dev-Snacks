@IsTest
public class ReturnCreditNoteCancelSFTest {

  

    private static String getValidReturnStatus() {
        for (Schema.PicklistEntry pe :
            Return__c.Credit_Note_Status_c__c.getDescribe().getPicklistValues()
        ) {
            if (pe.getValue() != 'Cancelled') {
                return pe.getValue();
            }
        }
        return 'Cancelled';
    }

    private static String getValidCompanyId() {
        for (Schema.PicklistEntry pe :
            Account.CompanyId__c.getDescribe().getPicklistValues()
        ) {
            return pe.getValue();
        }
        System.assert(false);
        return null;
    }

    private static Account createCustomer() {
        Account acc = new Account(
            Name = 'Test Customer',
            CompanyId__c = getValidCompanyId()
        );
        insert acc;
        return acc;
    }

    private static Branch__c createBranch() {
        Branch__c br = new Branch__c(
            Name = 'Test Branch'
        );
        insert br;
        return br;
    }

    private static Return__c createValidReturn(String status) {
        Account customer = createCustomer();
        Branch__c branch = createBranch();

        Return__c ret = new Return__c(
            Name = 'Test Return',
            Customer__c = customer.Id,
            Branch__c = branch.Id,
            Credit_Note_Status_c__c = status,
            Return_Date__c = Date.today()
        );
        insert ret;
        return ret;
    }

  

    @IsTest
    static void testCancelCreditNoteSuccess() {
        Return__c ret = createValidReturn(getValidReturnStatus());

        Test.startTest();
        String result = ReturnCreditNoteCancelSF.cancelCreditNoteSF(ret.Id);
        Test.stopTest();

        Return__c updated = [
            SELECT Credit_Note_Status_c__c
            FROM Return__c
            WHERE Id = :ret.Id
        ];

        System.assertEquals('SUCCESS', result);
        System.assertEquals('Cancelled', updated.Credit_Note_Status_c__c);
    }

    @IsTest
    static void testCancelCreditNoteAlreadyCancelled() {
        Return__c ret = createValidReturn('Cancelled');

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ReturnCreditNoteCancelSF.cancelCreditNoteSF(ret.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown);
    }

    @IsTest
    static void testCancelCreditNoteNullId() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ReturnCreditNoteCancelSF.cancelCreditNoteSF(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown);
    }
}