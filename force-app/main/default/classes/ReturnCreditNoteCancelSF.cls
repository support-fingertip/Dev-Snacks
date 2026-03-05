public with sharing class ReturnCreditNoteCancelSF {

    @AuraEnabled
    public static String cancelCreditNoteSF(Id returnId) {

        if(returnId == null){
            throw new AuraHandledException('Return Id is required');
        }

        // Query using correct API name
        Return__c ret = [
            SELECT Id, Credit_Note_Status_c__c
            FROM Return__c
            WHERE Id = :returnId
        ];

        // Prevent double cancellation
        if(ret.Credit_Note_Status_c__c == 'Cancelled'){
            throw new AuraHandledException('Credit Note is already cancelled.');
        }

        // Update status
        ret.Credit_Note_Status_c__c = 'Cancelled';

        update ret;

        return 'SUCCESS';
    }
}