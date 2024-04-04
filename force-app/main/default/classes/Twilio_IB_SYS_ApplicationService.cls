public class Twilio_IB_SYS_ApplicationService extends SYS_ApplicationService {

    public Twilio_IB_SYS_ApplicationService() {}

    public class Twilio_IB_SYS_ApplicationServiceException extends Exception {}

        /* ---------------  Inbound Webhook Processing  ----------------------*/
    //Convert Request Params Map Keys to Lowercase
    public static String convertRequestParamsJSON(Map<String,String> reqParams){
        String requestBody='';
        Map<String, String> newrequestParams = new Map<String, String>();
        if(reqParams.containsKey('To')){
            String toPhone = reqParams.get('To');
            toPhone = String.isNotBlank(toPhone) ? toPhone.replaceAll('[-+.^:,]','') : '';
            newrequestParams.put('To', toPhone);
        }
        if(reqParams.containsKey('From')){
            String fromPhone = reqParams.get('From');
            fromPhone = String.isNotBlank(fromPhone) ? fromPhone.replaceAll('[-+.^:,]','') : '';
            newrequestParams.put('From', fromPhone);
        }
        
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
        if(requestBody=='' && !requestParams.isEmpty()){
            requestBody = convertRequestParamsJSON(requestParams);
        } 
        
        Map<String, Object> newflatKeyMap = new Map<String, Object>();
        List<Contact> findCustomer  = new List<Contact>();
        String newjsonBody;
        Id contactId, accountId, leadId, whattId;
        Inbox__c inboxRecord = new Inbox__c();
        Account accountRecord = new Account();
        Contact contactRecord = new Contact();
        Lead leadRecord = new Lead();
        InboxSearchWrapper searchWrapperObject = new InboxSearchWrapper();
        String contactnumber = '', externalnumber = '';
        
		Object responseType = JSON.deserializeUntyped(requestBody);
        if(responseType instanceof Map<String,Object>){
            newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody ,'A.B')); 
        }
        if( (newflatKeyMap.containsKey('from') == true) && (newflatKeyMap.containsKey('to') == true) ) {
            contactnumber = newflatKeyMap.containsKey( 'from' ) ? (String) newflatKeyMap.get( 'from' ) : contactnumber;
            externalnumber = newflatKeyMap.containsKey( 'to' ) ? (String) newflatKeyMap.get( 'to' ) : externalnumber;

            //Fetch Related Lookup Ids
            searchWrapperObject = getAccountBasedRelatedLookupId(contactnumber);
            accountId = searchWrapperObject.accountId;
            contactId = searchWrapperObject.contactId;
            leadId = searchWrapperObject.leadId;
            whattId = searchWrapperObject.whattId;
            inboxRecord = searchWrapperObject.inboxRecord;
            contactRecord = searchWrapperObject.contactRecord;
            accountRecord = searchWrapperObject.accountRecord;
            leadRecord = searchWrapperObject.leadRecord;
            ((Map < String, Object > ) responseType).put('contactId', contactId);
            ((Map < String, Object > ) responseType).put('accountId', accountId);
            ((Map < String, Object > ) responseType).put('leadId', leadId);
            ((Map < String, Object > ) responseType).put('whattId', whattId);

            newjsonBody = JSON.serialize(responseType);
            SYS_debug.log('newjsonBody ' + newjsonBody);
            requestBody = newjsonBody;
            responseType = JSON.deserializeUntyped(requestBody);
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

    /*
    PMA Account Based Helper to Fetch Related Contact or inbox Record 
    */
    public InboxSearchWrapper getAccountBasedRelatedLookupId( String memberNumber ) {
        InboxSearchWrapper inboxSearchWrapperObject = new InboxSearchWrapper();
        Id accountId = NULL, contactId = NULL, leadId = NULL, whattId = NULL;
        Inbox__c inboxRecord = new Inbox__c();
        Account accountRecord = new Account();
        Contact contactRecord = new Contact();
        Lead leadRecord = new Lead();

        accountId = SYS_DataCacheFactory.accountId;
        String findCustomerQuery;
        List<Contact> findCustomer = new List<Contact>();
        String accountFilterCriteria = (accountId != null) ? ' AND AccountId =:accountId' : '';
        String inboxAccountFilterCriteria = (accountId != null) ? ' AND Account__c =:accountId' : '';

        String searchTerm = '"' + memberNumber + '"';
        Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        SYS_debug.log('remainingRows ' + remainingRows);

        String inboxSearchQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Inbox__c') +
        ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
        ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
        ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
        ' FROM Inbox__c WHERE External_Contact_Point__c =: memberNumber' + inboxAccountFilterCriteria + ' ORDER BY Latest_Message_Received_At__c DESC LIMIT 1';
        List<Inbox__c> inboxRecordsList = Database.query(inboxSearchQuery);
        
        if(inboxRecordsList.size() > 0){
            accountId = inboxRecordsList[0].Account__c;
            contactId = inboxRecordsList[0].Contact__c;
            leadId = inboxRecordsList[0].Lead__c;
            whattId = inboxRecordsList[0].WhatId__c;
            inboxRecord = inboxRecordsList[0];
        } else {//Search Contacts with phone
            //Fetch Contact for Account Lookup
            findCustomerQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
            ', ' + SYS_Helper.getAllParentFields('Account.', 'Account') +
            ', ' + ' FROM Contact WHERE Formatted_Phone_Number__c =:memberNumber' + accountFilterCriteria + ' ORDER BY LastModifiedDate LIMIT 1';
            findCustomer = Database.query(findCustomerQuery);

            SYS_debug.log('findCustomer ' + findCustomer);
            if(findCustomer.size() > 0){
                contactId = findCustomer[0].Id;
                contactRecord = findCustomer[0];
                accountId = findCustomer[0].AccountId;
            }
            //Map WhattId
            if (contactId != NULL) {
                whattId = contactId;
            }
        } 
        inboxSearchWrapperObject.accountId = (accountId != NULL) ? accountId : NULL;
        inboxSearchWrapperObject.contactId = (contactId != NULL) ? contactId : NULL;
        inboxSearchWrapperObject.leadId = (leadId != NULL) ? leadId : NULL;
        inboxSearchWrapperObject.whattId = (whattId != NULL) ? whattId : NULL;
        inboxSearchWrapperObject.inboxRecord = (inboxRecord != NULL) ? inboxRecord : new Inbox__c();
        inboxSearchWrapperObject.contactRecord = ( contactRecord != NULL ) ? contactRecord : new Contact();
        inboxSearchWrapperObject.accountRecord = ( accountRecord != NULL ) ? accountRecord : new Account();
        inboxSearchWrapperObject.leadRecord = ( leadRecord != NULL ) ? leadRecord : new Lead();

        return inboxSearchWrapperObject;
    }

    /*
    Helper to Fetch Related Account or contact or Lead or inbox Record 
    */
    public InboxSearchWrapper getRelatedLookupId( String memberNumber ) {
        InboxSearchWrapper inboxSearchWrapperObject = new InboxSearchWrapper();
        Id accountId = NULL, contactId = NULL, leadId = NULL, whattId = NULL;
        Inbox__c inboxRecord = new Inbox__c();
        Account accountRecord = new Account();
        Contact contactRecord = new Contact();
        Lead leadRecord = new Lead();

        String searchTerm = '"' + memberNumber + '"';
        Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        SYS_debug.log('remainingRows ' + remainingRows);

        String inboxSearchQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Inbox__c') +
        ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
        ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
        ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
        ' FROM Inbox__c WHERE (External_Contact_Point__c =: memberNumber) ORDER BY Latest_Message_Received_At__c DESC LIMIT 1';
        List<Inbox__c> inboxRecordsList = Database.query(inboxSearchQuery);
        
        if(inboxRecordsList.size() > 0){
            accountId = inboxRecordsList[0].Account__c;
            contactId = inboxRecordsList[0].Contact__c;
            leadId = inboxRecordsList[0].Lead__c;
            whattId = inboxRecordsList[0].WhatId__c;
            inboxRecord = inboxRecordsList[0];
        } else {//SOSL on Contact Account Lead
            //IN All FIELDS 
            List<List<sObject>> MemberSearchResults = [FIND :searchTerm RETURNING Contact(FirstName,LastName, Formatted_Phone_Number__c WHERE Formatted_Phone_Number__c != NULL  ORDER BY CreatedDate DESC), Account(Name, Formatted_Phone_Number__c WHERE Formatted_Phone_Number__c != NULL ORDER BY CreatedDate DESC), Lead(FirstName,LastName, Formatted_Phone_Number__c WHERE Formatted_Phone_Number__c != NULL AND isConverted = false ORDER BY CreatedDate DESC)]; 

            SYS_debug.log('MemberSearchResults ' + MemberSearchResults);
            List<Contact> contacts = (List<Contact>)MemberSearchResults[0];
            List<Account> accounts = (List<Account>)MemberSearchResults[1];
            List<Lead> leads = (List<Lead>)MemberSearchResults[2];
            if(MemberSearchResults.size()>0){
                if(contacts.size() > 0){
                    contactId = contacts[0].Id;
                    contactRecord = contacts[0];
                }
                if(accounts.size()>0){
                    accountId = accounts[0].Id;
                    accountRecord = accounts[0];
                }
                if(leads.size()>0){
                    leadId = leads[0].Id;
                    leadRecord = leads[0];
                }
                //Map WhattId
                if (accountId != NULL) {
                    whattId = accountId;
                } else if (leadId != NULL) {
                    whattId = leadId;
                } else if (contactId != NULL) {
                    whattId = contactId;
                }
            }
        } 
        inboxSearchWrapperObject.accountId = (accountId != NULL) ? accountId : NULL;
        inboxSearchWrapperObject.contactId = (contactId != NULL) ? contactId : NULL;
        inboxSearchWrapperObject.leadId = (leadId != NULL) ? leadId : NULL;
        inboxSearchWrapperObject.whattId = (whattId != NULL) ? whattId : NULL;
        inboxSearchWrapperObject.inboxRecord = (inboxRecord != NULL) ? inboxRecord : new Inbox__c();
        inboxSearchWrapperObject.contactRecord = ( contactRecord != NULL ) ? contactRecord : new Contact();
        inboxSearchWrapperObject.accountRecord = ( accountRecord != NULL ) ? accountRecord : new Account();
        inboxSearchWrapperObject.leadRecord = ( leadRecord != NULL ) ? leadRecord : new Lead();

        return inboxSearchWrapperObject;
    }

    // Wrapper for Inbox and SOSL Search Results
    public class InboxSearchWrapper {
        public Id accountId {
            set {
                accountId = value;
            }
            get {
                if (accountId == NULL) {
                    return NULL;
                }
                return accountId;
            }
        }
        public Id contactId {
            set {
                contactId = value;
            }
            get {
                if (contactId == NULL) {
                    return NULL;
                }
                return contactId;
            }
        }
        public Id leadId {
            set {
                leadId = value;
            }
            get {
                if (leadId == NULL) {
                    return NULL;
                }
                return leadId;
            }
        }
        public Id whattId {
            set {
                whattId = value;
            }
            get {
                if (whattId == NULL) {
                    return NULL;
                }
                return whattId;
            }
        }
        public Inbox__c inboxRecord {
            set {
                inboxRecord = value;
            }
            get {
                if (inboxRecord == NULL) {
                    return new Inbox__c();
                }
                return inboxRecord;
            }
        }
        public Account accountRecord {
            set {
                accountRecord = value;
            }
            get {
                if (accountRecord == NULL) {
                    return new Account();
                }
                return accountRecord;
            }
        }
        public Contact contactRecord {
            set {
                contactRecord = value;
            }
            get {
                if (contactRecord == NULL) {
                    return new Contact();
                }
                return contactRecord;
            }
        }
        public Lead leadRecord {
            set {
                leadRecord = value;
            }
            get {
                if (leadRecord == NULL) {
                    return new Lead();
                }
                return leadRecord;
            }
        }
    }

}