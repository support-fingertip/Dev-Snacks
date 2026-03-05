trigger OrderTrigger on Order__c (before insert) {
	for(Order__c ord: Trigger.new)
    {
        ord.Order_date__c = system.today();
        if(ord.EId__c ==null){
        Datetime x =  Datetime.now();
        string userid = UserInfo.getUserId();
        String format = userid.mid(10, 8);
        ord.EId__c = 'O'+format+x.year()+x.month()+x.day()+x.millisecond()+'S';
    }
    }
}