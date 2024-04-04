@isTest
public with sharing class DialogueFlow_InboundTest {

    public static String getProductWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://get_products.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getMemberWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://get_member.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getUpsertMemberWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://upsert_member.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getAvailabilityWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://get_availability.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getFetchupcomingAppointmentWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://fetchupcomingappointment.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getFetchCancelAppointmentWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://cancelappointment.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getNotificationApiWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://DF_send_verification_code.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getSchedulingLinkWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://DF_send_appointment_scheduling_text.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static String getProfileLinkWebhook(){
        
        Test.setMock(HttpCalloutMock.class, DialogueFlow_MockServer.startServer());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://DF_update_profile.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }

    public static Boolean personAccountsEnabled() {
        return Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
    }

    public static void createTestRecords(Integer numAccts, Integer numContactsPerAcct){
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account();
            if(!personAccountsEnabled()) {
                a.put('Name', 'Municorn Test Account' + i);
            } else {
                a.put('LastName', 'Municorn Test Account' + i);
            }
            a.UUID__c = SYS_Helper.getUUID();
            accts.add(a);
        }
        insert accts;

        List<SYS_Integration_Metadata__c> metadata = new List<SYS_Integration_Metadata__c>();
        List<SYS_OAuthConfig__c> authrecords = new List<SYS_OAuthConfig__c>();
        for(Account acc:accts) {

            SYS_OAuthConfig__c oauthRecord = new SYS_OAuthConfig__c();
            oauthRecord.Name = 'TestAccount';
            oauthRecord.Account__c = acc.Id;
            oauthRecord.Client_Id__c = 'testPublicKey';
            oauthRecord.Access_Token__c = 'testAccessToken';
            oauthRecord.Test_Mode__c = true;
            oauthRecord.Grant_Type__c = 'authorization_code';
            oauthRecord.Integration_Type__c = 'Calendar';
            oauthRecord.Token_type__c = 'Bearer';
            oauthRecord.Config_ID__c = 'SYSOAUTH-' + Integer.valueof((Math.random() * 1000));
            authrecords.add(oauthRecord);
            
            SYS_Integration_Metadata__c md = new SYS_Integration_Metadata__c();
            md.Integration_Type__c = 'MemberAndServicesAPI';
            md.Key__c = 'int-set';
            md.Value__c = 'MemberAndServicesAPI';
            md.Account__c = acc.Id;
            metadata.add(md);
            SYS_Integration_Metadata__c md1 = new SYS_Integration_Metadata__c();
            md1.Integration_Type__c = 'MemberUpsertAPI';
            md1.Key__c = 'int-set';
            md1.Value__c = 'MemberUpsertAPI';
            md1.Account__c = acc.Id;
            metadata.add(md1);
            SYS_Integration_Metadata__c md2 = new SYS_Integration_Metadata__c();
            md2.Integration_Type__c = 'SchedulingAPI';
            md2.Key__c = 'int-set';
            md2.Value__c = 'SchedulingAPI';
            md2.Account__c = acc.Id;

            metadata.add(md2);

            SYS_Integration_Metadata__c md3 = new SYS_Integration_Metadata__c();
            md3.Integration_Type__c = 'NotificationAPI';
            md3.Key__c = 'int-set';
            md3.Value__c = 'NotificationAPI';
            md3.Account__c = acc.Id;

            metadata.add(md3);

            SYS_Integration_Metadata__c md4 = new SYS_Integration_Metadata__c();
            md4.Integration_Type__c = 'Calendar';
            md4.Key__c = 'int-set';
            md4.Value__c = 'Calendar';
            md4.Account__c = acc.Id;

            metadata.add(md4);
        }
        
        insert metadata;
        insert authrecords;
        
        
        List<Contact> cons = new List<Contact>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];            
            // For each account just inserted, add contacts
            // for (Integer k=numContactsPerAcct*j;k<numContactsPerAcct*(j+1);k++) {
            for (Integer k=0 ; k<numContactsPerAcct ; k++) {
                cons.add(new Contact(firstname='Municorn'+k,
                                     lastname='Test Contact'+k,
                                     AccountId=acct.Id));
            }
        }
        // Insert all contacts for all accounts
        insert cons;

    }

    public static void createProduct(String accountId) {
        createTestProductRecord(accountId, 'shiftCalendarExId', 'bookingCalendarExId', true, true);
    }

    public static void createProductUUID(String accountId, String uuid) {
        Product__c prod = createTestProductRecord(accountId, 'shiftCalendarExId', 'bookingCalendarExId', true, false);
        prod.UUID__c = uuid;

        insert prod;
    }

    public static Product__c createTestProductRecord(Id accountRecordId, String shiftCalendarExId, String bookingCalendarExId, Boolean insertExternalId, Boolean doInsert){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000

        //Create one Scheduling Product
        Product__c BookingProduct = new Product__c();
        BookingProduct.Account__c = accountRecordId;
        BookingProduct.Name = 'Consultation';
        BookingProduct.Unit_Price__c = 12.5;
        BookingProduct.Active__c = true;
        BookingProduct.UUID__c = guid;
        BookingProduct.Allow_scheduling__c = true;
        BookingProduct.TimeZone__c = 'America/Los_Angeles';
        BookingProduct.Meet_Duration__c = '60';
        BookingProduct.Minimum_Lead_Time__c = '15';
        BookingProduct.Product_Family__c = 'Scheduling';
        if(insertExternalId){
            BookingProduct.Google_Shift_Calendar_Id__c = String.isNotBlank(shiftCalendarExId) ? shiftCalendarExId : ('exCalenderKeyBooking' + IntrandomNumber);
            BookingProduct.Google_Booking_Calendar_Id__c = String.isNotBlank(bookingCalendarExId) ? bookingCalendarExId : ('exCalenderKeyBooking' + IntrandomNumber);
        }
        if(doInsert){
            insert BookingProduct;
        }
        return BookingProduct;
    }

    @isTest
    static void testProductsServices() {
        String body = getProductWebhook();

        createTestRecords(1, 1);
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
        createProduct(accounts[0].Id);
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/MemberAndServicesAPI';
        request.addParameter('token', '8KW2sKpWAD');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }

    @isTest
    static void testMemberFind() {
        String body = getMemberWebhook();

        createTestRecords(1, 1);
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
        createProduct(accounts[0].Id);
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/MemberAndServicesAPI';
        request.addParameter('token', '8KW2sKpWAD');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }

    @isTest
    static void testMemberFindExistingMember() {
        String body = getMemberWebhook();

        createTestRecords(1, 1);
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Contact con = new Contact(firstname='john',
                                     lastname='doe',
                                     Birthdate= Date.newInstance(1990,01,01),
                                     AccountId=accounts[0].Id);
        insert con;
        createProduct(accounts[0].Id);
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/MemberAndServicesAPI';
        request.addParameter('token', '8KW2sKpWAD');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }

    @isTest
    static void testMemberUpsertApi() {
        String body = getUpsertMemberWebhook();

        createTestRecords(1, 1);
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Contact con = new Contact(firstname='James',
                                     lastname='Gunn',
                                     Birthdate= Date.newInstance(1995,01,01),
                                     UUID__c='0039H000007shtbQAA-sdhjsjdhsjdh',
                                     AccountId=accounts[0].Id);
        insert con;
        createProduct(accounts[0].Id);
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/MemberUpsertAPI';
        request.addParameter('token', '8KW2sKpWS2');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }

    @isTest
    static void testMemberUpsertApi_NonAccountModel() {
        String body = getUpsertMemberWebhook();

        createTestRecords(1, 1);
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Account acc = new Account(Name='James Gunn',
                                    First_Name__c='James',
                                     Last_Name__c='Gunn',
                                     Date_of_Birth__c= Date.newInstance(1995,01,01),
                                     UUID__c='0039H000007shtbQAA-sdhjsjdhsjdh');
        insert acc;
        createProduct(accounts[0].Id);
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/MemberUpsertAPI';
        request.addParameter('token', '8KW2sKpWS2');
        // request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }

    @isTest
    static void testSchedulingApiForAvailability() {
        String body = getAvailabilityWebhook();

        createTestRecords(1, 1);
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Contact con = new Contact(firstname='James',
                                     lastname='Gunn',
                                     Birthdate= Date.newInstance(1995,01,01),
                                     UUID__c='0039H000007shtbQAA-sdhjsjdhsjdh',
                                     AccountId=accounts[0].Id);
        insert con;
        createProductUUID(accounts[0].Id, '0039H000007shtbQAA-sdhjsjdhsjdh-service');
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SchedulingAPI';
        request.addParameter('token', 'EQW3212aAZ9');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }

    @isTest
    static void testgetFetchupcomingAppointmentWebhook() {
        String body = getFetchupcomingAppointmentWebhook();

        createTestRecords(1, 1);
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Contact con = new Contact(firstname='James',
                                     lastname='Gunn',
                                     Birthdate= Date.newInstance(1995,01,01),
                                     UUID__c='0039H000007shtbQAA-sdhjsjdhsjdh',
                                     AccountId=accounts[0].Id);
        insert con;
        createProductUUID(accounts[0].Id, '0039H000007shtbQAA-sdhjsjdhsjdh-service');
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SchedulingAPI';
        request.addParameter('token', 'EQW3212aAZ9');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }

    @isTest
    static void testgetFetchCancelAppointmentWebhook() {
        String body = getFetchCancelAppointmentWebhook();

        createTestRecords(1, 1);
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Contact con = new Contact(firstname='James',
                                     lastname='Gunn',
                                     Birthdate= Date.newInstance(1995,01,01),
                                     UUID__c='0039H000007shtbQAA-sdhjsjdhsjdh',
                                     AccountId=accounts[0].Id);
        insert con;
        createProductUUID(accounts[0].Id, '0039H000007shtbQAA-sdhjsjdhsjdh-service');
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/SchedulingAPI';
        request.addParameter('token', 'EQW3212aAZ9');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }

    @isTest
    static void testgetNotificationApiWebhook() {
        String body = getNotificationApiWebhook();

        createTestRecords(1, 1);
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Contact con = new Contact(firstname='James',
                                     lastname='Gunn',
                                     Birthdate= Date.newInstance(1995,01,01),
                                     UUID__c='0039H000007shtbQAA-sdhjsjdhsjdh',
                                     AccountId=accounts[0].Id);
        insert con;
        createProductUUID(accounts[0].Id, '0039H000007shtbQAA-sdhjsjdhsjdh-service');
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/NotificationAPI';
        request.addParameter('token', '8KW2sASD234');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    }   

    @isTest
    static void testSchedulingLinkWebhook() {
        String body = getSchedulingLinkWebhook();

        createTestRecords(1, 1);
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Contact con = new Contact(firstname='James',
                                     lastname='Gunn',
                                     Birthdate= Date.newInstance(1995,01,01),
                                     UUID__c='0039H000007shtbQAA-sdhjsjdhsjdh',
                                     AccountId=accounts[0].Id);
        insert con;
        createProductUUID(accounts[0].Id, '0039H000007shtbQAA-sdhjsjdhsjdh-service');
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/NotificationAPI';
        request.addParameter('token', '8KW2sASD234');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    } 

    @isTest
    static void testProfileLinkWebhook() {
        String body = getProfileLinkWebhook();

        createTestRecords(1, 1);
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        
        List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];

        Contact con = new Contact(firstname='James',
                                     lastname='Gunn',
                                     Birthdate= Date.newInstance(1995,01,01),
                                     UUID__c='0039H000007shtbQAA-sdhjsjdhsjdh',
                                     AccountId=accounts[0].Id);
        insert con;
        createProductUUID(accounts[0].Id, '0039H000007shtbQAA-sdhjsjdhsjdh-service');
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/NotificationAPI';
        request.addParameter('token', '8KW2sASD234');
        request.addParameter('key', accounts[0].UUID__c);
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = actualres;
        
        Test.startTest();
        SYS_Webservice.postRequest();
        Test.stopTest();
    } 
}