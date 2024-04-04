public class GoogleCalenderEventWrapper {
    public String summary; //Appointment for Ravi Kumar - Consultation
    public String status; //confirmed cancelled tentative
    public cls_start start;
    public cls_end end_x;
    public cls_attendees[] attendees; 
    public String location;	//USA
	public cls_conferenceData conferenceData;   

    public GoogleCalenderEventWrapper(){
        attendees = new List<cls_attendees>();
    }

    public class cls_start {
        public String dateTime_x; //2023-03-02T12:30:00.000Z
    }

    public class cls_end {
        public String dateTime_x; //2023-03-02T13:00:00.000Z
    }

    public class cls_attendees {
        public String email; //dev@adisols.com
    }

    public class cls_conferenceData {
		public cls_createRequest createRequest;
	}

	public class cls_createRequest {
		public String requestId;	//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
		public cls_status status;
		public cls_conferenceSolutionKey conferenceSolutionKey;
	}

    public class cls_status {
		public String statusCode;	//pending
	}
    
	public class cls_conferenceSolutionKey {
		public String type;	//hangoutsMeet
	}

    public void addStartDatetime(String startdateTime) {
        cls_start cls_startWrap = new cls_start();
        cls_startWrap.dateTime_x = startdateTime;
        start = cls_startWrap;
    }

    public void addEndDatetime(String enddateTime) {
        cls_end cls_endWrap = new cls_end();
        cls_endWrap.dateTime_x = enddateTime;
        end_x = cls_endWrap;
    }

    public void addAttendees(String attendeeEmail) {
        cls_attendees cls_attendeesWrap = new cls_attendees();
        cls_attendeesWrap.email = attendeeEmail;
        attendees.add(cls_attendeesWrap);
    }

    public void confrencedatacreate(String createRequestId, String createRequestStatus, string createRequestType) {
        cls_status cls_statuswrap = new cls_status();
        cls_conferenceSolutionKey cls_conferenceSolutionKeywrap = new cls_conferenceSolutionKey();
        cls_createRequest cls_createRequestwrap = new cls_createRequest();
        cls_conferenceData cls_conferenceDatawrap = new cls_conferenceData();
        //adding the granualls molecules
        cls_createRequestwrap.requestId = createRequestId;
        cls_statuswrap.statusCode = createRequestStatus; //pending
        cls_conferenceSolutionKeywrap.type = createRequestType; //hangoutsMeet
        //combining molecules to build class
        
        cls_createRequestwrap.status = cls_statuswrap;
        cls_createRequestwrap.conferenceSolutionKey = cls_conferenceSolutionKeywrap;
        // combining classes to achive json formatt
        cls_conferenceDatawrap.createRequest = cls_createRequestwrap;
        conferenceData = cls_conferenceDatawrap;
    }

    public static GoogleCalenderEventWrapper parse(String json) {
        return (GoogleCalenderEventWrapper) System.JSON.deserialize(json, GoogleCalenderEventWrapper.class);
    }
}