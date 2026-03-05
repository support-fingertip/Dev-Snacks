trigger OrderLineItemTrigger on Order_Item__c (before insert) {
	for(Order_Item__c ord: Trigger.new)
    {
        if(ord.EId__c ==null){
        Datetime x =  Datetime.now();
        string userid = UserInfo.getUserId();
        String format = userid.mid(10, 8);
        ord.EId__c = 'OI'+format+x.year()+x.month()+x.day()+x.millisecond()+'S';
    }
    }
}