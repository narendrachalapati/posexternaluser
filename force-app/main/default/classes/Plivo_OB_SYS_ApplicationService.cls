public class Plivo_OB_SYS_ApplicationService extends SYS_ApplicationService {
    public Plivo_OB_SYS_ApplicationService() {

    }
    /* ---------------  Outbound Immediate Response Processing  ----------------------*/
    //Immediate Response Wrapper
    public class PlivoMessage {
        public String message ;
        public List<String> message_uuid ;
        public String api_id ;
    }
    
    //Add Immediate Outbound Response Syslog to Upsert Using Custom Apex Handler
    public override List<SYS_IntegrationLog__c> generatelogForOutboundResultNew(HttpResponse resp,SYS_IntegrationLog__c log){
        SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();
        String responseJsonBody = resp.getBody();

        //GET Request Log to identify Activity Type
        Map<String, Object> requestFlatKeyMap = new Map<String, Object>();
        Boolean isMMSRequest, containsTypeKey = false;
        String requestJson = SYS_Helper.getDataFrom(log);
        if(String.isNotBlank(requestJson)) {
            Object requestLogObjectType = JSON.deserializeUntyped(requestJson);
            if(requestLogObjectType instanceof Map<String,Object>){
                requestFlatKeyMap = (SYS_Helper.getFlatKeys(requestJson ,'A.B')); 
                containsTypeKey = requestFlatKeyMap.containsKey('type');
                if(containsTypeKey == true){
                    String eventTypesms = (String)requestFlatKeyMap.get('type');
                    isMMSRequest = (eventTypesms == 'mms') ? true : false;
                }           
            }
        }

        //Check if Response was success
        if(resp.getStatusCode() == 202 || resp.getStatusCode() == 201 || resp.getStatusCode() == 200){
            //For Success Plivo outbound Parse Json using wrapper and modify json 
            Object convert = System.JSON.deserializeUntyped(responseJsonBody);
            if(convert instanceof Map<String, Object> && ( ((Map<String, Object>)convert).get('api_id') != null) 
                            && ( ((Map<String, Object>)convert).get('message_uuid') != null)
                            && ( ((Map<String, Object>)convert).get('message') != null) ) {            
                PlivoMessage plivoRespObj = (PlivoMessage)System.JSON.deserialize(responseJsonBody,PlivoMessage.class);
                String messageUUID = String.valueof(plivoRespObj.message_uuid[0]);
                String messageTypeString = (isMMSRequest == true) ? 'mms' : 'sms';

                ((Map<String, Object>)convert).put('messageuuid', messageUUID); 
                ((Map<String, Object>)convert).put('type', messageTypeString);
                ((Map<String, Object>)convert).put('direction', 'outbound');
                ((Map<String, Object>)convert).put('status', 'Sending'); 
                ((Map<String, Object>)convert).put('error', ''); 
                responseJsonBody = JSON.serialize(convert);
            }

            //Check and modify json for GET Call Recording Response
            Map<String, Object> newflatKeyMap = new Map<String, Object>();
            Boolean containsCallKey,containsRecordingIdKey = false;
            if(convert instanceof Map<String,Object>){
                newflatKeyMap = (SYS_Helper.getFlatKeys(responseJsonBody ,'A.B'));  
                containsCallKey = newflatKeyMap.containsKey('plivoevent');
                containsRecordingIdKey = newflatKeyMap.containsKey('recording_id');
            }
            if( (containsRecordingIdKey == true) && (containsCallKey == false) ){//Recording Get Call
                String eventType = 'callrecording';
                ((Map<String, Object>)convert).put('type', eventType);
                ((Map<String, Object>)convert).put('activitytype', 'Call');
                
                String recording_duration_ms = (String)newflatKeyMap.get('recording_duration_ms');
                recording_duration_ms = recording_duration_ms.split('\\.')[0];
                String recording_start_ms = (String)newflatKeyMap.get('recording_start_ms');
                recording_start_ms = recording_start_ms.split('\\.')[0];
                String recording_end_ms = (String)newflatKeyMap.get('recording_end_ms');
                recording_end_ms = recording_end_ms.split('\\.')[0];
                Integer recordDurationnumber = Integer.valueOf(recording_duration_ms)/1000;
                String recordingDuration = String.valueOf(recordDurationnumber);
                ((Map<String, Object>)convert).put('recording_duration_ms', recording_duration_ms);
                ((Map<String, Object>)convert).put('recording_duration', recordingDuration);
                ((Map<String, Object>)convert).put('recording_start_ms', recording_start_ms);
                ((Map<String, Object>)convert).put('recording_end_ms', recording_end_ms);
                responseJsonBody = JSON.serialize(convert);
            }
        }

        //If JSON is large chunk into multiple SYS_logs
        if(responseJsonBody != NULL && responseJsonBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
            List<SYS_IntegrationLog__c> logs = SYS_Helper.getLogsAfterPartition(responseJsonBody);
            if(logs != NULL && logs.size() > 0) {
                // SYS_Helper.upsertLog(logs[0]);
                // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                
                // SYS_Helper.upsertLog(childs);
                logResp = logs[0];
            }
        } else {
            logResp =  SYS_Helper.getLogsToInsert(responseJsonBody);
        }

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            logResp.Request_Digest__c = generateHash(responseJsonBody,algo);

        logResp.Force_Sync__c = log.Force_Sync__c;

        //Added Status 202 - Error Log Generation Creteria
        if(resp.getStatusCode() != 202 && resp.getStatusCode() != 201 && resp.getStatusCode() != 200){
            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+responseJsonBody);

            //Handle Plivo SMS Outbound Error 
            if (log.ObjectSettingId__c == 'PlivoSMS') {
                logResp.Status__c = 'NEW';
                try {
                    Object responseLogConvert = System.JSON.deserializeUntyped(responseJsonBody);
                    if ((responseLogConvert instanceof Map < String, Object > ) && (((Map < String, Object > ) responseLogConvert).get('error') != null)) {
                        ((Map < String, Object > ) responseLogConvert).put('status', 'Failed');
                        responseJsonBody = JSON.serialize(responseLogConvert);
                        logResp = SYS_Helper.getLogsToInsert(responseJsonBody);
                    }
                } catch (Exception e) {
                    String errorMessage = responseJsonBody.replaceAll('\\r\\n|\\r|\\n', '');
                    responseJsonBody = '{"status" : "Failed", "error" : "' + errorMessage + '"}';
                    logResp = SYS_Helper.getLogsToInsert(responseJsonBody);
                }
                

                logResp.SYS_Operation_Type__c = 'UPDATE';
                logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;
                if (SYS_DataCacheFactory.OBJ_TYPE != NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;

                logResp.How_To_Process__c = 'use_custom_apex_handler';                
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            } else {
                log.Status__c = 'FAIL';
                logResp.Status__c = 'ERROR';
                logResp.How_To_Process__c = 'ignore_log';                
            }

            //Set Error Default Values            
            if (!log.Force_Sync__c)
                log.retry__c = true;

            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE; 
            logResp.ObjectSettingId__c = log.ObjectSettingId__c;             
        } else {
            log.Status__c = 'DONE';

            if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
                logResp.Status__c = 'NEW';
                logResp.SYS_Operation_Type__c = 'UPDATE';

                if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                    logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                
                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            
            } else {
                if(SYS_DataCacheFactory.OBJ_TYPE != NULL && SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Always_Ignore_Response__c){
                        logResp.How_To_Process__c = 'ignore_log';
                        logResp.Status__c = 'DONE';
                } else {
                    logResp.SYS_Operation_Type__c = 'UPSERT';
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                }

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

    /* ------------------------------------------------------------------------ */
    /**
     * OUTBOUND
     * This hook is called from SYS_Transformer to set values for JSON record
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    /* ---------------  Modifying SMS Message Callback URL with record Id parameter  ----------------------*/
    public override Object getFieldValues(sObject obj, FieldSetting__mdt mapping, String fieldAPIName){
        //TODO - handle case - Account."CreatedBy".Name, where CreatedBy is not an sobject - This can be handled by overriding the current method and add the handler
        // on field setting

        String fvalue= (mapping.Send_Blanks_as_Empty_String__c)?'':null;
        if( (fieldAPIName == null) && (mapping.Key__c == 'url') ){//SMS_Message_Callback_URL override
            //https://*.my.salesforce-sites.com/MunicornSMS/services/apexrest/municorn/v1/Plivo?token=TQo5GqOWQERRW&activityrecordid=222
            fvalue = System.Label.GuestSiteLink + '' + mapping.StaticValue__c + '&activityrecordid=' + obj.get('Id');
        } else if(fieldAPIName == null){
            fvalue = mapping.StaticValue__c;
        } else if(fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)){
            List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
            try{
                for(Integer i = 0; i < splitedFields.size() - 1; i++){
                    obj = obj.getSobject(splitedFields[i]);   
                } 
                return obj.get(splitedFields[splitedFields.size()-1]);
            }catch(exception ex){
               /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
               return null;
            }
            
        } else if(obj.get(fieldAPIName)!=null){
            return obj.get(fieldAPIName);
        }
        return fvalue;
    }


    public override String sanitizeJSONForOutbound(String jsonRecord){
        String finalJSON = jsonRecord.replace('\n',' ');

        //Deserilize JSON and Map Keys 
        Map<String, Object> requestFlatKeyMap = new Map<String, Object>();
        Boolean isMMSRequest, containsTypeKey = false;
        Object responseType = JSON.deserializeUntyped(finalJSON);
        if(responseType instanceof Map<String,Object>){
            requestFlatKeyMap = (SYS_Helper.getFlatKeys(finalJSON ,'A.B')); 
            containsTypeKey = requestFlatKeyMap.containsKey('type');
            if(containsTypeKey == true){
                String eventTypesms = (String)requestFlatKeyMap.get('type');
                isMMSRequest = (eventTypesms == 'mms') ? true : false;
                // if(eventTypesms == 'mms'){
                //     ((Map < String, Object > ) responseType).remove('text');
                // }
                if(eventTypesms == 'sms'){
                    ((Map < String, Object > ) responseType).remove('media_urls');
                    String newjsonBody = JSON.serialize(responseType);
                    SYS_debug.log('newjsonBody ' + newjsonBody);
                    finalJSON = newjsonBody;
                }
            }           
        }

        return finalJSON;
    }

    public override void setHttpRequestHeaders(HttpRequest req,SYS_IntegrationLog__c log){
        
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
            SYS_debug.log('MS Header:'+req.getHeader('Authorization'));
        }
    }

}