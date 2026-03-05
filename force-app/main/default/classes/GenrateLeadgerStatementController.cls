public class GenrateLeadgerStatementController {
    @auraEnabled
    Public static string GetCustomLedger(string recId,Date d1,Date d2 ){
        string status;
        if(String.isBlank(recId)  || d1 ==null || d2 ==null){
           status='fail' ;
        }else{
            system.debug('indside method >>'+recId+'d1>>'+d1+'d2>>'+d2);
            status='pass';
        }
        return status;
    }
    
}