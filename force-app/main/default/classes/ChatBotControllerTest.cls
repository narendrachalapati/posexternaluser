@isTest
public class ChatBotControllerTest {
    
   /************************************************
checking the senario with search key for the people 
who we not sent the messages before
************************************************/
    @isTest
    static void membersearchwithEmptyconversationTest() {
        List<Id> idList = new List<Id>();
        Communication_TestDataFactory.createTestAccountWithContactsRecords(1, 5);
        Account acc = Communication_TestDataFactory.getAccountDetails();
        List<Contact> contactsList = Communication_TestDataFactory.getContactDetails();

        for(Contact itercon : contactsList){
            idList.add(itercon.Id);
        }
        Test.setFixedSearchResults(idList);

        String searchkey = 'Contact';
        String phone = '';
        String currentcontactid = '';
        Double storedActivityNumber = 0;
        Test.startTest();
        List<ChatBotController.InboxMember> Inboxmemberlist = ChatBotController.contactSearch(searchkey, storedActivityNumber, phone, currentcontactid);
        Test.stopTest();
        system.assertEquals(5, Inboxmemberlist.size());
    }
    /************************************************
//checking the senario with search key for the
// people who we sent the messages before
************************************************/
    @isTest
    static void membersearchwithconversationTest() {
        List<Id> idList = new List<Id>();
        Communication_TestDataFactory.createTestAccountWithContactsRecords(1, 5);
        Account acc = Communication_TestDataFactory.getAccountDetails();
        List<Contact> contactsList = Communication_TestDataFactory.getContactDetails();

        String activityType = 'sms';
        String externalPhone = '9999999999';
        String messageSubject = 'Test SMS Activity';
        String messagebody = 'Hello User This is Test SMS';
        Integer numActivities = 3;
        Boolean doInsert = true;
        Boolean isunread = false;
        Map<Id,Integer> recordActCountMap = new Map<Id,Integer>();
        for(Contact itercon : contactsList){
            idList.add(itercon.Id);
            recordActCountMap.put(itercon.Id, numActivities);
        }
        Test.setFixedSearchResults(idList);

        Communication_TestDataFactory.ContactActivitywrapper conActWrap = new Communication_TestDataFactory.ContactActivitywrapper();
        conActWrap.ActivityType = activityType;
        conActWrap.isunread = isunread;
        conActWrap.doInsert = doInsert;
        conActWrap.ContactList = contactsList;
        conActWrap.messageSubject = messageSubject;
        conActWrap.messagebody = messagebody;
        conActWrap.numActivities = numActivities;
        conActWrap.externalPhone = externalPhone;
        conActWrap.sobjectactivitycount = recordActCountMap;
        
        List<Activity__c> actList = Communication_TestDataFactory.createActivitiesforEachContact(conActWrap);

        string searchkey = 'Contact';
        string phone = '';
        string currentcontactid = '';
        Double storedActivityNumber = 0;
        Test.startTest();
        list<ChatBotController.InboxMember> Inboxmemberlist = ChatBotController.contactSearch(searchkey, storedActivityNumber, phone, currentcontactid);
        Test.stopTest();
        system.assertEquals(5, Inboxmemberlist.size());
    }
    /************************************************
this test class for no conversation started with 
in the chatbox yet onload test
************************************************/
    @isTest
    static void searchkeyblankOnloadsearch() { 
        List<Id> idList = new List<Id>();
        
        list<Contact> ContactlistDF = Communication_TestDataFactory.ContactListcreationDF(5,true);
        for(Contact itercon : ContactlistDF){
            idList.add(itercon.Id);
        }
        Test.setFixedSearchResults(idList);
        string searchkey = '';
        string phone = '';
        string currentcontactid = '';
        Double storedActivityNumber = 0;
        list<ChatBotController.InboxMember> Inboxmemberlist = ChatBotController.contactSearch(searchkey, storedActivityNumber, phone, currentcontactid);
        system.debug('Inboxmemberlist'+Inboxmemberlist);
        system.assertEquals(0, Inboxmemberlist.size());
    }
    /************************************************
this test method memebers serch in left sidepannel for having 
conversation started with 
in the chatbox onload test
***************************************************/
    @isTest
    static void contactSearchwithconversationsearchkeyblankOnload() { 
        List<Id> idList = new List<Id>();
        List<Lead> leadsList = LeadConversion_UnitTest.createLeads(20, true);
        List<Lead> fetchLeadsList = [SELECT Id,FirstName,LastName,Phone,Formatted_Phone_Number__c,Status,Company FROM Lead];     
        
        String externalPhone = '9999999999';
        String messageSubject = 'Test SMS Activity';
        String messagebody = 'Hello User This is Test SMS';
        Integer numActivities = 20;
        Boolean doInsert = true;
        
        List<Activity__c> createdActivities = LeadConversion_UnitTest.createActivitiesforEachLead(fetchLeadsList, externalPhone, messageSubject, messagebody, numActivities, doInsert);
        list<Inbox__c> inboxList = [select id from Inbox__c];
        system.debug('inboxList::::'+inboxList);
        list<Activity__c>activitylist = [select Id,Contact__c,Account__c,Lead__c from Activity__c];
        system.debug('activitylist'+activitylist);
        string searchkey = '';
        string phone = '';
        string currentcontactid = '';
        Double storedActivityNumber = 0;
        test.startTest();
        list<ChatBotController.InboxMember> Inboxmemberlist =   ChatBotController.contactSearch(searchkey, storedActivityNumber, phone, currentcontactid);
        Test.stopTest();
        system.debug(Inboxmemberlist);
        system.debug(Inboxmemberlist.size());
        system.assertEquals(10, Inboxmemberlist.size());
    }
    /*******************************************************************
Testing the senario while click on leftside pannel inbox contact
fetching the conversations with him And also checking unread meassage senario

*************************************************************************/
    @isTest
    static void getMessagesByRecordIdwithconversationsTest() {
        List<Id> idList = new List<Id>();
        Communication_TestDataFactory.createTestAccountWithContactsRecords(1, 5);
        Account acc = Communication_TestDataFactory.getAccountDetails();
        List<Contact> contactsList = Communication_TestDataFactory.getContactDetails();

        String activityType = 'sms';
        String externalPhone = '9999999999';
        String messageSubject = 'Test SMS Activity';
        String messagebody = 'Hello User This is Test SMS';
        Integer numActivities = 3;
        Boolean doInsert = true;
        Boolean isunread = false;
        Map<Id,Integer> recordActCountMap = new Map<Id,Integer>();
        for(Contact itercon : contactsList){
            idList.add(itercon.Id);
            recordActCountMap.put(itercon.Id, numActivities);
        }
        Test.setFixedSearchResults(idList);

        Communication_TestDataFactory.ContactActivitywrapper conActWrap = new Communication_TestDataFactory.ContactActivitywrapper();
        conActWrap.ActivityType = activityType;
        conActWrap.isunread = isunread;
        conActWrap.doInsert = doInsert;
        conActWrap.ContactList = contactsList;
        conActWrap.messageSubject = messageSubject;
        conActWrap.messagebody = messagebody;
        conActWrap.numActivities = numActivities;
        conActWrap.externalPhone = externalPhone;
        conActWrap.sobjectactivitycount = recordActCountMap;
        
        List<Activity__c> actList = Communication_TestDataFactory.createActivitiesforEachContact(conActWrap);
        String recordId = contactsList[0].Id;
        String phoneNumber = contactsList[0].Formatted_Phone_Number__c ;
        Integer messagesLimitPerPage  = 10 ;
        Integer currentPage = 1 ;
        
        ChatBotController.InboxMember Inboxmember = ChatBotController.getMessagesByRecordId(recordId, phoneNumber, messagesLimitPerPage, currentPage);
        system.debug('Inboxmember NDR ::::'+ Inboxmember);
        system.assertEquals(1, Inboxmember.paginatedActivitiesList.size());       
    }
    /*******************************************************************
Testing the senario while click on leftside pannel inbox contact
fetching the conversations with him if person has no conversations started
Account specific check
*************************************************************************/
    // @isTest
    // static void getMessagesByRecordIdNoconversationsTest() {
    //     List<Id> idList = new List<Id>();
    //     Account AccountDF = Communication_TestDataFactory.AccountListcreationDF(true);
        
