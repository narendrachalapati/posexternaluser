@IsTest
public class CalendarUtilityTest {

    @IsTest
    static void testcheckPageValidityNoMemberFound() {
        String uuid = SYS_Helper.getUUID();

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
        Product__c updateprodWithBookingCalendarId = MapProductWithGoogleCalendar.updateProductWithCalendarKey(calendarType, schedulingProductRec.Id, bookingCalendarExId, '');
        Test.startTest();
        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', contactRec.UUID__c);
        ApexPages.currentPage().getParameters().put('productuuid', schedulingProductRec.UUID__c);
        ApexPages.currentPage().getParameters().put('currentSessionId', uuid);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.checkPageValidity();
        Test.stopTest();
        System.assert(calendarUtil.memberuuid != null);          
    }

    @IsTest
    static void testcheckPageValidityNoMembers() {
        String uuid = SYS_Helper.getUUID();
        
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('currentSessionId', uuid);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.checkPageValidity();
        System.assert(calendarUtil.memberuuid == null);  
    }

    @IsTest
    static void testcheckPageValidityInvalidMemberParam() {
        String uuid = 'invaliduuid';
        
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', uuid);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.memberObjectApiName = null;
        calendarUtil.checkPageValidity();
        System.assert(calendarUtil.memberuuid != null);  
    }

    @IsTest
    static void testcheckFreeBusyonSelectedDate() {
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        String shiftCalendarExId = 'testshift@group.calendar.google.com';
        String bookingCalendarExId = 'testbooking@group.calendar.google.com';
        Id BookingProductId = null;

        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();
        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        Google_Calendar__c shiftCalendarRec = Scheduling_TestDataFactory.createTestShiftCalendarRecord(acc.Id, shiftCalendarExId, true, true);
        Google_Calendar__c bookingCalendarRec = Scheduling_TestDataFactory.createTestBookingCalendarRecord(acc.Id, BookingProductId, bookingCalendarExId, true, true);
        Product__c schedulingProductRec = Scheduling_TestDataFactory.createTestProductRecord(acc.Id, shiftCalendarExId, bookingCalendarExId, true, true);
        
        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', contactRec.UUID__c);
        ApexPages.currentPage().getParameters().put('productuuid', schedulingProductRec.UUID__c);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.selectedDisplayTimeZone = 'Asia/Kolkata';
        calendarUtil.displayTimeZone = 'Asia/Kolkata';
        calendarUtil.meetDuration = '60';

        Date dateMin = Date.newInstance(2070, 05, 16);
        Date dateMax = Date.newInstance(2070, 05, 17);
        Time dayStartTime = Time.newInstance(0, 0, 0, 0);
        Time dayEndTime = Time.newInstance(0, 0, 0, 0);
        DateTime startDatetimeVar = DateTime.newInstance(dateMin, dayStartTime);
        DateTime endDateTimeVar = DateTime.newInstance(dateMax, dayEndTime);
        calendarUtil.startDatetime = calendarUtil.formatDateTimetoISOString(startDatetimeVar);
        calendarUtil.endDateTime = calendarUtil.formatDateTimetoISOString(endDateTimeVar);
        Test.startTest();
        calendarUtil.checkFreeBusyonSelectedDate();
        System.assert(calendarUtil.freebusyResponseJson != null); 
        Test.stopTest();
    }

    @IsTest
    static void testcheckPageValidityInvalidProductUuid() {
        String uuid = SYS_Helper.getUUID();

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
        Product__c updateprodWithBookingCalendarId = MapProductWithGoogleCalendar.updateProductWithCalendarKey(calendarType, schedulingProductRec.Id, bookingCalendarExId, '');
        Test.startTest();
        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', contactRec.UUID__c);
        ApexPages.currentPage().getParameters().put('productuuid', uuid);
        ApexPages.currentPage().getParameters().put('currentSessionId', uuid);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.checkPageValidity();
        Test.stopTest();
        System.assert(calendarUtil.specificError != null);          
    }

