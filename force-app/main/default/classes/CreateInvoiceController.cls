public with sharing class CreateInvoiceController {
    @AuraEnabled
    public Order__C orderdata { get; set; }
    @AuraEnabled
    public Order__C cancelorder { get; set; }
    @AuraEnabled
    public string memberrecordid { get; set; }
    @AuraEnabled
    public string Accountrecordid { get; set; } 
    @AuraEnabled
    public String todorecordid { get; set; }
    @AuraEnabled
    public ToDo__c todorecord { get; set; }
    @AuraEnabled
    public ToDo__c updatedTodorecord { get; set; }
    @AuraEnabled
    public string uuid { get; set; } 
   
    @AuraEnabled
    public static list<Project__c> Projectinfofetch( string AccountId, string ContactId){
     return CreateInvoiceUtility.ProjectinfofetchUtility(AccountId,ContactId);
     }
    @AuraEnabled
    public static Invoice__c InvoiceCeration(CreateInvoiceUtility.InvoiceWrapper invoicewrap){
      system.debug('###############invoicewrap NDR################' + invoicewrap);
     
      return CreateInvoiceUtility.InvoiceCerationUtility(invoicewrap);
    }
    /*Used for fetching the selected Project details*/
    @AuraEnabled
    public static Project__c SelectedProjectinfofetch(string selectedProjectId){
      system.debug('###############SelectedProjectinfofetchUtility NDR################' + selectedProjectId);
     
      return CreateInvoiceUtility.SelectedProjectinfofetchUtility(selectedProjectId);
    }
    /* Doing callout for Invoice*/
    @AuraEnabled
    public static sObject InvoiceSynchronouscallout(string AccountId, string invoiceId){
      system.debug('###############invoicewrap NDR################' + AccountId + invoiceId);
     
      return CreateInvoiceUtility.ApiCalloutSynchronousWithRecordId(AccountId,invoiceId,'POST','INSERT','Quickbooks','QBObjectSetting_Invoice');
    }

     /* Doing callout for Invoice Email send*/
     @AuraEnabled
     public static sObject InvoiceEmailSynchronouscallout(string AccountId, string invoiceId){
       system.debug('###############invoicewrap NDR################' + AccountId + invoiceId);
      
       return CreateInvoiceUtility.ApiCalloutSynchronousWithRecordId(AccountId,invoiceId,'POST','INSERT','Quickbooks','QBObjectSetting_SendInvoiceEmail');
     }
     
}