    //     string recordId = AccountDF.Id;
    //     string phoneNumber = AccountDF.Formatted_Phone_Number__c ;
    //     integer messagesLimitPerPage  = 10 ;
    //     integer currentPage = 1 ;
    //     ChatBotController.InboxMember Inboxmember = ChatBotController.getMessagesByRecordId(recordId, phoneNumber, messagesLimitPerPage, currentPage);
    //     system.debug('Inboxmember NDR ::::'+ Inboxmember);
    //     system.assertEquals(0, Inboxmember.paginatedActivitiesList.size());
    //     system.assertEquals('InboxAccount', Inboxmember.contactName);
    // }
    /*******************************************************************
Testing the senario while click on leftside pannel inbox contact
fetching the conversations with him if person has no conversations started
Lead specific check
*************************************************************************/
    // @isTest
    // static void getMessagesByRecordIdNoconversationsLeadTest() {
    //     Lead LeadDF = Communication_TestDataFactory.createLeadDF(true);
    //     string recordId = LeadDF.Id;
    //     string phoneNumber = LeadDF.Formatted_Phone_Number__c ;
    //     integer messagesLimitPerPage  = 10 ;
    //     integer currentPage = 1 ;
    //     ChatBotController.InboxMember Inboxmember = ChatBotController.getMessagesByRecordId(recordId, phoneNumber, messagesLimitPerPage, currentPage);
    //     system.debug('Inboxmember NDR ::::'+ Inboxmember);
    //     system.assertEquals(0, Inboxmember.paginatedActivitiesList.size());
    //     system.debug('Inboxmember.contactName'+Inboxmember.contactName);
    //     system.assertEquals('Lead', Inboxmember.objectApiName);
    // }
    
