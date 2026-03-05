global class  DeleteRecordsWithinDateRange implements Database.Batchable <Sobject>{
    global string query;
    Date startDate;
    Date endDate;
    string objectName;
    integer count=0;
    integer successCount=0;
    integer failedCount=0;
    global DeleteRecordsWithinDateRange(Date startDate, Date endDate,string objectName,integer count) {
        this.startDate = startDate;
        this.endDate = endDate;
         this.objectName = objectName;
         this.count = count;
        query = 'SELECT Id FROM '+objectName +' WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate';
        if(objectName == 'Sales_Order__c'){
            query += ' AND Status__c = \'Converted\'';
        }
        system.debug(query);
    }
    Global Database.QueryLocator Start(Database.BatchableContext bcontext) {
        return Database.getQueryLocator( query);
    }
    Global void Execute(Database.BatchableContext bcontext,list<Sobject> recordToProcess){
        Database.DeleteResult[] results = Database.delete(recordToProcess, false);
        for (Database.DeleteResult res : results) {
    if (res.isSuccess()) {
        successCount++;
    } else {
        failedCount++;
    }
}

System.debug('Success: ' + successCount + ', Failed: ' + failedCount);
    }
    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'nanma@fingertipplus.com','mayuri.patel@fingertipplus.com','networkadmin@seraphinedevimpex.com'};//'mayuri.patel@fingertipplus.com',
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Job Complete');
        string htmlbody ='The batch job to delete .<br/>Object Name: '+objectName+'<br/>  Date range : '+startDate +' to '+endDate +'<br/> Data Count :'+count ;
        mail.setHtmlBody(htmlbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}