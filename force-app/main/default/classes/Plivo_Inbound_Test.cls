@IsTest
public class Plivo_Inbound_Test {
    @IsTest
    static void testPostOutboundWebhook(){
        
        //String body = SYS_TestUtil.getMockBody();
        Test.setMock(HttpCalloutMock.class, Communication_MockHttpResponseGenerator.Sucesscallout());
        
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Webhook/');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        string body = res.getBody();
        system.debug('bodyNDR::'+body);
        Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationWithUUIDDF(false,true,false);
        
        List<Activity__c> Activity = [SELECT Id, UUID__c FROM Activity__c LIMIT 1];
        system.debug('ActivityNDR::'+Activity);
        
        SYS_DataCacheFactory init = new SYS_DataCacheFactory(
            // Activity[0].Id,
            // 'PlivoInbound', 
            SYS_DataCacheFactory.OBJ_TYPE,
            SYS_DataCacheFactory.INT_TYPE
        );
        system.debug('ObjecttypeNDR::'+SYS_DataCacheFactory.OBJ_TYPE);
        system.debug('INT_TYPENDR::'+SYS_DataCacheFactory.INT_TYPE);
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.requestURI = '/municorn/v1/Plivo';
        request.addParameter('token', 'TQo5GqOWQERRW');
        
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        
        Test.startTest();
        request.addParameter('key', '');
        try{
            SYS_Webservice.postRequest();
        } catch(Exception e) {
            System.assert(e.getMessage() != NULL);
        }
        request.addParameter('key', Activity[0].UUID__c);
        SYS_Webservice.postRequest();
        request.addParameter('token', 'incorrect_token');
        SYS_Webservice.postRequest();
        Test.stopTest();
        
        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }
    @IsTest
    static void testPostInboundWebhook(){
        StaticResource PlivoWebookResponseStaticResource = [SELECT Id,body FROM StaticResource WHERE Name = 'PlivoWebookResponce'];
		String plivoInboundWebhookSuccessResponse = PlivoWebookResponseStaticResource.body.toString();
        
        system.debug('plivoInboundWebhookSuccessResponse ::'+ plivoInboundWebhookSuccessResponse);
        Map<String, String> requestParams = (Map<String,String>) JSON.deserialize(plivoInboundWebhookSuccessResponse, Map<String,String>.class);
        System.debug('requestParams ' + requestParams);
        Test.startTest();
        Activity__c activityRecord = Communication_TestDataFactory.ActivitycreationWithUUIDDF(false,true,false);
        List<Id> recordIdList = new List<Id>();
        for(Sobject iterRecord : [SELECT Id FROM Contact]){
            recordIdList.add(iterRecord.Id);
        }
        Test.setFixedSearchResults(recordIdList);
        List<Activity__c> Activity = [SELECT Id, UUID__c FROM Activity__c LIMIT 1];
        system.debug('ActivityNDR::'+Activity);
        
        SYS_DataCacheFactory init = new SYS_DataCacheFactory(
            // Activity[0].Id,
            // 'PlivoInbound', 
            SYS_DataCacheFactory.OBJ_TYPE,
            SYS_DataCacheFactory.INT_TYPE
        );
        
        RestRequest request = new RestRequest();
        RestResponse actualres = new RestResponse();
        request.httpMethod = 'POST';
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/municorn/v1/PlivoInbound';
        //request.addHeader('Content-Type', 'application/json');
        for(String key : requestParams.keySet()){
            request.addParameter(key.toLowerCase(), requestParams.get(key));
            System.debug('requestParams ' + key.toLowerCase() +' ' + requestParams.get(key));
        }
        
        request.addParameter('token', 'VbLz0ev7Nx29eEAhHr4PpB0W0HM');
        request.addParameter('messagedirection', 'inboundsms');
        
        RestContext.response = actualres;
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        
        
        
        try{
            SYS_Webservice.postRequest();
        } catch(Exception e) {
            System.debug('exception ' + e);
            System.assert(e.getMessage() != NULL);
        }
        
        system.debug('ObjecttypeNDR::'+SYS_DataCacheFactory.OBJ_TYPE);
        system.debug('INT_TYPENDR::'+SYS_DataCacheFactory.INT_TYPE);
        Test.stopTest();
        
        List<SYS_IntegrationLog__c> log = [SELECT Id FROM SYS_IntegrationLog__c];
        System.assert(log.size()>0);
        
    }
    
}