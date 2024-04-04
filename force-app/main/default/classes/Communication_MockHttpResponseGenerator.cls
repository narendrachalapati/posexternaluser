@isTest
global class Communication_MockHttpResponseGenerator  {
     Map<String, HttpResponse> router;

    public static MultiStaticResourceCalloutMock Sucesscallout(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Message/', 'Outboundimmediateresonce');
        multimockServer.setStaticResource('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Media/', 'PlivoMediasucessresponce');
         multimockServer.setStaticResource('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Webhook/', 'PlivoWebookResponce');

        multimockServer.setStatusCode(200);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }
    public static MultiStaticResourceCalloutMock stopServer(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Message/', 'Plivosmsfailresonce'); 
         multimockServer.setStaticResource('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Media/', 'PlivoMediaFail');
        multimockServer.setStatusCode(500);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }
}