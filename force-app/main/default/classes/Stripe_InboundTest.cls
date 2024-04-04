@isTest
public class Stripe_InboundTest {
	private static TransactionService transactionService = new TransactionService();
	private static StripeService stripeService = new StripeService();
    @TestSetup
    static void Stripe_InboundTest() {
        Account account = new Account(Name = 'Sample Account');
        insert account;
		
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = account.Id,StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(account.Id);

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
    }   
}