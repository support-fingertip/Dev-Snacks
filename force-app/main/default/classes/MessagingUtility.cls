public class MessagingUtility {
 /* @Method Name :fetchEmailAddressInvoice  @autor:Nanma @description :fetch email from Account
    *  @param-1 :Invoice record Id @date: 30/08/2024
    * @retun : MessagingUtility emailId and Email default body  @Developers :Nanma  @lastModifiedDate - 30/08/24 
    */
        @AuraEnabled
    public string email {get;set;}
    @AuraEnabled
    public string emailBody {get;set;}
    
    
    
    @auraEnabled
    public static MessagingUtility fetchEmailAddressInvoice(string invoiceId){
        Sales_Invoice__c inv =[select Id,Name,Customer__r.Name ,Invoice_Full_Name__c,Customer__r.Email__c from Sales_Invoice__c where Id=:invoiceId];
        /*fetch email &variables present in email body*/
      user u =[select Id,name,profile.Name from user where Id=:userInfo.getUserId()];
        
        MessagingUtility ms =new MessagingUtility();
        ms.email = inv.Customer__r.Email__c;
        string emailBody = label.EmailContent;
        emailBody = emailBody.replace('[CustomerName]',inv.Customer__r.Name); /* setting customer name*/
        emailBody = emailBody.replace('[InvoiceNumber]',inv.Invoice_Full_Name__c);  /* setting invoice name*/
        emailBody = emailBody.replace('[ExeName]',u.Name); /* setting employee  designation*/
        emailBody = emailBody.replace('[ExeDesign]',u.profile.Name);  /* setting employee  name*/
        system.debug(emailBody);
        ms.emailBody = emailBody;
        return ms;
    }
    
    
        /* @Method Name :sendEmailToCustomer  @autor:Nanma @description :send email with attached invoice pdf
*@param-1:email Body  @param-2 :invoice record Id @date -30/08/24
@retun : none  @Developers :Nanma  @lastModifiedDate - 30/08/24 */
    
    @AuraEnabled
    public static void sendEmailToCustomer(string body,string email,string invoiceId)
    {
        list<string> emailAddress = new list<string>();
  Sales_Invoice__c inv =[select Id,Name,Customer__r.Name ,Invoice_Full_Name__c,Customer__r.Email__c from Sales_Invoice__c where Id=:invoiceId];
         user u =[select Id,name,email,profile.Name from user where Id=:userInfo.getUserId()];
        emailAddress.add(email); /* customer Email*/
        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        PageReference pref;
        pref = page.InvoicePDFDraft; /* getting vfp page content*/
           pref.getParameters().put('id',inv.Id);
         pref.getParameters().put('userId',u.Id);
        pref.setRedirect(true);
        system.debug(pref);
        Blob b;
        if (!Test.isRunningTest()){
            b = pref.getContent();
        }
        else{  b = Blob.valueof('Some random String'); }
        attach.setFileName(inv.Invoice_Full_Name__c+'.pdf');
        attach.setBody(b);
        semail.setSubject('Invoice '+inv.Invoice_Full_Name__c+' from Seraphine Dev Impex Pvt Ltd'); /* setting companay name*/
        semail.setToAddresses(emailAddress); /*set to address*/
        semail.setPlainTextBody(body);/*set email body*/
        semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach}); /*attaching attachment to Email*/
        
        EmailMessage em = new EmailMessage();
        em.Incoming = false;
        em.FromAddress = u.Email;
        em.FromName = u.Name;
        em.TextBody = body;
        em.Subject  = 'Invoice '+inv.Invoice_Full_Name__c+' from Seraphine Dev Impex Pvt Ltd';
        em.ToAddress =email;
        em.status = '3';
        em.RelatedToId = inv.Id;
        //em.HasAttachment =true;
        insert em;
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.emailMessageId = em.Id;
        emr.relationId =  userInfo.getUserId(); // user id of the sender
        emr.relationType = 'FromAddress';
        insert emr;
        
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = b;
        ContVerFile.Title = inv.Invoice_Full_Name__c; 
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient=inv.Invoice_Full_Name__c+'.pdf';
        ContVerFile.FirstPublishLocationId = em.id;
        try{
            insert ContVerFile;
        }   
        catch (System.Exception ae) {    ExceptionHandler.addLog(ae,String.valueOf(ContVerFile) ); } /*Add Exception to error log*/ 
        try{}  catch (System.Exception ae) {    ExceptionHandler.addLog(ae,String.valueOf(em)  ); } /*Add Exception to error log*/
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});/*send email*/
    }
    
       
}