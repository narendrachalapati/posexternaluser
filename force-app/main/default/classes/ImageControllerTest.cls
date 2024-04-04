@IsTest
public class ImageControllerTest {
    
    @IsTest
    static void sysTrackerDisplayPictureTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;
        
        Contact objContact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
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
        ImageController.createSysTrackRecord(objContact.Id, contentToInsert.Id);
        Test.stopTest();
        List<SYS_Tracker__c> existingSysTracker = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c LIMIT 1];
        System.assert(existingSysTracker.size()>0);
    }
    
    @IsTest
    static void getSysTrackRecordPictureURLTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;
        
        Contact objContact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        ImageController.createSysTrackRecord(objContact.Id, contentToInsert.Id);
        Test.startTest();
        String pictureURL =  ImageController.getSysTrackRecordPictureURL(objContact.Id);
        Test.stopTest();
        System.assertNotEquals(null, pictureURL);
    }
    
    @IsTest
    static void getShortendImageNameTest(){
        String shortImageName =  ImageController.getShortendImageName('Adisols Test');
        
        String shortNoName =  ImageController.getShortendImageName('');
        String shortNoNameThree =  ImageController.getShortendImageName('Adisols Test New');
        String shortNoNameFour =  ImageController.getShortendImageName('Adisols Test New Member');
        String shortNoNameFive =  ImageController.getShortendImageName('Adisols Test New Member Record');
        System.assertEquals('AT', shortImageName);
    }
    
    @IsTest
    static void WhattIdSysTrackerWrapperTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;
        
        Contact objContact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        ImageController.createSysTrackRecord(objContact.Id, contentToInsert.Id);
        
        //SecondContact Create
        Contact objContactnew = new Contact(FirstName = 'SampleNew', LastName = 'ContactNew', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl1',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq31',RecordTypeId = MemberRecordTypeId);
        insert objContactnew ;
        ContentVersion contentToInsertsecond = new ContentVersion(); 
        contentToInsertsecond.Title = fileName; 
        contentToInsertsecond.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsertsecond.PathOnClient='/' + fileName ;
        contentToInsertsecond.IsMajorVersion = false;
        insert contentToInsertsecond;
        ImageController.createSysTrackRecord(objContactnew.Id, contentToInsertsecond.Id);
        
        List<SYS_Tracker__c> existingSysTrackerList = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c];
        
        ImageController.WhattIdSysTrackerWrapper whattIdSystrackWrapper = new ImageController.WhattIdSysTrackerWrapper();
        whattIdSystrackWrapper.sysTrackerList = existingSysTrackerList;
        whattIdSystrackWrapper.displayPictureURL = 'noimage';
        System.assertNotEquals(0, existingSysTrackerList.size());
    }
    
    @IsTest
    static void getSysTrackRecordDocumentIdTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;
        
        Contact objContact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        ImageController.createSysTrackRecord(objContact.Id, contentToInsert.Id);
        Test.startTest();
        String cvId =  ImageController.getSysTrackRecordDocumentId(objContact.Id);
        Test.stopTest();
        List<SYS_Tracker__c> existingSysTracker = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c LIMIT 1];
        System.assert(existingSysTracker.size()>0);
    }
    
    @IsTest
    static void loadAllRecordImagesMapTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;
        
        Contact objContact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        ImageController.createSysTrackRecord(objContact.Id, contentToInsert.Id);
        Test.startTest();
        Map < Id, String > map_RecordsDisplayPic = ImageController.loadAllRecordImagesMap();
        String imageUrl = map_RecordsDisplayPic.get(objContact.Id);
        imageUrl = (String.IsNotBlank(imageUrl)) ? imageUrl : 'noimage';
        Test.stopTest();
        List<SYS_Tracker__c> existingSysTracker = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c LIMIT 1];
        System.assert(existingSysTracker.size()>0);
        System.assertNotEquals(null, imageUrl);
    }
    
    @IsTest
    static void getWhattIdBasedSystrackerWrapperTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;
        
        Contact objContact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        ImageController.createSysTrackRecord(objContact.Id, contentToInsert.Id);
        
        ContentVersion contentToInsertnew = new ContentVersion(); 
        contentToInsertnew.Title = fileName; 
        contentToInsertnew.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsertnew.PathOnClient='/' + fileName ;
        contentToInsertnew.IsMajorVersion = false;
        insert contentToInsertnew;
        ImageController.createSysTrackRecord(objContact.Id, contentToInsertnew.Id);
        
        //SecondContact Create
        Contact objContactnew = new Contact(FirstName = 'SampleNew', LastName = 'ContactNew', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl1',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq31',RecordTypeId = MemberRecordTypeId);
        insert objContactnew ;
        ContentVersion contentToInsertsecond = new ContentVersion(); 
        contentToInsertsecond.Title = fileName; 
        contentToInsertsecond.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsertsecond.PathOnClient='/' + fileName ;
        contentToInsertsecond.IsMajorVersion = false;
        insert contentToInsertsecond;
        ImageController.createSysTrackRecord(objContactnew.Id, contentToInsertsecond.Id);
        
        ContentVersion contentToInsertsecondnew = new ContentVersion(); 
        contentToInsertsecondnew.Title = fileName; 
        contentToInsertsecondnew.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsertsecondnew.PathOnClient='/' + fileName ;
        contentToInsertsecondnew.IsMajorVersion = false;
        insert contentToInsertsecondnew;
        ImageController.createSysTrackRecord(objContactnew.Id, contentToInsertsecondnew.Id);
        
        list<id>emptylist = new list<Id>();
        Test.startTest();
        List<Id> WhattIdsList = new List<Id>{objContact.Id, objContactnew.Id};
            Map<Id, ImageController.WhattIdSysTrackerWrapper> WhattIdSysTrackerWrapperMap = ImageController.getWhattIdBasedSystrackerWrapper(WhattIdsList);
        ImageController.getWhattIdBasedSystrackerWrapper(emptylist);
        Test.stopTest();
        for(Id whattId :WhattIdSysTrackerWrapperMap.keySet()){
            ImageController.WhattIdSysTrackerWrapper newWhattIdSysTrackerWrapper =  WhattIdSysTrackerWrapperMap.get(whattId);
            System.assertNotEquals(null, newWhattIdSysTrackerWrapper.sysTrackerIdsList);
            System.assertNotEquals(null, newWhattIdSysTrackerWrapper.sysTrackerWhoIdsList);
        }
        
        List<SYS_Tracker__c> existingSysTracker = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c LIMIT 1];
        System.assertNotEquals(null, WhattIdSysTrackerWrapperMap);
    }
    @IsTest
    static void getWhattIdBasedSystrackerWrapperTestv2(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;
        
        Contact objContact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert objContact ;
        String fileName = 'test Attachment';
        Blob file =  Blob.valueOf('sample text');
        ContentVersion contentToInsert = new ContentVersion(); 
        contentToInsert.Title = fileName; 
        contentToInsert.VersionData = EncodingUtil.base64Decode(file.toString());
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;
        List< Id > whatidList = new List< Id >();
        whatidList.add(objContact.Id);
        List< SYS_Tracker__c > sysTrackerList = new List< SYS_Tracker__c >();
        SYS_Tracker__c sysTracker =new SYS_Tracker__c();
        sysTracker.Type__c = 'Activity SMS';
        sysTracker.WhatId__c =objContact.Id;
        sysTracker.WhoId__c = contentToInsert.Id;
        sysTrackerList.add(sysTracker);
        insert  sysTrackerList;
        
        ImageController.getWhattIdBasedSystrackerWrapper(whatidList);
    }
    
}