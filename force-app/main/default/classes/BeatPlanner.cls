public class BeatPlanner { 
    
  /*  @AuraEnabled
    public static List<Route__c> getRouteList(string uId) {
        
        List<RR_member__c> rrmList = [SELECT Id,Name,User__c,RR_queue__c FROM RR_member__c WHERE User__c =: uId];
        Set<Id> rq = new Set<Id>();
        
        for(RR_member__c rrm: rrmList){
            rq.add(rrm.RR_queue__c);
        }
        List<RR_queue__c> rrqlist = [SELECT Id,Municipality__c FROM RR_queue__c WHERE Id IN: rq];
        
        Set<Id> mun = new Set<Id>();
        
        for(RR_queue__c rrq: rrqlist){
            mun.add(rrq.municipality__c);
        }
        return  [SELECT Id,Name,State__c,District__c FROM Route__c WHERE Id IN: mun];
        
    }
    @AuraEnabled
    public static List<Account1__c> getAccountList( string uId,string District, string beatId) {
        
        List<Beat_Line__c> blist = [select id,account1__c from Beat_Line__c where beat__c =: beatId];
        List<id> existds = new list<id>();
        for(Beat_Line__c b: blist){
            existds.add( b.account1__c);
        }
        List<String> districtList = new List<String>();
        if(!test.isRunningTest())
            districtList = (List<String>)JSON.deserialize(District, List<String>.class);
        return [SELECT Id, Name,Routes__c, RouteName__c, Product_Type__c, Division__c,State__c,District__c,Owner.Name FROM Account1__c  WHERE OwnerId=:uId AND District__c In:districtList and id not in : existds ];
        
    }
    
    
    public static  Map<decimal, List<Beat_Line__c>> bmap  {get;set;}
    @AuraEnabled
    public static void getbeatLineList() {
        string   beatId = apexpages.currentPage().getParameters().get('id');
        bmap  =  new  Map<decimal, List<Beat_Line__c>>();
        Beat__c beat = [select id, Number_Days__c from beat__c where id=: beatId];
        List<Beat_Line__c>  blist = [ SELECT Id, day__c, Name,  Beat__c, Account1__c,  Account1__r.Name, Day_Order__c, Mode_of_Transport__c, Type_of_Visit__c, When__c, Where__Latitude__s, Where__Longitude__s, Where__c, With_Executive_1__c, With_Executive_2__c, With__c, Assigned_Beat_User__c, Beat_User__c,   Sub_Mode_of_transport__c FROM Beat_Line__c where beat__c=:BeatId order by Day__c asc ];
        for(Beat_Line__c b: blist){ 
            if(bmap.containsKey(b.day__c))
            {
                bmap.get(b.day__c).add(b);
            }else{
                bmap.put(b.day__c, new list<Beat_Line__c>{b} );
            }
        } 
        for(decimal i=1;i<=beat.Number_Days__c;i++){
            
            if(bmap.get(i) ==null){
                bmap.put(i, new List<Beat_Line__c>()) ;
                system.debug(i);
            }
            
            
        }
        system.debug( 'bmap'+bmap);
    }
    
    
    @AuraEnabled
    public static void createBeatLines( string uId, string  beatId,string day,List<sobject> lines) {
        List<Beat_Line__c> bList = new List<Beat_Line__c>();
        //SELECT Id, Day__c, Today_Selection__c, Sub_Mode_of_transport__c, Number_of_Visits_Required__c,
        // Beat_User__c, Assigned_Beat_User__c, With__c, With_Executive_2__c, Where__Longitude__s, 
        // Where__Latitude__s, When__c, Type_of_Visit__c, Mode_of_Transport__c, Day_Order__c, Accounts__c,
        //  Account__c, Beat__c, Name FROM Beat_Line__c
        //  
        
        for(sobject so: lines){
            
            Account1__c  a = (Account1__c )so;
            Beat_Line__c bl= new Beat_Line__c();
            bl.Beat__c = beatId;
            bl.Day__c = integer.valueof( day );
            bl.Account1__c = a.id;
            bList.add(bl); 
            
            
        }
        insert bList;
        
        
    }
    @remoteaction
    public static string deleteVisitPlan(String deleteId){
        delete [select id from beat_line__c where id=: deleteId];
        return 'success';
        
    }
    @AuraEnabled
    public static void createVisits(  string beatId) {
        Beat__c beat = [SELECT Id, Name, Next_Day_Order__c, To_Day__c, Executive__c, From_Day__c, Number_Days__c, Off_Days__c FROM Beat__c where id=:beatId ];
        List<Beat_Line__c>  blist = [ SELECT Id, day__c, Name,  Beat__c, Account1__c,  Account1__r.Name, Day_Order__c, Mode_of_Transport__c, Type_of_Visit__c, When__c, Where__Latitude__s, Where__Longitude__s, Where__c, With_Executive_1__c, With_Executive_2__c, With__c, Assigned_Beat_User__c, Beat_User__c,   Sub_Mode_of_transport__c FROM Beat_Line__c where beat__c=:beatId order by Day__c asc ];
        List<visit__c> visitExList = [select id,status__c from visit__c where Beat_Line__c in:blist and status__c = 'Planned' ];
        List<Holiday__c> hlist = [select id,date__c from Holiday__c];
        List<Beat_Skip__c> bslist = [select id,date__c from Beat_Skip__c];
        
        delete visitExList;
        
        Set<Id> beatLines = new  Set<Id>();
        Set<date> skipset = new  Set<date>();
        List<visit__c> vlist = new  List<visit__c>();
        
        for(Holiday__c h: hlist){
            skipset.add(h.date__c);
        } 
        for(Beat_Skip__c b: bslist){
            skipset.add(b.date__c);
        } 
        
        datetime startdate = beat.From_Day__c;
        datetime enddate = beat.To_Day__c;
        datetime currDate =  startdate;
        decimal oldday = 1;
        while(currDate <= enddate){
            
            for(Beat_Line__c bl : blist){ 
                visit__c v = new visit__c();
                
                if(oldday !=  bl.Day__c){
                    oldday =  bl.Day__c;
                    currDate = currDate.addDays( 1 );
                }
                
                
                while((beat.Off_Days__c != null && beat.Off_Days__c.contains(currDate.format('EEEE') )) ||   skipset.contains( date.valueof( currDate ) )  ){
                    currDate = currDate.addDays(1);
                } 
                
                v.Planned_Start_Time__c = currDate;
                v.Status__c = 'Planned';  
                v.New_Account__c = bl.Account1__c;
                v.Beat_Line__c = bl.id;
                currDate = v.Planned_Start_Time__c;
                v.ownerId = beat.Executive__c;
                vlist.add(v); 
                
            }
            
        }
        
        insert vlist;
        
    }*/
    
}