    @isTest
    static void createActivityTest() {
        Contact contactDF = Communication_TestDataFactory.createContactDF(true);
        list<Media_URL__c> mediautllistDF = Communication_TestDataFactory.createmediaurllistDF(5,true);
        String type = 'sms';
        List<String> mediaUrls = new list <String>(); 
        for (Media_URL__c mediter : mediautllistDF){
            mediaUrls.add(mediter.Media_Url__c);
        }
        String messagebody= 'Hi team';
        String messageSubject= 'Inbox - Outbound SMS';
        String fromPhone;
        String toPhone = contactDF.Formatted_Phone_Number__c;
        Id recordId = contactDF.Id;
        String accountId = contactDF.AccountId;
        Activity__c activity = ChatBotController.createActivity(type, mediaUrls, messagebody, messageSubject, fromPhone, toPhone, recordId, accountId);
        System.assertNotEquals(null, activity);
    }
    
    @IsTest
    static void saveChunkTest(){
        Account AccountDF = Communication_TestDataFactory.AccountListcreationDF(true);
        Contact ContactDF = Communication_TestDataFactory.createContactDF(true);       
        
        Blob file =  Blob.valueOf('sample text');
        
        Id cvId = ChatBotController.saveChunk(ContactDF.id, 'testAttachment', file.toString(), 'jpg', null);
        System.assertNotEquals(null, cvId);
    }
    @IsTest
    static void saveExistingFileChunkTest(){
       // Account AccountDF = Communication_TestDataFactory.AccountListcreationDF(true);
        Contact ContactDF = Communication_TestDataFactory.createContactDF(true);
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        
        Id cvId = ChatBotController.saveChunk(ContactDF.id, 'testAttachment', file.toString(), 'jpg', contentToInsert.Id);
        System.assertNotEquals(null, cvId);
    }
    /******************************************
* Callout methods thesting               *
* ****************************************/
    
