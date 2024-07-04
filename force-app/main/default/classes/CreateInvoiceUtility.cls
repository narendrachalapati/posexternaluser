public without sharing class CreateInvoiceUtility {
    public class CreateInvoicControllerException extends Exception {}

    public  static list<Project__c> ProjectinfofetchUtility(string AccountId, string ContactId) {

        List<Project__c> ProjectRecordList = new List<Project__c>();
        system.debug('ContactIdNDR' + ContactId);
        try {
            String query = 'SELECT ' + SYS_Helper.getAllFieldsFor('Project__c') + 
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Employee__r.', 'Contact') + 
            ', ' + SYS_Helper.getAllParentFields('Vendor__r.', 'Contact') +
            ' FROM Project__c WHERE Employee__c =: ContactId AND Status__c = \'Active\'';
            ProjectRecordList = Database.query(query);
            system.debug('ProjectRecordListNDR'+ ProjectRecordList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        system.debug('ProjectRecordList' + ProjectRecordList );
        return (ProjectRecordList.size()> 0) ? (ProjectRecordList) : (new list<Project__c>());

    }
   
    public  static Project__c SelectedProjectinfofetchUtility(string selectedProjectId) {
        String query = 'SELECT ' + SYS_Helper.getAllFieldsFor('Project__c') + 
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Employee__r.', 'Contact') + 
            ', ' + SYS_Helper.getAllParentFields('Vendor__r.', 'Contact') +
            ' FROM Project__c WHERE Id =: selectedProjectId';
            Project__c ProjectRecord = Database.query(query);
            system.debug('ProjectRecordListNDR'+ ProjectRecord);
       
        return (ProjectRecord !=null) ? (ProjectRecord) : (new Project__c());
    } 
    
    public static Invoice__c InvoiceCerationUtility( InvoiceWrapper invoicewrap ){
        Invoice__c invoice = new Invoice__c();
        try {
           
            invoice.Description__c = invoicewrap.Description;
            invoice.Amount__c = invoicewrap.Amount;
            invoice.Account__c = invoicewrap.AccountId;
            invoice.Contact__c = invoicewrap.ContactId;
            invoice.Invoice_Date__c = invoicewrap.invoiceDate;
            invoice.Synchronous__c = true;
            invoice.DueDate__c = invoicewrap.Duedate;
            invoice.Terms__c = invoicewrap.Term;
            invoice.VendorEmail__c = invoicewrap.selectedProject.Vendor__r.Email;
            invoice.EmployeeEmail__c = invoicewrap.selectedProject.Employee__r.Email;
            string invoiceEmails = invoicewrap.selectedProject.Vendor__r.Invoice_Emails__c;
            string employeeEmail   = invoicewrap.selectedProject.Employee__r.Email;
            string vendorEmail = invoicewrap.selectedProject.Vendor__r.Email;
            if(invoiceEmails != null){
              
               invoice.Invoice_Emails__c = invoiceEmails + ',' + employeeEmail ;
            }else{
                invoice.Invoice_Emails__c =  vendorEmail ; 
            }
            
            insert invoice;
            Invoice_Item__c invoiceitem = new Invoice_Item__c();
            invoiceitem.Invoice__c= invoice.Id;
            invoiceitem.Amount__c = invoicewrap.Amount;
            invoiceitem.UnitPrice__c = invoicewrap.Amount;
            invoiceitem.Quantity__c = 1;
            invoiceitem.Product__c = invoicewrap.ProductId;
            insert invoiceitem;
          //  sObject syslog = ApiCalloutSynchronousWithRecordId(invoicewrap.AccountId,invoice.Id,'POST','INSERT','Quickbooks','QBObjectSetting_Invoice');
           // system.debug('syslogNDR' + syslog);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return invoice;
    }
    /* 
     /* RecordId Based API Callout Outbound Synchronous */
     @AuraEnabled
     public static sObject ApiCalloutSynchronousWithRecordId(string accountId, string recId, String httpMethod, String operationType, String integrationSetting, String objectSetting) {
         Sobject fetchRecord;
         Id accountRecordId = Id.valueOf(accountId);
         system.debug('accountRecordId NDR' + accountRecordId);
         Id recordId = Id.valueOf(recId);
         system.debug('recordId NDR' + recordId);
         try {
             String objectApiName = recordId.getSObjectType().getDescribe().getName();
             Schema.SObjectType sObjectTypeField = Schema.getGlobalDescribe().get(objectApiName);
 
             if(recordId == NULL) {
                 throw new CreateInvoicControllerException('Missing recordId Parameter for ApiCalloutSynchronous');
             }
 
             if( (String.isBlank(integrationSetting)) || (String.isBlank(objectSetting)) ) {
                 throw new CreateInvoicControllerException('Missing Parameters:- Integration Setting or Object Setting for ApiCalloutSynchronous');
             }
 
             if( (String.isBlank(httpMethod)) || (String.isBlank(operationType)) ) {
                 throw new CreateInvoicControllerException('Missing Parameters:- httpMethod or operationType for ApiCalloutSynchronous');
             }
 
             // if(String.isNotBlank(httpMethod)) {
             //     SYS_ApplicationService appserviceInstance = new SYS_ApplicationService();
             //     operationType = String.isNotBlank(operationType) ? operationType : appserviceInstance.getOperationTypeFor(httpMethod); 
             // } else {
             //     throw new CustomfileuploaderControllerException('HTTP Method is required for ApiCalloutSynchronous');
             // }
 
             String query = 'SELECT '+SYS_Helper.getAllFieldsFor(objectApiName) +' FROM '+ objectApiName;
             String whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
             List<sObject> outboundRecordsList = Database.query(String.escapeSingleQuotes(query)+whereClause);
             
             if(accountRecordId != NULL){
                 SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                     accountRecordId,
                     integrationSetting,
                     integrationSetting,
                     objectSetting
                 );
             } else {
                 SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                     new List<String>{''},
                     NULL,
                     integrationSetting,
                     objectSetting
                 );
             }
             
             List<SYS_IntegrationLog__c> outboundRequestSysLogs = new List<SYS_IntegrationLog__c>();
             List<sObject> outboundResponseLogs = new List<sObject>();
             String finalJsonForOutbound;   
 
             SYS_ApplicationService appService = (SYS_ApplicationService)System.Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();
         
             Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(outboundRecordsList);
             
             if(jsonListForOutbound.values().size() > 0){
                 for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                     /*
                     Pre-processing each transformed JSON record. Default is to remove newlines.
                     For Custom pre-processing override sanitizeJSONForOutbound() method in SYS_ApplicationService
                     by creating an extension class. Configure the new extended class in ObjectSettings metadata
                     */
                     finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));
                     /*--*/SYS_debug.log('cleanJSON'+finalJsonForOutbound); 
 
                     SYS_IntegrationLog__c newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                     newSysLog.Callout_URL__c = SYS_Helper.urlFromPattern(httpMethod, jsonRecordId);
                     newSysLog.Status__c = 'NEW';
                     newSysLog.Type__c = SYS_Constants.OUTBOUND;
                     newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                     newSysLog.SYS_Operation_Type__c = operationType;
                     newSysLog.How_to_process__c = 'ignore_log';
                     newSysLog.whatid__c = jsonRecordId;
                     newSysLog.HTTP_Method__c = httpMethod;
                     newSysLog.ObjectSettingId__c = SYS_DataCacheFactory.OBJ_TYPE;
                     newSysLog.Account_Id__c = SYS_DataCacheFactory.accountId;
                     newSysLog.Integration_Type__c = SYS_DataCacheFactory.integrationType;
                     outboundRequestSysLogs.add(newSysLog);
                 }
 
                 if(!outboundRequestSysLogs.isEmpty() && SYS_DataCacheFactory.enableCheck){ 
                     SYS_IntegrationLog__c outboundRequestLog = outboundRequestSysLogs[0]; 
                     System.debug('outboundRequestLog ' + outboundRequestLog);
                     HttpResponse outboundResponse = appService.doOutbound(outboundRequestLog);
                     outboundResponseLogs.addAll(appService.generatelogForOutboundResultNew(outboundResponse, outboundRequestLog));
                 }
 
                 if(outboundResponseLogs.size() > 0){
                     SYS_Helper.upsertLog(outboundResponseLogs);  
                     Map<String, String> uuidMap = new Map<String, String>();
                     for(sObject log : outboundResponseLogs) {
                         if(((SYS_IntegrationLog__c)log).UUID__c != NULL) {
                             uuidMap.put(((SYS_IntegrationLog__c)log).UUID__c, ((SYS_IntegrationLog__c)log).Id);
                         }
                     }
                     for(sObject log : outboundResponseLogs) {
                         if(((SYS_IntegrationLog__c)log).Parent_UUID__c != NULL) {
                             ((SYS_IntegrationLog__c)log).SYS_RequestId__c = uuidMap.get(((SYS_IntegrationLog__c)log).Parent_UUID__c);
                         }
                     }
                     SYS_Helper.upsertLog(outboundResponseLogs);
                 } 
             }
 
             String fetchRecordQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor(objectApiName)
                     + ', ' + SYS_Helper.getAllParentFields('Last_Processed_SYSLog__r.', 'SYS_IntegrationLog__c')
                     + ' FROM ' + objectApiName + ' WHERE Id =:recordId';
             System.debug('fetchRecordQueryNDR ' + fetchRecordQuery);
             List<Sobject> fetchRecordsList = Database.query(fetchRecordQuery);
             fetchRecord = ( fetchRecordsList.size() > 0 ) ? fetchRecordsList[0] : NULL;
         } catch (Exception e) {
             // throw new AuraHandledException(e.getMessage());
             System.debug(e.getMessage()+'\n'+e.getStackTraceString());
             throw new CreateInvoicControllerException(e.getMessage()+'\n'+e.getStackTraceString()); 
         }
         return fetchRecord;
     }

 
    public class InvoiceWrapper {
        @AuraEnabled public Project__c selectedProject {set;get;}
        @AuraEnabled public string Description {set;get;}
        @AuraEnabled public Decimal Amount {set;get;}
        @AuraEnabled public string AccountId {set;get;}
        @AuraEnabled public string ContactId {set;get;}
        @AuraEnabled public Date invoiceDate {set;get;}
        @AuraEnabled public Date Duedate {set;get;}
        @AuraEnabled public string ProductId {set;get;}
        @AuraEnabled public string ProjectId {set;get;} 
        @AuraEnabled public string Term {set;get;}
        @AuraEnabled public string EmployeeEmail {set;get;}
        @AuraEnabled public string vendorEmail {set;get;}
    }
}