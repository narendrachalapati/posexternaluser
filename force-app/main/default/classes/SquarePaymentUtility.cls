public without sharing class SquarePaymentUtility {
    public class CreateInvoicControllerException extends Exception {}
    /* This method is used for creating a card record */
    public static  card__c cardRecCreationUtility(string memberId,string AccountId,string token) {
        Card__c card = new Card__c ();
        card.Customer__c = memberId;
        card.Account__c =  AccountId;
        card.Source_Id__c = token;
        card.Synchronous__c = true;
        insert card;
        card__c cardfetch = [SELECT Id,Customer__c,Account__c,Source_Id__c from Card__c where Source_Id__c=:token AND Account__c=:AccountId AND Customer__c =:memberId AND Synchronous__c =true];
     return cardfetch;
    }
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

   
    
      /* This method is used for creating a card record */
      public static  Payments__c paymentRecCreationUtility(string memberId,string AccountId,Decimal amount,string selectedcardId) {
        system.debug('selectedcardIdNDR ' + selectedcardId);
        Payments__c payment = new Payments__c ();
        payment.Source_Id__c = selectedcardId;
        payment.Amount__c = amount;
        payment.Account__c =  AccountId;
        payment.Currency__c = 'USD';
        payment.Customer__c = memberId;
        payment.Synchronous__c = true;
        insert payment;
        system.debug('payment NDR' + payment);
     return payment;
    }

    
    public static HttpResponse buildOutboundHttpRequest(Id accountRecordId, String integrationSetting, String objectSetting, String operationType, String httpMethod, String calloutUrl, String requestJsonBody, Map<String, String> customHeaders) {
        try {
            List<SYS_IntegrationLog__c> outboundRequestSysLogs = new List<SYS_IntegrationLog__c>();
            List<sObject> outboundResponseLogs = new List<sObject>();
            String finalJsonForOutbound;

            //Request and Response Specific Variables
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            SYS_IntegrationLog__c outboundSysLog = new SYS_IntegrationLog__c();

            if( (String.isBlank(integrationSetting)) || (String.isBlank(objectSetting)) ) {
                throw new CreateInvoicControllerException('Missing Parameters:- Integration Setting or Object Setting for ApiCalloutSynchronous');
            }

            //Init Appservice and DataCache
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

            SYS_ApplicationService appService = (SYS_ApplicationService)System.Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();

            // If Method was Empty -> Set HTTP Method Based on Metadata
            if( String.isBlank(httpMethod) ) {
                httpMethod = appService.getHttpRequestMethod(outboundSysLog, NULL);
            }

            // If calloutUrl was Empty -> Set calloutUrl Based on Metadata
            if( String.isBlank(calloutUrl) ) {
                calloutUrl = appService.getHttpRequestEndpoint(req, outboundSysLog, NULL);
            }

            if( (String.isBlank(httpMethod)) || (String.isBlank(operationType)) ) {
                throw new CreateInvoicControllerException('Missing Parameters:- httpMethod or operationType for ApiCalloutSynchronous');
            }
            
            outboundSysLog = SYS_Helper.getLogsToInsert(requestJsonBody);
            outboundSysLog.Callout_URL__c = calloutUrl;
            outboundSysLog.Status__c = 'NEW';
            outboundSysLog.Type__c = SYS_Constants.OUTBOUND;
            outboundSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            outboundSysLog.SYS_Operation_Type__c = operationType;
            outboundSysLog.How_to_process__c = 'ignore_log';
            outboundSysLog.whatid__c = '';
            outboundSysLog.HTTP_Method__c = httpMethod;
            outboundSysLog.ObjectSettingId__c = SYS_DataCacheFactory.OBJ_TYPE;
            outboundSysLog.Account_Id__c = SYS_DataCacheFactory.accountId;
            outboundSysLog.Integration_Type__c = SYS_DataCacheFactory.integrationType;
            outboundRequestSysLogs.add(outboundSysLog);

            //Set Auth Header from Framework
            appService.setHttpRequestHeaders(req,outboundSysLog);

            // Check if custom headers map is not empty
            if (!customHeaders.isEmpty()) {
                // Iterate over custom headers and add to existing headers
                for (String key : customHeaders.keySet()) {
                    req.setHeader(key, customHeaders.get(key));
                }
            }

            System.debug('Header Name: Content-Type Value: ' + req.getHeader('Content-Type'));
            System.debug('Header Name: Content-Length Value: ' + req.getHeader('Content-Length'));

            //Set EndPoint
            req.setMethod(httpMethod);
            req.setEndpoint(calloutUrl);
            if(!string.isEmpty(requestJsonBody)){
                req.setBody(requestJsonBody);
                System.debug('Outbound Request json:' + requestJsonBody);
    
            }
            
            //Do HTTP Callout
            HttpResponse outboundResponse = http.send(req);
            string responseBody = outboundResponse.getBody();
            system.debug('##### responseBody #######' + responseBody);
            if(responseBody != '{}'){
            if(!outboundRequestSysLogs.isEmpty() && SYS_DataCacheFactory.enableCheck){ 
                SYS_IntegrationLog__c outboundRequestLog = outboundRequestSysLogs[0]; 
                
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
              System.debug('Outbound Response: ' + outboundResponse.getBody() );
            }
            
            return outboundResponse;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new CreateInvoicControllerException(e.getMessage()+'\n'+e.getStackTraceString()); 
        }
    }
    /* This method is used for getting the amount for the payment */
    public static  decimal gettingAmountForPayment(string orderId,string AppointmentId,Decimal amount, string customerId) {
        decimal payableamount;
        if(amount != 0.00 || amount != 0) {
            payableamount = amount;
            system.debug('from amount' + payableamount);
        }
        else if(String.isNotBlank(orderId)){
            order__c order = [select Id,Total_Price__c from order__c where Id =:orderId];
            payableamount = order.Total_Price__c;
            system.debug('from order' + payableamount);
        }else if(String.isNotBlank(AppointmentId)){
            Appointment_Scheduling__c Appointment = [SELECT Product__r.Default_Price__c from Appointment_Scheduling__c where Id =:AppointmentId ];
            payableamount = Appointment.Product__r.Default_Price__c;
            system.debug('from Appointment' + payableamount);
        }else{
         contact con = [SELECT Balance__c,Id from contact where Id =:customerId];
         payableamount = con.Balance__c;
         system.debug('from contact' + payableamount);
        }
        return  payableamount;
    }
}