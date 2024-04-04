@IsTest
public class AppointmentSchedulingServiceTest {
    @IsTest
    static void testcreateNewAppointment() {
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        String shiftCalendarExId = ('exCalenderKeyShift' + IntrandomNumber);
        String bookingCalendarExId = ('exCalenderKeyBooking' + IntrandomNumber);
        Id BookingProductId = null;
        String calendarType = 'Booking';

        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();
        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        Google_Calendar__c shiftCalendarRec = Scheduling_TestDataFactory.createTestShiftCalendarRecord(acc.Id, shiftCalendarExId, true, true);
        Google_Calendar__c bookingCalendarRec = Scheduling_TestDataFactory.createTestBookingCalendarRecord(acc.Id, BookingProductId, bookingCalendarExId, true, true);
        Product__c schedulingProductRec = Scheduling_TestDataFactory.createTestProductRecord(acc.Id, shiftCalendarExId, bookingCalendarExId, true, true);
        Product__c updateprodWithBookingCalendarId = MapProductWithGoogleCalendar.updateProductWithCalendarKey(calendarType,schedulingProductRec.Id, bookingCalendarExId, '');

        String appointmentTitle = 'Test New' + schedulingProductRec.Name + ' Appointment';
        Datetime currentDatetime = Datetime.now();
        Datetime appointmentStartDateTime = currentDatetime.addMinutes(60);
        Datetime appointmentEndDateTime = currentDatetime.addMinutes(60);
        String meetDuration = '30';
        String appointmentDescription = 'Appointment For '+ schedulingProductRec.Name;
        Id accountId = acc.Id;
        Id contactId = contactRec.Id;
        Id productId = schedulingProductRec.Id;
        String emails = 'dev@adisols.com';
        String bookingcalendarId = bookingCalendarExId;
        String googleCalendarEventId;
        String googleCalendarEventStatus = 'confirmed';
        String googleCalendarEventTimezone = 'America/Los_Angeles';
        String scheduledUserTimezone = 'America/Los_Angeles';
        Boolean IsActive = true;
        Appointment_Scheduling__c apptRec = AppointmentSchedulingService.createNewAppointment( appointmentTitle, appointmentStartDateTime, appointmentEndDateTime, meetDuration, appointmentDescription, accountId, contactId, productId, emails, bookingcalendarId, googleCalendarEventId, googleCalendarEventStatus, googleCalendarEventTimezone, scheduledUserTimezone, IsActive);
        System.assert(apptRec != null);    
    }

    @IsTest
    static void testgetAppointmentDetailsById() {
        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();
        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        
        String appointmentTitle = 'Test New Appointment Demo Max length reached Title handling truncation of excess words';
        Datetime currentDatetime = Datetime.now();
        Datetime appointmentStartDateTime = currentDatetime.addMinutes(60);
        Datetime appointmentEndDateTime = currentDatetime.addMinutes(60);
        String meetDuration = '30';
        String appointmentDescription = 'Test New Appointment';
        Id accountId = acc.Id;
        Id contactId = contactRec.Id;
        Id productId = null;
        String emails = 'dev@adisols.com';
        String bookingcalendarId = '';
        String googleCalendarEventId = 'test3333';
        String googleCalendarEventStatus = 'confirmed';
        String googleCalendarEventTimezone = 'America/Los_Angeles';
        String scheduledUserTimezone = 'America/Los_Angeles';
        Boolean IsActive = true;
        Appointment_Scheduling__c apptRec = AppointmentSchedulingService.createNewAppointment( appointmentTitle, appointmentStartDateTime, appointmentEndDateTime, meetDuration, appointmentDescription, accountId, contactId, productId, emails, bookingcalendarId, googleCalendarEventId, googleCalendarEventStatus, googleCalendarEventTimezone, scheduledUserTimezone, IsActive);

        String IdorUuid = apptRec.Id;
        Test.startTest();
        Appointment_Scheduling__c fetchAppointment = AppointmentSchedulingService.getAppointmentDetails(IdorUuid);
        Test.stopTest();
        System.assert(apptRec != null);   
    }

    @IsTest
    static void testgetAppointmentDetailsByUUId() {
        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();
        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        
        String appointmentTitle = 'Test New Appointment';
        Datetime currentDatetime = Datetime.now();
        Datetime appointmentStartDateTime = currentDatetime.addMinutes(60);
        Datetime appointmentEndDateTime = currentDatetime.addMinutes(60);
        String meetDuration = '30';
        String appointmentDescription = 'Test New Appointment';
        Id accountId = acc.Id;
        Id contactId = contactRec.Id;
        Id productId = null;
        String emails = 'dev@adisols.com';
        String bookingcalendarId = '';
        String googleCalendarEventId = 'test222';
        String googleCalendarEventStatus = 'confirmed';
        String googleCalendarEventTimezone = 'America/Los_Angeles';
        String scheduledUserTimezone = 'America/Los_Angeles';
        Boolean IsActive = true;
        Appointment_Scheduling__c apptRec = AppointmentSchedulingService.createNewAppointment( appointmentTitle, appointmentStartDateTime, appointmentEndDateTime, meetDuration, appointmentDescription, accountId, contactId, productId, emails, bookingcalendarId, googleCalendarEventId, googleCalendarEventStatus, googleCalendarEventTimezone, scheduledUserTimezone, IsActive);

        String IdorUuid = apptRec.UUID__c;
        Test.startTest();
        Appointment_Scheduling__c fetchAppointment = AppointmentSchedulingService.getAppointmentDetails(IdorUuid);
        Test.stopTest();
        System.assert(apptRec != null);   
    }

    @IsTest
    static void testupdateAppointment() {
        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();
        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        
        String appointmentTitle = 'Test New Appointment';
        Datetime currentDatetime = Datetime.now();
        Datetime appointmentStartDateTime = currentDatetime.addMinutes(60);
        Datetime appointmentEndDateTime = currentDatetime.addMinutes(60);
        String meetDuration = '30';
        String appointmentDescription = 'Test New Appointment';
        Id accountId = acc.Id;
        Id contactId = contactRec.Id;
        Id productId = null;
        String emails = 'dev@adisols.com';
        String bookingcalendarId = null;
        String googleCalendarEventId = 'test123';
        String googleCalendarEventStatus = 'confirmed';
        String googleCalendarEventTimezone = 'America/Los_Angeles';
        String scheduledUserTimezone = 'America/Los_Angeles';
        Boolean IsActive = true;
        Appointment_Scheduling__c apptRec = AppointmentSchedulingService.createNewAppointment( appointmentTitle, appointmentStartDateTime, appointmentEndDateTime, meetDuration, appointmentDescription, accountId, contactId, productId, emails, bookingcalendarId, googleCalendarEventId, googleCalendarEventStatus, googleCalendarEventTimezone, scheduledUserTimezone, IsActive);

        Test.startTest();
        Appointment_Scheduling__c fetchAppointment = AppointmentSchedulingService.updateAppointment(apptRec);
        Test.stopTest();
        System.assert(apptRec != null);   
    }

}