    @IsTest
    static void testAccountcheckFreeBusyonSelectedDate() {
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        String shiftCalendarExId = 'testshift@group.calendar.google.com';
        String bookingCalendarExId = 'testbooking@group.calendar.google.com';
        Id BookingProductId = null;

        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();
        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        Google_Calendar__c shiftCalendarRec = Scheduling_TestDataFactory.createTestShiftCalendarRecord(acc.Id, shiftCalendarExId, true, true);
        Google_Calendar__c bookingCalendarRec = Scheduling_TestDataFactory.createTestBookingCalendarRecord(acc.Id, BookingProductId, bookingCalendarExId, true, true);
        Product__c schedulingProductRec = Scheduling_TestDataFactory.createTestProductRecord(acc.Id, shiftCalendarExId, bookingCalendarExId, true, true);
        
        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', acc.UUID__c);
        ApexPages.currentPage().getParameters().put('productuuid', schedulingProductRec.UUID__c);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.memberObjectApiName = 'Account';
        calendarUtil.selectedDisplayTimeZone = 'Asia/Kolkata';
        calendarUtil.displayTimeZone = 'Asia/Kolkata';
        calendarUtil.meetDuration = '60';
        calendarUtil.checkPageValidity();

        Date dateMin = Date.newInstance(2070, 05, 16);
        Date dateMax = Date.newInstance(2070, 05, 17);
        Time dayStartTime = Time.newInstance(0, 0, 0, 0);
        Time dayEndTime = Time.newInstance(0, 0, 0, 0);
        DateTime startDatetimeVar = DateTime.newInstance(dateMin, dayStartTime);
        DateTime endDateTimeVar = DateTime.newInstance(dateMax, dayEndTime);
        calendarUtil.startDatetime = calendarUtil.formatDateTimetoISOString(startDatetimeVar);
        calendarUtil.endDateTime = calendarUtil.formatDateTimetoISOString(endDateTimeVar);
        Test.startTest();
        calendarUtil.checkFreeBusyonSelectedDate();
        // System.assert(calendarUtil.freebusyResponseJson != null); 
        Test.stopTest();
    }

    @IsTest
    static void testroundToNextInterval() {
        String uuid = SYS_Helper.getUUID();
        Integer slotInterval = 30;
        Datetime currentDatetime = Datetime.now();
        Datetime availSlots1 = currentDatetime.addMinutes(60);
        Datetime availSlots2 = currentDatetime.addMinutes(49);
        Datetime availSlots3 = currentDatetime.addMinutes(18);
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', uuid);
        List<Datetime> availableBookingSlotsList = new List<Datetime>();
        availableBookingSlotsList.add(availSlots1);
        availableBookingSlotsList.add(availSlots2);
        availableBookingSlotsList.add(availSlots3);
        CalendarUtility calendarUtil = new CalendarUtility();
        DateTime roundedDatetime1 = calendarUtil.roundToNextInterval(availSlots1, slotInterval);
        DateTime roundedDatetime2 = calendarUtil.roundToNextInterval(availSlots2, slotInterval);
        DateTime roundedDatetime3 = calendarUtil.roundToNextInterval(availSlots3, slotInterval);
        // DateTime roundedDatetime4 = calendarUtil.roundToNextInterval(availSlots3, 0);
        System.assert(roundedDatetime1 != null);  
        System.assert(roundedDatetime2 != null);  
        System.assert(roundedDatetime3 != null);  
        // System.assert(roundedDatetime4 != null);  
    }

    @IsTest
    static void testfetchUpcomingAppointments() {
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
        
        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', contactRec.UUID__c);

        Test.startTest();
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.fetchUpcomingAppointments();
        Test.stopTest();
        System.assert(calendarUtil.selectedMemberScheduledAppointments.size() > 0);   
    }

    @IsTest
    static void testgetGMTStringDatetime() {
        String uuid = SYS_Helper.getUUID();
        Datetime currentDatetime = Datetime.now();
        Datetime availSlots1 = currentDatetime.addMinutes(60);
        Datetime availSlots2 = currentDatetime.addMinutes(60);
        Datetime availSlots3 = currentDatetime.addMinutes(60);
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', uuid);
        List<Datetime> availableBookingSlotsList = new List<Datetime>();
        availableBookingSlotsList.add(availSlots1);
        availableBookingSlotsList.add(availSlots2);
        availableBookingSlotsList.add(availSlots3);
        CalendarUtility calendarUtil = new CalendarUtility();
        List<String> gmtTimeSlots = calendarUtil.getGMTStringDatetime(availableBookingSlotsList);
        System.assert(gmtTimeSlots.size() > 0);  
    }
    //void cancelAppointment()

