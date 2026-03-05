public class GetAvailableStockController {
    @auraEnabled
    Public static string GetCustomStock(string recId,Date d1,Date d2 ){
        string status;
        if(String.isBlank(recId)  || d1 ==null || d2 ==null){
            status='fail' ;
        }else{
            system.debug('indside method >>'+recId+'d1>>'+d1+'d2>>'+d2);
            status='pass';
        }
        return status;
    }
    @auraEnabled
    Public static String  GetStock(string recId,string LedgerOf ){
        string status;
        if(String.isBlank(recId) || String.isBlank(LedgerOf) ){
            status='fail';
        }else{
            status='pass';
            system.debug('indside method >>'+recId+'LedgerOf>>'+LedgerOf);
            
        }
        
        return status;
    }
}