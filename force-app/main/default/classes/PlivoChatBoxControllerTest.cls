@IsTest
public class PlivoChatBoxControllerTest {
	
    @IsTest
    static void fetchVirtualTerminalcontactTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        List<Contact> contList = PlivoChatBoxController.contactlist();
        System.assert(contList.size()>0);
    }

    @IsTest
    static void getContactDetailsTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        Contact cont = PlivoChatBoxController.getContactDetails(contact.Id);
        System.assertEquals('Sample Contact', cont.Name);
    }

    @IsTest
    static void contactserchTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111' , AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        String messagebody = 'Test SMS Activity';
        String messageSubject = 'Inbox - Outbound SMS to Sample Guest';
        String issmsActivityCreated = PlivoChatBoxController.createActivity(messagebody, messageSubject, contact.Id);
        Contact con = [SELECT Id, Name, Phone_Number__c, ActivityCount__c, Latest_Activity_Number__c, UnreadActivitiesCount__c FROM Contact WHERE Id =: contact.Id];
                
        List<PlivoChatBoxController.ActivityContactListWrapper> contWrapper = PlivoChatBoxController.contactserch('Sample', 123 ,null);
        System.assert(contWrapper.size()>0);
    }
    
    @IsTest
    static void emptyString_contactserchTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        String messagebody = 'Test SMS Activity';
        String messageSubject = 'Inbox - Outbound SMS to Sample Guest';
        String issmsActivityCreated = PlivoChatBoxController.createActivity(messagebody, messageSubject, contact.Id);
        Contact con = [SELECT Id, Name, Phone_Number__c, ActivityCount__c, Latest_Activity_Number__c, UnreadActivitiesCount__c FROM Contact WHERE Id =: contact.Id];
                
        List<PlivoChatBoxController.ActivityContactListWrapper> contWrapper = PlivoChatBoxController.contactserch('', 123 ,null);
        System.assertNotEquals(null, contWrapper);
    }
    
    @IsTest
    static void getMessagesByRecordIdTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        String messagebody = 'Test SMS Activity';
        String messagebody1 = 'Test SMS Activity New';
        String messageSubject = 'Inbox - Outbound SMS to Sample Guest';
        String issmsActivityCreated = PlivoChatBoxController.createActivity(messagebody, messageSubject, contact.Id);
        String issmsActivityCreated1 = PlivoChatBoxController.createActivity(messagebody1, messageSubject, contact.Id);
        PlivoChatBoxController.ActivityContactWrapper wrapRecord = PlivoChatBoxController.getMessagesByRecordId(contact.Id , 10 , 0, false);
        System.assertNotEquals(null, wrapRecord);
    }
    
    @IsTest
    static void EmptyActivity_getMessagesByRecordIdTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        PlivoChatBoxController.ActivityContactWrapper wrapRecord = PlivoChatBoxController.getMessagesByRecordId(contact.Id , 10 , 0, false);
        System.assertNotEquals(null, wrapRecord);
    }

    @IsTest
    static void GetActivitiesRemainingTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        String messagebody = 'Test SMS Activity';
        String messagebody1 = 'Test SMS Activity New';
        String messageSubject = 'Inbox - Outbound SMS to Sample Guest';
        String issmsActivityCreated = PlivoChatBoxController.createActivity(messagebody, messageSubject, contact.Id);
        String issmsActivityCreated1 = PlivoChatBoxController.createActivity(messagebody1, messageSubject, contact.Id);
        PlivoChatBoxController.ActivityContactWrapper wrapRecord = PlivoChatBoxController.GetActivitiesRemaining(contact.Id , 10 , 0);
        System.assertNotEquals(null, wrapRecord);
    }
     
    @IsTest
    static void calloutSynchronousOutboundTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        String accountMergeFieldForContact = 'AccountId';
        Account account = new Account(Name = 'Sample Account');
        insert account;

        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();

        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo',
            Key__c = 'int-set',
            Value__c = 'Plivo'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo_PHLO',
            Key__c = 'int-set',
            Value__c = 'Plivo_PHLO'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Stripe',
            Key__c = 'int-set',
            Value__c = 'Stripe'));
        
        insert accIntMetadata; 

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        String objSetting = 'Plivo_PHLO_Call';
        String apexHandler = 'SYS_ApplicationService';
        String direction ='OUT';
        Test.startTest();
        StaticResourceCalloutMock plivoConfMock = new StaticResourceCalloutMock();
		plivoConfMock.setStaticResource('mockPlivoConferenceSuccess');
        plivoConfMock.setStatusCode(200);
        plivoConfMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, plivoConfMock);
        String callStatus = PlivoChatBoxController.calloutSynchronousOutbound(contact.Id, objSetting, apexHandler, direction, accountMergeFieldForContact);
        Test.stopTest();
        
        System.assertNotEquals(null, callStatus);
    }   
    @IsTest
    static void saveChunkTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact objContact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        
        Blob file =  Blob.valueOf('sample text');
        
        Id cvId = PlivoChatBoxController.saveChunk(objContact.id, 'testAttachment', file.toString(), 'jpg', null);
        System.assertNotEquals(null, cvId);
    }
    
    @IsTest
    static void saveExistingFileChunkTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact objContact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        
        Id cvId = PlivoChatBoxController.saveChunk(objContact.id, 'testAttachment', file.toString(), 'jpg', contentToInsert.Id);
        System.assertNotEquals(null, cvId);
    }
    
    
    @IsTest
    static void submitAttachmentTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact objContact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        Test.startTest();
        StaticResourceCalloutMock plivommsMock = new StaticResourceCalloutMock();
		plivommsMock.setStaticResource('mockPlivoMMSSuccess');
        plivommsMock.setStatusCode(200);
        plivommsMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, plivommsMock);
        String attachUploadStatus = PlivoChatBoxController.submitAttachment(contentToInsert.Id, 'text/plain' , objContact.id );
        Test.stopTest();
        
        System.assertNotEquals(null, attachUploadStatus);
    }
}