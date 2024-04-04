public without sharing class Stripe_Outbound_SYS_ApplicationService extends SYS_ApplicationService {
    public Stripe_Outbound_SYS_ApplicationService() {

    }

    /* ------------------------------------------------------------------------ */
    public override void setHttpRequestHeaders(HttpRequest req,SYS_IntegrationLog__c log){
        SYS_debug.log('header is WhatId__c= '+log.WhatId__c);
        List<HttpHeaders__mdt> httpHeader = SYS_DataCacheFactory.headerSetting;
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.header_name__c +' '+head.Value__c);
            req.setHeader(String.valueOf(head.header_name__c), String.valueOf(head.Value__c));       
        }
        String oauthGrantType = SYS_DataCacheFactory.integrationSetting.AuthenticationType__c;
        if(oauthGrantType.toLowerCase() == 'oauth'){
            List<SYS_OAuthConfig__c> configs = SYS_DataCacheFactory.authRec;
            if(configs.size()>0){
                if( (configs[0].Grant_Type__c == 'password') && (configs[0].Token_type__c == 'Basic')  ){
                    String Username = configs[0].Username__c;
                    String Password = configs[0].Password__c;
                    Blob headerValue = Blob.valueOf(Username + ':' + Password);
                    String authorizationHeader = EncodingUtil.base64Encode(headerValue);
                    req.setHeader('Authorization',configs[0].Token_type__c+' '+authorizationHeader); 
                }
                if( (configs[0].Grant_Type__c == 'authorization_code') && (configs[0].Token_type__c == 'Bearer')  ){
                    req.setHeader('Authorization',configs[0].Token_type__c+' '+configs[0].Access_Token__c); 
                }                                        
            }
            SYS_debug.log('MS Header:'+configs[0].Token_type__c+'::'+req.getHeader('Authorization'));
        }
        if(log.Id != NULL)
            req.setHeader('Idempotency-Key', log.Id);         
    }

    public override HttpResponse doOutbound(SYS_IntegrationLog__c log){

       
        Http http = new Http();
        HttpRequest req = buildOutboundHttpRequest(log);

        if(req.getMethod()!='GET' && req.getMethod()!='DELETE' && log.ObjectSettingId__c != 'Stripe_Invoice_Finalize' && log.ObjectSettingId__c != 'Stripe_Invoice_Pay' && log.ObjectSettingId__c != 'Stripe_Invoice_Void'){
            String body = SYS_Helper.getDataFrom(log); 
            body = preprocessJSONForOutbound(log,body,req);
            req.setBody(body);
            SYS_debug.log('body:'+body);
        }
 
        HttpResponse response = http.send(req);
        SYS_debug.log('Outbound Request:'+req);
        SYS_debug.log('Outbound Response:'+response.getBody());
        return response;
        
    }

    /*
    public override SYS_IntegrationLog__c generatelogForOutboundResult(HttpResponse resp,SYS_IntegrationLog__c log){

        SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            logResp.Request_Digest__c = generateHash(resp.getBody(),algo);

        logResp.Force_Sync__c = log.Force_Sync__c;

        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody());

            if(log.ObjectSettingId__c == 'StripeSubscription') {
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPDATE';
                logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;
                if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
            
                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                logResp.WhatId__c = log.WhatId__c;
                logResp.Type__c = 'RESPONSE';
                logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                logResp.ObjectSettingId__c = log.ObjectSettingId__c;
                log.Status__c = 'FAIL';

            } else {

                log.Status__c = 'FAIL';
                if(!log.Force_Sync__c)
                    log.retry__c = true;
    
                logResp.Status__c = 'ERROR';
                
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                logResp.WhatId__c = log.WhatId__c;
                logResp.Type__c = 'RESPONSE';
                logResp.How_To_Process__c = 'ignore_log';
                logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            }
        }
        else{
            log.Status__c = 'DONE';

            if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPDATE';
                logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;

                if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                
                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            
            } else if(log.SYS_Operation_Type__c == 'DELETE') {
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPSERT';
                logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;

                if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                
                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            }
            else{

                
                if(SYS_DataCacheFactory.OBJ_TYPE != NULL && SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Always_Ignore_Response__c){
                        logResp.How_To_Process__c = 'ignore_log';
                        logResp.Status__c = 'DONE';
                }
                else{
                    logResp.SYS_Operation_Type__c = 'UPSERT';
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                }
                //logResp.Status__c = 'DONE';
                //logResp.How_To_Process__c = 'ignore_log';

            }
        
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            logResp.ObjectSettingId__c = log.ObjectSettingId__c;
            
        }

        //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
        SYS_Helper.upsertLog(log);
        logResp.SYS_RequestId__c = log.Id;

        return logResp;
    }
    */

    /* ------------------------------------------------------------------------ */

    public override List<SYS_IntegrationLog__c> generatelogForOutboundResultNew(HttpResponse resp,SYS_IntegrationLog__c log ){

        SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();
        String responseJsonBody = resp.getBody();

        //If JSON is large chunk into multiple SYS_logs
        if(responseJsonBody != NULL && responseJsonBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
            logAfterPartition = SYS_Helper.getLogsAfterPartition(responseJsonBody);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                // SYS_Helper.upsertLog(logs[0]);
                // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                
                // SYS_Helper.upsertLog(childs);
                logResp = logAfterPartition[0];
            }
        } else {
            logResp =  SYS_Helper.getLogsToInsert(responseJsonBody);
        }

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            logResp.Request_Digest__c = generateHash(responseJsonBody,algo);

        logResp.Force_Sync__c = log.Force_Sync__c;

        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200){

            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+responseJsonBody);

            if (log.ObjectSettingId__c == 'StripeSubscription') {
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPDATE';
                logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;
                if (SYS_DataCacheFactory.OBJ_TYPE != NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;

                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                logResp.WhatId__c = log.WhatId__c;
                logResp.Type__c = 'RESPONSE';
                logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                logResp.ObjectSettingId__c = log.ObjectSettingId__c;
                log.Status__c = 'FAIL';

            } else {

                log.Status__c = 'FAIL';
                if (!log.Force_Sync__c)
                    log.retry__c = true;

                logResp.Status__c = 'ERROR';

                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                logResp.WhatId__c = log.WhatId__c;
                logResp.Type__c = 'RESPONSE';
                logResp.How_To_Process__c = 'ignore_log';
                logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            }
        } else {
            log.Status__c = 'DONE';

            if (log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c) {
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPDATE';

                if (SYS_DataCacheFactory.OBJ_TYPE != NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;

                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;

            } else if (log.SYS_Operation_Type__c == 'DELETE') {
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPSERT';

                if (SYS_DataCacheFactory.OBJ_TYPE != NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;

                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            } else {

                if (SYS_DataCacheFactory.OBJ_TYPE != NULL && SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Always_Ignore_Response__c) {
                    logResp.How_To_Process__c = 'ignore_log';
                    logResp.Status__c = 'DONE';
                } else {
                    logResp.SYS_Operation_Type__c = 'UPSERT';
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                }
                //logResp.Status__c = 'DONE';
                //logResp.How_To_Process__c = 'ignore_log';

            }
            logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            logResp.ObjectSettingId__c = log.ObjectSettingId__c;

        }
        
        logResp.SYS_RequestId__c = log.Id;
        if(log.Id == NULL && log.UUID__c == NULL) {
            log.UUID__c = SYS_Helper.getUUID();
            logResp.Parent_UUID__c = log.UUID__c;
        }
        List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
        returnVal.add(log);
        returnVal.add(logResp);
        if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
            logResp.Status__c = 'PENDING_PARTITIONED_LOOKUP';
            for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                returnVal.add(logAfterPartition[i]);
            }
        }
        return returnVal;
    }


}