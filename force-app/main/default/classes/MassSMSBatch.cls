public with sharing class MassSMSBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public List<Id> activityIds = new List<Id>();

    public MassSMSBatch(List<Id> activityIds) {
        this.activityIds = activityIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> activityList = this.activityIds;
        String query = 'SELECT Id FROM Activity__c WHERE Id IN :activityList';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            for(sObject item:scope) {
                SYS_ForceSync_Controller.invokeAccountFlow(item.Id,'PlivoSMS','Plivo_Outbound_SYS_ApplicationService', 'OUT', 
                'Account__c');
    
            }
        } catch(Exception e) {
            System.debug('Some error occured '+e.getStackTraceString()+e.getMessage());
        }
        
        
    }

    public void finish(Database.BatchableContext BC){
        //nothing so far

        // AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
        // TotalJobItems, CreatedBy.Email
        // from AsyncApexJob where Id =:BC.getJobId()];

        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // String[] toAddresses = new String[] {'soumya@adisols.com'};
        // mail.setToAddresses(toAddresses);
        // mail.setSubject('Mass SMS Status ' + a.Status);
        // mail.setPlainTextBody('Mass SMS Sent. Request count' + a.TotalJobItems  +
        // ' ## batches with '+ a.NumberOfErrors + ' failures.');
        // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}