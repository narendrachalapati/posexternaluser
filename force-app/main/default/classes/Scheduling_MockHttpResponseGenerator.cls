@isTest
public class Scheduling_MockHttpResponseGenerator {
    public static MultiStaticResourceCalloutMock startServer() {
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('https://get_mock_item_calendar_body.inbound', 'gc_response');
        multimockServer.setStaticResource('https://www.googleapis.com/calendar/v3/freeBusy', 'freeBusy_response');
        // multimockServer.setStaticResource('https://www.googleapis.com/calendar/v3/calendars/'+ calendarId +'/events?sendNotifications=true&sendUpdates=all&maxAttendees=1', 'createEvent_response');
        // multimockServer.setStaticResource('https://www.googleapis.com/calendar/v3/calendars/'+ calendarId +'/events/'+ eventId +'?sendNotifications=true&sendUpdates=all&maxAttendees=1', 'cancelEvent_response');
        SYS_DataCacheFactory.INT_TYPE = 'Calendar';
        multimockServer.setStatusCode(200);
        multimockServer.setHeader('Content-Type', 'application/json');

        return multimockServer;
    }

    public static MultiStaticResourceCalloutMock stopServer() {
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        // multimockServer.setStaticResource('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Message/', 'Plivosmsfailresonce');
        // multimockServer.setStaticResource('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Media/', 'PlivoMediaFail');
        // multimockServer.setStatusCode(500);
        // multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }
}