public class Plivo_IB_SYS_ApplicationService extends SYS_ApplicationService {
    public Plivo_IB_SYS_ApplicationService() {

    }

    /* ---------------  Inbound Webhook Processing  ----------------------*/
    //Convert Request Params Map Keys to Lowercase
    public static String convertRequestParamsJSON(Map<String,String> reqParams){
        String requestBody='';
        Map<String, String> newrequestParams = new Map<String, String>(); 
        for(String key : reqParams.keySet()){
            newrequestParams.put(key.toLowerCase(), reqParams.get(key));
        }
        requestBody=JSON.serialize(newrequestParams);
        SYS_debug.log('body== from Params' + requestBody);  
        return requestBody;
    }
    
    /**
     * This hook is called from each of the hook for Http Verb processing
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    public override List<SYS_IntegrationLog__c> generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();

        Map<String, String> requestParams = RestContext.request.params;
        Map<String, String> webHookEvents = new Map<String, String>{'StartApp' => 'callincoming', 'Ring' => 'callincoming', 'Hangup' => 'callincoming', 'ConferenceEnter' => 'conferencecall' , 'ConferenceExit' => 'conferencecall', 'ConferenceRecordStart' => 'conferencecall' , 'ConferenceRecordStop' => 'conferencecall'  };
        if(requestBody=='' && !requestParams.isEmpty()){
            requestBody = convertRequestParamsJSON(requestParams);
        } 
        
        
        Id contactId, accountId, leadId, whattId;
        accountId = SYS_DataCacheFactory.accountId;
        String accountFilterCriteria = (accountId != null) ? ' AND AccountId =:accountId' : '';
        String findCustomerQuery;
        method = getOperationTypeFor(method);
        Map<String, Object> newflatKeyMap = new Map<String, Object>();
        List<Contact> findCustomer  = new List<Contact>();
        String rootkey, eventType, newjsonBody,newCallStatus;
        Boolean containsCallKey,containsEventKey,isInboundSMSMMS,containsRecordingResponseKey,hasCallStatusKey;
        Object responseType = JSON.deserializeUntyped(requestBody);
        if(responseType instanceof Map<String,Object>){
            rootkey = new List<String>(((Map<String, Object>)responseType).keySet())[0];
            newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody ,'A.B'));  
            containsEventKey = newflatKeyMap.containsKey('event');
            containsCallKey = newflatKeyMap.containsKey('plivoevent');
            isInboundSMSMMS = newflatKeyMap.containsKey('messagedirection');
            containsRecordingResponseKey = newflatKeyMap.containsKey('response');
            hasCallStatusKey = newflatKeyMap.containsKey('callstatus');
        }
        if( (rootkey!='') && (newflatKeyMap.containsKey('to') == true) && (newflatKeyMap.containsKey('type') == true) ){
            String eventTypesms = (String)newflatKeyMap.get('type');
            String smsToNumber = (String)newflatKeyMap.get('to'); // Plivo Number IB
            String smsFromNumber = (String)newflatKeyMap.get('from');//Customer Number IB
            if( ( (eventTypesms == 'sms') || (eventTypesms == 'mms') ) && (isInboundSMSMMS == false) ){ // Outbound Webhooks SMS Or MMS
                if(newflatKeyMap.containsKey('sequence')){
                    String sequenceValue = (String)newflatKeyMap.get('sequence');
                    if(sequenceValue == '1'){
                        ((Map<String, Object>) responseType).remove('status'); 
                    }
                }
                if(newflatKeyMap.containsKey('errorcode')){
                    String errorcodeValue = (String)newflatKeyMap.get('errorcode');
                    if ( String.isNotBlank(errorcodeValue) ) {
                        if (errorcodeValue == '200') {
                            ((Map < String, Object > ) responseType).put('error', 'The destination has opted out from your campaign and blocked all messages sent from your phone number. All messages to destinations that have opted out are blocked until the destination opts in with another response.');
                        } else {
                            ((Map < String, Object > ) responseType).put('error', 'Oops! failed to deliver the message ' + errorcodeValue + ' Refer the following Page for more details https://www.plivo.com/docs/sms/troubleshooting/error-codes/');
                        }
                    }
                }
                // ((Map < String, Object > ) responseType).put('status', 'Delivered');
                ((Map < String, Object > ) responseType).put('contactnumber', smsToNumber);
                ((Map < String, Object > ) responseType).put('externalnumber', smsFromNumber);
                newjsonBody = JSON.serialize(responseType);
                requestBody = newjsonBody;
                responseType = JSON.deserializeUntyped(requestBody);
                method = 'UPDATE';
            }

            if( ( (eventTypesms == 'sms') && (isInboundSMSMMS == true) ) || ( (eventTypesms == 'mms') && (isInboundSMSMMS == true) ) ){ // INBOUND SMS Or MMS                
                SYS_debug.log('INBOUND SMS OR MMS eventType ' + eventType);

                ((Map < String, Object > ) responseType).put('direction', 'INBOUND');                
                ((Map < String, Object > ) responseType).put('contactnumber', smsFromNumber);
                ((Map < String, Object > ) responseType).put('externalnumber', smsToNumber);
                ((Map < String, Object > ) responseType).put('receivedAt', DateTime.now());

                Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
                SYS_debug.log('remainingRows ' + remainingRows);

                String inboxAccountFilterCriteria = (accountId != null) ? ' AND Account__c =:accountId' : '';
                String inboxSearchQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Inbox__c') +
                ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
                ' FROM Inbox__c WHERE External_Contact_Point__c =: smsFromNumber'+ inboxAccountFilterCriteria +' ORDER BY Latest_Message_Received_At__c DESC LIMIT 1';
                List<Inbox__c> inboxRecordsList = Database.query(inboxSearchQuery);
                
                if(inboxRecordsList.size() > 0){
                    SYS_debug.log('inboxRecordsList ' + inboxRecordsList);
                    SYS_debug.log('(inboxRecordsList.size() > 0)  ' + (inboxRecordsList.size()));
                    contactId = (inboxRecordsList.size() > 0) ? inboxRecordsList[0].Contact__c : null;
                    accountId = (inboxRecordsList.size() > 0) ? inboxRecordsList[0].Account__c : null;
                    leadId = (inboxRecordsList.size() > 0) ? inboxRecordsList[0].Lead__c : null;
                    whattId = (inboxRecordsList.size() > 0) ? inboxRecordsList[0].WhatId__c : null;
                    ((Map < String, Object > ) responseType).put('contactId', contactId);
                    ((Map < String, Object > ) responseType).put('accountId', accountId);
                    // ((Map < String, Object > ) responseType).put('leadId', leadId);
                    ((Map < String, Object > ) responseType).put('whattId', whattId);
                } else {//Search Contacts with phone
                    //Fetch Contact for Account Lookup 
                    findCustomerQuery = 'SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId FROM Contact WHERE Formatted_Phone_Number__c =:smsFromNumber' + accountFilterCriteria + ' ORDER BY LastModifiedDate LIMIT 1';
                    findCustomer = Database.query(findCustomerQuery);

                    SYS_debug.log('findCustomer ' + findCustomer);
                    SYS_debug.log('(findCustomer.size() > 0)  ' + (findCustomer.size()));
                    contactId = (findCustomer.size() > 0) ? findCustomer[0].Id : null;
                    accountId = (findCustomer.size() > 0) ? findCustomer[0].AccountId : null;
                    ((Map < String, Object > ) responseType).put('contactId', contactId);
                    ((Map < String, Object > ) responseType).put('accountId', accountId);

                    //Map WhattId
                     if (contactId != null) {
                        ((Map < String, Object > ) responseType).put('whattId', contactId);
                    }

                } 
                newjsonBody = JSON.serialize(responseType);
                SYS_debug.log('newjsonBody ' + newjsonBody);
                requestBody = newjsonBody;
                responseType = JSON.deserializeUntyped(requestBody);
            }
        }

        //Outbound and Inbound Call
        if( (rootkey!='') && (containsCallKey == true) ){ // Outbound and Inbound Call
            String eventName = (String)newflatKeyMap.get('event');
            String plivoevent = (String)newflatKeyMap.get('plivoevent');
            ///eventType = webHookEvents.get(eventName);

            String OutgoingCallToNumber = (String)newflatKeyMap.get('dialblegto'); // Outgoing Call Customer Number
            OutgoingCallToNumber = String.isNotBlank(OutgoingCallToNumber) ? OutgoingCallToNumber.replaceAll('[-+.^:,]','') : NULL;
            String OutgoingCallFromNumber = (String)newflatKeyMap.get('dialblegfrom'); // Outgoing Call Plivo Number
            OutgoingCallFromNumber = String.isNotBlank(OutgoingCallFromNumber) ? OutgoingCallFromNumber.replaceAll('[-+.^:,]','') : NULL;
            String OutgoingCallPlivoNumber = (String)newflatKeyMap.get('callername'); // Outgoing Call Plivo Number
            String CallToNumber = (String)newflatKeyMap.get('customerphone'); // Outgoing Call Customer Number
            
            String IncomingCallFromNumber = (String)newflatKeyMap.get('from'); // Incoming Call Customer Number
            String IncomingCalltoNumber = (String)newflatKeyMap.get('plivonumber'); // Incoming Call Plivo Number
            
            String dialbleghangupcausename = (String)newflatKeyMap.get('dialbleghangupcausename');
            
            if(containsRecordingResponseKey == true){ // Call Recording JSON Modify
                String responsekeyValue =(String)newflatKeyMap.get('response');
                String newrecJson = responsekeyValue.replace('\\' , '');
                Object newresponseType = JSON.deserializeUntyped(newrecJson);
                if(newresponseType instanceof Map<String,Object>){
                    ((Map<String, Object>)newresponseType).put('plivoevent', (String)newflatKeyMap.get('plivoevent'));
                    ((Map<String, Object>)newresponseType).put('token', (String)newflatKeyMap.get('token'));
                    ((Map<String, Object>)newresponseType).put('event_time', (String)newflatKeyMap.get('event_time'));
                    responseType = newresponseType;
                }
                SYS_debug.log('responseType ' + responseType);            
            }

            if(plivoevent == 'outgoingcall'){ // OUTBOUND Call outgoingcall
                eventType = 'outgoingcall';
                ((Map<String, Object>)responseType).put('direction', 'outbound');

                if( (eventName == 'Ring') || (eventName == 'Hangup') ){
                    if( String.isNotBlank(CallToNumber) && String.isNotBlank(OutgoingCallPlivoNumber) ){
                        //Fetch Contact for Account Lookup 
                        findCustomerQuery = 'SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId FROM Contact WHERE Formatted_Phone_Number__c =:CallToNumber' + accountFilterCriteria + ' ORDER BY LastModifiedDate LIMIT 1';
                        findCustomer = Database.query(findCustomerQuery);

                        SYS_debug.log('findCustomer ' + findCustomer);
                        SYS_debug.log('(findCustomer.size() > 0)  ' + (findCustomer.size()));
                        contactId = (findCustomer.size() > 0) ? findCustomer[0].Id : null;
                        accountId = (findCustomer.size() > 0) ? findCustomer[0].AccountId : null;
                        ((Map < String, Object > ) responseType).put('contactId', contactId);
                        ((Map < String, Object > ) responseType).put('accountId', accountId);
                        ((Map < String, Object > ) responseType).put('dialblegto', CallToNumber);

                        ((Map < String, Object > ) responseType).put('contactnumber', CallToNumber);
                        ((Map < String, Object > ) responseType).put('externalnumber', OutgoingCallPlivoNumber);
                    }
                }else{
                    if( String.isNotBlank(OutgoingCallToNumber) && String.isNotBlank(OutgoingCallFromNumber) ){
                        //Fetch Contact for Account Lookup 
                        findCustomerQuery = 'SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId FROM Contact WHERE Formatted_Phone_Number__c =:OutgoingCallToNumber' + accountFilterCriteria + ' ORDER BY LastModifiedDate LIMIT 1';
                        findCustomer = Database.query(findCustomerQuery);
                        
                        SYS_debug.log('findCustomer ' + findCustomer);
                        SYS_debug.log('(findCustomer.size() > 0)  ' + (findCustomer.size()));
                        contactId = (findCustomer.size() > 0) ? findCustomer[0].Id : null;
                        accountId = (findCustomer.size() > 0) ? findCustomer[0].AccountId : null;
                        ((Map < String, Object > ) responseType).put('contactId', contactId);
                        ((Map < String, Object > ) responseType).put('accountId', accountId);

                        ((Map < String, Object > ) responseType).put('contactnumber', OutgoingCallToNumber);
                        ((Map < String, Object > ) responseType).put('externalnumber', OutgoingCallFromNumber);
                    }
                }
                
                if( (hasCallStatusKey == true) ){
                    String callStatusvalue = (String)newflatKeyMap.get('callstatus');
                    if(callStatusvalue == 'in-progress'){
                        newCallStatus = 'connected';
                    }else if( callStatusvalue == 'ringing' ){
                        newCallStatus = 'ringing';
                    }else if( callStatusvalue == 'no-answer' ){
                        newCallStatus = 'no-answer';
                    }else if( callStatusvalue == 'completed' ){
                        newCallStatus = 'hangup';
                    }else{
                        newCallStatus = 'ringing';
                    }
                    if( String.isNotBlank(newCallStatus) ){
                        ((Map < String, Object > ) responseType).put('dialblegstatus', newCallStatus);
                    }
                }
            }

            if(plivoevent == 'incomingcall'){ // INBOUND Call incomingcall
                eventType = 'callincoming';
                ((Map<String, Object>)responseType).put('direction', 'inbound');

                if( String.isNotBlank(IncomingCalltoNumber) && String.isNotBlank(IncomingCallFromNumber) ){
                    //Fetch Contact for Account Lookup 
                    findCustomerQuery = 'SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId FROM Contact WHERE Formatted_Phone_Number__c =:IncomingCallFromNumber' + accountFilterCriteria + ' ORDER BY LastModifiedDate LIMIT 1';
                    findCustomer = Database.query(findCustomerQuery);
                    
                    SYS_debug.log('findCustomer ' + findCustomer);
                    SYS_debug.log('(findCustomer.size() > 0)  ' + (findCustomer.size()));
                    contactId = (findCustomer.size() > 0) ? findCustomer[0].Id : null;
                    accountId = (findCustomer.size() > 0) ? findCustomer[0].AccountId : null;
                    ((Map < String, Object > ) responseType).put('contactId', contactId);
                    ((Map < String, Object > ) responseType).put('accountId', accountId);

                    ((Map < String, Object > ) responseType).put('contactnumber', IncomingCallFromNumber);
                    ((Map < String, Object > ) responseType).put('externalnumber', IncomingCalltoNumber);
                }
                
                if( (hasCallStatusKey == true) ){
                    String callStatusvalue = (String)newflatKeyMap.get('callstatus');
                    if(callStatusvalue == 'in-progress'){
                        newCallStatus = 'connected';
                    }else if( callStatusvalue == 'ringing' ){
                        newCallStatus = 'ringing';
                    }else if( callStatusvalue == 'no-answer' ){
                        newCallStatus = 'no-answer';
                    }else if( callStatusvalue == 'completed' ){
                        newCallStatus = 'hangup';
                    }else{
                        newCallStatus = 'ringing';
                    }
                    if( String.isNotBlank(newCallStatus) ){
                        ((Map < String, Object > ) responseType).put('dialblegstatus', newCallStatus);
                    }
                }
                
                if(String.isNotBlank(dialbleghangupcausename) && dialbleghangupcausename == 'No Answer'){
                    newCallStatus = 'no-answer';
                    ((Map < String, Object > ) responseType).put('dialblegstatus', newCallStatus);
                }
                
            }
            
            ((Map<String, Object>)responseType).put('type', eventType);
            ((Map<String, Object>)responseType).put('activitytype', 'Call');
            newjsonBody = JSON.serialize(responseType);
            SYS_debug.log('eventType '+ eventType);
            SYS_debug.log('newjsonBody '+ newjsonBody);
            requestBody = newjsonBody;
        }

        //Check criteria when chars more than 1M
        if(requestBody != NULL && requestBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
            logAfterPartition = SYS_Helper.getLogsAfterPartition(requestBody);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                // SYS_Helper.upsertLog(logs[0]);
                // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                
                // SYS_Helper.upsertLog(childs);
                log = logAfterPartition[0];
            }
            SYS_debug.log('SP 1M<<');
        } else {
            log = SYS_Helper.getLogsToInsert(requestBody);
            SYS_debug.log('SP 1M>>');
        }

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
            log.Is_Notification_Only__c = true;

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = method;
        log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
        log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
        log.Status__c = 'NEW';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;

        //new fields
        log.Account_Id__c = SYS_DataCacheFactory.accountId;
        log.Integration_Type__c = SYS_DataCacheFactory.integrationSetting?.Integration_Type__c;

        List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
        returnVal.add(log);
        if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
            log.Status__c = 'PENDING_PARTITIONED_LOOKUP';
            for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                returnVal.add(logAfterPartition[i]);
            }
        }

        return returnVal;
    }

    /**
     * This hook is called from insertWebhookLog methods and webservice.
     * Default is to set the response body with incoming request
     * Zero Arguments. Relies on Integration Setting in DataCache and RestContext
     * Override if custom handler is required after successful log creation
     */
    public override void setSuccessHttpResponse(){
        if(RestContext.response != NULL){
            String requestJson = RestContext.request.requestBody.toString();
            Map<String, String> requestParams = RestContext.request.params;
            if(requestJson =='' && !requestParams.isEmpty()){
                requestJson = convertRequestParamsJSON(requestParams);
            }

            //Variables for Incoming call
            String rootkey, customerNumber, plivoNumber, contactOwnerPhone, contactOwnerName;
            Boolean containsCallKey = false;
            Map<String, Object> newflatKeyMap = new Map<String, Object>();
            Object responseType = JSON.deserializeUntyped(requestJson);
            if(responseType instanceof Map<String,Object>){
                rootkey = new List<String>(((Map<String, Object>)responseType).keySet())[0];
                newflatKeyMap = (SYS_Helper.getFlatKeys(requestJson ,'A.B'));  
                containsCallKey = newflatKeyMap.containsKey('incomingcall');
            }
            //If Request is incoming call send contact point phone as response
            if(containsCallKey){
                customerNumber = (String)newflatKeyMap.get('from');
                plivoNumber = (String)newflatKeyMap.get('plivonumber');
                Id accountId = SYS_DataCacheFactory.accountId;
                String accountFilterCriteria = (accountId != null) ? ' AND AccountId =:accountId' : '';
                //Fetch Contact for Account Lookup 
                String findCustomerQuery = 'SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId, Owner.Phone, Owner.Name, Point_of_Contact__c, Point_of_Contact__r.Phone, Point_of_Contact__r.Formatted_Phone__c, Point_of_Contact__r.Name FROM Contact WHERE Formatted_Phone_Number__c =:customerNumber' + accountFilterCriteria + ' ORDER BY LastModifiedDate LIMIT 1';
                List<Contact> findCustomer  = new List<Contact>();
                findCustomer = Database.query(findCustomerQuery);
                contactOwnerPhone = ( findCustomer.size() > 0 ) ? findCustomer[0].Point_of_Contact__r.Formatted_Phone__c : '' ;
                contactOwnerName = ( findCustomer.size() > 0 ) ? findCustomer[0].Point_of_Contact__r.Name : '' ;
                Map<String, String> newrequestParams = new Map<String, String>(); 
                newrequestParams.put('Name', contactOwnerName);
                newrequestParams.put('Phone', contactOwnerPhone);
                requestJson = JSON.serialize(newrequestParams);
                RestContext.response.addHeader('Content-Type', 'application/json');
            }

            RestContext.response.responseBody = Blob.valueOf(requestJson);
        }        
    }

}