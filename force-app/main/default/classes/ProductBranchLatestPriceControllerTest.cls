@IsTest
public class ProductBranchLatestPriceControllerTest {
    @testSetup
    static void setupData(){
        product2 Prod= new Product2(
        Name = 'Test Product',
        IsActive = true
        );
        insert prod;
        
        Branch__c branch1= new Branch__c(Name= 'Branch A');
        Branch__c branch2 = new Branch__c(Name= 'Branch B');
        insert new List<Branch__c>{ branch1, branch2};
            
            Stock__c stockA1 = new Stock__c(
            Product__c = prod.Id,
            Branch__c = branch1.Id,
            Price__c = 100,
            Stock_Date__c=Date.today().addDays(-5)
            );
        Stock__c stockA2 = new Stock__c(
        Product__c = prod.Id,
        //Branch_c = branch1.Id,
        Price__c = 150,
        Stock_Date__c = Date.today());
        
       Stock__c stockB1 = new Stock__c(
       Product__c = prod.Id,
       Branch__c = branch2.Id,
       Price__c = 200,
       Stock_Date__c = Date.today().addDays(-10)
       );
        
        Stock__c stockB2 = new Stock__c(
       Product__c = prod.Id,
       Branch__c = branch2.Id,
       Price__c= 250,
       Stock_date__c= Date.today().addDays(-1));
        insert new List<stock__c>{ stockA1, stockA2, stockB1, stockB2};
            }
            
        
        @IsTest
        static void testGetLatestBranchPrice(){
            Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
            Test.startTest();
            List<ProductBranchLatestPriceController.BranchPriceWrapper> result= productBranchLatestPriceController.getLatestBranchPrice(prod.Id);
            Test.stopTest();
            
            system.assertEquals(2, result.size(), 'Should return latest price per branch');
            
            Map<String, Decimal> branchPriceMap = new Map<String, Decimal>();
            for ( ProductBranchLatestPriceController.BranchPriceWrapper bp : result){
                branchPriceMap.put(bp.branchName, bp.price);
                
            }
            system.assertEquals(150, branchPriceMap.get('Branch A'),
                               'Branch A should return latest price');
            
            system.assertEquals(250, branchPriceMap.get('Branch B'),
                               'Branch B should retun latest price');
        }
    
     
        
        
    }