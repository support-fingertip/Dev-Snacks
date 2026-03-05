@IsTest
public class CashInHandHandlerTest {

    @TestSetup
    static void setupData() {

        Branch__c br = new Branch__c(
            Cash_In_Hand__c = 100
        );
        insert br;

        Route__c rt = new Route__c(
            Branch_Name__c = br.Id,
            Cash_In_Hand__c = 200
        );
        insert rt;

        Trip__c tr = new Trip__c(
            Route__c = rt.Id,
            Status__c = 'Started',
            Cash_In_Hand__c = 50
        );
        insert tr;
    }

    @IsTest
    static void testUpdateCIH() {

        Branch__c br = [SELECT Id FROM Branch__c LIMIT 1];
        Route__c rt = [SELECT Id, Cash_In_Hand__c FROM Route__c LIMIT 1];
        Trip__c tr = [SELECT Id, Cash_In_Hand__c FROM Trip__c LIMIT 1];

        Receipt__c rec = new Receipt__c(
            Route__c = rt.Id,
            Branch__c = br.Id,
            Amount__c = 100
        );
        insert rec;

        Test.startTest();
            new CashInHandHandler();
            CashInHandHandler.updateCIH(rec);
        Test.stopTest();

        rt = [SELECT Cash_In_Hand__c FROM Route__c WHERE Id = :rt.Id];
        tr = [SELECT Cash_In_Hand__c FROM Trip__c WHERE Id = :tr.Id];

        System.assertEquals(200, rt.Cash_In_Hand__c);
        System.assertEquals(50, tr.Cash_In_Hand__c);
    }
}