public without sharing class AppointmentSchedulingService {

    public static Appointment_Scheduling__c getAppointmentDetails(String IdorUuid) {
        String appointmentListFilterCriteria = ' WHERE ';
        if ((IdorUuid.length() == 15) || (IdorUuid.length() == 18)) {
            appointmentListFilterCriteria += 'Id =: IdorUuid';
        } else {
            appointmentListFilterCriteria += 'UUID__c =: IdorUuid';
        }
        String appointmentListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
                ' FROM Appointment_Scheduling__c'+ appointmentListFilterCriteria;
        List<Appointment_Scheduling__c> appointmentList = Database.query(appointmentListQuery);
        return (appointmentList.size() > 0) ? appointmentList[0] : new Appointment_Scheduling__c();
    }

    public static Boolean hasDuplicateAppointments(Datetime appointmentStartDateTime, String Google_Booking_Calendar_Id) {
        String appointmentListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
                ' FROM Appointment_Scheduling__c WHERE StartDate__c =: appointmentStartDateTime AND Google_Booking_Calendar_Id__c =: Google_Booking_Calendar_Id AND Status__c = \'confirmed\'';
        List<Appointment_Scheduling__c> appointmentList = Database.query(appointmentListQuery);
        return (appointmentList.size() >= THRESHOLD);
    }

    public static Integer THRESHOLD{
        get{
            Integer val;
            try {
                val = Integer.valueOf(Label.ADS_booking_threshold);
            } catch (Exception e) {
                val = 1;
            }
            return val;
        }
    }

    public static Appointment_Scheduling__c createNewAppointment(
        String appointmentTitle,
        Datetime appointmentStartDateTime,
        Datetime appointmentEndDateTime,
        String meetDuration,
        String appointmentDescription,
        Id accountId,
        Id contactId,
        Id productId,
        String emails,
        String bookingcalendarId,
        String googleCalendarEventId,
        String googleCalendarEventStatus,
        String googleCalendarEventTimezone,
        String scheduledUserTimezone, Boolean IsActive) {

        //Name Field MAX Size Truncate
        Integer fieldmaxSize = 80;
        String truncatedAppointmentTitle = appointmentTitle;
        if (appointmentTitle.length() > fieldmaxSize) {
            truncatedAppointmentTitle = appointmentTitle.substring(0, fieldmaxSize);
        }
        Date appointmentDate = Date.newinstance(appointmentStartDateTime.year(), appointmentStartDateTime.month(), appointmentStartDateTime.day());
        Appointment_Scheduling__c googleCalendarEvent = new Appointment_Scheduling__c(
            Name = truncatedAppointmentTitle,
            AppointmentDate__c = appointmentDate,
            StartDate__c = appointmentStartDateTime,
            EndDate__c = appointmentEndDateTime,
            Duration_of_Meet__c = meetDuration,
            Description__c = appointmentDescription,
            Account__c = accountId,
            Contact__c = contactId,
            Product__c = productId,
            Guest_Email__c = emails,
            Google_Booking_Calendar_Id__c = bookingcalendarId,
            Google_Calendar_Event_Id__c = googleCalendarEventId,
            Status__c = googleCalendarEventStatus,
            TimeZone__c = googleCalendarEventTimezone,
            Scheduled_User_TimeZone__c = scheduledUserTimezone,
            ISActive__c = IsActive,
            UUID__c = SYS_Helper.getUUID()
        );

        insert googleCalendarEvent;

        return getAppointmentDetails(googleCalendarEvent.Id);
    }
    public static Appointment_Scheduling__c createNewAppointmenthangoutlink(
        String appointmentTitle,
        Datetime appointmentStartDateTime,
        Datetime appointmentEndDateTime,
        String meetDuration,
        String appointmentDescription,
        Id accountId,
        Id contactId,
        Id productId,
        String emails,
        String bookingcalendarId,
        String googleCalendarEventId,
        String googleCalendarEventStatus,
        String googleCalendarEventTimezone,
        String scheduledUserTimezone, Boolean IsActive,string handoutMeetingURL) {

        //Name Field MAX Size Truncate
        Integer fieldmaxSize = 80;
        String truncatedAppointmentTitle = appointmentTitle;
        if (appointmentTitle.length() > fieldmaxSize) {
            truncatedAppointmentTitle = appointmentTitle.substring(0, fieldmaxSize);
        }
        Date appointmentDate = Date.newinstance(appointmentStartDateTime.year(), appointmentStartDateTime.month(), appointmentStartDateTime.day());
        Appointment_Scheduling__c googleCalendarEvent = new Appointment_Scheduling__c(
            Name = truncatedAppointmentTitle,
            AppointmentDate__c = appointmentDate,
            StartDate__c = appointmentStartDateTime,
            EndDate__c = appointmentEndDateTime,
            Duration_of_Meet__c = meetDuration,
            Description__c = appointmentDescription,
            Account__c = accountId,
            Contact__c = contactId,
            Product__c = productId,
            Guest_Email__c = emails,
            Google_Booking_Calendar_Id__c = bookingcalendarId,
            Google_Calendar_Event_Id__c = googleCalendarEventId,
            Status__c = googleCalendarEventStatus,
            TimeZone__c = googleCalendarEventTimezone,
            Scheduled_User_TimeZone__c = scheduledUserTimezone,
            ISActive__c = IsActive,
            UUID__c = SYS_Helper.getUUID(),
            hangoutLink__c = handoutMeetingURL
        );

        insert googleCalendarEvent;

        return getAppointmentDetails(googleCalendarEvent.Id);
    }
    public static Appointment_Scheduling__c updateAppointment(Appointment_Scheduling__c updateAppointmentRecord){
        if(updateAppointmentRecord != null){
            update updateAppointmentRecord;
        }
        return getAppointmentDetails(updateAppointmentRecord.Id);
    }

}