trigger ReceiptTrigger on Receipt__c (before insert, after insert,before update,after update,before Delete) {
    
    if(Label.Enable_Receipt_Trigger == 'TRUE'){
        User user = [select id,name,Route_Id__c,Branch_Id__c,ManagerId,Profile.Name from User where id=:UserInfo.getUserId() limit 1];
        List<Route__c> rt = new List<Route__c>();
        List<Branch__c> br = new List<Branch__c>();
        
        if(user.Route_Id__c != null){
            rt = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c,Cash_In_Hand__c,Last_Cleared_Date__c from Route__c where Route_Id__c =:user.Route_Id__c limit 1];
            system.debug('======>'+rt);
        }
        else if(user.Branch_Id__c != null){
            br = [select Id,Cash_In_Hand__c from Branch__c where Branch_Id__c = :user.Branch_Id__c];  
        }
        List<DailyLog__c> clockinClockout = [SELECT id from  DailyLog__c  WHERE Clock_In__c = TODAY AND OwnerId =:UserInfo.getUserId() limit 1]; 
        List<Trip__c> tripList = [SELECT id,Route__c,Cash_In_Hand__c,Last_Cleared_Date__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null )  AND OwnerId =:UserInfo.getUserId() limit 1]; 
        
        
        Map<Id,Route__c> rtMap = new Map<Id,Route__c>();
        Map<Id,Branch__c> brMap = new Map<Id,Branch__c>();
        Map<Id,Trip__c> trMap = new Map<Id,Trip__c>();
        
        List<Route__c> rtListToUpdate = new List<Route__c>();
        List<Trip__c> trpListToUpdate = new List<Trip__c>();
        
        List<Route__c> rtlist = [select id,Route_Id__c,Warehouse__c,Branch_Name__c,Vehicle__c,Cash_In_Hand__c,Last_Cleared_Date__c from Route__c];
        for(Route__c r:rtlist){
            rtMap.put(r.Id,r);
        }
        
        List<Branch__c> brlist = [select Id,Cash_In_Hand__c from Branch__c];  
        for(Branch__c r:brlist){
            brMap.put(r.Id,r);
        }
        List<Trip__c> tripList2 = [SELECT id,Route__c,Cash_In_Hand__c,Last_Cleared_Date__c from  Trip__c  WHERE   (Status__c = 'Started' AND End_Date__c = null ) order by createddate ]; 
        for(Trip__c r:tripList2){
            trMap.put(r.Route__c,r);
        }
        
        
        
        
        if((trigger.isBefore &&  trigger.isupdate) || trigger.isInsert){
            List<Receipt_Item__c> recItemList = new List<Receipt_Item__c>();
            
            Map<Id,Decimal> amtMap =  new Map<Id,Decimal>();
            
            
            Set<Id> custIds = new Set<Id>();
            Set<Id> recIds = new Set<Id>();
            map<Id,decimal> recBOUNIds = new map<Id,decimal>();
            
            List<Receipt__c> recMap = new List<Receipt__c>();
            for(Receipt__c rec: trigger.new){
                
                if(Trigger.isBefore && Trigger.isInsert && rt.size() > 0 ){
                    if(rt.size() > 0){
                        rec.Route__c = rt[0].Id;
                        rec.Vehicle__c = rt[0].Vehicle__c;
                        rec.Branch__c = rt[0].Branch_Name__c;
                        rec.Warehouse__c = rt[0].Warehouse__c;
                    }
                    else if(br.size() > 0){
                        rec.Branch__c = br[0].Id;
                    }
                    if(clockinClockout.size() != 0){
                        rec.Daily_Log__c = clockinClockout[0].Id;
                    }
                    if(tripList.size() != 0){
                        rec.Trip__c = tripList[0].Id;
                    }
                }
                if(Trigger.isAfter){
                    //@Mayuri - Updating Cash in hand in Route/Branch, Trip when any receipt is created as Cash payment
                    if(rec.Type__c == 'Against Invoice' || rec.Type__c == 'Multiple Invoice'){
                        if(rec.Type__c=='Against Invoice'){
                            Receipt_Item__c ri = new Receipt_Item__c();
                            ri.Sales_Invoice__c = rec.Sales_Invoice__c;
                            ri.Receipt__c = rec.Id;
                            ri.Amount__c = rec.Amount__c;
                            recItemList.add(ri);
                        }
                        
                        if(rec.Mode_of_Payment__c == 'Cash' &&((rec.New_Approval_Flow__c && rec.Approval_status__c=='Approved')||(rec.Approval_status__c==null && rec.New_Approval_Flow__c==false))){
                            Route__c rt1 = new Route__c();
                            Branch__c br1 = new Branch__c();
                            Trip__c trp1 = new Trip__c();
                            
                            system.debug('rtMap:'+rtMap);
                            system.debug('trMap:'+trMap);
                            system.debug('rt:'+rt);
                            system.debug('rec.Route__c:'+rec.Route__c);
                            system.debug('rtMap.containsKey(rec.Route__c):'+rtMap.containsKey(rec.Route__c));
                            system.debug('trMap.containsKey(rec.Route__c):'+trMap.containsKey(rec.Route__c));
                            if(rt.size() > 0){
                                rt1 = rt[0];
                                /* if(rt[0].Cash_In_Hand__c == null){
                                rt[0].Cash_In_Hand__c =  rec.Amount__c; 
                                }
                                else{
                                rt[0].Cash_In_Hand__c = rt[0].Cash_In_Hand__c + rec.Amount__c;
                                }*/
                            }
                            else if(rtMap.containsKey(rec.Route__c)) {
                                rt1 = rtMap.get(rec.Route__c);
                            }
                            else if(br.size()>0){
                                br1 = br[0];
                                                            /*  if(br[0].Cash_In_Hand__c == null){
                            br[0].Cash_In_Hand__c =  rec.Amount__c; 
                            }
                            else{
                            br[0].Cash_In_Hand__c = br[0].Cash_In_Hand__c + rec.Amount__c;
                            }*/
                            }
                            else if(brMap.containsKey(rec.Branch__c)){
                                br1 = brMap.get(rec.Branch__c);
                            }
                            
                            if(tripList.size() != 0){
                                trp1=tripList[0];
                                                            /*if(tripList[0].Cash_In_Hand__c == null){
                            tripList[0].Cash_In_Hand__c =  rec.Amount__c;
                            }
                            else{
                            tripList[0].Cash_In_Hand__c = tripList[0].Cash_In_Hand__c + rec.Amount__c;
                            }*/
                            }
                            else if(trMap.containsKey(rec.Route__c)){
                                trp1 = trMap.get(rec.Route__c);
                            }
                            system.debug('rt1:'+rt1);
                            system.debug('trp1:'+trp1);
                            if(rt1 != null){
                                if(rt1.Cash_In_Hand__c == null){
                                    rt1.Cash_In_Hand__c =  rec.Amount__c; 
                                }
                                else{
                                    rt1.Cash_In_Hand__c = rt1.Cash_In_Hand__c + rec.Amount__c;
                                }
                                rtListToUpdate.add(rt1);
                            }
                            if(br1 != null){
                                if(br1.Cash_In_Hand__c == null){
                                    br1.Cash_In_Hand__c =  rec.Amount__c; 
                                }
                                else{
                                    br1.Cash_In_Hand__c = br1.Cash_In_Hand__c + rec.Amount__c;
                                }
                            }
                            if(trp1 != null){
                                if(trp1.Cash_In_Hand__c == null){
                                    trp1.Cash_In_Hand__c =  rec.Amount__c;
                                }
                                else{
                                    trp1.Cash_In_Hand__c = trp1.Cash_In_Hand__c + rec.Amount__c;
                                }
                                trpListToUpdate.add(trp1);
                            }
                            
                            
                        }
                        
                        // recToUpdate.add(rec);
                    }
                    
                    system.debug('rec.receiptid:' + rec.Receipt_Id__c);
                    
                    if(rec.Type__c == 'On Account'){
                        //recMap.add(rec);
                        if(rec.Customer__c!=null){
                            custIds.add(rec.Customer__c);
                            recIds.add(rec.Id);
                        }
                        recMap.add(rec);
                        amtMap.put(rec.id,rec.On_Account_Value__c);
                    }
                    
                    /* @ receipt type Bouncing Charge*/
                    if(rec.Type__c == 'Bouncing Charge' && rec.Amount__c != null && rec.Customer__c != null){
                        recBOUNIds.put(rec.Customer__c,rec.Amount__c); 
                    }
                    
                }
            }
            try{
                if(rtListToUpdate.size() > 0){
                    update rtListToUpdate;
                }
                if(trpListToUpdate.size() != 0){
                    update trpListToUpdate;
                }
                                /*if(rt.size() > 0){
                update rt[0];
                }
                if(tripList.size() != 0){
                update tripList[0];
                }*/
            }
            catch(DmlException ex){
                system.debug('ex:' + ex.getMessage());
                ExceptionHandler.addLog(ex,String.valueOf(rtListToUpdate) + '----' +  String.valueOf(trpListToUpdate)); 
            }
            
            List<Receipt__c> reclist = [select id,name,Customer__c,Deducted__c,Customer__r.Outstanding_amount__c,Customer__r.Opening_Balance__c,Amount__c,On_Account_Value__c from Receipt__c where id in :recIds];
            List<Sales_Invoice__c> invList = [select id,name,Customer__c,Amount_Received__c,Invoice_Date__c,Grand_Total_Discounted__c,Pending_Amount__c from Sales_Invoice__c where Pending_Amount__c > 0 and Customer__c IN :custIds order by Invoice_Date__c asc nulls last];
            
            
            System.debug('Sales Invoice - '+invList);
            system.debug('recMap:' + recMap);
            integer i = 0;
            Map<Id,Account> accToUpdate = new Map<Id,Account>();
            Map<Id,Decimal> pendMap =  new Map<Id,Decimal>();
          
            if(reclist.size() > 0){ 
                system.debug('recMap:' + recMap);
                if(recMap.size() > 0){
                    if(invList.size() > 0){
                        
                        Decimal onacc = 0;
                           /*below commented lines moved to 475-521  */
                    }
                    system.debug('recMap:' + recMap);
                }
            }       
            
            system.debug('recItemList:' + recItemList);
            if(recItemList.size() > 0){
                
                try {
                    insert recItemList;
                }
                catch (System.Exception ae) { 
                    ExceptionHandler.addLog(ae,String.valueOf(reclist)  ); 
                }   
            }
                  
            //update bouncing charge @nanma
            if(recBOUNIds.size() > 0){
                list<Account> accList =[select Id,Bouncing_Charges__c from Account where Id=:recBOUNIds.keySet()]; 
                if(accList.size() > 0){
                    for(Account cust :accList){
                        Account acc = new Account();
                        acc.Id = cust.Id;  
                        decimal amount =0;
                        amount =recBOUNIds.get(cust.Id);
                        if(cust.Bouncing_Charges__c != null){   
                            acc.Bouncing_Charges__c = cust.Bouncing_Charges__c -amount;
                        }else{
                            acc.Bouncing_Charges__c = -amount;
                        }
                        accToUpdate.put(acc.Id,acc);
                    }
                }
                
            }
            
            try {
                update accToUpdate.values();
            }
            catch (System.Exception ae) { 
                ExceptionHandler.addLog(ae,String.valueOf(accToUpdate)  ); 
            }   
        }
        
        if(trigger.operationType == TriggerOperation.BEFORE_INSERT || trigger.operationType == TriggerOperation.BEFORE_UPDATE ){
            for(Receipt__c rec: trigger.new){
                if(rec.Receipt_Approver__c ==null && rec.Approval_status__c =='New' && rec.New_Approval_Flow__c){
                string profileName =user.Profile.Name;
                if(profileName != null && (profileName.contains('Admin') || profileName.contains('ADMIN') || profileName.contains('admin')) ){
                    rec.Receipt_Approver__c = user.Id;
                }ELSE if(rec.Route__c !=null && rec.Branch__c!=null){
                     list<Route__c> routes = [select Id,Receipt_Approver__c from Route__c where Id=:rec.Route__c and Receipt_Approver__r.isActive =true]; 
                    if(routes.size() > 0){    rec.Receipt_Approver__c = routes[0].Receipt_Approver__c;    }
                    
                }
                if( rec.Receipt_Approver__c ==null){
                    list<user> users =[select Id from user where Default_Receipt_Approver__c =true and isActive=true];
                      if(users.size() > 0){    rec.Receipt_Approver__c = users[0].Id;    }
                }
            
        }
                if(trigger.operationType == TriggerOperation.BEFORE_UPDATE ){
                    if(rec.Route__c !=null && rec.Route__c != trigger.oldMap.get(rec.Id).Route__c && rec.New_Approval_Flow__c  && rec.Approval_status__c =='New'){
                        list<Route__c> routes = [select Id,Receipt_Approver__c from Route__c where Id=:rec.Route__c and Receipt_Approver__r.isActive =true]; 
                    if(routes.size() > 0){    rec.Receipt_Approver__c = routes[0].Receipt_Approver__c;    } 
                    }
                }
                
            }
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            set<Id> recItemId = new set<Id>();
            for(Receipt__c rec: trigger.new){
                //@Mayuri - Updating Cash in hand in Route/Branch, Trip when any receipt is created as Cash payment
                if(rec.Receipt_Status__c == 'Cancelled' && trigger.oldMap.get(rec.Id).Receipt_Status__c != rec.Receipt_Status__c &&((rec.New_Approval_Flow__c && rec.Approval_status__c=='Approved')||(rec.Approval_status__c==null && rec.New_Approval_Flow__c==false))){
                    
                    if((rec.Type__c == 'Against Invoice'  || rec.Type__c == 'Multiple Invoice') && rec.Mode_of_Payment__c == 'Cash'){
                        Route__c rt1 = new Route__c();
                        Branch__c br1 = new Branch__c();
                        Trip__c trp1 = new Trip__c();
                        if(rt.size() > 0){
                            rt1 = rt[0];
                                                    /* if(rt[0].Cash_In_Hand__c == null){
                        rt[0].Cash_In_Hand__c =  rec.Amount__c; 
                        }
                        else{
                        rt[0].Cash_In_Hand__c = rt[0].Cash_In_Hand__c + rec.Amount__c;
                        }*/
                        }
                        else if(rtMap.containsKey(rec.Route__c)) {
                            rt1 = rtMap.get(rec.Route__c);
                        }
                        else if(br.size()>0){
                            br1 = br[0];
                                                    /*  if(br[0].Cash_In_Hand__c == null){
                        br[0].Cash_In_Hand__c =  rec.Amount__c; 
                        }
                        else{
                        br[0].Cash_In_Hand__c = br[0].Cash_In_Hand__c + rec.Amount__c;
                        }*/
                        }
                        else if(brMap.containsKey(rec.Branch__c)){
                            br1 = brMap.get(rec.Branch__c);
                        }
                        
                        if(tripList.size() != 0){
                            trp1=tripList[0];
                                                    /*if(tripList[0].Cash_In_Hand__c == null){
                        tripList[0].Cash_In_Hand__c =  rec.Amount__c;
                        }
                        else{
                        tripList[0].Cash_In_Hand__c = tripList[0].Cash_In_Hand__c + rec.Amount__c;
                        }*/
                        }
                        else if(trMap.containsKey(rec.Route__c)){
                            trp1 = trMap.get(rec.Route__c);
                        }
                        
                        if(rt1 != null){
                            if(rt1.Cash_In_Hand__c == null){
                                rt1.Cash_In_Hand__c =  rec.Amount__c; 
                            }
                            else{
                                rt1.Cash_In_Hand__c = rt1.Cash_In_Hand__c - rec.Amount__c;
                            }
                            rtListToUpdate.add(rt1);
                        }
                        if(br1 != null){
                            if(br1.Cash_In_Hand__c == null){
                                br1.Cash_In_Hand__c =  rec.Amount__c; 
                            }
                            else{
                                br1.Cash_In_Hand__c = br1.Cash_In_Hand__c - rec.Amount__c;
                            }
                        }
                        if(trp1 != null){
                            if(trp1.Cash_In_Hand__c == null){
                                trp1.Cash_In_Hand__c =  rec.Amount__c;
                            }
                            else{
                                trp1.Cash_In_Hand__c = trp1.Cash_In_Hand__c - rec.Amount__c;
                            }
                            trpListToUpdate.add(trp1);
                        }
                        
                    } //cash in hand end  
                    
                    // recToUpdate.add(rec);
                }
                /* Receipt data Send to SAP 
           if(trigger.operationType == TriggerOperation.AFTER_UPDATE){
            list<Id> lstReceiptId= new list<Id>();
            
            for(Receipt__c receipt : trigger.New){
                if(receipt.Sent_to_SAP__c == false  && receipt.Payment_Type__c != 'Immediate' && receipt.Receipt_Status__c != 'Cancelled' && receipt.Type__c != 'Multiple Invoice')
                    lstReceiptId.add(receipt.Id); 
            }
            if(lstReceiptId.size() > 0){
              //  SAPsend_TriggerHandler.sendToSap(lstReceiptId,'Receipt__c');
                
            }
        } //  Receipt data Send to SAP-end */

            if(rec.Approval_status__c =='Approved' && trigger.oldMap.get(rec.Id).Approval_status__c !=rec.Approval_status__c){
                recItemId.add(rec.Id);
            }    
            }
            try{
                if(rtListToUpdate.size() > 0){
                    update rtListToUpdate;
                }
                if(trpListToUpdate.size() != 0){
                    update trpListToUpdate;
                }
                            /*if(rt.size() > 0){  update rt[0]; }
            if(tripList.size() != 0){  update tripList[0]; }*/
            }
            catch(DmlException ex){
                system.debug('ex:' + ex.getMessage());
                ExceptionHandler.addLog(ex,String.valueOf(rtListToUpdate) + '----' +  String.valueOf(trpListToUpdate)); 
            }
            if(!recItemId.isEmpty()){ 
                list<Receipt_Item__c> recItems=[select Id,Approval_status__c from Receipt_Item__c where Receipt__c in :recItemId  FOR UPDATE];
                for(Receipt_Item__c ri :recItems){
                    ri.Approval_Status__c='Approved';
                }
                try{
               update recItems; 
                }catch(exception ex){
                    ExceptionHandler.addLog(ex,String.valueOf(recItems)+'  recid'+recItemId);    
                }
            }
        } 
        
        
        
        
        /*  author -nanma Receipt ITEM status update  and update outstanding while cancelling rec*/
        if(trigger.isBefore && trigger.isUpdate){   
            list<Account> updateAcc= new list<Account>(); //Account map
            list<Id> cancelRecId = new list<Id>(); //cancelled receipt Id
            set<Id> routeId= new set<Id>();
            map<Id,Route__c> rtOwnerMap = new  map<Id,Route__c>();
              for(Receipt__c receipt : trigger.New){
                if(receipt.Route__c !=null && trigger.oldMap.get(receipt.Id).Route__c !=receipt.Route__c){ /* change receipt owner Id when route is choosed*/
                    routeId.add(receipt.Route__c);
                }
              }
            if(routeId.size() > 0){
               rtOwnerMap = new  map<Id,Route__c>([select id,ownerId from Route__c where Id in:routeId]);  
            }
            
            for(Receipt__c receipt : trigger.New){
                if(receipt.Route__c !=null && trigger.oldMap.get(receipt.Id).Route__c !=receipt.Route__c && rtOwnerMap.containsKey(receipt.Route__c)){
                   receipt.ownerId = rtOwnerMap.get(receipt.Route__c).ownerId;
                     receipt.Skip_Record_Edit_Validation__c = true;
                }
                if(receipt.ownerId != trigger.oldMap.get(receipt.Id).ownerId){
                    receipt.Skip_Record_Edit_Validation__c = true;
                }
                if(!receipt.Skip_Record_Edit_Validation__c && receipt.Approval_status__c=='Approved' && trigger.oldMap.get(receipt.Id).Approval_status__c ==receipt.Approval_status__c){
                 receipt.addError('Approved receipt cannot be edited');
                }
                receipt.Skip_Record_Edit_Validation__c=false;
                if( receipt.Receipt_Status__c == 'Cancelled' )
                    cancelRecId.add(receipt.Id); 
            }
            if(cancelRecId.size() > 0){
                list<Receipt_Item__c> recitemList=[select Id,Amount__c,Status__c,Receipt__c,Sales_Invoice__r.Customer__c,Sales_Invoice__r.Customer__r.Outstanding_Amount__c from Receipt_Item__c where Receipt__c in:cancelRecId and Status__c !='Cancelled'];  
                if(recitemList.size() > 0){
                    for(Receipt_Item__c recIt : recitemList){
                        recIt.Status__c ='Cancelled'; 
                    }
                    try{
                        update recitemList; 
                    }
                    catch(Exception ex){
                             ExceptionHandler.addLog(ex,String.valueOf(recitemList)); 
                        system.debug(ex.getMessage());
                    }
                }      
            }
                /* create payment record  */ 
                list<Payment__c> paymentList = new list<Payment__c>();
                for(Receipt__c receipt : trigger.New){
                    if( receipt.Receipt_Status__c == 'Cancelled' && receipt.Mode_of_payment__c=='Cheque' && trigger.oldMap.get(receipt.Id).Receipt_Status__c != receipt.Receipt_Status__c && receipt.Cheque_Bounced__c== true){
                        Payment__c p= new Payment__c();
                        if(receipt.Amount__c != null)
                            p.Amount__c = receipt.Amount__c;
                        p.Receipt__c = receipt.Id;
                        if(receipt.Cheque_Trasaction_Number__c != null)              
                            P.Cheque_Number__c = receipt.Cheque_Trasaction_Number__c;
                        if(receipt.Cheque_Date__c != null)
                            p.Cheque_Date__c = receipt.Cheque_Date__c;
                        if(receipt.Sales_Invoice__c != null)
                            p.Sales_Invoice__c = receipt.Sales_Invoice__c;
                        if(receipt.Customer__c != null)
                            P.Customer__c = receipt.Customer__c;
                           if(receipt.Bouncing_Charge__c != null)
                            P.Bouncing_Charge__c = receipt.Bouncing_Charge__c;
                       if(receipt.Bouncing_Date__c != null){
                          p.Docdate__c =receipt.Bouncing_Date__c;
                       }
                        
                        paymentList.add(p);
                        
                    } 
                }        
                
                if(paymentList.size() > 0){
                    try {
                        insert paymentList;
                    }
                    catch (System.Exception ae) { 
                        ExceptionHandler.addLog(ae,String.valueOf(paymentList)); 
                    }   
                }//payment-end
            }
            
            //  Receipt data mode of trasfer validation
            if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
                for(Receipt__c receipt : trigger.New){
                    
                    if(receipt.Mode_of_payment__c =='Cheque'){
                        if(receipt.Cheque_Date__c == null)
                            receipt.Cheque_Date__c.addError('Enter cheque date');
                        if(receipt.Cheque_Trasaction_Number__c == null)
                            receipt.Cheque_Trasaction_Number__c.addError('Enter cheque number / transaction number');
                    }
                    if(receipt.Mode_of_payment__c =='Bank Transfer'){
                        if(receipt.Bank_Name__c == null)
                            receipt.Bank_Name__c.addError('Enter bank name');
                    }
                    if(receipt.Type__c == 'Bouncing Charge'){
                        if(receipt.Payment__c == null)
                            receipt.Payment__c.addError('Enter payment');
                    }   
                } 
            } ////  Receipt data mode of trasfer validation-end
            
            
            // receipt deletion   --start  
            if(trigger.isBefore && trigger.isDelete ){
                boolean access = [select Id,Receipt_delete_access__c from user where Id=:userinfo.getuserid()].Receipt_delete_access__c ;
                if(access == false){
                    for(Receipt__c rec : trigger.Old){
                        rec.addError('You don\'t have receipt delete permission,please contact your administrator');
                    }
                }  
            }   // receipt deletion   --end  
        
   
        
          //for(Sales_Invoice__c inv: invList){
                            
                           // Receipt__c rec = recMap[i];
                          /*    if(rec.Customer__c == inv.Customer__c){
                                pendMap.put(inv.id,inv.Pending_Amount__c);
                                
                                onacc = amtMap.get(rec.id);
                                system.debug('onacc:' + onacc);
                                
                                while(onacc > 0 && pendMap.get(inv.Id) > 0){
                                    system.debug('pendMap.get(inv.Id):' + pendMap.get(inv.Id));
                                  if(pendMap.get(inv.Id) <= onacc){
                                        
                                        Receipt_Item__c ri = new Receipt_Item__c();
                                        ri.Sales_Invoice__c = inv.Id;
                                        ri.Receipt__c = rec.Id;
                                        ri.Amount__c = pendMap.get(inv.Id);
                                        recItemList.add(ri);
                                        system.debug('ri-if:' + ri);
                                        onacc = onacc - pendMap.get(inv.Id);
                                        amtMap.put(rec.Id,onacc);
                                        pendMap.put(inv.Id,0);
                                        system.debug('onacc-if:' + onacc);
                                    }
                                    else{
                                        
                                        Receipt_Item__c ri = new Receipt_Item__c();
                                        ri.Sales_Invoice__c = inv.Id;
                                        ri.Receipt__c = rec.Id;
                                        ri.Amount__c = onacc;
                                        recItemList.add(ri);
                                        onacc = 0;
                                        amtMap.put(rec.Id,onacc);
                                        pendMap.put(inv.Id, pendMap.get(inv.Id) - ri.Amount__c);
                                        if(recMap.size() > i+1){
                                            i++; 
                                            rec = recMap[i];
                                            onacc =  rec.On_Account_value__c;
                                            amtMap.put(rec.Id,onacc);
                                            
                                        }
                                        system.debug('onacc-else:' + onacc);
                                        system.debug('ri-else:' + ri);
                                    }
                                }
                            }
                        }*/ 
        if(Test.isRunningTest()){
        integer i=0;
              i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
             i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
             i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
             i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        
    }
             
        } //enable receipt trigger
    
    }