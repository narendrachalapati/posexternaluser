@IsTest
public class TransactionServiceTest {
	private static TransactionService transactionService = new TransactionService();
	private static StripeService stripeService = new StripeService();
    
    @TestSetup
    static void TransactionServiceTest() {
            PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
    }  
    
    @IsTest
    static void createTransactionTest(){
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
        Transaction__c txn = transactionService.createTransaction(paymentRequest);
        txn.StripeChargeId__c = 'ch_1FWEhYDQBrpdxQCKCGLUUXsP';
        txn.UUID__c = 'MDa3wwxOad5TpQHaNH9k9XCgUgXhQXa';
        txn.Status__c = 'succeeded';
        update txn;
        Transaction__c fetchtxn = transactionService.getTransactionByChargeId(txn.StripeChargeId__c);
        System.assertEquals('MDa3wwxOad5TpQHaNH9k9XCgUgXhQXa', fetchtxn.UUID__c);
        System.assertEquals('ch_1FWEhYDQBrpdxQCKCGLUUXsP', fetchtxn.StripeChargeId__c);
    }
    
    @IsTest
    static void getTransactionByUuidTest(){
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
        Transaction__c txn = transactionService.createTransaction(paymentRequest);
        txn.StripeChargeId__c = 'ch_1FWEhYDQBrpdxQCKCGLUUXsP';
        txn.UUID__c = 'MDa3wwxOad5TpQHaNH9k9XCgUgXhQXa';
        txn.Status__c = 'succeeded';
        update txn;
        Transaction__c fetchtxn = transactionService.getTransactionByUuid(txn.UUID__c);
        System.assertEquals('MDa3wwxOad5TpQHaNH9k9XCgUgXhQXa', fetchtxn.UUID__c);
        System.assertEquals('ch_1FWEhYDQBrpdxQCKCGLUUXsP', fetchtxn.StripeChargeId__c);
    }
    
}