@IsTest
private class TransactionControllerTest {

    private static TransactionService transactionService = new TransactionService();
	private static StripeService stripeService = new StripeService();
    
    @TestSetup
    static void TransactionControllerTest() {
            PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 3);
    }    
	    
    @IsTest
    static void initCards_thenGetsCustomerCards() {
        Account account = new Account(Name = 'Sample Account');
        insert account;

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);
		
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id,StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

        Opportunity opportunity = new Opportunity(Name = 'Sample Opportunity', AccountId = account.Id,
                StageName = 'Open', CloseDate = Date.today().addDays(2));
        opportunity.Name = 'Sample Opportunity';
        opportunity.AccountId = account.Id;
        insert opportunity;

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

        Transaction__c txn = transactionService.createTransaction(paymentRequest);


        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCustomerCards');
        
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);
        
        PageReference pageRef = Page.StripePaymentPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', paymentRequest.UUID__c);

        TransactionController transactionController = new TransactionController();
        //List<Stripe.Card> cards = new List<Stripe.Card>();
		//Stripe.PaymentMethods paymentMethods = stripeService.getPaymentMethods(contact.Id);
		//cards = paymentMethods.cards;
        transactionController.initCards();

        List<Stripe.Card> cards = transactionController.cards;

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
        System.assertEquals('cus_G5i0UDob8XanSl', [SELECT Id, StripeCustomerId__c FROM Contact WHERE Id = :contact.Id].StripeCustomerId__c);
    }
    
    @IsTest
    static void testFailedTrasactionpayment_expired() {
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
        	paymentRequest.Status__c = 'payment_expired';
        	update paymentRequest;
		    PageReference pageRef = Page.StripePaymentPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('reqid', paymentRequest.UUID__c);
            TransactionController transactionController = new TransactionController();
        
            System.assertEquals(paymentRequest.Amount__c, transactionController.paymentRequests[0].Amount__c);
    }
    
    @IsTest
    static void testFailedTrasactionpayment_done() {
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
        	paymentRequest.Status__c = 'payment_done';
        	update paymentRequest;
        	Transaction__c txn = transactionService.createTransaction(paymentRequest);
        	txn.Status__c = 'succeeded';
        	update txn;
		    PageReference pageRef = Page.StripePaymentPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('reqid', paymentRequest.UUID__c);
            TransactionController transactionController = new TransactionController();
        
            System.assertEquals(paymentRequest.Amount__c, transactionController.paymentRequests[0].Amount__c);
    }

    @IsTest
    static void charge_givenNewCardWithSaveEnabled_thenChargesOnNewCard() {
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
        

        Transaction__c txn = transactionService.createTransaction(paymentRequest);
        txn.StripeChargeId__c = 'ch_1FWEhYDQBrpdxQCKCGLUUXsP';
		txn.Status__c = 'succeeded';
        update txn;
        System.assertEquals('cus_G5i0UDob8XanSl', contact.StripeCustomerId__c);

        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeChargeSuccess');

        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);

        PageReference pageRef = Page.StripePaymentPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', paymentRequest.UUID__c);

        TransactionController transactionController = new TransactionController();
		transactionController.paymentRequests.add(paymentRequest);
		Stripe.UserPaymentRequest stripePaymentRequest = new Stripe.UserPaymentRequest();
        stripePaymentRequest.selectedPaymentSource = '';
        transactionController.stripePaymentRequestJson = '{"selectedPaymentSource":""}';
        transactionController.charge();

        Transaction__c saved_txn = transactionService.getTransaction(txn.Id);

        System.assertEquals('succeeded', saved_txn.Status__c);
        System.assertEquals('Transaction successful', saved_txn.StatusMessage__c);
        System.assertEquals('ch_1FWEhYDQBrpdxQCKCGLUUXsP', saved_txn.StripeChargeId__c);
        System.assertEquals(0, saved_txn.AmountRefunded__c);
        System.assertEquals(null, saved_txn.FailureCode__c);
        System.assertEquals(null, saved_txn.FailureMessage__c);
        System.assert(saved_txn.TransactionDate__c != null);
        System.assertEquals('card', saved_txn.PaymentMethodType__c);
        System.assertEquals('card_2JZWVCDQBrpdxQCKwNKVLJq3', saved_txn.PaymentMethod__c);
        System.assertEquals('9876', saved_txn.PaymentCardLast4Digits__c);

        Payment_Intent__c savedPaymentRequest = [SELECT Id, Status__c FROM Payment_Intent__c WHERE Id = :paymentRequest.Id];
        System.assertEquals('payment_done', savedPaymentRequest.Status__c);
    }

    @IsTest
    static void testrefreshStripeError() {
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        Contact fetchContact = getcurrAccount.Contacts[0];
        User cuser = PMA_SearchController.fetchCurrentUser();
        cuser.ContactId__c = fetchContact.Id;
        update cuser;

        Payment_Intent__c paymentRequest = PaymentIntentService.createNewPaymentIntent(
                'Test Payment Request',
                fetchContact.Id,
                getcurrAccount.Id,
                null,
                'immediate',
                Double.valueOf(23.4),
                'sample@gmail.com',
                'single',
                System.TODAY());

        PageReference pageRef = Page.StripePaymentPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', paymentRequest.UUID__c);

        TransactionController transactionController = new TransactionController();
        transactionController.paymentRequests.add(paymentRequest);
        transactionController.stripeError = 'Your card has insufficient funds.';
        transactionController.refreshStripeError();
        System.assertEquals('Your card has insufficient funds.', transactionController.stripeError);
    }

    @IsTest
    static void testresetStripeError() {
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        Contact fetchContact = getcurrAccount.Contacts[0];
        User cuser = PMA_SearchController.fetchCurrentUser();
        cuser.ContactId__c = fetchContact.Id;
        update cuser;

        Payment_Intent__c paymentRequest = PaymentIntentService.createNewPaymentIntent(
                'Test Payment Request',
                fetchContact.Id,
                getcurrAccount.Id,
                null,
                'immediate',
                Double.valueOf(23.4),
                'sample@gmail.com',
                'single',
                System.TODAY());

        PageReference pageRef = Page.StripePaymentPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', paymentRequest.UUID__c);

        TransactionController transactionController = new TransactionController();
        transactionController.paymentRequests.add(paymentRequest);
        transactionController.stripeError = 'Your card has insufficient funds.';
        transactionController.resetStripeError();
        System.assertEquals(null, transactionController.stripeError);
    }

	@IsTest
    static void charge_Catch_JSONException() {
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
        

        Transaction__c txn = transactionService.createTransaction(paymentRequest);
        txn.StripeChargeId__c = 'ch_1FWEhYDQBrpdxQCKCGLUUXsP';
		txn.Status__c = 'succeeded';
        update txn;
        System.assertEquals('cus_G5i0UDob8XanSl', contact.StripeCustomerId__c);

        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeChargeSuccess');

        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);

        PageReference pageRef = Page.StripePaymentPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reqid', paymentRequest.UUID__c);

        TransactionController transactionController = new TransactionController();
		transactionController.paymentRequests.add(paymentRequest);
		Stripe.UserPaymentRequest stripePaymentRequest = new Stripe.UserPaymentRequest();
        stripePaymentRequest.selectedPaymentSource = '';
        transactionController.stripePaymentRequestJson = '{"Account":"","Contact":""}';
        transactionController.charge();

        Transaction__c saved_txn = transactionService.getTransaction(txn.Id);

        System.assertEquals('succeeded', saved_txn.Status__c);
        System.assertEquals('Transaction successful', saved_txn.StatusMessage__c);
        System.assertEquals('ch_1FWEhYDQBrpdxQCKCGLUUXsP', saved_txn.StripeChargeId__c);
        System.assertEquals(0, saved_txn.AmountRefunded__c);
        System.assertEquals(null, saved_txn.FailureCode__c);
        System.assertEquals(null, saved_txn.FailureMessage__c);
        System.assert(saved_txn.TransactionDate__c != null);
        System.assertEquals('card', saved_txn.PaymentMethodType__c);
        System.assertEquals('card_2JZWVCDQBrpdxQCKwNKVLJq3', saved_txn.PaymentMethod__c);
        System.assertEquals('9876', saved_txn.PaymentCardLast4Digits__c);

        Payment_Intent__c savedPaymentRequest = [SELECT Id, Status__c FROM Payment_Intent__c WHERE Id = :paymentRequest.Id];
        System.assertEquals('payment_done', savedPaymentRequest.Status__c);
    }
}