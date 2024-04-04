public without sharing class CheckinController {

    public String uuid { get; set; }
    public Appointment_Scheduling__c appointment { get; set; }
    public String locationTagUUID { get; set; }
    public String checkinMessage { get; set; }
    public Datetime appointmentStartTime { get; set; }
    public String appointmentStartTimeString { get; set; }
    public String invalidUrlMessage { get; set; }
    public Boolean isComponent { get; set; }
    public ToDo__c todorecord { get; set; }



    public CheckinController() { }

    public class CheckinControllerException extends Exception {}

    public void init() {
        try {
            this.uuid = ApexPages.currentPage().getParameters().get('uuid');
            this.appointment = getAppointmentDetails(this.uuid);
            if (this.appointment != NULL) {
                this.appointmentStartTime = this.appointment?.StartDate__c;
                if (this.appointment?.Status__c == 'checked-in') {
                    this.checkinMessage = 'Checked in successfully!!';
                }
            }
            else {
                this.invalidUrlMessage = 'Invalid URL!!';
            }
        } catch ( Exception e ) {
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new CheckinControllerException(e.getMessage()+'\n'+e.getStackTraceString());
        }
    }

    public void checkinAppointment() {
        try {
            System.debug('locationTagUUID '+locationTagUUID);
            LocationTags__c locationtag;
            if (String.isNotBlank(locationTagUUID))
                locationtag = getLocationTag(locationTagUUID);

            if (appointment != NULL) {
                appointment.LocationTags__c = locationtag?.Id;
                appointment.Status__c = 'checked-in';
                System.debug('appointment '+appointment);
                update appointment;
                this.checkinMessage = 'Checked in successfully!!';
            }
            if (this.todorecord != NULL) {
                this.todorecord.Status__c = 'Completed';
                update this.todorecord;
            }
            
        } catch ( Exception e ) {
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new CheckinControllerException(e.getMessage()+'\n'+e.getStackTraceString());
        }
    }

    public LocationTags__c getLocationTag(String uuid) {
        LocationTags__c record;
        try {
            String query = 'SELECT '+ SYS_Helper.getAllFieldsFor('LocationTags__c') 
                    +' FROM LocationTags__c ';
            String whereclause = ' WHERE UUID__c =:uuid LIMIT 1';

            List<LocationTags__c> records = Database.query(String.escapeSingleQuotes(query + whereclause));
            if (records.size() > 0) 
            record = records[0];

        } catch ( Exception e ) {
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new CheckinControllerException(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return record;
    }

    public Appointment_Scheduling__c getAppointmentDetails(String uuid) {
        Appointment_Scheduling__c record;
        try {
            String query = 'SELECT '+ SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') 
                    +', '+ SYS_Helper.getAllParentFields('Account__r.', 'Account') 
                    +', '+ SYS_Helper.getAllParentFields('Contact__r.', 'Contact') 
                    +', '+ SYS_Helper.getAllParentFields('Product__r.', 'Product__c')
                    +' FROM Appointment_Scheduling__c ';
            String whereclause = ' WHERE UUID__c =:uuid LIMIT 1';

            List<Appointment_Scheduling__c> records = Database.query(String.escapeSingleQuotes(query + whereclause));
            if (records.size() > 0) 
                record = records[0];

        } catch ( Exception e ) {
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new CheckinControllerException(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return record;
    }
}