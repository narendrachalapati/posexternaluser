@IsTest
public with sharing class MapProductWithGoogleCalendarTest {
    
    @TestSetup
    static void MapProductWithGoogleCalendarTest() {
        List < Account > accts = new List < Account > ();
        for (Integer i = 0; i < 3; i++) {
            Account a = new Account(Name = 'PMA Test Account' + i);
            accts.add(a);
        }
        insert accts;
    }

    @IsTest
    static void getProductDetailsTest() {
        Account getcurrAccount = [SELECT Id, Name FROM Account LIMIT 1];

        SYS_OAuthConfig__c oauthRecord = new SYS_OAuthConfig__c();
        oauthRecord.Name = 'TestAccount';
        oauthRecord.Account__c = getcurrAccount.Id;
        oauthRecord.Client_Id__c = 'testPublicKey';
        oauthRecord.Access_Token__c = 'testAccessToken';
        oauthRecord.Test_Mode__c = true;
        oauthRecord.Grant_Type__c = 'authorization_code';
        oauthRecord.Integration_Type__c = 'Stripe';
        oauthRecord.Token_type__c = 'Bearer';
        oauthRecord.Config_ID__c = 'SYSOAUTH-' + Integer.valueof((Math.random() * 1000));
        insert oauthRecord;


        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);

        Product__c product = new Product__c();
        product.Name = 'Golf Simulator';
        product.Unit_Price__c = 12.5;
        product.Active__c = true;
        product.Account__c = getcurrAccount.Id;
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '60';
        insert product;
        Test.starttest();
        Product__c prodRecord = MapProductWithGoogleCalendar.getProductDetails(product.Id);
        System.assertEquals(prodRecord.Name, 'Golf Simulator');
        Test.stoptest();
    }

    @IsTest
    static void getProductDetailsExceptionTest() {
        Account getcurrAccount = [SELECT Id, Name FROM Account LIMIT 1];

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        Product__c product = new Product__c();
        product.Name = 'Golf Simulator';
        product.Unit_Price__c = 12.5;
        product.Active__c = true;
        product.Account__c = getcurrAccount.Id;
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '60';
        product.Google_Booking_Calendar_Id__c = 'tesing';
        insert product;
        Test.starttest();
        try {
            Product__c prodRecord = MapProductWithGoogleCalendar.getProductDetails(NULL);
            System.assertEquals(prodRecord, new Product__c());
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage() != null);
        }

        Test.stoptest();
    }

    @IsTest
    static void ListofCalendarsTest() {
        Test.starttest();
        Account getcurrAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Boolean isAccountBasedMapper = true;
        String accountRecordId = getcurrAccount.Id;
        SYS_DataCacheFactory init = new SYS_DataCacheFactory(
            accountRecordId,
            'Calendar',
            'Calendar',
            null
        );
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        Product__c product = new Product__c();
        product.Name = 'Cheese Burger';
        product.Unit_Price__c = 12.5;
        product.Active__c = true;
        product.Account__c = getcurrAccount.Id;
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '60';
        product.Google_Booking_Calendar_Id__c = 'tesing';
        insert product;


        List < Google_Calendar__c > cclist = new List < Google_Calendar__c > ();
        Google_Calendar__c shiftcc = new Google_Calendar__c();
        shiftcc.Calendar_Name__c = 'Shift Customcalendartest';
        shiftcc.TimeZone__c = 'Asia/Kolkata';
        shiftcc.Google_Calendar_Id__c = 'ShiftexCalenderKey';
        shiftcc.Account__c = getcurrAccount.Id;
        shiftcc.Calendar_Type__c = 'Shift Calendar';
        shiftcc.Active__c = true;
        cclist.add(shiftcc);

        Datetime currentDatetime = Datetime.now();
        Datetime expiryDateTime = currentDatetime.addDays(30);

        for (Integer i = 0; i < 5; i++) {
            Google_Calendar__c cc = new Google_Calendar__c();
            cc.Calendar_Name__c = 'Customcalendartest' + i;
            cc.TimeZone__c = 'Asia/Kolkata';
            cc.Google_Calendar_Id__c = 'exCalenderKey' + i;
            cc.PMA_Product__c = product.Id;
            cc.Account__c = getcurrAccount.Id;
            cc.Calendar_Type__c = 'Booking Calendar';//	Shift Calendar
            cc.Active__c = true;
            cc.Watch_Event_Expiry__c = expiryDateTime;
            cc.Watch_Event_Resource_URI__c = 'https://www.googleapis.com/calendar/v3/calendars/test@group.calendar.google.com/events?alt=json';
            cclist.add(cc);
        }
        insert cclist;

        List < Google_Calendar__c > calendarlist = MapProductWithGoogleCalendar.ListofCalendars(isAccountBasedMapper, accountRecordId);
        System.assert(calendarlist.size() > 0);
        Test.stoptest();
    }

    @IsTest
    static void updateProductWithShiftCalenderKeyTest() {
        Account getcurrAccount = [SELECT Id, Name FROM Account LIMIT 1];
        String calendarType = 'Shift';
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        Product__c product = new Product__c();
        product.Name = 'Golf Simulator';
        product.Unit_Price__c = 12.5;
        product.Active__c = true;
        product.Account__c = getcurrAccount.Id;
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '60';
        // product.Google_Booking_Calendar_Id__c = 'tesing';
        // product.Google_Shift_Calendar_Id__c = 'tesing';
        insert product;
        Test.starttest();

        Google_Calendar__c cc = new Google_Calendar__c();
        cc.Calendar_Name__c = 'Customcalendartest';
        cc.TimeZone__c = 'Asia/Kolkata';
        cc.Account__c = getcurrAccount.Id;
        cc.Calendar_Type__c = 'Shift Calendar';//	Shift Calendar
        cc.Google_Calendar_Id__c = 'tesing';
        cc.Active__c = true;
        insert cc;

        Product__c updateprodid = MapProductWithGoogleCalendar.updateProductWithCalendarKey(calendarType, product.Id, cc.Google_Calendar_Id__c, cc.Id);
        System.assert(updateprodid != null);
        Test.stoptest();
    }

    @IsTest
    static void updateProductWithBookingCalenderKeyTest() {
        Account getcurrAccount = [SELECT Id, Name FROM Account LIMIT 1];
        String calendarType = 'Booking';
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        Product__c product = new Product__c();
        product.Name = 'Golf Simulator';
        product.Unit_Price__c = 12.5;
        product.Active__c = true;
        product.Account__c = getcurrAccount.Id;
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '60';
        // product.Google_Booking_Calendar_Id__c = 'tesing';
        // product.Google_Shift_Calendar_Id__c = 'tesing';
        insert product;
        Test.starttest();

        Datetime currentDatetime = Datetime.now();
        Datetime expiryDateTime = currentDatetime.addDays(30);

        Google_Calendar__c cc = new Google_Calendar__c();
        cc.Calendar_Name__c = 'Customcalendartest';
        cc.TimeZone__c = 'Asia/Kolkata';
        cc.PMA_Product__c = product.Id;
        cc.Account__c = getcurrAccount.Id;
        cc.Active__c = true;
        cc.Calendar_Type__c = 'Booking Calendar';//	Shift Calendar
        cc.Google_Calendar_Id__c = 'tesing';
        cc.Watch_Event_Expiry__c = expiryDateTime;
        cc.Watch_Event_Resource_URI__c = 'https://www.googleapis.com/calendar/v3/calendars/test@group.calendar.google.com/events?alt=json';
        insert cc;

        Product__c updateprodid = MapProductWithGoogleCalendar.updateProductWithCalendarKey(calendarType, product.Id, cc.Google_Calendar_Id__c, cc.Id);
        System.assert(updateprodid != null);
        Test.stoptest();
    }

    @IsTest
    static void updateProductWithCalenderKeyExceptionTest() {
        Account getcurrAccount = [SELECT Id, Name FROM Account LIMIT 1];
        String calendarType = 'Booking';
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        Product__c product = new Product__c();
        product.Name = 'Golf Simulator';
        product.Unit_Price__c = 12.5;
        product.Active__c = true;
        product.Account__c = getcurrAccount.Id;
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '60';
        product.Google_Booking_Calendar_Id__c = 'tesing';
        insert product;
        Test.starttest();
        try {

            Product__c createprod = new Product__c();
            createprod.Name = 'testproduct';
            createprod.Unit_Price__c = 12.5;
            createprod.Active__c = true;
            createprod.Account__c = getcurrAccount.Id;
            createprod.UUID__c = guid;
            createprod.Allow_scheduling__c = true;
            createprod.TimeZone__c = 'Asia/Kolkata';
            createprod.Meet_Duration__c = '60';
            // createprod.Google_Booking_Calendar_Id__c = 'tesing123';
            insert createprod;

            Google_Calendar__c cc = new Google_Calendar__c();
            cc.Calendar_Name__c = 'Customcalendartest';
            cc.TimeZone__c = 'Asia/Kolkata';
            cc.PMA_Product__c = createprod.Id;
            cc.Account__c = getcurrAccount.Id;
            cc.Active__c = true;
            cc.Calendar_Type__c = 'Booking Calendar';//	Shift Calendar
            cc.Google_Calendar_Id__c = 'tesing123';
            insert cc;

            Product__c updateprodid = MapProductWithGoogleCalendar.updateProductWithCalendarKey(calendarType, NULL, cc.Google_Calendar_Id__c, cc.Id);
            System.assert(updateprodid != null);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage() != null);
        }
        Test.stoptest();
    }

    @IsTest
    static void createCustomCalendarTest() {
        Test.starttest();
        Account getcurrAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Boolean isAccountBasedMapper = true;
        String accountRecordId = getcurrAccount.Id;
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        Product__c product = new Product__c();
        product.Name = 'Golf Simulator';
        product.Unit_Price__c = 12.5;
        product.Active__c = true;
        product.Account__c = getcurrAccount.Id;
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '60';
        product.Google_Booking_Calendar_Id__c = 'tesing';
        insert product;
        try {
            Google_Calendar__c customcalendar = MapProductWithGoogleCalendar.createCustomCalendar(isAccountBasedMapper, accountRecordId, 'createCustomcalender', product.Id, 'Booking Calendar', 'Asia/Kolkata');
            System.assertEquals(customcalendar.Calendar_Name__c, 'createCustomcalender');
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage() != null);
        }
        Test.stoptest();
    }

    @IsTest
    static void createCustomCalendarExceptionTest() {
        Test.starttest();
        Account getcurrAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Boolean isAccountBasedMapper = true;
        String accountRecordId = getcurrAccount.Id;

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        Product__c product = new Product__c();
        product.Name = 'Golf Simulator';
        product.Unit_Price__c = 12.5;
        product.Active__c = true;
        product.Account__c = getcurrAccount.Id;
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '60';
        product.Google_Booking_Calendar_Id__c = 'tesing';
        insert product;
        try {
            Google_Calendar__c customcalendar = MapProductWithGoogleCalendar.createCustomCalendar(isAccountBasedMapper, accountRecordId,'createCustomcalender', 'InvalidId', 'Booking Calendar', 'Asia/Kolkata');
            System.assertEquals(customcalendar.Calendar_Name__c, 'createCustomcalender');
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage() != null);
        }
        Test.stoptest();
    }
}