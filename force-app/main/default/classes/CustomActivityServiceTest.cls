@IsTest
public class CustomActivityServiceTest {
	private static TransactionService transactionService = new TransactionService();
	private static StripeService stripeService = new StripeService();
    
    @TestSetup
    static void CustomActivityServiceTest() {
            PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
    }   
    @IsTest
    static void createNewSmsActivityTest(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        String recordId = (fetchContact.size()>0)? fetchContact[0].Id: null;
        System.debug('fetchContact test ' + fetchContact);
        String type = 'sms';
        List<String> mediaUrls = new List<String>();
        Boolean invokeOutboundFlow = true;
        String integrationSetting = 'Plivo';
        String fromPhone = ChatBotController.getDefaultPhoneNumber(integrationSetting);
        String toPhone = '9999999990';
		String email = 'dev@adisols.com';
        String messageSubject = 'Test Activity';
        String messageBody = 'Test Sms Content';
        
        Test.startTest();
		Activity__c accRec = CustomActivityService.createActivity(invokeOutboundFlow, type, mediaUrls, messageBody, messageSubject, fromPhone, toPhone, recordId);
        Test.stopTest();
        System.assertEquals('19999999990', accRec.Formatted_Phone__c);
    }
    
    @IsTest
    static void getActivityByUUIDTest(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        String recordId = (fetchContact.size()>0)? fetchContact[0].Id: null;
        System.debug('fetchContact test ' + fetchContact);
        String toPhone = '9999999990';
		String email = 'dev@adisols.com';
        String messageSubject = 'Test Activity';
        String messageBody = 'Test Sms Content';
        Test.startTest();
        StaticResourceCalloutMock plivommsMock = new StaticResourceCalloutMock();
		plivommsMock.setStaticResource('mockPlivoSMSDeliveredEvent');
        plivommsMock.setStatusCode(200);
        plivommsMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, plivommsMock);
        Boolean invokeOutboundFlow = true;
        String type = 'sms';
        List<String> mediaUrls = new List<String>();
        String integrationSetting = 'Plivo';
        String fromPhone = ChatBotController.getDefaultPhoneNumber(integrationSetting);
        Activity__c accRec = CustomActivityService.createActivity(invokeOutboundFlow, type, mediaUrls, messageBody, messageSubject, fromPhone, toPhone, recordId);

        Activity__c fetchActivity =  CustomActivityService.getActivityByUUID(accRec.UUID__c);
        Test.stopTest();
        
        System.assertEquals('19999999990', fetchActivity.Formatted_Phone__c);
    }
}