    @IsTest
    static void testcreateAppointment() {
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        String shiftCalendarExId = 'testshift@group.calendar.google.com';
        String bookingCalendarExId = 'testbooking@group.calendar.google.com';
        Id BookingProductId = null;

        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();

        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        Google_Calendar__c shiftCalendarRec = Scheduling_TestDataFactory.createTestShiftCalendarRecord(acc.Id, shiftCalendarExId, true, true);
        Google_Calendar__c bookingCalendarRec = Scheduling_TestDataFactory.createTestBookingCalendarRecord(acc.Id, BookingProductId, bookingCalendarExId, true, true);
        Product__c schedulingProductRec = Scheduling_TestDataFactory.createTestProductRecord(acc.Id, shiftCalendarExId, bookingCalendarExId, true, true);

        Datetime currentDatetime = Datetime.now();
        Datetime availSlots1 = currentDatetime.addMinutes(60);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('createEvent_response');
        mock.setStatusCode(200); // Or other appropriate HTTP status code
        mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml

        //Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);

        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', contactRec.UUID__c);
        ApexPages.currentPage().getParameters().put('productuuid', schedulingProductRec.UUID__c);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.selectedDisplayTimeZone = 'Asia/Kolkata';
        calendarUtil.displayTimeZone = 'Asia/Kolkata';
        calendarUtil.meetDuration = '60';
        DateTime roundedDatetime1 = calendarUtil.roundToNextInterval(availSlots1, 60);
        calendarUtil.selectedAppointmentStartDateTime = calendarUtil.formatDateTimetoISOString(roundedDatetime1);

        Test.startTest();
        calendarUtil.createAppointment();
        Test.stopTest();

        System.assert(calendarUtil.selectedMemberScheduledAppointments != null); 
    }

    @IsTest
    static void testcancelAppointment() {
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        String shiftCalendarExId = 'testshift@group.calendar.google.com';
        String bookingCalendarExId = 'testbooking@group.calendar.google.com';
        Id BookingProductId = null;

        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();

        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        Google_Calendar__c shiftCalendarRec = Scheduling_TestDataFactory.createTestShiftCalendarRecord(acc.Id, shiftCalendarExId, true, true);
        Google_Calendar__c bookingCalendarRec = Scheduling_TestDataFactory.createTestBookingCalendarRecord(acc.Id, BookingProductId, bookingCalendarExId, true, true);
        Product__c schedulingProductRec = Scheduling_TestDataFactory.createTestProductRecord(acc.Id, shiftCalendarExId, bookingCalendarExId, true, true);

        //Create Appointment Record
        String appointmentTitle = 'Test New Appointment';
        Datetime currentDatetime = Datetime.now();
        Datetime appointmentStartDateTime = currentDatetime.addMinutes(60);
        Datetime appointmentEndDateTime = currentDatetime.addMinutes(60);
        String meetDuration = '30';
        String appointmentDescription = 'Test New Appointment';
        Id accountId = acc.Id;
        Id contactId = contactRec.Id;
        Id productId = schedulingProductRec.Id;
        String emails = 'dev@adisols.com';
        String bookingcalendarId = bookingCalendarExId;
        String googleCalendarEventId = 'test123';
        String googleCalendarEventStatus = 'confirmed';
        String googleCalendarEventTimezone = 'America/Los_Angeles';
        String scheduledUserTimezone = 'America/Los_Angeles';
        Boolean IsActive = true;
        Appointment_Scheduling__c apptRec = AppointmentSchedulingService.createNewAppointment( appointmentTitle, appointmentStartDateTime, appointmentEndDateTime, meetDuration, appointmentDescription, accountId, contactId, productId, emails, bookingcalendarId, googleCalendarEventId, googleCalendarEventStatus, googleCalendarEventTimezone, scheduledUserTimezone, IsActive);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('cancelEvent_response');
        mock.setStatusCode(200); // Or other appropriate HTTP status code
        mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml

        //Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);

        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', contactRec.UUID__c);
        ApexPages.currentPage().getParameters().put('productuuid', schedulingProductRec.UUID__c);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.selectedDisplayTimeZone = 'Asia/Kolkata';
        calendarUtil.displayTimeZone = 'Asia/Kolkata';
        calendarUtil.meetDuration = '60';
        calendarUtil.selectedappointmentUuid = apptRec.UUID__c;

        calendarUtil.checkinAppointment();
        Test.startTest();
        calendarUtil.cancelAppointment();
        Test.stopTest();

        System.assert(calendarUtil.selectedMemberScheduledAppointments != null); 
    }

