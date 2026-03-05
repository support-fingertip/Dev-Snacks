global class CalenderManager {
    public static calEvent[] events { get; set;}
    public String selectedRep {  get;  set; }
    public static String startString {  get;  set; }
    public static String endString {  get;  set; }
    public String usersTimezoneOffset {
        get;
        set;
    }
    static String dtFormat = 'EEE, d MMM yyyy HH:mm:ss +05:30';
    
    
    public static String selectedType {  get;  set; }
    public static List<Object> objectList {  get;  set; }
    
    
    public CalenderManager(){
        
    }
    
    public class calEvent {
        public String  title {get;set;}
        public Boolean allDay {get;set;}
        public String  startString {get;set;}
        public String  endString {get;set;}
        public String  url {get;set; }
        public String  className {get;set;}
        public String  id {get;set;}
        public String  dealerId {get;set;}
        public String  ownerId {get;set;}
    }
    
    public class accountData {
        public String  Id {get;set;}
        public String Name {get;set;}
       public String status {get;set;}
    }
    
    @RemoteAction
    public static List<accountData> listRecords(string userId,string searchText){
        List<accountData> accountList = new List<accountData>();
        id currentuserId = userinfo.getUserId();
        List<User> userDetails = [Select id,UserRoleId from user where Id =: userId LIMIT 1];
        set<Id> userroleIds = new set<Id>();
        for(User u : userDetails){
            userroleIds.add(u.UserRoleId);
        }
        Set<Id> roleIds = getAllSubRoleIds(userroleIds);
        Map<Id,User> mapUser = new map<Id,User>([select id from User where UserRoleId IN : roleIds]);
        String searchTxt = '%'+searchText+'%';
        if(!userDetails.isEmpty()){
           // if(userDetails[0].Category_Type__c == 'Retail Lead' || userDetails[0].Category_Type__c == 'Both'){
            	for(Account acc : [select id, Name,Approval_status__c from Account where (ownerid =:userId or OwnerId IN : mapUser.keyset()) and Approval_status__c='Approved' and Name like : searchTxt Order by Name asc]){
                   
                   accountList.add(assignData(acc.Id,acc.Name));    
                }
           // }
           
        }   
        return accountList;
    }
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();
    
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId 
             IN :roleIds AND ParentRoleID != null]) {
            currentRoleIds.add(userRole.Id);
        }
    
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
    
        return currentRoleIds;
    }
    
    public static accountData assignData(String recId, String recName){
        accountData ad = new accountData();
        ad.Id = recId;
        ad.Name = recName;
        return ad;
    }
    
    public static list < User > getRepresentative() {
        //list < SelectOption > options = new list < SelectOption > (); 
        list < user > user = new list < user > ();
        id currentuserId = userinfo.getUserId();
        user = [select id, name from user where IsActive = true order by Name asc ];
        system.debug('user--->' + user);
        /*options.add(new SelectOption('None', '-Select-'));
        for (user user1: user) {
            options.add(new SelectOption(user1.id, user1.name)); 
        }*/
        return user;
    } 
    @RemoteAction
    global static String showEvents(string selectedRep, string startstr,string endstr) {
        
        startstr = startstr.replaceAll('T',' ');
        endstr = endstr.replaceAll('T',' ');
        datetime startDatetime = datetime.valueof(startstr);
        datetime endDatetime = datetime.valueof(endstr);
        system.debug(startstr);
        system.debug(endstr);
        if(events != null){ 
            events.clear(); 
        } 
        else{
            events = new List<calEvent>();
        }
        if(selectedRep == null){
            selectedRep = userinfo.getuserId();  
        } 
        List<Visit__c> eventList = [select Id,ownerId,planned_start_Time__c,planned_end_Time__c,Account1__r.Name  from Visit__c where planned_start_Time__c>=:startDatetime  and  planned_start_Time__c <=: endDatetime and  ownerId =: selectedRep ];
        for(Visit__c e: eventList){
            calEvent ev = new calEvent();
            //if(e.Lead__c == null)
                ev.title = e.Account1__r.Name;
           /* else if(e.Lead__c != null)
                ev.title = e.Lead__r.Full_Name__c+' '+ e.Lead__r.Last_Name__c;*/
            ev.startString =  string.valueof( e.planned_start_Time__c); 
            ev.endString =  string.valueof(e.planned_end_Time__c); 
            ev.url = '/' + e.Id; 
            ev.id =   e.Id;
            //if(e.Lead__c == null)
                ev.className = e.Account1__r.Name != null ? 'event-personal' : 'fc-account'; 
           /* else if(e.Lead__c != null){
                ev.className = 'fc-lead';
            } */   
            ev.ownerId = e.ownerId;
            //if(e.Lead__c == null)
                ev.dealerId = e.Account1__c;
           /* else if(e.lead__c != null)
                ev.dealerId = e.Lead__c;*/
            events.add(ev);
            
        }
        System.debug(events);
        
        List<string> EventJsonString=new List<string>();
        
        
        return JSON.serialize(events);
    }
    
    @RemoteAction 
    public static void  deleteEvent(string eventId) {
        if(Schema.sObjectType.visit__c.isDeletable()){
            delete [select id from visit__c where id =:eventId];
        }  
    }
    
    @RemoteAction
    public static string saveVisit(calEvent cal) { 
        Visit__c vis = new Visit__c(); 
        // vis.Date__c = datetime.valueof(cal.startString);
        vis.Planned_Start_Time__c = datetime.valueofGMT(cal.startString.replaceall('T',' '));
         vis.Planned_Start_Time__c= vis.Planned_Start_Time__c.addMinutes(360);
        vis.Planned_End_Time__c = vis.Planned_Start_Time__c.addMinutes(30);
        vis.status__c = 'Planned';
       Datetime x =  Datetime.now();
        string userid = UserInfo.getUserId();
        String format = userid.mid(10, 8);
        vis.EId__c = 'V'+format+x.year()+x.month()+x.day()+x.millisecond()+'C';
        id recordId = cal.dealerId;
        if(recordId != null){
            String sobjectType = recordId.getSObjectType().getDescribe().getName();
            if(sobjectType == 'Account'){
               // vis.Dealer__c = cal.dealerId ;
                vis.Account1__c = cal.dealerId;
            }else{
              //  vis.Account__c =  cal.dealerId;
            }  
        }     
        vis.ownerId = cal.ownerId;
        insert vis; 
        return vis.id;
    }
    @RemoteAction
    public static void updateVisit(calEvent cal) { 
        Visit__c vis =  [select id ,Planned_Start_Time__c ,Planned_End_Time__c from Visit__c  where id=:cal.id ]; 
        // vis.Date__c = datetime.valueof(cal.startString);
        vis.Planned_Start_Time__c = datetime.valueofGMT(cal.startString.replaceall('T',' '));
        vis.Planned_End_Time__c = datetime.valueofGMT(cal.endString.replaceall('T',' '));
        
        update vis; 
    }
    
    
    
}