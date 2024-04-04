@isTest
public with sharing class GoogleCalenderEventResponseWrapperTest {
    
	@isTest
	static void testParse() {
		String json = '{'+
		' "kind": "calendar#event",'+
		' "etag": "3355534264050000",'+
		' "id": "8l245gl5612va0uknnpm7uj5kc",'+
		' "status": "confirmed",'+
		' "htmlLink": "https://www.google.com/calendar/event?eid=OGwyNDVnbDU2MTJ2YTB1a25ucG03dWo1a2MgY19wcTc5OXU0MGppY3Nxcjlpamh0ZzRlM3IzZ0Bn",'+
		' "created": "2023-03-02T14:25:32.000Z",'+
		' "updated": "2023-03-02T14:25:32.025Z",'+
		' "summary": "Appointment for Ravi Kumar - Consultation",'+
		' "creator": {'+
		'  "email": "webmaster@adisols.com"'+
		' },'+
		' "organizer": {'+
		'  "email": "c_pq799u40jicsqr9ijhtg4e3r3g@group.calendar.google.com",'+
		'  "displayName": "B-Consultation",'+
		'  "self": true'+
		' },'+
		' "start": {'+
		'  "dateTime_x": "2023-03-02T06:30:21-08:00",'+
		'  "timeZone": "America/Los_Angeles"'+
		' },'+
		' "end_x": {'+
		'  "dateTime_x": "2023-03-02T07:00:21-08:00",'+
		'  "timeZone": "America/Los_Angeles"'+
		' },'+
		' "iCalUID": "8l245gl5612va0uknnpm7uj5kc@google.com",'+
		' "sequence": 0,'+
		' "attendees": ['+
		'  {'+
		'   "email": "dev@adisols.com",'+
		'   "displayName": "support",'+
		'   "responseStatus": "needsAction"'+
		'  }'+
		' ],'+
		' "reminders": {'+
		'  "useDefault": true'+
		' },'+
		' "eventType": "default"'+
		'}';
		GoogleCalenderEventResponseWrapper obj = GoogleCalenderEventResponseWrapper.parse(json);
		System.assert(obj != null);
	}
}