    @IsTest
    static void testchangeSelectedProductUuid() {
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        String shiftCalendarExId = ('exCalenderKeyShift' + IntrandomNumber);
        String bookingCalendarExId = ('testbooking@group.calendar.google.com');
        String bookingCalendar1ExId = ('testbooking1@group.calendar.google.com');
        Id BookingProductId = null;
        String calendarType = 'Booking';

        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();
        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        Google_Calendar__c shiftCalendarRec = Scheduling_TestDataFactory.createTestShiftCalendarRecord(acc.Id, shiftCalendarExId, true, true);
        Google_Calendar__c bookingCalendarRec = Scheduling_TestDataFactory.createTestBookingCalendarRecord(acc.Id, BookingProductId, bookingCalendarExId, true, true);
        Product__c schedulingProductRec = Scheduling_TestDataFactory.createTestProductRecord(acc.Id, shiftCalendarExId, bookingCalendarExId, true, true);
        Product__c updateprodWithBookingCalendarId = MapProductWithGoogleCalendar.updateProductWithCalendarKey(calendarType, schedulingProductRec.Id, bookingCalendarExId, '');

        Google_Calendar__c bookingCalendarRec1 = Scheduling_TestDataFactory.createTestBookingCalendarRecord(acc.Id, BookingProductId, bookingCalendar1ExId, true, true);
        Product__c schedulingProductRec1 = Scheduling_TestDataFactory.createTestProductRecord(acc.Id, shiftCalendarExId, bookingCalendar1ExId, true, true);
        Product__c updateprodWithBookingCalendarId1 = MapProductWithGoogleCalendar.updateProductWithCalendarKey(calendarType, schedulingProductRec1.Id, bookingCalendar1ExId, '');
        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', contactRec.UUID__c);
        CalendarUtility calendarUtil = new CalendarUtility();
        Test.startTest();
        calendarUtil.selectedproductuuid = schedulingProductRec.UUID__c;
        calendarUtil.changeSelectedProductUuid();
        Test.stopTest();
        System.assert(calendarUtil.selectedschedulingProduct != null); 
    }

    @IsTest
    static void testchangeSelectedDisplayTimeZone() {
        String uuid = SYS_Helper.getUUID();
        Datetime currentDatetime = Datetime.now();
        Datetime availSlots1 = currentDatetime.addMinutes(60);
        Datetime availSlots2 = currentDatetime.addMinutes(60);
        Datetime availSlots3 = currentDatetime.addMinutes(60);
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', uuid);
        List<Datetime> availableBookingSlotsList = new List<Datetime>();
        availableBookingSlotsList.add(availSlots1);
        availableBookingSlotsList.add(availSlots2);
        availableBookingSlotsList.add(availSlots3);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.selectedDisplayTimeZone = 'Asia/Kolkata';
        calendarUtil.availableBookingSlots = availableBookingSlotsList;
        calendarUtil.changeSelectedDisplayTimeZone();
        System.assert(calendarUtil.availableBookingSlotsTimezone.size() > 0);  
    }

