@isTest
public class Communication_TestDataFactory {

    // Account Contact Product google calender 2  
    public static void createTestAccountWithContactsRecords(Integer numAccts, Integer numContactsPerAcct){
        List<Account> accountsList = new List<Account>();
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account tempAcc = new Account();
            tempAcc.Name = 'Test Account' + i;
            accountsList.add(tempAcc);
        }
        insert accountsList;
        
        List<Contact> contactsList = new List<Contact>();

        for (Integer j=0;j<numAccts;j++) {
            Account acct = accountsList[j];  
            // For each account just inserted, add contacts
            for (Integer k=numContactsPerAcct*j;k<numContactsPerAcct*(j+1);k++) {
                accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = acct.Id,
                                    Integration_Type__c = 'Plivo', 
                                    Key__c = 'int-set',
                                    Value__c = 'Plivo'));
                accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = acct.Id,
                                    Integration_Type__c = 'Stripe', 
                                    Key__c = 'int-set',
                                    Value__c = 'Stripe'));     
                accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = acct.Id,
                                    Integration_Type__c = 'Calendar', 
                                    Key__c = 'int-set',
                                    Value__c = 'Calendar'));  

                //Ramdom Number Generator
                
                String randomPhoneNumber = generateVerificationCode(10);
                
                Contact tempCont = new Contact();
                tempCont.FirstName='Test'+k;
                tempCont.LastName='Contact'+k;
                tempCont.Email= 'testemail' + k +'@adisols.com';
                tempCont.AccountId=acct.Id;

                tempCont.Member_Type__c = 'Subscriber';
                tempCont.Membership_Type__c = 'Individual';
                tempCont.Phone_Number__c = randomPhoneNumber;
                tempCont.StripeCustomerId__c = 'test_customer'+k;
                tempCont.Active__c = true;
                tempCont.Payment_SMS_Sent__c = true;
                tempCont.Payment_Date_Time__c = System.now();
                tempCont.Registration_Order_Created__c = true;
                tempCont.RecordTypeId = MemberRecordTypeId;
                contactsList.add(tempCont);
            }
        }
        // Insert all Integration Metadata for all accounts
        insert accIntMetadata;
        // Insert all contacts for all accounts
        insert contactsList;
    }
    public static String generateVerificationCode(Integer length) {
        String verificationcode = '';
        String firstindexdigits = '123456789';
        String digits = '123456789';
        Integer verificationCodeLength = length;
        for(Integer i=1; i <= verificationCodeLength; i++){
            Integer digitsLength = 0;
            if(i == 0){
                digitsLength = firstindexdigits.length();
            } else {
                digitsLength = digits.length();
            }
            Integer index = Integer.valueOf(Math.floor(Math.random()*(digitsLength)));
            String indexValue = String.valueOf(index);
            verificationcode = verificationcode + indexValue;     
        }
        System.debug('verificationcode ' + verificationcode);
        return verificationcode;
    }

    public static Account getAccountDetails(){
        String AccountListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Account') +
                ' FROM Account LIMIT 1';
        List<Account> AccountList = Database.query(AccountListQuery);
        return (AccountList.size() > 0) ? AccountList[0] : new Account();
    }

    public static List<Contact> getContactDetails(){
        String ContactListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
                ' FROM Contact';
        List<Contact> ContactList = Database.query(ContactListQuery);
        return ContactList;
    }

    public static List<Activity__c> createActivitiesforEachContact(ContactActivitywrapper ContactActivities) {
        List<String> mediaUrls = new List<String>();
        String type = ContactActivities.ActivityType;
        List<Activity__c> ActivityListToCreate = new List<Activity__c>();
        for(Contact iterRec : ContactActivities.Contactlist){
            Id iterRecordId = iterRec.Id;
            String iterToPhone = iterRec.Formatted_Phone_Number__c;            
            
            Id contactId, accountId, leadId = null;
            String objectApiName = '';
            String mediaurlString = '';
            List<Media_URL__c> mediaUrlList = new List<Media_URL__c>();
            
            if(iterRecordId != null){    
                objectApiName = iterRecordId.getSObjectType().getDescribe().getName();
                if(objectApiName == 'Contact'){
                    contactId = iterRecordId;
                }
                if(objectApiName == 'Account'){
                    accountId = iterRecordId;
                }
                if(objectApiName == 'Lead'){
                    leadId = iterRecordId;
                }
            }else {
                iterRecordId = null;
            }
            
            if(mediaUrls.size() > 0){
                mediaurlString = String.join(mediaurls,',');
            }
            
            Activity__c activityRecord = new Activity__c();
            activityRecord.Type__c = type;
            activityRecord.Direction__c ='OUTBOUND';
            activityRecord.Status__c = 'Queued'; //Sending
            activityRecord.Contact__c = contactId;
            activityRecord.Account__c = accountId;
            activityRecord.Lead__c = leadId;
            activityRecord.WhatId__c = iterRecordId;
            activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
            activityRecord.Subject__c = ContactActivities.messageSubject;
            activityRecord.Message__c = ContactActivities.messagebody;
            activityRecord.media_url__c = mediaurlString;
            activityRecord.Phone__c = iterToPhone;
            activityRecord.External_Number__c = ContactActivities.externalPhone;
            // activityRecord.Email__c = email;
            activityRecord.IsInboxMessage__c = true;
            activityRecord.Log__c = true;
            activityRecord.Trackable__c = true;
            activityRecord.IsUnread__c = ContactActivities.IsUnread;
            activityRecord.When__c = System.now();
            ActivityListToCreate.add(activityRecord); 
        }      
        if(ContactActivities.doInsert) {
            insert ActivityListToCreate;
        }
        return ActivityListToCreate;
    }
    
    public static List<Activity__c> createActivitiesforEachLead(LeadActivitywrapper leadActivities) {
        List<String> mediaUrls = new List<String>();
        String type = String.isNotBlank(leadActivities.ActivityType) ? leadActivities.ActivityType : 'sms';
        String direction = String.isNotBlank(leadActivities.ActivityDirection) ? leadActivities.ActivityDirection : 'OUTBOUND';
        String status = String.isNotBlank(leadActivities.ActivityStatus) ? leadActivities.ActivityStatus : 'Queued';
        Boolean bypassFlow = (leadActivities.bypassFlow) ? true : false;
        Map<Id,Integer> tempRecordIdActivityCountMap = leadActivities.recordIdActivityCountMap;
        List<Activity__c> ActivityListToCreate = new List<Activity__c>();
        for(Lead iterRec : leadActivities.leadsList){
            Id iterRecordId = iterRec.Id;
            Integer noOfActivitiestoCreate = tempRecordIdActivityCountMap.containsKey(iterRecordId) ? tempRecordIdActivityCountMap.get(iterRecordId) : 0;
            String iterToPhone = iterRec.Formatted_Phone_Number__c;            
            
            Id contactId, accountId, leadId = null;
            String objectApiName = '';
            String mediaurlString = '';
            List<Media_URL__c> mediaUrlList = new List<Media_URL__c>();
            
            if(iterRecordId != null){    
                objectApiName = iterRecordId.getSObjectType().getDescribe().getName();
                if(objectApiName == 'Contact'){
                    contactId = iterRecordId;
                }
                if(objectApiName == 'Account'){
                    accountId = iterRecordId;
                }
                if(objectApiName == 'Lead'){
                    leadId = iterRecordId;
                }
            }else {
                iterRecordId = null;
            }
            
            if(mediaUrls.size() > 0){
                mediaurlString = String.join(mediaurls,',');
            }
            for(Integer i = 0; i < noOfActivitiestoCreate; i++ ){
                Activity__c activityRecord = new Activity__c();
                activityRecord.Type__c = type;
                activityRecord.Direction__c = direction;
                activityRecord.Status__c = status; //Sending
                activityRecord.Contact__c = contactId;
                activityRecord.Account__c = accountId;
                activityRecord.Lead__c = leadId;
                activityRecord.WhatId__c = iterRecordId;
                activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
                activityRecord.Subject__c = leadActivities.messageSubject;
                activityRecord.Message__c = leadActivities.messagebody;
                activityRecord.media_url__c = mediaurlString;
                activityRecord.Phone__c = iterToPhone;
                activityRecord.External_Number__c = leadActivities.externalPhone;
                // activityRecord.Email__c = email;
                if(bypassFlow){
                	activityRecord.IsInboxMessage__c = true;// Ignore Outbound callout flow
                }
                activityRecord.Log__c = true;
                activityRecord.Trackable__c = true;
                activityRecord.IsUnread__c = leadActivities.IsUnread;
                activityRecord.When__c = System.now();
                ActivityListToCreate.add(activityRecord); 
            }
        }      
        if(leadActivities.doInsert) {
            insert ActivityListToCreate;
        }
        return ActivityListToCreate;
    }
   
    public static List<Activity__c> createActivitiesforEachAccount(AccountActivitywrapper AccountActivities) {
        List<String> mediaUrls = new List<String>();
        String type = AccountActivities.ActivityType;
        List<Activity__c> ActivityListToCreate = new List<Activity__c>();
        for(Account iterRec : AccountActivities.Accountlist){
            Id iterRecordId = iterRec.Id;
            String iterToPhone = iterRec.Formatted_Phone_Number__c;            
            
            Id contactId, accountId, leadId = null;
            String objectApiName = '';
            String mediaurlString = '';
            List<Media_URL__c> mediaUrlList = new List<Media_URL__c>();
            
            if(iterRecordId != null){    
                objectApiName = iterRecordId.getSObjectType().getDescribe().getName();
                if(objectApiName == 'Contact'){
                    contactId = iterRecordId;
                }
                if(objectApiName == 'Account'){
                    accountId = iterRecordId;
                }
                if(objectApiName == 'Lead'){
                    leadId = iterRecordId;
                }
            }else {
                iterRecordId = null;
            }
            
            if(mediaUrls.size() > 0){
                mediaurlString = String.join(mediaurls,',');
            }
            
            Activity__c activityRecord = new Activity__c();
            activityRecord.Type__c = type;
            activityRecord.Direction__c ='OUTBOUND';
            activityRecord.Status__c = 'Queued'; //Sending
            activityRecord.Contact__c = contactId;
            activityRecord.Account__c = accountId;
            activityRecord.Lead__c = leadId;
            activityRecord.WhatId__c = iterRecordId;
            activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
            activityRecord.Subject__c = AccountActivities.messageSubject;
            activityRecord.Message__c = AccountActivities.messagebody;
            activityRecord.media_url__c = mediaurlString;
            activityRecord.Phone__c = iterToPhone;
            activityRecord.External_Number__c = AccountActivities.externalPhone;
            // activityRecord.Email__c = email;
            activityRecord.IsInboxMessage__c = true;
            activityRecord.Log__c = true;
            activityRecord.Trackable__c = true;
            activityRecord.IsUnread__c = AccountActivities.IsUnread;
            activityRecord.When__c = System.now();
            ActivityListToCreate.add(activityRecord); 
        }      
        if(AccountActivities.doInsert) {
            insert ActivityListToCreate;
        }
        return ActivityListToCreate;
    }
    
    Public static Activity__c ActivitycreationDF(Boolean Accountcheck, Boolean Contactcheck, Boolean leadcheck) {
        Account accountrec;Contact contactrec;Lead leadrec;string recordId = '';string objectApiName = '';
        if (Accountcheck) {
            accountrec = new Account(Name = 'Sample Account',phone= '9100000056');
            insert accountrec;
            
            objectApiName = 'Account';
        }
        if (Contactcheck) {
            contactrec = new Contact(FirstName = 'Sample', LastName = 'Contact',Phone= '9100831465');
            insert contactrec;
            objectApiName = 'Contact';
        }
        if (leadcheck) {
            leadrec = new lead();
            leadrec.FirstName = 'Test';
            leadrec.LastName = 'Lead';
            leadrec.Company = 'Test Company';
            leadrec.Status = 'Open-Contracted';
            leadrec.Phone = '234-567-8492';
            Insert leadrec;
            objectApiName = 'Lead';
        }
        Activity__c activityRecord = new Activity__c();
        if (leadcheck) {
            activityRecord.Type__c = 'mms';
            activityRecord.Phone__c = leadrec.Formatted_Phone_Number__c;
        }
        if (Accountcheck) {
            activityRecord.Type__c = 'sms';
            activityRecord.Phone__c = accountrec.Formatted_Phone_Number__c ;
            
        }
        if (Contactcheck) {
            activityRecord.Type__c = 'call';
            activityRecord.Phone__c = contactrec.Formatted_Phone_Number__c;
            activityRecord.IsUnread__c = true;
        }
        activityRecord.Direction__c = 'OUTBOUND';
        activityRecord.Status__c = 'Queued'; //Sending
        if (Contactcheck) {
            activityRecord.Contact__c = contactrec.Id;
        }
        if (Accountcheck) {
            activityRecord.Account__c = accountrec.Id;
        }
        if (leadcheck) {
            activityRecord.Lead__c = leadrec.Id;
        }
        activityRecord.WhatId__c = recordId;
        activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
        activityRecord.Subject__c = 'Outbound SMS';
        activityRecord.Message__c = 'Hi team';
        if (leadcheck) {
            activityRecord.media_url__c = 'https://ibb.co/mbTg9CH';
        }
        
        activityRecord.External_Number__c = '15598885159';
        // activityRecord.Email__c = email;
        activityRecord.IsInboxMessage__c = true;
        activityRecord.Log__c = true;
        activityRecord.Trackable__c = true;
        // activityRecord.IsUnread__c = false;
        activityRecord.When__c = System.now();
        insert activityRecord;
        return activityRecord;
    }
    
    Public static list < Activity__c > listActivitycreationDF(Boolean Accountcheck, Boolean Contactcheck, Boolean leadcheck) {
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();
        Account accountrec;
        Contact contactrec;
        Lead leadrec;
        string recordId = '';
        string objectApiName = '';
        list<Activity__c> Activitylist = new list<Activity__c>();
        if (Accountcheck) {
            accountrec = new Account(Name = 'Sample Account',Phone = '234-567-8490');
            insert accountrec;
            
            objectApiName = 'Account';
        }
        if (Contactcheck) {
            Account pmaAcc = new Account(Name='PMA Test Account');
            insert pmaAcc;
            accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = pmaAcc.Id,
                                Integration_Type__c = 'Plivo', 
                                Key__c = 'int-set',
                                Value__c = 'Plivo'));
            accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = pmaAcc.Id,
                                Integration_Type__c = 'Stripe', 
                                Key__c = 'int-set',
                                Value__c = 'Stripe'));     
            accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = pmaAcc.Id,
                                Integration_Type__c = 'Calendar', 
                                Key__c = 'int-set',
                                Value__c = 'Calendar'));                                                
            contactrec = new Contact(FirstName='PMA',
                                    LastName='Test Contact',
                                    Member_Type__c = 'Subscriber',
                                    Membership_Type__c = 'Individual',
                                    Phone_Number__c = '234-567-8491',
                                    StripeCustomerId__c = 'test_customer',
                                    Active__c = true,
                                    Payment_SMS_Sent__c = true,
                                    Payment_Date_Time__c = System.now(),
                                    Registration_Order_Created__c = true,
                                    RecordTypeId = MemberRecordTypeId,
                                    AccountId=pmaAcc.Id);
            // Insert all Integration Metadata for all accounts
            insert accIntMetadata;
            insert contactrec;
            objectApiName = 'Contact';
        }
        if (leadcheck) {
            leadrec = new lead();
            leadrec.FirstName = 'Test';
            leadrec.LastName = 'Lead';
            leadrec.Company = 'Test Company';
            leadrec.Status = 'Open-Contracted';
            leadrec.Phone = '234-567-8492';
            Insert leadrec;
            objectApiName = 'Lead';
        }
        for (integer i = 1; i < 5; i++) {
            Activity__c activityRecord = new Activity__c();
            if (leadcheck) {
                activityRecord.Type__c = 'sms';
                activityRecord.Phone__c = leadrec.Formatted_Phone_Number__c;
            }
            if (Accountcheck) {
                activityRecord.Type__c = 'sms';
                activityRecord.Phone__c = accountrec.Formatted_Phone_Number__c;
                
            }
            if (Contactcheck) {
                activityRecord.Type__c = 'call';
                activityRecord.Phone__c = contactrec.Formatted_Phone_Number__c;
                activityRecord.IsUnread__c = true;
                
            }
            activityRecord.Direction__c = 'OUTBOUND';
            activityRecord.Status__c = 'Queued'; //Sending
            if (Contactcheck) {
                activityRecord.Contact__c = contactrec.Id;
            }
            if (Accountcheck) {
                activityRecord.Account__c = accountrec.Id;
            }
            if (leadcheck) {
                activityRecord.Lead__c = leadrec.Id;
            }
            activityRecord.WhatId__c = recordId;
            activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
            activityRecord.Subject__c = 'Outbound SMS';
            activityRecord.Message__c = 'Hi team';
            if (leadcheck) {
                activityRecord.media_url__c = 'https://ibb.co/mbTg9CH';
            }
            
            activityRecord.External_Number__c = '15598885159';
            // activityRecord.Email__c = email;
            activityRecord.IsInboxMessage__c = true;
            activityRecord.Log__c = true;
            activityRecord.Trackable__c = true;
            //activityRecord.IsUnread__c = false;
            activityRecord.When__c = System.now(); 
            //  activityRecord.UUID__c = '15598885159' + i;
            Activitylist.add(activityRecord);
        }
        return Activitylist;
    }
    
    Public static  Inbox__c  CreationofInbox() {
        Account accountrec = new Account(Name = 'Sample Account');
        insert accountrec;
        Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
        
        activityRecord.Account__c = accountrec.Id;
        Inbox__c inboxRecord = new Inbox__c();
        inboxRecord.Contact__c = activityRecord.Contact__c;
        inboxRecord.Account__c = activityRecord.Account__c;
        inboxRecord.Lead__c = activityRecord.Lead__c;
        inboxRecord.WhatId__c = activityRecord.WhatId__c;
        inboxRecord.WhatId_ObjectApi_Name__c = activityRecord.WhatId_ObjectApi_Name__c;
        inboxRecord.Latest_Message__c = 'hi Team';
        inboxRecord.Latest_Message_Received_At__c = activityRecord.When__c;
        inboxRecord.Latest_Activity_Number__c = 125;
        
        inboxRecord.Email__c = activityRecord.Email__c;
        //inboxRecord.Member_Name__c = activityRecord.Contact__r.Name;
        inboxRecord.Phone__c = activityRecord.Contact__r.Phone;
        inboxRecord.External_Phone__c = activityRecord.External_Number__c;
        inboxRecord.External_Contact_Point__c = '15108672811';
        insert inboxRecord;
        return inboxRecord;
        
    }
    
    Public static  list<Inbox__c>  CreationofInboxList(Integer NumberofRec,Boolean insertcheck) {
        list<Inbox__c> inboxlist = new list <Inbox__c>();
        
        Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
        for (integer i = 1; i < NumberofRec; i++) {
            // activityRecord.Account__c = accountrec.Id;
            Inbox__c inboxRecord = new Inbox__c();
            inboxRecord.Contact__c = activityRecord.Contact__c;
            inboxRecord.Account__c = activityRecord.Account__c;
            inboxRecord.Lead__c = activityRecord.Lead__c;
            //inboxRecord.WhatId__c = activityRecord.WhatId__c;
            // inboxRecord.WhatId_ObjectApi_Name__c = activityRecord.WhatId_ObjectApi_Name__c;
            inboxRecord.Latest_Message__c = 'hi Team';
            inboxRecord.Latest_Message_Received_At__c = activityRecord.When__c;
            inboxRecord.Latest_Activity_Number__c = 125;
            
            inboxRecord.Email__c = activityRecord.Email__c;
            //inboxRecord.Member_Name__c = activityRecord.Contact__r.Name;
            inboxRecord.Phone__c = activityRecord.Contact__r.Phone;
            inboxRecord.External_Phone__c = activityRecord.External_Number__c;
            inboxRecord.External_Contact_Point__c = '15108672811'+i;
            inboxlist.add(inboxRecord);
        }
        if(insertcheck){
            insert inboxlist;
        }
        return inboxlist;
        
    }
    Public static  list<Contact>  ContactListcreationDF(integer NumberofRec,Boolean insertcheck) {
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<NumberofRec; i++){
            
            Account acc = new Account();
            acc.Name= 'AccName'+ i;
            accList.add(acc);
        }
        
        if(accList.size() > 0)
            insert accList;
        
        // Create Contacts
        List<Contact> conList = new List<Contact>();
        
        for (Integer i=0; i<accList.size(); i++){
            
            Contact con = new Contact();
            con.FirstName = 'contact';
            con.LastName = 'sfdc'+i;
            con.Accountid = accList[0].id;
            con.Phone = '14153905925'+i;
            conList.add(con);
        }   
        if(conList.size() > 0 && insertcheck == true)
            insert conList;
        return conList;
    }
    //creation of list of Accounts With nno converstions
    Public static  list<Account>  AccountListcreationDF(integer NumberofRec,Boolean insertcheck) {
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<NumberofRec; i++){
            
            Account acc = new Account();
            acc.Name= 'AccName'+ i;
            acc.Phone = '14153905925'+i;
            accList.add(acc);
        }
        
        if(accList.size() > 0 && insertcheck == true)
            insert accList;
        return accList;
    }
    //creation of  Account With no converstions
    Public static  Account  AccountListcreationDF(Boolean insertcheck) {
        
        Account acc = new Account();
        acc.Name= 'InboxAccount';
        acc.Phone = '14153905925';
        
        if( insertcheck == true)
            insert acc;
        return acc;
    }
    //creation of  list of leads With no converstions
    public static List<Lead> createLeadListDF(Integer numLeads, Boolean doInsert) {
        List<Lead> leads = new List<Lead>();
        for(Integer i = 1; i <= numLeads; i++) {
            Lead iterLead = new Lead();
            iterLead.LastName = 'TestLead ' + i;
            iterLead.Phone = '234-567-849' + i;
            iterLead.Status = 'Open - Not Contacted';
            iterLead.Company = 'TestCompany' + i;
            leads.add(iterLead);
        }
        
        if(doInsert) {
            insert leads;
        }
        return leads;
    } 
    //creation of  lead With no converstions
    public static Lead createLeadDF(Boolean doInsert) {
        
        Lead iterLead = new Lead();
        iterLead.LastName = 'InboxLead ' ;
        iterLead.Phone = '234-567-849' ;
        iterLead.Status = 'Open - Not Contacted';
        iterLead.Company = 'TestCompany' ;
        
        if(doInsert) {
            insert iterLead;
        }
        return iterLead;
    } 
    //single contact creation
    public static Contact createContactDF( Boolean Insertcheck) {
        Contact contactrec = new Contact(FirstName = 'Sample', LastName = 'Contact',Phone= '234-567-8491');
        if(Insertcheck)
            insert contactrec;
        return contactrec;
    }
    //list of media url records creation
    public static list<Media_URL__c> createmediaurllistDF( integer NumberofRec,Boolean Insertcheck) {
        Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
        list<Media_URL__c> mediautllist = new list <Media_URL__c>();
        for(Integer i=0; i<NumberofRec; i++){
            Media_URL__c itermediaurl = new Media_URL__c();
            itermediaurl.Activity__c = activityRecord.Id;
            itermediaurl.Media_Url__c = 'https://media.plivo.com/Account/MAZJM3ZDZLNWRKZWJJYW/Media/42abea94-4017-4b2b-b142-f57b2ffc6ec2';
            mediautllist.add(itermediaurl);
        }
        if(Insertcheck)
            insert mediautllist;
        return mediautllist;
    }
    //for the overriden methods we are creating a test data for sys_integration log creation
    //list of media url records creation
    /* public static SYS_IntegrationLog__c createsysintegrationlogDF(Boolean Insertcheck) {
SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();
logResp.data0__c = '{"whattId":"00QDn0000056CFGMA2","leadId":"00QDn0000056CFGMA2","accountId":null,"contactId":null,"powerpackuuid":"","messagedirection":"inboundsms","token":"VbLz0ev7Nx29eEAhHr4PpB0W0HM","units":"1","messageuuid":"78bd0f66-cfcf-11ed-8209-0242ac110005","totalrate":"0","to":"15598885159","totalamount":"0","from":"15108672811","text":"Hello Adisolsteam","messageintent":"","type":"sms","direction":"INBOUND","contactnumber":"15108672811","externalnumber":"15598885159","receivedAt":"2023-03-31T14:22:31.626Z"}';
logResp.Status__c = 'NEW';
logResp.SYS_Operation_Type__c = 'UPDATE';
logResp.Type__c = 'RESPONSE';
logResp.How_to_process__c = 'Use Custom Apex Handler';
logResp.Custom_Apex_Handler__c = 'Plivo_IB_SYS_ApplicationService';
logResp.Integration_Setting__c = 'Plivo';
logResp.SYS_Http_Status__c = 202;
logResp.Resource__c = 'sms';
logResp.Request_Digest__c = 'YaXmx1iltEM9jRUln8ACGlNAPro=';
logResp.
}*/
    public static SYS_IntegrationLog__c createsysintegrationlogDF(Boolean Insertcheck) {
        Activity__c activty =  ActivitycreationDF(false,True,false);
        SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
        log.Type__c = 'OUTBOUND';
        log.WhatId__c = activty.Id;
        log.data0__c = '{"type":"sms","log":"true","text":"Hi  test. My name is Adisols and I am a concierge team member with EMER Medical. You recently submitted a lead and I am here to help you book your consultation. Give me a call at xxxx-xxx-xxx or reply to this text.","dst":"15108672811","method":"POST","src":"18008803326","url":"https://modernhealthcare-dev-ed.develop.my.salesforce-sites.com/services/apexrest/municorn/v1/Plivo?token=TQo5GqOWQERRW"}';
        log.Status__c = 'NEW';
        log.SYS_Operation_Type__c = 'INSERT';
        log.How_to_process__c = 'Use Custom Apex Handler';
        log.Custom_Apex_Handler__c = 'Plivo_IB_SYS_ApplicationService';
        log.Integration_Setting__c = 'Plivo';
        log.SYS_Http_Status__c = 202;
        // log.Resource__c = 'sms';
        // log.Request_Digest__c = 'YaXmx1iltEM9jRUln8ACGlNAPro=';
        log.ObjectSettingId__c = 'PlivoSMS';
        log.Callout_URL__c = 'https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Message/';
        log.HTTP_Method__c = 'POST';
        if(Insertcheck)
            insert log ;
        return log ;
    }
    Public static Activity__c ActivitycreationWithUUIDDF(Boolean Accountcheck, Boolean Contactcheck, Boolean leadcheck) {
        Account accountrec;Contact contactrec;Lead leadrec;string recordId = '';string objectApiName = '';
        if (Accountcheck) {
            accountrec = new Account(Name = 'Sample Account',phone= '9100000056');
            insert accountrec;
            
            objectApiName = 'Account';
        }
        if (Contactcheck) {
            contactrec = new Contact(FirstName = 'Sample', LastName = 'Contact',Phone= '15108672811');
            insert contactrec;
            objectApiName = 'Contact';
        }
        if (leadcheck) {
            leadrec = new lead();
            leadrec.FirstName = 'Test';
            leadrec.LastName = 'Lead';
            leadrec.Company = 'Test Company';
            leadrec.Status = 'Open-Contracted';
            leadrec.Phone = '234-567-8492';
            Insert leadrec;
            objectApiName = 'Lead';
        }
        Activity__c activityRecord = new Activity__c();
        if (leadcheck) {
            activityRecord.Type__c = 'mms';
            activityRecord.Phone__c = leadrec.Formatted_Phone_Number__c;
        }
        if (Accountcheck) {
            activityRecord.Type__c = 'sms';
            activityRecord.Phone__c = accountrec.Formatted_Phone_Number__c ;
            
        }
        if (Contactcheck) {
            activityRecord.Type__c = 'sms';
            activityRecord.Phone__c = contactrec.Formatted_Phone_Number__c;
            activityRecord.IsUnread__c = true;
        }
        activityRecord.Direction__c = 'OUTBOUND';
        activityRecord.Status__c = 'Queued'; //Sending
        if (Contactcheck) {
            activityRecord.Contact__c = contactrec.Id;
        }
        if (Accountcheck) {
            activityRecord.Account__c = accountrec.Id;
        }
        if (leadcheck) {
            activityRecord.Lead__c = leadrec.Id;
        }
        activityRecord.UUID__c = 'VbLz0ev7Nx29eEAhHr4PpB0W0HM';
        activityRecord.WhatId__c = recordId;
        activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
        activityRecord.Subject__c = 'Outbound SMS';
        activityRecord.Message__c = 'Hi team';
        if (leadcheck) {
            activityRecord.media_url__c = 'https://ibb.co/mbTg9CH';
        }
        
        activityRecord.External_Number__c = '15598885159';
        // activityRecord.Email__c = email;
        activityRecord.IsInboxMessage__c = true;
        activityRecord.Log__c = true;
        activityRecord.Trackable__c = true;
        // activityRecord.IsUnread__c = false;
        activityRecord.When__c = System.now();
        insert activityRecord;
        return activityRecord;
    }
     public static List<Lead> createLeads(Integer numLeads, Boolean doInsert) {
		List<Lead> leads = new List<Lead>();
		for(Integer i = 1; i <= numLeads; i++) {
			Lead iterLead = new Lead();
			iterLead.LastName = 'TestLead ' + i;
            iterLead.Phone = '234-567-849' + i;
			iterLead.Status = 'Open - Not Contacted';
            iterLead.Company = 'TestCompany' + i;
			leads.add(iterLead);
		}
        
        if(doInsert) {
			insert leads;
		}
		return leads;
	}
    public class LeadActivitywrapper{  
        public  Boolean doInsert { get; set;}
        public  Boolean isunread { get; set;}
        public Map<Id,Integer> recordIdActivityCountMap { get; set;}
        public List<Lead> leadsList { get; set;}
        public String externalPhone { get; set;}
        public String messageSubject { get; set;}
        public  String messagebody { get; set;}
        public  String ActivityType { get; set;}
        public  String ActivityDirection { get; set;}
        public  String ActivityStatus { get; set;}
        public  Boolean bypassFlow { get; set;}
        public  Integer numActivities { get; set;}
    }
    public class AccountActivitywrapper{  
        public  Boolean doInsert { get; set;}
        public  Boolean isunread { get; set;}
        public  map<id,integer> sobjectactivitycount { get; set;}
        public List<Account> AccountList { get; set;}
        public String externalPhone { get; set;}
        public String messageSubject { get; set;}
        public  String messagebody { get; set;}
        public  String ActivityType { get; set;}
        public  Integer numActivities { get; set;}
    }
    public class ContactActivitywrapper{  
        public Boolean doInsert { get; set;}
        public Boolean isunread { get; set;}
        public Map<Id,Integer> sobjectactivitycount { get; set;}
        public List<Contact> ContactList { get; set;}
        public String externalPhone { get; set;}
        public String messageSubject { get; set;}
        public String messagebody { get; set;}
        public String ActivityType { get; set;}
        public Integer numActivities { get; set;}
    }
}