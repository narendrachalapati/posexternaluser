public without sharing class CreateInvoiceUtility {

    public  static Project__c ProjectinfofetchUtility(string AccountId, string ContactId) {
        List<Project__c> ProjectRecordList = new List<Project__c>();
        try {
            String query = 'SELECT ' + 
            SYS_Helper.getAllFieldsFor('Project__c') + ', ' + 
            SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ' FROM Project__c WHERE Employee__c =: ContactId AND Status__c = \'Active\'';
            ProjectRecordList = Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        system.debug('ProjectRecordList' + ProjectRecordList );
        return (ProjectRecordList.size()> 0) ? (ProjectRecordList[0]) : (new Project__c());

    }
    public static Invoice__c InvoiceCerationUtility( string Description, Decimal Amount,string AccountId,string ContactId,Date invoiceDate ){
        Invoice__c invoice = new Invoice__c();
        try {
           
            invoice.Description__c = Description;
            invoice.Amount__c = Amount;
            invoice.Account__c = AccountId;
            invoice.Contact__c = ContactId;
            invoice.Invoice_Date__c = invoiceDate;
            insert invoice;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return invoice;
    }

}