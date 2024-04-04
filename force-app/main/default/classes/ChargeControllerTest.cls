@IsTest
public class ChargeControllerTest {
	@TestSetup
    static void ChargeControllerTest(){
        PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 3);  
    }
    
    @IsTest
    static void fetchVirtualTerminalcontactTest(){
        Contact virtualTerminalcontact = ChargeController.fetchVirtualTerminalcontact();
        System.assertEquals('Anonymous', virtualTerminalcontact.Member_Type__c);
    }
    
    @IsTest
    static void fetchExisting_VirtualTerminalcontactTest(){
        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        Contact newContact = new Contact();
        newContact.FirstName = 'Virtual';
        newContact.LastName = 'Terminal';
        newContact.RecordTypeId = memberRecordTypeId;
        newContact.Member_Type__c = 'Anonymous';
        insert newContact;
        Contact virtualTerminalcontact = ChargeController.fetchVirtualTerminalcontact();
        System.assertEquals('Anonymous', virtualTerminalcontact.Member_Type__c);
    }
    
    @IsTest
    static void getCurrencyTest(){
        String userCurrency = ChargeController.getCurrency();
        System.assertEquals(UserInfo.getDefaultCurrency(), userCurrency);
    }
    
    @IsTest
    static void getOrgUrlTest(){
        String OrgUrl = ChargeController.getOrgUrl();
        System.assertNotEquals(null, OrgUrl);
    }
    
	@IsTest
    static void getPropertiesTest(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        Contact fetchContact = getcurrAccount.Contacts[0];
        User cuser = PMA_SearchController.fetchCurrentUser();
        cuser.ContactId__c = fetchContact.Id;
        update cuser;
        PMA_SearchController.StripeApiTokensWrap apiKeyWrap = ChargeController.getProperties();
        System.assertNotEquals(null, apiKeyWrap.Name);
        
    }   
    
    @IsTest
    static void getObjectAndLabelsTest(){
        Map<String, Object> labelsMap = ChargeController.getObjectAndLabels();
        System.assertNotEquals(null, labelsMap);
    } 
    
    @IsTest
    static void createPaymentRequestsTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();

        Account account = new Account(Name = 'Sample Account', Plivo_Country_Code__c = '1',
            Plivo_Sender_Id__c = '12222222222', Plivo_PHLO_Id__c = 'Test123');
        insert account;

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);

        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

        User cuser = PMA_SearchController.fetchCurrentUser();
        cuser.ContactId__c = contact.Id;
        update cuser;

		List<ChargeController.ChargeRequest> chargeRequests = new List<ChargeController.ChargeRequest>();
        ChargeController.ChargeRequest  chrgReq = new ChargeController.ChargeRequest();
        chrgReq.paymentName = 'Virtual Payment';
        chrgReq.contactId = null;
        chrgReq.accountId = account.Id;
        chrgReq.opportunityId = null;
        chrgReq.orderId = null;
        chrgReq.paymentType = 'immediate';
        chrgReq.amount = Double.valueOf(23.4);
        chrgReq.email = 'dev@adisols.com';
        chrgReq.frequency = 'single'; 
        chrgReq.firstChargeDate = System.TODAY();    
       	chargeRequests.add(chrgReq);
        
        List<Payment_Intent__c> pmtIntentList = ChargeController.createPaymentRequests(chargeRequests);
        System.assert(pmtIntentList.size()>0);
    } 
    
    @IsTest
    static void processPayments_defaultCardTest() {
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);

        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

		List<Payment_Intent__c> paymentRequests = new List<Payment_Intent__c>();
        Payment_Intent__c paymentRequest = PaymentIntentService.createNewPaymentIntent(
                'Test Payment Request',
                contact.Id,
                account.Id,
                null,
                'immediate',
                Double.valueOf(23.4),
                'sample@gmail.com',
                'single',
                System.TODAY());
        paymentRequests.add(paymentRequest);
        Stripe.UserPaymentRequest stripePaymentRequest = new Stripe.UserPaymentRequest();
        stripePaymentRequest.paymentMethod = 'card';
        stripePaymentRequest.selectedPaymentSource = 'card_2JZWVCDQBrpdxQCKwNKVLJq3';
        
        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeChargeSuccess');
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, stripeMock);
        Stripe.Payment newpymtprocess = ChargeController.processPayments(paymentRequests, stripePaymentRequest);
        Test.stopTest();
        System.assertNotEquals(null, newpymtprocess);
    }
    
    @IsTest
    static void getUserCards_thenGetsCustomerCards() {
        Account account = new Account(Name = 'Sample Account');
        insert account;

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);
		
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id,StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

        Payment_Intent__c paymentRequest = PaymentIntentService.createNewPaymentIntent(
                'Test Payment Request',
                contact.Id,
                account.Id,
                null,
                'immediate',
                Double.valueOf(23.4),
                'sample@gmail.com',
                'single',
                System.TODAY());

        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCustomerCards');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);
        List<Stripe.Card> cardsList = ChargeController.getUserCards(contact.Id);
        Test.stopTest();
        System.assert(cardsList.size()>0);
    }
    
    @IsTest
    static void getPaymentMethods_thenGetsCustomerCards() {
        Account account = new Account(Name = 'Sample Account');
        insert account;

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);
		
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id,StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

        Payment_Intent__c paymentRequest = PaymentIntentService.createNewPaymentIntent(
                'Test Payment Request',
                contact.Id,
                account.Id,
                null,
                'immediate',
                Double.valueOf(23.4),
                'sample@gmail.com',
                'single',
                System.TODAY());

        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCustomerCards');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);
        Stripe.PaymentMethods allPaymentMethods = ChargeController.getPaymentMethods(contact.Id);
        Test.stopTest();
        System.assert(allPaymentMethods.cards.size()>0);
    }
            
}