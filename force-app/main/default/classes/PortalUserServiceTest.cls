@IsTest
public class PortalUserServiceTest {
    @TestSetup
    static void PortalUserServiceTest() {
            PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
    }
    /*
    @IsTest
    static void createPartnerManagerUserTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        Id ManagerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Manager').getRecordTypeId();
        
        Contact currentContact = [Select Id,Name,FirstName,LastName,RecordTypeId, Phone_Number__c, Email, Account.Name,RecordType.Name FROM Contact LIMIT 1];
		currentContact.RecordTypeId = ManagerRecordTypeId;
        currentContact.FirstName = 'Test';
        currentContact.LastName = 'ContactPartnerManager';
        currentContact.Email = 'devportalmanageruser@adisols.com';
        update currentContact;
        Test.startTest();        
        PortalUserService.createPartnerUser(currentContact.Id);
        Test.stopTest();
        
        User currentUserRecord = [SELECT ContactId, ContactId__c FROM User WHERE ContactId =: currentContact.Id];
        System.assertEquals(currentContact.Id, currentUserRecord.ContactId);
    }
    
    @IsTest
    static void createPartnerVendorUserTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        Id VendorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        
        Contact currentContact = [Select Id,Name,FirstName,LastName,RecordTypeId, Phone_Number__c, Email, Account.Name,RecordType.Name FROM Contact LIMIT 1];
		currentContact.RecordTypeId = VendorRecordTypeId;
        currentContact.FirstName = 'Test';
        currentContact.LastName = 'ContactPartnerVendor';
        currentContact.Email = 'devportalVendoruser@adisols.com';
        update currentContact;
        Test.startTest();        
        PortalUserService.createPartnerUser(currentContact.Id);
        Test.stopTest();
        
        User currentUserRecord = [SELECT ContactId, ContactId__c FROM User WHERE ContactId =: currentContact.Id];
        System.assertEquals(currentContact.Id, currentUserRecord.ContactId);
    }
    */
    @IsTest
    static void createManagerSalesforceUserTest(){
        Account account = new Account(Name = 'Sample Account', Plivo_Country_Code__c = '1',
            Plivo_Sender_Id__c = '12222222222', Plivo_PHLO_Id__c = 'Test123');
        insert account;

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);
		
        Id ManagerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Manager').getRecordTypeId();
        Test.startTest();
        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', Email = 'devsfmanager@adisols.com',
            AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl', 
            Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3', RecordTypeId = ManagerRecordTypeId);
        insert contact;
        
        //PortalUserService.createSalesforceUser(contact.Id);
        Test.stopTest();
        User currentUserRecord = [SELECT ContactId, ContactId__c FROM User WHERE ContactId__c =: contact.Id];
        System.assertEquals(contact.Id, currentUserRecord.ContactId__c);
    }
        
}