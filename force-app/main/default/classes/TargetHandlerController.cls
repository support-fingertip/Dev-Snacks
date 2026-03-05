public class TargetHandlerController{ 

        Public static void calculate(){
        
            Date todayDate = date.today(); 
            Map<id,Map<id,Target__c > > userTargetObjMap =  new Map<id,Map<id,Target__c > >();
            Map<id,Map<id,decimal> > userTargetMap =  new Map<id,Map<id,decimal> >();
            List<Target__c> targetListtoUpsert = new  List<Target__c>();
        
            Period__c p = [select id,Start_Date__c,End_Date__c from  Period__c  where Start_Date__c<=: todayDate  and End_Date__c>=: todayDate limit 1];
            
            List<Target__c> targetList = [Select id,Target_Metrics__c,Executive__c, Actual__c from Target__c where Target_Period__c =: p.id];
            
            List<Target_Metrics__c> tmetrics = [select id,Name, Active__c,Aggregate_Function__c, Field_To_Aggregate__c, Field_To_Filter__c, Field_To_Group__c, Field_Value_to_Filter__c,Object_Name__c from Target_Metrics__c limit 10];
            
            List<user> ulist = [Select id from user ];  
    
            AggregateResult[] totalsale =  [SELECT Sum( Grand_Total__c ) value,  Store__r.ownerId  owner   FROM Invoice__c where Invoice_Date__c>=:p.Start_Date__c and Invoice_Date__c<=: p.End_Date__c Group by Store__r.ownerId ];
            AggregateResult[] visits =  [SELECT count( id ) value, Account1__r.ownerId owner   FROM visit__c where Date__c>=:p.Start_Date__c and Date__c<=: p.End_Date__c Group by Account1__r.ownerId ];
            AggregateResult[] newAccounts =  [SELECT count( id ) value, account.ownerId owner   FROM account where createddate >=:p.Start_Date__c and createddate <=: p.End_Date__c Group by ownerId ];
           
           
            for(Target__c t: targetList ){ 
                Map<id,Target__c > targetToMetrics = new Map<id,Target__c >();
                if(userTargetObjMap.get(t.Executive__c)  != null ){
                   targetToMetrics  = userTargetObjMap.get(t.Executive__c);
                } 
                targetToMetrics.put( t.Target_Metrics__c,t ) ;  
                userTargetObjMap.put(t.Executive__c, targetToMetrics); 
            }
            
            
            if(targetList.size() == 0){ 
                  for( user u : ulist ){  
                            Map<id,Target__c > targetToMetrics = new Map<id,Target__c >(); 
                            for(Target_Metrics__c t: tmetrics ){ 
                                targetToMetrics.put( t.id , new Target__c(Target_Metrics__c =t.id,Executive__c=u.id, Target_Period__c =p.id )  ) ;
                            }
                            userTargetObjMap.put(u.id, targetToMetrics ); 
                  } 
            } 
           
           
            Map<id,decimal>  salesMap = new Map<id,decimal>();
            Map<id,decimal>  visitMap = new Map<id,decimal>();
            Map<id,decimal>  newAccountMap = new Map<id,decimal>();
            Map<id,decimal>  conversionsMap = new Map<id,decimal>();
            Map<id,decimal>  productAMap = new Map<id,decimal>();
          
            for( AggregateResult a: totalsale ){  
               salesMap.put((Id)a.get('owner'),(Decimal)a.get('value') ); 
            }
            for( AggregateResult a: visits ){  
               visitMap.put((Id)a.get('owner'),(Decimal)a.get('value') ); 
            }
            for( AggregateResult a: newAccounts ){  
               newAccountMap .put((Id)a.get('owner'),(Decimal)a.get('value') ); 
            }  
           
            for( user u : ulist ){  
              Map<id,decimal>  tarMetricMap = new Map<id,decimal>();
              for(Target_Metrics__c t: tmetrics ){
                
                      if(t.Name == 'Sales'){
                           tarMetricMap.put(t.id,salesMap.get(u.id) );
                       }
                       if(t.Name == 'Visits'){
                           tarMetricMap.put(t.id,visitMap.get(u.id) );
                       } 
                       if(t.Name == 'Account'){
                           tarMetricMap.put(t.id,visitMap.get(u.id) );
                       }  
                } 
                userTargetMap.put(u.id, tarMetricMap ) ;       
            
            }  
            
            for( user u : ulist ){    
                  Map<id,Target__c > targetObjMap  =  userTargetObjMap.get(u.id); 
                  for(id tid : targetObjMap.keySet() ){ 
                      targetObjMap.get(tid).Actual__c  = userTargetMap.get(u.id).get(tid)  ;
                      targetListtoUpsert .add( targetObjMap.get(tid));
                  } 
             }   
             upsert targetListtoUpsert ; 
            
        } 
        Public static List<targetWrapper> twrapp{get;set;}  
        Public static List<Target_Metrics__c> tmetrics{get;set;}  
 
        public class pickValue{
            @AuraEnabled public string label{get;set;} 
            @AuraEnabled public  string name{get;set;}
        }
        @AuraEnabled(cacheable=true)
        public static List<pickValue>  queryPeriods(){  
            List<pickValue> plist = new List<pickValue>();
            for(Period__c pr: [select id,name, Start_Date__c, End_Date__c from  Period__c order by Start_Date__c desc limit 10]){
                pickValue p = new pickValue(); 
                p.label = pr.name;
                p.name = pr.id;
                plist.add(p ); 
            }
            return plist ; 
        }
        @AuraEnabled(cacheable=true)
        public static List<pickValue>  queryProfiles(string periodId){  

            Period__c period = [select id from  Period__c  where  id=:periodId];
            List<Target__c> targetList = [Select id,Target_Metrics__r.Profiles_Applicable__c,Executive__c,Target__c, Actual__c from Target__c where Target_Period__c  =: period.id  ];
            set<string> targetDefinedProfiles = new  set<string>();

            for(Target__c t: targetList){
                targetDefinedProfiles.add(t.Target_Metrics__r.Profiles_Applicable__c);
            }
            List<pickValue> plist = new List<pickValue>();
            for(profile pr: [select id,name  from  profile where name in : targetDefinedProfiles ]){
                pickValue p = new pickValue(); 
                p.label = pr.name; 
                p.name = pr.Id;
                plist.add(p);  
            }
            return plist ; 
        }

        @AuraEnabled(cacheable=true)
        public static List<pickValue>  queryUsers(string profileId){  
            List<pickValue> plist = new List<pickValue>();
            for(User  us: [select id,name from user where profileId =:profileId]){
                pickValue  p = new pickValue(); 
                p.label = us.name;
                p.name = us.id;
                plist.add(p ); 
            }
            return plist ; 
        }

        @AuraEnabled(cacheable=true)
        public static targetMetricsWrapper  queryTargets(  String periodId,string profileId, string reportingTo){ 
            Date todayDate = date.today(); 
            Map<id,Map<id,Target__c > > userTargetObjMap =  new Map<id,Map<id,Target__c > >();
            Map<id,Map<id,decimal> > userTargetMap =  new Map<id,Map<id,decimal> >();
            List<Target__c> targetListtoUpsert = new  List<Target__c>();
            twrapp  = new List<targetWrapper>();
           
            Period__c p = [select id from  Period__c  where  id=:periodId];
            List<user> ulist = [Select id,Name,Profile.Name, ProfileId,managerId, manager.name, UserRole.Name,UserRoleId from user ]; 
            
            List<Target__c> targetList = [Select id,Target_Metrics__c,Executive__c,Target__c, Actual__c from Target__c where Target_Period__c  =: p.id  ];
             
            tmetrics = [select id,Name, Active__c,Aggregate_Function__c, Field_To_Aggregate__c, Field_To_Filter__c, Field_To_Group__c, Field_Value_to_Filter__c,Object_Name__c from Target_Metrics__c      ];
            
            if(profileId  != '' ){
                 profile pro = [select name from profile where id=: profileId];
                 tmetrics = [select id,Name, Active__c,Aggregate_Function__c, Field_To_Aggregate__c, Field_To_Filter__c, Field_To_Group__c, Field_Value_to_Filter__c,Object_Name__c from Target_Metrics__c where    Profiles_Applicable__c =: pro.name  ];
                 ulist = [Select id,Name,Profile.Name, ProfileId,managerId, manager.name, UserRole.Name,UserRoleId from user where profileid=:profileId  ]; 
            } 
            
            if(reportingTo != '' ){
                ulist = [Select id,Name,Profile.Name, ProfileId,managerId, manager.name, UserRole.Name,UserRoleId from user where managerId=:reportingTo    ]; 
            }   
            
             
             for(Target__c t: targetList ){ 
                Map<id,Target__c > targetToMetrics = new Map<id,Target__c >(); 
                if(userTargetObjMap.get(t.Executive__c)  != null ){
                   targetToMetrics  = userTargetObjMap.get(t.Executive__c);  
                } 
                targetToMetrics.put( t.Target_Metrics__c,t ) ;  
                userTargetObjMap.put(t.Executive__c, targetToMetrics); 
            }
            
             for( user u : ulist ){    
                  targetWrapper tw = new targetWrapper();
                  tw.executiveId = u.id;
                  tw.executiveName = u.Name;
                  tw.profileName = u.Profile.Name;
                  tw.profileId =  u.ProfileId;
                  tw.reportingTo = u.managerId;
                  tw.reportingToName = u.manager.name;
                  tw.roleId = u.UserRole.Name;
                  tw.roleName = u.UserRoleId;
                  tw.targets =  new list<target__c>();  
                  Map<id,Target__c > targetObjMap  =  userTargetObjMap.get(u.id); 
                  for(id tid : targetObjMap.keySet() ){ 
                        tw.targets.add( targetObjMap.get(tid));
                  } 
                  twrapp.add(tw);
             }  

             targetMetricsWrapper  t = new targetMetricsWrapper();
             t.targetsWrapper = twrapp;
             t.targetMetrics = tmetrics;
             
             return t;
            
        }
        public class targetWrapper{
            @AuraEnabled  public string  executiveId {get;set;}
            @AuraEnabled public string  executiveName {get;set;}
            @AuraEnabled public string  profileName {get;set;}
            @AuraEnabled public string  profileId {get;set;}
            @AuraEnabled public string  reportingTo {get;set;}
            @AuraEnabled public string  reportingToName {get;set;}
            @AuraEnabled public string  roleId {get;set;}
            @AuraEnabled public string  roleName {get;set;}
            @AuraEnabled public Id periodId {get;set;}
            @AuraEnabled public List<target__c> targets{get;set;}
        }
        public class targetMetricsWrapper{   
            @AuraEnabled   public List<targetWrapper> targetsWrapper{get;set;}
            @AuraEnabled   public List<Target_Metrics__c> targetMetrics{get;set;} 

        }


}