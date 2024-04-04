@isTest
public with sharing class DialogueFlow_MockServer {
    
    public static MultiStaticResourceCalloutMock startServer(){
        MultiStaticResourceCalloutMock multimockServer = new MultiStaticResourceCalloutMock();
        multimockServer.setStaticResource('https://get_products.inbound', 'DF_get_product');
        multimockServer.setStaticResource('https://get_member.inbound', 'DF_get_member');
        multimockServer.setStaticResource('https://upsert_member.inbound', 'DF_upsert_member');
        multimockServer.setStaticResource('https://get_availability.inbound', 'DF_get_availability');
        multimockServer.setStaticResource('https://fetchupcomingappointment.inbound', 'DF_fetchupcomingappointment');
        multimockServer.setStaticResource('https://cancelappointment.inbound', 'DF_cancelappointment');
        multimockServer.setStaticResource('https://DF_send_verification_code.inbound', 'DF_send_verification_code');
        multimockServer.setStaticResource('https://DF_send_appointment_scheduling_text.inbound', 'DF_send_appointment_scheduling_text');
        multimockServer.setStaticResource('https://DF_update_profile.inbound', 'DF_update_profile');
        SYS_DataCache.INT_TYPE = 'SYS_Test_IntegrationSetting';
        multimockServer.setStatusCode(200);
        multimockServer.setHeader('Content-Type', 'application/json');
        return multimockServer;
    }
}