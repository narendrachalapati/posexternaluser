public with sharing class GoogleCalenderEventResponseWrapper{
	public String kind;	//calendar#event
	public String etag;	//"3355534264050000"
	public String id;	//8l245gl5612va0uknnpm7uj5kc
	public String status;	//confirmed
	public String htmlLink;	//https://www.google.com/calendar/event?eid=OGwyNDVnbDU2MTJ2YTB1a25ucG03dWo1a2MgY19wcTc5OXU0MGppY3Nxcjlpamh0ZzRlM3IzZ0Bn
	public String hangoutLink; ////https://meet.google.com/ecv-hgfw-utc
	public String created;	//2023-03-02T14:25:32.000Z
	public String updated;	//2023-03-02T14:25:32.025Z
	public String summary;	//Appointment for Ravi Kumar - Consultation
	public cls_creator creator;
	public cls_organizer organizer;
	public cls_start start;
	public cls_end end_x;
	public String iCalUID;	//8l245gl5612va0uknnpm7uj5kc@google.com
	public Integer sequence;	//0
	public cls_attendees[] attendees;
	public cls_reminders reminders;
	public String eventType;	//default
	public class cls_creator {
		public String email;	//webmaster@adisols.com
	}
	public class cls_organizer {
		public String email;	//c_pq799u40jicsqr9ijhtg4e3r3g@group.calendar.google.com
		public String displayName;	//B-Consultation
		public boolean self;
	}
	public class cls_start {
		public String dateTime_x;	//2023-03-02T06:30:21-08:00
		public String timeZone;	//America/Los_Angeles
	}
	public class cls_end {
		public String dateTime_x;	//2023-03-02T07:00:21-08:00
		public String timeZone;	//America/Los_Angeles
	}
	public class cls_attendees {
		public String email;	//dev@adisols.com
		public String displayName;	//support
		public String responseStatus;	//needsAction
	}
	public class cls_reminders {
		public boolean useDefault;
	}
	public static GoogleCalenderEventResponseWrapper parse(String json){
		return (GoogleCalenderEventResponseWrapper) System.JSON.deserialize(json, GoogleCalenderEventResponseWrapper.class);
	}
}