    @isTest static void testPlivoSMSCalloutsucess() {
        
        Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
        string recordId = activityRecord.Id;
        string httpMethod = 'POST';
        string operationType = 'INSERT';
        string integrationSetting = 'Plivo';
        string  objectSetting = 'PlivoSMS';
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, Communication_MockHttpResponseGenerator.Sucesscallout());     
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Activity__c res = ChatBotController.plivoSmsCalloutSynchronous(recordId, httpMethod, operationType, integrationSetting, objectSetting);
        system.debug('Activityresponce::::::::'+res);
          List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        System.assertEquals('OUTBOUND', res.Direction__C);
        Test.stopTest();
    }
    @isTest static void testPlivoSMSCalloutfailure() {
        
        Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
        string recordId = activityRecord.Id;
        string httpMethod = 'POST';
        string operationType = 'INSERT';
        string integrationSetting = 'Plivo';
        string  objectSetting = 'PlivoSMS';
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, Communication_MockHttpResponseGenerator.stopServer());     
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Activity__c res = ChatBotController.plivoSmsCalloutSynchronous(recordId, httpMethod, operationType, integrationSetting, objectSetting);
        system.debug('Activityresponce::::::::'+res);
        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        Test.stopTest();
    }
    
    @isTest static void testPlivoMediaCalloutsucess() {
        
        Contact ContactDF = Communication_TestDataFactory.createContactDF(true);
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        
        Id cvId = ChatBotController.saveChunk(ContactDF.id, 'testAttachment', file.toString(), 'png', contentToInsert.Id);
        
        //Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
        //string  contentVersionId = contentToInsert.Id;
        string  currentfileType = 'Png';
        string  recordId = ContactDF.Id;
        string messageSubject = 'oubound media';
        string  toPhone  = ContactDF.Formatted_Phone_Number__c;
        string  fromPhone = '18008803326';
        String accountId = contactDF.AccountId;
        Test.setMock(HttpCalloutMock.class, Communication_MockHttpResponseGenerator.Sucesscallout());
        Test.startTest();
        ChatBotController.UploadApiResponseWrapper uploadwrapper = ChatBotController.submitAttachment(cvId, currentfileType, messageSubject, fromPhone, toPhone, recordId, accountId);
        system.assert(uploadwrapper!=null);
        Test.stopTest();
    }
       @isTest static void testPlivoMediaCalloutFailure() {
        
        Contact ContactDF = Communication_TestDataFactory.createContactDF(true);
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        
        Id cvId = ChatBotController.saveChunk(ContactDF.id, 'testAttachment', file.toString(), 'png', contentToInsert.Id);
        
        //Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
        //string  contentVersionId = contentToInsert.Id;
        string  currentfileType = 'Png';
        string  recordId = ContactDF.Id;
        string messageSubject = 'oubound media';
        string  toPhone  = ContactDF.Formatted_Phone_Number__c;
        string  fromPhone = '18008803326';
        String accountId = contactDF.AccountId;
        Test.setMock(HttpCalloutMock.class, Communication_MockHttpResponseGenerator.stopServer());
        Test.startTest();
        ChatBotController.UploadApiResponseWrapper uploadwrapper = ChatBotController.submitAttachment(cvId, currentfileType, messageSubject, fromPhone, toPhone, recordId, accountId);
        system.assert(uploadwrapper!=null);
        Test.stopTest();
    }
     
    /****************************
* need to cover in senarios*
* **************************/
    
    @isTest
    static void getReversedActivitiesListTest() {
        list<Activity__c> activityList = new list <Activity__c>();
        Test.startTest();
        list<Activity__c> activityRecordDFList = Communication_TestDataFactory.listActivitycreationDF(false,false,true);
        activityList = ChatBotController.getReversedActivitiesList(activityRecordDFList);
        system.assert(activityList!=null);
        
        Test.stopTest();
    }
    @isTest
    static void getContactNameFromInboxRecordTest() {
        Test.startTest();
        Inbox__c InboxRecordDF = Communication_TestDataFactory.CreationofInbox();
        string contactName =  ChatBotController.getContactNameFromInboxRecord(InboxRecordDF);
        //system.assert(activityList!=null);
        
        Test.stopTest();
    }
    @isTest
    static void registerActivityRecordsListTest() {
        list<Activity__c> activityList = new list <Activity__c>();
        Test.startTest();
        list<Activity__c> activityRecordDFList = Communication_TestDataFactory.listActivitycreationDF(false,true,false);
        system.debug(activityRecordDFList);
        insert activityRecordDFList;
        String fetchActivityListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
            ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
            ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
            ' FROM Activity__c ORDER BY When__c DESC ';
        List<Activity__c> fetchActivity = Database.query(fetchActivityListQuery); 
        
        ChatBotController.InboxMember  InbodmemberList = ChatBotController.registerActivityRecordsList(fetchActivity);
        //system.assert(activityList!=null);
        
        Test.stopTest();
    }
    
    @isTest
    static void getParsedResponseTest() {
        Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
        string recordid = activityRecord.Id;
        string phone  = activityRecord.Message__c;
        string smsBody = ChatBotController.getParsedResponse(recordid,phone);
        system.assert(smsBody!=null);
    }
    @isTest
    static void getParsedResponseTestExceptionhandling() {
        string smsBody;
        try{
            Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationDF(false,true,false);
            string recordid = '';
            string phone  = '';
            smsBody = ChatBotController.getParsedResponse(recordid,phone);
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage(), 'Failed to parse Message Template');  
        }
    }
    
    @isTest
    static void getDefaultPhoneNumberTest() {
        Test.startTest();
        string Intsetting = 'Plivo';
        string  fromNumber = ChatBotController.getDefaultPhoneNumber(Intsetting);
        
        // string smsBody = ChatBotController.getParsedResponse(recordid,phone);
        system.assert(fromNumber!=null);
        Test.stopTest();
    }  
    @isTest
    static void getAllSMSTemplatesTest() {
        Test.startTest();
        Lead LeadDF = Communication_TestDataFactory.createLeadDF(true);
        string recordId = LeadDF.Id;
        ChatBotController.getAllSMSTemplates(recordId);
        Test.stopTest();
    }   
    @isTest
    static void registerInboxRecordsListTest() {
        Test.startTest();
        list<Inbox__c> inboxlistDF = Communication_TestDataFactory.CreationofInboxList(5,true);
        ChatBotController.registerInboxRecordsList(inboxlistDF);
        Test.stopTest();
    }   
    
    
}