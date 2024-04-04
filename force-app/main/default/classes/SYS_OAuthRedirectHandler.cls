@RestResource(urlMapping='/v1/callback/*')
global without sharing class SYS_OAuthRedirectHandler extends SYS_ApplicationService{

    private static String authCode;
    private static String calloutUrl;

	@HttpGet
    global static void doGet(){
        if(RestContext.response!=NULL){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.addHeader('Access-Control-Allow-Origin', '*');
        }
        String code= RestContext.request.params.get('code');
        String state = RestContext.request.params.get('state');
        authCode = code;
        
        String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c')+' FROM SYS_OAuthConfig__c';
        String whereClause = ' WHERE Id =\''+String.escapeSingleQuotes(state)+'\'';
        List<SYS_OAuthConfig__c> configs = Database.query(String.escapeSingleQuotes(query)+whereClause);
        
        if(configs.size()>0){
            //calloutUrl = configs[0].Token_Endpoint__c;
            try{

                SYS_DataCache.OBJ_TYPE = configs[0].Object_Setting__c;
                SYS_DataCache.INT_TYPE = SYS_DataCache.objectSettingMap.get(configs[0].Object_Setting__c).IntegrationType__r.DeveloperName;
                SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
                List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
                
                SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.objectSettingMap.get(SYS_DataCache.OBJ_TYPE).ApexHandler__c).newInstance();
                Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(configs);
                
                if(jsonListForOutbound.values().size() > 0){
                    for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                        String finalJsonForOutbound;

                        finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));

                        newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                        newSysLog.Status__c = SYS_Constants.NEW_STATUS;
                        newSysLog.HTTP_Method__c = 'POST';
                        newSysLog.Type__c = SYS_Constants.OUTBOUND;
                        newSysLog.Integration_Setting__c = SYS_DataCache.INT_TYPE;
                        newSysLog.How_to_process__c = 'use_object_setting';
                        newSysLog.ObjectSettingId__c = SYS_DataCache.OBJ_TYPE;
                        newSysLog.SYS_Operation_Type__c = 'INSERT';
                        //newSysLog.Callout_URL__c = calloutUrl;
                        newSysLog.Custom_Field_Value__c = code;
                        newSysLog.WhatId__c = state;
                        
                        newSysLog.retry__c = false;
                        insertSysLog.add(newSysLog);
                    }

                    if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
                        new SYS_IntegrationLogOutboundImmediate(insertSysLog).execute();
                    }
                    if(RestContext.response!=null)
                    RestContext.response.responseBody = 
                    Blob.valueOf('Token Generated succesfully.');
                    
                }
            }catch(Exception e){
                if(RestContext.response!=null)
                RestContext.response.responseBody = 
                    Blob.valueOf('Something went wrong while trying to call token url \n'+e.getMessage() + '\n' +e.getStackTraceString());
            }
            

        }else{
            RestContext.response.responseBody = Blob.valueOf('{"error":'+'Invalid Config Id. Authentication Failed'+'}');
        }
        
    }
        
    global override sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){
        if(value==NULL) return sObj;
        sObj.put(mapping.FieldApiName__c,SYS_Helper.secondsToDatetime(String.valueOf(value)));
        return sObj;
    }

    global override String preprocessJSONForOutbound(SYS_IntegrationLog__c log,String jsonBody,HttpRequest req) {
        
        String formUrlEncodedBody='';
        Map<String,Object> jsonobj = SYS_Helper.getFlatKeys(jsonBody, 'A[B]');//(Map<String,Object>)JSON.deserializeUntyped(flatJSON);
        List<String> reqkeymap = new List<String>(jsonobj.keySet());
        List<String> keyValueList = new List<String>();
        reqkeymap.sort();

        for (String key: reqkeymap) {
            if (!String.isBlank(key)){
                keyValueList.add(key.toLowerCase() + '=' + EncodingUtil.urlEncode(String.valueOf(jsonobj.get(key)!=NULL?jsonobj.get(key):''),'UTF-8'));
            }
        }
        if(authCode!=NULL)
        keyValueList.add('code' + '=' + EncodingUtil.urlEncode(authCode,'UTF-8'));

        formUrlEncodedBody = String.join(keyValueList,'&');
        log.data1__c = formUrlEncodedBody; 

        jsonBody = formUrlEncodedBody;
        
        return jsonBody;
    }
    
    global override String getHttpRequestEndpoint(HttpRequest req,SYS_IntegrationLog__c log, String externalId){
        if( externalId != NULL ) {
            String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_OAuthConfig__c')+' FROM SYS_OAuthConfig__c';
            String whereClause = ' WHERE Id =\''+String.escapeSingleQuotes(externalId)+'\'';
            List<SYS_OAuthConfig__c> configs = Database.query(String.escapeSingleQuotes(query)+whereClause);
            
            if(configs.size()>0) {
                calloutUrl = configs[0].Token_Endpoint__c;
            }    
        }
		
        if(calloutUrl != NULL){
            return calloutUrl;
        }
        
        if(log.Callout_URL__c!=NULL){
            return log.Callout_URL__c;
        }
        
        String urlFromPattern = SYS_Helper.urlFromPattern(log.HTTP_Method__c, log.WhatId__c);
        
        if(urlFromPattern != null){
            log.Callout_URL__c = urlFromPattern;
            return log.Callout_URL__c;
        }
        else{
            String baseEndpoint = SYS_DataCacheFactory.integrationSetting.BaseAPIEndPoint__c;
            String resourceUrl = baseEndpoint + SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ResourcePath__c;
            
            /*--*/SYS_debug.log('====== MS Endpoint check:'+resourceUrl);

            //Log is to create resource
            if(req.getMethod() == 'POST' && (externalId == NULL || externalId == '')){
                String urlParams='';
                if(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).url_params__c != NULL)
                        urlParams = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).url_params__c;
                
                if(urlParams!=''){
                    resourceUrl+='/'+urlParams;
                }
            }
            else{
                //Method is PUT / PATCH / DELETE / GET - so the URL will be of the form https://<xyz.abc>/v1/resource/:id
                resourceUrl+= '/'+ externalId;
            }
            /*--*/SYS_debug.log('====== MS Endpoint check:'+resourceUrl);
            log.Callout_URL__c = resourceUrl;
            return resourceUrl;
        }
        
    }
    
}