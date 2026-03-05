public class EmployeeTracker {
    
     @AuraEnabled
    public static List<userWrap> getUserList() {
        List<userWrap> users = new List<userWrap>();
        id currentuserId = userinfo.getUserId();
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName!='System Administrator' && profileName!='Admin'){ 
            
            for (User UserDe: [select Id,Name from User where ManagerId  =: currentuserId or manager.ManagerId  =: currentuserId or  profile.name = 'Sales Executive' Order By Name ]) {
                userWrap us =new userWrap();  
                us.Ids = UserDe.Id;
                us.userName = UserDe.Name;
                users.add(us);
            }    
        }
        else{
            for (User UserDe: [select Id,Name from User order by Name]) {
                userWrap us =new userWrap();
                us.Ids = UserDe.Id;
                us.userName = UserDe.Name;
                users.add(us);
            }    
            
        }
        return users;
    }
    
    public class userWrap{
        @AuraEnabled
        public string userName{set;get;}
        @AuraEnabled
        public string Ids{set;get;}
    }
    
    @AuraEnabled
    public static countWrap showSummeryCount(String mystartDate,String currentuserid,Decimal latitude,Decimal longitude){
        system.debug(currentuserid);
        Double totalDistance = 0.0;
        String user_id;
        Integer plannedVisitCount = 0;
        Integer completedVisitCount = 0;
         Integer PostPoneVisitCount = 0;
        Integer MissedVisitCount = 0;
        Integer InprogressVisitCount = 0;
        Integer IncompleteVisitCount = 0;
        Date startDate1 = Date.valueOf(mystartDate); 
        Datetime startDate = Datetime.newinstance(startDate1.year(),startDate1.month(),startDate1.day());
        Datetime endDate =  Datetime.newinstance(startDate1.year(),startDate1.month(),startDate1.day()+1 );
        if(currentuserid != null && currentuserid != ''){
            user_id=currentuserid;
            system.debug('current user is'+user_id);
            List<Visit__c> listVisits;
            system.debug('im from inside if');
            
                listVisits =  [SELECT Planned_Start_Date__c,PostPoned__c,Account_Name__c,Id,Account1__c,Account1__r.Name,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Planned_Start_Time__c,Status__c,Account1__r.GeoLocation__c,Account1__r.GeoLocation__latitude__s,Account1__r.GeoLocation__longitude__s FROM Visit__c WHERE ((Planned_Start_Time__c >=:startDate and Planned_Start_Time__c <:endDate) or (PostPoned__c=true and lastmodifieddate >=:startDate and lastmodifieddate <:endDate)) AND OwnerId = : user_id]; 
            system.debug(listVisits);
            Location distance =Location.newInstance(latitude, longitude);
            Location l ;
             DateTime dT = System.now();
			Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            if(listVisits.size() > 0){
                for(Visit__c visit : listVisits){
                    if(visit.Status__c == 'Planned' && date.newinstance(visit.Planned_Start_Time__c.year(),visit.Planned_Start_Time__c.month(),visit.Planned_Start_Time__c.day())== system.today()){
                        plannedVisitCount++;
                        if(visit.Account1__r.GeoLocation__c != null){
                            l = visit.Account1__r.GeoLocation__c;  
                        }
                        else{
                            l = null;
                        }
                        
                        
                        Double d =  l== null ? 0.00:Location.getDistance(distance,l,'km');
                        System.debug('-----Location----'+l);
                        System.debug('-----Distance----'+d);
                        totalDistance += d;
                    }
                     if(visit.Status__c == 'PostPone'){
                    PostPoneVisitCount++;
                }
                if(visit.Status__c == 'Missed'){
                    MissedVisitCount++;
                }
                
                    if(visit.Status__c == 'Completed'){
                        completedVisitCount++;
                    }
                   if(visit.Status__c == 'In Progress'){
                        InprogressVisitCount++;
                    } 
                     if(visit.Status__c == 'Incomplete'){
                        IncompleteVisitCount++;
                    } 
                }
                countWrap cw = new countWrap();
                cw.expectedDistance = (Integer)totalDistance;
                cw.visitCount = listVisits.size();
                cw.plannedVisits = plannedVisitCount;
                cw.completedVisits = completedVisitCount;
                 cw.PostponedVisits = PostPoneVisitCount;
            	cw.MissedVisits = MissedVisitCount;
                cw.InprogressVisitCount = InprogressVisitCount;
                cw.IncompleteVisitCount = IncompleteVisitCount;
                System.debug('size'+listVisits.size());
                System.debug('-----totalDistance----'+totalDistance);
                return cw;
            }else{
                countWrap cw = new countWrap(); 
                cw.expectedDistance =0;
                cw.visitCount = 0;
                cw.plannedVisits = 0;
                cw.completedVisits =0;
                cw.InprogressVisitCount=0;
                cw.IncompleteVisitCount =0;
                return cw;
            }  
            
        }
        else{
            return null;
        }
        
    }
    public class countWrap{
        @AuraEnabled
        public Integer visitCount{set;get;}
        @AuraEnabled
        public Integer expectedDistance{set;get;}
        @AuraEnabled
        public Integer plannedVisits{set;get;}
        @AuraEnabled
        public Integer completedVisits{set;get;}
         @AuraEnabled
        public Integer PostponedVisits{set;get;}
         @AuraEnabled
        public Integer MissedVisits{set;get;}
        @AuraEnabled
        public Integer InprogressVisitCount{set;get;}
        @AuraEnabled
        public Integer IncompleteVisitCount{set;get;}
    }
    
  @AuraEnabled
    Public static string showMeeting( String para1, String para2,String mystartDate,String currentuserid){ 
        
        visitWrapper wc = new visitWrapper();
        Date startDate1 = Date.valueOf(mystartDate); 
        Datetime startDate = Datetime.newinstance(startDate1.year(),startDate1.month(),startDate1.day());
        Datetime endDate =  Datetime.newinstance(startDate1.year(),startDate1.month(),startDate1.day()+1 );
        decimal latt = decimal.valueOf(para1);
        decimal longi = decimal.valueOf(para2);
        String user_id = ''; 
        if(currentuserid != null && currentuserid != ''){
            user_id=currentuserid;
          
        }
        else{
            user_id=userinfo.getuserid();
        } 
        List<Visit__c> listVisits =  [SELECT  CheckedOutLatitude__c,CheckedInLongitude__c,ClockIn_Latitude__c,Clockin_Longitude__c,Account1__r.GeoLocation__c,Account1__r.GeoLocation__latitude__s,Account1__r.GeoLocation__longitude__s,Visit_Type__c, Account_Name__c,Id,Account1__c,Account1__r.Name,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Planned_Start_Time__c,Status__c FROM Visit__c WHERE ((Planned_Start_Time__c >=:startDate and Planned_Start_Time__c <:endDate) or (PostPoned__c=true and lastmodifieddate >=:startDate and lastmodifieddate <:endDate)) and  ownerId =:user_id ORDER BY Actual_Start_Time__c ASC NULLS LAST]; 
        List<Visit__c> nextVisit =  [SELECT  CheckedOutLatitude__c,CheckedInLongitude__c,ClockIn_Latitude__c,Clockin_Longitude__c,Visit_Type__c, Account_Name__c,Id,Account1__c,Account1__r.Name,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Planned_Start_Time__c,Status__c,Account1__r.GeoLocation__c,Account1__r.GeoLocation__latitude__s,Account1__r.GeoLocation__longitude__s FROM Visit__c WHERE (( Planned_Start_Time__c >=:startDate  and Planned_Start_Time__c <:endDate) or (PostPoned__c=true and lastmodifieddate >=:startDate and lastmodifieddate <:endDate)) and  ownerId =:user_id ORDER BY Actual_Start_Time__c ASC NULLS LAST]; 
      
        if(nextVisit.size() > 0){
            wc.currentvisit = nextVisit[0];
          
        }
        if(listVisits.size() > 0){
            wc.Allmeetings = listVisits;
          
        }else{
            wc.Allmeetings = null;
          
        }
        wc.dailyLogs = [select Id,Clock_In__c,Clock_Out__c, Clock_In_Location__Latitude__s, Clock_In_Location__Longitude__s, Clock_Out_Location__Latitude__s, Clock_Out_Location__Longitude__s FROM DailyLog__c where CreatedDate >=:startDate and CreatedDate <:endDate and ownerId =:user_id ];
        wc.expenses = [SELECT Id,Expense_Date__c,Approval_Status__c,TA__c,DA__c FROM Expense__c WHERE ownerId =:user_id AND Expense_Date__c =:startDate1];
        
        decimal total = 0;
        if( wc.currentVisit != null && wc.Allmeetings != null){
            //system.debug(JSON.serialize(wc.Allmeetings));
           List<visit__c> cList = new List<visit__c>();
            for(integer i=0; i<wc.Allmeetings.size(); i++){
                if(wc.Allmeetings[i].status__c == 'Completed' || wc.Allmeetings[i].status__c == 'In Progress'){
                    cList.add(wc.Allmeetings[i]);
                }
            }
           for(integer i=0; i<cList.size(); i++){
                //system.debug(wc.Allmeetings[i].ClockIn_Latitude__c + ' '+wc.Allmeetings[i]);
                if(cList[i].ClockIn_Latitude__c !=null && cList[i].Clockin_Longitude__c!=null){
                        if(i!= (cList.size()-1)){
                             	Location loc1 = Location.newInstance(cList[i].ClockIn_Latitude__c, cList[i].Clockin_Longitude__c);
								Location loc2 = Location.newInstance(cList[i+1].ClockIn_Latitude__c, cList[i+1].Clockin_Longitude__c);
								system.debug(loc1+' '+loc2);
                            Double dist = Location.getDistance(loc1, loc2, 'km');
                            	total = total+dist;
                            	system.debug(i+' '+total);
                        }else{
                            
                            }
                        }
                  
                }
           
            wc.distance = total.setScale(2);
            return JSON.serialize(wc);
            
        }else{
           
            return null;
        }        
        
    }
   public class visitWrapper{
        @AuraEnabled
        public Visit__c currentvisit {get; set;} 
        @AuraEnabled
        public Visit__c dailyLog {get; set;} 
        @AuraEnabled
        public List<Visit__c> Allmeetings {get; set;}
        @AuraEnabled
        public List<DailyLog__c> dailyLogs {get; set;}
         @AuraEnabled
        public List<Expense__c> expenses {get; set;}
        @AuraEnabled
        public decimal  latti {get; set;}
        @AuraEnabled
        public decimal  longi {get; set;} 
       @AuraEnabled
        public decimal  distance {get; set;} 
    }       
    
 @AuraEnabled
    public static DailyLog__c getClockInClockOut(){
        List<DailyLog__c> clockinClockout = [SELECT id,Clock_In__c,Clock_Out__c from  DailyLog__c  WHERE   DAY_ONLY(Clock_In__c )  = today AND OwnerId =:UserInfo.getUserId() limit 1]; 
        if(clockinClockout.size() == 0){
            return null;
        }
        return clockinClockout[0]; 
    }
        
    
    
    
    
    
    
    
    
    
    
    
   /*
    @AuraEnabled
    public static string  movetoNext(String para1, String para2,String visitId){ 
        visitWrapper  wc = new visitWrapper();
        Date startDate = Date.today(); 
        Datetime endDate =  Datetime.newinstance(date.today().year(),date.today().month(),date.today().day()+1 );
        decimal latt = decimal.valueOf(para1);
        decimal longi = decimal.valueOf(para2);
        string  user_id=userinfo.getuserid();
        Visit__c currentvisit = [select Visit_Type__c, Account_Name__c,Id,Account1__c,Account1__r.Name,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Planned_Start_Time__c,Status__c,Account1__r.GeoLocation__c,Account1__r.GeoLocation__latitude__s,Account1__r.GeoLocation__longitude__s FROM Visit__c where Id=:visitId  ];   
        List<Visit__c> listVisits =  [SELECT  Visit_Type__c, Account_Name__c,Id,Account1__c,Account1__r.Name,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Planned_Start_Time__c,Status__c,Account1__r.GeoLocation__c,Account1__r.GeoLocation__latitude__s,Account1__r.GeoLocation__longitude__s FROM Visit__c WHERE DAY_ONLY(Planned_Start_Time__c)=:startDate  and Planned_Start_Time__c <:endDate  and  ownerId =:user_id ORDER BY Actual_Start_Time__c asc]; 
        wc.currentvisit= currentvisit;
        wc.Allmeetings = listVisits;
        return JSON.serialize(wc);
    }
   
   
    @AuraEnabled
    public static void updateGeoLocation(string visitId,decimal latitude,decimal longitude){
        if(visitId!=null && latitude!=null && longitude!=null){
            visit__c v=[select id,Account1__r.id, Account1__r.Geolocation__Longitude__s,Account1__r.Geolocation__Latitude__s  from visit__c where id=:visitId];
            account acc = new account();
            acc.id = v.Account1__r.id;
            acc.GeoLocation__latitude__s=latitude;
            acc.GeoLocation__Longitude__s=longitude;
            update acc; 
        }    
    } 
   */
    
     /* public static void  testcover()
    {
        Integer i =0;
        i=1;
        i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;i =0;
        
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        
        i =0;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;i =1;
        
        
    }*/
}