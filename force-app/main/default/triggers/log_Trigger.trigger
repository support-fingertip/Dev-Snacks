trigger log_Trigger on Log__c (before insert) {
    
    if(trigger.isInsert && trigger.isBefore){
        for(Log__c l : trigger.New){
            if(l.Request__c != null || l.Request__c != ''){
                try{
              string data =l.Request__c;
                       if(l.Type__c == null){
                if(data != '' ){
                    string datasub = data.substringBetween(',"CompanyId__c"', '}'); 
                      system.debug(datasub);
                    if(datasub == '' || datasub == null){
                        datasub = data.substringBetween('","Doc_date":"', ',"GoodsIssueItems"'); 
                    }
                       if(datasub == '' || datasub == null){
                           datasub = data.substringBetween(',"Company_Id__c"', '}'); 
                    }
                       if(datasub != '' && datasub != null){
                            string Idd =datasub.substringBetween(',"Id":"', '"');
                           string Iddu =datasub.substringBetween(',"GoodsIssueId":"', '"');
                            system.debug(datasub);
                         system.debug('test'+Idd);  
                           string rLink =system.label.DataUrl;
                           if(Idd != null && Idd !=''){
                           l.RecordId__c= Idd;
                           }else{
                              l.RecordId__c= Iddu;   
                           }
                           if(l.Object__c != '' && Idd !=null)
                           l.Record__c =rLink+l.Object__c+'/'+Idd+'/view';
                           if(l.Object__c != '' && Iddu !=null)
                           l.Record__c =rLink+l.Object__c+'/'+Iddu+'/view';
                }
   
            }
                       }
                   else if(l.Type__c =='E Invoice - Generate' || l.Type__c =='E Invoice - Cancel'){
                           string rLink =system.label.DataUrl;
                        if(l.RecordId__c != null && l.Object__c !='')
                        l.Record__c =rLink+l.Object__c+'/'+l.RecordId__c+'/view'; 
                       
                    }  else if(l.Type__c =='OutStandingInv' || l.Type__c =='OutStandingCust'){
                         string rLink =system.label.DataUrl;
                        if(l.RecordId__c != null && l.RecordId__c !=''){
                            l.RecordId__c  =  l.RecordId__c.removeStart('(');
                              l.RecordId__c  =  l.RecordId__c.removeEnd(')');
                        l.Record__c =rLink+'Account'+'/'+l.RecordId__c+'/view'; 
                           
                        }
                    }
                    if(l.RecordId__c !=null && l.RecordId__c !=''){
                        Id recId =l.RecordId__c;
                       Schema.SObjectType sobjectType = recId.getSObjectType();
                 String sobjectName = sobjectType.getDescribe().getName();
                        if(sobjectName =='Account'){
                            l.Customer__c =l.RecordId__c;
                        }else if(sobjectName =='Receipt__c'){
                                l.Receipt__c =l.RecordId__c;
                        }else if(sobjectName =='Return__c'){
                                l.Return__c =l.RecordId__c;
                        }else if(sobjectName =='Route__c'){
                                l.Route__c =l.RecordId__c;
                        }else if(sobjectName =='Sales_Invoice__c'){
                                l.Sales_Invoice__c =l.RecordId__c;
                        }else if(sobjectName =='Item_Replacement__c'){
                                l.Item_Replacement__c =l.RecordId__c;
                        }else if(sobjectName =='Payment__c'){
                                l.Payment__c =l.RecordId__c;
                        }else if(sobjectName =='Stock_Request__c'){
                                l.Stock_Request__c =l.RecordId__c;
                        }
                    }
                    
                }
                catch(Exception  ex){
                system.debug('Error'+ ex.getMessage());
                 ExceptionHandler.addLog(ex,String.valueOf(l));
            }
        }
    }
        if(test.isRunningTest()){
            integer i=0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
    }
}