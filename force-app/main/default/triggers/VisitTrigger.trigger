trigger VisitTrigger on Visit__c (before insert) {
 Integer i = 0;
for(Visit__c vs: Trigger.new)
    {
        if(vs.EId__c ==null){
        Datetime x =  Datetime.now();
        string userid = UserInfo.getUserId();
        String format = userid.mid(10, 8);
        vs.EId__c = 'V'+format+x.year()+x.month()+x.day()+x.millisecond()+'S'+ i;
        i++;
    }
    }

}