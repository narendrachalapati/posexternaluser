@IsTest
public class freeBusyResponseWrapperTest {
    //Datetime formatDateTime(String dt, String format)
    @IsTest
    static void testParseFormatDatetime() {
    	String dateString = '2023-02-01T14:00:00-07:21';
        String datetimeformat = 'YYYY-MM-DDThh:mm:ss_zh:zm';
        Datetime testDatetime = freeBusyResponseWrapper.formatDateTime(dateString, datetimeformat);
        System.assert(testDatetime != null);
	}
    
    //one Calendat has no Available Busy Slots
    @IsTest
    static void testParseNoSlotsOneCalendar() {
        String jsonnoBusySlots = '{\"kind\":\"calendar#freeBusy\",\"timeMin\":\"2023-02-01T14:00:00.000Z\",\"timeMax\":\"2023-02-17T23:00:00.000Z\",\"calendars\":{\"CalenderExId\":{}, \"CalenderExId1\":{\"busy\":[]}, \"CalenderExId2\":null}}';
        jsonnoBusySlots = jsonnoBusySlots.replaceAll('start_x', 'start');
        jsonnoBusySlots = jsonnoBusySlots.replaceAll('end_x', 'end');
		jsonnoBusySlots = jsonnoBusySlots.replaceAll('dateTime_x', 'dateTime');
		FreeBusyResponseWrapper objnoBusySlots = freeBusyResponseWrapper.parse(jsonnoBusySlots);
		System.assert(objnoBusySlots != null);
    }

    //No Available Busy Slots
    @IsTest
    static void testParseNoSlots() {
        String jsonnoBusySlots = '{\"kind\":\"calendar#freeBusy\",\"timeMin\":\"2023-02-01T14:00:00.000Z\",\"timeMax\":\"2023-02-17T23:00:00.000Z\",\"calendars\":{\"CalenderExId\":{}}}';
		FreeBusyResponseWrapper objnoBusySlots = freeBusyResponseWrapper.parse(jsonnoBusySlots);
		System.assert(objnoBusySlots != null);
    }
    
    @IsTest
	static void testParse() {
		String json = '{\"kind\":\"calendar#freeBusy\",\"timeMin\":\"2023-02-01T14:00:00.000Z\",\"timeMax\":\"2023-02-17T23:00:00.000Z\",\"calendars\":{\"CalenderExId\":{\"busy\":[{\"start_x\":\"2023-02-14T14:12:00Z\",\"end_x\":\"2023-02-14T15:12:00Z\"},{\"start_x\":\"2023-02-14T18:00:00Z\",\"end_x\":\"2023-02-14T19:00:00Z\"},{\"start_x\":\"2023-02-15T14:00:00Z\",\"end_x\":\"2023-02-15T15:00:00Z\"},{\"start_x\":\"2023-02-15T18:00:00Z\",\"end_x\":\"2023-02-15T19:00:00Z\"}]},\"CalenderExId1\":{\"busy\":[{\"start_x\":\"2023-02-15T14:00:00Z\",\"end_x\":\"2023-02-15T15:00:00Z\"},{\"start_x\":\"2023-02-15T14:00:00Z\",\"end_x\":\"2023-02-15T15:00:00Z\"}]}}}';
		json = json.replaceAll('start_x', 'start');
        json = json.replaceAll('end_x', 'end');
		json = json.replaceAll('dateTime_x', 'dateTime');
        FreeBusyResponseWrapper r = freeBusyResponseWrapper.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		freeBusyResponseWrapper.Busy objBusy = new freeBusyResponseWrapper.Busy(System.JSON.createParser(json));
		System.assert(objBusy != null);
		System.assert(objBusy.start_x == null);
		System.assert(objBusy.end_x == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		freeBusyResponseWrapper.Calendars objCalendars = new freeBusyResponseWrapper.Calendars(System.JSON.createParser(json));
		System.assert(objCalendars != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		freeBusyResponseWrapper objFreeBusyResponseWrapper = new freeBusyResponseWrapper(System.JSON.createParser(json));
		System.assert(objFreeBusyResponseWrapper != null);
		System.assert(objFreeBusyResponseWrapper.kind == null);
		System.assert(objFreeBusyResponseWrapper.timeMin == null);
		System.assert(objFreeBusyResponseWrapper.timeMax == null);
		System.assert(objFreeBusyResponseWrapper.calendars == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		freeBusyResponseWrapper.Busy objbusyWrap = new freeBusyResponseWrapper.busy(System.JSON.createParser(json));
		System.assert(objbusyWrap != null);
		System.assert(objbusyWrap.start_x == null);
	}
}