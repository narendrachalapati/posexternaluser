public with sharing class InboundEmailSerives implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
        Messaging.InboundEnvelope env) {

        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        system.debug('result :' + result);
        String myPlainText = '';

        // Add the email plain text into the local variable 
        myPlainText = email.plainTextBody;

        try {

            system.debug('EmailNDR' + env);
            string Contactpointemailaddress = env.toAddress;
            InboxSearchWrapper inboxSearchWrapperObject = new InboxSearchWrapper();
            // inboxSearchWrapperObject = getAccountBasedRelatedLookupId(email.fromAddress);
            List < String > mediaurls = New list < string > ();
            inboxSearchWrapperObject = getAccountBasedRelatedLookupId(email.fromAddress, Contactpointemailaddress);
            // inboxSearchWrapperObject.contactId = (contactId != NULL) ? contactId : NULL;
            CustomActivityService.createEmailActivityLog(True, 'Email', email.fromAddress, 'INBOUND', 'sent', mediaurls, email.subject, inboxSearchWrapperObject.contactId,
                inboxSearchWrapperObject.accountId, myPlainText,email.htmlBody);
            system.debug('inboxSearchWrapperObjectNDR' + inboxSearchWrapperObject);


           // System.debug('New Task Object: ' + newTask);
        } catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }


        result.success = true;

        // Return the result for the Apex Email Service
        return result;
    }
    /*
     PMA Account Based Helper to Fetch Related Contact or inbox Record 
     */
    public static InboxSearchWrapper getAccountBasedRelatedLookupId(String memberEmail, string contactpointemail) {
        InboxSearchWrapper inboxSearchWrapperObject = new InboxSearchWrapper();
        Id accountId = NULL, contactId = NULL, leadId = NULL, whattId = NULL;
        Inbox__c inboxRecord = new Inbox__c();
        Account accountRecord = new Account();
        Contact contactRecord = new Contact();
        Lead leadRecord = new Lead();
        List < Contact_Point__c > contpoint = [SELECT Account__C from Contact_Point__c where From_Email__c =: contactpointemail];
        accountId = contpoint[0].Account__C;

        String findCustomerQuery;
        List < Contact > findCustomer = new List < Contact > ();
        String accountFilterCriteria = (accountId != null) ? ' AND AccountId =:accountId' : '';
        String inboxAccountFilterCriteria = (accountId != null) ? ' AND Account__c =:accountId' : '';

        String searchTerm = '"' + memberEmail + '"';
        Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        SYS_debug.log('remainingRows ' + remainingRows);

        String inboxSearchQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Inbox__c') +
            ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
            ' FROM Inbox__c WHERE External_Contact_Point__c =: memberEmail' + inboxAccountFilterCriteria + ' ORDER BY Latest_Message_Received_At__c DESC LIMIT 1';
        List < Inbox__c > inboxRecordsList = Database.query(inboxSearchQuery);

        if (inboxRecordsList.size() > 0) {
            accountId = inboxRecordsList[0].Account__c;
            contactId = inboxRecordsList[0].Contact__c;
            leadId = inboxRecordsList[0].Lead__c;
            whattId = inboxRecordsList[0].WhatId__c;
            inboxRecord = inboxRecordsList[0];
        } else { //Search Contacts with phone
            //Fetch Contact for Account Lookup
            findCustomerQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
                ', ' + SYS_Helper.getAllParentFields('Account.', 'Account') +
                ' FROM Contact WHERE Email =:memberEmail' + accountFilterCriteria + ' ORDER BY LastModifiedDate LIMIT 1';
            findCustomer = Database.query(findCustomerQuery);

            SYS_debug.log('findCustomer ' + findCustomer);
            if (findCustomer.size() > 0) {
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
        inboxSearchWrapperObject.contactRecord = (contactRecord != NULL) ? contactRecord : new Contact();
        inboxSearchWrapperObject.accountRecord = (accountRecord != NULL) ? accountRecord : new Account();
        inboxSearchWrapperObject.leadRecord = (leadRecord != NULL) ? leadRecord : new Lead();

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