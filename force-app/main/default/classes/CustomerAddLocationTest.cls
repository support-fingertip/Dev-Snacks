@isTest
public class CustomerAddLocationTest {
    @isTest
    public static void TestCustomerAddLocation(){
        
        Account acc=new Account();
        acc.Name='testaccount1';
        acc.Phone = '9985542322';
        acc.Email__c = 'test@gmail.com';
        acc.Pan_Number__c = 'QWERT0098U';
        acc.GST__c = '1SQWER0098UYQZA';
        acc.CardType__c = 'C';
        //acc.Customer_Code__c = 100;
        acc.Contact_Person__c = 'ftest';
        //acc.EId__c = 'S25521252hsb2';
        acc.CompanyId__c = 'Dev';
      	acc.OwnerId = UserInfo.getUserId();
        acc.GeoLocation__latitude__s=23.753732;
        acc.GeoLocation__Longitude__s=69.759741;
        //acc.Approval_Status__c = 'Approved';
        insert acc;
        
        /*List<ProcessInstanceWorkitem> approvalRequest = [select id,ActorId, CreatedDate, OriginalActorId,OriginalActor.name, ProcessInstanceId, ProcessInstance.Status, 
                                    ProcessInstance.SubmittedById, ProcessInstance.ProcessDefinition.TableEnumOrId,ProcessInstance.ProcessDefinition.Type 
                                    from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:acc.Id 
                                    and ProcessInstance.ProcessDefinition.Type ='Approval' limit 1];
        system.debug('approvalRequest=== '+approvalRequest);

        if(approvalRequest.size()>0){
            string approvalRequestID = approvalRequest[0].Id;
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approving request using Trigger');
            req.setAction('Approve');
            req.setWorkitemId(approvalRequestID);
            system.debug('req=== '+req);
            Approval.ProcessResult result = Approval.process(req);
            
            
        }*/
        
        if(Approval.isLocked(acc.Id)){
            Approval.Unlock(acc.Id, false);
          
        }
          test.startTest();
            CustomerAddLocation.gettingOutlet(acc.id);
            CustomerAddLocation.updateOutlet(acc.id,acc.GeoLocation__latitude__s,  acc.GeoLocation__Longitude__s);
            //system.assertEquals(acc.New_Geo_Location__Latitude__s, acc.GeoLocation__latitude__s);
            test.stopTest();
        
    }

}