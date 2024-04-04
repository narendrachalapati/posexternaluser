@isTest
public class Google_Calendar_InboundTest {

    private static String responseJson;

    public class GC_HttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response.
            // Set response values, and 
            // return response.
            HttpResponse res = new HttpResponse();
            res.setBody(responseJson);
            res.setStatusCode(200);
            return res;
        }
    }

    public static String getMockCalendarBody(){
        
        Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());


        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://get_mock_item_calendar_body.inbound');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res.getBody();

    }
    
    @isTest
    static void calendarInboundWebhook() {
        
        System.runAs(Scheduling_TestDataFactory.getUser()) {

            // SYS_TestDataFactory.createTestRecords(1, 1);
            // List<account> accounts = [SELECT Id, UUID__c FROM Account LIMIT 1];
            
            RestRequest request = new RestRequest();
            RestResponse actualres = new RestResponse();
            request.requestURI = '/municorn/v1/Calendar';
            request.addParameter('token', '252Fm035j000000dIoZ');
            request.addHeader('X-Goog-Resource-URI', 'https://www.googleapis.com/calendar/v3/calendars/c_pq799u40jicsqr9ijhtg4e3r3g@group.calendar.google.com/events?alt=json');
            request.requestBody = Blob.valueOf('');

            RestContext.request = request;
            // Test.setMock(HttpCalloutMock.class, Scheduling_MockHttpResponseGenerator.startServer());

            Test.startTest();
            try{
                // System.debug('handler '+RestContext?.request?.requestURI);
                SYS_Webservice.postRequest();
                // Google_Calendar_SYS_ApplicationService gc = new Google_Calendar_SYS_ApplicationService();
                // gc.getAllCalendarEvents('https://www.googleapis.com/calendar/v3/calendars/c_pq799u40jicsqr9ijhtg4e3r3g@group.calendar.google.com/');
            } catch(Exception e) {
                System.debug('error message '+e.getMessage() + e.getStackTraceString());
                System.assert(e.getMessage() != NULL);
            }
            Test.stopTest();

            List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(log.size()>0);
        }
    }

    @isTest
    static void testEventCallout() {
        Google_Calendar_InboundTest.responseJson = getMockCalendarBody();
        
        System.runAs(Scheduling_TestDataFactory.getUser()) {
            

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Google_Calendar_InboundTest.GC_HttpCalloutMockImpl());

            Google_Calendar_SYS_ApplicationService gc = new Google_Calendar_SYS_ApplicationService();
            String requestBody = gc.getAllCalendarEvents('https://www.googleapis.com/calendar/v3/calendars/c_pq799u40jicsqr9ijhtg4e3r3g@group.calendar.google.com/');
            SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
            List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();
            
            //Check criteria when chars more than 1M
            if(requestBody != NULL && requestBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
                logAfterPartition = SYS_Helper.getLogsAfterPartition(requestBody);
                if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                    // SYS_Helper.upsertLog(logs[0]);
                    // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                    
                    // SYS_Helper.upsertLog(childs);
                    log = logAfterPartition[0];
                }
                System.debug('SP 1M<<');
            } else {
                log = SYS_Helper.getLogsToInsert(requestBody);
                System.debug('SP 1M>>');
            }

            String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
            if(algo!=NULL && algo!='')
            log.Request_Digest__c = gc.generateHash(requestBody,algo);

            if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
                log.Is_Notification_Only__c = true;

            log.Type__c = 'INBOUND';
            log.SYS_Operation_Type__c = gc.getOperationTypeFor('POST');
            log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
            log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            log.Status__c = 'NEW';
            log.How_to_process__c = 'use_custom_apex_handler';
            log.Custom_Apex_Handler__c = 'Google_Calendar_SYS_ApplicationService';
            
            log.Account_Id__c = SYS_DataCacheFactory.accountId;
            log.Integration_Type__c = SYS_DataCacheFactory.integrationSetting?.Integration_Type__c;

            List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
            returnVal.add(log);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                log.Status__c = 'PENDING_PARTITIONED_LOOKUP';
                for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                    returnVal.add(logAfterPartition[i]);
                }
            }

            SYS_Helper.upsertLog(returnVal);
            Test.stopTest();

            List<SYS_IntegrationLog__c> logs = [SELECT Id FROM SYS_IntegrationLog__c];
            System.assert(logs.size()>0);
        }
    }
}