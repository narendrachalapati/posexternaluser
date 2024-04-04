@IsTest
private class PaymentMethodsControllerTest {
    private static StripeService stripeService = new StripeService();

    @TestSetup
    static void TransactionControllerTest() {
            PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 3);
    } 

    @IsTest
    static void initStripeProps_thenGetsCustomerCards() {
        Account account = new Account(Name = 'Sample Account');
        insert account;

        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo',
            Key__c = 'int-set',
            Value__c = 'Plivo'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Stripe',
            Key__c = 'int-set',
            Value__c = 'Stripe'));
        
        insert accIntMetadata; 

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);
		
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id,StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        
        Contact fetchContact = [SELECT Id,UUID__c, StripeCustomerId__c FROM Contact WHERE Id = :contact.Id LIMIT 1];

        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCustomerCards');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);
        
        PageReference pageRef = Page.StripePaymentMethod;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', fetchContact.UUID__c);

        PaymentMethodsController paymentmethodsController = new PaymentMethodsController();
        paymentmethodsController.initStripeProps();

        List<Stripe.Card> cards = paymentmethodsController.cards;
        Test.stopTest();

        System.assertEquals(1, cards.size());
        Stripe.Card card = cards.get(0);

        System.assertEquals('card_1FZWVCDQBrpdxQCKwNKVLJq3', card.id);
        System.assertEquals('Visa', card.brand);
        System.assertEquals('US', card.country);
        System.assertEquals('cus_G5i0UDob8XanSl', card.customer);
        System.assertEquals(8, card.exp_month);
        System.assertEquals(2020, card.exp_year);
        System.assertEquals('yuXurUji077WWEYr', card.fingerprint);
        System.assertEquals('credit', card.funding);
        System.assertEquals('4242', card.last4);
        System.assertEquals(new Map<String, String>(), card.metadata);
        System.assertEquals(null, card.tokenization_method);
        System.assertEquals('cus_G5i0UDob8XanSl', fetchContact.StripeCustomerId__c);
    }

    @IsTest
    static void saveNewCardTest() {
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo',
            Key__c = 'int-set',
            Value__c = 'Plivo'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Stripe',
            Key__c = 'int-set',
            Value__c = 'Stripe'));
        
        insert accIntMetadata; 

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);

        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

        Contact fetchContact = [SELECT Id,UUID__c, StripeCustomerId__c FROM Contact WHERE Id = :contact.Id LIMIT 1];
        
        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCreateCard');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);

        PageReference pageRef = Page.StripePaymentMethod;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', fetchContact.UUID__c);

        PaymentMethodsController paymentmethodsController = new PaymentMethodsController();
        paymentmethodsController.stripePaymentRequestJson = '{"selectedPaymentSource":"", "stripeToken":"testToken", "saveCard": true }';
        System.debug('paymentmethodsController.stripePaymentRequestJson ' + paymentmethodsController.stripePaymentRequestJson);
        paymentmethodsController.saveNewCard();
        System.debug('cards.size() ' + paymentmethodsController.cards);

        List<Stripe.Card> cards = paymentmethodsController.cards;
        Test.stopTest();

        System.assertEquals(null, cards);
    }

    @IsTest
    static void testrefreshStripeError() {
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        Contact fetchContact = getcurrAccount.Contacts[0];
        User cuser = PMA_SearchController.fetchCurrentUser();
        cuser.ContactId__c = fetchContact.Id;
        update cuser;

        Test.startTest();     
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCustomerCards');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);

        PageReference pageRef = Page.StripePaymentMethod;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', fetchContact.UUID__c);

        PaymentMethodsController paymentmethodsController = new PaymentMethodsController();
        paymentmethodsController.stripeError = 'Your card was Declined.';
        paymentmethodsController.refreshStripeError();
        Test.stopTest();

        System.assertEquals('Your card was Declined.', paymentmethodsController.stripeError);
    }

    @IsTest
    static void testresetStripeError() {
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        Contact fetchContact = getcurrAccount.Contacts[0];
        User cuser = PMA_SearchController.fetchCurrentUser();
        cuser.ContactId__c = fetchContact.Id;
        update cuser;

        Test.startTest();      
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCustomerCards');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);

        PageReference pageRef = Page.StripePaymentMethod;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', fetchContact.UUID__c);

        PaymentMethodsController paymentmethodsController = new PaymentMethodsController();
        paymentmethodsController.stripeError = 'Your card was Declined.';
        paymentmethodsController.resetStripeError();
        Test.stopTest();

        System.assertEquals(null, paymentmethodsController.stripeError);
    }

    @IsTest
    static void saveNewCardCatchJSONExceptionTest() {
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo',
            Key__c = 'int-set',
            Value__c = 'Plivo'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Stripe',
            Key__c = 'int-set',
            Value__c = 'Stripe'));
        
        insert accIntMetadata; 

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);

        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

        Contact fetchContact = [SELECT Id,UUID__c, StripeCustomerId__c FROM Contact WHERE Id = :contact.Id LIMIT 1];
        
        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCardErrorResponse');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);

        PageReference pageRef = Page.StripePaymentMethod;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', fetchContact.UUID__c);

        PaymentMethodsController paymentmethodsController = new PaymentMethodsController();
        paymentmethodsController.stripePaymentRequestJson = '';
        System.debug('paymentmethodsController.stripePaymentRequestJson ' + paymentmethodsController.stripePaymentRequestJson);
        paymentmethodsController.saveNewCard();
        System.debug('cards.size() ' + paymentmethodsController.cards);

        List<Stripe.Card> cards = paymentmethodsController.cards;
        Test.stopTest();

        System.assertEquals(null, cards);
    }

    @IsTest
    static void saveNewCardCatchRestExceptionTest() {
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo',
            Key__c = 'int-set',
            Value__c = 'Plivo'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Stripe',
            Key__c = 'int-set',
            Value__c = 'Stripe'));
        
        insert accIntMetadata; 

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);

        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

        Contact fetchContact = [SELECT Id,UUID__c, StripeCustomerId__c FROM Contact WHERE Id = :contact.Id LIMIT 1];
        oauthRecord.Access_Token__c= '';
        update oauthRecord;

        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCardErrorResponse');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);

        PageReference pageRef = Page.StripePaymentMethod;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', fetchContact.UUID__c);

        PaymentMethodsController paymentmethodsController = new PaymentMethodsController();

        
        paymentmethodsController.stripePaymentRequestJson = '{"selectedPaymentSource":"", "stripeToken":"", "saveCard": true }';
        paymentmethodsController.saveNewCard();
        System.debug('cards.size() ' + paymentmethodsController.cards);

        List<Stripe.Card> cards = paymentmethodsController.cards;
        Test.stopTest();

        System.assertEquals(null, cards);
    }

}