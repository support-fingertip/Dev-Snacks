trigger CopyAddressTrigger on Address__c (before insert,after insert, after update) 
{
    if(label.Enable_Address_Trigger == 'TRUE'){
        if(Trigger.isBefore && Trigger.isInsert)
        {
            
            for(Address__c add : Trigger.New)
            {
                if(add.Same_as_Billing_Address__c == false && (add.Country__c == null || add.State__c == null 
                                                               || add.District__c == null || add.Address__c == null))
                {
                    add.addError('Please Fill the Mandatory Fields (Address, Country, State, District)');
                }
                
                
            }
            
            
            Set<Id> accountIds = new Set<Id>();
            Set<Id> custIds = new Set<Id>();
            for(Address__c address : Trigger.New){
                if(address.Customer__c != null){
                    accountIds.add(address.Customer__c);
                    if(address.Same_as_Billing_Address__c == true){
                        custIds.add(address.Customer__c);
                    }
                }
                
            }
            Map<Id,Decimal> rowNumMap = new Map<Id,Decimal>();
            //List<Address__c> existingAddress = [select id,Customer__c from Address__c where Customer__c IN : accountIds ORDER BY CreatedDate ASC];
            
            List<AggregateResult > countAdd =[select Customer__c,count(Id)cnt from Address__c where Customer__c IN :accountIds group by Customer__c];
            
            
            for(AggregateResult agg: countAdd){
                rowNumMap.put((String)agg.get('Customer__c'),(Decimal)agg.get('cnt'));
            }
            for(Address__c addr : Trigger.New){
                if(addr.Customer__c != null && rowNumMap.containsKey(addr.Customer__c)){
                    addr.RowNum__c = rowNumMap.get(addr.Customer__c) + 1;
                }
                else{
                    addr.RowNum__c = 1;
                }
                
            }
            
            
            Map<Id,Address__c> addMap = new Map<Id,Address__c>();
            List<Address__c> billingAddress = [select Customer__c,Address__c, Address_Type__c, Block__c, Building__c, 
                                               City__c, Country__c, District__c, GST_No__c, RowNum__c, State__c, GST_type__c,
                                               Street__c, Street_No__c, ZipCode__c from Address__c 
                                               where Address_Type__c = 'B' and  Customer__c IN : custIds ];
            system.debug('billingAddress - '+billingAddress);
            
            if(billingAddress.size() > 0){
                for(Address__c acc : billingAddress)
                {
                    addMap.put(acc.Customer__c,acc);
                }
                
                for(Address__c add : Trigger.New)
                {
                    if(add.Customer__c != null && addMap.containsKey(add.Customer__c)){
                        Address__c acc = addMap.get(add.Customer__c);
                        add.Address__c = acc.Address__c;
                        add.Address_Type__c = 'S';
                        add.Block__c = acc.Block__c;
                        add.Building__c = acc.Building__c;
                        add.City__c = acc.City__c;
                        add.Country__c = acc.Country__c;
                        add.District__c = acc.District__c;
                        add.GST_No__c = acc.GST_No__c;
                        add.RowNum__c = acc.RowNum__c + 1;
                        add.State__c = acc.State__c;
                        add.Street__c = acc.Street__c;
                        add.Street_No__c = acc.Street_No__c;
                        add.ZipCode__c = acc.ZipCode__c;
                        add.GST_type__c = acc.GST_type__c;
                    }
                }
                
            }
            else if(custIds.size() > 0 && billingAddress.size() == 0){
                for(Address__c addr : Trigger.New){
                    addr.addError('No existing addresses found for this customer.');
                }
            }
            
        }
        
        if(label.DisableDuplicateCheck == 'True'){
            if(Trigger.isAfter && (Trigger.isInsert || trigger.isUpdate)){
                Set<string> gstIn = new set<string>();
                
                for(Address__c add : Trigger.New)
                {
                    if(Trigger.isInsert){
                        if(add.GST_No__c != null && add.accountHasParentAccount__c == false )
                            gstIn.add(add.GST_No__c);  
                    }
                    if(Trigger.isUpdate){
                        if(add.GST_No__c != null && add.accountHasParentAccount__c == false && trigger.oldMap.get(add.Id).GST_No__c != add.GST_No__c )
                            gstIn.add(add.GST_No__c);  
                    }
                    
                }
                /* Address duplicate check */
                if(gstIn.size() > 0){
                list<Address__c> addexList =[select Id,GST_No__c,Customer__r.Name from Address__c where GST_No__c in :gstIn and Customer__c != null];
                for(Address__c add : trigger.New){
                    if(add.Customer__c != null && add.GST_No__c != null ){
                        for(Address__c adex : addexList){
                            if(adex.GST_No__c == add.GST_No__c && adex.Customer__c != add.Customer__c && add.Id != adex.Id && add.Same_as_Billing_Address__c==false){
                                add.GST_No__c.addError('Duplicate GST number .Gst number already exist in -'+adex.Customer__r.Name);
                            } 
                        }
                        
                    }
                } 
            }
                list<Id> addIds = new list<Id>();
              for(Address__c add : Trigger.New)
                {
                    if(Trigger.isInsert){
                        if(add.GST_No__c != null && add.GST_No__c != ''  )
                          gstVerification.sendDataforValidation(add.Id);
                    }
                    if(Trigger.isUpdate){
                        if(add.GST_No__c != null && trigger.oldMap.get(add.Id).GST_No__c != add.GST_No__c && add.GST_No__c != '' )
                            gstVerification.sendDataforValidation(add.Id);
                    }  
                }  
                
            }  
        }
    }  
}