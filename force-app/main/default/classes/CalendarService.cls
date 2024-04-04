public with sharing class CalendarService {
    
    public class CalendarServiceException extends Exception {}

    public static String createPlaceHolderRecurrance(RecurringEvent request) {
        String response;
        try {
            CalendarUtility utility = new CalendarUtility();
            String requestjson = getRecurringRequestForCalendar(request);

            String IntegrationName = 'Calendar';
            String calloutMethod = 'POST';
            String calloutUrl = 'https://www.googleapis.com/calendar/v3/calendars/'++'/events';
            
            HttpResponse resp = buildOutboundHttpRequest(IntegrationName, calloutMethod, calloutUrl, requestJsonBody);

        } catch ( Exception e ) {
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new CalendarServiceException(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return response;
    }

    public static String getRecurringRequestForCalendar(RecurringEvent request) {
        String result;
        try {
            Map<String, String> startMap = new Map<String, String>();
            Map<String, String> endMap = new Map<String, String>();

            if (String.isNotBlank(request.StartDateTime))
                startMap.put('dateTime', request.StartDateTime);
            else if (String.isNotBlank(request.StartDate))
                startMap.put('date', request.StartDate);
            startMap.put('timeZone', request.TimeZone);

            if (String.isNotBlank(request.StartDateTime))
                endMap.put('dateTime', request.StartDateTime);
            else if (String.isNotBlank(request.StartDate))
                endMap.put('date', request.StartDate);
            endMap.put('timeZone', request.TimeZone);

            Map<String, Object> requestMap = new Map<String, Object>();
            requestMap.put('end', endMap);
            requestMap.put('start', startMap);
            requestMap.put('recurrence', request.rrule);
            requestMap.put('summary', request.summary);
            requestMap.put('description', request.description);
            
            result = JSON.serializePretty(requestMap);
        } catch ( Exception e ) {
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new CalendarServiceException(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return result;
    }

    public static String getDateTimeISOString(String json) {
        String dtString;
        try {
            if (String.isBlank(json)) {
                throw new CalendarServiceException('Datetime object received is empty '+json);
            }
            dateJson obj = parse(json); //2023-12-07 11:59:00-0800
            dtString = String.valueof(obj.year)+'-'+String.valueof(obj.month)+'-'+String.valueof(obj.day)+' '
                +String.valueof(obj.hours)+':'+String.valueof(obj.minutes)+':'+String.valueof(obj.seconds);

        } catch ( Exception e) {
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new CalendarServiceException(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return dtString;
    }

    public static dateJson parse(String json){
        return (dateJson) System.JSON.deserialize(json, dateJson.class);
    }

    public class dateJson {
        public Integer year;
        public Integer month;
        public Integer day;
        public Integer hours;
        public Integer minutes;
        public Integer seconds;	
        public Integer nanos;
    }

    public class RecurringEvent {
        public String StartDateTime;
        public String StartDate;
        public String EndDateTime;
        public String EndDate;
        public String TimeZone;
        public String rrule;
        public String summary;
        public String description;
    }
}