    @IsTest
    static void testfreeBusyRequestJSON() {
        String uuid = SYS_Helper.getUUID();
        String freebusyRequestJson = '{"timeMin":"2070-05-16T01:00:00.000Z","timeMax":"2070-05-17T22:00:00.000Z","calendarExpansionMax":"50","groupExpansionMax":"100","timeZone":"UTC","items":[{"id":"c_9tnsdnol964pp3u3c5codtmkdo@group.calendar.google.com"}]}';

        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', uuid);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.selectedDisplayTimeZone = 'Asia/Kolkata';
        CalendarUtility.freeBusyRequestJSON freeBusyrequestJosnWrapper = new CalendarUtility.freeBusyRequestJSON();
        CalendarUtility.freeBusyRequestJSON freebusyRequestObj = freeBusyrequestJosnWrapper.parse(freebusyRequestJson);
        System.assert(freebusyRequestObj != null);  
    }

    @IsTest
    static void testClassVariables() {
        String uuid = SYS_Helper.getUUID();
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', uuid);
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.selectedDisplayTimeZone = 'Asia/Kolkata';
        List<Product__c> productsList = calendarUtil.schedulingProductsList;
        List<Appointment_Scheduling__c> scheduledAppointments = calendarUtil.selectedMemberScheduledAppointments;
        Boolean showScheduledAppointments = calendarUtil.showScheduledAppointmentDetails;
        System.assert(showScheduledAppointments == false);  
        CalendarUtility.MemberWrapper MemberWrapperAccountObj = new CalendarUtility.MemberWrapper(new Account());
        CalendarUtility.MemberWrapper MemberWrapperContactObj = new CalendarUtility.MemberWrapper(new Contact());
        Account accRec = MemberWrapperAccountObj.accountRecord;
        Contact contRec = MemberWrapperAccountObj.contactRecord;
        MemberWrapperAccountObj.accountRecord = NULL;
        MemberWrapperAccountObj.contactRecord = NULL;
    }

    @IsTest
    static void testcheckNewFreeBusyonSelectedDate() {
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        String shiftCalendarExId = 'testshift@group.calendar.google.com';
        String bookingCalendarExId = 'testbooking@group.calendar.google.com';
        Id BookingProductId = null;

        Scheduling_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
        Account acc = Scheduling_TestDataFactory.getAccountDetails();
        Contact contactRec = Scheduling_TestDataFactory.getContactDetails();
        Google_Calendar__c shiftCalendarRec = Scheduling_TestDataFactory.createTestShiftCalendarRecord(acc.Id, shiftCalendarExId, true, true);
        Google_Calendar__c bookingCalendarRec = Scheduling_TestDataFactory.createTestBookingCalendarRecord(acc.Id, BookingProductId, bookingCalendarExId, true, true);
        Product__c schedulingProductRec = Scheduling_TestDataFactory.createTestProductRecord(acc.Id, shiftCalendarExId, bookingCalendarExId, true, true);
        
        //Set Calendar Page Reference 
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('memberuuid', contactRec.UUID__c);
        ApexPages.currentPage().getParameters().put('productuuid', schedulingProductRec.UUID__c);
        ApexPages.currentPage().getParameters().put('dayCount', '30');
        CalendarUtility calendarUtil = new CalendarUtility();
        calendarUtil.selectedDisplayTimeZone = 'Asia/Kolkata';
        calendarUtil.displayTimeZone = 'Asia/Kolkata';
        calendarUtil.meetDuration = '60';

        Date dateMin = Date.newInstance(2070, 05, 16);
        Date dateMax = Date.newInstance(2070, 05, 17);
        Time dayStartTime = Time.newInstance(0, 0, 0, 0);
        Time dayEndTime = Time.newInstance(0, 0, 0, 0);
        DateTime startDatetimeVar = DateTime.newInstance(dateMin, dayStartTime);
        DateTime endDateTimeVar = DateTime.newInstance(dateMax, dayEndTime);
        calendarUtil.startDatetime = calendarUtil.formatDateTimetoISOString(startDatetimeVar);
        calendarUtil.endDateTime = calendarUtil.formatDateTimetoISOString(endDateTimeVar);
        Test.startTest();
        calendarUtil.fetchAvailableSlot();
        System.assert(calendarUtil.availableSlotMap != null); 
        Test.stopTest();
    }
}