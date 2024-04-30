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
    public ToDo__c todorecord { get; set; }
    @AuraEnabled
    public ToDo__c updatedTodorecord { get; set; }
    @AuraEnabled
    public string uuid { get; set; } 
    @AuraEnabled
    public static Project__c Projectinfofetch( string AccountId, string ContactId){
     return CreateInvoiceUtility.ProjectinfofetchUtility(AccountId,ContactId);
     }
    @AuraEnabled
    public static Invoice__c InvoiceCeration( string Description, Decimal Amount,string AccountId,string ContactId,Date invoiceDate ){
      return CreateInvoiceUtility.InvoiceCerationUtility( Description,Amount, AccountId, ContactId,invoiceDate );
    }
}