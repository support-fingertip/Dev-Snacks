trigger InvoiceNumberSeriesTrigger on Invoice_Number_Series__c (before insert) {
    
    if(Label.Enable_Number_Series_Trigger == 'TRUE'){
        If(trigger.isInsert && trigger.isBefore){
            InvoiceNumberSeriesTriggerHandler.addLastInvoiceNumber(trigger.new);
        }
    }
    
}