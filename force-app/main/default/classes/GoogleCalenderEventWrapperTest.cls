@IsTest
public class GoogleCalenderEventWrapperTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  "summary": "Appointment for Ravi Kumar - Consultation",'+
		'  "start": {'+
		'    "dateTime_x": "2023-03-02T12:30:00.000Z"'+
		'  }, 		'+
		'  "end_x": {'+
		'    "dateTime_x": "2023-03-02T13:00:00.000Z"'+
		'  },'+
		'  "attendees": ['+
		'    {'+
		'      "email": "dev@adisols.com"'+
		'    }'+
		'  ]'+
		'}';
		GoogleCalenderEventWrapper obj = GoogleCalenderEventWrapper.parse(json);
		System.assert(obj != null);
	}
}